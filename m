From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 4/4] e1000e: Not initialize the e1000_ps_page array when packet-split is not used
Date: Mon, 20 May 2013 16:15:07 +0800
Message-ID: <1369037707-27026-5-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:51976 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab3ETIPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 04:15:33 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 21 May 2013 05:12:57 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 590882BB0051
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:28 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4K81MsI20185324
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:01:22 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4K8FRrW029296
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:27 +1000
In-Reply-To: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When packet split is not used, those fields are still initialized and memory
is allocated for them.

This patch check whether packet split is used and do the initialization base
on the status.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   38 ++++++++++++++-------------
 1 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a2e8a53..c75d9cf 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1690,15 +1690,17 @@ static void e1000_clean_rx_ring(struct e1000_ring *rx_ring)
 			buffer_info->skb = NULL;
 		}
 
-		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
-			ps_page = &buffer_info->ps_pages[j];
-			if (!ps_page->page)
-				break;
-			dma_unmap_page(&pdev->dev, ps_page->dma, PAGE_SIZE,
-				       DMA_FROM_DEVICE);
-			ps_page->dma = 0;
-			put_page(ps_page->page);
-			ps_page->page = NULL;
+		if (adapter->rx_ps_pages) {
+			for (j = 0; j < PS_PAGE_BUFFERS; j++) {
+				ps_page = &buffer_info->ps_pages[j];
+				if (!ps_page->page)
+					break;
+				dma_unmap_page(&pdev->dev, ps_page->dma, PAGE_SIZE,
+					       DMA_FROM_DEVICE);
+				ps_page->dma = 0;
+				put_page(ps_page->page);
+				ps_page->page = NULL;
+			}
 		}
 	}
 
@@ -2355,16 +2357,16 @@ int e1000e_setup_rx_resources(struct e1000_ring *rx_ring)
 	if (!rx_ring->buffer_info)
 		goto err;
 
-	for (i = 0; i < rx_ring->count; i++) {
-		buffer_info = &rx_ring->buffer_info[i];
-		buffer_info->ps_pages = kcalloc(PS_PAGE_BUFFERS,
-						sizeof(struct e1000_ps_page),
-						GFP_KERNEL);
-		if (!buffer_info->ps_pages)
-			goto err_pages;
-	}
-
 	if (adapter->rx_ps_pages) {
+		for (i = 0; i < rx_ring->count; i++) {
+			buffer_info = &rx_ring->buffer_info[i];
+			buffer_info->ps_pages = kcalloc(PS_PAGE_BUFFERS,
+							sizeof(struct e1000_ps_page),
+							GFP_KERNEL);
+			if (!buffer_info->ps_pages)
+				goto err_pages;
+		}
+
 		/* this is a 32 byte descriptor */
 		desc_len = sizeof(union e1000_rx_desc_packet_split);
 	} else {
-- 
1.7.5.4
