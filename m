From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 09/18] e1000: Remove unneeded and unwanted memsets
Date: Wed, 01 Nov 2006 09:51:49 -0800
Message-ID: <20061101175148.2356.73152.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:19216 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946970AbWKARoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:39 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This memsetting was added in a paranoid rage debugging TX hangs, but
are no longer of importance. We can beef up the performance quite a
bit removing them. Make sure to fill in next_to_watch to allow this.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000/e1000_main.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7f3d243..2cd5009 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1993,10 +1993,13 @@ e1000_unmap_and_free_tx_resource(struct 
 				buffer_info->dma,
 				buffer_info->length,
 				PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
 	}
-	if (buffer_info->skb)
+	if (buffer_info->skb) {
 		dev_kfree_skb_any(buffer_info->skb);
-	memset(buffer_info, 0, sizeof(struct e1000_buffer));
+		buffer_info->skb = NULL;
+	}
+	/* buffer_info must be completely set up in the transmit path */
 }
 
 /**
@@ -2661,6 +2664,7 @@ e1000_tso(struct e1000_adapter *adapter,
 		context_desc->cmd_and_length = cpu_to_le32(cmd_length);
 
 		buffer_info->time_stamp = jiffies;
+		buffer_info->next_to_watch = i;
 
 		if (++i == tx_ring->count) i = 0;
 		tx_ring->next_to_use = i;
@@ -2695,6 +2699,7 @@ e1000_tx_csum(struct e1000_adapter *adap
 		context_desc->cmd_and_length = cpu_to_le32(E1000_TXD_CMD_DEXT);
 
 		buffer_info->time_stamp = jiffies;
+		buffer_info->next_to_watch = i;
 
 		if (unlikely(++i == tx_ring->count)) i = 0;
 		tx_ring->next_to_use = i;
@@ -2763,6 +2768,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 				size,
 				PCI_DMA_TODEVICE);
 		buffer_info->time_stamp = jiffies;
+		buffer_info->next_to_watch = i;
 
 		len -= size;
 		offset += size;
@@ -2802,6 +2808,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 					size,
 					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp = jiffies;
+			buffer_info->next_to_watch = i;
 
 			len -= size;
 			offset += size;
@@ -3620,7 +3627,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			cleaned = (i == eop);
 
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
-			memset(tx_desc, 0, sizeof(struct e1000_tx_desc));
+			tx_desc->upper.data = 0;
 
 			if (unlikely(++i == tx_ring->count)) i = 0;
 		}



---
Auke Kok <auke-jan.h.kok@intel.com>
