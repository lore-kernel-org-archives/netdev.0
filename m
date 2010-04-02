From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH 2/2] benet: fix the misusage of zero dma address
Date: Fri,  2 Apr 2010 11:53:23 +0900
Message-ID: <1270176803-8561-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp
To: sathyap@serverengines.com, subbus@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:48539 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759117Ab0DBC5C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 22:57:02 -0400
In-Reply-To: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

benet driver wrongly assumes that zero is an invalid dma address
(calls dma_unmap_page for only non zero dma addresses). Zero is a
valid dma address on some architectures. The dma length can be used
here.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/benet/be_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 8d5e27b..8828c7d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -394,13 +394,15 @@ static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
 	be_dws_le_to_cpu(wrb, sizeof(*wrb));
 
 	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
-	if (dma != 0) {
+	if (wrb->frag_len) {
 		if (unmap_single)
 			pci_unmap_single(pdev, dma, wrb->frag_len,
 				PCI_DMA_TODEVICE);
 		else
 			pci_unmap_page(pdev, dma, wrb->frag_len,
 				PCI_DMA_TODEVICE);
+
+		wrb->frag_len = 0;
 	}
 }
 
@@ -466,9 +468,9 @@ dma_err:
 	txq->head = map_head;
 	while (copied) {
 		wrb = queue_head_node(txq);
+		copied -= wrb->frag_len;
 		unmap_tx_frag(pdev, wrb, map_single);
 		map_single = false;
-		copied -= wrb->frag_len;
 		queue_head_inc(txq);
 	}
 	return 0;
-- 
1.7.0

