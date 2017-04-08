From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/3] net: dsa: Move skb_unshare() to dsa_switch_rcv()
Date: Sat,  8 Apr 2017 08:55:22 -0700
Message-ID: <20170408155523.20447-3-f.fainelli@gmail.com>
References: <20170408155523.20447-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35874 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751914AbdDHPzb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:55:31 -0400
Received: by mail-it0-f67.google.com with SMTP id a140so1600551ita.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 08:55:31 -0700 (PDT)
In-Reply-To: <20170408155523.20447-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All DSA tag receive functions need to unshare the skb before mangling it, move
this to the generic dsa_switch_rcv() function which will allow us to make the
tag receive function return their mangled skb without caring about freeing a
NULL skb.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c         | 4 ++++
 net/dsa/tag_brcm.c    | 5 -----
 net/dsa/tag_dsa.c     | 5 -----
 net/dsa/tag_edsa.c    | 5 -----
 net/dsa/tag_mtk.c     | 5 -----
 net/dsa/tag_qca.c     | 5 -----
 net/dsa/tag_trailer.c | 5 -----
 7 files changed, 4 insertions(+), 30 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6cad15da5892..d370c8bfa372 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -906,6 +906,10 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (!skb)
+		return 0;
+
 	return dst->rcv(skb, dev, pt, orig_dev);
 }
 
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 68d4feef96d4..263941769c88 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -102,10 +102,6 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	ds = dst->cpu_switch;
 
-	skb = skb_unshare(skb, GFP_ATOMIC);
-	if (skb == NULL)
-		goto out;
-
 	if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
 		goto out_drop;
 
@@ -151,7 +147,6 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 
 out_drop:
 	kfree_skb(skb);
-out:
 	return 0;
 }
 
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 377569c0e4f7..b7032699eaad 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -77,10 +77,6 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_device;
 	int source_port;
 
-	skb = skb_unshare(skb, GFP_ATOMIC);
-	if (skb == NULL)
-		goto out;
-
 	if (unlikely(!pskb_may_pull(skb, DSA_HLEN)))
 		goto out_drop;
 
@@ -175,7 +171,6 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 
 out_drop:
 	kfree_skb(skb);
-out:
 	return 0;
 }
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 30520ff9c9a2..b87009672b40 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -90,10 +90,6 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_device;
 	int source_port;
 
-	skb = skb_unshare(skb, GFP_ATOMIC);
-	if (skb == NULL)
-		goto out;
-
 	if (unlikely(!pskb_may_pull(skb, EDSA_HLEN)))
 		goto out_drop;
 
@@ -194,7 +190,6 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 
 out_drop:
 	kfree_skb(skb);
-out:
 	return 0;
 }
 
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 836c311a3c38..d0a477084870 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -55,10 +55,6 @@ static int mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	int port;
 	__be16 *phdr, hdr;
 
-	skb = skb_unshare(skb, GFP_ATOMIC);
-	if (!skb)
-		goto out;
-
 	if (unlikely(!pskb_may_pull(skb, MTK_HDR_LEN)))
 		goto out_drop;
 
@@ -105,7 +101,6 @@ static int mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 
 out_drop:
 	kfree_skb(skb);
-out:
 	return 0;
 }
 
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 6579d6db1bc6..d1324649808c 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -75,10 +75,6 @@ static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	int port;
 	__be16 *phdr, hdr;
 
-	skb = skb_unshare(skb, GFP_ATOMIC);
-	if (!skb)
-		goto out;
-
 	if (unlikely(!pskb_may_pull(skb, QCA_HDR_LEN)))
 		goto out_drop;
 
@@ -126,7 +122,6 @@ static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 
 out_drop:
 	kfree_skb(skb);
-out:
 	return 0;
 }
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index f5c764ee2968..1fc0b221a70f 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -68,10 +68,6 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	ds = dst->cpu_switch;
 
-	skb = skb_unshare(skb, GFP_ATOMIC);
-	if (skb == NULL)
-		goto out;
-
 	if (skb_linearize(skb))
 		goto out_drop;
 
@@ -100,7 +96,6 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 
 out_drop:
 	kfree_skb(skb);
-out:
 	return 0;
 }
 
-- 
2.9.3
