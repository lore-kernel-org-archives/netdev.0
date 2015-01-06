From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: support ndo_features_check
Date: Tue, 6 Jan 2015 17:41:58 +0800
Message-ID: <1394712342-15778-113-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:53958 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435AbbAFJmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 04:42:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support ndo_features_check to avoid:
 - the transport offset is more than the hw limitation when using hw checksum.
 - the skb->len of a GSO packet is more than the limitation.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2d1c77e..57ec23e 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1897,6 +1897,22 @@ static void _rtl8152_set_rx_mode(struct net_device *netdev)
 	netif_wake_queue(netdev);
 }
 
+static netdev_features_t
+rtl8152_features_check(struct sk_buff *skb, struct net_device *dev,
+		       netdev_features_t features)
+{
+	u32 mss = skb_shinfo(skb)->gso_size;
+	int max_offset = mss ? GTTCPHO_MAX : TCPHO_MAX;
+	int offset = skb_transport_offset(skb);
+
+	if ((mss || skb->ip_summed == CHECKSUM_PARTIAL) && offset > max_offset)
+		features &= ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+	else if ((skb->len + sizeof(struct tx_desc)) > agg_buf_sz)
+		features &= ~NETIF_F_GSO_MASK;
+
+	return features;
+}
+
 static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 				      struct net_device *netdev)
 {
@@ -3706,6 +3722,7 @@ static const struct net_device_ops rtl8152_netdev_ops = {
 	.ndo_set_mac_address	= rtl8152_set_mac_address,
 	.ndo_change_mtu		= rtl8152_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_features_check	= rtl8152_features_check,
 };
 
 static void r8152b_get_version(struct r8152 *tp)
-- 
2.1.0
