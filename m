From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/3] add netdev_alloc_skb
Date: Wed, 26 Jul 2006 13:31:36 +0200
Message-ID: <20060726113136.GA403@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:34723 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751407AbWGZLbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 07:31:50 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a dev_alloc_skb variant that takes a struct net_device * paramater.
For now that paramater is unused, but I'll use it to allocate the skb
from node-local memory in a follow-up patch.  Also there have been some
other plans mentioned on the list that can use it.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-07-26 10:58:43.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-07-26 11:10:23.000000000 +0200
@@ -1104,6 +1104,28 @@
 	return __dev_alloc_skb(length, GFP_ATOMIC);
 }
 
+extern struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
+		unsigned int length, gfp_t gfp_mask);
+
+/**
+ *	netdev_alloc_skb - allocate an skbuff for rx on a specific device
+ *	@dev: network device to receive on
+ *	@length: length to allocate
+ *
+ *	Allocate a new &sk_buff and assign it a usage count of one. The
+ *	buffer has unspecified headroom built in. Users should allocate
+ *	the headroom they think they need without accounting for the
+ *	built in space. The built in space is used for optimisations.
+ *
+ *	%NULL is returned in there is no free memory. Although this function
+ *	allocates memory it can be called from an interrupt.
+ */
+static inline struct sk_buff *netdev_alloc_skb(struct net_device *dev,
+		unsigned int length)
+{
+	return __netdev_alloc_skb(dev, length, GFP_ATOMIC);
+}
+
 /**
  *	skb_cow - copy header of skb when it is required
  *	@skb: buffer to cow
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2006-07-26 10:58:43.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2006-07-26 11:10:40.000000000 +0200
@@ -256,6 +256,29 @@
 	goto out;
 }
 
+/**
+ *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
+ *	@dev: network device to receive on
+ *	@length: length to allocate
+ *	@gfp_mask: get_free_pages mask, passed to alloc_skb
+ *
+ *	Allocate a new &sk_buff and assign it a usage count of one. The
+ *	buffer has unspecified headroom built in. Users should allocate
+ *	the headroom they think they need without accounting for the
+ *	built in space. The built in space is used for optimisations.
+ *
+ *	%NULL is returned in there is no free memory.
+ */
+struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
+		unsigned int length, gfp_t gfp_mask)
+{
+	struct sk_buff *skb;
+
+	skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	if (likely(skb))
+		skb_reserve(skb, NET_SKB_PAD);
+	return skb;
+}
 
 static void skb_drop_list(struct sk_buff **listp)
 {
@@ -2042,6 +2065,7 @@
 EXPORT_SYMBOL(kfree_skb);
 EXPORT_SYMBOL(__pskb_pull_tail);
 EXPORT_SYMBOL(__alloc_skb);
+EXPORT_SYMBOL(__netdev_alloc_skb);
 EXPORT_SYMBOL(pskb_copy);
 EXPORT_SYMBOL(pskb_expand_head);
 EXPORT_SYMBOL(skb_checksum);
