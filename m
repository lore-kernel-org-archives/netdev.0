From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH] smsc75xx: only set mac address once on bind
Date: Mon, 10 Dec 2012 11:01:19 +0000
Message-ID: <1355137279-2695-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Bjorn Mork <bjorn@mork.no>, Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:48296 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551Ab2LJLBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 06:01:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes when we decide what the device's MAC address
is from per ifconfig up to once when the device is connected.

Without this patch, a manually forced device MAC is overwritten
on ifconfig down/up.  Also devices that have no EEPROM are
assigned a new random address on ifconfig down/up instead of
persisting the same one.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
Reported-by: Robert Cunningham <rcunningham@nsmsurveillance.com>
Cc: Bjorn Mork <bjorn@mork.no>
Cc: Dan Williams <dcbw@redhat.com>
---
 drivers/net/usb/smsc75xx.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1cbd936..251a335 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1054,8 +1054,6 @@ static int smsc75xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "PHY reset complete\n");
 
-	smsc75xx_init_mac_address(dev);
-
 	ret = smsc75xx_set_mac_address(dev);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to set mac address\n");
@@ -1422,6 +1420,14 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_RXCSUM;
 
+	ret = smsc75xx_wait_ready(dev, 0);
+	if (ret < 0) {
+		netdev_warn(dev->net, "device not ready in smsc75xx_bind\n");
+		return ret;
+	}
+
+	smsc75xx_init_mac_address(dev);
+
 	/* Init all registers */
 	ret = smsc75xx_reset(dev);
 	if (ret < 0) {
-- 
1.7.10.4
