From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v6 7/10] xen-netback: Handle guests with too many frags
Date: Tue, 4 Mar 2014 22:32:18 +0000
Message-ID: <1393972341-21135-8-git-send-email-zoltan.kiss@citrix.com>
References: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>, Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Xen network protocol had implicit dependency on MAX_SKB_FRAGS. Netback has to
handle guests sending up to XEN_NETBK_LEGACY_SLOTS_MAX slots. To achieve that:
- create a new skb
- map the leftover slots to its frags (no linear buffer here!)
- chain it to the previous through skb_shinfo(skb)->frag_list
- map them
- copy and coalesce the frags into a brand new one and send it to the stack
- unmap the 2 old skb's pages

NOTE: if bisect brought you here, you should apply the series up until #9,
otherwise malicious guests can block other guests by not releasing their sent
packets.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
v3:
- adding extra check for frag number
- consolidate alloc_skb's into xenvif_alloc_skb()
- BUG_ON(frag_overflow > MAX_SKB_FRAGS)

v4:
- handle error of skb_copy_expand()

v5:
- ratelimit error messages
- remove a tx_flags setting from xenvif_tx_submit 

v6:
- move out handling from tx_submit into a new funciont, as it became quite long
- skb_copy[_expand] allocate a new skb with a huge linear buffer, which is bad
  in times of memory pressure. Just make a new frags array and do the copy and
  coalesce with skb_copy_bits

 drivers/net/xen-netback/netback.c |  172 ++++++++++++++++++++++++++++++++++---
 1 file changed, 162 insertions(+), 10 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 447d58a..b284851 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -37,6 +37,7 @@
 #include <linux/kthread.h>
 #include <linux/if_vlan.h>
 #include <linux/udp.h>
+#include <linux/highmem.h>
 
 #include <net/tcp.h>
 
@@ -792,6 +793,23 @@ static inline void xenvif_tx_create_gop(struct xenvif *vif,
 	       sizeof(*txp));
 }
 
+static inline struct sk_buff *xenvif_alloc_skb(unsigned int size)
+{
+	struct sk_buff *skb =
+		alloc_skb(size + NET_SKB_PAD + NET_IP_ALIGN,
+			  GFP_ATOMIC | __GFP_NOWARN);
+	if (unlikely(skb == NULL))
+		return NULL;
+
+	/* Packets passed to netif_rx() must have some headroom. */
+	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+
+	/* Initialize it here to avoid later surprises */
+	skb_shinfo(skb)->destructor_arg = NULL;
+
+	return skb;
+}
+
 static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 							struct sk_buff *skb,
 							struct xen_netif_tx_request *txp,
@@ -802,11 +820,16 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 	u16 pending_idx = *((u16 *)skb->cb);
 	int start;
 	pending_ring_idx_t index;
-	unsigned int nr_slots;
+	unsigned int nr_slots, frag_overflow = 0;
 
 	/* At this point shinfo->nr_frags is in fact the number of
 	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
 	 */
+	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
+		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
+		BUG_ON(frag_overflow > MAX_SKB_FRAGS);
+		shinfo->nr_frags = MAX_SKB_FRAGS;
+	}
 	nr_slots = shinfo->nr_frags;
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
@@ -822,6 +845,30 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 
 	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
 
+	if (frag_overflow) {
+		struct sk_buff *nskb = xenvif_alloc_skb(0);
+		if (unlikely(nskb == NULL)) {
+			if (net_ratelimit())
+				netdev_err(vif->dev,
+					   "Can't allocate the frag_list skb.\n");
+			return NULL;
+		}
+
+		shinfo = skb_shinfo(nskb);
+		frags = shinfo->frags;
+
+		for (shinfo->nr_frags = 0; shinfo->nr_frags < frag_overflow;
+		     shinfo->nr_frags++, txp++, gop++) {
+			index = pending_index(vif->pending_cons++);
+			pending_idx = vif->pending_ring[index];
+			xenvif_tx_create_gop(vif, pending_idx, txp, gop);
+			frag_set_pending_idx(&frags[shinfo->nr_frags],
+					     pending_idx);
+		}
+
+		skb_shinfo(skb)->frag_list = nskb;
+	}
+
 	return gop;
 }
 
@@ -862,6 +909,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	struct pending_tx_info *tx_info;
 	int nr_frags = shinfo->nr_frags;
 	int i, err, start;
+	struct sk_buff *first_skb = NULL;
 
 	/* Check status of header. */
 	err = gop->status;
@@ -873,6 +921,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
+check_frags:
 	for (i = start; i < nr_frags; i++) {
 		int j, newerr;
 
@@ -896,9 +945,11 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
 			continue;
-
 		/* First error: invalidate header and preceding fragments. */
-		pending_idx = *((u16 *)skb->cb);
+		if (!first_skb)
+			pending_idx = *((u16 *)skb->cb);
+		else
+			pending_idx = *((u16 *)first_skb->cb);
 		xenvif_idx_unmap(vif, pending_idx);
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
@@ -909,6 +960,32 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		err = newerr;
 	}
 
