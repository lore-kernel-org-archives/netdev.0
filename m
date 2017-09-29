From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/7] net: dsa: add master helper to look up slaves
Date: Fri, 29 Sep 2017 17:19:15 -0400
Message-ID: <20170929211921.5571-2-vivien.didelot@savoirfairelinux.com>
References: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA tagging code does not need to know about the DSA architecture,
it only needs to return the slave device corresponding to the source
port index (and eventually the source device index for cascade-capable
switches) parsed from the frame received on the master device.

For this purpose, provide an inline dsa_master_get_slave helper which
validates the device and port indexes and look up the slave device.

This makes the tagging rcv functions more concise and robust, and also
makes dsa_get_cpu_port obsolete.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h    | 24 +++++++++++++++++++-----
 net/dsa/tag_brcm.c    |  9 ++-------
 net/dsa/tag_dsa.c     | 18 ++----------------
 net/dsa/tag_edsa.c    | 18 ++----------------
 net/dsa/tag_ksz.c     |  9 +++------
 net/dsa/tag_lan9303.c | 20 ++------------------
 net/dsa/tag_mtk.c     | 16 +++-------------
 net/dsa/tag_qca.c     | 17 +++--------------
 net/dsa/tag_trailer.c |  9 +++------
 9 files changed, 39 insertions(+), 101 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index eccc62776283..d429505dc4e7 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -113,6 +113,25 @@ int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 int dsa_master_ethtool_setup(struct net_device *dev);
 void dsa_master_ethtool_restore(struct net_device *dev);
 
+static inline struct net_device *dsa_master_get_slave(struct net_device *dev,
+						      int device, int port)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds;
+
+	if (device < 0 || device >= DSA_MAX_SWITCHES)
+		return NULL;
+
+	ds = dst->ds[device];
+	if (!ds)
+		return NULL;
+
+	if (port < 0 || port >= ds->num_ports)
+		return NULL;
+
+	return ds->ports[port].netdev;
+}
+
 /* port.c */
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
 		       struct switchdev_trans *trans);
@@ -182,9 +201,4 @@ static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
 	return p->dp->cpu_dp->netdev;
 }
 
-static inline struct dsa_port *dsa_get_cpu_port(struct dsa_switch_tree *dst)
-{
-	return dst->cpu_dp;
-}
-
 #endif
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index dbb016434ace..8e4bdb9d9ae3 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -92,9 +92,6 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				    struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
 	int source_port;
 	u8 *brcm_tag;
 
@@ -117,8 +114,8 @@ static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* Locate which port this is coming from */
 	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
 
-	/* Validate port against switch setup, either the port is totally */
-	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
+	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	if (!skb->dev)
 		return NULL;
 
 	/* Remove Broadcom tag and update checksum */
@@ -129,8 +126,6 @@ static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 		skb->data - ETH_HLEN - BRCM_TAG_LEN,
 		2 * ETH_ALEN);
 
-	skb->dev = ds->ports[source_port].netdev;
-
 	return skb;
 }
 
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index fbf9ca954773..c77218f173d1 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -67,8 +67,6 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
 	u8 *dsa_header;
 	int source_device;
 	int source_port;
@@ -93,18 +91,8 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	source_device = dsa_header[0] & 0x1f;
 	source_port = (dsa_header[1] >> 3) & 0x1f;
 
