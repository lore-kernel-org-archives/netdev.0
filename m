From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: dsa: change tag_protocol to an enum
Date: Thu, 11 Sep 2014 21:18:09 -0700
Message-ID: <1410495489-7050-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, kernel@wantstofly.org,
	alexander.duyck@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:40875 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbaILEST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 00:18:19 -0400
Received: by mail-oi0-f48.google.com with SMTP id a141so125073oig.21
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 21:18:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we introduced an additional multiplexing/demultiplexing layer
with commit 3e8a72d1dae37 ("net: dsa: reduce number of protocol hooks")
that lives within the DSA code, we no longer need to have a given switch
driver tag_protocol be an actual ethertype value, instead, we can
replace it with an enum: dsa_tag_protocol.

Do this replacement in the drivers, which allows us to get rid of the
cpu_to_be16()/htons() dance, and remove ETH_P_BRCMTAG since we do not
need it anymore.

Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- removed now obsolete comment about the former ETH_P_BRCMTAG we did
  introduce earlier

 drivers/net/dsa/bcm_sf2.c         |  2 +-
 drivers/net/dsa/mv88e6060.c       |  2 +-
 drivers/net/dsa/mv88e6123_61_65.c |  4 ++--
 drivers/net/dsa/mv88e6131.c       |  2 +-
 include/net/dsa.h                 | 17 ++++++++++-------
 net/dsa/slave.c                   |  8 ++++----
 net/dsa/tag_brcm.c                |  1 -
 7 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index bb7cb8e..e9918c7 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -592,7 +592,7 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 }
 
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
-	.tag_protocol		= htons(ETH_P_BRCMTAG),
+	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.priv_size		= sizeof(struct bcm_sf2_priv),
 	.probe			= bcm_sf2_sw_probe,
 	.setup			= bcm_sf2_sw_setup,
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 7a54ec0..d8037c1 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -258,7 +258,7 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
 }
 
 static struct dsa_switch_driver mv88e6060_switch_driver = {
-	.tag_protocol	= htons(ETH_P_TRAILER),
+	.tag_protocol	= DSA_TAG_PROTO_TRAILER,
 	.probe		= mv88e6060_probe,
 	.setup		= mv88e6060_setup,
 	.set_addr	= mv88e6060_set_addr,
diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 69c4251..975774f 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -207,7 +207,7 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 	 */
 	val = 0x0433;
 	if (dsa_is_cpu_port(ds, p)) {
-		if (ds->dst->tag_protocol == htons(ETH_P_EDSA))
+		if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
 			val |= 0x3300;
 		else
 			val |= 0x0100;
@@ -391,7 +391,7 @@ static int mv88e6123_61_65_get_sset_count(struct dsa_switch *ds)
 }
 
 struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
-	.tag_protocol		= cpu_to_be16(ETH_P_EDSA),
+	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6123_61_65_probe,
 	.setup			= mv88e6123_61_65_setup,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 953bc6a..35541f2 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -379,7 +379,7 @@ static int mv88e6131_get_sset_count(struct dsa_switch *ds)
 }
 
 struct dsa_switch_driver mv88e6131_switch_driver = {
-	.tag_protocol		= cpu_to_be16(ETH_P_DSA),
+	.tag_protocol		= DSA_TAG_PROTO_DSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6131_probe,
 	.setup			= mv88e6131_setup,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 9771292..8a8a5d9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -19,10 +19,13 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 
-/* Not an official ethertype value, used only internally for DSA
- * demultiplexing
- */
-#define ETH_P_BRCMTAG		(ETH_P_XDSA + 1)
+enum dsa_tag_protocol {
+	DSA_TAG_PROTO_NONE = 0,
+	DSA_TAG_PROTO_DSA,
+	DSA_TAG_PROTO_TRAILER,
+	DSA_TAG_PROTO_EDSA,
+	DSA_TAG_PROTO_BRCM,
+};
 
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
@@ -89,7 +92,7 @@ struct dsa_switch_tree {
 	 */
 	struct net_device	*master_netdev;
 	const struct dsa_device_ops	*ops;
-	__be16			tag_protocol;
+	enum dsa_tag_protocol	tag_protocol;
 
 	/*
 	 * The switch and port to which the CPU is attached.
@@ -166,7 +169,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 struct dsa_switch_driver {
 	struct list_head	list;
 
-	__be16			tag_protocol;
+	enum dsa_tag_protocol	tag_protocol;
 	int			priv_size;
 
 	/*
@@ -215,7 +218,7 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
 
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
-	return dst->tag_protocol != 0;
+	return dst->tag_protocol != DSA_TAG_PROTO_NONE;
 }
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7333a4a..809eeb1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -437,22 +437,22 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	switch (ds->dst->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
-	case htons(ETH_P_DSA):
+	case DSA_TAG_PROTO_DSA:
 		ds->dst->ops = &dsa_netdev_ops;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
-	case htons(ETH_P_EDSA):
+	case DSA_TAG_PROTO_EDSA:
 		ds->dst->ops = &edsa_netdev_ops;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
-	case htons(ETH_P_TRAILER):
+	case DSA_TAG_PROTO_TRAILER:
 		ds->dst->ops = &trailer_netdev_ops;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_BRCM
-	case htons(ETH_P_BRCMTAG):
+	case DSA_TAG_PROTO_BRCM:
 		ds->dst->ops = &brcm_netdev_ops;
 		break;
 #endif
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index e0b759e..8fbc21c 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -91,7 +91,6 @@ static netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	skb->protocol = htons(ETH_P_BRCMTAG);
 	skb->dev = p->parent->dst->master_netdev;
 	dev_queue_xmit(skb);
 
-- 
1.9.1
