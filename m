From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/3] bonding: make sure tx and rx hash tables stay in sync when using alb mode
Date: Tue, 29 Sep 2009 17:15:30 -0700
Message-ID: <1254269731-7341-3-git-send-email-fubar@us.ibm.com>
References: <1254269731-7341-1-git-send-email-fubar@us.ibm.com>
 <1254269731-7341-2-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:46979 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753609AbZI3APg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 20:15:36 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8U0DECm030403
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:13:14 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8U0Fd7Z252716
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8U0Fd6m023144
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:39 -0400
In-Reply-To: <1254269731-7341-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

I noticed that it was easy for alb (mode 6) bonding to get into a state
where the tx hash-table and rx hash-table are out of sync (there is
really nothing to keep them synchronized), and we will transmit traffic
destined for a host on one slave and send ARP frames to the same slave
from another interface using a different source MAC.

There is no compelling reason to do this, so this patch makes sure the
rx hash-table changes whenever the tx hash-table is updated based on
device load.  This patch also drops the code that does rlb re-balancing
since the balancing will now be controlled by the tx hash-table based on
transmit load.  In order to address an issue found with the initial
patch, I have also combined the rx and tx hash table lock into a single
lock.  This will facilitate moving these into a single table at some
point.

Patch modified by Jay Vosburgh to fix a typo and remove some leftover
rlb rebalance code.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_alb.c |  215 ++++++++++++++--------------------------
 drivers/net/bonding/bond_alb.h |    7 +-
 2 files changed, 75 insertions(+), 147 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index cf2842e..5cd0400 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -118,6 +118,7 @@ static inline struct arp_pkt *arp_pkt(const struct sk_buff *skb)
 
 /* Forward declaration */
 static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[]);
+static struct slave *alb_get_best_slave(struct bonding *bond, u32 hash_index);
 
 static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 {
@@ -131,18 +132,18 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 	return hash;
 }
 
-/*********************** tlb specific functions ***************************/
-
-static inline void _lock_tx_hashtbl(struct bonding *bond)
+/********************* hash table lock functions *************************/
+static inline void _lock_hashtbl(struct bonding *bond)
 {
-	spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	spin_lock_bh(&(BOND_ALB_INFO(bond).hashtbl_lock));
 }
 
-static inline void _unlock_tx_hashtbl(struct bonding *bond)
+static inline void _unlock_hashtbl(struct bonding *bond)
 {
-	spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).hashtbl_lock));
 }
 
+/*********************** tlb specific functions ***************************/
 /* Caller must hold tx_hashtbl lock */
 static inline void tlb_init_table_entry(struct tlb_client_info *entry, int save_load)
 {
@@ -170,7 +171,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
 	struct tlb_client_info *tx_hash_table;
 	u32 index;
 
-	_lock_tx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	/* clear slave from tx_hashtbl */
 	tx_hash_table = BOND_ALB_INFO(bond).tx_hashtbl;
@@ -187,7 +188,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
 
 	tlb_init_slave(slave);
 
-	_unlock_tx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 /* Must be called before starting the monitor timer */
@@ -198,7 +199,7 @@ static int tlb_initialize(struct bonding *bond)
 	struct tlb_client_info *new_hashtbl;
 	int i;
 
-	spin_lock_init(&(bond_info->tx_hashtbl_lock));
+	spin_lock_init(&(bond_info->hashtbl_lock));
 
 	new_hashtbl = kzalloc(size, GFP_KERNEL);
 	if (!new_hashtbl) {
@@ -207,7 +208,7 @@ static int tlb_initialize(struct bonding *bond)
 		       bond->dev->name);
 		return -1;
 	}
-	_lock_tx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	bond_info->tx_hashtbl = new_hashtbl;
 
@@ -215,7 +216,7 @@ static int tlb_initialize(struct bonding *bond)
 		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 1);
 	}
 
-	_unlock_tx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 
 	return 0;
 }
@@ -225,12 +226,12 @@ static void tlb_deinitialize(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 
-	_lock_tx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	kfree(bond_info->tx_hashtbl);
 	bond_info->tx_hashtbl = NULL;
 
-	_unlock_tx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 /* Caller must hold bond lock for read */
@@ -271,24 +272,6 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 	return least_loaded;
 }
 
