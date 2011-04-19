From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] bonding: move processing of recv handlers into handle_frame()
Date: Tue, 19 Apr 2011 15:48:16 +0200
Message-ID: <1303220896-9092-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425Ab1DSNsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 09:48:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since now when bonding uses rx_handler, all traffic going into bond
device goes thru bond_handle_frame. So there's no need to go back into
bonding code later via ptype handlers. This patch converts
original ptype handlers into "bonding receive probes". These functions
are called from bond_handle_frame and they are registered per-mode.

Note that vlan packets are also handled because they are always untagged
thanks to vlan_untag()

Note that this also allows arpmon for eth-bond-bridge-vlan topology.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_3ad.c   |   29 ++--------
 drivers/net/bonding/bond_3ad.h   |    4 +-
 drivers/net/bonding/bond_alb.c   |   46 ++++-----------
 drivers/net/bonding/bond_alb.h   |    1 -
 drivers/net/bonding/bond_main.c  |  121 +++++++------------------------------
 drivers/net/bonding/bond_sysfs.c |    6 --
 drivers/net/bonding/bonding.h    |    4 +-
 net/core/dev.c                   |   21 -------
 8 files changed, 43 insertions(+), 189 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 123dd60..d0981c2 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2465,35 +2465,16 @@ out:
 	return NETDEV_TX_OK;
 }
 
-int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type* ptype, struct net_device *orig_dev)
+void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
+			  struct slave *slave)
 {
-	struct bonding *bond = netdev_priv(dev);
-	struct slave *slave = NULL;
-	int ret = NET_RX_DROP;
-
-	if (!(dev->flags & IFF_MASTER))
-		goto out;
-
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb)
-		goto out;
+	if (skb->protocol != PKT_TYPE_LACPDU)
+		return;
 
 	if (!pskb_may_pull(skb, sizeof(struct lacpdu)))
-		goto out;
+		return;
 
 	read_lock(&bond->lock);
-	slave = bond_get_slave_by_dev(netdev_priv(dev), orig_dev);
-	if (!slave)
-		goto out_unlock;
-
 	bond_3ad_rx_indication((struct lacpdu *) skb->data, slave, skb->len);
-
-	ret = NET_RX_SUCCESS;
-
-out_unlock:
 	read_unlock(&bond->lock);
-out:
-	dev_kfree_skb(skb);
-
-	return ret;
 }
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index b28baff..291dbd4 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -258,7 +258,6 @@ struct ad_bond_info {
 				 * requested
 				 */
 	struct timer_list ad_timer;
-	struct packet_type ad_pkt_type;
 };
 
 struct ad_slave_info {
@@ -280,7 +279,8 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
 int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
-int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type* ptype, struct net_device *orig_dev);
+void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
+			  struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
 #endif //__BOND_3AD_H__
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index ba71582..3b7b040 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -308,49 +308,33 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 	_unlock_rx_hashtbl(bond);
 }
 
-static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
+static void rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
+			 struct slave *slave)
 {
-	struct bonding *bond;
-	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
-	int res = NET_RX_DROP;
+	struct arp_pkt *arp;
 
-	while (bond_dev->priv_flags & IFF_802_1Q_VLAN)
-		bond_dev = vlan_dev_real_dev(bond_dev);
-
-	if (!(bond_dev->priv_flags & IFF_BONDING) ||
-	    !(bond_dev->flags & IFF_MASTER))
-		goto out;
+	if (skb->protocol != cpu_to_be16(ETH_P_ARP))
+		return;
 
+	arp = (struct arp_pkt *) skb->data;
 	if (!arp) {
 		pr_debug("Packet has no ARP data\n");
-		goto out;
+		return;
 	}
 
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb)
-		goto out;
-
-	if (!pskb_may_pull(skb, arp_hdr_len(bond_dev)))
-		goto out;
+	if (!pskb_may_pull(skb, arp_hdr_len(bond->dev)))
+		return;
 
 	if (skb->len < sizeof(struct arp_pkt)) {
 		pr_debug("Packet is too small to be an ARP\n");
-		goto out;
+		return;
 	}
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
-		bond = netdev_priv(bond_dev);
 		rlb_update_entry_from_arp(bond, arp);
 		pr_debug("Server received an ARP Reply from client\n");
 	}
-
-	res = NET_RX_SUCCESS;
-
-out:
-	dev_kfree_skb(skb);
-
-	return res;
 }
 
 /* Caller must hold bond lock for read */
@@ -759,7 +743,6 @@ static void rlb_init_table_entry(struct rlb_client_info *entry)
 static int rlb_initialize(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct packet_type *pk_type = &(BOND_ALB_INFO(bond).rlb_pkt_type);
 	struct rlb_client_info	*new_hashtbl;
 	int size = RLB_HASH_TABLE_SIZE * sizeof(struct rlb_client_info);
 	int i;
@@ -784,13 +767,8 @@ static int rlb_initialize(struct bonding *bond)
 
 	_unlock_rx_hashtbl(bond);
 
-	/*initialize packet type*/
-	pk_type->type = cpu_to_be16(ETH_P_ARP);
-	pk_type->dev = bond->dev;
-	pk_type->func = rlb_arp_recv;
-
 	/* register to receive ARPs */
-	dev_add_pack(pk_type);
+	bond->recv_probe = rlb_arp_recv;
 
 	return 0;
 }
