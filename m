From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: change tag_protocol to an enum
Date: Thu, 11 Sep 2014 11:57:22 -0700
Message-ID: <1410461842-15792-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, alexander.duyck@gmail.com,
	kernel@wantstofly.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:38386 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbaIKS5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 14:57:33 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so11952635pdb.39
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 11:57:32 -0700 (PDT)
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
 drivers/net/dsa/bcm_sf2.c         |  2 +-
 drivers/net/dsa/mv88e6060.c       |  2 +-
 drivers/net/dsa/mv88e6123_61_65.c |  4 ++--
 drivers/net/dsa/mv88e6131.c       |  2 +-
 include/net/dsa.h                 | 14 ++++++++++----
 net/dsa/slave.c                   |  8 ++++----
 net/dsa/tag_brcm.c                |  1 -
 7 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index bb7cb8e283b1..e9918c7f1792 100644
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
index 7a54ec04b418..d8037c1055ac 100644
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
index 69c42513dd72..975774f338c2 100644
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
index 953bc6a49e59..35541f2ceca3 100644
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
index 97712927a9d2..3e88b4ad274f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -22,7 +22,13 @@
 /* Not an official ethertype value, used only internally for DSA
  * demultiplexing
  */
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
@@ -89,7 +95,7 @@ struct dsa_switch_tree {
 	 */
 	struct net_device	*master_netdev;
 	const struct dsa_device_ops	*ops;
-	__be16			tag_protocol;
+	enum dsa_tag_protocol	tag_protocol;
 
 	/*
 	 * The switch and port to which the CPU is attached.
@@ -166,7 +172,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 struct dsa_switch_driver {
 	struct list_head	list;
 
-	__be16			tag_protocol;
+	enum dsa_tag_protocol	tag_protocol;
 	int			priv_size;
 
 	/*
@@ -215,7 +221,7 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
 
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
-	return dst->tag_protocol != 0;
+	return dst->tag_protocol != DSA_TAG_PROTO_NONE;
 }
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7333a4aebb7d..809eeb13eb12 100644
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
index e0b759ec209e..8fbc21c0de78 100644
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
