From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bond interface arp, vlan and trunk / network question
Date: Wed, 22 Apr 2009 18:12:29 -0700
Message-ID: <32563.1240449149@death.nxdomain.ibm.com>
References: <1ef444010904201050g72651387se3feca3fbd68ce30@mail.gmail.com> <49ECBBF0.80202@cosmosbay.com> <30257.1240252651@death.nxdomain.ibm.com> <1ef444010904201300r43268672sb74277f4a0242236@mail.gmail.com> <7609.1240259780@death.nxdomain.ibm.com> <1ef444010904201403s5d583750i1ce3a5da6c6f4059@mail.gmail.com> <13606.1240262581@death.nxdomain.ibm.com> <1ef444010904201439i60f9e918j760d94eeca428ece@mail.gmail.com> <22462.1240272112@death.nxdomain.ibm.com> <1ef444010904220129l24a74f07q8f32edfabe603436@mail.gmail.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: stefan novak <lms.brubaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:51923 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbZDWBM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 21:12:29 -0400
In-reply-to: <1ef444010904220129l24a74f07q8f32edfabe603436@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stefan novak <lms.brubaker@gmail.com> wrote:

>so its a bug in kernel?

	Yes.  I think the following patch should add support for
arp_validate over VLANs, could you test this?  This is still a work in
progress, so it's pretty rough around the edges, but the core
functionality should be there.

	This works by moving the skb_bond_should_drop logic around, and
replaces the current inline code with a hook into bonding to do all of
that, plus additional logic.  The reason for a hook is to get the
skb_bond_should_drop callers from the VLAN input path before the input
device is assigned to the VLAN device.

	-J

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 99610f3..cc367a3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1607,6 +1607,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	read_lock(&bond->lock);
 
 	new_slave->last_arp_rx = jiffies;
+	bond_fix_slave_validate_flag(bond, new_slave);
 
 	if (bond->params.miimon && !bond->params.use_carrier) {
 		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
@@ -2538,8 +2539,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 {
 	struct sk_buff *skb;
 
-	pr_debug("arp %d on slave %s: dst %x src %x vid %d\n", arp_op,
-	       slave_dev->name, dest_ip, src_ip, vlan_id);
+	pr_debug("arp %d on slave %s: dst %x src %x vid %d j %lu\n", arp_op,
+		 slave_dev->name, dest_ip, src_ip, vlan_id, jiffies);
 	       
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
@@ -2679,8 +2680,6 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 
 	targets = bond->params.arp_targets;
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
-		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
-			&sip, &tip, i, &targets[i], bond_has_this_ip(bond, tip));
 		if (sip == targets[i]) {
 			if (bond_has_this_ip(bond, tip))
 				slave->last_arp_rx = jiffies;
@@ -2689,35 +2688,36 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 	}
 }
 
