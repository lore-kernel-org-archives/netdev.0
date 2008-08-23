From: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Subject: [PATCH] mcs7830: add set_mac_address
Date: Sat, 23 Aug 2008 20:01:53 +0200
Message-ID: <20080823200153.40a8ec24@ors.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:40506 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbYHWSB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 14:01:57 -0400
Received: by fg-out-1718.google.com with SMTP id 19so550023fgg.17
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 11:01:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement set_mac_address for mcs7830. This enables me to use it with my
cable modem. Tested (and using it right now) with 2.6.26, tested to
compile with 2.6.27-rc4

Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>

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
