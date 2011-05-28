From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V7 2/4 net-next] skbuff: Add userspace zero-copy buffers in
 skb
Date: Sat, 28 May 2011 12:23:08 -0700
Message-ID: <1306610588.5180.87.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds userspace buffers support in skb shared info. A new 
struct skb_ubuf_info is needed to maintain the userspace buffers
argument and index, a callback is used to notify userspace to release
the buffers once lower device has done DMA (Last reference to that skb
has gone).

If there is any userspace apps to reference these userspace buffers,
then these userspaces buffers will be copied into kernel. This way we
can prevent userspace apps to hold these userspace buffers too long.

One userspace buffer info pointer is added in skb_shared_info. Is that
safe to use destructor_arg? From the comments, this destructor_arg is
used for destructor, destructor calls doesn't wait for last reference to
that skb is gone.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 include/linux/skbuff.h |   24 ++++++++++++++++
 net/core/skbuff.c      |   73 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e8b78ce..37a2cb4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -189,6 +189,17 @@ enum {
 	SKBTX_DRV_NEEDS_SK_REF = 1 << 3,
 };
 
+/*
+ * The callback notifies userspace to release buffers when skb DMA is done in
+ * lower device, the skb last reference should be 0 when calling this.
+ * The desc is used to track userspace buffer index.
+ */
+struct ubuf_info {
+	void (*callback)(void *);
+	void *arg;
+	unsigned long desc;
+};
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -203,6 +214,9 @@ struct skb_shared_info {
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
 
+	/* DMA mapping from/to userspace buffers info */
+	void		*ubuf_arg;
+
 	/*
 	 * Warning : all fields before dataref are cleared in __alloc_skb()
 	 */
@@ -2261,5 +2275,15 @@ static inline void skb_checksum_none_assert(struct sk_buff *skb)
 }
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
+
+/*
+ *	skb *uarg - is the buffer from userspace
+ *	@skb: buffer to check
+ */
+static inline int skb_ubuf(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->ubuf_arg != NULL;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46cbd28..115c5ca 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -329,6 +329,19 @@ static void skb_release_data(struct sk_buff *skb)
 				put_page(skb_shinfo(skb)->frags[i].page);
 		}
 
+		/*
+		 * If skb buf is from userspace, we need to notify the caller
+		 * the lower device DMA has done;
+		 */
+		if (skb_ubuf(skb)) {
+			struct ubuf_info *uarg;
+
+			uarg = (struct ubuf_info *)skb_shinfo(skb)->ubuf_arg;
+
+			if (uarg->callback)
+				uarg->callback(uarg);
+		}
+
 		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
 
@@ -481,6 +494,9 @@ bool skb_recycle_check(struct sk_buff *skb, int skb_size)
 	if (irqs_disabled())
 		return false;
 
+	if (skb_ubuf(skb))
+		return false;
+
 	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
 		return false;
 
@@ -573,6 +589,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	atomic_set(&n->users, 1);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
+	skb_shinfo(skb)->ubuf_arg = NULL;
 	skb->cloned = 1;
 
 	return n;
@@ -596,6 +613,51 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
+/* skb frags copy userspace buffers to kernel */
+static int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	int i;
+	int num_frags = skb_shinfo(skb)->nr_frags;
+	struct page *page, *head = NULL;
+	struct ubuf_info *uarg = skb_shinfo(skb)->ubuf_arg;
+
+	for (i = 0; i < num_frags; i++) {
+		u8 *vaddr;
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+
+		page = alloc_page(GFP_ATOMIC);
+		if (!page) {
+			while (head) {
+				put_page(head);
+				head = (struct page *)head->private;
+			}
+			return -ENOMEM;
+		}
+		vaddr = kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
+		memcpy(page_address(page),
+		       vaddr + f->page_offset, f->size);
+		kunmap_skb_frag(vaddr);
+		page->private = (unsigned long)head;
+		head = page;
+	}
+
+	/* skb frags release userspace buffers */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+		put_page(skb_shinfo(skb)->frags[i].page);
+
+	uarg->callback(uarg);
+	skb_shinfo(skb)->ubuf_arg = NULL;
+
+	/* skb frags point to kernel buffers */
+	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
+		skb_shinfo(skb)->frags[i - 1].page_offset = 0;
+		skb_shinfo(skb)->frags[i - 1].page = head;
+		head = (struct page *)head->private;
+	}
+	return 0;
+}
+
+
 /**
  *	skb_clone	-	duplicate an sk_buff
  *	@skb: buffer to clone
@@ -614,6 +676,11 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	struct sk_buff *n;
 
+	if (skb_ubuf(skb)) {
+		if (skb_copy_ubufs(skb, gfp_mask))
+			return NULL;
+	}
+
 	n = skb + 1;
 	if (skb->fclone == SKB_FCLONE_ORIG &&
 	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
@@ -731,6 +798,12 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 	if (skb_shinfo(skb)->nr_frags) {
 		int i;
 
+		if (skb_ubuf(skb)) {
+			if (skb_copy_ubufs(skb, gfp_mask)) {
+				kfree(n);
+				goto out;
+			}
+		}
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
 			get_page(skb_shinfo(n)->frags[i].page);
