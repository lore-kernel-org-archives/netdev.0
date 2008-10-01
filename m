From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] ixgb: fix bug when freeing resources
Date: Wed, 01 Oct 2008 14:59:27 -0700
Message-ID: <20081001215927.21799.53359.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:46136 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752297AbYJAV7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 17:59:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

It was pointed out by Breno Leitao <leitao@linux.vnet.ibm.com> that
ixgb would crash on PPC when an IOMMU was in use, if change_mtu was
called.

It appears to be a pretty simple issue in the driver that wasn't discovered
because most systems don't run with an IOMMU.  The driver needs to only unmap
buffers that are mapped (duh).

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Breno Leitao <leitao@linux.vnet.ibm.com>
---

 drivers/net/ixgb/ixgb_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index aa75385..be3c7dc 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -977,15 +977,17 @@ ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
 
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if (buffer_info->skb) {
-
+		if (buffer_info->dma) {
 			pci_unmap_single(pdev,
 					 buffer_info->dma,
 					 buffer_info->length,
 					 PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
+			buffer_info->length = 0;
+		}
 
+		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
-
 			buffer_info->skb = NULL;
 		}
 	}

