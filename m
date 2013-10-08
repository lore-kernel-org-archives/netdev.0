From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next] Revert "xen-netback: improve ring effeciency for guest RX"
Date: Tue, 8 Oct 2013 10:54:21 +0100
Message-ID: <1381226061-6521-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xen.org>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Annie Li <annie.li@oracle.com>, Matt Wilson <msw@amazon.com>,
	Xi Xiong <xixiong@amazon.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21999 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab3JHJyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 05:54:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c.

The named changeset is causing problem. Let's aim to make this part less
fragile before trying to improve things.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Annie Li <annie.li@oracle.com>
Cc: Matt Wilson <msw@amazon.com>
Cc: Xi Xiong <xixiong@amazon.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Paul Durrant <paul.durrant@citrix.com>
---
 drivers/net/xen-netback/netback.c |  144 +++++++++++++++++++++----------------
 1 file changed, 83 insertions(+), 61 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index d0b0feb..f3e591c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -47,14 +47,6 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/page.h>
 
-/* SKB control block overlay is used to store useful information when
- * doing guest RX.
- */
-struct skb_cb_overlay {
-	int meta_slots_used;
-	int peek_slots_count;
-};
-
 /* Provide an option to disable split event channels at load time as
  * event channels are limited resource. Split event channels are
  * enabled by default.
@@ -220,6 +212,49 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
 	return false;
 }
 
+struct xenvif_count_slot_state {
+	unsigned long copy_off;
+	bool head;
+};
+
+unsigned int xenvif_count_frag_slots(struct xenvif *vif,
+				     unsigned long offset, unsigned long size,
+				     struct xenvif_count_slot_state *state)
+{
+	unsigned count = 0;
+
+	offset &= ~PAGE_MASK;
+
+	while (size > 0) {
+		unsigned long bytes;
+
+		bytes = PAGE_SIZE - offset;
+
+		if (bytes > size)
+			bytes = size;
+
+		if (start_new_rx_buffer(state->copy_off, bytes, state->head)) {
+			count++;
+			state->copy_off = 0;
+		}
+
+		if (state->copy_off + bytes > MAX_BUFFER_OFFSET)
+			bytes = MAX_BUFFER_OFFSET - state->copy_off;
+
+		state->copy_off += bytes;
+
+		offset += bytes;
+		size -= bytes;
+
+		if (offset == PAGE_SIZE)
+			offset = 0;
+
+		state->head = false;
+	}
+
+	return count;
+}
+
 /*
  * Figure out how many ring slots we're going to need to send @skb to
  * the guest. This function is essentially a dry run of
@@ -227,53 +262,40 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
  */
 unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 {
+	struct xenvif_count_slot_state state;
 	unsigned int count;
-	int i, copy_off;
-	struct skb_cb_overlay *sco;
+	unsigned char *data;
+	unsigned i;
 
-	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
+	state.head = true;
+	state.copy_off = 0;
 
-	copy_off = skb_headlen(skb) % PAGE_SIZE;
+	/* Slot for the first (partial) page of data. */
+	count = 1;
 
+	/* Need a slot for the GSO prefix for GSO extra data? */
 	if (skb_shinfo(skb)->gso_size)
 		count++;
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
-		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
-		unsigned long bytes;
-
-		offset &= ~PAGE_MASK;
-
-		while (size > 0) {
-			BUG_ON(offset >= PAGE_SIZE);
-			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
-
-			bytes = PAGE_SIZE - offset;
-
-			if (bytes > size)
-				bytes = size;
+	data = skb->data;
+	while (data < skb_tail_pointer(skb)) {
+		unsigned long offset = offset_in_page(data);
+		unsigned long size = PAGE_SIZE - offset;
 
-			if (start_new_rx_buffer(copy_off, bytes, 0)) {
-				count++;
-				copy_off = 0;
-			}
+		if (data + size > skb_tail_pointer(skb))
+			size = skb_tail_pointer(skb) - data;
 
-			if (copy_off + bytes > MAX_BUFFER_OFFSET)
-				bytes = MAX_BUFFER_OFFSET - copy_off;
+		count += xenvif_count_frag_slots(vif, offset, size, &state);
 
-			copy_off += bytes;
+		data += size;
+	}
 
-			offset += bytes;
-			size -= bytes;
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
 
-			if (offset == PAGE_SIZE)
-				offset = 0;
-		}
+		count += xenvif_count_frag_slots(vif, offset, size, &state);
 	}
