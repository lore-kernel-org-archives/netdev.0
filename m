From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH v3] pch_gbe: Fix the issue that the receiving data is not
 normal.
Date: Wed, 09 Feb 2011 17:15:59 +0900
Message-ID: <4D524D3F.70906@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomoya Morinaga <tomoya-linux@dsn.okisemi.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>
To: ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Devid

I resubmit this patch modified.

 - The memmove() function was used instead of memcpy() + memcpy().
 - Rx packets processing was arranged to four case. 

Please check them.

Best regards
Toshiharu Okada(OKI semiconductor)
---
This PCH_GBE driver had an issue that the receiving data is not normal.
This driver had not removed correctly the padding data 
which the DMA include in receiving data. 

This patch fixed this issue.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |   97 ++++++++++++++++++++---------------
 1 files changed, 55 insertions(+), 42 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 03a1d28..76a31b0 100644
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
@@ -1369,16 +1370,13 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 	struct pch_gbe_buffer *buffer_info;
 	struct pch_gbe_rx_desc *rx_desc;
 	u32 length;
-	unsigned char tmp_packet[ETH_HLEN];
 	unsigned int i;
 	unsigned int cleaned_count = 0;
 	bool cleaned = false;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *new_skb;
 	u8 dma_status;
 	u16 gbec_status;
 	u32 tcp_ip_status;
-	u8 skb_copy_flag = 0;
-	u8 skb_padding_flag = 0;
 
 	i = rx_ring->next_to_clean;
 
@@ -1422,55 +1420,70 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			pr_err("Receive CRC Error\n");
 		} else {
 			/* get receive length */
-			/* length convert[-3], padding[-2] */
-			length = (rx_desc->rx_words_eob) - 3 - 2;
+			/* length convert[-3] */
+			length = (rx_desc->rx_words_eob) - 3;
 
 			/* Decide the data conversion method */
 			if (!adapter->rx_csum) {
 				/* [Header:14][payload] */
-				skb_padding_flag = 0;
-				skb_copy_flag = 1;
+				if (NET_IP_ALIGN) {
+					/* Because alignment differs,
+					 * the new_skb is newly allocated,
+					 * and data is copied to new_skb.*/
+					new_skb = netdev_alloc_skb(netdev,
+							 length + NET_IP_ALIGN);
+					if (!new_skb) {
+						/* dorrop error */
+						pr_err("New skb allocation "
+							"Error\n");
+						goto dorrop;
+					}
+					skb_reserve(new_skb, NET_IP_ALIGN);
+					memcpy(new_skb->data, skb->data,
+					       length);
+					skb = new_skb;
+				} else {
+					/* DMA buffer is used as SKB as it is.*/
+					buffer_info->skb = NULL;
+				}
 			} else {
 				/* [Header:14][padding:2][payload] */
-				skb_padding_flag = 1;
-				if (length < copybreak)
-					skb_copy_flag = 1;
-				else
-					skb_copy_flag = 0;
-			}
-
-			/* Data conversion */
-			if (skb_copy_flag) {	/* recycle  skb */
-				struct sk_buff *new_skb;
-				new_skb =
-				    netdev_alloc_skb(netdev,
-						     length + NET_IP_ALIGN);
-				if (new_skb) {
-					if (!skb_padding_flag) {
-						skb_reserve(new_skb,
-								NET_IP_ALIGN);
+				/* The length includes padding length */
+				length = length - PCH_GBE_DMA_PADDING;
+				if ((length < copybreak) ||
+				    (NET_IP_ALIGN != PCH_GBE_DMA_PADDING)) {
+					/* Because alignment differs,
+					 * the new_skb is newly allocated,
+					 * and data is copied to new_skb.
+					 * Padding data is deleted
+					 * at the time of a copy.*/
+					new_skb = netdev_alloc_skb(netdev,
+							 length + NET_IP_ALIGN);
+					if (!new_skb) {
+						/* dorrop error */
+						pr_err("New skb allocation "
+							"Error\n");
+						goto dorrop;
 					}
+					skb_reserve(new_skb, NET_IP_ALIGN);
 					memcpy(new_skb->data, skb->data,
-						length);
-					/* save the skb
-					 * in buffer_info as good */
+					       ETH_HLEN);
+					memcpy(&new_skb->data[ETH_HLEN],
+					       &skb->data[ETH_HLEN +
+					       PCH_GBE_DMA_PADDING],
+					       length - ETH_HLEN);
 					skb = new_skb;
-				} else if (!skb_padding_flag) {
-					/* dorrop error */
-					pr_err("New skb allocation Error\n");
-					goto dorrop;
+				} else {
+					/* Padding data is deleted
+					 * by moving header data.*/
+					memmove(&skb->data[PCH_GBE_DMA_PADDING],
+						&skb->data[0], ETH_HLEN);
+					skb_reserve(skb, NET_IP_ALIGN);
+					buffer_info->skb = NULL;
 				}
-			} else {
-				buffer_info->skb = NULL;
 			}
-			if (skb_padding_flag) {
-				memcpy(&tmp_packet[0], &skb->data[0], ETH_HLEN);
-				memcpy(&skb->data[NET_IP_ALIGN], &tmp_packet[0],
-					ETH_HLEN);
-				skb_reserve(skb, NET_IP_ALIGN);
-
-			}
-
+			/* The length includes FCS length */
+			length = length - ETH_FCS_LEN;
 			/* update status of driver */
 			adapter->stats.rx_bytes += length;
 			adapter->stats.rx_packets++;
-- 
1.6.2.5
