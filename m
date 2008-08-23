From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 2/2] net/usb/mcs7830: add set_mac_address
Date: Sat, 23 Aug 2008 22:08:47 +0200
Message-ID: <200808232208.47578.arnd@arndb.de>
References: <200808232202.23822.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Oliver Martin <oliver.martin-oe7qfRrRQffzPE21tAIdciO7C/xPubJB@public.gmane.org>
To: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200808232202.23822.arnd-r2nGTMty4D4@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Martin <oliver.martin-oe7qfRrRQffzPE21tAIdciO7C/xPubJB@public.gmane.org>

Implement set_mac_address for mcs7830. This enables me to use it with my
cable modem. Tested (and using it right now) with 2.6.26, tested to
compile with 2.6.27-rc4

Signed-off-by: Oliver Martin <oliver.martin-oe7qfRrRQffzPE21tAIdciO7C/xPubJB@public.gmane.org>
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

--- linux-2.6.26/drivers/net/usb/mcs7830.c.orig	2008-08-23 01:44:26.000000000 +0200
+++ linux-2.6.26/drivers/net/usb/mcs7830.c	2008-08-23 02:26:28.000000000 +0200
@@ -442,6 +442,29 @@ static struct ethtool_ops mcs7830_ethtoo
 	.nway_reset		= usbnet_nway_reset,
 };
 
+static int mcs7830_set_mac_address(struct net_device *netdev, void *p)
+{
+	int ret;
+	struct usbnet *dev = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+
+	ret = mcs7830_set_reg(dev, HIF_REG_ETHERNET_ADDR, ETH_ALEN,
+			netdev->dev_addr);
+
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
 static int mcs7830_bind(struct usbnet *dev, struct usb_interface *udev)
 {
 	struct net_device *net = dev->net;
@@ -455,6 +478,7 @@ static int mcs7830_bind(struct usbnet *d
 	net->ethtool_ops = &mcs7830_ethtool_ops;
 	net->set_multicast_list = mcs7830_set_multicast;
 	mcs7830_set_multicast(net);
+	net->set_mac_address = mcs7830_set_mac_address;
 
 	/* reserve space for the status byte on rx */
 	dev->rx_urb_size = ETH_FRAME_LEN + 1;

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
