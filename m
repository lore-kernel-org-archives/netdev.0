From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/4] net: dsa: change dsa_ptr for a dsa_master
Date: Thu, 31 Aug 2017 14:37:45 -0400
Message-ID: <20170831183746.2109-4-vivien.didelot@savoirfairelinux.com>
References: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_ptr of a net_device currently points to a dsa_switch_tree.

This is not correct because the interface is physically linked to a
switch port, and because several network interface could point to
several (so called "CPU") ports of the same DSA switch tree.

Because the tagging operations are specific to the DSA master port and
not the whole switch tree, move the tag_ops pointer in dsa_master.

Finally change the dsa_ptr from dsa_switch_tree to a dsa_master.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/linux/netdevice.h |  4 ++--
 include/net/dsa.h         | 21 ++++++++++-----------
 net/dsa/dsa.c             |  6 +++---
 net/dsa/dsa2.c            | 13 +++++--------
 net/dsa/dsa_priv.h        |  8 ++------
 net/dsa/legacy.c          | 13 ++++---------
 net/dsa/master.c          | 28 ++++++++++++++++++++++------
 net/dsa/slave.c           |  2 +-
 net/dsa/tag_brcm.c        |  5 ++---
 net/dsa/tag_dsa.c         |  3 ++-
 net/dsa/tag_edsa.c        |  3 ++-
 net/dsa/tag_ksz.c         |  5 ++---
 net/dsa/tag_lan9303.c     |  6 ++----
 net/dsa/tag_mtk.c         | 12 ++----------
 net/dsa/tag_qca.c         | 12 ++----------
 net/dsa/tag_trailer.c     |  5 ++---
 16 files changed, 65 insertions(+), 81 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 29bf06ff157c..eb0501c9afc5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -55,7 +55,7 @@
 struct netpoll_info;
 struct device;
 struct phy_device;
-struct dsa_switch_tree;
+struct dsa_master;
 
 /* 802.11 specific */
 struct wireless_dev;
@@ -1752,7 +1752,7 @@ struct net_device {
 	struct vlan_info __rcu	*vlan_info;
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA)
-	struct dsa_switch_tree	*dsa_ptr;
+	struct dsa_master	*dsa_ptr;
 #endif
 #if IS_ENABLED(CONFIG_TIPC)
 	struct tipc_bearer __rcu *tipc_ptr;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index f4a5afc4255b..d5b24cd10f79 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -130,11 +130,6 @@ struct dsa_switch_tree {
 	 */
 	struct dsa_platform_data	*pd;
 
-	/* Copy of tag_ops->rcv for faster access in hot path */
-	struct sk_buff *	(*rcv)(struct sk_buff *skb,
-				       struct net_device *dev,
-				       struct packet_type *pt);
-
 	/*
 	 * The switch port to which the CPU is attached.
 	 */
@@ -144,12 +139,6 @@ struct dsa_switch_tree {
 	 * Data for the individual switch chips.
 	 */
 	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
-
-	/*
-	 * Tagging protocol operations for adding and removing an
-	 * encapsulation tag.
-	 */
-	const struct dsa_device_ops *tag_ops;
 };
 
 /* TC matchall action types, only mirroring for now */
@@ -177,6 +166,16 @@ struct dsa_master {
 	struct dsa_port *port;
 	struct net_device *netdev;
 
+	/*
+	 * Tagging protocol operations for adding and removing an
+	 * encapsulation tag.
+	 */
+	const struct dsa_device_ops *tag_ops;
+
+	/* Copy of tag_ops->rcv for faster access in hot path */
+	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt);
+
 	/* Original copy of the master netdev ethtool_ops */
 	const struct ethtool_ops *orig_ethtool_ops;
 	struct ethtool_ops ethtool_ops;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 81c852e32821..f2ebd3572d6f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -160,12 +160,12 @@ EXPORT_SYMBOL_GPL(dsa_dev_to_net_device);
 static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 			  struct packet_type *pt, struct net_device *unused)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_master *master = dev->dsa_ptr;
 	struct sk_buff *nskb = NULL;
 	struct pcpu_sw_netstats *s;
 	struct dsa_slave_priv *p;
 
-	if (unlikely(dst == NULL)) {
+	if (unlikely(!master)) {
 		kfree_skb(skb);
 		return 0;
 	}
@@ -174,7 +174,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!skb)
 		return 0;
 
