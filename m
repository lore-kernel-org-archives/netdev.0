From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net v2] xen-netback: Fix grant ref resolution in RX path
Date: Tue, 13 May 2014 21:19:54 +0100
Message-ID: <1400012394-16645-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <davem@davemloft.net>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:59483 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198AbaEMUUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 16:20:09 -0400
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
- reordering the frags
It's optimized to the most common case, when there is 1:1 relation between the
frags and the list, plus works optimal when frags are removed from the end or
the beginning.

[1]: 3e2234: xen-netback: Handle foreign mapped pages on the guest RX path

Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
v2:
- rework to handle more scenarios
- use const keyword more often

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7666540..d97af5c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -104,7 +104,7 @@ static inline unsigned long idx_to_kaddr(struct xenvif *vif,
 
 /* Find the containing VIF's structure from a pointer in pending_tx_info array
  */
-static inline struct xenvif* ubuf_to_vif(struct ubuf_info *ubuf)
+static inline struct xenvif *ubuf_to_vif(const struct ubuf_info *ubuf)
 {
 	u16 pending_idx = ubuf->desc;
 	struct pending_tx_info *temp =
@@ -323,6 +323,42 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 }
 
 /*
+ * Find the grant ref for a given frag in chained struct ubuf_info's
+ * skb: the skb itself
+ * i: the frag's number
+ * ubuf: a pointer to an element in the chain. It should not be NULL
+ *
+ * Returns a pointer to the element in the chain where the page were found. If
+ * not found, returns NULL.
+ * See the definition of callback_struct in common.h for more details about
+ * the chain.
+ */
+static const struct ubuf_info *xenvif_find_gref(const struct sk_buff *const skb,
+						const int i,
+						const struct ubuf_info *ubuf)
+{
+	struct xenvif *foreign_vif = ubuf_to_vif(ubuf);
+
+	do {
+		u16 pending_idx = ubuf->desc;
+
+		if (skb_shinfo(skb)->frags[i].page.p ==
+		    foreign_vif->mmap_pages[pending_idx])
+			break;
+		ubuf = (struct ubuf_info *) ubuf->ctx;
+	} while (ubuf);
+
+	return ubuf;
+}
+
+#define gref_found() {							\
+u16 pending_idx = ubuf->desc;						\
+foreign_vif = ubuf_to_vif(ubuf);					\
+foreign_gref = foreign_vif->pending_tx_info[pending_idx].req.gref;	\
+ubuf = ubuf->ctx ? (struct ubuf_info *) ubuf->ctx : head_ubuf;		\
+}
+
+/*
  * Prepare an SKB to be transmitted to the frontend.
  *
  * This function is responsible for allocating grant operations, meta
@@ -346,9 +382,9 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	int head = 1;
 	int old_meta_prod;
 	int gso_type;
-	struct ubuf_info *ubuf = skb_shinfo(skb)->destructor_arg;
-	grant_ref_t foreign_grefs[MAX_SKB_FRAGS];
-	struct xenvif *foreign_vif = NULL;
+	const struct ubuf_info *ubuf = skb_shinfo(skb)->destructor_arg;
+	const struct ubuf_info *const head_ubuf =
+					skb_shinfo(skb)->destructor_arg;
 
 	old_meta_prod = npo->meta_prod;
 
@@ -386,19 +422,6 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	npo->copy_off = 0;
 	npo->copy_gref = req->gref;
 
-	if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
-		 (ubuf->callback == &xenvif_zerocopy_callback)) {
-		int i = 0;
-		foreign_vif = ubuf_to_vif(ubuf);
-
-		do {
-			u16 pending_idx = ubuf->desc;
-			foreign_grefs[i++] =
-				foreign_vif->pending_tx_info[pending_idx].req.gref;
-			ubuf = (struct ubuf_info *) ubuf->ctx;
-		} while (ubuf);
-	}
-
 	data = skb->data;
 	while (data < skb_tail_pointer(skb)) {
 		unsigned int offset = offset_in_page(data);
@@ -415,13 +438,35 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	}
 
 	for (i = 0; i < nr_frags; i++) {
+		grant_ref_t foreign_gref = UINT_MAX;
+		struct xenvif *foreign_vif = NULL;
+
+		if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
+			(ubuf->callback == &xenvif_zerocopy_callback)) {
+
+			ubuf = xenvif_find_gref(skb, i, ubuf);
+
+			if (likely(ubuf)) {
+				gref_found()
+			} else {
+				/* Try again from the beginning of the list */
+				ubuf = xenvif_find_gref(skb, i, head_ubuf);
+
+				if (ubuf)
+					gref_found()
+				else
+					ubuf = head_ubuf;
+			}
+
+
+		}
 		xenvif_gop_frag_copy(vif, skb, npo,
 				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				     skb_shinfo(skb)->frags[i].page_offset,
 				     &head,
 				     foreign_vif,
-				     foreign_grefs[i]);
+				     foreign_gref);
 	}
 
 	return npo->meta_prod - old_meta_prod;
