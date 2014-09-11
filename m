From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 7/7] bonding: adjust locking comments
Date: Thu, 11 Sep 2014 22:49:28 +0200
Message-ID: <1410468568-13781-8-git-send-email-nikolay@redhat.com>
References: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757385AbaIKUuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 16:50:50 -0400
In-Reply-To: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that locks have been removed, remove some unnecessary comments and
adjust others to reflect reality. Also add a comment to "mode_lock" to
describe its current users and give a brief summary why they need it.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_alb.c  | 8 +-------
 drivers/net/bonding/bond_main.c | 6 +++---
 drivers/net/bonding/bonding.h   | 6 ++++++
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 876b97fb55e9..85af961f1317 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -119,7 +119,6 @@ static inline void tlb_init_slave(struct slave *slave)
 	SLAVE_TLB_INFO(slave).head = TLB_NULL_INDEX;
 }
 
-/* Caller must hold bond lock for read, BH disabled */
 static void __tlb_clear_slave(struct bonding *bond, struct slave *slave,
 			 int save_load)
 {
@@ -142,7 +141,6 @@ static void __tlb_clear_slave(struct bonding *bond, struct slave *slave,
 	tlb_init_slave(slave);
 }
 
-/* Caller must hold bond lock for read */
 static void tlb_clear_slave(struct bonding *bond, struct slave *slave,
 			 int save_load)
 {
@@ -199,7 +197,6 @@ static long long compute_gap(struct slave *slave)
 	       (s64) (SLAVE_TLB_INFO(slave).load << 3); /* Bytes to bits */
 }
 
-/* Caller must hold bond lock for read */
 static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 {
 	struct slave *slave, *least_loaded;
@@ -337,7 +334,6 @@ out:
 	return RX_HANDLER_ANOTHER;
 }
 
-/* Caller must hold bond lock for read */
 static struct slave *rlb_next_rx_slave(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
@@ -370,7 +366,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 	return rx_slave;
 }
 
-/* Caller must hold rcu_read_lock() for read */
+/* Caller must hold rcu_read_lock() */
 static struct slave *__rlb_next_rx_slave(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
@@ -749,7 +745,6 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 	return tx_slave;
 }
 
-/* Caller must hold bond lock for read */
 static void rlb_rebalance(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
@@ -1677,7 +1672,6 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 
 }
 
-/* Caller must hold bond lock for read */
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 116cf6965bc5..2d90a8b7f62e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1629,7 +1629,7 @@ err_undo_flags:
 /*
  * Try to release the slave device <slave> from the bond device <master>
  * It is legal to access curr_active_slave without a lock because all the function
- * is write-locked. If "all" is true it means that the function is being called
+ * is RTNL-locked. If "all" is true it means that the function is being called
  * while destroying a bond interface and all slaves are being released.
  *
  * The rules for slave state should be:
@@ -2494,7 +2494,7 @@ re_arm:
  * place for the slave.  Returns 0 if no changes are found, >0 if changes
  * to link states must be committed.
  *
- * Called with rcu_read_lock hold.
+ * Called with rcu_read_lock held.
  */
 static int bond_ab_arp_inspect(struct bonding *bond)
 {
@@ -2642,7 +2642,7 @@ do_failover:
 /*
  * Send ARP probes for active-backup mode ARP monitor.
  *
- * Called with rcu_read_lock hold.
+ * Called with rcu_read_lock held.
  */
 static bool bond_ab_arp_probe(struct bonding *bond)
 {
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0cda34b827f8..3aff1a815e89 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -195,6 +195,12 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
 			      struct slave *);
+	/* mode_lock is used for mode-specific locking needs, currently used by:
+	 * 3ad mode (4) - protect against running bond_3ad_unbind_slave() and
+	 *                bond_3ad_state_machine_handler() concurrently.
+	 * TLB mode (5) - to sync the use and modifications of its hash table
+	 * ALB mode (6) - to sync the use and modifications of its hash table
+	 */
 	spinlock_t mode_lock;
 	u8	 send_peer_notif;
 	u8       igmp_retrans;
-- 
1.9.3
