From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2] r8152: autoresume before setting MAC address
Date: Thu, 2 Oct 2014 17:03:12 +0800
Message-ID: <1394712342-15778-56-Taiwan-albertk@realtek.com>
References: <1394712342-15778-55-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:38911 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbaJBJDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 05:03:21 -0400
In-Reply-To: <1394712342-15778-55-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resume the device before setting the MAC address.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 604ef21..5ee7582 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1007,9 +1007,14 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 	struct sockaddr *addr = p;
+	int ret = -EADDRNOTAVAIL;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+		goto out1;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out1;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
@@ -1017,7 +1022,9 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 	pla_ocp_write(tp, PLA_IDR, BYTE_EN_SIX_BYTES, 8, addr->sa_data);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 
-	return 0;
+	usb_autopm_put_interface(tp->intf);
+out1:
+	return ret;
 }
 
 static void read_bulk_callback(struct urb *urb)
-- 
1.9.3
