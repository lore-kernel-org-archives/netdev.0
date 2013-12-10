From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next v4 6/11] bonding: rebuild the lock use for bond_activebackup_arp_mon()
Date: Mon, 09 Dec 2013 18:39:03 -0800
Message-ID: <7308.1386643143@death.nxdomain>
References: <52A2D22F.1000902@huawei.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:43292 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab3LJCjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:39:09 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 9 Dec 2013 19:39:08 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DEA273E40026
	for <netdev@vger.kernel.org>; Mon,  9 Dec 2013 19:39:06 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA0axhf196966
	for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 01:36:59 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA2d5Mj007376
	for <netdev@vger.kernel.org>; Mon, 9 Dec 2013 19:39:06 -0700
In-reply-to: <52A2D22F.1000902@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The bond_activebackup_arp_mon() use the bond lock for read to
>protect the slave list, it is no effect, and the RTNL is only
>called for bond_ab_arp_commit() and peer notify, for the performance
>better, use RCU to replace with the bond lock, to the bond slave
>list need to called in RCU, add a new bond_first_slave_rcu()
>to get the first slave in RCU protection.
>
>In bond_ab_arp_probe(), the bond->current_arp_slave may changd
>if bond release slave, just like:
>
>	bond_ab_arp_probe()			bond_release()
>	cpu 0					cpu 1
>	...
>	if (bond->current_arp_slave...)		...
>	...				bond->current_arp_slave = NULl
>	bond->current_arp_slave->dev->name	...
>
>So the current_arp_slave need to dereference in the section.
>
>When bond_ab_arp_inspect() and should_notify_peers is true, the
>RTNL will called twice, it is a loss of performance, so make the
>two RTNL together to avoid performance loss.

	Just for the record, we cannot acquire RTNL every single pass of
the monitor (at typically ten per second), but the situation you cite is
rare, and the performance impact of two round trips on RTNL is minimal.
That said, if the code is clear, there's no disadvantage with arranging
for just one round trip on RTNL.

	In patch 2 of the series you reorganized the RTNL locking around
the inspect / notify_peers logic in bond_mii_monitor to be generally:

	if (inspect) {
		[ acquire RTNL ]
		[ do commit activity, et al ]

		if (should_notify_peers)
			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);

		[ release RNTL ]
	} else {
		if (should_notify_peers) {
			[ acquire RTNL ]
			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);
			[ release RTNL ]
		}
	}

	but in this patch, the new logic in bond_activebackup_arp_mon
is:

	if (inspect) {
		[ acquire RTNL ]
		[ do commit activity, et al ]

		if (should_notify_peers) {
			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);
			should_notify_peers = false;
		}
		[ release RNTL ]
	}

[ ... ]

