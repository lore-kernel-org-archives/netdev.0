From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: support VLAN
Date: Thu, 11 Sep 2014 20:16:24 +0800
Message-ID: <1394712342-15778-36-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support hw VLAN for tx and rx. And enable them by default.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 85 +++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 71 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2130c75..9b6c35c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -506,6 +506,7 @@ struct rx_desc {
 #define IPF				(1 << 23) /* IP checksum fail */
 #define UDPF				(1 << 22) /* UDP checksum fail */
 #define TCPF				(1 << 21) /* TCP checksum fail */
+#define RX_VLAN_TAG			(1 << 16)
 
 	__le32 opts4;
 	__le32 opts5;
@@ -531,6 +532,7 @@ struct tx_desc {
 #define MSS_MAX			0x7ffU
 #define TCPHO_SHIFT		17
 #define TCPHO_MAX		0x7ffU
+#define TX_VLAN_TAG			(1 << 16)
 };
 
 struct r8152;
@@ -1423,6 +1425,25 @@ static int msdn_giant_send_check(struct sk_buff *skb)
 	return ret;
 }
 
+static inline void rtl_tx_vlan_tag(struct tx_desc *desc, struct sk_buff *skb)
+{
+	if (vlan_tx_tag_present(skb)) {
+		u32 opts2;
+
+		opts2 = TX_VLAN_TAG | swab16(vlan_tx_tag_get(skb));
+		desc->opts2 |= cpu_to_le32(opts2);
+	}
+}
+
+static inline void rtl_rx_vlan_tag(struct rx_desc *desc, struct sk_buff *skb)
+{
+	u32 opts2 = le32_to_cpu(desc->opts2);
+
+	if (opts2 & RX_VLAN_TAG)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       swab16(opts2 & 0xffff));
+}
+
 static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 			 struct sk_buff *skb, u32 len, u32 transport_offset)
 {
@@ -1550,6 +1571,8 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 			continue;
 		}
 
+		rtl_tx_vlan_tag(tx_desc, skb);
+
 		tx_data += sizeof(*tx_desc);
 
 		len = skb->len;
@@ -1691,6 +1714,7 @@ static void rx_bottom(struct r8152 *tp)
 			memcpy(skb->data, rx_data, pkt_len);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, netdev);
+			rtl_rx_vlan_tag(rx_desc, skb);
 			netif_receive_skb(skb);
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_len;
@@ -2082,6 +2106,34 @@ static void r8152_power_cut_en(struct r8152 *tp, bool enable)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 }
 
+static void rtl_rx_vlan_en(struct r8152 *tp, bool enable)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
+	if (enable)
+		ocp_data |= CPCR_RX_VLAN;
+	else
+		ocp_data &= ~CPCR_RX_VLAN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
+}
+
+static int rtl8152_set_features(struct net_device *dev,
+				netdev_features_t features)
+{
+	netdev_features_t changed = features ^ dev->features;
+	struct r8152 *tp = netdev_priv(dev);
+
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX) {
+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
+			rtl_rx_vlan_en(tp, true);
+		else
+			rtl_rx_vlan_en(tp, false);
+	}
+
+	return 0;
+}
+
 #define WAKE_ANY (WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_BCAST | WAKE_MCAST)
 
 static u32 __rtl_get_wol(struct r8152 *tp)
@@ -2330,9 +2382,10 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_USB, USB_TX_DMA,
 			TEST_MODE_DISABLE | TX_SIZE_ADJUST1);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
-	ocp_data &= ~CPCR_RX_VLAN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
+	if (tp->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		rtl_rx_vlan_en(tp, true);
+	else
+		rtl_rx_vlan_en(tp, false);
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
 
@@ -2376,9 +2429,7 @@ static void r8152b_enter_oob(struct r8152 *tp)
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
-	ocp_data |= CPCR_RX_VLAN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
+	rtl_rx_vlan_en(tp, true);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PAL_BDC_CR);
 	ocp_data |= ALDPS_PROXY_MODE;
@@ -2532,9 +2583,10 @@ static void r8153_first_init(struct r8152 *tp)
 		usleep_range(1000, 2000);
 	}
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
-	ocp_data &= ~CPCR_RX_VLAN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
+	if (tp->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		rtl_rx_vlan_en(tp, true);
+	else
+		rtl_rx_vlan_en(tp, false);
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8153_RMS);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_MTPS, MTPS_JUMBO);
@@ -2593,9 +2645,7 @@ static void r8153_enter_oob(struct r8152 *tp)
 	ocp_data &= ~TEREDO_WAKE_MASK;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG, ocp_data);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
-	ocp_data |= CPCR_RX_VLAN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
+	rtl_rx_vlan_en(tp, true);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PAL_BDC_CR);
 	ocp_data |= ALDPS_PROXY_MODE;
@@ -3330,6 +3380,7 @@ static const struct net_device_ops rtl8152_netdev_ops = {
 	.ndo_do_ioctl		= rtl8152_ioctl,
 	.ndo_start_xmit		= rtl8152_start_xmit,
 	.ndo_tx_timeout		= rtl8152_tx_timeout,
+	.ndo_set_features	= rtl8152_set_features,
 	.ndo_set_rx_mode	= rtl8152_set_rx_mode,
 	.ndo_set_mac_address	= rtl8152_set_mac_address,
 	.ndo_change_mtu		= rtl8152_change_mtu,
@@ -3484,10 +3535,16 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	netdev->features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
 			    NETIF_F_TSO | NETIF_F_FRAGLIST | NETIF_F_IPV6_CSUM |
-			    NETIF_F_TSO6;
+			    NETIF_F_TSO6 | NETIF_F_HW_VLAN_CTAG_RX |
+			    NETIF_F_HW_VLAN_CTAG_TX;
 	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
 			      NETIF_F_TSO | NETIF_F_FRAGLIST |
-			      NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
+			      NETIF_F_IPV6_CSUM | NETIF_F_TSO6 |
+			      NETIF_F_HW_VLAN_CTAG_RX |
+			      NETIF_F_HW_VLAN_CTAG_RX;
+	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+				NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
+				NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
 
 	netdev->ethtool_ops = &ops;
 	netif_set_gso_max_size(netdev, RTL_LIMITED_TSO_SIZE);
-- 
1.9.3
