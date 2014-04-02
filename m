From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH] grant-table, xen-netback: Introduce helper functions for grant copy operations
Date: Wed, 2 Apr 2014 18:05:49 +0100
Message-ID: <1396458349-30112-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stefano.stabellini@eu.citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>, Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <konrad.wilk@oracle.com>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:52722 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932740AbaDBRF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 13:05:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create helper functions for grant copy operations and use them in netback.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 8d3bb4a..874df60 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -275,23 +275,29 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
 
 		copy_gop = npo->copy + npo->copy_prod++;
-		copy_gop->flags = GNTCOPY_dest_gref;
-		copy_gop->len = bytes;
 
 		if (foreign_vif) {
-			copy_gop->source.domid = foreign_vif->domid;
-			copy_gop->source.u.ref = foreign_gref;
-			copy_gop->flags |= GNTCOPY_source_gref;
+			gnttab_set_copy_op_ref_to_ref(copy_gop,
+						      foreign_gref,
+						      npo->copy_gref,
+						      foreign_vif->domid,
+						      offset,
+						      vif->domid,
+						      npo->copy_off,
+						      bytes,
+						      GNTCOPY_dest_gref |
+						      GNTCOPY_source_gref);
 		} else {
-			copy_gop->source.domid = DOMID_SELF;
-			copy_gop->source.u.gmfn =
-				virt_to_mfn(page_address(page));
+			gnttab_set_copy_op_gmfn_to_ref(copy_gop,
+						       virt_to_mfn(page_address(page)),
+						       npo->copy_gref,
+						       DOMID_SELF,
+						       offset,
+						       vif->domid,
+						       npo->copy_off,
+						       bytes,
+						       GNTCOPY_dest_gref);
 		}
-		copy_gop->source.offset = offset;
-
-		copy_gop->dest.domid = vif->domid;
-		copy_gop->dest.offset = npo->copy_off;
-		copy_gop->dest.u.ref = npo->copy_gref;
 
 		npo->copy_off += bytes;
 		meta->size += bytes;
@@ -1297,18 +1303,16 @@ static void xenvif_tx_build_gops(struct xenvif *vif,
 		XENVIF_TX_CB(skb)->pending_idx = pending_idx;
 
 		__skb_put(skb, data_len);
-		vif->tx_copy_ops[*copy_ops].source.u.ref = txreq.gref;
-		vif->tx_copy_ops[*copy_ops].source.domid = vif->domid;
-		vif->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
-
-		vif->tx_copy_ops[*copy_ops].dest.u.gmfn =
-			virt_to_mfn(skb->data);
-		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
-		vif->tx_copy_ops[*copy_ops].dest.offset =
-			offset_in_page(skb->data);
-
-		vif->tx_copy_ops[*copy_ops].len = data_len;
-		vif->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
+
+		gnttab_set_copy_op_ref_to_gmfn(&vif->tx_copy_ops[*copy_ops],
+					       txreq.gref,
+					       virt_to_mfn(skb->data),
+					       vif->domid,
+					       txreq.offset,
+					       DOMID_SELF,
+					       offset_in_page(skb->data),
+					       data_len,
+					       GNTCOPY_source_gref);
 
 		(*copy_ops)++;
 
diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
index a5af2a2..90a2f4c 100644
--- a/include/xen/grant_table.h
+++ b/include/xen/grant_table.h
@@ -140,6 +140,59 @@ void gnttab_grant_foreign_transfer_ref(grant_ref_t, domid_t domid,
 				       unsigned long pfn);
 
 static inline void
+gnttab_set_copy_op_common(struct gnttab_copy *copy,
+			  domid_t src_domid, uint16_t src_offset,
+			  domid_t dst_domid, uint16_t dst_offset,
+			  uint16_t len, uint16_t flags)
+{
+	copy->source.domid = src_domid;
+	copy->source.offset = src_offset;
+	copy->dest.domid = dst_domid;
+	copy->dest.offset = dst_offset;
+	copy->len = len;
+	copy->flags = flags;
+}
+
+static inline void
+gnttab_set_copy_op_gmfn_to_ref(struct gnttab_copy *copy,
+			       xen_pfn_t src_gmfn, grant_ref_t dst_ref,
+			       domid_t src_domid, uint16_t src_offset,
+			       domid_t dst_domid, uint16_t dst_offset,
+			       uint16_t len, uint16_t flags)
+{
+	copy->source.u.gmfn = src_gmfn;
+	copy->dest.u.ref = dst_ref;
+	gnttab_set_copy_op_common(copy, src_domid, src_offset, dst_domid,
+				  dst_offset, len, flags);
+}
+
+static inline void
+gnttab_set_copy_op_ref_to_ref(struct gnttab_copy *copy,
+			      grant_ref_t src_ref, grant_ref_t dst_ref,
+			      domid_t src_domid, uint16_t src_offset,
+			      domid_t dst_domid, uint16_t dst_offset,
+			      uint16_t len, uint16_t flags)
+{
+	copy->source.u.ref = src_ref;
+	copy->dest.u.ref = dst_ref;
+	gnttab_set_copy_op_common(copy, src_domid, src_offset, dst_domid,
+				  dst_offset, len, flags);
+}
+
+static inline void
+gnttab_set_copy_op_ref_to_gmfn(struct gnttab_copy *copy,
+			       grant_ref_t src_ref, xen_pfn_t dst_gmfn,
+			       domid_t src_domid, uint16_t src_offset,
+			       domid_t dst_domid, uint16_t dst_offset,
+			       uint16_t len, uint16_t flags)
+{
+	copy->source.u.ref = src_ref;
+	copy->dest.u.gmfn = dst_gmfn;
+	gnttab_set_copy_op_common(copy, src_domid, src_offset, dst_domid,
+				  dst_offset, len, flags);
+}
+
+static inline void
 gnttab_set_map_op(struct gnttab_map_grant_ref *map, phys_addr_t addr,
 		  uint32_t flags, grant_ref_t ref, domid_t domid)
 {
