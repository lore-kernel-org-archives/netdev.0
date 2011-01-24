From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH] pch_gbe: Fix the issue that the receiving data is not normal.
Date: Mon, 24 Jan 2011 13:43:31 +0900
Message-ID: <4D3D0373.30003@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>
To: ML netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:33070 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751892Ab1AXElZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 23:41:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This PCH_GBE driver had an issue that the receiving data is not normal.
This driver had not removed correctly the padding data 
which the DMA include in receiving data. 

This patch fixed this issue.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 03a1d28..1bf2626 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -29,6 +29,7 @@ const char pch_driver_version[] = DRV_VERSION;
 #define PCH_GBE_SHORT_PKT		64
 #define DSC_INIT16			0xC000
 #define PCH_GBE_DMA_ALIGN		0
+#define PCH_GBE_DMA_PADDING		2
 #define PCH_GBE_WATCHDOG_PERIOD		(1 * HZ)	/* watchdog time */
 #define PCH_GBE_COPYBREAK_DEFAULT	256
 #define PCH_GBE_PCI_BAR			1
@@ -1422,8 +1423,8 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			pr_err("Receive CRC Error\n");
 		} else {
 			/* get receive length */
-			/* length convert[-3], padding[-2] */
-			length = (rx_desc->rx_words_eob) - 3 - 2;
+			/* length convert[-3] */
+			length = (rx_desc->rx_words_eob) - 3;
 
 			/* Decide the data conversion method */
 			if (!adapter->rx_csum) {
@@ -1443,12 +1444,11 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			if (skb_copy_flag) {	/* recycle  skb */
 				struct sk_buff *new_skb;
 				new_skb =
-				    netdev_alloc_skb(netdev,
-						     length + NET_IP_ALIGN);
+				    netdev_alloc_skb(netdev, length);
 				if (new_skb) {
 					if (!skb_padding_flag) {
 						skb_reserve(new_skb,
-								NET_IP_ALIGN);
+							PCH_GBE_DMA_PADDING);
 					}
 					memcpy(new_skb->data, skb->data,
 						length);
@@ -1465,12 +1465,15 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			}
 			if (skb_padding_flag) {
 				memcpy(&tmp_packet[0], &skb->data[0], ETH_HLEN);
-				memcpy(&skb->data[NET_IP_ALIGN], &tmp_packet[0],
-					ETH_HLEN);
-				skb_reserve(skb, NET_IP_ALIGN);
-
+				memcpy(&skb->data[PCH_GBE_DMA_PADDING],
+				       &tmp_packet[0], ETH_HLEN);
+				skb_reserve(skb, PCH_GBE_DMA_PADDING);
+				/* The length includes padding length */
+				length = length - PCH_GBE_DMA_PADDING;
 			}
 
+			/* The length includes FCS length */
+			length = length - ETH_FCS_LEN;
 			/* update status of driver */
 			adapter->stats.rx_bytes += length;
 			adapter->stats.rx_packets++;
-- 
1.6.2.5
