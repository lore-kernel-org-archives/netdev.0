From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 5/7] bonding: alb: convert to bond->mode_lock
Date: Thu, 11 Sep 2014 22:49:26 +0200
Message-ID: <1410468568-13781-6-git-send-email-nikolay@redhat.com>
References: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757364AbaIKUuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 16:50:46 -0400
In-Reply-To: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ALB/TLB specific spinlocks are no longer necessary as we now have
bond->mode_lock for this purpose, so convert them and remove them from
struct alb_bond_info.
Also remove the unneeded lock/unlock functions and use spin_lock/unlock
directly.

Suggested-by: Jay Vosburgh <jay.vosburgh@canonical.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_alb.c     | 108 ++++++++++++-------------------------
 drivers/net/bonding/bond_alb.h     |   2 -
 drivers/net/bonding/bond_debugfs.c |   4 +-
 drivers/net/bonding/bond_main.c    |  10 ----
 4 files changed, 35 insertions(+), 89 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b755659ddfdc..876b97fb55e9 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -100,27 +100,6 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 
 /*********************** tlb specific functions ***************************/
 
-static inline void _lock_tx_hashtbl_bh(struct bonding *bond)
-{
-	spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
-}
-
-static inline void _unlock_tx_hashtbl_bh(struct bonding *bond)
-{
-	spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
-}
-
-static inline void _lock_tx_hashtbl(struct bonding *bond)
-{
-	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
-}
-
-static inline void _unlock_tx_hashtbl(struct bonding *bond)
-{
-	spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
-}
-
-/* Caller must hold tx_hashtbl lock */
 static inline void tlb_init_table_entry(struct tlb_client_info *entry, int save_load)
 {
 	if (save_load) {
@@ -167,9 +146,9 @@ static void __tlb_clear_slave(struct bonding *bond, struct slave *slave,
 static void tlb_clear_slave(struct bonding *bond, struct slave *slave,
 			 int save_load)
 {
-	_lock_tx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 	__tlb_clear_slave(bond, slave, save_load);
-	_unlock_tx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 /* Must be called before starting the monitor timer */
@@ -184,14 +163,14 @@ static int tlb_initialize(struct bonding *bond)
 	if (!new_hashtbl)
 		return -1;
 
-	_lock_tx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	bond_info->tx_hashtbl = new_hashtbl;
 
 	for (i = 0; i < TLB_HASH_TABLE_SIZE; i++)
 		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 0);
 
-	_unlock_tx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 
 	return 0;
 }
@@ -202,12 +181,12 @@ static void tlb_deinitialize(struct bonding *bond)
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct tlb_up_slave *arr;
 
-	_lock_tx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	kfree(bond_info->tx_hashtbl);
 	bond_info->tx_hashtbl = NULL;
 
-	_unlock_tx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 
 	arr = rtnl_dereference(bond_info->slave_arr);
 	if (arr)
@@ -281,7 +260,6 @@ static struct slave *__tlb_choose_channel(struct bonding *bond, u32 hash_index,
 	return assigned_slave;
 }
 
-/* Caller must hold bond lock for read */
 static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index,
 					u32 skb_len)
 {
@@ -291,32 +269,13 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index,
 	 * tlb_choose_channel() is only called by bond_alb_xmit()
 	 * which already has softirq disabled.
 	 */
-	_lock_tx_hashtbl(bond);
+	spin_lock(&bond->mode_lock);
 	tx_slave = __tlb_choose_channel(bond, hash_index, skb_len);
-	_unlock_tx_hashtbl(bond);
+	spin_unlock(&bond->mode_lock);
 	return tx_slave;
 }
 
 /*********************** rlb specific functions ***************************/
-static inline void _lock_rx_hashtbl_bh(struct bonding *bond)
-{
-	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
-}
-
-static inline void _unlock_rx_hashtbl_bh(struct bonding *bond)
-{
-	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
-}
-
-static inline void _lock_rx_hashtbl(struct bonding *bond)
-{
-	spin_lock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
-}
-
-static inline void _unlock_rx_hashtbl(struct bonding *bond)
-{
-	spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
-}
 
 /* when an ARP REPLY is received from a client update its info
  * in the rx_hashtbl
@@ -327,7 +286,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	hash_index = _simple_hash((u8 *)&(arp->ip_src), sizeof(arp->ip_src));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
@@ -342,7 +301,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 		bond_info->rx_ntt = 1;
 	}
 
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 static int rlb_arp_recv(const struct sk_buff *skb, struct bonding *bond,
@@ -479,7 +438,7 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 	u32 index, next_index;
 
 	/* clear slave from rx_hashtbl */
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	rx_hash_table = bond_info->rx_hashtbl;
 	index = bond_info->rx_hashtbl_used_head;
@@ -510,7 +469,7 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 		}
 	}
 
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 
 	if (slave != rtnl_dereference(bond->curr_active_slave))
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
@@ -561,7 +520,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	hash_index = bond_info->rx_hashtbl_used_head;
 	for (; hash_index != RLB_NULL_INDEX;
@@ -579,7 +538,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
 	 */
 	bond_info->rlb_update_delay_counter = RLB_UPDATE_DELAY;
 
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 /* The slave was assigned a new mac address - update the clients */
@@ -590,7 +549,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 	int ntt = 0;
 	u32 hash_index;
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	hash_index = bond_info->rx_hashtbl_used_head;
 	for (; hash_index != RLB_NULL_INDEX;
@@ -611,7 +570,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 		bond_info->rlb_update_retry_counter = RLB_UPDATE_RETRY;
 	}
 
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 /* mark all clients using src_ip to be updated */
@@ -621,7 +580,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	_lock_rx_hashtbl(bond);
+	spin_lock(&bond->mode_lock);
 
 	hash_index = bond_info->rx_hashtbl_used_head;
 	for (; hash_index != RLB_NULL_INDEX;
@@ -645,10 +604,9 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		}
 	}
 
