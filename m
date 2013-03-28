From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH] smsc75xx: fix jumbo frame support
Date: Thu, 28 Mar 2013 12:34:41 +0000
Message-ID: <1364474081-21918-1-git-send-email-steve.glendinning@shawell.net>
Cc: philip.dawson@paconsulting.com,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.69.43.92] ([212.69.43.92]:34678 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754571Ab3C1Mph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 08:45:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables RX of jumbo frames for LAN7500.

Previously the driver would transmit jumbo frames succesfully but
would drop received jumbo frames (incrementing the interface errors
count).

With this patch applied the device can succesfully receive jumbo
frames up to MTU 9000 (9014 bytes on the wire including ethernet
header).

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 9abe517..1a15ec1 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -914,8 +914,12 @@ static int smsc75xx_set_rx_max_frame_length(struct usbnet *dev, int size)
 static int smsc75xx_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct usbnet *dev = netdev_priv(netdev);
+	int ret;
+
+	if (new_mtu > MAX_SINGLE_PACKET_SIZE)
+		return -EINVAL;
 
-	int ret = smsc75xx_set_rx_max_frame_length(dev, new_mtu);
+	ret = smsc75xx_set_rx_max_frame_length(dev, new_mtu + ETH_HLEN);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to set mac rx frame length\n");
 		return ret;
@@ -1324,7 +1328,7 @@ static int smsc75xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "FCT_TX_CTL set to 0x%08x\n", buf);
 
-	ret = smsc75xx_set_rx_max_frame_length(dev, 1514);
+	ret = smsc75xx_set_rx_max_frame_length(dev, dev->net->mtu + ETH_HLEN);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to set max rx frame length\n");
 		return ret;
@@ -2134,8 +2138,8 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			else if (rx_cmd_a & (RX_CMD_A_LONG | RX_CMD_A_RUNT))
 				dev->net->stats.rx_frame_errors++;
 		} else {
-			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */
-			if (unlikely(size > (ETH_FRAME_LEN + 12))) {
+			/* MAX_SINGLE_PACKET_SIZE + 4(CRC) + 2(COE) + 4(Vlan) */
+			if (unlikely(size > (MAX_SINGLE_PACKET_SIZE + ETH_HLEN + 12))) {
 				netif_dbg(dev, rx_err, dev->net,
 					  "size err rx_cmd_a=0x%08x\n",
 					  rx_cmd_a);
-- 
1.7.10.4