-	nskb = dst->rcv(skb, dev, pt);
+	nskb = master->rcv(skb, dev, pt);
 	if (!nskb) {
 		kfree_skb(skb);
 		return 0;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index d60f681b96cc..80a9706324f2 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -444,7 +444,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dst->master->netdev->dsa_ptr = dst;
+	dst->master->netdev->dsa_ptr = dst->master;
 	dst->applied = true;
 
 	return 0;
@@ -487,9 +487,9 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 			 struct dsa_switch_tree *dst,
 			 struct dsa_switch *ds)
 {
-	enum dsa_tag_protocol tag_protocol;
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
+	int err;
 
 	if (port->dn) {
 		ethernet = of_parse_phandle(port->dn, "ethernet", 0);
@@ -516,16 +516,13 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	 */
 	ds->cpu_port_mask |= BIT(index);
 
-	tag_protocol = ds->ops->get_tag_protocol(ds);
-	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
-	if (IS_ERR(dst->tag_ops)) {
+	err = dsa_master_tag_protocol(dst->master);
+	if (err) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
 		ds->cpu_port_mask &= ~BIT(index);
-		return PTR_ERR(dst->tag_ops);
+		return err;
 	}
 
-	dst->rcv = dst->tag_ops->rcv;
-
 	return 0;
 }
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 4fa14b4305b9..59f155cbbe87 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -66,7 +66,7 @@ struct dsa_notifier_vlan_info {
 };
 
 struct dsa_slave_priv {
-	/* Copy of dp->ds->dst->tag_ops->xmit for faster access in hot path */
+	/* Copy of the master xmit tagging op for faster access in hot path */
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
@@ -115,6 +115,7 @@ struct dsa_master *dsa_master_create(struct dsa_port *port,
 				     struct net_device *netdev);
 int dsa_master_ethtool_setup(struct dsa_master *master);
 void dsa_master_ethtool_restore(struct dsa_master *master);
+int dsa_master_tag_protocol(struct dsa_master *master);
 
 /* port.c */
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
@@ -183,9 +184,4 @@ static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
 	return p->dp->ds->dst->master->netdev;
 }
 
-static inline struct dsa_port *dsa_get_cpu_port(struct dsa_switch_tree *dst)
-{
-	return dst->master->port;
-}
-
 #endif
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index acd81c488bf4..3afedd9758c5 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -147,14 +147,9 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	 * switch.
 	 */
 	if (dst->master->port->ds == ds) {
-		enum dsa_tag_protocol tag_protocol;
-
-		tag_protocol = ops->get_tag_protocol(ds);
-		dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
-		if (IS_ERR(dst->tag_ops))
-			return PTR_ERR(dst->tag_ops);
-
-		dst->rcv = dst->tag_ops->rcv;
+		ret = dsa_master_tag_protocol(dst->master);
+		if (ret)
+			return ret;
 	}
 
 	memcpy(ds->rtable, cd->rtable, sizeof(ds->rtable));
@@ -607,7 +602,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dev->dsa_ptr = dst;
+	dev->dsa_ptr = dst->master;
 
 	return 0;
 }
diff --git a/net/dsa/master.c b/net/dsa/master.c
index 9ecce3e7c8df..6714750ee13f 100644
--- a/net/dsa/master.c
+++ b/net/dsa/master.c
@@ -16,8 +16,7 @@ static void dsa_master_get_ethtool_stats(struct net_device *dev,
 					 struct ethtool_stats *stats,
 					 uint64_t *data)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_master *master = dst->master;
+	struct dsa_master *master = dev->dsa_ptr;
 	struct dsa_port *port = master->port;
 	struct dsa_switch *ds = port->ds;
 	int count = 0;
@@ -33,8 +32,7 @@ static void dsa_master_get_ethtool_stats(struct net_device *dev,
 
 static int dsa_master_get_sset_count(struct net_device *dev, int sset)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_master *master = dst->master;
+	struct dsa_master *master = dev->dsa_ptr;
 	struct dsa_port *port = master->port;
 	struct dsa_switch *ds = port->ds;
 	int count = 0;
@@ -51,8 +49,7 @@ static int dsa_master_get_sset_count(struct net_device *dev, int sset)
 static void dsa_master_get_strings(struct net_device *dev, uint32_t stringset,
 				   uint8_t *data)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_master *master = dst->master;
+	struct dsa_master *master = dev->dsa_ptr;
 	struct dsa_port *port = master->port;
 	struct dsa_switch *ds = port->ds;
 	int len = ETH_GSTRING_LEN;
@@ -116,6 +113,25 @@ void dsa_master_ethtool_restore(struct dsa_master *master)
 	master->orig_ethtool_ops = NULL;
 }
 
