From: Matt Wilson <msw@amazon.com>
Subject: [PATCH RFC] xen-netback: calculate the number of slots required for large MTU vifs
Date: Tue, 9 Jul 2013 22:40:59 +0000
Message-ID: <1373409659-22383-1-git-send-email-msw@amazon.com>
References: <20130709221406.GA13671@u109add4315675089e695.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Xi Xiong <xixiong@amazon.com>, Matt Wilson <msw@amazon.com>,
	Annie Li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:27438 "EHLO
	smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab3GIWll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 18:41:41 -0400
In-Reply-To: <20130709221406.GA13671@u109add4315675089e695.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xi Xiong <xixiong@amazon.com>

[ note: I've just cherry picked this onto net-next, and only compile
  tested. This a RFC only. -msw ]

Currently the number of RX slots required to transmit a SKB to
xen-netfront can be miscalculated when an interface uses a MTU larger
than PAGE_SIZE. If the slot calculation is wrong, xen-netback can
pause the queue indefinitely or reuse slots. The former manifests as a
loss of connectivity to the guest (which can be restored by lowering
the MTU set on the interface). The latter manifests with "Bad grant
reference" messages from Xen such as:

(XEN) grant_table.c:1797:d0 Bad grant reference 264241157

and kernel messages within the guest such as:

[  180.419567] net eth0: Invalid extra type: 112
[  180.868620] net eth0: rx->offset: 0, size: 4294967295
[  180.868629] net eth0: rx->offset: 0, size: 4294967295

BUG_ON() assertions can also be hit if RX slots are exhausted while
handling a SKB.

This patch changes xen_netbk_rx_action() to count the number of RX
slots actually consumed by netbk_gop_skb() instead of using nr_frags + 1.
This prevents under-counting the number of RX slots consumed when a
SKB has a large linear buffer.

Additionally, we now store the estimated number of RX slots required
to handle a SKB in the cb overlay. This value is used to determine if
the next SKB in the queue can be processed.

Finally, the logic in start_new_rx_buffer() can cause RX slots to be
wasted when setting up copy grant table operations for SKBs with large
linear buffers. For example, a SKB with skb_headlen() equal to 8157
bytes that starts 64 bytes 64 bytes from the start of the page will
consume three RX slots instead of two. This patch changes the "head"
parameter to netbk_gop_frag_copy() to act as a flag. When set,
start_new_rx_buffer() will always place as much data as possible into
each RX slot.

Signed-off-by: Xi Xiong <xixiong@amazon.com>
Reviewed-by: Matt Wilson <msw@amazon.com>
[ msw: minor code cleanups, rewrote commit message, adjusted code
  to count RX slots instead of meta structures ]
Signed-off-by: Matt Wilson <msw@amazon.com>
Cc: Annie Li <annie.li@oracle.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <Ian.Campbell@citrix.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
 drivers/net/xen-netback/netback.c |   51 ++++++++++++++++++++++--------------
 1 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 64828de..82dd207 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -110,6 +110,11 @@ union page_ext {
 	void *mapping;
 };
 
+struct skb_cb_overlay {
+	int meta_slots_used;
+	int peek_slots_count;
+};
+
 struct xen_netbk {
 	wait_queue_head_t wq;
 	struct task_struct *task;
@@ -370,6 +375,7 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 {
 	unsigned int count;
 	int i, copy_off;
+	struct skb_cb_overlay *sco;
 
 	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
 
@@ -411,6 +417,9 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 				offset = 0;
 		}
 	}
+
+	sco = (struct skb_cb_overlay *) skb->cb;
+	sco->peek_slots_count = count;
 	return count;
 }
 
@@ -443,13 +452,12 @@ static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
 }
 
 /*
- * Set up the grant operations for this fragment. If it's a flipping
- * interface, we also set up the unmap request from here.
+ * Set up the grant operations for this fragment.
  */
 static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 				struct netrx_pending_operations *npo,
 				struct page *page, unsigned long size,
-				unsigned long offset, int *head)
+				unsigned long offset, int head, int *first)
 {
 	struct gnttab_copy *copy_gop;
 	struct netbk_rx_meta *meta;
@@ -479,12 +487,12 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		if (bytes > size)
 			bytes = size;
 
-		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
+		if (start_new_rx_buffer(npo->copy_off, bytes, head)) {
 			/*
 			 * Netfront requires there to be some data in the head
 			 * buffer.
 			 */
-			BUG_ON(*head);
+			BUG_ON(*first);
 
 			meta = get_next_rx_buffer(vif, npo);
 		}
@@ -529,10 +537,10 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		}
 
 		/* Leave a gap for the GSO descriptor. */
-		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
+		if (*first && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
 			vif->rx.req_cons++;
 
-		*head = 0; /* There must be something in this buffer now. */
+		*first = 0; /* There must be something in this buffer now. */
 
 	}
 }
@@ -558,7 +566,7 @@ static int netbk_gop_skb(struct sk_buff *skb,
 	struct xen_netif_rx_request *req;
 	struct netbk_rx_meta *meta;
 	unsigned char *data;
-	int head = 1;
+	int first = 1;
 	int old_meta_prod;
 
 	old_meta_prod = npo->meta_prod;
@@ -594,16 +602,16 @@ static int netbk_gop_skb(struct sk_buff *skb,
 			len = skb_tail_pointer(skb) - data;
 
 		netbk_gop_frag_copy(vif, skb, npo,
-				    virt_to_page(data), len, offset, &head);
+				virt_to_page(data), len, offset, 1, &first);
 		data += len;
 	}
 
 	for (i = 0; i < nr_frags; i++) {
 		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
-				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
-				    skb_shinfo(skb)->frags[i].page_offset,
-				    &head);
+				skb_frag_page(&skb_shinfo(skb)->frags[i]),
+				skb_frag_size(&skb_shinfo(skb)->frags[i]),
+				skb_shinfo(skb)->frags[i].page_offset,
+				0, &first);
 	}
 
 	return npo->meta_prod - old_meta_prod;
@@ -661,10 +669,6 @@ static void netbk_add_frag_responses(struct xenvif *vif, int status,
 	}
 }
 
-struct skb_cb_overlay {
-	int meta_slots_used;
-};
-
 static void xen_netbk_rx_action(struct xen_netbk *netbk)
 {
 	struct xenvif *vif = NULL, *tmp;
@@ -690,19 +694,26 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 	count = 0;
 
 	while ((skb = skb_dequeue(&netbk->rx_queue)) != NULL) {
+		RING_IDX old_rx_req_cons;
+ 
 		vif = netdev_priv(skb->dev);
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
+		old_rx_req_cons = vif->rx.req_cons;
 		sco = (struct skb_cb_overlay *)skb->cb;
 		sco->meta_slots_used = netbk_gop_skb(skb, &npo);
 
-		count += nr_frags + 1;
+		count += vif->rx.req_cons - old_rx_req_cons;
 
 		__skb_queue_tail(&rxq, skb);
 
+		skb = skb_peek(&netbk->rx_queue);
+		if (skb == NULL)
+			break;
+		sco = (struct skb_cb_overlay *) skb->cb;
+
 		/* Filled the batch queue? */
-		/* XXX FIXME: RX path dependent on MAX_SKB_FRAGS */
-		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
+		if (count + sco->peek_slots_count >= XEN_NETIF_RX_RING_SIZE)
 			break;
 	}
 
-- 
1.7.4.5
