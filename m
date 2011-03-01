From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] benet: use GFP_KERNEL allocations when
 possible
Date: Tue, 01 Mar 2011 16:48:12 +0100
Message-ID: <1298994492.3284.112.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47820 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756774Ab1CAPtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 10:49:11 -0500
Received: by fxm17 with SMTP id 17so4931008fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 07:49:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend be_alloc_pages() with a gfp parameter, so that we use GFP_KERNEL
allocations instead of GFP_ATOMIC when not running in softirq context.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/benet/be_main.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 0bdccb1..ef66dc6 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1169,20 +1169,20 @@ static inline void be_rx_compl_reset(struct be_eth_rx_compl *rxcp)
 	rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] = 0;
 }
 
-static inline struct page *be_alloc_pages(u32 size)
+static inline struct page *be_alloc_pages(u32 size, gfp_t gfp)
 {
-	gfp_t alloc_flags = GFP_ATOMIC;
 	u32 order = get_order(size);
+
 	if (order > 0)
-		alloc_flags |= __GFP_COMP;
-	return  alloc_pages(alloc_flags, order);
+		gfp |= __GFP_COMP;
+	return  alloc_pages(gfp, order);
 }
 
 /*
  * Allocate a page, split it to fragments of size rx_frag_size and post as
  * receive buffers to BE
  */
-static void be_post_rx_frags(struct be_rx_obj *rxo)
+static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 {
 	struct be_adapter *adapter = rxo->adapter;
 	struct be_rx_page_info *page_info_tbl = rxo->page_info_tbl;
@@ -1196,7 +1196,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo)
 	page_info = &rxo->page_info_tbl[rxq->head];
 	for (posted = 0; posted < MAX_RX_POST && !page_info->page; posted++) {
 		if (!pagep) {
-			pagep = be_alloc_pages(adapter->big_page_size);
+			pagep = be_alloc_pages(adapter->big_page_size, gfp);
 			if (unlikely(!pagep)) {
 				rxo->stats.rx_post_fail++;
 				break;
@@ -1753,7 +1753,7 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 
 	/* Refill the queue */
 	if (atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM)
-		be_post_rx_frags(rxo);
+		be_post_rx_frags(rxo, GFP_ATOMIC);
 
 	/* All consumed */
 	if (work_done < budget) {
@@ -1890,7 +1890,7 @@ static void be_worker(struct work_struct *work)
 
 		if (rxo->rx_post_starved) {
 			rxo->rx_post_starved = false;
-			be_post_rx_frags(rxo);
+			be_post_rx_frags(rxo, GFP_KERNEL);
 		}
 	}
 	if (!adapter->ue_detected && !lancer_chip(adapter))
@@ -2138,7 +2138,7 @@ static int be_open(struct net_device *netdev)
 	u16 link_speed;
 
 	for_all_rx_queues(adapter, rxo, i) {
-		be_post_rx_frags(rxo);
+		be_post_rx_frags(rxo, GFP_KERNEL);
 		napi_enable(&rxo->rx_eq.napi);
 	}
 	napi_enable(&tx_eq->napi);


