From: Maxim Uvarov <maxim.uvarov@oracle.com>
Subject: [PATCH] bond_alb: don't disable softirq under bond_alb_xmit
Date: Fri,  6 Jan 2012 12:23:43 -0800
Message-ID: <1325881423-19309-1-git-send-email-maxim.uvarov@oracle.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net,
	Maxim Uvarov <maxim.uvarov@oracle.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:56944 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932638Ab2AFU0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 15:26:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to lock soft irqs under bond_alb_xmit()
which already has softirq disabled.

Signed-off-by: Maxim Uvarov <maxim.uvarov@oracle.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/bonding/bond_alb.c |   40 +++++++++++++++++++++++++++-------------
 1 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 106b88a..42d4286 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -135,7 +135,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
 	struct tlb_client_info *tx_hash_table;
 	u32 index;
 
-	_lock_tx_hashtbl(bond);
+	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 
 	/* clear slave from tx_hashtbl */
 	tx_hash_table = BOND_ALB_INFO(bond).tx_hashtbl;
@@ -152,7 +152,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
 
 	tlb_init_slave(slave);
 
-	_unlock_tx_hashtbl(bond);
+	spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
 /* Must be called before starting the monitor timer */
@@ -226,15 +226,13 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 	return least_loaded;
 }
 
-/* Caller must hold bond lock for read */
-static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
+static struct slave *__tlb_choose_channel(struct bonding *bond, u32 hash_index,
+						u32 skb_len)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct tlb_client_info *hash_table;
 	struct slave *assigned_slave;
 
-	_lock_tx_hashtbl(bond);
-
 	hash_table = bond_info->tx_hashtbl;
 	assigned_slave = hash_table[hash_index].tx_slave;
 	if (!assigned_slave) {
@@ -263,11 +261,27 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 		hash_table[hash_index].tx_bytes += skb_len;
 	}
 
-	_unlock_tx_hashtbl(bond);
-
 	return assigned_slave;
 }
 
+/* Caller must hold bond lock for read */
+static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index,
+					u32 skb_len)
+{
+	struct slave *tx_slave;
+	/*
+	 * We don't need to disable softirq here, becase
+	 * tlb_choose_channel() is only called by bond_alb_xmit()
+	 * which already has softirq disabled.
+	 */
+	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	tx_slave = __tlb_choose_channel(bond, hash_index, skb_len);
+	spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	return tx_slave;
+}
+
+
+
 /*********************** rlb specific functions ***************************/
 static inline void _lock_rx_hashtbl(struct bonding *bond)
 {
@@ -548,7 +562,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	_lock_rx_hashtbl(bond);
+	spin_lock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 
 	hash_index = bond_info->rx_hashtbl_head;
 	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
@@ -572,7 +586,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		}
 	}
 
-	_unlock_rx_hashtbl(bond);
+	spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 }
 
 /* Caller must hold both bond and ptr locks for read */
@@ -584,7 +598,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 	struct rlb_client_info *client_info;
 	u32 hash_index = 0;
 
-	_lock_rx_hashtbl(bond);
+	spin_lock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 
 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
@@ -600,7 +614,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 
 			assigned_slave = client_info->slave;
 			if (assigned_slave) {
-				_unlock_rx_hashtbl(bond);
+				spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 				return assigned_slave;
 			}
 		} else {
@@ -652,7 +666,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 	}
 
-	_unlock_rx_hashtbl(bond);
+	spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 
 	return assigned_slave;
 }
-- 
1.7.4.1