-/* Caller must hold bond lock for read and hashtbl lock */
-static struct slave *tlb_get_best_slave(struct bonding *bond, u32 hash_index)
-{
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct tlb_client_info *tx_hash_table = bond_info->tx_hashtbl;
-	struct slave *last_slave = tx_hash_table[hash_index].last_slave;
-	struct slave *next_slave = NULL;
-
-	if (last_slave && SLAVE_IS_OK(last_slave)) {
-		/* Use the last slave listed in the tx hashtbl if:
-		   the last slave currently is essentially unloaded. */
-		if (SLAVE_TLB_INFO(last_slave).load < 10)
-			next_slave = last_slave;
-	}
-
-	return next_slave ? next_slave : tlb_get_least_loaded_slave(bond);
-}
-
 /* Caller must hold bond lock for read */
 static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
 {
@@ -296,13 +279,12 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 	struct tlb_client_info *hash_table;
 	struct slave *assigned_slave;
 
-	_lock_tx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	hash_table = bond_info->tx_hashtbl;
 	assigned_slave = hash_table[hash_index].tx_slave;
 	if (!assigned_slave) {
-		assigned_slave = tlb_get_best_slave(bond, hash_index);
-
+		assigned_slave = alb_get_best_slave(bond, hash_index);
 		if (assigned_slave) {
 			struct tlb_slave_info *slave_info =
 				&(SLAVE_TLB_INFO(assigned_slave));
@@ -326,20 +308,52 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 		hash_table[hash_index].tx_bytes += skb_len;
 	}
 
-	_unlock_tx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 
 	return assigned_slave;
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
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct tlb_client_info *tx_hash_table = bond_info->tx_hashtbl;
+	struct slave *last_slave = tx_hash_table[hash_index].last_slave;
+	struct slave *next_slave = NULL;
+
+	/* presume the next slave will be the least loaded one */
+	next_slave = tlb_get_least_loaded_slave(bond);
+
+	if (last_slave && SLAVE_IS_OK(last_slave)) {
+		/* Use the last slave listed in the tx hashtbl if:
+		   the last slave currently is essentially unloaded. */
+		if (SLAVE_TLB_INFO(last_slave).load < 10)
+			next_slave = last_slave;
+	}
+
+	/* update the rlb hashtbl if there was a previous entry */
+	if (bond_info->rlb_enabled)
+		rlb_update_rx_table(bond, next_slave, hash_index);
+
+	return next_slave;
 }
 
 /* when an ARP REPLY is received from a client update its info
@@ -351,7 +365,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	hash_index = _simple_hash((u8*)&(arp->ip_src), sizeof(arp->ip_src));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
@@ -365,7 +379,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 		bond_info->rx_ntt = 1;
 	}
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
@@ -409,38 +423,6 @@ out:
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
@@ -475,14 +457,14 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 	u32 index, next_index;
 
 	/* clear slave from rx_hashtbl */
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	rx_hash_table = bond_info->rx_hashtbl;
 	index = bond_info->rx_hashtbl_head;
 	for (; index != RLB_NULL_INDEX; index = next_index) {
 		next_index = rx_hash_table[index].next;
 		if (rx_hash_table[index].slave == slave) {
-			struct slave *assigned_slave = rlb_next_rx_slave(bond);
+			struct slave *assigned_slave = alb_get_best_slave(bond, index);
 
 			if (assigned_slave) {
 				rx_hash_table[index].slave = assigned_slave;
@@ -506,7 +488,7 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 		}
 	}
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 
 	write_lock_bh(&bond->curr_slave_lock);
 
@@ -565,7 +547,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	hash_index = bond_info->rx_hashtbl_head;
 	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
@@ -583,7 +565,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
 	 */
 	bond_info->rlb_update_delay_counter = RLB_UPDATE_DELAY;
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 /* The slave was assigned a new mac address - update the clients */
@@ -594,7 +576,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 	int ntt = 0;
 	u32 hash_index;
 
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	hash_index = bond_info->rx_hashtbl_head;
 	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
@@ -614,7 +596,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 		bond_info->rlb_update_retry_counter = RLB_UPDATE_RETRY;
 	}
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 /* mark all clients using src_ip to be updated */
@@ -624,7 +606,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	hash_index = bond_info->rx_hashtbl_head;
 	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
@@ -650,7 +632,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		}
 	}
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 /* Caller must hold both bond and ptr locks for read */
@@ -662,7 +644,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 	struct rlb_client_info *client_info;
 	u32 hash_index = 0;
 
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_src));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
@@ -678,7 +660,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 
 			assigned_slave = client_info->slave;
 			if (assigned_slave) {
-				_unlock_rx_hashtbl(bond);
+				_unlock_hashtbl(bond);
 				return assigned_slave;
 			}
 		} else {
@@ -694,7 +676,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 	}
 	/* assign a new slave */
