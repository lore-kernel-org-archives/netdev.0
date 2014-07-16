From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv4] bonding: Do not try to send packets over dead link in TLB mode.
Date: Wed, 16 Jul 2014 11:10:36 -0700
Message-ID: <1405534236-26542-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:37792 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbaGPSKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 14:10:48 -0400
Received: by mail-ie0-f201.google.com with SMTP id tr6so281041ieb.2
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 11:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
group are selected based on the hash distribution. This does not
exclude dead links which are part of the bond. Also if there is a
temporary link event which brings down the interface, packets
hashed on that interface would be dropped too.

This patch fixes these issues and distributes flows across the
UP links only. Also the array construction of links which are
capable of sending packets happen in the control path leaving
only link-selection during the data-path.

One possible side effect of this is - at a link event; all
flows will be shuffled to get good distribution. But impact of
this should be minimum with the assumption that a member or
members of the bond group are not available is a very temporary
situation.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_alb.c | 55 ++++++++++++++++++++++++++++++++++++++----
 drivers/net/bonding/bond_alb.h |  8 ++++++
 drivers/net/bonding/bonding.h  |  6 +++++
 3 files changed, 64 insertions(+), 5 deletions(-)

[v1]
  * Initial patch
[v2]
  * Removed spinlock protection
  * Removed explicit rcu_read_(un)lock() calls since Xmit fn run in RCU
  * Updated condition during bond-dismantle to check for only arrays' existance.
[v3]
  * Correct RCU annotation during dismantle
  * Alloc changed from GFP_KERNEL to GFP_ATOMIC
  * Added another call during alb_deinit_slave() to update array.
[v4]
  * RCU annotation corrections suggested by Eric.

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 76c0dade233f..90946cfcc310 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -202,6 +202,7 @@ static int tlb_initialize(struct bonding *bond)
 static void tlb_deinitialize(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct tlb_up_slave *arr;
 
 	_lock_tx_hashtbl_bh(bond);
 
@@ -209,6 +210,10 @@ static void tlb_deinitialize(struct bonding *bond)
 	bond_info->tx_hashtbl = NULL;
 
 	_unlock_tx_hashtbl_bh(bond);
+
+	arr = rtnl_dereference(bond_info->slave_arr);
+	if (arr)
+		kfree_rcu(arr, rcu);
 }
 
 static long long compute_gap(struct slave *slave)
@@ -1406,9 +1411,39 @@ out:
 	return NETDEV_TX_OK;
 }
 
+static int bond_tlb_update_slave_arr(struct bonding *bond,
+				     struct slave *skipslave)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct slave *tx_slave;
+	struct list_head *iter;
+	struct tlb_up_slave *new_arr, *old_arr;
+
+	new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
+			  GFP_ATOMIC);
+	if (!new_arr)
+		return -ENOMEM;
+
+	bond_for_each_slave(bond, tx_slave, iter) {
+		if (!bond_slave_can_tx(tx_slave))
+			continue;
+		if (skipslave == tx_slave)
+			continue;
+		new_arr->arr[new_arr->count++] = tx_slave;
+	}
+
+	old_arr = rtnl_dereference(bond_info->slave_arr);
+	rcu_assign_pointer(bond_info->slave_arr, new_arr);
+	if (old_arr)
+		kfree_rcu(old_arr, rcu);
+
+	return 0;
+}
+
 int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct ethhdr *eth_data;
 	struct slave *tx_slave = NULL;
 	u32 hash_index;
@@ -1429,12 +1464,12 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 							      hash_index & 0xFF,
 							      skb->len);
 			} else {
-				struct list_head *iter;
-				int idx = hash_index % bond->slave_cnt;
+				struct tlb_up_slave *slaves;
 
-				bond_for_each_slave_rcu(bond, tx_slave, iter)
-					if (--idx < 0)
-						break;
+				slaves = rcu_dereference(bond_info->slave_arr);
+				if (slaves && slaves->count)
+					tx_slave = slaves->arr[hash_index %
+							       slaves->count];
 			}
 			break;
 		}
@@ -1698,6 +1733,11 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 		bond->alb_info.rx_slave = NULL;
 		rlb_clear_slave(bond, slave);
 	}
+
+	if (bond_is_nondyn_tlb(bond))
+		if (bond_tlb_update_slave_arr(bond, slave))
+			pr_err("Failed to build slave-array for TLB mode.\n");
+
 }
 
 /* Caller must hold bond lock for read */
@@ -1721,6 +1761,11 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
 			 */
 		}
 	}
+
+	if (bond_is_nondyn_tlb(bond)) {
+		if (bond_tlb_update_slave_arr(bond, NULL))
+			pr_err("Failed to build slave-array for TLB mode.\n");
+	}
 }
 
 /**
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 5fc76c01636c..aaeac61d03cf 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -139,12 +139,20 @@ struct tlb_slave_info {
 			 */
 };
 
+struct tlb_up_slave {
+	unsigned int	count;
+	struct rcu_head rcu;
+	struct slave	*arr[0];
+};
+
 struct alb_bond_info {
 	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
 	spinlock_t		tx_hashtbl_lock;
 	u32			unbalanced_load;
 	int			tx_rebalance_counter;
 	int			lp_counter;
+	/* -------- non-dynamic tlb mode only ---------*/
+	struct tlb_up_slave __rcu *slave_arr;	  /* Up slaves */
 	/* -------- rlb parameters -------- */
 	int rlb_enabled;
 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0b4d9cde0b05..ad9b3dce07d8 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -265,6 +265,12 @@ static inline bool bond_is_lb(const struct bonding *bond)
 	       BOND_MODE(bond) == BOND_MODE_ALB;
 }
 
+static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
+{
+	return (BOND_MODE(bond) == BOND_MODE_TLB)  &&
+	       (bond->params.tlb_dynamic_lb == 0);
+}
+
 static inline bool bond_mode_uses_arp(int mode)
 {
 	return mode != BOND_MODE_8023AD && mode != BOND_MODE_TLB &&
-- 
2.0.0.526.g5318336
