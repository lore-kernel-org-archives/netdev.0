From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 2/3] net: Pull out core bits of __netdev_alloc_skb and
 add __napi_alloc_skb
Date: Wed, 26 Nov 2014 16:06:04 -0800
Message-ID: <20141127000604.1617.15165.stgit@ahduyck-vm-fedora20>
References: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brouer@redhat.com,
	jeffrey.t.kirsher@intel.com, eric.dumazet@gmail.com,
	ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbaK0AGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2014 19:06:12 -0500
In-Reply-To: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change pulls the core functionality out of __netdev_alloc_skb and
places them in a new function named __alloc_rx_skb.  The reason for doing
this is to make these bits accessible to a new function __napi_alloc_skb.
In addition __alloc_rx_skb now has a new flags value that is used to
determine which page frag pool to allocate from.  If the SKB_ALLOC_NAPI
flag is set then the NAPI pool is used.  The advantage of this is that we
do not have to use local_irq_save/restore when accessing the NAPI pool from
NAPI context.

In my test setup I saw at least 11ns of savings using the napi_alloc_skb
function versus the netdev_alloc_skb function, most of this being due to
the fact that we didn't have to call local_irq_save/restore.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/skbuff.h |    9 ++++++
 net/core/dev.c         |    2 +
 net/core/skbuff.c      |   74 +++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 77 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e596efa..67de1d0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -151,6 +151,7 @@ struct net_device;
 struct scatterlist;
 struct pipe_inode_info;
 struct iov_iter;
+struct napi_struct;
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 struct nf_conntrack {
@@ -674,6 +675,7 @@ struct sk_buff {
 
 #define SKB_ALLOC_FCLONE	0x01
 #define SKB_ALLOC_RX		0x02
+#define SKB_ALLOC_NAPI		0x04
 
 /* Returns true if the skb was allocated from PFMEMALLOC reserves */
 static inline bool skb_pfmemalloc(const struct sk_buff *skb)
@@ -2185,6 +2187,13 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 }
 
 void *napi_alloc_frag(unsigned int fragsz);
+struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
+				 unsigned int length, gfp_t gfp_mask);
+static inline struct sk_buff *napi_alloc_skb(struct napi_struct *napi,
+					     unsigned int length)
+{
+	return __napi_alloc_skb(napi, length, GFP_ATOMIC);
+}
 
 /**
  * __dev_alloc_pages - allocate page for network Rx
diff --git a/net/core/dev.c b/net/core/dev.c
index ac48362..ff636ad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4172,7 +4172,7 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 	struct sk_buff *skb = napi->skb;
 
 	if (!skb) {
-		skb = netdev_alloc_skb_ip_align(napi->dev, GRO_MAX_HEAD);
+		skb = napi_alloc_skb(napi, GRO_MAX_HEAD);
 		napi->skb = skb;
 	}
 	return skb;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6dd2b44..397efd8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -419,10 +419,13 @@ void *napi_alloc_frag(unsigned int fragsz)
 EXPORT_SYMBOL(napi_alloc_frag);
 
 /**
- *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
- *	@dev: network device to receive on
+ *	__alloc_rx_skb - allocate an skbuff for rx
  *	@length: length to allocate
  *	@gfp_mask: get_free_pages mask, passed to alloc_skb
+ *	@flags:	If SKB_ALLOC_RX is set, __GFP_MEMALLOC will be used for
+ *		allocations in case we have to fallback to __alloc_skb()
+ *		If SKB_ALLOC_NAPI is set, page fragment will be allocated
+ *		from napi_cache instead of netdev_cache.
  *
  *	Allocate a new &sk_buff and assign it a usage count of one. The
  *	buffer has unspecified headroom built in. Users should allocate
@@ -431,11 +434,11 @@ EXPORT_SYMBOL(napi_alloc_frag);
  *
  *	%NULL is returned if there is no free memory.
  */
-struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
-				   unsigned int length, gfp_t gfp_mask)
+static struct sk_buff *__alloc_rx_skb(unsigned int length, gfp_t gfp_mask,
+				      int flags)
 {
 	struct sk_buff *skb = NULL;
-	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
+	unsigned int fragsz = SKB_DATA_ALIGN(length) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	if (fragsz <= PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
@@ -444,7 +447,9 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		if (sk_memalloc_socks())
 			gfp_mask |= __GFP_MEMALLOC;
 
-		data = __netdev_alloc_frag(fragsz, gfp_mask);
+		data = (flags & SKB_ALLOC_NAPI) ?
+			__napi_alloc_frag(fragsz, gfp_mask) :
+			__netdev_alloc_frag(fragsz, gfp_mask);
 
 		if (likely(data)) {
 			skb = build_skb(data, fragsz);
@@ -452,17 +457,72 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 				put_page(virt_to_head_page(data));
 		}
 	} else {
-		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
+		skb = __alloc_skb(length, gfp_mask,
 				  SKB_ALLOC_RX, NUMA_NO_NODE);
 	}
+	return skb;
+}
+
+/**
+ *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
+ *	@dev: network device to receive on
+ *	@length: length to allocate
+ *	@gfp_mask: get_free_pages mask, passed to alloc_skb
+ *
+ *	Allocate a new &sk_buff and assign it a usage count of one. The
+ *	buffer has NET_SKB_PAD headroom built in. Users should allocate
+ *	the headroom they think they need without accounting for the
+ *	built in space. The built in space is used for optimisations.
+ *
+ *	%NULL is returned if there is no free memory.
+ */
+struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
+				   unsigned int length, gfp_t gfp_mask)
+{
+	struct sk_buff *skb;
+
+	length += NET_SKB_PAD;
+	skb = __alloc_rx_skb(length, gfp_mask, 0);
+
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
 	}
+
 	return skb;
 }
 EXPORT_SYMBOL(__netdev_alloc_skb);
 
+/**
+ *	__napi_alloc_skb - allocate skbuff for rx in a specific NAPI instance
+ *	@napi: napi instance this buffer was allocated for
+ *	@length: length to allocate
+ *	@gfp_mask: get_free_pages mask, passed to alloc_skb and alloc_pages
+ *
+ *	Allocate a new sk_buff for use in NAPI receive.  This buffer will
+ *	attempt to allocate the head from a special reserved region used
+ *	only for NAPI Rx allocation.  By doing this we can save several
+ *	CPU cycles by avoiding having to disable and re-enable IRQs.
+ *
+ *	%NULL is returned if there is no free memory.
+ */
+struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
+				 unsigned int length, gfp_t gfp_mask)
+{
+	struct sk_buff *skb;
+
+	length += NET_SKB_PAD + NET_IP_ALIGN;
+	skb = __alloc_rx_skb(length, gfp_mask, SKB_ALLOC_NAPI);
+
+	if (likely(skb)) {
+		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+		skb->dev = napi->dev;
+	}
+
+	return skb;
+}
+EXPORT_SYMBOL(__napi_alloc_skb);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		     int size, unsigned int truesize)
 {