-
-	sco = (struct skb_cb_overlay *)skb->cb;
-	sco->peek_slots_count = count;
 	return count;
 }
 
@@ -305,11 +327,14 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
 	return meta;
 }
 
-/* Set up the grant operations for this fragment. */
+/*
+ * Set up the grant operations for this fragment. If it's a flipping
+ * interface, we also set up the unmap request from here.
+ */
 static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 				 struct netrx_pending_operations *npo,
 				 struct page *page, unsigned long size,
-				 unsigned long offset, int head, int *first)
+				 unsigned long offset, int *head)
 {
 	struct gnttab_copy *copy_gop;
 	struct xenvif_rx_meta *meta;
@@ -333,12 +358,12 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		if (bytes > size)
 			bytes = size;
 
-		if (start_new_rx_buffer(npo->copy_off, bytes, head)) {
+		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
 			/*
 			 * Netfront requires there to be some data in the head
 			 * buffer.
 			 */
-			BUG_ON(*first);
+			BUG_ON(*head);
 
 			meta = get_next_rx_buffer(vif, npo);
 		}
@@ -372,10 +397,10 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		}
 
 		/* Leave a gap for the GSO descriptor. */
-		if (*first && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
+		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
 			vif->rx.req_cons++;
 
-		*first = 0; /* There must be something in this buffer now. */
+		*head = 0; /* There must be something in this buffer now. */
 
 	}
 }
@@ -401,7 +426,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	struct xen_netif_rx_request *req;
 	struct xenvif_rx_meta *meta;
 	unsigned char *data;
-	int first = 1;
+	int head = 1;
 	int old_meta_prod;
 
 	old_meta_prod = npo->meta_prod;
@@ -437,7 +462,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 			len = skb_tail_pointer(skb) - data;
 
 		xenvif_gop_frag_copy(vif, skb, npo,
-				     virt_to_page(data), len, offset, 1, &first);
+				     virt_to_page(data), len, offset, &head);
 		data += len;
 	}
 
@@ -446,7 +471,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				     skb_shinfo(skb)->frags[i].page_offset,
-				     0, &first);
+				     &head);
 	}
 
 	return npo->meta_prod - old_meta_prod;
@@ -504,6 +529,10 @@ static void xenvif_add_frag_responses(struct xenvif *vif, int status,
 	}
 }
 
+struct skb_cb_overlay {
+	int meta_slots_used;
+};
+
 static void xenvif_kick_thread(struct xenvif *vif)
 {
 	wake_up(&vif->wq);
@@ -534,26 +563,19 @@ void xenvif_rx_action(struct xenvif *vif)
 	count = 0;
 
 	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
-		RING_IDX old_rx_req_cons;
-
 		vif = netdev_priv(skb->dev);
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
-		old_rx_req_cons = vif->rx.req_cons;
 		sco = (struct skb_cb_overlay *)skb->cb;
 		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
 
-		count += vif->rx.req_cons - old_rx_req_cons;
+		count += nr_frags + 1;
 
 		__skb_queue_tail(&rxq, skb);
 
-		skb = skb_peek(&vif->rx_queue);
-		if (skb == NULL)
-			break;
-		sco = (struct skb_cb_overlay *)skb->cb;
-
 		/* Filled the batch queue? */
-		if (count + sco->peek_slots_count >= XEN_NETIF_RX_RING_SIZE)
+		/* XXX FIXME: RX path dependent on MAX_SKB_FRAGS */
+		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
 			break;
 	}
 
-- 
1.7.10.4
