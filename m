From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/2] skbuff: Add pskb_extract() helper function
Date: Wed, 20 Apr 2016 03:17:41 -0700
Message-ID: <8d683318ede700f5f1b4d4333dfad8a1935f9ce6.1461086306.git.sowmini.varadhan@oracle.com>
References: <cover.1461086306.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com, eric.dumazet@gmail.com,
	marcelo.leitner@gmail.com
To: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36910 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932979AbcDTKS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 06:18:29 -0400
In-Reply-To: <cover.1461086306.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1461086306.git.sowmini.varadhan@oracle.com>
References: <cover.1461086306.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pattern of skb usage seen in modules such as RDS-TCP is to
extract `to_copy' bytes from the received TCP segment, starting
at some offset `off' into a new skb `clone'. This is done in
the ->data_ready callback, where the clone skb is queued up for rx on
the PF_RDS socket, while the parent TCP segment is returned unchanged
back to the TCP engine.

The existing code uses the sequence
	clone = skb_clone(..);
	pskb_pull(clone, off, ..);
	pskb_trim(clone, to_copy, ..);
with the intention of discarding the first `off' bytes. However,
skb_clone() + pskb_pull() implies pksb_expand_head(), which ends
up doing a redundant memcpy of bytes that will then get discarded
in __pskb_pull_tail().

To avoid this inefficiency, this commit adds pskb_extract() that
creates the clone, and memcpy's only the relevant header/frag/frag_list
to the start of `clone'. pskb_trim() is then invoked to trim clone
down to the requested to_copy bytes.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/linux/skbuff.h |    2 +
 net/core/skbuff.c      |  248 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 250 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index da0ace3..a1ce639 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2986,6 +2986,8 @@ struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
 int skb_ensure_writable(struct sk_buff *skb, int write_len);
 int skb_vlan_pop(struct sk_buff *skb);
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
+struct sk_buff *pskb_extract(struct sk_buff *skb, int off, int to_copy,
+			     gfp_t gfp);
 
 static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4cc594c..e8b6d20 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4619,3 +4619,251 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
 	return NULL;
 }
 EXPORT_SYMBOL(alloc_skb_with_frags);
