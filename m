From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH 4/4] MCS7830 USB-Ether: resume _with_ working link, via
	.reset_resume support
Date: Sun, 31 Jan 2010 13:58:42 +0100
Message-ID: <20100131125842.GD13435@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	David Hollis <dhollis@davehollis.com>,
	Phil Chang <pchang23@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:60170 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab0AaM6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 07:58:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ChangeLog:
Implement .reset_resume support to retain a live network connection
during suspend despite USB power loss.
- rework operation to reference cached data in mcs7830_data and
  netdev->dev_addr 
- update netdev->dev_addr only in case new MAC was set successfully
. Tests done:
  . ethtool -d pre-/post-suspend: register values match
  . running ssh session suspend, resume: works
  . ifdown device, suspend, resume: works
  . ifup, suspend, unplug, resume: WORKS (eth1 is removed, re-ifup of eth1
    after card replug works)
  . verified identical MAC in ifconfig post-resume
    (ok, should be verified on network side to be fully certain...)


Keywords: suspend resume network connection dead interface down

Signed-off-by: Andreas Mohr <andi@lisas.de>


Index: linux-2.6.33-rc4/drivers/net/usb/mcs7830.c
===================================================================
--- linux-2.6.33-rc4.orig/drivers/net/usb/mcs7830.c	2010-01-31 13:01:24.000000000 +0100
+++ linux-2.6.33-rc4/drivers/net/usb/mcs7830.c	2010-01-31 13:05:17.000000000 +0100
@@ -12,8 +12,6 @@
  * Definitions gathered from MOSCHIP, Data Sheet_7830DA.pdf (thanks!).
  *
  * TODO:
- * - add .reset_resume support (iface is _gone_ after resume w/ power loss)
- * - verify that mcs7830_get_regs() does have same output pre-/post-suspend
  * - support HIF_REG_CONFIG_SLEEPMODE/HIF_REG_CONFIG_TXENABLE (via autopm?)
  * - implement ethtool_ops get_pauseparam/set_pauseparam
  *   via HIF_REG_PAUSE_THRESHOLD (>= revision C only!)
@@ -137,7 +135,7 @@
 	return ret;
 }
 
-static int mcs7830_set_reg(struct usbnet *dev, u16 index, u16 size, void *data)
+static int mcs7830_set_reg(struct usbnet *dev, u16 index, u16 size, const void *data)
 {
 	struct usb_device *xdev = dev->udev;
 	int ret;
@@ -211,13 +209,43 @@
 	usb_free_urb(urb);
 }
 
-static int mcs7830_get_address(struct usbnet *dev)
+static int mcs7830_hif_get_mac_address(struct usbnet *dev, unsigned char *addr)
+{
+	int ret = mcs7830_get_reg(dev, HIF_REG_ETHERNET_ADDR, ETH_ALEN, addr);
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+
+static int mcs7830_hif_set_mac_address(struct usbnet *dev, unsigned char *addr)
+{
+	int ret = mcs7830_set_reg(dev, HIF_REG_ETHERNET_ADDR, ETH_ALEN, addr);
+
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+
+static int mcs7830_set_mac_address(struct net_device *netdev, void *p)
 {
 	int ret;
-	ret = mcs7830_get_reg(dev, HIF_REG_ETHERNET_ADDR, ETH_ALEN,
-				   dev->net->dev_addr);
+	struct usbnet *dev = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	ret = mcs7830_hif_set_mac_address(dev, addr->sa_data);
+
 	if (ret < 0)
 		return ret;
+
+	/* it worked --> adopt it on netdev side */
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+
 	return 0;
 }
 
@@ -359,33 +387,6 @@
 	}
 }
 
-static int mcs7830_init_dev(struct usbnet *dev)
-{
-	int ret;
-	int retry;
-
-	/* Read MAC address from EEPROM */
-	ret = -EINVAL;
-	for (retry = 0; retry < 5 && ret; retry++)
-		ret = mcs7830_get_address(dev);
-	if (ret) {
-		dev_warn(&dev->udev->dev, "Cannot read MAC address\n");
-		goto out;
-	}
-
-	/* Set up PHY */
-	ret = mcs7830_set_autoneg(dev, 0);
-	if (ret) {
-		dev_info(&dev->udev->dev, "Cannot set autoneg\n");
-		goto out;
-	}
-
-	mcs7830_rev_C_fixup(dev);
-	ret = 0;
-out:
-	return ret;
-}
-
 static int mcs7830_mdio_read(struct net_device *netdev, int phy_id,
 			     int location)
 {
@@ -406,11 +407,33 @@
 	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
 }
 
