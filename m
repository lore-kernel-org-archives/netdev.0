From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 5/9] net: pad skb data and shinfo as a whole rather than individually
Date: Thu, 3 May 2012 15:56:07 +0100
Message-ID: <1336056971-7839-5-git-send-email-ian.campbell@citrix.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43178 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756053Ab2ECO4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 10:56:14 -0400
In-Reply-To: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reduces the minimum overhead required for this allocation such that the
shinfo can be grown in the following patch without overflowing 2048 bytes for a
1500 byte frame.

Reducing this overhead while also growing the shinfo means that sometimes the
tail end of the data can end up in the same cache line as the beginning of the
shinfo. Specifically in the case of the 64 byte cache lines on a 64 bit system
the first 8 bytes of shinfo can overlap the tail cacheline of the data. In many
cases the allocation slop means that there is no overlap.

In order to ensure that the hot struct members remain on the same 64 byte cache
line move the "destructor_arg" member to the front, this member is not used on
any hot path so it is a good choice to potentially be on a separate cache line
(and which addtionally may be shared with skb->data).

Also rather than relying on knowledge about the size and layout of the rest of
the shinfo to ensure that the right parts of the shinfo are aligned decree that
nr_frags will be cache aligned and therefore that the 64 bytes starting at
nr_frags should contain the hot struct members.

All this avoids hitting an extra cache line on hot operations such as
kfree_skb.

On 4k pages this motion and alignment strategy (along with the following frag
size increase) results in the shinfo abutting the very end of the allocation.
On larger pages (where SKB_MAX_FRAGS can be smaller) it means that we still
correctly align the hot data without needing to make assumptions about the data
layout outside of the hot 64-bytes of the shinfo.

Explicitly aligning nr_frags, rather than relying on analysis of the shinfo
layout was suggested by Alexander Duyck <alexander.h.duyck@intel.com>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |   50 +++++++++++++++++++++++++++++------------------
 net/core/skbuff.c      |    9 +++++++-
 2 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19e348f..3698625 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -41,19 +41,24 @@
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
-/* maximum data size which can fit into an allocation of X bytes */
-#define SKB_WITH_OVERHEAD(X)	\
-	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+
 /*
- * minimum allocation size required for an skb containing X bytes of data
- *
- * We do our best to align skb_shared_info on a separate cache
- * line. It usually works because kmalloc(X > SMP_CACHE_BYTES) gives
- * aligned memory blocks, unless SLUB/SLAB debug is enabled.  Both
- * skb->head and skb_shared_info are cache line aligned.
+ * We do our best to align the hot members of skb_shared_info on a
+ * separate cache line.  We explicitly align the nr_frags field and
+ * arrange that the order of the fields in skb_shared_info is such
+ * that the interesting fields are nr_frags onwards and are therefore
+ * cache line aligned.
  */
-#define SKB_ALLOCSIZE(X)	\
-	(SKB_DATA_ALIGN((X)) + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+#define SKB_SHINFO_SIZE							\
+	(SKB_DATA_ALIGN(sizeof(struct skb_shared_info)			\
+			- offsetof(struct skb_shared_info, nr_frags))	\
+	 + offsetof(struct skb_shared_info, nr_frags))
+
+/* maximum data size which can fit into an allocation of X bytes */
+#define SKB_WITH_OVERHEAD(X)	((X) - SKB_SHINFO_SIZE)
+
+/* minimum allocation size required for an skb containing X bytes of data */
+#define SKB_ALLOCSIZE(X)	(SKB_DATA_ALIGN((X) + SKB_SHINFO_SIZE))
 
 #define SKB_MAX_ORDER(X, ORDER) \
 	SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
@@ -63,7 +68,7 @@
 /* return minimum truesize of one skb containing X bytes of data */
 #define SKB_TRUESIZE(X) ((X) +						\
 			 SKB_DATA_ALIGN(sizeof(struct sk_buff)) +	\
-			 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+			 SKB_SHINFO_SIZE)
 
 /* A. Checksumming of received packets by device.
  *
@@ -263,6 +268,19 @@ struct ubuf_info {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
+	/* Intermediate layers must ensure that destructor_arg
+	 * remains valid until skb destructor */
+	void		*destructor_arg;
+
+	/* Warning: all fields from here until dataref are cleared in
+	 * skb_shinfo_init() (called from __alloc_skb, build_skb,
+	 * skb_recycle, etc).
+	 *
+	 * nr_frags will always be aligned to the start of a cache
+	 * line. It is intended that everything from nr_frags until at
+	 * least frags[0] (inclusive) should fit into the same 64-byte
+	 * cache line.
+	 */
 	unsigned char	nr_frags;
 	__u8		tx_flags;
 	unsigned short	gso_size;
@@ -273,15 +291,9 @@ struct skb_shared_info {
 	struct skb_shared_hwtstamps hwtstamps;
 	__be32          ip6_frag_id;
 
-	/*
-	 * Warning : all fields before dataref are cleared in __alloc_skb()
-	 */
+	/* fields from nr_frags until dataref are cleared in skb_shinfo_init */
 	atomic_t	dataref;
 
-	/* Intermediate layers must ensure that destructor_arg
-	 * remains valid until skb destructor */
-	void *		destructor_arg;
-
 	/* must be last field, see pskb_expand_head() */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e96f68b..fab6de0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -149,8 +149,15 @@ static void skb_shinfo_init(struct sk_buff *skb)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 
+	/* Ensure that nr_frags->frags[0] (at least) fits into a
+	 * single cache line. */
+	BUILD_BUG_ON((offsetof(struct skb_shared_info, frags[1])
+		      - offsetof(struct skb_shared_info, nr_frags)) > 64);
+
 	/* make sure we initialize shinfo sequentially */
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	memset(&shinfo->nr_frags, 0,
+	       offsetof(struct skb_shared_info, dataref)
+	       - offsetof(struct skb_shared_info, nr_frags));
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 }
-- 
1.7.2.5