-	_unlock_rx_hashtbl(bond);
+	spin_unlock(&bond->mode_lock);
 }
 
-/* Caller must hold both bond and ptr locks for read */
 static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
@@ -657,7 +615,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 	struct rlb_client_info *client_info;
 	u32 hash_index = 0;
 
-	_lock_rx_hashtbl(bond);
+	spin_lock(&bond->mode_lock);
 
 	curr_active_slave = rcu_dereference(bond->curr_active_slave);
 
@@ -676,7 +634,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 
 			assigned_slave = client_info->slave;
 			if (assigned_slave) {
-				_unlock_rx_hashtbl(bond);
+				spin_unlock(&bond->mode_lock);
 				return assigned_slave;
 			}
 		} else {
@@ -738,7 +696,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 	}
 
-	_unlock_rx_hashtbl(bond);
+	spin_unlock(&bond->mode_lock);
 
 	return assigned_slave;
 }
@@ -800,7 +758,7 @@ static void rlb_rebalance(struct bonding *bond)
 	int ntt;
 	u32 hash_index;
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	ntt = 0;
 	hash_index = bond_info->rx_hashtbl_used_head;
@@ -818,7 +776,7 @@ static void rlb_rebalance(struct bonding *bond)
 	/* update the team's flag only after the whole iteration */
 	if (ntt)
 		bond_info->rx_ntt = 1;
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 /* Caller must hold rx_hashtbl lock */
@@ -917,7 +875,7 @@ static void rlb_purge_src_ip(struct bonding *bond, struct arp_pkt *arp)
 	u32 ip_src_hash = _simple_hash((u8 *)&(arp->ip_src), sizeof(arp->ip_src));
 	u32 index;
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	index = bond_info->rx_hashtbl[ip_src_hash].src_first;
 	while (index != RLB_NULL_INDEX) {
@@ -928,7 +886,7 @@ static void rlb_purge_src_ip(struct bonding *bond, struct arp_pkt *arp)
 				rlb_delete_table_entry(bond, index);
 		index = next_index;
 	}
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 static int rlb_initialize(struct bonding *bond)
@@ -942,7 +900,7 @@ static int rlb_initialize(struct bonding *bond)
 	if (!new_hashtbl)
 		return -1;
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	bond_info->rx_hashtbl = new_hashtbl;
 
