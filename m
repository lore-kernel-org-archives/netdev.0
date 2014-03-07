From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 5/7] r8152: support rx checksum
Date: Fri, 7 Mar 2014 11:04:38 +0800
Message-ID: <1394161480-2918-6-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support hw rx checksum for TCP and UDP packets.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 41 +++++++++++++++++++++++++++++++++++++++--
 1 file changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 08f4e870..8bb8782 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -467,8 +467,17 @@ enum rtl8152_flags {
 struct rx_desc {
 	__le32 opts1;
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
@@ -1404,6 +1413,32 @@ out_tx_fill:
 	return ret;
 }
 
+static u8 r8152_rx_csum(struct r8152 *tp, struct rx_desc *rx_desc)
+{
+	u8 checksum = CHECKSUM_NONE;
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
+			checksum = CHECKSUM_NONE;
+		else if ((opts2 & RD_UDP_CS) && (opts3 & UDPF))
+			checksum = CHECKSUM_NONE;
+		else if ((opts2 & RD_TCP_CS) && (opts3 & TCPF))
+			checksum = CHECKSUM_NONE;
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
@@ -1458,6 +1493,8 @@ static void rx_bottom(struct r8152 *tp)
 				stats->rx_dropped++;
 				goto find_next_rx;
 			}
+
+			skb->ip_summed = r8152_rx_csum(tp, rx_desc);
 			memcpy(skb->data, rx_data, pkt_len);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, netdev);
@@ -3103,8 +3140,8 @@ static int rtl8152_probe(struct usb_interface *intf,
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
 
-	netdev->features |= NETIF_F_IP_CSUM;
-	netdev->hw_features = NETIF_F_IP_CSUM;
+	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
+	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
 
 	SET_ETHTOOL_OPS(netdev, &ops);
 
-- 
1.8.4.2
