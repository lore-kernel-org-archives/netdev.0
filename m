From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 10/13] r8152: support IPv6
Date: Wed, 5 Mar 2014 14:49:25 +0800
Message-ID: <1394002168-3193-11-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support hw IPv6 checksum for TCP and UDP packets.

Note that the hw has the limitation of the range of the transport
offset. Besides, the TCP Pseudo Header of the IPv6 TSO of the hw
bases on the Microsoft document which excludes the packet length.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 107 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 104 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8f6d0f8..8e208f30 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -21,6 +21,7 @@
 #include <linux/list.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <net/ip6_checksum.h>
 
 /* Version Information */
 #define DRIVER_VERSION "v1.06.0 (2014/03/03)"
@@ -472,6 +473,7 @@ struct rx_desc {
 	__le32 opts2;
 #define RD_UDP_CS			(1 << 23)
 #define RD_TCP_CS			(1 << 22)
+#define RD_IPV6_CS			(1 << 20)
 #define RD_IPV4_CS			(1 << 19)
 
 	__le32 opts3;
@@ -489,7 +491,9 @@ struct tx_desc {
 #define TX_FS			(1 << 31) /* First segment of a packet */
 #define TX_LS			(1 << 30) /* Final segment of a packet */
 #define GTSENDV4		(1 << 28)
+#define GTSENDV6		(1 << 27)
 #define GTTCPHO_SHIFT		18
+#define GTTCPHO_MAX		0x7fU
 #define TX_LEN_MAX		0x3ffffU
 
 	__le32 opts2;
@@ -500,6 +504,7 @@ struct tx_desc {
 #define MSS_SHIFT		17
 #define MSS_MAX			0x7ffU
 #define TCPHO_SHIFT		17
+#define TCPHO_MAX		0x7ffU
 };
 
 struct r8152;
@@ -1319,6 +1324,70 @@ static inline __be16 get_protocol(struct sk_buff *skb)
 	return protocol;
 }
 
+/*
+ * r8152_csum_workaround()
+ * The hw limites the value the transport offset. When the offset is out of the
+ * range, calculate the checksum by sw.
+ */
+static void r8152_csum_workaround(struct r8152 *tp, struct sk_buff *skb,
+				  struct sk_buff_head *list)
+{
+	if (skb_shinfo(skb)->gso_size) {
+		netdev_features_t features = tp->netdev->features;
+		struct sk_buff_head seg_list;
+		struct sk_buff *segs, *nskb;
+
+		features &= ~(NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO);
+		segs = skb_gso_segment(skb, features);
+		if (IS_ERR(segs) || !segs)
+			goto drop;
+
+		__skb_queue_head_init(&seg_list);
+
+		do {
+			nskb = segs;
+			segs = segs->next;
+			nskb->next = NULL;
+			__skb_queue_tail(&seg_list, nskb);
+		} while (segs);
+
+		skb_queue_splice(&seg_list, list);
+
+		dev_kfree_skb(skb);
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (skb_checksum_help(skb) < 0)
+			goto drop;
+
+		__skb_queue_head(list, skb);
+	} else {
+		struct net_device_stats *stats;
+
+drop:
+		stats = &tp->netdev->stats;
+		stats->tx_dropped++;
+		dev_kfree_skb(skb);
+	}
+}
+
+/*
+ * msdn_giant_send_check()
+ * According to the document of microsoft, the TCP Pseudo Header excludes the
+ * packet length for IPv6 TCP large packets.
+ */
+static int msdn_giant_send_check(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ipv6h;
+	struct tcphdr *th;
+
+	ipv6h = ipv6_hdr(skb);
+	th = tcp_hdr(skb);
+
+	th->check = 0;
+	th->check = ~tcp_v6_check(0, &ipv6h->saddr, &ipv6h->daddr, 0);
+
+	return 0;
+}
+
 static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 			 struct sk_buff *skb, u32 len, u32 transport_offset)
 {
@@ -1331,11 +1400,24 @@ static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 	opts1 = len | TX_FS | TX_LS;
 
 	if (mss) {
+		if (transport_offset > GTTCPHO_MAX) {
+			netif_warn(tp, tx_err, tp->netdev,
+				   "Invalid transport offset 0x%x for TSO\n",
+				   transport_offset);
+			ret = TX_CSUM_TSO;
+			goto unavailable;
+		}
+
 		switch (get_protocol(skb)) {
 		case htons(ETH_P_IP):
 			opts1 |= GTSENDV4;
 			break;
 
+		case htons(ETH_P_IPV6):
+			opts1 |= GTSENDV6;
+			msdn_giant_send_check(skb);
+			break;
+
 		default:
 			WARN_ON_ONCE(1);
 			break;
@@ -1346,6 +1428,14 @@ static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 ip_protocol;
 
+		if (transport_offset > TCPHO_MAX) {
+			netif_warn(tp, tx_err, tp->netdev,
+				   "Invalid transport offset 0x%x\n",
+				   transport_offset);
+			ret = TX_CSUM_NONE;
+			goto unavailable;
+		}
+
 		switch (get_protocol(skb)) {
 		case htons(ETH_P_IP):
 			opts2 |= IPV4_CS;
@@ -1375,6 +1465,7 @@ static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 	desc->opts2 = cpu_to_le32(opts2);
 	desc->opts1 = cpu_to_le32(opts1);
 
+unavailable:
 	return ret;
 }
 
@@ -1415,7 +1506,10 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 
 		offset = (u32)skb_transport_offset(skb);
 
-		r8152_tx_csum(tp, tx_desc, skb, skb->len, offset);
+		if (r8152_tx_csum(tp, tx_desc, skb, skb->len, offset)) {
+			r8152_csum_workaround(tp, skb, &skb_head);
+			continue;
+		}
 
 		tx_data += sizeof(*tx_desc);
 
@@ -1487,6 +1581,11 @@ static int r8152_rx_csum(struct r8152 *tp, struct rx_desc *rx_desc)
 			checksum = CHECKSUM_NONE;
 		else
 			checksum = CHECKSUM_UNNECESSARY;
+	} else if (RD_IPV6_CS) {
+		if ((opts2 & RD_UDP_CS) && !(opts3 & UDPF))
+			checksum = CHECKSUM_UNNECESSARY;
+		else if ((opts2 & RD_TCP_CS) && !(opts3 & TCPF))
+			checksum = CHECKSUM_UNNECESSARY;
 	}
 
 return_result:
@@ -3195,9 +3294,11 @@ static int rtl8152_probe(struct usb_interface *intf,
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
 
 	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
-			    NETIF_F_TSO | NETIF_F_FRAGLIST;
+			    NETIF_F_TSO | NETIF_F_FRAGLIST | NETIF_F_IPV6_CSUM |
+			    NETIF_F_TSO6;
 	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
-			      NETIF_F_TSO | NETIF_F_FRAGLIST;
+			      NETIF_F_TSO | NETIF_F_FRAGLIST |
+			      NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
 
 	SET_ETHTOOL_OPS(netdev, &ops);
 	netif_set_gso_max_size(netdev, RTL_LIMITED_TSO_SIZE);
-- 
1.8.4.2
