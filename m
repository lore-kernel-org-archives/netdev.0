From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] net: consolidate netif_needs_gso() checks
Date: Wed, 16 Jun 2010 17:18:12 -0700
Message-ID: <20100617001804.5155.30862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.westchester.pa.mail.comcast.net ([76.96.59.228]:45807
	"EHLO qmta15.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759128Ab0FQASe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 20:18:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

netif_needs_gso() is checked twice in the TX path once,
before submitting the skb to the qdisc and once after
it is dequeued from the qdisc just before calling
ndo_hard_start().  This opens a window for a user to
change the gso/tso or tx checksum settings that can
cause netif_needs_gso to be true in one check and false
in the other.

Specifically, changing TX checksum setting may cause
the warning in skb_gso_segment() to be triggered if
the checksum is calculated earlier.

This consolidates the netif_needs_gso() calls so that
the stack only checks if gso is needed in
dev_hard_start_xmit().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/dev.c |   68 ++++++++++++++++++++++++++------------------------------
 1 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5902426..7f390b5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1895,6 +1895,22 @@ static inline void skb_orphan_try(struct sk_buff *skb)
 		skb_orphan(skb);
 }
 
+/*
+ * Returns true if either:
+ *	1. skb has frag_list and the device doesn't support FRAGLIST, or
+ *	2. skb is fragmented and the device does not support SG, or if
+ *	   at least one of fragments is in highmem and device does not
+ *	   support DMA from it.
+ */
+static inline int skb_needs_linearize(struct sk_buff *skb,
+				      struct net_device *dev)
+{
+	return skb_is_nonlinear(skb) &&
+	       ((skb_has_frags(skb) && !(dev->features & NETIF_F_FRAGLIST)) ||
+	        (skb_shinfo(skb)->nr_frags && (!(dev->features & NETIF_F_SG) ||
+					      illegal_highdma(dev, skb))));
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1919,6 +1935,22 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				goto out_kfree_skb;
 			if (skb->next)
 				goto gso;
+		} else {
+			if (skb_needs_linearize(skb, dev) &&
+			    __skb_linearize(skb))
+				goto out_kfree_skb;
+
+			/* If packet is not checksummed and device does not
+			 * support checksumming for this protocol, complete
+			 * checksumming here.
+			 */
+			if (skb->ip_summed == CHECKSUM_PARTIAL) {
+				skb_set_transport_header(skb, skb->csum_start -
+					      skb_headroom(skb));
+				if (!dev_can_checksum(dev, skb) &&
+				     skb_checksum_help(skb))
+					goto out_kfree_skb;
+			}
 		}
 
 		rc = ops->ndo_start_xmit(skb, dev);
@@ -2089,22 +2121,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	return rc;
 }
 
-/*
- * Returns true if either:
- *	1. skb has frag_list and the device doesn't support FRAGLIST, or
- *	2. skb is fragmented and the device does not support SG, or if
- *	   at least one of fragments is in highmem and device does not
- *	   support DMA from it.
- */
-static inline int skb_needs_linearize(struct sk_buff *skb,
-				      struct net_device *dev)
-{
-	return skb_is_nonlinear(skb) &&
-	       ((skb_has_frags(skb) && !(dev->features & NETIF_F_FRAGLIST)) ||
-	        (skb_shinfo(skb)->nr_frags && (!(dev->features & NETIF_F_SG) ||
-					      illegal_highdma(dev, skb))));
-}
-
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -2137,25 +2153,6 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
-	/* GSO will handle the following emulations directly. */
-	if (netif_needs_gso(dev, skb))
-		goto gso;
-
-	/* Convert a paged skb to linear, if required */
-	if (skb_needs_linearize(skb, dev) && __skb_linearize(skb))
-		goto out_kfree_skb;
-
-	/* If packet is not checksummed and device does not support
-	 * checksumming for this protocol, complete checksumming here.
-	 */
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		skb_set_transport_header(skb, skb->csum_start -
-					      skb_headroom(skb));
-		if (!dev_can_checksum(dev, skb) && skb_checksum_help(skb))
-			goto out_kfree_skb;
-	}
-
-gso:
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
@@ -2214,7 +2211,6 @@ gso:
 	rc = -ENETDOWN;
 	rcu_read_unlock_bh();
 
-out_kfree_skb:
 	kfree_skb(skb);
 	return rc;
 out:

