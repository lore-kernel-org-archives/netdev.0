From: <Nisar.Sayed@microchip.com>
Subject: [PATCH v2 net] smsc95xx: Support only IPv4 TCP/UDP csum offload
Date: Fri, 19 May 2017 14:00:25 +0000
Message-ID: <CE371C1263339941885964188A0225FA308E06@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <steve.glendinning@shawell.net>,
        <popcornmix@gmail.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:45718 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751406AbdESOAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 10:00:30 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

When TX checksum offload is used, if the computed checksum is 0 the
LAN95xx device do not alter the checksum to 0xffff.  In the case of ipv4
UDP checksum, it indicates to receiver that no checksum is calculated.
Under ipv6, UDP checksum yields a result of zero must be changed to
0xffff. Hence disabling checksum offload for ipv6 packets.

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>

Reported-by: popcorn mix <popcornmix@gmail.com>
---
Changes
V2
- Updated e-mail alias
- Updated commit message and comments

 drivers/net/usb/smsc95xx.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 765400b..2dfca96 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -681,7 +681,7 @@ static int smsc95xx_set_features(struct net_device *netdev,
 	if (ret < 0)
 		return ret;
 
-	if (features & NETIF_F_HW_CSUM)
+	if (features & NETIF_F_IP_CSUM)
 		read_buf |= Tx_COE_EN_;
 	else
 		read_buf &= ~Tx_COE_EN_;
@@ -1279,12 +1279,19 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	spin_lock_init(&pdata->mac_cr_lock);
 
+	/* LAN95xx devices do not alter the computed checksum of 0 to 0xffff.
+	 * RFC 2460, ipv6 UDP calculated checksum yields a result of zero must
+	 * be changed to 0xffff. RFC 768, ipv4 UDP computed checksum is zero,
+	 * it is transmitted as all ones. The zero transmitted checksum means
+	 * transmitter generated no checksum. Hence, enable csum offload only
+	 * for ipv4 packets.
+	 */
 	if (DEFAULT_TX_CSUM_ENABLE)
-		dev->net->features |= NETIF_F_HW_CSUM;
+		dev->net->features |= NETIF_F_IP_CSUM;
 	if (DEFAULT_RX_CSUM_ENABLE)
 		dev->net->features |= NETIF_F_RXCSUM;
 
-	dev->net->hw_features = NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
+	dev->net->hw_features = NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 
 	smsc95xx_init_mac_address(dev);
 
-- 
1.9.1
