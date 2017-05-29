From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] netvsc: optimize calculation of number of slots
Date: Mon, 29 May 2017 11:31:57 -0700
Message-ID: <20170529183159.22205-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35844 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdE2ScE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 14:32:04 -0400
Received: by mail-pf0-f178.google.com with SMTP id m17so51139481pfg.3
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 11:32:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speed up transmit check for fragmented packets by using existing
macros to compute number of pages, and eliminate loop since
each skb fragment is only one page.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 43 ++++++++++-------------------------------
 1 file changed, 10 insertions(+), 33 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4421a6d00375..548c78863ce9 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -343,34 +343,14 @@ static u32 init_page_array(void *hdr, u32 len, struct sk_buff *skb,
 	return slots_used;
 }
 
-static int count_skb_frag_slots(struct sk_buff *skb)
-{
-	int i, frags = skb_shinfo(skb)->nr_frags;
-	int pages = 0;
-
-	for (i = 0; i < frags; i++) {
-		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
-		unsigned long size = skb_frag_size(frag);
-		unsigned long offset = frag->page_offset;
-
-		/* Skip unused frames from start of page */
-		offset &= ~PAGE_MASK;
-		pages += PFN_UP(offset + size);
-	}
-	return pages;
-}
-
-static int netvsc_get_slots(struct sk_buff *skb)
+/* Estimate number of page buffers neede to transmit
+ * Need at most 2 for RNDIS header plus skb body and fragments.
+ */
+static unsigned int netvsc_get_slots(const struct sk_buff *skb)
 {
-	char *data = skb->data;
-	unsigned int offset = offset_in_page(data);
-	unsigned int len = skb_headlen(skb);
-	int slots;
-	int frag_slots;
-
-	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE);
-	frag_slots = count_skb_frag_slots(skb);
-	return slots + frag_slots;
+	return PFN_UP(offset_in_page(skb->data)+ skb_headlen(skb))
+		+ skb_shinfo(skb)->nr_frags
+		+ 2;
 }
 
 static u32 net_checksum_info(struct sk_buff *skb)
@@ -408,21 +388,18 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
 	struct hv_page_buffer *pb = page_buf;
 
-	/* We will atmost need two pages to describe the rndis
-	 * header. We can only transmit MAX_PAGE_BUFFER_COUNT number
+	/* We can only transmit MAX_PAGE_BUFFER_COUNT number
 	 * of pages in a single packet. If skb is scattered around
 	 * more pages we try linearizing it.
 	 */
-
-	num_data_pgs = netvsc_get_slots(skb) + 2;
-
+	num_data_pgs = netvsc_get_slots(skb);
 	if (unlikely(num_data_pgs > MAX_PAGE_BUFFER_COUNT)) {
 		++net_device_ctx->eth_stats.tx_scattered;
 
 		if (skb_linearize(skb))
 			goto no_memory;
 
-		num_data_pgs = netvsc_get_slots(skb) + 2;
+		num_data_pgs = netvsc_get_slots(skb);
 		if (num_data_pgs > MAX_PAGE_BUFFER_COUNT) {
 			++net_device_ctx->eth_stats.tx_too_big;
 			goto drop;
-- 
2.11.0