@@ -799,8 +777,6 @@ static void rlb_deinitialize(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 
-	dev_remove_pack(&(bond_info->rlb_pkt_type));
-
 	_lock_rx_hashtbl(bond);
 
 	kfree(bond_info->rx_hashtbl);
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 8ca7158..90f140a 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -129,7 +129,6 @@ struct alb_bond_info {
 	int			lp_counter;
 	/* -------- rlb parameters -------- */
 	int rlb_enabled;
-	struct packet_type	rlb_pkt_type;
 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
 	spinlock_t		rx_hashtbl_lock;
 	u32			rx_hashtbl_head;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4ce14bd..66d9dc6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1439,27 +1439,17 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 }
 
 /* On bonding slaves other than the currently active slave, suppress
- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
- * ARP on active-backup slaves with arp_validate enabled.
+ * duplicates except for alb non-mcast/bcast.
  */
 static bool bond_should_deliver_exact_match(struct sk_buff *skb,
 					    struct slave *slave,
 					    struct bonding *bond)
 {
 	if (bond_is_slave_inactive(slave)) {
-		if (slave_do_arp_validate(bond, slave) &&
-		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
-			return false;
-
 		if (bond->params.mode == BOND_MODE_ALB &&
 		    skb->pkt_type != PACKET_BROADCAST &&
 		    skb->pkt_type != PACKET_MULTICAST)
-				return false;
-
-		if (bond->params.mode == BOND_MODE_8023AD &&
-		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
 			return false;
-
 		return true;
 	}
 	return false;
@@ -1483,6 +1473,15 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 	if (bond->params.arp_interval)
 		slave->dev->last_rx = jiffies;
 
+	if (bond->recv_probe) {
+		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+
+		if (likely(nskb)) {
+			bond->recv_probe(nskb, bond, slave);
+			dev_kfree_skb(nskb);
+		}
+	}
+
 	if (bond_should_deliver_exact_match(skb, slave, bond)) {
 		return RX_HANDLER_EXACT;
 	}
@@ -2743,48 +2742,26 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 	}
 }
 
-static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static void bond_arp_rcv(struct sk_buff *skb, struct bonding *bond,
+			 struct slave *slave)
 {
 	struct arphdr *arp;
-	struct slave *slave;
-	struct bonding *bond;
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
 
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
-		/*
-		 * When using VLANS and bonding, dev and oriv_dev may be
-		 * incorrect if the physical interface supports VLAN
-		 * acceleration.  With this change ARP validation now
-		 * works for hosts only reachable on the VLAN interface.
-		 */
-		dev = vlan_dev_real_dev(dev);
-		orig_dev = dev_get_by_index_rcu(dev_net(skb->dev),skb->skb_iif);
-	}
-
-	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
-		goto out;
+	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
+		return;
 
-	bond = netdev_priv(dev);
 	read_lock(&bond->lock);
 
-	pr_debug("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
-		 bond->dev->name, skb->dev ? skb->dev->name : "NULL",
-		 orig_dev ? orig_dev->name : "NULL");
+	pr_debug("bond_arp_rcv: bond %s skb->dev %s\n",
+		 bond->dev->name, skb->dev->name);
 
-	slave = bond_get_slave_by_dev(bond, orig_dev);
-	if (!slave || !slave_do_arp_validate(bond, slave))
-		goto out_unlock;
-
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb)
-		goto out_unlock;
-
-	if (!pskb_may_pull(skb, arp_hdr_len(dev)))
+	if (!pskb_may_pull(skb, arp_hdr_len(bond->dev)))
 		goto out_unlock;
 
 	arp = arp_hdr(skb);
-	if (arp->ar_hln != dev->addr_len ||
+	if (arp->ar_hln != bond->dev->addr_len ||
 	    skb->pkt_type == PACKET_OTHERHOST ||
 	    skb->pkt_type == PACKET_LOOPBACK ||
 	    arp->ar_hrd != htons(ARPHRD_ETHER) ||
@@ -2793,9 +2770,9 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 		goto out_unlock;
 
 	arp_ptr = (unsigned char *)(arp + 1);
-	arp_ptr += dev->addr_len;
+	arp_ptr += bond->dev->addr_len;
 	memcpy(&sip, arp_ptr, 4);
-	arp_ptr += 4 + dev->addr_len;
+	arp_ptr += 4 + bond->dev->addr_len;
 	memcpy(&tip, arp_ptr, 4);
 
 	pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
@@ -2818,9 +2795,6 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 
 out_unlock:
 	read_unlock(&bond->lock);
-out:
-	dev_kfree_skb(skb);
-	return NET_RX_SUCCESS;
 }
 
 /*
@@ -3407,48 +3381,6 @@ static struct notifier_block bond_inetaddr_notifier = {
 	.notifier_call = bond_inetaddr_event,
 };
 
-/*-------------------------- Packet type handling ---------------------------*/
-
-/* register to receive lacpdus on a bond */
-static void bond_register_lacpdu(struct bonding *bond)
-{
-	struct packet_type *pk_type = &(BOND_AD_INFO(bond).ad_pkt_type);
-
-	/* initialize packet type */
-	pk_type->type = PKT_TYPE_LACPDU;
-	pk_type->dev = bond->dev;
-	pk_type->func = bond_3ad_lacpdu_recv;
-
-	dev_add_pack(pk_type);
-}
-
-/* unregister to receive lacpdus on a bond */
-static void bond_unregister_lacpdu(struct bonding *bond)
-{
-	dev_remove_pack(&(BOND_AD_INFO(bond).ad_pkt_type));
-}
-
-void bond_register_arp(struct bonding *bond)
-{
-	struct packet_type *pt = &bond->arp_mon_pt;
-
-	if (pt->type)
-		return;
-
-	pt->type = htons(ETH_P_ARP);
-	pt->dev = bond->dev;
-	pt->func = bond_arp_rcv;
-	dev_add_pack(pt);
-}
-
-void bond_unregister_arp(struct bonding *bond)
-{
-	struct packet_type *pt = &bond->arp_mon_pt;
-
-	dev_remove_pack(pt);
-	pt->type = 0;
-}
-
 /*---------------------------- Hashing Policies -----------------------------*/
 
 /*
@@ -3542,14 +3474,14 @@ static int bond_open(struct net_device *bond_dev)
 
 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		if (bond->params.arp_validate)
-			bond_register_arp(bond);
+			bond->recv_probe = bond_arp_rcv;
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
-		bond_register_lacpdu(bond);
+		bond->recv_probe = bond_3ad_lacpdu_recv;
 		bond_3ad_initiate_agg_selection(bond, 1);
 	}
 
@@ -3560,14 +3492,6 @@ static int bond_close(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
-		/* Unregister the receive of LACPDUs */
-		bond_unregister_lacpdu(bond);
-	}
-
-	if (bond->params.arp_validate)
-		bond_unregister_arp(bond);
-
 	write_lock_bh(&bond->lock);
 
 	/* signal timers not to re-arm */
@@ -3604,6 +3528,7 @@ static int bond_close(struct net_device *bond_dev)
 		 */
 		bond_alb_deinitialize(bond);
 	}
