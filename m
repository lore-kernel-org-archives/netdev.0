From: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use flush_delayed_work_sync
 in bond_close
Date: Fri, 28 Oct 2011 10:52:31 +0900
Message-ID: <4EAA0ADF.5020504@hitachi.com>
References: <20111019081757.12455.24788.stgit@ltc219.sdl.hitachi.co.jp> <27007.1319047262@death> <20111019114129.162d895a@nehalam.linuxnetplumber.net> <29731.1319051397@death> <CAM_iQpV8089aU8gfeo8KotTNXQbx4ficMeBX69Nin_yXzqcEKg@mail.gmail.com> <17144.1319178396@death> <14766.1319245142@death> <4EA4E2EE.4050201@hitachi.com> <2216.1319650260@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2216.1319650260@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joy,

I checked your patch, and any problems have not been observed for
almost one day although I could reproduce the BUG in the latest net-next
without it. 

I think this patch works well.

Tested-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>


(2011/10/27 2:31), Jay Vosburgh wrote:
> HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com> wrote:
> [...]
>> The interval of mii_mon was set to 1 to reproduce this bug easily and 
>> the 802.3ad mode was used. Then, I executed the following command.
>>
>> # while true; do ifconfig bond0 down; done &
>> # while true; do ifconfig bond0 up; done &
>>
>> This bug rarely occurs since it is the severe timing problem.
>> I found that it is more easily to reproduce this bug when using guest OS.
>>
>> For example, it took one to three days for me to reproduce it on host OS, 
>> but some hours on guest OS.
> 
> 	Could you test this patch and see if it resolves the problem?
> 
> 	This patch does a few things:
> 
> 	All of the monitor functions that run on work queues are
> modified to never unconditionally acquire RTNL; all will reschedule the
> work and return if rtnl_trylock fails.  This covers bond_mii_monitor,
> bond_activebackup_arp_mon, and bond_alb_monitor.
> 
> 	The "clear out the work queues" calls in bond_close and
> bond_uninit now call cancel_delayed_work_sync, which should either
> delete a pending work item, or wait for an executing item to complete.
> I chose cancel_ over the original patch's flush_ because we just want
> the work queue stopped.  We don't need to have any pending items execute
> if they're not already running.
> 
> 	Also in reference to the previous, I'm not sure if we still need
> to check for delayed_work_pending, but I've left those checks in place.
> 
> 	Remove the "kill_timers" field and all references to it.  If
> cancel_delayed_work_sync is safe to use, we do not need an extra
> sentinel.
> 
> 	Lastly, for testing purposes only, the bond_alb_monitor in this
> patch includes an unconditional call to rtnl_trylock(); this is an
> artifical way to make the race in that function easier to test for,
> because the real race is very difficult to hit.
> 
> 	This patch is against net-next as of yesterday.
> 
> 	Comments?
> 
> 	-J
> 
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index b33c099..0ae0d7c 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2110,9 +2110,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>  
>  	read_lock(&bond->lock);
>  
> -	if (bond->kill_timers)
> -		goto out;
> -
>  	//check if there are any slaves
>  	if (bond->slave_cnt == 0)
>  		goto re_arm;
> @@ -2161,9 +2158,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>  	}
>  
>  re_arm:
> -	if (!bond->kill_timers)
> -		queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
> -out:
> +	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
> +
>  	read_unlock(&bond->lock);
>  }
>  
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index d4fbd2e..13d1bf9 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -1343,10 +1343,6 @@ void bond_alb_monitor(struct work_struct *work)
>  
>  	read_lock(&bond->lock);
>  
> -	if (bond->kill_timers) {
> -		goto out;
> -	}
> -
>  	if (bond->slave_cnt == 0) {
>  		bond_info->tx_rebalance_counter = 0;
>  		bond_info->lp_counter = 0;
> @@ -1394,6 +1390,14 @@ void bond_alb_monitor(struct work_struct *work)
>  		bond_info->tx_rebalance_counter = 0;
>  	}
>  
> +	/* XXX - unconditional attempt at RTNL for testing purposes, as
> +	 * normal case, below, is difficult to induce.
> +	 */
> +	read_unlock(&bond->lock);
> +	if (rtnl_trylock())
> +		rtnl_unlock();
> +	read_lock(&bond->lock);
> +
>  	/* handle rlb stuff */
>  	if (bond_info->rlb_enabled) {
>  		if (bond_info->primary_is_promisc &&
> @@ -1404,7 +1408,10 @@ void bond_alb_monitor(struct work_struct *work)
>  			 * nothing else.
>  			 */
>  			read_unlock(&bond->lock);
> -			rtnl_lock();
> +			if (!rtnl_trylock()) {
> +				read_lock(&bond->lock);
> +				goto re_arm;
> +			}
>  
>  			bond_info->rlb_promisc_timeout_counter = 0;
>  
> @@ -1440,9 +1447,8 @@ void bond_alb_monitor(struct work_struct *work)
>  	}
>  
>  re_arm:
> -	if (!bond->kill_timers)
> -		queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
> -out:
> +	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
> +
>  	read_unlock(&bond->lock);
>  }
>  
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 71efff3..e6fefff 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -774,9 +774,6 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
>  
>  	read_lock(&bond->lock);
>  
> -	if (bond->kill_timers)
> -		goto out;
> -
>  	/* rejoin all groups on bond device */
>  	__bond_resend_igmp_join_requests(bond->dev);
>  
> @@ -790,9 +787,9 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
>  			__bond_resend_igmp_join_requests(vlan_dev);
>  	}
>  
> -	if ((--bond->igmp_retrans > 0) && !bond->kill_timers)
> +	if (--bond->igmp_retrans > 0)
>  		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
> -out:
> +
>  	read_unlock(&bond->lock);
>  }
>  
> @@ -2518,19 +2515,26 @@ void bond_mii_monitor(struct work_struct *work)
>  	struct bonding *bond = container_of(work, struct bonding,
>  					    mii_work.work);
>  	bool should_notify_peers = false;
> +	unsigned long delay;
>  
>  	read_lock(&bond->lock);
> -	if (bond->kill_timers)
> -		goto out;
> +
> +	delay = msecs_to_jiffies(bond->params.miimon);
>  
>  	if (bond->slave_cnt == 0)
>  		goto re_arm;
>  
> -	should_notify_peers = bond_should_notify_peers(bond);
> -
>  	if (bond_miimon_inspect(bond)) {
>  		read_unlock(&bond->lock);
> -		rtnl_lock();
> +
> +		/* Race avoidance with bond_close flush of workqueue */
> +		if (!rtnl_trylock()) {
> +			read_lock(&bond->lock);
> +			delay = 1;
> +			should_notify_peers = false;
> +			goto re_arm;
> +		}
> +
>  		read_lock(&bond->lock);
>  
>  		bond_miimon_commit(bond);
> @@ -2540,15 +2544,21 @@ void bond_mii_monitor(struct work_struct *work)
>  		read_lock(&bond->lock);
>  	}
>  
> +	should_notify_peers = bond_should_notify_peers(bond);
> +
>  re_arm:
> -	if (bond->params.miimon && !bond->kill_timers)
> -		queue_delayed_work(bond->wq, &bond->mii_work,
> -				   msecs_to_jiffies(bond->params.miimon));
> -out:
> +	if (bond->params.miimon)
> +		queue_delayed_work(bond->wq, &bond->mii_work, delay);
> +
>  	read_unlock(&bond->lock);
>  
>  	if (should_notify_peers) {
> -		rtnl_lock();
> +		if (!rtnl_trylock()) {
> +			read_lock(&bond->lock);
> +			bond->send_peer_notif++;
> +			read_unlock(&bond->lock);
> +			return;
> +		}
>  		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
>  		rtnl_unlock();
>  	}
> @@ -2790,9 +2800,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
>  
>  	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>  
> -	if (bond->kill_timers)
> -		goto out;
> -
>  	if (bond->slave_cnt == 0)
>  		goto re_arm;
>  
> @@ -2889,9 +2896,9 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
>  	}
>  
>  re_arm:
> -	if (bond->params.arp_interval && !bond->kill_timers)
> +	if (bond->params.arp_interval)
>  		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
> -out:
> +
>  	read_unlock(&bond->lock);
>  }
>  
> @@ -3132,9 +3139,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
>  
>  	read_lock(&bond->lock);
>  
> -	if (bond->kill_timers)
> -		goto out;
> -
>  	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>  
>  	if (bond->slave_cnt == 0)
> @@ -3144,7 +3148,15 @@ void bond_activebackup_arp_mon(struct work_struct *work)
>  
>  	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
>  		read_unlock(&bond->lock);
> -		rtnl_lock();
> +
> +		/* Race avoidance with bond_close flush of workqueue */
> +		if (!rtnl_trylock()) {
> +			read_lock(&bond->lock);
> +			delta_in_ticks = 1;
> +			should_notify_peers = false;
> +			goto re_arm;
> +		}
> +
>  		read_lock(&bond->lock);
>  
>  		bond_ab_arp_commit(bond, delta_in_ticks);
> @@ -3157,13 +3169,18 @@ void bond_activebackup_arp_mon(struct work_struct *work)
>  	bond_ab_arp_probe(bond);
>  
>  re_arm:
> -	if (bond->params.arp_interval && !bond->kill_timers)
> +	if (bond->params.arp_interval)
>  		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
> -out:
> +
>  	read_unlock(&bond->lock);
>  
>  	if (should_notify_peers) {
> -		rtnl_lock();
> +		if (!rtnl_trylock()) {
> +			read_lock(&bond->lock);
> +			bond->send_peer_notif++;
> +			read_unlock(&bond->lock);
> +			return;
> +		}
>  		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
>  		rtnl_unlock();
>  	}
> @@ -3425,8 +3442,6 @@ static int bond_open(struct net_device *bond_dev)
>  	struct slave *slave;
>  	int i;
>  
> -	bond->kill_timers = 0;
> -
>  	/* reset slave->backup and slave->inactive */
>  	read_lock(&bond->lock);
>  	if (bond->slave_cnt > 0) {
> @@ -3495,33 +3510,30 @@ static int bond_close(struct net_device *bond_dev)
>  
>  	bond->send_peer_notif = 0;
>  
> -	/* signal timers not to re-arm */
> -	bond->kill_timers = 1;
> -
>  	write_unlock_bh(&bond->lock);
>  
>  	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
> -		cancel_delayed_work(&bond->mii_work);
> +		cancel_delayed_work_sync(&bond->mii_work);
>  	}
>  
>  	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
> -		cancel_delayed_work(&bond->arp_work);
> +		cancel_delayed_work_sync(&bond->arp_work);
>  	}
>  
>  	switch (bond->params.mode) {
>  	case BOND_MODE_8023AD:
> -		cancel_delayed_work(&bond->ad_work);
> +		cancel_delayed_work_sync(&bond->ad_work);
>  		break;
>  	case BOND_MODE_TLB:
>  	case BOND_MODE_ALB:
> -		cancel_delayed_work(&bond->alb_work);
> +		cancel_delayed_work_sync(&bond->alb_work);
>  		break;
>  	default:
>  		break;
>  	}
>  
>  	if (delayed_work_pending(&bond->mcast_work))
> -		cancel_delayed_work(&bond->mcast_work);
> +		cancel_delayed_work_sync(&bond->mcast_work);
>  
>  	if (bond_is_lb(bond)) {
>  		/* Must be called only after all
> @@ -4368,26 +4380,22 @@ static void bond_setup(struct net_device *bond_dev)
>  
>  static void bond_work_cancel_all(struct bonding *bond)
>  {
> -	write_lock_bh(&bond->lock);
> -	bond->kill_timers = 1;
> -	write_unlock_bh(&bond->lock);
> -
>  	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
> -		cancel_delayed_work(&bond->mii_work);
> +		cancel_delayed_work_sync(&bond->mii_work);
>  
>  	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
> -		cancel_delayed_work(&bond->arp_work);
> +		cancel_delayed_work_sync(&bond->arp_work);
>  
>  	if (bond->params.mode == BOND_MODE_ALB &&
>  	    delayed_work_pending(&bond->alb_work))
> -		cancel_delayed_work(&bond->alb_work);
> +		cancel_delayed_work_sync(&bond->alb_work);
>  
>  	if (bond->params.mode == BOND_MODE_8023AD &&
>  	    delayed_work_pending(&bond->ad_work))
> -		cancel_delayed_work(&bond->ad_work);
> +		cancel_delayed_work_sync(&bond->ad_work);
>  
>  	if (delayed_work_pending(&bond->mcast_work))
> -		cancel_delayed_work(&bond->mcast_work);
> +		cancel_delayed_work_sync(&bond->mcast_work);
>  }
>  
>  /*
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 82fec5f..1aecc37 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -222,7 +222,6 @@ struct bonding {
>  			       struct slave *);
>  	rwlock_t lock;
>  	rwlock_t curr_slave_lock;
> -	s8       kill_timers;
>  	u8	 send_peer_notif;
>  	s8	 setup_by_slave;
>  	s8       igmp_retrans;
> 
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
