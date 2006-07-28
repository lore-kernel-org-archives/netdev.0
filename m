From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] add netdev_alloc_skb
Date: Fri, 28 Jul 2006 10:46:28 +0200
Message-ID: <20060728084628.GA27892@lst.de>
References: <20060728070851.GB25174@lst.de> <20060728.012424.70217564.davem@davemloft.net> <20060728082712.GA27366@lst.de> <20060728.012832.99202035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:30892 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751796AbWG1Iq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 04:46:58 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060728.012832.99202035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 01:28:32AM -0700, David Miller wrote:
> From: Christoph Hellwig <hch@lst.de>
> Date: Fri, 28 Jul 2006 10:27:12 +0200
> 
> > We need a fixup patch for the existing wrong comments on dev_alloc_skb
> > anyway - but if you prefer to respin the netdev_alloc_skb and have
> > another patch to fixup the original comments I can do that aswell.
> 
> I intend to, for everyone's convenience, put the addition of
> netdev_alloc_skb() into 2.6.18.

Here is the requested fixed up version:


Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-07-26 13:27:07.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-07-28 10:41:00.000000000 +0200
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
+ *	%NULL is returned if there is no free memory. Although this function
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
--- linux-2.6.orig/net/core/skbuff.c	2006-07-26 13:27:07.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2006-07-28 10:41:09.000000000 +0200
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
+ *	%NULL is returned if there is no free memory.
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