re_arm:

	if (should_notify_peers) {
		[ acquire RTNL ]
		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS);
		[ release RTNL ]
	}


	Is there a reason not to have these both operate the same way?

	I found the version in bond_mii_monitor (from patch 2 of the
series) easier to follow than this version for bond_activebackup_arp_mon
(because the two calls are closer together, and the "should_notify_peers
= false" is easy to miss on a first read).

	-J

>Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
>Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 49 +++++++++++++++++++++--------------------
> 1 file changed, 25 insertions(+), 24 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 1f5e709..d9bb5ee 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2521,7 +2521,7 @@ re_arm:
>  * place for the slave.  Returns 0 if no changes are found, >0 if changes
>  * to link states must be committed.
>  *
>- * Called with bond->lock held for read.
>+ * Called with rcu_read_lock hold.
>  */
> static int bond_ab_arp_inspect(struct bonding *bond)
> {
>@@ -2530,7 +2530,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
> 	struct slave *slave;
> 	int commit = 0;
>
>-	bond_for_each_slave(bond, slave, iter) {
>+	bond_for_each_slave_rcu(bond, slave, iter) {
> 		slave->new_link = BOND_LINK_NOCHANGE;
> 		last_rx = slave_last_rx(bond, slave);
>
>@@ -2592,7 +2592,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
>  * Called to commit link state changes noted by inspection step of
>  * active-backup mode ARP monitor.
>  *
>- * Called with RTNL and bond->lock for read.
>+ * Called with RTNL hold.
>  */
> static void bond_ab_arp_commit(struct bonding *bond)
> {
>@@ -2667,19 +2667,20 @@ do_failover:
> /*
>  * Send ARP probes for active-backup mode ARP monitor.
>  *
>- * Called with bond->lock held for read.
>+ * Called with rcu_read_lock hold.
>  */
> static void bond_ab_arp_probe(struct bonding *bond)
> {
>-	struct slave *slave, *before = NULL, *new_slave = NULL;
>+	struct slave *slave, *before = NULL, *new_slave = NULL,
>+		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave);
> 	struct list_head *iter;
> 	bool found = false;
>
> 	read_lock(&bond->curr_slave_lock);
>
>-	if (bond->current_arp_slave && bond->curr_active_slave)
>+	if (curr_arp_slave && bond->curr_active_slave)
> 		pr_info("PROBE: c_arp %s && cas %s BAD\n",
>-			bond->current_arp_slave->dev->name,
>+			curr_arp_slave->dev->name,
> 			bond->curr_active_slave->dev->name);
>
> 	if (bond->curr_active_slave) {
>@@ -2695,15 +2696,15 @@ static void bond_ab_arp_probe(struct bonding *bond)
> 	 * for becoming the curr_active_slave
> 	 */
>
>-	if (!bond->current_arp_slave) {
>-		bond->current_arp_slave = bond_first_slave(bond);
>-		if (!bond->current_arp_slave)
>+	if (!curr_arp_slave) {
>+		curr_arp_slave = bond_first_slave_rcu(bond);
>+		if (!curr_arp_slave)
> 			return;
> 	}
>
>-	bond_set_slave_inactive_flags(bond->current_arp_slave);
>+	bond_set_slave_inactive_flags(curr_arp_slave);
>
>-	bond_for_each_slave(bond, slave, iter) {
>+	bond_for_each_slave_rcu(bond, slave, iter) {
> 		if (!found && !before && IS_UP(slave->dev))
> 			before = slave;
>
>@@ -2726,7 +2727,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
> 			pr_info("%s: backup interface %s is now down.\n",
> 				bond->dev->name, slave->dev->name);
> 		}
>-		if (slave == bond->current_arp_slave)
>+		if (slave == curr_arp_slave)
> 			found = true;
> 	}
>
>@@ -2740,8 +2741,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
> 	bond_set_slave_active_flags(new_slave);
> 	bond_arp_send_all(bond, new_slave);
> 	new_slave->jiffies = jiffies;
>-	bond->current_arp_slave = new_slave;
>-
>+	rcu_assign_pointer(bond->current_arp_slave, new_slave);
> }
>
> void bond_activebackup_arp_mon(struct work_struct *work)
>@@ -2751,17 +2751,17 @@ void bond_activebackup_arp_mon(struct work_struct *work)
> 	bool should_notify_peers = false;
> 	int delta_in_ticks;
>
>-	read_lock(&bond->lock);
>-
> 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>
> 	if (!bond_has_slaves(bond))
> 		goto re_arm;
>
>+	rcu_read_lock();
>+
> 	should_notify_peers = bond_should_notify_peers(bond);
>
> 	if (bond_ab_arp_inspect(bond)) {
>-		read_unlock(&bond->lock);
>+		rcu_read_unlock();
>
> 		/* Race avoidance with bond_close flush of workqueue */
> 		if (!rtnl_trylock()) {
>@@ -2771,23 +2771,24 @@ void bond_activebackup_arp_mon(struct work_struct *work)
> 			goto re_arm;
> 		}
>
>-		read_lock(&bond->lock);
>-
> 		bond_ab_arp_commit(bond);
>+		if (should_notify_peers) {
>+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
>+					bond->dev);
>+			should_notify_peers = false;
>+		}
>
>-		read_unlock(&bond->lock);
> 		rtnl_unlock();
>-		read_lock(&bond->lock);
>+		rcu_read_lock();
> 	}
>
> 	bond_ab_arp_probe(bond);
>+	rcu_read_unlock();
>
> re_arm:
> 	if (bond->params.arp_interval)
> 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>
>-	read_unlock(&bond->lock);
>-
> 	if (should_notify_peers) {
> 		if (!rtnl_trylock())
> 			return;
>-- 
>1.8.2.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
