From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Tue, 13 May 2014 15:31:40 +0100
Message-ID: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <davem@davemloft.net>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:14740 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbaEMOcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 10:32:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original series for reintroducing grant mapping for netback had a patch [1]
to handle receiving of packets from an another VIF. Grant copy on the receiving
side needs the grant ref of the page to set up the op.
The original patch assumed (wrongly) that the frags array haven't changed. In
the case reported by Sander, the sending guest sent a packet where the linear
buffer and the first frag were under PKT_PROT_LEN (=128) bytes.
xenvif_tx_submit() then pulled up the linear area to 128 bytes, and ditched the
first frag. The receiving side had an off-by-one problem when gathered the grant
refs.
This patch fixes that by checking whether the actual frag's page pointer is the
same as the page in the original frag list. It can handle any kind of changes on
the original frags array, like:
- removing granted frags from the beginning or the end
- adding local pages to the frags list
To keep it optimized to the most common cases, it doesn't handle when the order
of the original frags changed. That would require ubuf to be reseted to the
beginning of the chain (skb_shinfo(skb)->destructor_arg), and reiterating
through the list every time.

OPEN QUESTIONS:
- Is it a safe assumption that nothing changes the order of the original frags?
  Removing them from the array or injecting new pages anywhere is not a problem.
- I used UINT_MAX as a kind of INVALID_GRANT_REF, however there is no such thing
  in the grant mapping API. Should we codify this or is it better if we just
  find another way to distinguish whether a frag is local or not?
- Should this fix go to David's net tree or directly to the mainline tree? Or
  both?

[1]: 3e2234: xen-netback: Handle foreign mapped pages on the guest RX path

Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7666540..e18ac23 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -278,7 +278,7 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop->flags = GNTCOPY_dest_gref;
 		copy_gop->len = bytes;
 
-		if (foreign_vif) {
+		if (foreign_vif && (foreign_gref != UINT_MAX)) {
 			copy_gop->source.domid = foreign_vif->domid;
 			copy_gop->source.u.ref = foreign_gref;
 			copy_gop->flags |= GNTCOPY_source_gref;
@@ -388,15 +388,22 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 
 	if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
 		 (ubuf->callback == &xenvif_zerocopy_callback)) {
-		int i = 0;
 		foreign_vif = ubuf_to_vif(ubuf);
 
-		do {
-			u16 pending_idx = ubuf->desc;
-			foreign_grefs[i++] =
-				foreign_vif->pending_tx_info[pending_idx].req.gref;
-			ubuf = (struct ubuf_info *) ubuf->ctx;
-		} while (ubuf);
+		for (i = 0; i < nr_frags; i++) {
+			foreign_grefs[i] = UINT_MAX;
+			do {
+				u16 pending_idx = ubuf->desc;
+
+				ubuf = (struct ubuf_info *) ubuf->ctx;
+				if (skb_shinfo(skb)->frags[i].page.p ==
+					foreign_vif->mmap_pages[pending_idx]) {
+					foreign_grefs[i] =
+						foreign_vif->pending_tx_info[pending_idx].req.gref;
+					break;
+				}
+			} while (ubuf);
+		}
 	}
 
 	data = skb->data;