-static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static void bond_handle_arp(struct sk_buff *skb, struct net_device *dev)
 {
 	struct arphdr *arp;
 	struct slave *slave;
+	struct net_device *bond_dev = dev->master;
 	struct bonding *bond;
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
 
 	if (dev_net(dev) != &init_net)
-		goto out;
+		return;
 
-	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
-		goto out;
+	bond = netdev_priv(bond_dev);
 
-	bond = netdev_priv(dev);
 	read_lock(&bond->lock);
 
-	pr_debug("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
-		bond->dev->name, skb->dev ? skb->dev->name : "NULL",
-		orig_dev ? orig_dev->name : "NULL");
-
-	slave = bond_get_slave_by_dev(bond, orig_dev);
+	slave = bond_get_slave_by_dev(bond, dev);
 	if (!slave || !slave_do_arp_validate(bond, slave))
 		goto out_unlock;
 
 	if (!pskb_may_pull(skb, arp_hdr_len(dev)))
 		goto out_unlock;
 
-	arp = arp_hdr(skb);
+	/* Can't use arp_hdr; it's not initialized yet. */
+	arp = (struct arphdr *)skb->data;
+
+	pr_debug("arp: hln %d p_t %d hrd %x pro %x pln %d\n",
+	       arp->ar_hln, skb->pkt_type, ntohs(arp->ar_hrd),
+	       ntohs(arp->ar_pro), arp->ar_pln);
+
 	if (arp->ar_hln != dev->addr_len ||
 	    skb->pkt_type == PACKET_OTHERHOST ||
 	    skb->pkt_type == PACKET_LOOPBACK ||
@@ -2732,29 +2732,67 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	arp_ptr += 4 + dev->addr_len;
 	memcpy(&tip, arp_ptr, 4);
 
-	pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
-		bond->dev->name, slave->dev->name, slave->state,
-		bond->params.arp_validate, slave_do_arp_validate(bond, slave),
-		&sip, &tip);
-
-	/*
-	 * Backup slaves won't see the ARP reply, but do come through
-	 * here for each ARP probe (so we swap the sip/tip to validate
-	 * the probe).  In a "redundant switch, common router" type of
-	 * configuration, the ARP probe will (hopefully) travel from
-	 * the active, through one switch, the router, then the other
-	 * switch before reaching the backup.
-	 */
-	if (slave->state == BOND_STATE_ACTIVE)
+	switch (ntohs(arp->ar_op)) {
+	case ARPOP_REPLY:
 		bond_validate_arp(bond, slave, sip, tip);
-	else
+		break;
+	case ARPOP_REQUEST:
 		bond_validate_arp(bond, slave, tip, sip);
+		break;
+	}
 
 out_unlock:
 	read_unlock(&bond->lock);
-out:
-	dev_kfree_skb(skb);
-	return NET_RX_SUCCESS;
+}
+
+/*
+ * Called by core packet processing in netif_receive_skb and in VLAN fast
+ * path to (a) determine if packet should be dropped, and (b) to perform
+ * ARP monitor processing (last_rx, validation).
+ *
+ * For the VLAN case, called before the skb->dev is reassigned to the
+ * VLAN.
+ *
+ * Returns 1 if frame should nominally be dropped; 0 if it should be kept.
+ *
+ * We want to keep:
+ * - all traffic on active slaves
+ * - some traffic on inactive slaves: non-broadcast and non-multicast in
+ * ALB/TLB mode and LACP frames in 802.3ad mode.
+ *
+ * ARP frames are handled as normal traffic; the ARP monitor handling
+ * takes place here, so they need not be kept on inactive slaves.
+ */
+static int bond_handle_frame(struct sk_buff *skb)
+{
+	struct net_device *dev;
+	struct net_device *master;
+
+	dev = skb->dev;
+	master = dev->master;
+	if (!master || !master->priv_flags & IFF_BONDING)
+		return 0;
+
+	if (master->priv_flags & IFF_MASTER_ARPMON) {
+		dev->last_rx = jiffies;
+		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
+		    skb->protocol == __constant_htons(ETH_P_ARP))
+			bond_handle_arp(skb, dev);
+	}
+
+	if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
+		if (master->priv_flags & IFF_MASTER_ALB) {
+			if (skb->pkt_type != PACKET_BROADCAST &&
+			    skb->pkt_type != PACKET_MULTICAST)
+				return 0;
+		}
+		if (master->priv_flags & IFF_MASTER_8023AD &&
+		    skb->protocol == __constant_htons(ETH_P_SLOW))
+			return 0;
+
+		return 1;
+	}
+	return 0;
 }
 
 /*
@@ -3688,6 +3726,7 @@ static void bond_unregister_lacpdu(struct bonding *bond)
 
 void bond_register_arp(struct bonding *bond)
 {
+#if 0
 	struct packet_type *pt = &bond->arp_mon_pt;
 
 	if (pt->type)
@@ -3697,14 +3736,17 @@ void bond_register_arp(struct bonding *bond)
 	pt->dev = bond->dev;
 	pt->func = bond_arp_rcv;
 	dev_add_pack(pt);
+#endif
 }
 
 void bond_unregister_arp(struct bonding *bond)
 {
+#if 0
 	struct packet_type *pt = &bond->arp_mon_pt;
 
 	dev_remove_pack(pt);
 	pt->type = 0;
+#endif
 }
 
 /*---------------------------- Hashing Policies -----------------------------*/
@@ -5188,6 +5230,8 @@ out_rtnl:
 	return res;
 }
 
