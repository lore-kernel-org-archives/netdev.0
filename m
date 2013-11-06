From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 5/9] bonding: rebuild the lock use for bond_activebackup_arp_mon()
Date: Wed, 6 Nov 2013 14:52:55 +0800
Message-ID: <5279E747.6020607@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5695 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab3KFGyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:54:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_activebackup_arp_mon() use the bond lock for read to
protect the slave list, it is no effect, and the RTNL is still
called for bond_ab_arp_monitor(), so move the RTNL to the top
of the monitor to protect the whole function is a clear way,
I also remove the curr_slave_lock for bond_select_active_slave(),
RTNL is enough here.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 57 +++++++++++------------------------------
 1 file changed, 15 insertions(+), 42 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b875dff..dc17a85 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2545,7 +2545,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
  * Called to commit link state changes noted by inspection step of
  * active-backup mode ARP monitor.
  *
- * Called with RTNL and bond->lock for read.
+ * Called with RTNL hold.
  */
 static void bond_ab_arp_commit(struct bonding *bond)
 {
@@ -2608,9 +2608,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 do_failover:
 		ASSERT_RTNL();
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
 
@@ -2620,7 +2618,7 @@ do_failover:
 /*
  * Send ARP probes for active-backup mode ARP monitor.
  *
- * Called with bond->lock held for read.
+ * Called with RNTL held.
  */
 static void bond_ab_arp_probe(struct bonding *bond)
 {
@@ -2628,8 +2626,6 @@ static void bond_ab_arp_probe(struct bonding *bond)
 	struct list_head *iter;
 	bool found = false;
 
-	read_lock(&bond->curr_slave_lock);
-
 	if (bond->current_arp_slave && bond->curr_active_slave)
 		pr_info("PROBE: c_arp %s && cas %s BAD\n",
 			bond->current_arp_slave->dev->name,
@@ -2637,12 +2633,9 @@ static void bond_ab_arp_probe(struct bonding *bond)
 
 	if (bond->curr_active_slave) {
 		bond_arp_send_all(bond, bond->curr_active_slave);
-		read_unlock(&bond->curr_slave_lock);
 		return;
 	}
 
-	read_unlock(&bond->curr_slave_lock);
-
 	/* if we don't have a curr_active_slave, search for the next available
 	 * backup slave from the current_arp_slave and make it the candidate
 	 * for becoming the curr_active_slave
@@ -2702,51 +2695,31 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	struct bonding *bond = container_of(work, struct bonding,
 					    arp_work.work);
 	bool should_notify_peers = false;
-	int delta_in_ticks;
-
-	read_lock(&bond->lock);
 
-	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
+	if (!rtnl_trylock())
+		goto re_arm;
 
-	if (!bond_has_slaves(bond))
+	if (!bond_has_slaves(bond)) {
+		rtnl_unlock();
 		goto re_arm;
+	}
 
 	should_notify_peers = bond_should_notify_peers(bond);
 
-	if (bond_ab_arp_inspect(bond)) {
-		read_unlock(&bond->lock);
-
-		/* Race avoidance with bond_close flush of workqueue */
-		if (!rtnl_trylock()) {
-			read_lock(&bond->lock);
-			delta_in_ticks = 1;
-			should_notify_peers = false;
-			goto re_arm;
-		}
-
-		read_lock(&bond->lock);
-
+	if (bond_ab_arp_inspect(bond))
 		bond_ab_arp_commit(bond);
 
-		read_unlock(&bond->lock);
-		rtnl_unlock();
-		read_lock(&bond->lock);
-	}
-
 	bond_ab_arp_probe(bond);
 
-re_arm:
-	if (bond->params.arp_interval)
-		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
+	if (should_notify_peers)
+		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
 
-	read_unlock(&bond->lock);
+	rtnl_unlock();
 
-	if (should_notify_peers) {
-		if (!rtnl_trylock())
-			return;
-		call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
-		rtnl_unlock();
-	}
+re_arm:
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond->wq, &bond->arp_work,
+				msecs_to_jiffies(bond->params.arp_interval));
 }
 
 /*-------------------------- netdev event handling --------------------------*/
-- 
1.8.2.1
