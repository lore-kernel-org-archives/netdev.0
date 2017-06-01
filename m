From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 5/5] net: dsa: factor skb freeing on xmit
Date: Thu,  1 Jun 2017 16:07:15 -0400
Message-ID: <20170601200715.8438-6-vivien.didelot@savoirfairelinux.com>
References: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As of a86d8becc3f0 ("net: dsa: Factor bottom tag receive functions"),
the rcv caller frees the original SKB in case or error.

Be symmetric with that and make the xmit caller do the same.

At the same time, fix the checkpatch NULL comparison check:

        CHECK: Comparison to NULL could be written "!nskb"
    #208: FILE: net/dsa/tag_trailer.c:35:
    +	if (nskb == NULL)

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c       | 8 ++++++--
 net/dsa/tag_brcm.c    | 6 +-----
 net/dsa/tag_dsa.c     | 8 ++------
 net/dsa/tag_edsa.c    | 8 ++------
 net/dsa/tag_ksz.c     | 4 +---
 net/dsa/tag_lan9303.c | 5 +----
 net/dsa/tag_mtk.c     | 6 +-----
 net/dsa/tag_qca.c     | 6 +-----
 net/dsa/tag_trailer.c | 4 +---
 9 files changed, 16 insertions(+), 39 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0442b6bf52fa..1cfdb31a2f44 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -357,10 +357,14 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
-	/* Transmit function may have to reallocate the original SKB */
+	/* Transmit function may have to reallocate the original SKB,
+	 * in which case it must have freed it. Only free it here on error.
+	 */
 	nskb = p->xmit(skb, dev);
-	if (!nskb)
+	if (!nskb) {
+		kfree_skb(skb);
 		return NETDEV_TX_OK;
+	}
 
 	/* SKB for netpoll still need to be mangled with the protocol-specific
 	 * tag to be successfully transmitted
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 635ecb6781e4..c03860907f28 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -65,7 +65,7 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 	u8 *brcm_tag;
 
 	if (skb_cow_head(skb, BRCM_TAG_LEN) < 0)
-		goto out_free;
+		return NULL;
 
 	skb_push(skb, BRCM_TAG_LEN);
 
@@ -86,10 +86,6 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 	brcm_tag[3] = (1 << p->dp->index) & BRCM_IG_DSTMAP1_MASK;
 
 	return skb;
-
-out_free:
-	kfree_skb(skb);
-	return NULL;
 }
 
 static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 089c99c8ed51..12867a4b458f 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -28,7 +28,7 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (skb->protocol == htons(ETH_P_8021Q)) {
 		if (skb_cow_head(skb, 0) < 0)
-			goto out_free;
+			return NULL;
 
 		/*
 		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
@@ -46,7 +46,7 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	} else {
 		if (skb_cow_head(skb, DSA_HLEN) < 0)
-			goto out_free;
+			return NULL;
 		skb_push(skb, DSA_HLEN);
 
 		memmove(skb->data, skb->data + DSA_HLEN, 2 * ETH_ALEN);
@@ -62,10 +62,6 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	return skb;
-
-out_free:
-	kfree_skb(skb);
-	return NULL;
 }
 
 static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index a7eed1d43d80..67a9d26f9075 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -30,7 +30,7 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (skb->protocol == htons(ETH_P_8021Q)) {
 		if (skb_cow_head(skb, DSA_HLEN) < 0)
-			goto out_free;
+			return NULL;
 		skb_push(skb, DSA_HLEN);
 
 		memmove(skb->data, skb->data + DSA_HLEN, 2 * ETH_ALEN);
@@ -55,7 +55,7 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	} else {
 		if (skb_cow_head(skb, EDSA_HLEN) < 0)
-			goto out_free;
+			return NULL;
 		skb_push(skb, EDSA_HLEN);
 
 		memmove(skb->data, skb->data + EDSA_HLEN, 2 * ETH_ALEN);
@@ -75,10 +75,6 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	return skb;
-
-out_free:
-	kfree_skb(skb);
-	return NULL;
 }
 
 static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index dfcd2fff5b13..b94a334a1d02 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -46,10 +46,8 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else {
 		nskb = alloc_skb(NET_IP_ALIGN + skb->len +
 				 padlen + KSZ_INGRESS_TAG_LEN, GFP_ATOMIC);
-		if (!nskb) {
-			kfree_skb(skb);
+		if (!nskb)
 			return NULL;
-		}
 		skb_reserve(nskb, NET_IP_ALIGN);
 
 		skb_reset_mac_header(nskb);
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index afd59330b5f1..247774d149f9 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -52,7 +52,7 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb_cow_head(skb, LAN9303_TAG_LEN) < 0) {
 		dev_dbg(&dev->dev,
 			"Cannot make room for the special tag. Dropping packet\n");
-		goto out_free;
+		return NULL;
 	}
 
 	/* provide 'LAN9303_TAG_LEN' bytes additional space */
@@ -66,9 +66,6 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 	lan9303_tag[1] = htons(p->dp->index | BIT(4));
 
 	return skb;
-out_free:
-	kfree_skb(skb);
-	return NULL;
 }
 
 static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 4b4aaf1574aa..2f32b7ea3365 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -27,7 +27,7 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 	u8 *mtk_tag;
 
 	if (skb_cow_head(skb, MTK_HDR_LEN) < 0)
-		goto out_free;
+		return NULL;
 
 	skb_push(skb, MTK_HDR_LEN);
 
@@ -41,10 +41,6 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 	mtk_tag[3] = 0;
 
 	return skb;
-
-out_free:
-	kfree_skb(skb);
-	return NULL;
 }
 
 static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 44f545d2761a..4f43cf0b4eff 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -45,7 +45,7 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_bytes += skb->len;
 
 	if (skb_cow_head(skb, 0) < 0)
-		goto out_free;
+		return NULL;
 
 	skb_push(skb, QCA_HDR_LEN);
 
@@ -60,10 +60,6 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 	*phdr = htons(hdr);
 
 	return skb;
-
-out_free:
-	kfree_skb(skb);
-	return NULL;
 }
 
 static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index ec729c0ef390..b4f6db094409 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -32,10 +32,8 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 		padlen = 60 - skb->len;
 
 	nskb = alloc_skb(NET_IP_ALIGN + skb->len + padlen + 4, GFP_ATOMIC);
-	if (nskb == NULL) {
-		kfree_skb(skb);
+	if (!nskb)
 		return NULL;
-	}
 	skb_reserve(nskb, NET_IP_ALIGN);
 
 	skb_reset_mac_header(nskb);
-- 
2.13.0
