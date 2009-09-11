From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2/4] bonding: make sure tx and rx hash tables stay in sync
	when using alb mode
Date: Fri, 11 Sep 2009 17:11:12 -0400
Message-ID: <20090911211112.GR8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755418AbZIKVLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:11:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Subject: [PATCH] bonding: make sure tx and rx hash tables stay in sync when using alb mode

I noticed that it was easy for alb (mode 6) bonding to get into a state
where the tx hash-table and rx hash-table are out of sync (there is
really nothing to keep them synchronized), and we will transmit traffic
destined for a host on one slave and send ARP frames to the same slave
from another interface using a different source MAC.

There is no compelling reason to do this, so this patch makes sure the
rx hash-table changes whenever the tx hash-table is updated based on
device load.  This patch also drops the code that does rlb re-balancing
since the balancing will not be controlled by the tx hash-table based on
transmit load.

Long-term it would be nice to reduce these two tables into one, but
until that is done (as well as some significant re-factoring on the alb
code) they should be kept in sync.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_alb.c |  123 ++++++++++++++++------------------------
 1 files changed, 49 insertions(+), 74 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index bcf25c6..a88d0ec 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -111,6 +111,7 @@ static inline struct arp_pkt *arp_pkt(const struct sk_buff *skb)
 
 /* Forward declaration */
 static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[]);
+static struct slave *rlb_update_rx_table(struct bonding *bond, struct slave *next_slave, u32 hash_index);
 
 static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 {
@@ -124,7 +125,18 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 	return hash;
 }
 
-/*********************** tlb specific functions ***************************/
+
+/********************* rlb and tlb lock functions *************************/
+static inline void _lock_rx_hashtbl(struct bonding *bond)
+{
+	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+}
+
+static inline void _unlock_rx_hashtbl(struct bonding *bond)
+{
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+}
+
 
 static inline void _lock_tx_hashtbl(struct bonding *bond)
 {
@@ -136,6 +148,7 @@ static inline void _unlock_tx_hashtbl(struct bonding *bond)
 	spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
+/*********************** tlb specific functions ***************************/
 /* Caller must hold tx_hashtbl lock */
 static inline void tlb_init_table_entry(struct tlb_client_info *entry, int save_load)
 {
@@ -296,6 +309,12 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 	if (!assigned_slave) {
 		assigned_slave = tlb_get_best_slave(bond, hash_index);
 
+		if (bond_info->rlb_enabled) {
+			_lock_rx_hashtbl(bond);
+			rlb_update_rx_table(bond, assigned_slave, hash_index);
+			_unlock_rx_hashtbl(bond);
+		}
+
 		if (assigned_slave) {
 			struct tlb_slave_info *slave_info =
 				&(SLAVE_TLB_INFO(assigned_slave));
@@ -325,14 +344,37 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 }
 
 /*********************** rlb specific functions ***************************/
-static inline void _lock_rx_hashtbl(struct bonding *bond)
+
+/* Caller must hold bond lock for read and hashtbl lock */
+static struct slave *rlb_update_rx_table(struct bonding *bond, struct slave *next_slave, u32 hash_index)
 {
-	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+
+	/* check rlb table and correct it if wrong */
+	if (bond_info->rlb_enabled) {
+		struct rlb_client_info *rx_client_info = &(bond_info->rx_hashtbl[hash_index]);
+
+		/* if the new slave computed by tlb checks doesn't match rlb, stop rlb from using it */
+		if (next_slave && (next_slave != rx_client_info->slave)) 
+			rx_client_info->slave = next_slave;
+	}
+	return next_slave;
 }
 
-static inline void _unlock_rx_hashtbl(struct bonding *bond)
+/* Caller must hold bond lock for read and hashtbl lock */
+static struct slave *alb_get_best_slave(struct bonding *bond, u32 hash_index)
 {
-	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	struct slave *next_slave = NULL;
+
+	_lock_tx_hashtbl(bond);
+
+	next_slave = tlb_get_best_slave(bond, hash_index);
+
+	_unlock_tx_hashtbl(bond);
+
+	rlb_update_rx_table(bond, next_slave, hash_index);
+
+	return next_slave;
 }
 
 /* when an ARP REPLY is received from a client update its info
@@ -402,38 +444,6 @@ out:
 	return res;
 }
 
-/* Caller must hold bond lock for read */
-static struct slave *rlb_next_rx_slave(struct bonding *bond)
-{
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct slave *rx_slave, *slave, *start_at;
-	int i = 0;
-
-	if (bond_info->next_rx_slave) {
-		start_at = bond_info->next_rx_slave;
-	} else {
-		start_at = bond->first_slave;
-	}
-
-	rx_slave = NULL;
-
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		if (SLAVE_IS_OK(slave)) {
-			if (!rx_slave) {
-				rx_slave = slave;
-			} else if (slave->speed > rx_slave->speed) {
-				rx_slave = slave;
-			}
-		}
-	}
-
-	if (rx_slave) {
-		bond_info->next_rx_slave = rx_slave->next;
-	}
-
-	return rx_slave;
-}
-
 /* teach the switch the mac of a disabled slave
  * on the primary for fault tolerance
  *
@@ -475,7 +485,7 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 	for (; index != RLB_NULL_INDEX; index = next_index) {
 		next_index = rx_hash_table[index].next;
 		if (rx_hash_table[index].slave == slave) {
-			struct slave *assigned_slave = rlb_next_rx_slave(bond);
+			struct slave *assigned_slave = alb_get_best_slave(bond, index);
 
 			if (assigned_slave) {
 				rx_hash_table[index].slave = assigned_slave;
@@ -687,7 +697,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 	}
 	/* assign a new slave */
-	assigned_slave = rlb_next_rx_slave(bond);
+	assigned_slave = alb_get_best_slave(bond, hash_index);
 
 	if (assigned_slave) {
 		client_info->ip_src = arp->ip_src;
@@ -771,36 +781,6 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 	return tx_slave;
 }
 
-/* Caller must hold bond lock for read */
-static void rlb_rebalance(struct bonding *bond)
-{
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct slave *assigned_slave;
-	struct rlb_client_info *client_info;
-	int ntt;
-	u32 hash_index;
-
-	_lock_rx_hashtbl(bond);
-
-	ntt = 0;
-	hash_index = bond_info->rx_hashtbl_head;
-	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
-		client_info = &(bond_info->rx_hashtbl[hash_index]);
-		assigned_slave = rlb_next_rx_slave(bond);
-		if (assigned_slave && (client_info->slave != assigned_slave)) {
-			client_info->slave = assigned_slave;
-			client_info->ntt = 1;
-			ntt = 1;
-		}
-	}
-
-	/* update the team's flag only after the whole iteration */
-	if (ntt) {
-		bond_info->rx_ntt = 1;
-	}
-	_unlock_rx_hashtbl(bond);
-}
-
 /* Caller must hold rx_hashtbl lock */
 static void rlb_init_table_entry(struct rlb_client_info *entry)
 {
@@ -1521,11 +1501,6 @@ void bond_alb_monitor(struct work_struct *work)
 			read_lock(&bond->lock);
 		}
 
-		if (bond_info->rlb_rebalance) {
-			bond_info->rlb_rebalance = 0;
-			rlb_rebalance(bond);
-		}
-
 		/* check if clients need updating */
 		if (bond_info->rx_ntt) {
 			if (bond_info->rlb_update_delay_counter) {
-- 
1.5.5.6