-	/*
-	 * Check that the source device exists and that the source
-	 * port is a registered DSA port.
-	 */
-	if (source_device >= DSA_MAX_SWITCHES)
-		return NULL;
-
-	ds = dst->ds[source_device];
-	if (!ds)
-		return NULL;
-
-	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
+	skb->dev = dsa_master_get_slave(dev, source_device, source_port);
+	if (!skb->dev)
 		return NULL;
 
 	/*
@@ -153,8 +141,6 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 			2 * ETH_ALEN);
 	}
 
-	skb->dev = ds->ports[source_port].netdev;
-
 	return skb;
 }
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 76367ba1b2e2..0b83cbe0c9e8 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -80,8 +80,6 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 				struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
 	u8 *edsa_header;
 	int source_device;
 	int source_port;
@@ -106,18 +104,8 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	source_device = edsa_header[0] & 0x1f;
 	source_port = (edsa_header[1] >> 3) & 0x1f;
 
-	/*
-	 * Check that the source device exists and that the source
-	 * port is a registered DSA port.
-	 */
-	if (source_device >= DSA_MAX_SWITCHES)
-		return NULL;
-
-	ds = dst->ds[source_device];
-	if (!ds)
-		return NULL;
-
-	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
+	skb->dev = dsa_master_get_slave(dev, source_device, source_port);
+	if (!skb->dev)
 		return NULL;
 
 	/*
@@ -172,8 +160,6 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 			2 * ETH_ALEN);
 	}
 
-	skb->dev = ds->ports[source_port].netdev;
-
 	return skb;
 }
 
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index 010ca0a336c4..b241c990cde0 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -80,22 +80,19 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
 	u8 *tag;
 	int source_port;
 
 	tag = skb_tail_pointer(skb) - KSZ_EGRESS_TAG_LEN;
 
 	source_port = tag[0] & 7;
-	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
+
+	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	if (!skb->dev)
 		return NULL;
 
 	pskb_trim_rcsum(skb, skb->len - KSZ_EGRESS_TAG_LEN);
 
-	skb->dev = ds->ports[source_port].netdev;
-
 	return skb;
 }
 
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 0b9826105e42..4f211e56c81f 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -71,17 +71,8 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 			struct packet_type *pt)
 {
 	u16 *lan9303_tag;
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
 	unsigned int source_port;
 
-	ds = dst->ds[0];
-
-	if (unlikely(!ds)) {
-		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing DSA switch device\n");
-		return NULL;
-	}
-
 	if (unlikely(!pskb_may_pull(skb, LAN9303_TAG_LEN))) {
 		dev_warn_ratelimited(&dev->dev,
 				     "Dropping packet, cannot pull\n");
@@ -103,16 +94,12 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	source_port = ntohs(lan9303_tag[1]) & 0x3;
 
-	if (source_port >= ds->num_ports) {
+	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	if (!skb->dev) {
 		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid source port\n");
 		return NULL;
 	}
 
-	if (!ds->ports[source_port].netdev) {
-		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid netdev or device\n");
-		return NULL;
-	}
-
 	/* remove the special VLAN tag between the MAC addresses
 	 * and the current ethertype field.
 	 */
@@ -120,9 +107,6 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 	memmove(skb->data - ETH_HLEN, skb->data - (ETH_HLEN + LAN9303_TAG_LEN),
 		2 * ETH_ALEN);
 
-	/* forward the packet to the dedicated interface */
-	skb->dev = ds->ports[source_port].netdev;
-
 	return skb;
 }
 
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index ec8ee5f43255..968586c5d40e 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -46,8 +46,6 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
 	int port;
 	__be16 *phdr, hdr;
 
@@ -68,20 +66,12 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
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
-	if (!ds->ports[port].netdev)
-		return NULL;
 
-	skb->dev = ds->ports[port].netdev;
+	skb->dev = dsa_master_get_slave(dev, 0, port);
+	if (!skb->dev)
+		return NULL;
 
 	return skb;
 }
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 1d4c70711c0f..8d33d9ebf910 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -65,9 +65,6 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds;
 	u8 ver;
 	int port;
 	__be16 *phdr, hdr;
@@ -92,20 +89,12 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
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
-	if (!ds->ports[port].netdev)
-		return NULL;
 
-	/* Update skb & forward the frame accordingly */
-	skb->dev = ds->ports[port].netdev;
+	skb->dev = dsa_master_get_slave(dev, 0, port);
+	if (!skb->dev)
+		return NULL;
 
 	return skb;
 }
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index d2fd4923aa3e..61668be267f5 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -58,9 +58,6 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-	struct dsa_switch *ds = cpu_dp->ds;
 	u8 *trailer;
 	int source_port;
 
@@ -73,13 +70,13 @@ static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 		return NULL;
 
 	source_port = trailer[1] & 7;
-	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
+
+	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	if (!skb->dev)
 		return NULL;
 
 	pskb_trim_rcsum(skb, skb->len - 4);
 
-	skb->dev = ds->ports[source_port].netdev;
-
 	return skb;
 }
 
-- 
2.14.1
