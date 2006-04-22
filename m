From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 06/11] ixgb: Fix TSO
Date: Fri, 21 Apr 2006 18:00:43 -0700
Message-ID: <20060422010043.24255.8531.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:12718 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750812AbWDVA5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:38 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- this fixes an issue of premature desc writeback by hardware

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 93a518f..9d262c8 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1280,6 +1280,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	struct ixgb_buffer *buffer_info;
 	int len = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
+	unsigned int mss = skb_shinfo(skb)->tso_size;
 
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
@@ -1291,6 +1292,11 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	while(len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
+		/* Workaround for premature desc write-backs
+		 * in TSO mode.  Append 4-byte sentinel desc */
+		if(unlikely(mss && !nr_frags && size == len && size > 8))
+			size -= 4;
+
 		buffer_info->length = size;
 		buffer_info->dma =
 			pci_map_single(adapter->pdev,
@@ -1315,6 +1321,12 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
+			/* Workaround for premature desc write-backs
+			 * in TSO mode.  Append 4-byte sentinel desc */
+			if(unlikely(mss && (f == (nr_frags-1)) && (size == len)
+						&& (size > 8)))
+				size -= 4;
+
 			buffer_info->length = size;
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,
@@ -1392,7 +1404,8 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 #define TXD_USE_COUNT(S) (((S) >> IXGB_MAX_TXD_PWR) + \
 			 (((S) & (IXGB_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
 #define DESC_NEEDED TXD_USE_COUNT(IXGB_MAX_DATA_PER_TXD) + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1 \
+	/* one more for TSO workaround */ + 1
 
 static int
 ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -1430,7 +1443,7 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 		return NETDEV_TX_OK;
 	}
 
-	if (tso)
+	if (likely(tso))
 		tx_flags |= IXGB_TX_FLAGS_TSO;
 	else if(ixgb_tx_csum(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_CSUM;

