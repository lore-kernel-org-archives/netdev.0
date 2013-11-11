From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 6/10] bonding: rebuild the lock use for bond_activebackup_arp_mon()
Date: Mon, 11 Nov 2013 20:36:45 +0800
Message-ID: <5280CF5D.1020502@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:33049 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809Ab3KKMhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 07:37:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_activebackup_arp_mon() use the bond lock for read to
protect the slave list, it is no effect, and the RTNL is only
called for bond_ab_arp_commit() and peer notify, for the performance
better, use RCU to replace with the bond lock, to the bond slave
list need to called in RCU, add a new bond_first_slave_rcu()
to get the first slave in RCU protection.

In bond_ab_arp_probe(), the bond->current_arp_slave may changd
if bond release slave, just like:

	bond_ab_arp_probe()			bond_release()
	cpu 0					cpu 1
	...
	if (bond->current_arp_slave...)		...
	...				bond->current_arp_slave = NULl
	bond->current_arp_slave->dev->name	...

So the current_arp_slave need to dereference in the section.

When bond_ab_arp_inspect() and should_notify_peers is true, the
RTNL will called twice, it is a loss of performance, so make the
two RTNL together to avoid performance loss.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 49 +++++++++++++++++++++--------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5df705c..80d5c6a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2517,7 +2517,7 @@ re_arm:
  * place for the slave.  Returns 0 if no changes are found, >0 if changes
  * to link states must be committed.
  *
- * Called with bond->lock held for read.
+ * Called with rcu_read_lock hold.
  */
 static int bond_ab_arp_inspect(struct bonding *bond)
 {
@@ -2526,7 +2526,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 	struct slave *slave;
 	int commit = 0;
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 		last_rx = slave_last_rx(bond, slave);
 
@@ -2588,7 +2588,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
  * Called to commit link state changes noted by inspection step of
  * active-backup mode ARP monitor.
  *
- * Called with RTNL and bond->lock for read.
+ * Called with RTNL hold.
  */
 static void bond_ab_arp_commit(struct bonding *bond)
 {
@@ -2663,19 +2663,20 @@ do_failover:
 /*
  * Send ARP probes for active-backup mode ARP monitor.
  *
- * Called with bond->lock held for read.
+ * Called with rcu_read_lock hold.
  */
 static void bond_ab_arp_probe(struct bonding *bond)
 {
-	struct slave *slave, *before = NULL, *new_slave = NULL;
+	struct slave *slave, *before = NULL, *new_slave = NULL,
+		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave);
 	struct list_head *iter;
 	bool found = false;
 
 	read_lock(&bond->curr_slave_lock);
 
-	if (bond->current_arp_slave && bond->curr_active_slave)
+	if (curr_arp_slave && bond->curr_active_slave)
 		pr_info("PROBE: c_arp %s && cas %s BAD\n",
-			bond->current_arp_slave->dev->name,
+			curr_arp_slave->dev->name,
 			bond->curr_active_slave->dev->name);
 
 	if (bond->curr_active_slave) {
@@ -2691,15 +2692,15 @@ static void bond_ab_arp_probe(struct bonding *bond)
 	 * for becoming the curr_active_slave
 	 */
 
-	if (!bond->current_arp_slave) {
-		bond->current_arp_slave = bond_first_slave(bond);
-		if (!bond->current_arp_slave)
+	if (!curr_arp_slave) {
+		curr_arp_slave = bond_first_slave_rcu(bond);
+		if (!curr_arp_slave)
 			return;
 	}
 
-	bond_set_slave_inactive_flags(bond->current_arp_slave);
+	bond_set_slave_inactive_flags(curr_arp_slave);
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (!found && !before && IS_UP(slave->dev))
 			before = slave;
 
@@ -2722,7 +2723,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
 			pr_info("%s: backup interface %s is now down.\n",
 				bond->dev->name, slave->dev->name);
 		}
-		if (slave == bond->current_arp_slave)
+		if (slave == curr_arp_slave)
 			found = true;
 	}
 
@@ -2736,8 +2737,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
 	bond_set_slave_active_flags(new_slave);
 	bond_arp_send_all(bond, new_slave);
 	new_slave->jiffies = jiffies;
-	bond->current_arp_slave = new_slave;
-
+	rcu_assign_pointer(bond->current_arp_slave, new_slave);
 }
 
 void bond_activebackup_arp_mon(struct work_struct *work)
@@ -2747,17 +2747,17 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	bool should_notify_peers = false;
 	int delta_in_ticks;
 
-	read_lock(&bond->lock);
-
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
+	rcu_read_lock();
+
 	should_notify_peers = bond_should_notify_peers(bond);
 
 	if (bond_ab_arp_inspect(bond)) {
-		read_unlock(&bond->lock);
+		rcu_read_unlock();
 
 		/* Race avoidance with bond_close flush of workqueue */
 		if (!rtnl_trylock()) {
@@ -2767,23 +2767,24 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 			goto re_arm;
 		}
 
-		read_lock(&bond->lock);
-
 		bond_ab_arp_commit(bond);
+		if (should_notify_peers) {
+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
+					bond->dev);
+			should_notify_peers = false;
+		}
 
-		read_unlock(&bond->lock);
 		rtnl_unlock();
-		read_lock(&bond->lock);
+		rcu_read_lock();
 	}
 
 	bond_ab_arp_probe(bond);
+	rcu_read_unlock();
 
 re_arm:
 	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 
-	read_unlock(&bond->lock);
-
 	if (should_notify_peers) {
 		if (!rtnl_trylock())
 			return;
-- 
1.8.2.1
