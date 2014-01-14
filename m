From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v4 4/9] xen-netback: Change RX path for mapped SKB fragments
Date: Tue, 14 Jan 2014 20:39:50 +0000
Message-ID: <1389731995-9887-5-git-send-email-zoltan.kiss@citrix.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27967 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbaANUkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 15:40:15 -0500
In-Reply-To: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX path need to know if the SKB fragments are stored on pages from another
domain.

v4:
- indentation fixes

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/netback.c |   46 +++++++++++++++++++++++++++++++++----
 1 file changed, 41 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f74fa92..d43444d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -226,7 +226,9 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
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
@@ -268,8 +270,15 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
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
@@ -330,6 +339,9 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	int old_meta_prod;
 	int gso_type;
 	int gso_size;
+	struct ubuf_info *ubuf = skb_shinfo(skb)->destructor_arg;
+	grant_ref_t foreign_grefs[MAX_SKB_FRAGS];
+	struct xenvif *foreign_vif = NULL;
 
 	old_meta_prod = npo->meta_prod;
 
@@ -370,6 +382,26 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	npo->copy_off = 0;
 	npo->copy_gref = req->gref;
 
+	if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
+		 (ubuf->callback == &xenvif_zerocopy_callback)) {
+		u16 pending_idx = ubuf->desc;
+		int i = 0;
+		struct pending_tx_info *temp =
+			container_of(ubuf,
+				     struct pending_tx_info,
+				     callback_struct);
+		foreign_vif =
+			container_of(temp - pending_idx,
+				     struct xenvif,
+				     pending_tx_info[0]);
+		do {
+			pending_idx = ubuf->desc;
+			foreign_grefs[i++] =
+				foreign_vif->pending_tx_info[pending_idx].req.gref;
+			ubuf = (struct ubuf_info *) ubuf->ctx;
+		} while (ubuf);
+	}
+
 	data = skb->data;
 	while (data < skb_tail_pointer(skb)) {
 		unsigned int offset = offset_in_page(data);
@@ -379,7 +411,9 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 			len = skb_tail_pointer(skb) - data;
 
 		xenvif_gop_frag_copy(vif, skb, npo,
-				     virt_to_page(data), len, offset, &head);
+				     virt_to_page(data), len, offset, &head,
+				     NULL,
+				     0);
 		data += len;
 	}
 
@@ -388,7 +422,9 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				     skb_shinfo(skb)->frags[i].page_offset,
-				     &head);
+				     &head,
+				     foreign_vif,
+				     foreign_grefs[i]);
 	}
 
 	return npo->meta_prod - old_meta_prod;
