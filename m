From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] e100: Release skb when DMA mapping is failed in e100_xmit_prepare
Date: Tue, 18 Aug 2015 14:09:15 -0700
Message-ID: <1439932162-1995-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17210 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbbHRVJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:30 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>

When pci_dma_mapping_error in e100_xmit_prepare is failed, the skb buffer
allocated by netdev_alloc_skb_ip_align in e100_rx_alloc_skb is not
released, which causes a possible resource leak.
This patch adds error handling code to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 767c161..068789e 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1770,8 +1770,11 @@ static int e100_xmit_prepare(struct nic *nic, struct cb *cb,
 	dma_addr = pci_map_single(nic->pdev,
 				  skb->data, skb->len, PCI_DMA_TODEVICE);
 	/* If we can't map the skb, have the upper layer try later */
-	if (pci_dma_mapping_error(nic->pdev, dma_addr))
+	if (pci_dma_mapping_error(nic->pdev, dma_addr)) {
+		dev_kfree_skb_any(skb);
+		skb = NULL;
 		return -ENOMEM;
+	}
 
 	/*
 	 * Use the last 4 bytes of the SKB payload packet as the CRC, used for
-- 
2.4.3
