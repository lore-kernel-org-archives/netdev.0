From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v7 3/9] xen-netback: Handle foreign
	mapped pages on the guest RX path
Date: Thu, 6 Mar 2014 21:48:25 +0000
Message-ID: <1394142511-14827-4-git-send-email-zoltan.kiss@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zoltan Kiss <zoltan.kiss@citrix.com>, jonathan.davies@citrix.com
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

RX path need to know if the SKB fragments are stored on pages from another
domain.
Logically this patch should be after introducing the grant mapping itself, as
it makes sense only after that. But to keep bisectability, I moved it here. It
shouldn't change any functionality here. xenvif_zerocopy_callback and
ubuf_to_vif are just stubs here, they will be introduced properly later on.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
v4:
- indentation fixes

v6:
- use ubuf_to_vif helper
- move the patch earlier in the series due to bisectability

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 9d35845..8f264df 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -247,6 +247,9 @@ static inline bool xenvif_tx_pending_slots_available(struct xenvif *vif)
 		< MAX_PENDING_REQS;
 }
 
+/* Callback from stack when TX packet can be released */
+void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
+
 extern bool separate_tx_rx_irq;
 
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 715d810..e9391ba 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -101,6 +101,10 @@ static inline unsigned long idx_to_kaddr(struct xenvif *vif,
 	return (unsigned long)pfn_to_kaddr(idx_to_pfn(vif, idx));
 }
 
+static inline struct xenvif* ubuf_to_vif(struct ubuf_info *ubuf)
+{
+	return NULL;
+}
 /* This is a miniumum size for the linear area to avoid lots of
  * calls to __pskb_pull_tail() as we set up checksum offsets. The
  * value 128 was chosen as it covers all IPv4 and most likely
@@ -221,7 +225,9 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
 static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 				 struct netrx_pending_operations *npo,
 				 struct page *page, unsigned long size,
-				 unsigned long offset, int *head)
+				 unsigned long offset, int *head,
+				 struct xenvif *foreign_vif,
+				 grant_ref_t foreign_gref)
 {
 	struct gnttab_copy *copy_gop;
 	struct xenvif_rx_meta *meta;
@@ -263,8 +269,15 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop->flags = GNTCOPY_dest_gref;
 		copy_gop->len = bytes;
 
-		copy_gop->source.domid = DOMID_SELF;
-		copy_gop->source.u.gmfn = virt_to_mfn(page_address(page));
+		if (foreign_vif) {
+			copy_gop->source.domid = foreign_vif->domid;
+			copy_gop->source.u.ref = foreign_gref;
+			copy_gop->flags |= GNTCOPY_source_gref;
+		} else {
+			copy_gop->source.domid = DOMID_SELF;
+			copy_gop->source.u.gmfn =
+				virt_to_mfn(page_address(page));
+		}
 		copy_gop->source.offset = offset;
 
 		copy_gop->dest.domid = vif->domid;
@@ -325,6 +338,9 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	int old_meta_prod;
 	int gso_type;
 	int gso_size;
+	struct ubuf_info *ubuf = skb_shinfo(skb)->destructor_arg;
+	grant_ref_t foreign_grefs[MAX_SKB_FRAGS];
+	struct xenvif *foreign_vif = NULL;
 
 	old_meta_prod = npo->meta_prod;
 
@@ -365,6 +381,19 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	npo->copy_off = 0;
 	npo->copy_gref = req->gref;
 
+	if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
+		 (ubuf->callback == &xenvif_zerocopy_callback)) {
+		int i = 0;
+		foreign_vif = ubuf_to_vif(ubuf);
+
+		do {
+			u16 pending_idx = ubuf->desc;
+			foreign_grefs[i++] =
+				foreign_vif->pending_tx_info[pending_idx].req.gref;
+			ubuf = (struct ubuf_info *) ubuf->ctx;
+		} while (ubuf);
+	}
+
 	data = skb->data;
 	while (data < skb_tail_pointer(skb)) {
 		unsigned int offset = offset_in_page(data);
@@ -374,7 +403,9 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 			len = skb_tail_pointer(skb) - data;
 
 		xenvif_gop_frag_copy(vif, skb, npo,
-				     virt_to_page(data), len, offset, &head);
+				     virt_to_page(data), len, offset, &head,
+				     NULL,
+				     0);
 		data += len;
 	}
 
@@ -383,7 +414,9 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				     skb_shinfo(skb)->frags[i].page_offset,
-				     &head);
+				     &head,
+				     foreign_vif,
+				     foreign_grefs[i]);
 	}
 
 	return npo->meta_prod - old_meta_prod;
@@ -1351,6 +1384,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
 	return work_done;
 }
 
+void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
+{
+	return;
+}
+
 /* Called after netfront has transmitted */
 int xenvif_tx_action(struct xenvif *vif, int budget)
 {
