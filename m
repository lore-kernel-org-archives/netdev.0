From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH] be2net: fix bug in rx page posting
Date: Thu, 21 Jan 2010 17:26:17 +0530
Message-ID: <20100121115617.GA29213@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29048 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752894Ab0AUL4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 06:56:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pages are posted to the rxq in such a way that more than one frag
can share the page. The last frag that uses the page unmaps the
page.  In the case when a page is not fully used (due to lack of space in rxq)
the last frag that uses the page is not being set as a "last_page_user";
instead, the next frag in the rxq is incorrectly being set.

The fix has also been tested on ppc64 with 64k pages...

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 3a1f790..33ab8c7 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -910,7 +910,7 @@ static inline struct page *be_alloc_pages(u32 size)
 static void be_post_rx_frags(struct be_adapter *adapter)
 {
 	struct be_rx_page_info *page_info_tbl = adapter->rx_obj.page_info_tbl;
-	struct be_rx_page_info *page_info = NULL;
+	struct be_rx_page_info *page_info = NULL, *prev_page_info = NULL;
 	struct be_queue_info *rxq = &adapter->rx_obj.q;
 	struct page *pagep = NULL;
 	struct be_eth_rx_d *rxd;
@@ -941,7 +941,6 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 		rxd = queue_head_node(rxq);
 		rxd->fragpa_lo = cpu_to_le32(frag_dmaaddr & 0xFFFFFFFF);
 		rxd->fragpa_hi = cpu_to_le32(upper_32_bits(frag_dmaaddr));
-		queue_head_inc(rxq);
 
 		/* Any space left in the current big page for another frag? */
 		if ((page_offset + rx_frag_size + rx_frag_size) >
@@ -949,10 +948,13 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 			pagep = NULL;
 			page_info->last_page_user = true;
 		}
+
+		prev_page_info = page_info;
+		queue_head_inc(rxq);
 		page_info = &page_info_tbl[rxq->head];
 	}
 	if (pagep)
-		page_info->last_page_user = true;
+		prev_page_info->last_page_user = true;
 
 	if (posted) {
 		atomic_add(posted, &rxq->used);
-- 
1.6.3.3

