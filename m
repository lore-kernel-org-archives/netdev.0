From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/9] ixgb: revert an unwanted fix regarding tso/descriptors
Date: Fri, 26 May 2006 09:52:00 -0700
Message-ID: <20060526165200.30514.86901.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:30470 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751130AbWEZQq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:46:56 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There seemed to be another bug introduced as well as a performance hit
with the addtion of the sentinel descriptor workaround.  Removal of
this workaround appears to prevent the hang.  We'll take a risk
and remove it, as we had never seen the originally reported bug
under linux.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 26c777f..5561ab6 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1295,7 +1295,6 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	struct ixgb_buffer *buffer_info;
 	int len = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
-	unsigned int mss = skb_shinfo(skb)->tso_size;
 
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
@@ -1307,11 +1306,6 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	while(len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
-		/* Workaround for premature desc write-backs
-		 * in TSO mode.  Append 4-byte sentinel desc */
-		if(unlikely(mss && !nr_frags && size == len && size > 8))
-			size -= 4;
-
 		buffer_info->length = size;
 		buffer_info->dma =
 			pci_map_single(adapter->pdev,
@@ -1337,12 +1331,6 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
-			/* Workaround for premature desc write-backs
-			 * in TSO mode.  Append 4-byte sentinel desc */
-			if(unlikely(mss && (f == (nr_frags-1)) && (size == len)
-			            && (size > 8)))
-				size -= 4;
-
 			buffer_info->length = size;
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,
@@ -1421,8 +1409,7 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 #define TXD_USE_COUNT(S) (((S) >> IXGB_MAX_TXD_PWR) + \
 			 (((S) & (IXGB_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
 #define DESC_NEEDED TXD_USE_COUNT(IXGB_MAX_DATA_PER_TXD) + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1 \
-	/* one more for TSO workaround */ + 1
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1
 
 static int
 ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)



--
Auke Kok <auke-jan.h.kok@intel.com>
