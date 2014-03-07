From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 6/7] r8152: support TSO
Date: Fri, 7 Mar 2014 11:04:39 +0800
Message-ID: <1394161480-2918-7-git-send-email-hayeswang@realtek.com>
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

Support scatter gather and TSO.

Adjust the tx checksum function and set the max gso size to fix the
size of the tx aggregation buffer.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 117 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 87 insertions(+), 30 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8bb8782..b23b2ae 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -23,7 +23,7 @@
 #include <linux/ipv6.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.05.0 (2014/02/18)"
+#define DRIVER_VERSION "v1.06.0 (2014/03/03)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -487,13 +487,18 @@ struct tx_desc {
 	__le32 opts1;
 #define TX_FS			(1 << 31) /* First segment of a packet */
 #define TX_LS			(1 << 30) /* Final segment of a packet */
-#define TX_LEN_MASK		0x3ffff
+#define GTSENDV4		(1 << 28)
+#define GTTCPHO_SHIFT		18
+#define TX_LEN_MAX		0x3ffffU
 
 	__le32 opts2;
 #define UDP_CS			(1 << 31) /* Calculate UDP/IP checksum */
 #define TCP_CS			(1 << 30) /* Calculate TCP/IP checksum */
 #define IPV4_CS			(1 << 29) /* Calculate IPv4 checksum */
 #define IPV6_CS			(1 << 28) /* Calculate IPv6 checksum */
+#define MSS_SHIFT		17
+#define MSS_MAX			0x7ffU
+#define TCPHO_SHIFT		17
 };
 
 struct r8152;
@@ -560,12 +565,21 @@ enum rtl_version {
 	RTL_VER_MAX
 };
 
+enum tx_csum_stat {
+	TX_CSUM_SUCCESS = 0,
+	TX_CSUM_TSO,
+	TX_CSUM_NONE
+};
+
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
  * The RTL chips use a 64 element hash table based on the Ethernet CRC.
  */
 static const int multicast_filter_limit = 32;
 static unsigned int rx_buf_sz = 16384;
 
+#define RTL_LIMITED_TSO_SIZE	(rx_buf_sz - sizeof(struct tx_desc) - \
+				 VLAN_ETH_HLEN - VLAN_HLEN)
+
 static
 int get_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 {
@@ -1292,24 +1306,46 @@ static struct tx_agg *r8152_get_tx_agg(struct r8152 *tp)
 	return agg;
 }
 
-static void
-r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
+static inline __be16 get_protocol(struct sk_buff *skb)
 {
-	memset(desc, 0, sizeof(*desc));
+	__be16 protocol;
 
-	desc->opts1 = cpu_to_le32((skb->len & TX_LEN_MASK) | TX_FS | TX_LS);
+	if (skb->protocol == htons(ETH_P_8021Q))
+		protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+	else
+		protocol = skb->protocol;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		__be16 protocol;
-		u8 ip_protocol;
-		u32 opts2 = 0;
+	return protocol;
+}
 
-		if (skb->protocol == htons(ETH_P_8021Q))
-			protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
-		else
-			protocol = skb->protocol;
+static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
+			 struct sk_buff *skb, u32 len, u32 transport_offset)
+{
+	u32 mss = skb_shinfo(skb)->gso_size;
+	u32 opts1, opts2 = 0;
+	int ret = TX_CSUM_SUCCESS;
+
+	WARN_ON_ONCE(len > TX_LEN_MAX);
+
+	opts1 = len | TX_FS | TX_LS;
+
+	if (mss) {
+		switch (get_protocol(skb)) {
+		case htons(ETH_P_IP):
+			opts1 |= GTSENDV4;
+			break;
+
+		default:
+			WARN_ON_ONCE(1);
+			break;
+		}
+
+		opts1 |= transport_offset << GTTCPHO_SHIFT;
+		opts2 |= min(mss, MSS_MAX) << MSS_SHIFT;
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		u8 ip_protocol;
 
-		switch (protocol) {
+		switch (get_protocol(skb)) {
 		case htons(ETH_P_IP):
 			opts2 |= IPV4_CS;
 			ip_protocol = ip_hdr(skb)->protocol;
@@ -1325,17 +1361,20 @@ r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
 			break;
 		}
 
-		if (ip_protocol == IPPROTO_TCP) {
+		if (ip_protocol == IPPROTO_TCP)
 			opts2 |= TCP_CS;
-			opts2 |= (skb_transport_offset(skb) & 0x7fff) << 17;
-		} else if (ip_protocol == IPPROTO_UDP) {
+		else if (ip_protocol == IPPROTO_UDP)
 			opts2 |= UDP_CS;
-		} else {
+		else
 			WARN_ON_ONCE(1);
-		}
 
-		desc->opts2 = cpu_to_le32(opts2);
+		opts2 |= transport_offset << TCPHO_SHIFT;
 	}
+
+	desc->opts2 = cpu_to_le32(opts2);
+	desc->opts1 = cpu_to_le32(opts1);
+
+	return ret;
 }
 
 static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
@@ -1357,29 +1396,44 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		struct tx_desc *tx_desc;
 		struct sk_buff *skb;
 		unsigned int len;
+		u32 offset;
 
 		skb = __skb_dequeue(&skb_head);
 		if (!skb)
 			break;
 
-		remain -= sizeof(*tx_desc);
-		len = skb->len;
-		if (remain < len) {
+		len = skb->len + sizeof(*tx_desc);
+
+		if (len > remain) {
 			__skb_queue_head(&skb_head, skb);
 			break;
 		}
 
 		tx_data = tx_agg_align(tx_data);
 		tx_desc = (struct tx_desc *)tx_data;
+
+		offset = (u32)skb_transport_offset(skb);
+
+		r8152_tx_csum(tp, tx_desc, skb, skb->len, offset);
+
 		tx_data += sizeof(*tx_desc);
 
-		r8152_tx_csum(tp, tx_desc, skb);
-		memcpy(tx_data, skb->data, len);
-		agg->skb_num++;
+		len = skb->len;
+		if (skb_copy_bits(skb, 0, tx_data, len) < 0) {
+			struct net_device_stats *stats = &tp->netdev->stats;
+
+			stats->tx_dropped++;
+			dev_kfree_skb_any(skb);
+			tx_data -= sizeof(*tx_desc);
+			continue;
+		}
+
+		tx_data += len;
 		agg->skb_len += len;
+		agg->skb_num++;
+
 		dev_kfree_skb_any(skb);
 
-		tx_data += len;
 		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
@@ -3140,10 +3194,13 @@ static int rtl8152_probe(struct usb_interface *intf,
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
 
-	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
-	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
+	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
+			    NETIF_F_TSO | NETIF_F_FRAGLIST;
+	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
+			      NETIF_F_TSO | NETIF_F_FRAGLIST;
 
 	SET_ETHTOOL_OPS(netdev, &ops);
+	netif_set_gso_max_size(netdev, RTL_LIMITED_TSO_SIZE);
 
 	tp->mii.dev = netdev;
 	tp->mii.mdio_read = read_mii_word;
-- 
1.8.4.2
