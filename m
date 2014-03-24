From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v2 3/3] xen-netback: Follow-up patch for grant mapping series
Date: Mon, 24 Mar 2014 12:48:04 +0000
Message-ID: <1395665284-8911-3-git-send-email-zoltan.kiss@citrix.com>
References: <1395665284-8911-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:39005 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156AbaCXMsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 08:48:18 -0400
In-Reply-To: <1395665284-8911-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian made some late comments about the grant mapping series, I incorporated the
functional outcomes into this patch:

- use callback_param macro to shorten access to pending_tx_info in
  xenvif_fill_frags() and xenvif_tx_submit()
- print an error message in xenvif_idx_unmap() before panic

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
v2:
- expand commit message and split this into 2 patch
- fix typos

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f5c440b..0efa32d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -99,6 +99,9 @@ static inline unsigned long idx_to_kaddr(struct xenvif *vif,
 	return (unsigned long)pfn_to_kaddr(idx_to_pfn(vif, idx));
 }
 
+#define callback_param(vif, pending_idx) \
+	(vif->pending_tx_info[pending_idx].callback_struct)
+
 /* Find the containing VIF's structure from a pointer in pending_tx_info array
  */
 static inline struct xenvif* ubuf_to_vif(struct ubuf_info *ubuf)
@@ -1020,12 +1023,12 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 		/* If this is not the first frag, chain it to the previous*/
 		if (unlikely(prev_pending_idx == INVALID_PENDING_IDX))
 			skb_shinfo(skb)->destructor_arg =
-				&vif->pending_tx_info[pending_idx].callback_struct;
+				&callback_param(vif, pending_idx);
 		else if (likely(pending_idx != prev_pending_idx))
-			vif->pending_tx_info[prev_pending_idx].callback_struct.ctx =
-				&(vif->pending_tx_info[pending_idx].callback_struct);
+			callback_param(vif, prev_pending_idx).ctx =
+				&callback_param(vif, pending_idx);
 
-		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
+		callback_param(vif, pending_idx).ctx = NULL;
 		prev_pending_idx = pending_idx;
 
 		txp = &vif->pending_tx_info[pending_idx].req;
@@ -1395,13 +1398,13 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		memcpy(skb->data,
 		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
 		       data_len);
-		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
+		callback_param(vif, pending_idx).ctx = NULL;
 		if (data_len < txp->size) {
 			/* Append the packet payload as a fragment. */
 			txp->offset += data_len;
 			txp->size -= data_len;
 			skb_shinfo(skb)->destructor_arg =
-				&vif->pending_tx_info[pending_idx].callback_struct;
+				&callback_param(vif, pending_idx);
 		} else {
 			/* Schedule a response immediately. */
 			xenvif_idx_unmap(vif, pending_idx);
@@ -1678,12 +1680,20 @@ void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
 			    idx_to_kaddr(vif, pending_idx),
 			    GNTMAP_host_map,
 			    vif->grant_tx_handle[pending_idx]);
 	xenvif_grant_handle_reset(vif, pending_idx);
 
 	ret = gnttab_unmap_refs(&tx_unmap_op, NULL,
 				&vif->mmap_pages[pending_idx], 1);
-	BUG_ON(ret);
+	if (ret) {
+		netdev_err(vif->dev,
+			   "Unmap fail: ret: %d pending_idx: %d host_addr: %llx handle: %x status: %d\n",
+			   ret,
+			   pending_idx,
+			   tx_unmap_op.host_addr,
+			   tx_unmap_op.handle,
+			   tx_unmap_op.status);
+		BUG();
+	}
 
 	xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
 }