-/* credits go to asix_set_multicast */
-static void mcs7830_set_multicast(struct net_device *net)
+static inline struct mcs7830_data *mcs7830_get_data(struct usbnet *dev)
+{
+	return (struct mcs7830_data *)&dev->data;
+}
+
+static void mcs7830_hif_update_multicast_hash(struct usbnet *dev)
+{
+	struct mcs7830_data *data = mcs7830_get_data(dev);
+	mcs7830_set_reg_async(dev, HIF_REG_MULTICAST_HASH,
+				sizeof data->multi_filter,
+				data->multi_filter);
+}
+
+static void mcs7830_hif_update_config(struct usbnet *dev)
+{
+	/* implementation specific to data->config
+           (argument needs to be heap-based anyway - USB DMA!) */
+	struct mcs7830_data *data = mcs7830_get_data(dev);
+	mcs7830_set_reg_async(dev, HIF_REG_CONFIG, 1, &data->config);
+}
+
+static void mcs7830_data_set_multicast(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
-	struct mcs7830_data *data = (struct mcs7830_data *)&dev->data;
+	struct mcs7830_data *data = mcs7830_get_data(dev);
+
+	memset(data->multi_filter, 0, sizeof data->multi_filter);
 
 	data->config = HIF_REG_CONFIG_TXENABLE;
 
@@ -433,21 +456,51 @@
 		u32 crc_bits;
 		int i;
 
-		memset(data->multi_filter, 0, sizeof data->multi_filter);
-
 		/* Build the multicast hash filter. */
 		for (i = 0; i < net->mc_count; i++) {
 			crc_bits = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |= 1 << (crc_bits & 7);
 			mc_list = mc_list->next;
 		}
+	}
+}
 
-		mcs7830_set_reg_async(dev, HIF_REG_MULTICAST_HASH,
-				sizeof data->multi_filter,
-				data->multi_filter);
+static int mcs7830_apply_base_config(struct usbnet *dev)
+{
+	int ret;
+
+	/* re-configure known MAC (suspend case etc.) */
+	ret = mcs7830_hif_set_mac_address(dev, dev->net->dev_addr);
+	if (ret) {
+		dev_info(&dev->udev->dev, "Cannot set MAC address\n");
+		goto out;
 	}
 
-	mcs7830_set_reg_async(dev, HIF_REG_CONFIG, 1, &data->config);
+	/* Set up PHY */
+	ret = mcs7830_set_autoneg(dev, 0);
+	if (ret) {
+		dev_info(&dev->udev->dev, "Cannot set autoneg\n");
+		goto out;
+	}
+
+	mcs7830_hif_update_multicast_hash(dev);
+	mcs7830_hif_update_config(dev);
+
+	mcs7830_rev_C_fixup(dev);
+	ret = 0;
+out:
+	return ret;
+}
+
+/* credits go to asix_set_multicast */
+static void mcs7830_set_multicast(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	mcs7830_data_set_multicast(net);
+
+	mcs7830_hif_update_multicast_hash(dev);
+	mcs7830_hif_update_config(dev);
 }
 
 static int mcs7830_get_regs_len(struct net_device *net)
@@ -491,29 +544,6 @@
 	.nway_reset		= usbnet_nway_reset,
 };
 
-static int mcs7830_set_mac_address(struct net_device *netdev, void *p)
-{
-	int ret;
-	struct usbnet *dev = netdev_priv(netdev);
-	struct sockaddr *addr = p;
-
-	if (netif_running(netdev))
-		return -EBUSY;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
-
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-
-	ret = mcs7830_set_reg(dev, HIF_REG_ETHERNET_ADDR, ETH_ALEN,
-			netdev->dev_addr);
-
-	if (ret < 0)
-		return ret;
-
-	return 0;
-}
-
 static const struct net_device_ops mcs7830_netdev_ops = {
 	.ndo_open		= usbnet_open,
 	.ndo_stop		= usbnet_stop,
@@ -530,14 +560,25 @@
 {
 	struct net_device *net = dev->net;
 	int ret;
+	int retry;
 
-	ret = mcs7830_init_dev(dev);
+	/* Initial startup: Gather MAC address setting from EEPROM */
+	ret = -EINVAL;
+	for (retry = 0; retry < 5 && ret; retry++)
+		ret = mcs7830_hif_get_mac_address(dev, net->dev_addr);
+	if (ret) {
+		dev_warn(&dev->udev->dev, "Cannot read MAC address\n");
+		goto out;
+	}
+
+	mcs7830_data_set_multicast(net);
+
+	ret = mcs7830_apply_base_config(dev);
 	if (ret)
 		goto out;
 
 	net->ethtool_ops = &mcs7830_ethtool_ops;
 	net->netdev_ops = &mcs7830_netdev_ops;
-	mcs7830_set_multicast(net);
 
 	/* reserve space for the status byte on rx */
 	dev->rx_urb_size = ETH_FRAME_LEN + 1;
@@ -622,6 +663,20 @@
 };
 MODULE_DEVICE_TABLE(usb, products);
 
+static int mcs7830_reset_resume (struct usb_interface *intf)
+{
+ 	/* YES, this function is successful enough that ethtool -d
+           does show same output pre-/post-suspend */
+
+	struct usbnet		*dev = usb_get_intfdata(intf);
+
+	mcs7830_apply_base_config(dev);
+
+	usbnet_resume(intf);
+
+	return 0;
+}
+
 static struct usb_driver mcs7830_driver = {
 	.name = driver_name,
 	.id_table = products,
@@ -629,6 +684,7 @@
 	.disconnect = usbnet_disconnect,
 	.suspend = usbnet_suspend,
 	.resume = usbnet_resume,
+	.reset_resume = mcs7830_reset_resume,
 };
 
 static int __init mcs7830_init(void)
