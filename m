From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 2/10] bonding: rebuild the lock use for bond_mii_monitor()
Date: Fri, 08 Nov 2013 16:28:03 +0100
Message-ID: <527D0303.8030806@redhat.com>
References: <527C4771.90207@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757398Ab3KHPb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 10:31:28 -0500
In-Reply-To: <527C4771.90207@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2013 03:07 AM, Ding Tianhong wrote:
> The bond_mii_monitor() still use bond lock to protect bond slave list,
> it is no effect, I have 2 way to fix the problem, move the RTNL to the
> top of the function, or add RCU to protect the bond_has_slaves() and
> bond_miimon_inspect(), according to the Jay Vosburgh's opinion, 10 times
> one second is a truely big performance loss if use RTNL to protect the
> whole function, so I would take the advice and use RCU to protect the
> two functions, of course it need to add more modify, the
> bond_has_slave_rcu() is add for RCU use, and the bond_for_each_slave
> need to replace with bond_for_each_slave_rcu in bond_miimon_inspect.
> 
> I move the peer notify before the queue_delayed_work(), and obviously
> it is no need to lock the RTNL twice if call bond_miimon_commit() and
> peer notify together, other path is no logic change, I think the
> performance is better than before.
> 
> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/bonding/bond_main.c | 40 ++++++++++++++++++++--------------------
>  drivers/net/bonding/bonding.h   |  6 ++++++
>  2 files changed, 26 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index ba18719..def489d 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1913,7 +1913,7 @@ static int bond_miimon_inspect(struct bonding *bond)
>  
>  	ignore_updelay = !bond->curr_active_slave ? true : false;
>  
> -	bond_for_each_slave(bond, slave, iter) {
> +	bond_for_each_slave_rcu(bond, slave, iter) {
>  		slave->new_link = BOND_LINK_NOCHANGE;
>  
>  		link_state = bond_check_dev_link(bond, slave->dev, 0);
> @@ -2111,47 +2111,47 @@ void bond_mii_monitor(struct work_struct *work)
>  	bool should_notify_peers = false;
>  	unsigned long delay;
>  
> -	read_lock(&bond->lock);
> -
>  	delay = msecs_to_jiffies(bond->params.miimon);
>  
> -	if (!bond_has_slaves(bond))
> +	rcu_read_lock();
> +
> +	if (!bond_has_slaves_rcu(bond)) {
> +		rcu_read_unlock();
In fact the bond cannot disappear while this function is running, so this test
should be able to run outside the RCU region if I'm not missing something :-)
It'll be just as useful as running inside the region, at most a free run may
happen if there's one slave and it disappears.

>  		goto re_arm;
> +	}
>  
>  	should_notify_peers = bond_should_notify_peers(bond);
bond_should_notify_peers() is not RCU-safe, it uses curr_active_slave directly.

>  
>  	if (bond_miimon_inspect(bond)) {
> -		read_unlock(&bond->lock);
> +		rcu_read_unlock();
>  
>  		/* Race avoidance with bond_close cancel of workqueue */
>  		if (!rtnl_trylock()) {
> -			read_lock(&bond->lock);
>  			delay = 1;
> -			should_notify_peers = false;
>  			goto re_arm;
>  		}
>  
> -		read_lock(&bond->lock);
> -
>  		bond_miimon_commit(bond);
>  
> -		read_unlock(&bond->lock);
> +		if (should_notify_peers)
> +			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
> +					bond->dev);
> +
>  		rtnl_unlock();	/* might sleep, hold no other locks */
> -		read_lock(&bond->lock);
> +	} else {
> +		rcu_read_unlock();
> +		if (should_notify_peers) {
> +			if (!rtnl_trylock())
> +				goto re_arm;
> +			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
> +					bond->dev);
> +			rtnl_unlock();
> +		}
>  	}
>  
>  re_arm:
>  	if (bond->params.miimon)
>  		queue_delayed_work(bond->wq, &bond->mii_work, delay);
> -
> -	read_unlock(&bond->lock);
> -
> -	if (should_notify_peers) {
> -		if (!rtnl_trylock())
> -			return;
> -		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
> -		rtnl_unlock();
> -	}
>  }
>  
>  static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 046a605..deb9738 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -81,6 +81,12 @@
>  
>  #define bond_has_slaves(bond) !list_empty(bond_slave_list(bond))
>  
> +#define bond_has_slaves_rcu(bond)	\
> +	({struct list_head *__ptr = (bond_slave_list(bond)); \
> +	 struct list_head *__next = ACCESS_ONCE(__ptr->next); \
> +	 __ptr != __next; \
> +	 })
> +
This is unnecessary, bond_has_slaves() should be enough. See bond_start_xmit()
and also the list_empty comment in include/linux/rculist.h for more information why.
My bond_has_slaves() comments apply to all the patches that use it.

>  /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
>  #define bond_first_slave(bond) \
>  	(bond_has_slaves(bond) ? \
> 