+	bond->recv_probe = NULL;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 259ff32..935406a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -422,11 +422,6 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 		bond->dev->name, arp_validate_tbl[new_value].modename,
 		new_value);
 
-	if (!bond->params.arp_validate && new_value)
-		bond_register_arp(bond);
-	else if (bond->params.arp_validate && !new_value)
-		bond_unregister_arp(bond);
-
 	bond->params.arp_validate = new_value;
 
 	return count;
@@ -923,7 +918,6 @@ static ssize_t bonding_store_miimon(struct device *d,
 				bond->dev->name);
 			bond->params.arp_interval = 0;
 			if (bond->params.arp_validate) {
-				bond_unregister_arp(bond);
 				bond->params.arp_validate =
 					BOND_ARP_VALIDATE_NONE;
 			}
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6126c6a..85fb822 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -226,6 +226,8 @@ struct bonding {
 	struct   slave *primary_slave;
 	bool     force_primary;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
+	void     (*recv_probe)(struct sk_buff *, struct bonding *,
+			       struct slave *);
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
 	s8       kill_timers;
@@ -399,8 +401,6 @@ void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
-void bond_register_arp(struct bonding *);
-void bond_unregister_arp(struct bonding *);
 void bond_create_debugfs(void);
 void bond_destroy_debugfs(void);
 void bond_debug_register(struct bonding *bond);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3871bf6..f3aed72 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3076,25 +3076,6 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
-static void vlan_on_bond_hook(struct sk_buff *skb)
-{
-	/*
-	 * Make sure ARP frames received on VLAN interfaces stacked on
-	 * bonding interfaces still make their way to any base bonding
-	 * device that may have registered for a specific ptype.
-	 */
-	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
-	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
-	    skb->protocol == htons(ETH_P_ARP)) {
-		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
-
-		if (!skb2)
-			return;
-		skb2->dev = vlan_dev_real_dev(skb->dev);
-		netif_rx(skb2);
-	}
-}
-
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
@@ -3190,8 +3171,6 @@ ncls:
 			goto out;
 	}
 
-	vlan_on_bond_hook(skb);
-
 	/* deliver only exact match when indicated */
 	null_or_dev = deliver_exact ? skb->dev : NULL;
 
-- 
1.7.4.2