+extern int (*bond_handle_frame_hook)(struct sk_buff *skb);
+
 static int __init bonding_init(void)
 {
 	int i;
@@ -5221,6 +5265,8 @@ static int __init bonding_init(void)
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_register_ipv6_notifier();
 
+	bond_handle_frame_hook = bond_handle_frame;
+
 	goto out;
 err:
 	list_for_each_entry(bond, &bond_dev_list, bond_list) {
@@ -5249,6 +5295,9 @@ static void __exit bonding_exit(void)
 	rtnl_lock();
 	bond_free_all();
 	rtnl_unlock();
+
+	bond_handle_frame_hook = NULL;
+
 }
 
 module_init(bonding_init);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 18cf478..0e9f0e9 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -484,8 +484,9 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 					  struct device_attribute *attr,
 					  const char *buf, size_t count)
 {
-	int new_value;
+	int new_value, i;
 	struct bonding *bond = to_bond(d);
+	struct slave *slave;
 
 	new_value = bond_parse_parm(buf, arp_validate_tbl);
 	if (new_value < 0) {
@@ -504,13 +505,12 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 	       bond->dev->name, arp_validate_tbl[new_value].modename,
 	       new_value);
 
-	if (!bond->params.arp_validate && new_value) {
-		bond_register_arp(bond);
-	} else if (bond->params.arp_validate && !new_value) {
-		bond_unregister_arp(bond);
-	}
+	if (bond->params.arp_validate != new_value) {
+		bond->params.arp_validate = new_value;
 
-	bond->params.arp_validate = new_value;
+		bond_for_each_slave(bond, slave, i)
+			bond_fix_slave_validate_flag(bond, slave);
+	}
 
 	return count;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ca849d2..275f08d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -283,6 +283,15 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
 	return slave->dev->last_rx;
 }
 
+static inline void bond_fix_slave_validate_flag(struct bonding *bond,
+					       struct slave *slave)
+{
+	if (slave_do_arp_validate(bond, slave))
+		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
+	else
+		slave->dev->priv_flags &= ~IFF_SLAVE_NEEDARP;
+}
+
 static inline void bond_set_slave_inactive_flags(struct slave *slave)
 {
 	struct bonding *bond = netdev_priv(slave->dev->master);
@@ -290,14 +299,16 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
 	    bond->params.mode != BOND_MODE_ALB)
 		slave->state = BOND_STATE_BACKUP;
 	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
-	if (slave_do_arp_validate(bond, slave))
-		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
+	bond_fix_slave_validate_flag(bond, slave);
 }
 
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
+	struct bonding *bond = netdev_priv(slave->dev->master);
+
 	slave->state = BOND_STATE_ACTIVE;
-	slave->dev->priv_flags &= ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDARP);
+	slave->dev->priv_flags &= ~IFF_SLAVE_INACTIVE;
+	bond_fix_slave_validate_flag(bond, slave);
 }
 
 static inline void bond_set_master_3ad_flags(struct bonding *bond)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..3dafd8f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1874,6 +1874,7 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
+#if 0
 /* On bonding slaves other than the currently active slave, suppress
  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
  * ARP on active-backup slaves with arp_validate enabled.
@@ -1906,6 +1907,8 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 	}
 	return 0;
 }
+#endif
+extern int skb_bond_should_drop(struct sk_buff *skb);
 
 extern struct pernet_operations __net_initdata loopback_net_ops;
 #endif /* __KERNEL__ */
diff --git a/net/core/dev.c b/net/core/dev.c
index 91d792d..ac5a37e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2098,6 +2098,56 @@ static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
 #define handle_macvlan(skb, pt_prev, ret, orig_dev)	(skb)
 #endif
 
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
+int (*bond_handle_frame_hook)(struct sk_buff *skb);
+EXPORT_SYMBOL_GPL(bond_handle_frame_hook);
+
+/* On bonding slaves other than the currently active slave, suppress
+ * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
+ * ARP on active-backup slaves with arp_validate enabled.
+ */
+int skb_bond_should_drop(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct net_device *master = dev->master;
+
+	if (master)
+		return bond_handle_frame_hook(skb);
+
+	return 0;
+
+#if 0
+		if (master->priv_flags & IFF_MASTER_ARPMON)
+			dev->last_rx = jiffies;
+
+		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
+			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
+			    skb->protocol == __constant_htons(ETH_P_ARP))
+				return 0;
+
+			if (master->priv_flags & IFF_MASTER_ALB) {
+				if (skb->pkt_type != PACKET_BROADCAST &&
+				    skb->pkt_type != PACKET_MULTICAST)
+					return 0;
+			}
+			if (master->priv_flags & IFF_MASTER_8023AD &&
+			    skb->protocol == __constant_htons(ETH_P_SLOW))
+				return 0;
+
+			return 1;
+		}
+	}
+	return 0;
+#endif /* 0 */
+}
+#else
+int skb_bond_should_drop(struct sk_buff *skb)
+{
+	return 0;
+}
+#endif
+EXPORT_SYMBOL_GPL(skb_bond_should_drop);
+
 #ifdef CONFIG_NET_CLS_ACT
 /* TODO: Maybe we should just force sch_ingress to be compiled in
  * when CONFIG_NET_CLS_ACT is? otherwise some useless instructions


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
