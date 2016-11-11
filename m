From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 2/2] r8152: rx descriptor check
Date: Fri, 11 Nov 2016 15:15:41 +0800
Message-ID: <1394712342-15778-228-Taiwan-albertk@realtek.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, <mlord@pobox.com>,
        Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-226-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For some platforms, the data in memory is not the same with the one
from the device. That is, the data of memory is unbelievable. The
check is used to find out this situation.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0e42a78..e766121 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1756,6 +1756,43 @@ static u8 r8152_rx_csum(struct r8152 *tp, struct rx_desc *rx_desc)
 	return checksum;
 }
 
+static int invalid_rx_desc(struct r8152 *tp, struct rx_desc *rx_desc)
+{
+	u32 opts1 = le32_to_cpu(rx_desc->opts1);
+	u32 opts2 = le32_to_cpu(rx_desc->opts2);
+	unsigned int pkt_len = opts1 & RX_LEN_MASK;
+
+	switch (tp->version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		if (pkt_len > RTL8152_RMS)
+			return -EIO;
+		break;
+	default:
+		if (pkt_len > RTL8153_RMS)
+			return -EIO;
+		break;
+	}
+
+	switch (opts2 & (RD_IPV4_CS | RD_IPV6_CS)) {
+	case (RD_IPV4_CS | RD_IPV6_CS):
+		return -EIO;
+	case RD_IPV4_CS:
+	case RD_IPV6_CS:
+		switch (opts2 & (RD_UDP_CS | RD_TCP_CS)) {
+		case (RD_UDP_CS | RD_TCP_CS):
+			return -EIO;
+		default:
+			break;
+		}
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
 static int rx_bottom(struct r8152 *tp, int budget)
 {
 	unsigned long flags;
@@ -1812,6 +1849,18 @@ static int rx_bottom(struct r8152 *tp, int budget)
 			unsigned int pkt_len;
 			struct sk_buff *skb;
 
+			if (unlikely(invalid_rx_desc(tp, rx_desc))) {
+				if (net_ratelimit())
+					netif_err(tp, rx_err, netdev,
+						  "Memory unbelievable\n");
+				if (tp->netdev->features & NETIF_F_RXCSUM) {
+					tp->netdev->features &= ~NETIF_F_RXCSUM;
+					netif_err(tp, rx_err, netdev,
+						  "rx checksum off\n");
+				}
+				break;
+			}
+
 			pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
 			if (pkt_len < ETH_ZLEN)
 				break;
-- 
2.7.4
