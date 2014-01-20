From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v5 6/9] xen-netback: Handle guests with too many frags
Date: Mon, 20 Jan 2014 21:24:26 +0000
Message-ID: <1390253069-25507-7-git-send-email-zoltan.kiss@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Xen network protocol had implicit dependency on MAX_SKB_FRAGS. Netback has to
handle guests sending up to XEN_NETBK_LEGACY_SLOTS_MAX slots. To achieve that:
- create a new skb
- map the leftover slots to its frags (no linear buffer here!)
- chain it to the previous through skb_shinfo(skb)->frag_list
- map them
- copy the whole stuff into a brand new skb and send it to the stack
- unmap the 2 old skb's pages

v3:
- adding extra check for frag number
- consolidate alloc_skb's into xenvif_alloc_skb()
- BUG_ON(frag_overflow > MAX_SKB_FRAGS)

v4:
- handle error of skb_copy_expand()

v5:
- ratelimit error messages
- remove a tx_flags setting from xenvif_tx_submit 

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

---
 drivers/net/xen-netback/netback.c |  124 ++++++++++++++++++++++++++++++++++---
 1 file changed, 114 insertions(+), 10 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 22d05de..031258c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -803,6 +803,20 @@ static inline void xenvif_tx_create_gop(struct xenvif *vif,
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
+	return skb;
+}
+
 static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 							struct sk_buff *skb,
 							struct xen_netif_tx_request *txp,
@@ -813,11 +827,16 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 	u16 pending_idx = *((u16 *)skb->data);
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
@@ -833,6 +852,30 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 
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
 
@@ -846,6 +889,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	struct pending_tx_info *tx_info;
 	int nr_frags = shinfo->nr_frags;
 	int i, err, start;
+	struct sk_buff *first_skb = NULL;
 
 	/* Check status of header. */
 	err = gop->status;
@@ -866,6 +910,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
+check_frags:
 	for (i = start; i < nr_frags; i++) {
 		int j, newerr;
 
@@ -900,11 +945,20 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
 			continue;
-
 		/* First error: invalidate header and preceding fragments. */
-		pending_idx = *((u16 *)skb->data);
-		xenvif_idx_unmap(vif, pending_idx);
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
+		if (!first_skb) {
+			pending_idx = *((u16 *)skb->data);
+			xenvif_idx_unmap(vif, pending_idx);
+			xenvif_idx_release(vif,
+					   pending_idx,
+					   XEN_NETIF_RSP_OKAY);
+		} else {
+			pending_idx = *((u16 *)first_skb->data);
+			xenvif_idx_unmap(vif, pending_idx);
+			xenvif_idx_release(vif,
+					   pending_idx,
+					   XEN_NETIF_RSP_OKAY);
+		}
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
 			xenvif_idx_unmap(vif, pending_idx);
@@ -916,6 +970,32 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		err = newerr;
 	}
 
+	if (shinfo->frag_list) {
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
+		pending_idx = *((u16 *)first_skb->data);
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
@@ -1419,8 +1499,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			    ret < XEN_NETBK_LEGACY_SLOTS_MAX) ?
 			PKT_PROT_LEN : txreq.size;
 
-		skb = alloc_skb(data_len + NET_SKB_PAD + NET_IP_ALIGN,
-				GFP_ATOMIC | __GFP_NOWARN);
+		skb = xenvif_alloc_skb(data_len);
 		if (unlikely(skb == NULL)) {
 			netdev_dbg(vif->dev,
 				   "Can't allocate a skb in start_xmit.\n");
@@ -1428,9 +1507,6 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			break;
 		}
 
-		/* Packets passed to netif_rx() must have some headroom. */
-		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
-
 		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type) {
 			struct xen_netif_extra_info *gso;
 			gso = &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
@@ -1492,6 +1568,7 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		struct xen_netif_tx_request *txp;
 		u16 pending_idx;
 		unsigned data_len;
+		struct sk_buff *nskb = NULL;
 
 		pending_idx = *((u16 *)skb->data);
 		txp = &vif->pending_tx_info[pending_idx].req;
@@ -1534,6 +1611,30 @@ static int xenvif_tx_submit(struct xenvif *vif)
 				  pending_idx :
 				  INVALID_PENDING_IDX);
 
+		if (skb_shinfo(skb)->frag_list) {
+			nskb = skb_shinfo(skb)->frag_list;
+			xenvif_fill_frags(vif, nskb, INVALID_PENDING_IDX);
+			skb->len += nskb->len;
+			skb->data_len += nskb->len;
+			skb->truesize += nskb->truesize;
+			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+			skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+			vif->tx_zerocopy_sent += 2;
+			nskb = skb;
+
+			skb = skb_copy_expand(skb,
+					      0,
+					      0,
+					      GFP_ATOMIC | __GFP_NOWARN);
+			if (!skb) {
+				if (net_ratelimit())
+					netdev_dbg(vif->dev,
+						   "Can't consolidate skb with too many fragments\n");
+				kfree_skb(nskb);
+				continue;
+			}
+			skb_shinfo(skb)->destructor_arg = NULL;
+		}
 		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
 			int target = min_t(int, skb->len, PKT_PROT_LEN);
 			__pskb_pull_tail(skb, target - skb_headlen(skb));
@@ -1587,6 +1688,9 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		}
 
 		netif_receive_skb(skb);
+
+		if (nskb)
+			kfree_skb(nskb);
 	}
 
 	return work_done;
