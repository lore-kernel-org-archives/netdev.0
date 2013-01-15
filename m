From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 10/10] vmxnet3: better RSS support
Date: Tue, 15 Jan 2013 09:28:35 -0800
Message-ID: <1358270915-32758-11-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:60902 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756859Ab3AORaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:22 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so233306pad.17
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:22 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VMXNET3 device provides RSS hash value for received packets,
but it is not being used.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 9777dc6..b1c90f8 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1226,6 +1226,11 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			pci_unmap_single(adapter->pdev, rbi->dma_addr, rbi->len,
 					 PCI_DMA_FROMDEVICE);
 
+#ifdef VMXNET3_RSS
+			if (rcd->rssType != VMXNET3_RCD_RSS_TYPE_NONE &&
+			    (adapter->netdev->features & NETIF_F_RXHASH))
+				ctx->skb->rxhash = le32_to_cpu(rcd->rssHash);
+#endif
 			skb_put(ctx->skb, rcd->len);
 
 			/* Immediate refill */
@@ -3022,6 +3027,8 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	if (adapter->num_rx_queues > 1 &&
 	    adapter->intr.type == VMXNET3_IT_MSIX) {
 		adapter->rss = true;
+		netdev->hw_features |= NETIF_F_RXHASH;
+		netdev->features |= NETIF_F_RXHASH;
 		dev_dbg(&pdev->dev, "RSS is enabled.\n");
 	} else {
 		adapter->rss = false;
-- 
1.7.10.4
