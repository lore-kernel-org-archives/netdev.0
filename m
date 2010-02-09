From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 4/7] be2net: minor code optimizations
Date: Tue, 9 Feb 2010 17:04:21 +0530
Message-ID: <20100209113411.GA10498@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:63630 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793Ab0BILe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:34:27 -0500
Received: by iwn12 with SMTP id 12so8477086iwn.26
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 03:34:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of code optimizations in the Rx path (to avoid a memset).

From: Sathya P <sathyap@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f1136a3..107de6d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -635,9 +635,11 @@ get_rx_page_info(struct be_adapter *adapter, u16 frag_idx)
 	rx_page_info = &adapter->rx_obj.page_info_tbl[frag_idx];
 	BUG_ON(!rx_page_info->page);
 
-	if (rx_page_info->last_page_user)
+	if (rx_page_info->last_page_user) {
 		pci_unmap_page(adapter->pdev, pci_unmap_addr(rx_page_info, bus),
 			adapter->big_page_size, PCI_DMA_FROMDEVICE);
+		rx_page_info->last_page_user = false;
+	}
 
 	atomic_dec(&rxq->used);
 	return rx_page_info;
@@ -705,7 +707,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 		skb->data_len = curr_frag_len - hdr_len;
 		skb->tail += hdr_len;
 	}
-	memset(page_info, 0, sizeof(*page_info));
+	page_info->page = NULL;
 
 	if (pktsize <= rx_frag_size) {
 		BUG_ON(num_rcvd != 1);
@@ -738,7 +740,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 		skb->len += curr_frag_len;
 		skb->data_len += curr_frag_len;
 
-		memset(page_info, 0, sizeof(*page_info));
+		page_info->page = NULL;
 	}
 	BUG_ON(j > MAX_SKB_FRAGS);
 
-- 
1.6.3.3

