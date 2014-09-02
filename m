From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/2] r8152: change the location of rtl8152_set_mac_address
Date: Tue, 2 Sep 2014 17:55:10 +0800
Message-ID: <1394712342-15778-27-Taiwan-albertk@realtek.com>
References: <1394712342-15778-26-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:43399 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbaIBJzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 05:55:24 -0400
In-Reply-To: <1394712342-15778-26-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exchange the location of rtl8152_set_mac_address() and
set_ethernet_addr(). Then, the set_ethernet_addr() could
set the MAC address by calling rtl8152_set_mac_address()
later.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 80b0179..b5ff933 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -975,6 +975,23 @@ void write_mii_word(struct net_device *netdev, int phy_id, int reg, int val)
 static int
 r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags);
 
+static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
+{
+	struct r8152 *tp = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
+	pla_ocp_write(tp, PLA_IDR, BYTE_EN_SIX_BYTES, 8, addr->sa_data);
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
+
+	return 0;
+}
+
 static inline void set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
@@ -1003,23 +1020,6 @@ static inline void set_ethernet_addr(struct r8152 *tp)
 	}
 }
 
-static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
-{
-	struct r8152 *tp = netdev_priv(netdev);
-	struct sockaddr *addr = p;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-
-	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
-	pla_ocp_write(tp, PLA_IDR, BYTE_EN_SIX_BYTES, 8, addr->sa_data);
-	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
-
-	return 0;
-}
-
 static void read_bulk_callback(struct urb *urb)
 {
 	struct net_device *netdev;
-- 
1.9.3
