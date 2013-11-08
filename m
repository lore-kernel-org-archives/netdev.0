From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 6/10] bonding: rebuild the lock use for bond_activebackup_arp_mon()
Date: Fri, 08 Nov 2013 17:01:51 +0100
Message-ID: <527D0AEF.1060802@redhat.com>
References: <527C4784.1030402@huawei.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:1166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757222Ab3KHQFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 11:05:18 -0500
In-Reply-To: <527C4784.1030402@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2013 03:08 AM, Ding Tianhong wrote:
> The bond_activebackup_arp_mon() use the bond lock for read to
> protect the slave list, it is no effect, and the RTNL is only
> called for bond_ab_arp_commit() and peer notify, for the performance
> better, use RCU instead of the bond lock, because the bond slave
> list need to called in RCU, add a new bond_first_slave_rcu()
> to get the first slave in RCU protection.
> 
> When bond_ab_arp_inspect() and should_notify_peers is true, the
> RTNL will called twice, it is a loss of performance, so make the
> two RTNL together to avoid performance loss.
> 
> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/bonding/bond_main.c | 35 +++++++++++++++++++----------------
>  drivers/net/bonding/bonding.h   |  7 +++++++
>  2 files changed, 26 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 759dcd0..b48ca55 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2524,7 +2524,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
>  	struct slave *slave;
>  	int commit = 0;
>  
> -	bond_for_each_slave(bond, slave, iter) {
> +	bond_for_each_slave_rcu(bond, slave, iter) {
>  		slave->new_link = BOND_LINK_NOCHANGE;
>  		last_rx = slave_last_rx(bond, slave);
>  
> @@ -2586,7 +2586,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
>   * Called to commit link state changes noted by inspection step of
>   * active-backup mode ARP monitor.
>   *
> - * Called with RTNL and bond->lock for read.
> + * Called with RTNL hold.
>   */
>  static void bond_ab_arp_commit(struct bonding *bond)
>  {
> @@ -2661,7 +2661,7 @@ do_failover:
>  /*
>   * Send ARP probes for active-backup mode ARP monitor.
>   *
> - * Called with bond->lock held for read.
> + * Called with rcu_read_lock hold.
>   */
>  static void bond_ab_arp_probe(struct bonding *bond)
>  {
> @@ -2690,14 +2690,14 @@ static void bond_ab_arp_probe(struct bonding *bond)
>  	 */
>  
>  	if (!bond->current_arp_slave) {
> -		bond->current_arp_slave = bond_first_slave(bond);
> +		bond->current_arp_slave = bond_first_slave_rcu(bond);
>  		if (!bond->current_arp_slave)
>  			return;
>  	}
>  
>  	bond_set_slave_inactive_flags(bond->current_arp_slave);
>  
> -	bond_for_each_slave(bond, slave, iter) {
> +	bond_for_each_slave_rcu(bond, slave, iter) {
>  		if (!found && !before && IS_UP(slave->dev))
>  			before = slave;
>  
> @@ -2745,43 +2745,46 @@ void bond_activebackup_arp_mon(struct work_struct *work)
>  	bool should_notify_peers = false;
>  	int delta_in_ticks;
>  
> -	read_lock(&bond->lock);
> -
>  	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>  
> -	if (!bond_has_slaves(bond))
> +	rcu_read_lock();
> +
> +	if (!bond_has_slaves_rcu(bond)) {
> +		rcu_read_unlock();
>  		goto re_arm;
> +	}
>  
>  	should_notify_peers = bond_should_notify_peers(bond);
Again, bond_should_notify_peers() is not RCU-safe.

>  
>  	if (bond_ab_arp_inspect(bond)) {
> -		read_unlock(&bond->lock);
> +		rcu_read_unlock();
>  
>  		/* Race avoidance with bond_close flush of workqueue */
>  		if (!rtnl_trylock()) {
> -			read_lock(&bond->lock);
>  			delta_in_ticks = 1;
>  			should_notify_peers = false;
>  			goto re_arm;
>  		}
>  
> -		read_lock(&bond->lock);
> -
>  		bond_ab_arp_commit(bond);
>  
> -		read_unlock(&bond->lock);
> +		if (should_notify_peers) {
> +			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
> +					bond->dev);
> +			should_notify_peers = false;
> +		}
> +
>  		rtnl_unlock();
> -		read_lock(&bond->lock);
> +		rcu_read_lock();
>  	}
>  
>  	bond_ab_arp_probe(bond);
Generally you might be safe in bond_ab_arp_probe() due to the synchronization
done by netdev_rx_handler_unregister(), but this code may run after that (and
after the unlinked slave) but before current_arp_slave is set to NULL and thus
use it. Now I don't see a direct problem with that, only a complication that can
bite us later. I vaguely remember that I re-worked the bond_ab_arp_probe() and
the way current_arp_slave works when doing this transition in my patches.

> +	rcu_read_unlock();
>  
>  re_arm:
>  	if (bond->params.arp_interval)
>  		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>  
> -	read_unlock(&bond->lock);
> -
>  	if (should_notify_peers) {
>  		if (!rtnl_trylock())
>  			return;
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index deb9738..90b745c 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -97,6 +97,13 @@
>  		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
>  		NULL)
>  
> +#define bond_first_slave_rcu(bond) \
> +	({struct list_head *__ptr = (bond_slave_list(bond)); \
> +	 struct list_head *__next = ACCESS_ONCE(__ptr->next); \
> +	 likely(__ptr != __next) ? \
> +	 netdev_adjacent_get_private_rcu(__next) : NULL; \
> +	 })
> +
Honestly, I don't like this, it sure can be re-written in a more
straight-forward manner.

>  #define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
>  #define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
>  
> 
