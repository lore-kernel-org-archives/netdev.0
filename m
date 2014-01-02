From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 3/6] r8152: change some definitions
Date: Thu, 2 Jan 2014 11:22:41 +0800
Message-ID: <1388632963-1341-4-git-send-email-hayeswang@realtek.com>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
 <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace RX_BUF_THR with RX_THR_HIGH.
Replace RWSUME_INDICATE with RESUME_INDICATE.
Add CRC_SIZE, TX_ALIGN, and RX_ALIGN.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b8bc3eb..85862a8 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -209,7 +209,7 @@
 #define TX_AGG_MAX_THRESHOLD	0x03
 
 /* USB_RX_BUF_TH */
-#define RX_BUF_THR		0x7a120180
+#define RX_THR_HIGH		0x7a120180
 
 /* USB_TX_DMA */
 #define TEST_MODE_DISABLE	0x00000001
@@ -219,7 +219,7 @@
 #define POWER_CUT		0x0100
 
 /* USB_PM_CTRL_STATUS */
-#define RWSUME_INDICATE		0x0001
+#define RESUME_INDICATE		0x0001
 
 /* USB_USB_CTRL */
 #define RX_AGG_DISABLE		0x0010
@@ -274,6 +274,9 @@ enum rtl_register_content {
 #define RTL8152_MAX_TX		10
 #define RTL8152_MAX_RX		10
 #define INTBUFSIZE		2
+#define CRC_SIZE		4
+#define TX_ALIGN		4
+#define RX_ALIGN		8
 
 #define INTR_LINK		0x0004
 
@@ -916,12 +919,12 @@ resubmit:
 
 static inline void *rx_agg_align(void *data)
 {
-	return (void *)ALIGN((uintptr_t)data, 8);
+	return (void *)ALIGN((uintptr_t)data, RX_ALIGN);
 }
 
 static inline void *tx_agg_align(void *data)
 {
-	return (void *)ALIGN((uintptr_t)data, 4);
+	return (void *)ALIGN((uintptr_t)data, TX_ALIGN);
 }
 
 static void free_all_mem(struct r8152 *tp)
@@ -990,7 +993,8 @@ static int alloc_all_mem(struct r8152 *tp)
 
 		if (buf != rx_agg_align(buf)) {
 			kfree(buf);
-			buf = kmalloc_node(rx_buf_sz + 8, GFP_KERNEL, node);
+			buf = kmalloc_node(rx_buf_sz + RX_ALIGN, GFP_KERNEL,
+					   node);
 			if (!buf)
 				goto err1;
 		}
@@ -1015,7 +1019,8 @@ static int alloc_all_mem(struct r8152 *tp)
 
 		if (buf != tx_agg_align(buf)) {
 			kfree(buf);
-			buf = kmalloc_node(rx_buf_sz + 4, GFP_KERNEL, node);
+			buf = kmalloc_node(rx_buf_sz + TX_ALIGN, GFP_KERNEL,
+					   node);
 			if (!buf)
 				goto err1;
 		}
@@ -1215,7 +1220,7 @@ static void rx_bottom(struct r8152 *tp)
 
 			stats = rtl8152_get_stats(netdev);
 
-			pkt_len -= 4; /* CRC */
+			pkt_len -= CRC_SIZE;
 			rx_data += sizeof(struct rx_desc);
 
 			skb = netdev_alloc_skb_ip_align(netdev, pkt_len);
@@ -1230,7 +1235,7 @@ static void rx_bottom(struct r8152 *tp)
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_len;
 
-			rx_data = rx_agg_align(rx_data + pkt_len + 4);
+			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
 			rx_desc = (struct rx_desc *)rx_data;
 			len_used = (int)(rx_data - (u8 *)agg->head);
 			len_used += sizeof(struct rx_desc);
@@ -1580,7 +1585,7 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TXFIFO_CTRL, TXFIFO_THR_NORMAL);
 
 	ocp_write_byte(tp, MCU_TYPE_USB, USB_TX_AGG, TX_AGG_MAX_THRESHOLD);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH, RX_BUF_THR);
+	ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH, RX_THR_HIGH);
 	ocp_write_dword(tp, MCU_TYPE_USB, USB_TX_DMA,
 			TEST_MODE_DISABLE | TX_SIZE_ADJUST1);
 
@@ -1893,7 +1898,7 @@ static void r8152b_init(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
-	ocp_data &= ~RWSUME_INDICATE;
+	ocp_data &= ~RESUME_INDICATE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 
 	r8152b_exit_oob(tp);
@@ -2074,7 +2079,7 @@ static void rtl8152_unload(struct r8152 *tp)
 	}
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
-	ocp_data &= ~RWSUME_INDICATE;
+	ocp_data &= ~RESUME_INDICATE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 }
 
-- 
1.8.3.1
