From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 07/12] r8152: support rx checksum
Date: Tue, 4 Mar 2014 20:00:59 +0800
Message-ID: <1393934464-23675-8-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support hw rx checksum for TCP and UDP packets.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 53 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 50 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f1eaa18..5fdf0af 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -464,11 +464,23 @@ enum rtl8152_flags {
 #define REALTEK_USB_DEVICE(vend, prod)	\
 	USB_DEVICE_INTERFACE_CLASS(vend, prod, USB_CLASS_VENDOR_SPEC)
 
+#define RTL_CHECKSUM_FAIL		-1
+
 struct rx_desc {
 	__le32 opts1;
+#define RD_CRC				(1 << 15)
 #define RX_LEN_MASK			0x7fff
+
 	__le32 opts2;
+#define RD_UDP_CS			(1 << 23)
+#define RD_TCP_CS			(1 << 22)
+#define RD_IPV4_CS			(1 << 19)
+
 	__le32 opts3;
+#define IPF				(1 << 23) /* IP checksum fail */
+#define UDPF				(1 << 22) /* UDP checksum fail */
+#define TCPF				(1 << 21) /* TCP checksum fail */
+
 	__le32 opts4;
 	__le32 opts5;
 	__le32 opts6;
@@ -1404,6 +1416,31 @@ out_tx_fill:
 	return ret;
 }
 
+static int r8152_rx_csum(struct r8152 *tp, struct rx_desc *rx_desc)
+{
+	int checksum = CHECKSUM_NONE;
+	u32 opts2, opts3;
+
+	if (tp->version == RTL_VER_01)
+		goto return_result;
+
+	opts2 = le32_to_cpu(rx_desc->opts2);
+	opts3 = le32_to_cpu(rx_desc->opts3);
+
+	if (opts2 & RD_IPV4_CS) {
+		if (opts3 & IPF)
+			checksum = RTL_CHECKSUM_FAIL;
+		else if (((opts2 & RD_UDP_CS) && (opts3 & UDPF)) ||
+			 ((opts2 & RD_TCP_CS) && (opts3 & TCPF)))
+			checksum = RTL_CHECKSUM_FAIL;
+		else
+			checksum = CHECKSUM_UNNECESSARY;
+	}
+
+return_result:
+	return checksum;
+}
+
 static void rx_bottom(struct r8152 *tp)
 {
 	unsigned long flags;
@@ -1441,6 +1478,7 @@ static void rx_bottom(struct r8152 *tp)
 			struct net_device_stats *stats = &netdev->stats;
 			unsigned int pkt_len;
 			struct sk_buff *skb;
+			int checksum;
 
 			pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
 			if (pkt_len < ETH_ZLEN)
@@ -1453,11 +1491,19 @@ static void rx_bottom(struct r8152 *tp)
 			pkt_len -= CRC_SIZE;
 			rx_data += sizeof(struct rx_desc);
 
+			checksum = r8152_rx_csum(tp, rx_desc);
+			if (checksum == RTL_CHECKSUM_FAIL) {
+				stats->rx_errors++;
+				goto find_next_rx;
+			}
+
 			skb = netdev_alloc_skb_ip_align(netdev, pkt_len);
 			if (!skb) {
 				stats->rx_dropped++;
-				break;
+				goto find_next_rx;
 			}
+
+			skb->ip_summed = checksum;
 			memcpy(skb->data, rx_data, pkt_len);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, netdev);
@@ -1465,6 +1511,7 @@ static void rx_bottom(struct r8152 *tp)
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_len;
 
+find_next_rx:
 			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
 			rx_desc = (struct rx_desc *)rx_data;
 			len_used = (int)(rx_data - (u8 *)agg->head);
@@ -3102,8 +3149,8 @@ static int rtl8152_probe(struct usb_interface *intf,
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
 
-	netdev->features |= NETIF_F_IP_CSUM;
-	netdev->hw_features = NETIF_F_IP_CSUM;
+	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
+	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
 
 	SET_ETHTOOL_OPS(netdev, &ops);
 
-- 
1.8.4.2
