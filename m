From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 01/22] e1000: Fix early TSO completion
Date: Fri, 08 Dec 2006 15:02:46 -0800
Message-ID: <20061208230246.30109.2309.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4352 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761253AbWLHWwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:52:04 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This fix was already merged in commit 96f9c2e277768099479fbed7c3b69c294b1fadef
but reverted in commit 989316ddfeafd0e8fb51a4d811383769ad62637a. After
stresstesting we found that the fix does not add new regressions and
works around a TX hang spotted by several users.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index e628126..ebc9d71 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1287,6 +1287,9 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	struct ixgb_buffer *buffer_info;
 	int len = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
+#ifdef NETIF_F_TSO
+	unsigned int mss = skb_shinfo(skb)->gso_size;
+#endif
 
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
@@ -1298,6 +1301,12 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 	while(len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_DATA_PER_TXD);
+#ifdef NETIF_F_TSO
+		/* Workaround for premature desc write-backs
+		 * in TSO mode.  Append 4-byte sentinel desc */
+		if (unlikely(mss && !nr_frags && size == len && size > 8))
+			size -= 4;
+#endif
 		buffer_info->length = size;
 		WARN_ON(buffer_info->dma != 0);
 		buffer_info->dma =
@@ -1324,6 +1333,13 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_DATA_PER_TXD);
+#ifdef NETIF_F_TSO
+			/* Workaround for premature desc write-backs
+			 * in TSO mode.  Append 4-byte sentinel desc */
+			if (unlikely(mss && !nr_frags && size == len
+			             && size > 8))
+				size -= 4;
+#endif
 			buffer_info->length = size;
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,
@@ -1401,8 +1417,9 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) (((S) >> IXGB_MAX_TXD_PWR) + \
 			 (((S) & (IXGB_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
-#define DESC_NEEDED TXD_USE_COUNT(IXGB_MAX_DATA_PER_TXD) + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1
+#define DESC_NEEDED TXD_USE_COUNT(IXGB_MAX_DATA_PER_TXD) /* skb->date */ + \
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1 /* for context */ \
+	+ 1 /* one more needed for sentinel TSO workaround */
 
 static int
 ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)



---
Auke Kok <auke-jan.h.kok@intel.com>