-	assigned_slave = rlb_next_rx_slave(bond);
+	assigned_slave = alb_get_best_slave(bond, hash_index);
 
 	if (assigned_slave) {
 		client_info->ip_src = arp->ip_src;
@@ -730,7 +712,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 	}
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 
 	return assigned_slave;
 }
@@ -778,36 +760,6 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
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
@@ -824,8 +776,6 @@ static int rlb_initialize(struct bonding *bond)
 	int size = RLB_HASH_TABLE_SIZE * sizeof(struct rlb_client_info);
 	int i;
 
-	spin_lock_init(&(bond_info->rx_hashtbl_lock));
-
 	new_hashtbl = kmalloc(size, GFP_KERNEL);
 	if (!new_hashtbl) {
 		pr_err(DRV_NAME
@@ -833,7 +783,7 @@ static int rlb_initialize(struct bonding *bond)
 		       bond->dev->name);
 		return -1;
 	}
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	bond_info->rx_hashtbl = new_hashtbl;
 
@@ -843,7 +793,7 @@ static int rlb_initialize(struct bonding *bond)
 		rlb_init_table_entry(bond_info->rx_hashtbl + i);
 	}
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 
 	/*initialize packet type*/
 	pk_type->type = cpu_to_be16(ETH_P_ARP);
@@ -862,13 +812,13 @@ static void rlb_deinitialize(struct bonding *bond)
 
 	dev_remove_pack(&(bond_info->rlb_pkt_type));
 
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	kfree(bond_info->rx_hashtbl);
 	bond_info->rx_hashtbl = NULL;
 	bond_info->rx_hashtbl_head = RLB_NULL_INDEX;
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
@@ -876,7 +826,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	u32 curr_index;
 
-	_lock_rx_hashtbl(bond);
+	_lock_hashtbl(bond);
 
 	curr_index = bond_info->rx_hashtbl_head;
 	while (curr_index != RLB_NULL_INDEX) {
@@ -901,7 +851,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 		curr_index = next_index;
 	}
 
-	_unlock_rx_hashtbl(bond);
+	_unlock_hashtbl(bond);
 }
 
 /*********************** tlb/rlb shared functions *********************/
@@ -1525,11 +1475,6 @@ void bond_alb_monitor(struct work_struct *work)
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
@@ -1582,10 +1527,6 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	/* order a rebalance ASAP */
 	bond->alb_info.tx_rebalance_counter = BOND_TLB_REBALANCE_TICKS;
 
-	if (bond->alb_info.rlb_enabled) {
-		bond->alb_info.rlb_rebalance = 1;
-	}
-
 	return 0;
 }
 
@@ -1622,14 +1563,6 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
 	} else if (link == BOND_LINK_UP) {
 		/* order a rebalance ASAP */
 		bond_info->tx_rebalance_counter = BOND_TLB_REBALANCE_TICKS;
-		if (bond->alb_info.rlb_enabled) {
-			bond->alb_info.rlb_rebalance = 1;
-			/* If the updelay module parameter is smaller than the
-			 * forwarding delay of the switch the rebalance will
-			 * not work because the rebalance arp replies will
-			 * not be forwarded to the clients..
-			 */
-		}
 	}
 }
 
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index b65fd29..24bf35a 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -90,7 +90,7 @@ struct tlb_slave_info {
 struct alb_bond_info {
 	struct timer_list	alb_timer;
 	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
-	spinlock_t		tx_hashtbl_lock;
+	spinlock_t		hashtbl_lock; /* lock for both tables */
 	u32			unbalanced_load;
 	int			tx_rebalance_counter;
 	int			lp_counter;
@@ -98,7 +98,6 @@ struct alb_bond_info {
 	int rlb_enabled;
 	struct packet_type	rlb_pkt_type;
 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
-	spinlock_t		rx_hashtbl_lock;
 	u32			rx_hashtbl_head;
 	u8			rx_ntt;	/* flag - need to transmit
 					 * to all rx clients
@@ -115,10 +114,6 @@ struct alb_bond_info {
 	u32			rlb_update_retry_counter;/* counter of retries
 							  * of client update
 							  */
-	u8			rlb_rebalance;	/* flag - indicates that the
-						 * rx traffic should be
-						 * rebalanced
-						 */
 	struct vlan_entry	*current_alb_vlan;
 };
 
-- 
1.6.0.2

