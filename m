From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC/RFT 2/4] GSO: generalize for mac80211
Date: Wed, 30 Apr 2008 14:40:57 +0200
Message-ID: <20080430130049.359549000@sipsolutions.net>
References: <20080430124055.091382000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52845 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756676AbYD3OHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 10:07:45 -0400
Content-Disposition: inline; filename=037-generalize-gso-functions.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new function dev_skb_segment() that generalises
the existing dev_gso_segment() by allowing to give a segmentation
function. mac80211 will use that function using the segmentation
function skb_segment().

This patch also changes dev_gso_skb_destructor() to be safe when
the skb no longer has any segments, this will happen when mac80211
has internally passed off all the fragments to the driver instead
of asking dev_hard_start_xmit() to do it (which protects against
this by resetting the destructor if it has sent all fragments.)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   38 ++++++++++++++++++++++++++++++--------
 2 files changed, 31 insertions(+), 8 deletions(-)

--- everything.orig/net/core/dev.c	2008-04-30 01:52:23.000000000 +0200
+++ everything/net/core/dev.c	2008-04-30 03:46:33.000000000 +0200
@@ -1491,13 +1491,13 @@ static void dev_gso_skb_destructor(struc
 {
 	struct dev_gso_cb *cb;
 
-	do {
+	while (skb->next) {
 		struct sk_buff *nskb = skb->next;
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
 		kfree_skb(nskb);
-	} while (skb->next);
+	}
 
 	cb = DEV_GSO_CB(skb);
 	if (cb->destructor)
@@ -1505,22 +1505,31 @@ static void dev_gso_skb_destructor(struc
 }
 
 /**
- *	dev_gso_segment - Perform emulated hardware segmentation on skb.
+ *	dev_skb_segment - Perform segmentation on skb.
  *	@skb: buffer to segment
+ *	@segmfn: function that does the actual segmentation
  *
- *	This function segments the given skb and stores the list of segments
- *	in skb->next.
+ *	This function segments the given skb and stores the list
+ *	of segments in skb->next. The segmentation function is
+ *	used to do the actual segmentation, it must return the
+ *	list of segments as chained via the returned skb's @next
+ *	pointer. The segmentation function is given the skb to
+ *	segment and the features of the device the skb is going
+ *	to. The segmentation function needs to return an ERR_PTR
+ *	or a valid sk_buff pointer (or NULL for no segments.)
+ *
+ *	Note that segmentation needs the skbs @cb data.
  */
-static int dev_gso_segment(struct sk_buff *skb)
+int dev_skb_segment(struct sk_buff *skb, struct sk_buff *(segmfn)(struct sk_buff *skb, int feat))
 {
 	struct net_device *dev = skb->dev;
 	struct sk_buff *segs;
 	int features = dev->features & ~(illegal_highdma(dev, skb) ?
 					 NETIF_F_SG : 0);
 
-	segs = skb_gso_segment(skb, features);
+	segs = segmfn(skb, features);
 
-	/* Verifying header integrity only. */
+	/* Verifying header integrity only/no segments required. */
 	if (!segs)
 		return 0;
 
@@ -1533,6 +1542,19 @@ static int dev_gso_segment(struct sk_buf
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(dev_skb_segment);
+
+/**
+ *	dev_gso_segment - Perform emulated hardware segmentation on skb.
+ *	@skb: buffer to segment
+ *
+ *	This function segments the given skb and stores the list of segments
+ *	in skb->next.
+ */
+static int dev_gso_segment(struct sk_buff *skb)
+{
+	return dev_skb_segment(skb, skb_gso_segment);
+}
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
--- everything.orig/include/linux/netdevice.h	2008-04-30 01:52:23.000000000 +0200
+++ everything/include/linux/netdevice.h	2008-04-30 01:52:26.000000000 +0200
@@ -1454,6 +1454,7 @@ extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features);
+extern int dev_skb_segment(struct sk_buff *skb, struct sk_buff *(segmfn)(struct sk_buff *skb, int feat));
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else

-- 

