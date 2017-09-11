From: <Nisar.Sayed@microchip.com>
Subject: [PATCH v2 net] smsc95xx: Configure pause time to 0xffff when tx
 flow control enabled
Date: Mon, 11 Sep 2017 17:43:11 +0000
Message-ID: <CE371C1263339941885964188A0225FA335B8D@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <steve.glendinning@shawell.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:23160 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751144AbdIKRn6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 13:43:58 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Configure pause time to 0xffff when tx flow control enabled

Set pause time to 0xffff in the pause frame to indicate the
partner to stop sending the packets. When RX buffer frees up,
the device sends pause frame with pause time zero for partner to
resume transmission.

Fixes: 2f7ca802bdae ("Add SMSC LAN9500 USB2.0 10/100 ethernet adapter driver")
Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
v0 -> v1:
             * Added patch description in detail.
v1 -> v2:
             * Added fixes tag
---
 drivers/net/usb/smsc95xx.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 340c134..309b88a 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -526,7 +526,7 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 					   u16 lcladv, u16 rmtadv)
 {
-	u32 flow, afc_cfg = 0;
+	u32 flow = 0, afc_cfg;
 
 	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
 	if (ret < 0)
@@ -537,20 +537,19 @@ static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 
 		if (cap & FLOW_CTRL_RX)
 			flow = 0xFFFF0002;
-		else
-			flow = 0;
 
-		if (cap & FLOW_CTRL_TX)
+		if (cap & FLOW_CTRL_TX) {
 			afc_cfg |= 0xF;
-		else
+			flow |= 0xFFFF0000;
+		} else {
 			afc_cfg &= ~0xF;
+		}
 
 		netif_dbg(dev, link, dev->net, "rx pause %s, tx pause %s\n",
 				   cap & FLOW_CTRL_RX ? "enabled" : "disabled",
 				   cap & FLOW_CTRL_TX ? "enabled" : "disabled");
 	} else {
 		netif_dbg(dev, link, dev->net, "half duplex\n");
-		flow = 0;
 		afc_cfg |= 0xF;
 	}
 
-- 
1.9.1
