From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: dsa: Factor bottom tag receive functions
Date: Fri,  7 Apr 2017 13:41:54 -0700
Message-ID: <20170407204154.9651-4-f.fainelli@gmail.com>
References: <20170407204154.9651-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36526 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753804AbdDGUmH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:42:07 -0400
Received: by mail-qk0-f194.google.com with SMTP id v75so11688599qkb.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 13:42:06 -0700 (PDT)
In-Reply-To: <20170407204154.9651-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All DSA tag receive functions do strictly the same thing after they have located
the originating source port from their tag specific protocol:

- push ETH_HLEN bytes
- set pkt_type to PACKET_HOST
- call eth_type_trans()
- bump up counters
- call netif_receive_skb()

Factor all of that into dsa_switch_rcv(). This also makes us return a pointer to
a sk_buff, which makes us symetric with the xmit function.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h     |  2 +-
 net/dsa/dsa.c         | 20 +++++++++++++++++++-
 net/dsa/dsa_priv.h    |  5 +++--
 net/dsa/tag_brcm.c    | 18 +++++-------------
 net/dsa/tag_dsa.c     | 18 +++++-------------
 net/dsa/tag_edsa.c    | 18 +++++-------------
 net/dsa/tag_qca.c     | 18 +++++-------------
 net/dsa/tag_trailer.c | 18 +++++-------------
 8 files changed, 48 insertions(+), 69 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ffe56cc338fe..671a00aa35de 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -123,7 +123,7 @@ struct dsa_switch_tree {
 	 * protocol to use.
 	 */
 	struct net_device	*master_netdev;
-	int			(*rcv)(struct sk_buff *skb,
+	struct sk_buff *	(*rcv)(struct sk_buff *skb,
 				       struct net_device *dev,
 				       struct packet_type *pt,
 				       struct net_device *orig_dev);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index c20da7bfc771..21f960ef8138 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -23,6 +23,7 @@
 #include <linux/sysfs.h>
 #include <linux/phy_fixed.h>
 #include <linux/gpio/consumer.h>
+#include <linux/etherdevice.h>
 #include <net/dsa.h>
 #include "dsa_priv.h"
 
@@ -897,6 +898,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 			  struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct sk_buff *nskb = NULL;
 
 	if (unlikely(dst == NULL)) {
 		kfree_skb(skb);
@@ -907,7 +909,23 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!skb)
 		return 0;
 
-	return dst->rcv(skb, dev, pt, orig_dev);
+	nskb = dst->rcv(skb, dev, pt, orig_dev);
+	if (!nskb) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	skb = nskb;
+	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
+	skb->protocol = eth_type_trans(skb, skb->dev);
+
+	skb->dev->stats.rx_packets++;
+	skb->dev->stats.rx_bytes += skb->len;
+
+	netif_receive_skb(skb);
+
+	return 0;
 }
 
 static struct packet_type dsa_pack_type __read_mostly = {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 0706a511244e..f4ac8d5fb8d5 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -17,8 +17,9 @@
 
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
-	int (*rcv)(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev);
+	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt,
+			       struct net_device *orig_dev);
 };
 
 struct dsa_slave_priv {
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 263941769c88..2a9b52c5af86 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -92,8 +92,9 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 	return NULL;
 }
 
-static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-			struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
+				    struct packet_type *pt,
+				    struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
@@ -133,21 +134,12 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 		skb->data - ETH_HLEN - BRCM_TAG_LEN,
 		2 * ETH_ALEN);
 
-	skb_push(skb, ETH_HLEN);
-	skb->pkt_type = PACKET_HOST;
 	skb->dev = ds->ports[source_port].netdev;
-	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->stats.rx_packets++;
-	skb->dev->stats.rx_bytes += skb->len;
-
-	netif_receive_skb(skb);
-
-	return 0;
+	return skb;
 
 out_drop:
-	kfree_skb(skb);
-	return 0;
+	return NULL;
 }
 
 const struct dsa_device_ops brcm_netdev_ops = {
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index b7032699eaad..1c6633f0de01 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -68,8 +68,9 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NULL;
 }
 
-static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt,
+			       struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
@@ -158,20 +159,11 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	skb->dev = ds->ports[source_port].netdev;
-	skb_push(skb, ETH_HLEN);
-	skb->pkt_type = PACKET_HOST;
-	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->stats.rx_packets++;
-	skb->dev->stats.rx_bytes += skb->len;
-
-	netif_receive_skb(skb);
-
-	return 0;
+	return skb;
 
 out_drop:
-	kfree_skb(skb);
-	return 0;
+	return NULL;
 }
 
 const struct dsa_device_ops dsa_netdev_ops = {
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index b87009672b40..d9c668aa5e54 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -81,8 +81,9 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NULL;
 }
 
-static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
+				struct packet_type *pt,
+				struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
@@ -177,20 +178,11 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	skb->dev = ds->ports[source_port].netdev;
-	skb_push(skb, ETH_HLEN);
-	skb->pkt_type = PACKET_HOST;
-	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->stats.rx_packets++;
-	skb->dev->stats.rx_bytes += skb->len;
-
-	netif_receive_skb(skb);
-
-	return 0;
+	return skb;
 
 out_drop:
-	kfree_skb(skb);
-	return 0;
+	return NULL;
 }
 
 const struct dsa_device_ops edsa_netdev_ops = {
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index d1324649808c..3ba3f59f7a34 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -66,8 +66,9 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NULL;
 }
 
-static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-		       struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
+				   struct packet_type *pt,
+				   struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
@@ -108,21 +109,12 @@ static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto out_drop;
 
 	/* Update skb & forward the frame accordingly */
-	skb_push(skb, ETH_HLEN);
-	skb->pkt_type = PACKET_HOST;
 	skb->dev = ds->ports[port].netdev;
-	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->stats.rx_packets++;
-	skb->dev->stats.rx_bytes += skb->len;
-
-	netif_receive_skb(skb);
-
-	return 0;
+	return skb;
 
 out_drop:
-	kfree_skb(skb);
-	return 0;
+	return NULL;
 }
 
 const struct dsa_device_ops qca_netdev_ops = {
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 1fc0b221a70f..aafc2fc74c30 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -58,8 +58,9 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	return nskb;
 }
 
-static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
-		       struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
+				   struct packet_type *pt,
+				   struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
@@ -83,20 +84,11 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 	pskb_trim_rcsum(skb, skb->len - 4);
 
 	skb->dev = ds->ports[source_port].netdev;
-	skb_push(skb, ETH_HLEN);
-	skb->pkt_type = PACKET_HOST;
-	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->stats.rx_packets++;
-	skb->dev->stats.rx_bytes += skb->len;
-
-	netif_receive_skb(skb);
-
-	return 0;
+	return skb;
 
 out_drop:
-	kfree_skb(skb);
-	return 0;
+	return NULL;
 }
 
 const struct dsa_device_ops trailer_netdev_ops = {
-- 
2.9.3