+int dsa_master_tag_protocol(struct dsa_master *master)
+{
+	struct dsa_switch *ds = master->port->ds;
+	enum dsa_tag_protocol proto;
+
+	if (!ds->ops->get_tag_protocol)
+		return -EOPNOTSUPP;
+
+	proto = ds->ops->get_tag_protocol(ds);
+
+	master->tag_ops = dsa_resolve_tag_protocol(proto);
+	if (IS_ERR(master->tag_ops))
+		return PTR_ERR(master->tag_ops);
+
+	master->rcv = master->tag_ops->rcv;
+
+	return 0;
+}
+
 struct dsa_master *dsa_master_create(struct dsa_port *port,
 				     struct net_device *netdev)
 {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 99f9e48a6cee..d5a03ef8d0e0 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1206,7 +1206,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	}
 	p->dp = port;
 	INIT_LIST_HEAD(&p->mall_tc_list);
-	p->xmit = dst->tag_ops->xmit;
+	p->xmit = dst->master->tag_ops->xmit;
 
 	p->old_pause = -1;
 	p->old_link = -1;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index de74c3f77818..417266f23bed 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -91,9 +91,8 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				    struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch *ds = master->port->ds;
 	int source_port;
 	u8 *brcm_tag;
 
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index fbf9ca954773..7897bbd1a110 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -67,7 +67,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = master->port->ds->dst;
 	struct dsa_switch *ds;
 	u8 *dsa_header;
 	int source_device;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 76367ba1b2e2..12f9efed6251 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -80,7 +80,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 				struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = master->port->ds->dst;
 	struct dsa_switch *ds;
 	u8 *edsa_header;
 	int source_device;
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index 17f30675c15c..7043d51a7a80 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -78,9 +78,8 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch *ds = master->port->ds;
 	u8 *tag;
 	int source_port;
 
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 0b9826105e42..afb3df46712a 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -70,13 +70,11 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 			struct packet_type *pt)
 {
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch *ds = master->port->ds;
 	u16 *lan9303_tag;
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
 	unsigned int source_port;
 
-	ds = dst->ds[0];
-
 	if (unlikely(!ds)) {
 		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing DSA switch device\n");
 		return NULL;
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index ec8ee5f43255..7af26afaa8ac 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -46,8 +46,8 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch *ds = master->port->ds;
 	int port;
 	__be16 *phdr, hdr;
 
@@ -68,14 +68,6 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 		skb->data - ETH_HLEN - MTK_HDR_LEN,
 		2 * ETH_ALEN);
 
-	/* This protocol doesn't support cascading multiple
-	 * switches so it's safe to assume the switch is first
-	 * in the tree.
-	 */
-	ds = dst->ds[0];
-	if (!ds)
-		return NULL;
-
 	/* Get source port information */
 	port = (hdr & MTK_HDR_RECV_SOURCE_PORT_MASK);
 	if (!ds->ports[port].netdev)
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 1d4c70711c0f..a49cc7c6fac9 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -65,9 +65,8 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds;
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch *ds = master->port->ds;
 	u8 ver;
 	int port;
 	__be16 *phdr, hdr;
@@ -92,13 +91,6 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	memmove(skb->data - ETH_HLEN, skb->data - ETH_HLEN - QCA_HDR_LEN,
 		ETH_HLEN - QCA_HDR_LEN);
 
-	/* This protocol doesn't support cascading multiple switches so it's
-	 * safe to assume the switch is first in the tree
-	 */
-	ds = cpu_dp->ds;
-	if (!ds)
-		return NULL;
-
 	/* Get source port information */
 	port = (hdr & QCA_HDR_RECV_SOURCE_PORT_MASK);
 	if (!ds->ports[port].netdev)
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 8707157dea32..a3dacfb48dc0 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -58,9 +58,8 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
+	struct dsa_master *master = dev->dsa_ptr;
+	struct dsa_switch *ds = master->port->ds;
 	u8 *trailer;
 	int source_port;
 
-- 
2.14.1
