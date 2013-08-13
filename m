From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] net/usb/r8152: enable tx checksum
Date: Tue, 13 Aug 2013 15:28:32 +0800
Message-ID: <1376378913-879-2-git-send-email-hayeswang@realtek.com>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376378913-879-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable tx checksum.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 63 +++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 58 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c6c5aa2..5d9d949 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -20,6 +20,8 @@
 #include <linux/if_vlan.h>
 #include <linux/uaccess.h>
 #include <linux/list.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
 
 /* Version Information */
 #define DRIVER_VERSION "v1.01.0 (2013/08/12)"
@@ -314,8 +316,13 @@ struct tx_desc {
 	u32 opts1;
 #define TX_FS			(1 << 31) /* First segment of a packet */
 #define TX_LS			(1 << 30) /* Final segment of a packet */
-#define TX_LEN_MASK		0xffff
+#define TX_LEN_MASK		0x3ffff
+
 	u32 opts2;
+#define UDP_CS			(1 << 31) /* Calculate UDP/IP checksum */
+#define TCP_CS			(1 << 30) /* Calculate TCP/IP checksum */
+#define IPV4_CS			(1 << 29) /* Calculate IPv4 checksum */
+#define IPV6_CS			(1 << 28) /* Calculate IPv6 checksum */
 };
 
 struct rx_agg {
@@ -964,6 +971,51 @@ err1:
 	return -ENOMEM;
 }
 
+static void
+r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
+{
+	memset(desc, 0, sizeof(*desc));
+
+	desc->opts1 = cpu_to_le32((skb->len & TX_LEN_MASK) | TX_FS | TX_LS);
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		__be16 protocol;
+		u8 ip_protocol;
+		u32 opts2 = 0;
+
+		if (skb->protocol == htons(ETH_P_8021Q))
+			protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+		else
+			protocol = skb->protocol;
+
+		switch (protocol) {
+		case htons(ETH_P_IP):
+			opts2 |= IPV4_CS;
+			ip_protocol = ip_hdr(skb)->protocol;
+			break;
+
+		case htons(ETH_P_IPV6):
+			opts2 |= IPV6_CS;
+			ip_protocol = ipv6_hdr(skb)->nexthdr;
+			break;
+
+		default:
+			ip_protocol = IPPROTO_RAW;
+			break;
+		}
+
+		if (ip_protocol == IPPROTO_TCP) {
+			opts2 |= TCP_CS;
+			opts2 |= (skb_transport_offset(skb) & 0x7fff) << 17;
+		} else if (ip_protocol == IPPROTO_UDP) {
+			opts2 |= UDP_CS;
+		} else
+			WARN_ON_ONCE(1);
+
+		desc->opts2 = cpu_to_le32(opts2);
+	}
+}
+
 static void rx_bottom(struct r8152 *tp)
 {
 	struct net_device_stats *stats;
@@ -1100,8 +1152,7 @@ next_agg:
 		tx_desc = (struct tx_desc *)agg->data;
 		agg->data += sizeof(*tx_desc);
 
-		tx_desc->opts1 = cpu_to_le32((skb->len & TX_LEN_MASK) | TX_FS |
-					     TX_LS);
+		r8152_tx_csum(tp, tx_desc, skb);
 		memcpy(agg->data, skb->data, len);
 		agg->skb_num++;
 		agg->skb_len += len;
@@ -1249,7 +1300,7 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 	agg->skb_num = agg->skb_len = 0;
 
 	len = skb->len;
-	tx_desc->opts1 = cpu_to_le32((skb->len & TX_LEN_MASK) | TX_FS | TX_LS);
+	r8152_tx_csum(tp, tx_desc, skb);
 	memcpy(agg->data, skb->data, len);
 	dev_kfree_skb_any(skb);
 	agg->skb_num++;
@@ -1957,7 +2008,9 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->netdev = netdev;
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
-	netdev->features &= ~NETIF_F_IP_CSUM;
+
+	netdev->features |= NETIF_F_IP_CSUM;
+	netdev->hw_features = NETIF_F_IP_CSUM;
 	SET_ETHTOOL_OPS(netdev, &ops);
 	tp->speed = 0;
 
-- 
1.8.3.1