+
+/* carve out the first off bytes from skb when off < headlen */
+static int pskb_carve_inside_header(struct sk_buff *skb, const u32 off,
+				    const int headlen, gfp_t gfp_mask)
+{
+	int i;
+	int size = skb_end_offset(skb);
+	int new_hlen = headlen - off;
+	u8 *data;
+	int doff = 0;
+
+	size = SKB_DATA_ALIGN(size);
+
+	if (skb_pfmemalloc(skb))
+		gfp_mask |= __GFP_MEMALLOC;
+	data = kmalloc_reserve(size +
+			       SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
+			       gfp_mask, NUMA_NO_NODE, NULL);
+	if (!data)
+		return -ENOMEM;
+
+	size = SKB_WITH_OVERHEAD(ksize(data));
+
+	/* Copy real data, and all frags */
+	skb_copy_from_linear_data_offset(skb, off, data, new_hlen);
+	skb->len -= off;
+
+	memcpy((struct skb_shared_info *)(data + size),
+	       skb_shinfo(skb),
+	       offsetof(struct skb_shared_info,
+			frags[skb_shinfo(skb)->nr_frags]));
+	if (skb_cloned(skb)) {
+		/* drop the old head gracefully */
+		if (skb_orphan_frags(skb, gfp_mask)) {
+			kfree(data);
+			return -ENOMEM;
+		}
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+			skb_frag_ref(skb, i);
+		if (skb_has_frag_list(skb))
+			skb_clone_fraglist(skb);
+		skb_release_data(skb);
+	} else {
+		/* we can reuse existing recount- all we did was
+		 * relocate values
+		 */
+		skb_free_head(skb);
+	}
+
+	doff = (data - skb->head);
+	skb->head = data;
+	skb->data = data;
+	skb->head_frag = 0;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->end = size;
+	doff = 0;
+#else
+	skb->end = skb->head + size;
+#endif
+	skb_set_tail_pointer(skb, skb_headlen(skb));
+	skb_headers_offset_update(skb, 0);
+	skb->cloned = 0;
+	skb->hdr_len = 0;
+	skb->nohdr = 0;
+	atomic_set(&skb_shinfo(skb)->dataref, 1);
+
+	return 0;
+}
+
+static int pskb_carve(struct sk_buff *skb, const u32 off, gfp_t gfp);
+
+/* carve out the first eat bytes from skb's frag_list. May recurse into
+ * pskb_carve()
+ */
+static int pskb_carve_frag_list(struct sk_buff *skb,
+				struct skb_shared_info *shinfo, int eat,
+				gfp_t gfp_mask)
+{
+	struct sk_buff *list = shinfo->frag_list;
+	struct sk_buff *clone = NULL;
+	struct sk_buff *insp = NULL;
+
+	do {
+		if (!list) {
+			pr_err("Not enough bytes to eat. Want %d\n", eat);
+			return -EFAULT;
+		}
+		if (list->len <= eat) {
+			/* Eaten as whole. */
+			eat -= list->len;
+			list = list->next;
+			insp = list;
+		} else {
+			/* Eaten partially. */
+			if (skb_shared(list)) {
+				clone = skb_clone(list, gfp_mask);
+				if (!clone)
+					return -ENOMEM;
+				insp = list->next;
+				list = clone;
+			} else {
+				/* This may be pulled without problems. */
+				insp = list;
+			}
+			if (pskb_carve(list, eat, gfp_mask) < 0) {
+				kfree_skb(clone);
+				return -ENOMEM;
+			}
+			break;
+		}
+	} while (eat);
+
+	/* Free pulled out fragments. */
+	while ((list = shinfo->frag_list) != insp) {
+		shinfo->frag_list = list->next;
+		kfree_skb(list);
+	}
+	/* And insert new clone at head. */
+	if (clone) {
+		clone->next = list;
+		shinfo->frag_list = clone;
+	}
+	return 0;
+}
+
+/* carve off first len bytes from skb. Split line (off) is in the
+ * non-linear part of skb
+ */
+static int pskb_carve_inside_nonlinear(struct sk_buff *skb, const u32 off,
+				       int pos, gfp_t gfp_mask)
+{
+	int i, k = 0;
+	int size = skb_end_offset(skb);
+	u8 *data;
+	const int nfrags = skb_shinfo(skb)->nr_frags;
+	struct skb_shared_info *shinfo;
+	int doff = 0;
+
+	size = SKB_DATA_ALIGN(size);
+
+	if (skb_pfmemalloc(skb))
+		gfp_mask |= __GFP_MEMALLOC;
+	data = kmalloc_reserve(size +
+			       SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
+			       gfp_mask, NUMA_NO_NODE, NULL);
+	if (!data)
+		return -ENOMEM;
+
+	size = SKB_WITH_OVERHEAD(ksize(data));
+
+	memcpy((struct skb_shared_info *)(data + size),
+	       skb_shinfo(skb), offsetof(struct skb_shared_info,
+					 frags[skb_shinfo(skb)->nr_frags]));
+	if (skb_orphan_frags(skb, gfp_mask)) {
+		kfree(data);
+		return -ENOMEM;
+	}
+	shinfo = (struct skb_shared_info *)(data + size);
+	for (i = 0; i < nfrags; i++) {
+		int fsize = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+
+		if (pos + fsize > off) {
+			shinfo->frags[k] = skb_shinfo(skb)->frags[i];
+
+			if (pos < off) {
+				/* Split frag.
+				 * We have two variants in this case:
+				 * 1. Move all the frag to the second
+				 *    part, if it is possible. F.e.
+				 *    this approach is mandatory for TUX,
+				 *    where splitting is expensive.
+				 * 2. Split is accurately. We make this.
+				 */
+				shinfo->frags[0].page_offset += off - pos;
+				skb_frag_size_sub(&shinfo->frags[0], off - pos);
+			}
+			skb_frag_ref(skb, i);
+			k++;
+		}
+		pos += fsize;
+	}
+	shinfo->nr_frags = k;
+	if (skb_has_frag_list(skb))
+		skb_clone_fraglist(skb);
+
+	if (k == 0) {
+		/* split line is in frag list */
+		pskb_carve_frag_list(skb, shinfo, off - pos, gfp_mask);
+	}
+	skb_release_data(skb);
+
+	doff = (data - skb->head);
+	skb->head = data;
+	skb->head_frag = 0;
+	skb->data = data;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->end = size;
+	doff = 0;
+#else
+	skb->end = skb->head + size;
+#endif
+	skb_reset_tail_pointer(skb);
+	skb_headers_offset_update(skb, 0);
+	skb->cloned   = 0;
+	skb->hdr_len  = 0;
+	skb->nohdr    = 0;
+	skb->len -= off;
+	skb->data_len = skb->len;
+	atomic_set(&skb_shinfo(skb)->dataref, 1);
+	return 0;
+}
+
+/* remove len bytes from the beginning of the skb */
+static int pskb_carve(struct sk_buff *skb, const u32 len, gfp_t gfp)
+{
+	int headlen = skb_headlen(skb);
+
+	if (len < headlen)
+		return pskb_carve_inside_header(skb, len, headlen, gfp);
+	else
+		return pskb_carve_inside_nonlinear(skb, len, headlen, gfp);
+}
+
+/* Extract to_copy bytes starting at off from skb, and return this in
+ * a new skb
+ */
+struct sk_buff *pskb_extract(struct sk_buff *skb, int off,
+			     int to_copy, gfp_t gfp)
+{
+	struct sk_buff  *clone = skb_clone(skb, gfp);
+
+	if (!clone)
+		return NULL;
+
+	if (pskb_carve(clone, off, gfp) < 0) {
+		pr_warn("pskb_carve failed\n");
+		kfree_skb(clone);
+		return NULL;
+	}
+
+	if (pskb_trim(clone, to_copy)) {
+		pr_warn("pskb_trim failed\n");
+		kfree_skb(clone);
+		return NULL;
+	}
+	return clone;
+}
+EXPORT_SYMBOL(pskb_extract);
-- 
1.7.1
