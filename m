From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/9] ixgb: fix rare early tso completion
Date: Tue, 23 May 2006 11:04:05 -0700
Message-ID: <20060523180404.17428.25893.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:38661 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932107AbWEWR7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:07 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix rare early completion when using TSO.  This essentially is the
e1000 fix, with code that was mostly already written. Another skb frag
was also needed.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index cfd67d8..13181c4 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1266,6 +1266,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	struct ixgb_buffer *buffer_info;
 	int len = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
+	unsigned int mss = skb_shinfo(skb)->tso_size;
 
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
@@ -1277,6 +1278,11 @@ ixgb_tx_map(struct ixgb_adapter *adapter
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
@@ -1301,6 +1307,12 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
+			/* Workaround for premature desc write-backs
+			 * in TSO mode.  Append 4-byte sentinel desc */
+			if(unlikely(mss && (f == (nr_frags-1)) && (size == len)
+			            && (size > 8)))
+				size -= 4;
+
 			buffer_info->length = size;
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,
@@ -1378,7 +1390,8 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 #define TXD_USE_COUNT(S) (((S) >> IXGB_MAX_TXD_PWR) + \
 			 (((S) & (IXGB_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
 #define DESC_NEEDED TXD_USE_COUNT(IXGB_MAX_DATA_PER_TXD) + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1 \
+	/* one more for TSO workaround */ + 1
 
 static int
 ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -1416,7 +1429,7 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 		return NETDEV_TX_OK;
 	}
 
-	if (tso)
+	if (likely(tso))
 		tx_flags |= IXGB_TX_FLAGS_TSO;
 	else if(ixgb_tx_csum(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_CSUM;



--
Auke Kok <auke-jan.h.kok@intel.com>