+	if (skb_has_frag_list(skb)) {
+		first_skb = skb;
+		skb = shinfo->frag_list;
+		shinfo = skb_shinfo(skb);
+		nr_frags = shinfo->nr_frags;
+		start = 0;
+
+		goto check_frags;
+	}
+
+	/* There was a mapping error in the frag_list skb. We have to unmap
+	 * the first skb's frags
+	 */
+	if (first_skb && err) {
+		int j;
+		shinfo = skb_shinfo(first_skb);
+		pending_idx = *((u16 *)first_skb->cb);
+		start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
+		for (j = start; j < shinfo->nr_frags; j++) {
+			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
+			xenvif_idx_unmap(vif, pending_idx);
+			xenvif_idx_release(vif, pending_idx,
+					   XEN_NETIF_RSP_OKAY);
+		}
+	}
+
 	*gopp = gop + 1;
 	return err;
 }
@@ -921,7 +998,7 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 	u16 prev_pending_idx = INVALID_PENDING_IDX;
 
 	if (skb_shinfo(skb)->destructor_arg)
-		prev_pending_idx = skb->cb;
+		prev_pending_idx = *((u16 *)skb->cb);
 
 	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = shinfo->frags + i;
@@ -1160,8 +1237,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			    ret < XEN_NETBK_LEGACY_SLOTS_MAX) ?
 			PKT_PROT_LEN : txreq.size;
 
-		skb = alloc_skb(data_len + NET_SKB_PAD + NET_IP_ALIGN,
-				GFP_ATOMIC | __GFP_NOWARN);
+		skb = xenvif_alloc_skb(data_len);
 		if (unlikely(skb == NULL)) {
 			netdev_dbg(vif->dev,
 				   "Can't allocate a skb in start_xmit.\n");
@@ -1169,9 +1245,6 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			break;
 		}
 
-		/* Packets passed to netif_rx() must have some headroom. */
-		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
-
 		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type) {
 			struct xen_netif_extra_info *gso;
 			gso = &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
@@ -1222,6 +1295,75 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 	return gop - vif->tx_map_ops;
 }
 
+/* Consolidate skb with a frag_list into a brand new one with local pages on
+ * frags. Returns 0 or -ENOMEM if can't allocate new pages.
+ */
+static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
+{
+	unsigned int offset = skb_headlen(skb);
+	skb_frag_t frags[MAX_SKB_FRAGS];
+	int i;
+	struct ubuf_info *uarg;
+	struct sk_buff *nskb = skb_shinfo(skb)->frag_list;
+
+	vif->tx_zerocopy_sent += 2;
+	vif->tx_frag_overflow++;
+
+	xenvif_fill_frags(vif, nskb);
+	/* Subtract frags size, we will correct it later */
+	skb->truesize -= skb->data_len;
+	skb->len += nskb->len;
+	skb->data_len += nskb->len;
+
+	/* create a brand new frags array and coalesce there */
+	for (i = 0; offset < skb->len; i++) {
+		struct page *page;
+		void *vaddr;
+		unsigned int len;
+
+		BUG_ON(i >= MAX_SKB_FRAGS);
+		page = alloc_page(GFP_ATOMIC|__GFP_COLD);
+		if (!page) {
+			int j;
+			skb->truesize += skb->data_len;
+			for (j = 0; j < i; j++)
+				put_page(frags[j].page.p);
+			return -ENOMEM;
+		}
+
+		vaddr = kmap_atomic(page);
+		if (offset + PAGE_SIZE < skb->len)
+			len = PAGE_SIZE;
+		else
+			len = skb->len - offset;
+		if (skb_copy_bits(skb, offset, vaddr, len))
+			BUG();
+
+		kunmap_atomic(vaddr);
+		offset += len;
+		frags[i].page.p = page;
+		frags[i].page_offset = 0;
+		skb_frag_size_set(&frags[i], len);
+
+	}
+	/* swap out with old one */
+	memcpy(skb_shinfo(skb)->frags,
+	       frags,
+	       i * sizeof(skb_frag_t));
+	skb_shinfo(skb)->nr_frags = i;
+	skb->truesize += i * PAGE_SIZE;
+
+	/* remove traces of mapped pages and frag_list */
+	skb_frag_list_init(skb);
+	uarg = skb_shinfo(skb)->destructor_arg;
+	uarg->callback(uarg, true);
+	skb_shinfo(skb)->destructor_arg = NULL;
+
+	skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+	kfree_skb(nskb);
+
+	return 0;
+}
 
 static int xenvif_tx_submit(struct xenvif *vif)
 {
@@ -1258,7 +1400,6 @@ static int xenvif_tx_submit(struct xenvif *vif)
 				&vif->pending_tx_info[pending_idx].callback_struct;
 		} else {
 			/* Schedule a response immediately. */
-			skb_shinfo(skb)->destructor_arg = NULL;
 			xenvif_idx_unmap(vif, pending_idx);
 		}
 
@@ -1269,6 +1410,17 @@ static int xenvif_tx_submit(struct xenvif *vif)
 
 		xenvif_fill_frags(vif, skb);
 
+		if (unlikely(skb_has_frag_list(skb))) {
+			if (xenvif_handle_frag_list(vif, skb)) {
+				if (net_ratelimit())
+					netdev_err(vif->dev,
+						   "Not enough memory to consolidate frag_list!\n");
+				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+				kfree_skb(skb);
+				continue;
+			}
+		}
+
 		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
 			int target = min_t(int, skb->len, PKT_PROT_LEN);
 			__pskb_pull_tail(skb, target - skb_headlen(skb));