@@ -951,7 +909,7 @@ static int rlb_initialize(struct bonding *bond)
 	for (i = 0; i < RLB_HASH_TABLE_SIZE; i++)
 		rlb_init_table_entry(bond_info->rx_hashtbl + i);
 
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 
 	/* register to receive ARPs */
 	bond->recv_probe = rlb_arp_recv;
@@ -963,13 +921,13 @@ static void rlb_deinitialize(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	kfree(bond_info->rx_hashtbl);
 	bond_info->rx_hashtbl = NULL;
 	bond_info->rx_hashtbl_used_head = RLB_NULL_INDEX;
 
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
@@ -977,7 +935,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	u32 curr_index;
 
-	_lock_rx_hashtbl_bh(bond);
+	spin_lock_bh(&bond->mode_lock);
 
 	curr_index = bond_info->rx_hashtbl_used_head;
 	while (curr_index != RLB_NULL_INDEX) {
@@ -990,7 +948,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 		curr_index = next_index;
 	}
 
-	_unlock_rx_hashtbl_bh(bond);
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 /*********************** tlb/rlb shared functions *********************/
@@ -1394,9 +1352,9 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 	}
 
 	if (tx_slave && bond->params.tlb_dynamic_lb) {
-		_lock_tx_hashtbl(bond);
+		spin_lock(&bond->mode_lock);
 		__tlb_clear_slave(bond, tx_slave, 0);
-		_unlock_tx_hashtbl(bond);
+		spin_unlock(&bond->mode_lock);
 	}
 
 	/* no suitable interface, frame not sent */
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index aaeac61d03cf..3c6a7ff974d7 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -147,7 +147,6 @@ struct tlb_up_slave {
 
 struct alb_bond_info {
 	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
-	spinlock_t		tx_hashtbl_lock;
 	u32			unbalanced_load;
 	int			tx_rebalance_counter;
 	int			lp_counter;
@@ -156,7 +155,6 @@ struct alb_bond_info {
 	/* -------- rlb parameters -------- */
 	int rlb_enabled;
 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
-	spinlock_t		rx_hashtbl_lock;
 	u32			rx_hashtbl_used_head;
 	u8			rx_ntt;	/* flag - need to transmit
 					 * to all rx clients
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 280971b227ea..652f6c5d1bf7 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -29,7 +29,7 @@ static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
 	seq_printf(m, "SourceIP        DestinationIP   "
 			"Destination MAC   DEV\n");
 
-	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	spin_lock_bh(&bond->mode_lock);
 
 	hash_index = bond_info->rx_hashtbl_used_head;
 	for (; hash_index != RLB_NULL_INDEX;
@@ -42,7 +42,7 @@ static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
 			client_info->slave->dev->name);
 	}
 
-	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	spin_unlock_bh(&bond->mode_lock);
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 99d21c2fd44f..e06251417a7d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4297,19 +4297,9 @@ static int bond_init(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 
 	netdev_dbg(bond_dev, "Begin bond_init\n");
 
-	/*
-	 * Initialize locks that may be required during
-	 * en/deslave operations.  All of the bond_open work
-	 * (of which this is part) should really be moved to
-	 * a phase prior to dev_open
-	 */
-	spin_lock_init(&(bond_info->tx_hashtbl_lock));
-	spin_lock_init(&(bond_info->rx_hashtbl_lock));
-
 	bond->wq = create_singlethread_workqueue(bond_dev->name);
 	if (!bond->wq)
 		return -ENOMEM;
-- 
1.9.3
