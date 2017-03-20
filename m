From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 1/2] r8152: set the RMS of RTL8153 according to the mtu
Date: Mon, 20 Mar 2017 16:13:44 +0800
Message-ID: <1394712342-15778-257-Taiwan-albertk@realtek.com>
References: <1394712342-15778-256-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:40299 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751467AbdCTIPV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 04:15:21 -0400
In-Reply-To: <1394712342-15778-256-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the received maximum size (RMS) according to the mtu size. It is
unnecessary to receive a packet which is more than the size we could
transmit. Besides, this could let the rx buffer be used effectively.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 986243c..3a892fa 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2898,7 +2898,8 @@ static void r8153_first_init(struct r8152 *tp)
 
 	rtl_rx_vlan_en(tp, tp->netdev->features & NETIF_F_HW_VLAN_CTAG_RX);
 
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8153_RMS);
+	ocp_data = tp->netdev->mtu + VLAN_ETH_HLEN + CRC_SIZE;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, ocp_data);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_MTPS, MTPS_JUMBO);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TCR0);
@@ -2950,7 +2951,8 @@ static void r8153_enter_oob(struct r8152 *tp)
 		usleep_range(1000, 2000);
 	}
 
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8153_RMS);
+	ocp_data = tp->netdev->mtu + VLAN_ETH_HLEN + CRC_SIZE;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, ocp_data);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG);
 	ocp_data &= ~TEREDO_WAKE_MASK;
@@ -4200,8 +4202,14 @@ static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 
 	dev->mtu = new_mtu;
 
-	if (netif_running(dev) && netif_carrier_ok(dev))
-		r8153_set_rx_early_size(tp);
+	if (netif_running(dev)) {
+		u32 rms = new_mtu + VLAN_ETH_HLEN + CRC_SIZE;
+
+		ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, rms);
+
+		if (netif_carrier_ok(dev))
+			r8153_set_rx_early_size(tp);
+	}
 
 	mutex_unlock(&tp->control);
 
-- 
2.7.4
