From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: dsa: Refactor transmit path
Date: Thu, 30 Jul 2015 12:35:38 -0700
Message-ID: <1438284939-2750-4-git-send-email-f.fainelli@gmail.com>
References: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36621 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbG3TjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 15:39:15 -0400
Received: by pachj5 with SMTP id hj5so28003981pac.3
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 12:39:15 -0700 (PDT)
In-Reply-To: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All tagging protocols do the same thing: increment device statistics,
make room for the tag to be inserted, create the tag, invoke the parent
network device transmit function.

In order to prepare for adding netpoll support, which requires the tag
creation, but not using the parent network device transmit function, do
some little refactoring which eliminates duplication between the 4
tagging protocols supported.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa_priv.h    |  4 ++--
 net/dsa/slave.c       | 16 +++++++++++++++-
 net/dsa/tag_brcm.c    | 15 +++------------
 net/dsa/tag_dsa.c     | 12 +++---------
 net/dsa/tag_edsa.c    | 12 +++---------
 net/dsa/tag_trailer.c | 12 +++---------
 6 files changed, 29 insertions(+), 42 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d5f1f9b862ea..92ec9d839348 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -15,7 +15,7 @@
 #include <linux/netdevice.h>
 
 struct dsa_device_ops {
-	netdev_tx_t (*xmit)(struct sk_buff *skb, struct net_device *dev);
+	int (*xmit)(struct sk_buff *skb, struct net_device *dev);
 	int (*rcv)(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev);
 };
@@ -26,7 +26,7 @@ struct dsa_slave_priv {
 	 * switch port.
 	 */
 	struct net_device	*dev;
-	netdev_tx_t		(*xmit)(struct sk_buff *skb,
+	int			(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
 	/*
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0917123790ea..5495c23765ea 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -421,8 +421,22 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
+	int ret;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
-	return p->xmit(skb, dev);
+	ret = p->xmit(skb, dev);
+	if (ret)
+		return NETDEV_TX_OK;
+
+	/* Queue the SKB for transmission on the parent interface, but
+	 * do not modify its EtherType
+	 */
+	skb->dev = p->parent->dst->master_netdev;
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
 }
 
 static netdev_tx_t dsa_slave_notag_xmit(struct sk_buff *skb,
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 83d3572cdb20..db16d281e7a4 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -58,14 +58,11 @@
 #define BRCM_EG_TC_MASK		0x7
 #define BRCM_EG_PID_MASK	0x1f
 
-static netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
+static int brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *brcm_tag;
 
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
 	if (skb_cow_head(skb, BRCM_TAG_LEN) < 0)
 		goto out_free;
 
@@ -87,17 +84,11 @@ static netdev_tx_t brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 		brcm_tag[2] = BRCM_IG_DSTMAP2_MASK;
 	brcm_tag[3] = (1 << p->port) & BRCM_IG_DSTMAP1_MASK;
 
-	/* Queue the SKB for transmission on the parent interface, but
-	 * do not modify its EtherType
-	 */
-	skb->dev = p->parent->dst->master_netdev;
-	dev_queue_xmit(skb);
-
-	return NETDEV_TX_OK;
+	return 0;
 
 out_free:
 	kfree_skb(skb);
-	return NETDEV_TX_OK;
+	return -ENOMEM;
 }
 
 static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 2dab27063273..e6bd18542a51 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -15,14 +15,11 @@
 
 #define DSA_HLEN	4
 
-static netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
+static int dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *dsa_header;
 
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
 	/*
 	 * Convert the outermost 802.1q tag to a DSA tag for tagged
 	 * packets, or insert a DSA tag between the addresses and
@@ -63,14 +60,11 @@ static netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		dsa_header[3] = 0x00;
 	}
 
-	skb->dev = p->parent->dst->master_netdev;
-	dev_queue_xmit(skb);
-
-	return NETDEV_TX_OK;
+	return 0;
 
 out_free:
 	kfree_skb(skb);
-	return NETDEV_TX_OK;
+	return -ENOMEM;
 }
 
 static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 9aeda596f7ec..2b22d9fc55df 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -16,14 +16,11 @@
 #define DSA_HLEN	4
 #define EDSA_HLEN	8
 
-static netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
+static int edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *edsa_header;
 
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
 	/*
 	 * Convert the outermost 802.1q tag to a DSA tag and prepend
 	 * a DSA ethertype field is the packet is tagged, or insert
@@ -76,14 +73,11 @@ static netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[7] = 0x00;
 	}
 
-	skb->dev = p->parent->dst->master_netdev;
-	dev_queue_xmit(skb);
-
-	return NETDEV_TX_OK;
+	return 0;
 
 out_free:
 	kfree_skb(skb);
-	return NETDEV_TX_OK;
+	return -ENOMEM;
 }
 
 static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index e268f9db8893..1e90db207f13 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -13,16 +13,13 @@
 #include <linux/slab.h>
 #include "dsa_priv.h"
 
-static netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
+static int trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct sk_buff *nskb;
 	int padlen;
 	u8 *trailer;
 
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
 	/*
 	 * We have to make sure that the trailer ends up as the very
 	 * last 4 bytes of the packet.  This means that we have to pad
@@ -36,7 +33,7 @@ static netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	nskb = alloc_skb(NET_IP_ALIGN + skb->len + padlen + 4, GFP_ATOMIC);
 	if (nskb == NULL) {
 		kfree_skb(skb);
-		return NETDEV_TX_OK;
+		return -ENOMEM;
 	}
 	skb_reserve(nskb, NET_IP_ALIGN);
 
@@ -57,10 +54,7 @@ static netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	trailer[2] = 0x10;
 	trailer[3] = 0x00;
 
-	nskb->dev = p->parent->dst->master_netdev;
-	dev_queue_xmit(nskb);
-
-	return NETDEV_TX_OK;
+	return 0;
 }
 
 static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
-- 
2.1.0
