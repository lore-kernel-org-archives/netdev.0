From: Olivier Blin <olivier.blin@softathome.com>
Subject: [PATCH net 1/3] usbnet: add a callback for set_rx_mode
Date: Fri, 24 Oct 2014 19:43:00 +0200
Message-ID: <1414172582-30844-2-git-send-email-olivier.blin@softathome.com>
References: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Cc: oneukum@suse.de, hayeswang@realtek.com, bjorn@mork.no,
	davem@davemloft.net, Olivier Blin <olivier.blin@softathome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 92-137-167-83.reverse.alphalink.fr ([83.167.137.92]:39354 "EHLO
	mtantr1.softathome.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041AbaJXRwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 13:52:09 -0400
In-Reply-To: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To delegate promiscuous mode and multicast filtering to the subdriver.

Signed-off-by: Olivier Blin <olivier.blin@softathome.com>
---
 drivers/net/usb/usbnet.c   | 20 ++++++++++++++++++++
 include/linux/usb/usbnet.h |  4 ++++
 2 files changed, 24 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 5173821..53f51fc 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1051,6 +1051,21 @@ static void __handle_link_change(struct usbnet *dev)
 	clear_bit(EVENT_LINK_CHANGE, &dev->flags);
 }
 
+static void usbnet_set_rx_mode(struct net_device *net)
+{
+	struct usbnet		*dev = netdev_priv(net);
+
+	usbnet_defer_kevent(dev, EVENT_SET_RX_MODE);
+}
+
+static void __handle_set_rx_mode(struct usbnet *dev)
+{
+	if (dev->driver_info->set_rx_mode)
+		(dev->driver_info->set_rx_mode)(dev);
+
+	clear_bit(EVENT_SET_RX_MODE, &dev->flags);
+}
+
 /* work that cannot be done in interrupt context uses keventd.
  *
  * NOTE:  with 2.5 we could do more of this using completion callbacks,
@@ -1156,6 +1171,10 @@ skip_reset:
 	if (test_bit (EVENT_LINK_CHANGE, &dev->flags))
 		__handle_link_change(dev);
 
+	if (test_bit (EVENT_SET_RX_MODE, &dev->flags))
+		__handle_set_rx_mode(dev);
+
+
 	if (dev->flags)
 		netdev_dbg(dev->net, "kevent done, flags = 0x%lx\n", dev->flags);
 }
@@ -1523,6 +1542,7 @@ static const struct net_device_ops usbnet_netdev_ops = {
 	.ndo_stop		= usbnet_stop,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_set_rx_mode	= usbnet_set_rx_mode,
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 26088fe..d9a4905 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -78,6 +78,7 @@ struct usbnet {
 #		define EVENT_NO_RUNTIME_PM	9
 #		define EVENT_RX_KILL	10
 #		define EVENT_LINK_CHANGE	11
+#		define EVENT_SET_RX_MODE	12
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
@@ -159,6 +160,9 @@ struct driver_info {
 	/* called by minidriver when receiving indication */
 	void	(*indication)(struct usbnet *dev, void *ind, int indlen);
 
+	/* rx mode change (device changes address list filtering) */
+	void	(*set_rx_mode)(struct usbnet *dev);
+
 	/* for new devices, use the descriptor-reading code instead */
 	int		in;		/* rx endpoint */
 	int		out;		/* tx endpoint */
-- 
2.1.2

-- This message and any attachments herein are confidential, intended solely for the addressees and are SoftAtHome.s ownership. Any unauthorized use or dissemination is prohibited. If you are not the intended addressee of this message, please cancel it immediately and inform the sender.
-- This message and any attachments herein are confidential, intended solely for the addressees and are SoftAtHome.s ownership. Any unauthorized use or dissemination is prohibited. If you are not the intended addressee of this message, please cancel it immediately and inform the sender.
