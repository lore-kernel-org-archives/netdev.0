From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] e100: fix dma error in direction for mapping
Date: Fri, 14 Nov 2008 15:51:54 -0800
Message-ID: <20081114235154.13239.11435.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Russell King <linux@arm.linux.org.uk>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:37462 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751204AbYKNXwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 18:52:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The e100 driver triggers BUG_ON(buf->direction != dir)
by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).

Changing the DMA direction, especially with dmabounce will result
in unexpected behaviour.

Reported-by: Anders Grafstrom <grfstrm@users.sourceforge.net>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Russell King <linux@arm.linux.org.uk>
---

 drivers/net/e100.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 62cdefa..c9c7079 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -166,7 +166,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.5.23-k4"DRV_EXT
+#define DRV_VERSION		"3.5.23-k6"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -1804,7 +1804,7 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
 		put_unaligned_le32(rx->dma_addr, &prev_rfd->link);
 		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
-			sizeof(struct rfd), PCI_DMA_TODEVICE);
+			sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
 	}
 
 	return 0;
@@ -1823,7 +1823,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 
 	/* Need to sync before taking a peek at cb_complete bit */
 	pci_dma_sync_single_for_cpu(nic->pdev, rx->dma_addr,
-		sizeof(struct rfd), PCI_DMA_FROMDEVICE);
+		sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
 	rfd_status = le16_to_cpu(rfd->status);
 
 	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
@@ -1850,7 +1850,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 
 	/* Get data */
 	pci_unmap_single(nic->pdev, rx->dma_addr,
-		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 
 	/* If this buffer has the el bit, but we think the receiver
 	 * is still running, check to see if it really stopped while
@@ -1942,7 +1942,7 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 		new_before_last_rfd->command |= cpu_to_le16(cb_el);
 		pci_dma_sync_single_for_device(nic->pdev,
 			new_before_last_rx->dma_addr, sizeof(struct rfd),
-			PCI_DMA_TODEVICE);
+			PCI_DMA_BIDIRECTIONAL);
 
 		/* Now that we have a new stopping point, we can clear the old
 		 * stopping point.  We must sync twice to get the proper
@@ -1950,11 +1950,11 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 		old_before_last_rfd->command &= ~cpu_to_le16(cb_el);
 		pci_dma_sync_single_for_device(nic->pdev,
 			old_before_last_rx->dma_addr, sizeof(struct rfd),
-			PCI_DMA_TODEVICE);
+			PCI_DMA_BIDIRECTIONAL);
 		old_before_last_rfd->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
 		pci_dma_sync_single_for_device(nic->pdev,
 			old_before_last_rx->dma_addr, sizeof(struct rfd),
-			PCI_DMA_TODEVICE);
+			PCI_DMA_BIDIRECTIONAL);
 	}
 
 	if(restart_required) {
@@ -1977,7 +1977,7 @@ static void e100_rx_clean_list(struct nic *nic)
 		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
 			if(rx->skb) {
 				pci_unmap_single(nic->pdev, rx->dma_addr,
-					RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+					RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 				dev_kfree_skb(rx->skb);
 			}
 		}
@@ -2020,7 +2020,7 @@ static int e100_rx_alloc_list(struct nic *nic)
 	before_last->command |= cpu_to_le16(cb_el);
 	before_last->size = 0;
 	pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
-		sizeof(struct rfd), PCI_DMA_TODEVICE);
+		sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
 
 	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
 	nic->ru_running = RU_SUSPENDED;
@@ -2221,7 +2221,7 @@ static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)
 	msleep(10);
 
 	pci_dma_sync_single_for_cpu(nic->pdev, nic->rx_to_clean->dma_addr,
-			RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+			RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 
 	if(memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
 	   skb->data, ETH_DATA_LEN))

