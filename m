From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] expose simplified skb_checksum_recalc
Date: Thu, 11 May 2006 11:28:43 -0700
Message-ID: <20060511112843.6532bddd@localhost.localdomain>
References: <446259A0.8050504@myri.com>
	<Pine.GSO.4.44.0605101441510.498-100000@adel.myri.com>
	<20060510152244.44fb3db7@localhost.localdomain>
	<200605111924.33125.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <ioe-lkml@rameria.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49838 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750842AbWEKS2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 14:28:54 -0400
To: Ingo Oeser <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <200605111924.33125.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many users of skb_checksum_help() are just using it to recalculate
outbound checksum, so why not expose the interface in a more useful
way. Suggested by Ingo Oeser.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/include/linux/skbuff.h	2006-04-27 11:12:53.000000000 -0700
+++ linux-2.6/include/linux/skbuff.h	2006-05-11 11:17:39.000000000 -0700
@@ -1343,6 +1343,24 @@
 		__skb_checksum_complete(skb);
 }
 
+extern int skb_checksum_recalc(struct sk_buff *skb);
+/**
+ *	skb_checksum_help - recalculate checksum of packet
+ *	@skb: packet to process
+ *	@inward: direction of flow, zero is receiving
+ *
+ * Invalidate hardware checksum when packet is to be mangled on
+ * receive and complete checksum manually on outgoing path.
+ */
+static inline int skb_checksum_help(struct sk_buff *skb, int inward)
+{
+	if (inward) {
+		skb->ip_summed = CHECKSUM_NONE;
+		return 0;
+	}
+	return skb_checksum_recalc(skb);
+}
+
 #ifdef CONFIG_NETFILTER
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
 {
--- sky2.orig/net/core/dev.c	2006-05-10 10:17:51.000000000 -0700
+++ sky2/net/core/dev.c	2006-05-11 11:22:27.000000000 -0700
@@ -1144,39 +1144,6 @@
 EXPORT_SYMBOL(netif_device_attach);
 
 
-/*
- * Invalidate hardware checksum when packet is to be mangled, and
- * complete checksum manually on outgoing path.
- */
-int skb_checksum_help(struct sk_buff *skb, int inward)
-{
-	unsigned int csum;
-	int ret = 0, offset = skb->h.raw - skb->data;
-
-	if (inward) {
-		skb->ip_summed = CHECKSUM_NONE;
-		goto out;
-	}
-
-	if (skb_cloned(skb)) {
-		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (ret)
-			goto out;
-	}
-
-	BUG_ON(offset > (int)skb->len);
-	csum = skb_checksum(skb, offset, skb->len-offset, 0);
-
-	offset = skb->tail - skb->h.raw;
-	BUG_ON(offset <= 0);
-	BUG_ON(skb->csum + 2 > offset);
-
-	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
-	skb->ip_summed = CHECKSUM_NONE;
-out:	
-	return ret;
-}
-
 /* Take action when hardware reception checksum errors are detected. */
 #ifdef CONFIG_BUG
 void netdev_rx_csum_fault(struct net_device *dev)
@@ -3403,7 +3370,6 @@
 EXPORT_SYMBOL(register_gifconf);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(register_netdevice_notifier);
-EXPORT_SYMBOL(skb_checksum_help);
 EXPORT_SYMBOL(synchronize_net);
 EXPORT_SYMBOL(unregister_netdevice);
 EXPORT_SYMBOL(unregister_netdevice_notifier);
--- sky2.orig/net/core/skbuff.c	2006-04-27 11:12:54.000000000 -0700
+++ sky2/net/core/skbuff.c	2006-05-11 11:23:13.000000000 -0700
@@ -1334,6 +1334,36 @@
 }
 
 /**
+ *	skb_checksum_recalc - force software checksum
+ *	@skb: skb to process
+ *	Force complete checksum, this is used to force a software checksum
+ *	on the outgoing path.
+ */
+int skb_checksum_recalc(struct sk_buff *skb)
+{
+	unsigned int csum;
+	int ret = 0, offset = skb->h.raw - skb->data;
+
+	if (skb_cloned(skb)) {
+		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (ret)
+			goto out;
+	}
+
+	BUG_ON(offset > (int)skb->len);
+	csum = skb_checksum(skb, offset, skb->len-offset, 0);
+
+	offset = skb->tail - skb->h.raw;
+	BUG_ON(offset <= 0);
+	BUG_ON(skb->csum + 2 > offset);
+
+	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
+	skb->ip_summed = CHECKSUM_NONE;
+out:
+	return ret;
+}
+
+/**
  *	skb_dequeue - remove from the head of the queue
  *	@list: list to dequeue from
  *
@@ -1854,6 +1884,7 @@
 EXPORT_SYMBOL(pskb_copy);
 EXPORT_SYMBOL(pskb_expand_head);
 EXPORT_SYMBOL(skb_checksum);
+EXPORT_SYMBOL(skb_checksum_recalc);
 EXPORT_SYMBOL(skb_clone);
 EXPORT_SYMBOL(skb_clone_fraglist);
 EXPORT_SYMBOL(skb_copy);
