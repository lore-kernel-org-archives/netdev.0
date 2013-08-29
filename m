From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] USB2NET : SR9700 : One Chip USB 1.1 USB2NET SR9700
 Device Driver Support
Date: Fri, 30 Aug 2013 01:06:44 +0200
Message-ID: <20130829230644.GA12124@electric-eye.fr.zoreil.com>
References: <1377746832-6201-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, horms@verge.net.au, joe@perches.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: liujunliang_ljl@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377746832-6201-1-git-send-email-liujunliang_ljl@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- use all columns
- the driver uses both 'netdev' and 'net'. Let's use 'netdev' ('net' is
  shorter but it tastes of network namespaces)
- don't dereference dev->net when there is a local netdev at hand
- use some existing #define (please check those)
- skb_set_tail_pointer to avoid compiler cast warnings

Pick whatever you want. skb_set_tail_pointer if nothing else.

---
 drivers/net/usb/sr9700.c | 113 +++++++++++++++++++++++++----------------------
 1 file changed, 60 insertions(+), 53 deletions(-)

diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index 76e11f5..f7f46e6 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -28,8 +28,8 @@ static int sr_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
 	int err;
 
-	err = usbnet_read_cmd(dev, SR_RD_REGS, SR_REQ_RD_REG,
-			      0, reg, data, length);
+	err = usbnet_read_cmd(dev, SR_RD_REGS, SR_REQ_RD_REG, 0, reg, data,
+			      length);
 	if ((err != length) && (err >= 0))
 		err = -EINVAL;
 	return err;
@@ -39,8 +39,8 @@ static int sr_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
 	int err;
 
-	err = usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG,
-			       0, reg, data, length);
+	err = usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG, 0, reg, data,
+			       length);
 	if ((err >= 0) && (err < length))
 		err = -EINVAL;
 	return err;
@@ -158,11 +158,11 @@ static int sr9700_get_eeprom_len(struct net_device *dev)
 	return SR_EEPROM_LEN;
 }
 
-static int sr9700_get_eeprom(struct net_device *net,
+static int sr9700_get_eeprom(struct net_device *netdev,
 			     struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct usbnet *dev = netdev_priv(net);
-	__le16 *ebuf = (__le16 *)data;
+	struct usbnet *dev = netdev_priv(netdev);
+	__le16 *buf = (__le16 *)data;
 	int ret = 0;
 	int i;
 
@@ -170,9 +170,11 @@ static int sr9700_get_eeprom(struct net_device *net,
 	if ((eeprom->offset & 0x01) || (eeprom->len & 0x01))
 		return -EINVAL;
 
-	for (i = 0; i < eeprom->len / 2; i++)
-		ret = sr_read_eeprom_word(dev, eeprom->offset / 2 + i,
-					  &ebuf[i]);
+	for (i = 0; i < eeprom->len / 2; i++) {
+		ret = sr_read_eeprom_word(dev, eeprom->offset / 2 + i, buf + i);
+		if (ret < 0)
+			break;
+	}
 
 	return ret;
 }
@@ -184,7 +186,7 @@ static int sr_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	int rc = 0;
 
 	if (phy_id) {
-		netdev_dbg(dev->net, "Only internal phy supported\n");
+		netdev_dbg(netdev, "Only internal phy supported\n");
 		return 0;
 	}
 
@@ -202,7 +204,7 @@ static int sr_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	else
 		res = le16_to_cpu(res) & ~BMSR_LSTATUS;
 
-	netdev_dbg(dev->net, "sr_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+	netdev_dbg(netdev, "sr_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
 		   phy_id, loc, res);
 
 	return res;
@@ -215,19 +217,19 @@ static void sr_mdio_write(struct net_device *netdev, int phy_id, int loc,
 	__le16 res = cpu_to_le16(val);
 
 	if (phy_id) {
-		netdev_dbg(dev->net, "Only internal phy supported\n");
+		netdev_dbg(netdev, "Only internal phy supported\n");
 		return;
 	}
 
-	netdev_dbg(dev->net, "sr_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+	netdev_dbg(netdev, "sr_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
 		   phy_id, loc, val);
 
 	sr_share_write_word(dev, 1, loc, res);
 }
 
-static u32 sr9700_get_link(struct net_device *net)
+static u32 sr9700_get_link(struct net_device *netdev)
 {
-	struct usbnet *dev = netdev_priv(net);
+	struct usbnet *dev = netdev_priv(netdev);
 	u8 value = 0;
 	int rc = 0;
 
@@ -239,9 +241,9 @@ static u32 sr9700_get_link(struct net_device *net)
 	return rc;
 }
 
-static int sr9700_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
+static int sr9700_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 {
-	struct usbnet *dev = netdev_priv(net);
+	struct usbnet *dev = netdev_priv(netdev);
 
 	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
 }
@@ -258,9 +260,9 @@ static const struct ethtool_ops sr9700_ethtool_ops = {
 	.nway_reset	= usbnet_nway_reset,
 };
 
-static void sr9700_set_multicast(struct net_device *net)
+static void sr9700_set_multicast(struct net_device *netdev)
 {
-	struct usbnet *dev = netdev_priv(net);
+	struct usbnet *dev = netdev_priv(netdev);
 	/* We use the 20 byte dev->data for our 8 byte filter buffer
 	 * to avoid allocating memory that is tricky to free later
 	 */
@@ -271,14 +273,15 @@ static void sr9700_set_multicast(struct net_device *net)
 	memset(hashes, 0x00, SR_MCAST_SIZE);
 	/* broadcast address */
 	hashes[SR_MCAST_SIZE - 1] |= SR_MCAST_ADDR_FLAG;
-	if (net->flags & IFF_PROMISC) {
+	if (netdev->flags & IFF_PROMISC) {
 		rx_ctl |= RCR_PRMSC;
-	} else if (net->flags & IFF_ALLMULTI ||
-		   netdev_mc_count(net) > SR_MCAST_MAX) {
+	} else if (netdev->flags & IFF_ALLMULTI ||
+		   netdev_mc_count(netdev) > SR_MCAST_MAX) {
 		rx_ctl |= RCR_RUNT;
-	} else if (!netdev_mc_empty(net)) {
+	} else if (!netdev_mc_empty(netdev)) {
 		struct netdev_hw_addr *ha;
-		netdev_for_each_mc_addr(ha, net) {
+
+		netdev_for_each_mc_addr(ha, netdev) {
 			u32 crc = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			hashes[crc >> 3] |= 1 << (crc & 0x7);
 		}
@@ -288,19 +291,19 @@ static void sr9700_set_multicast(struct net_device *net)
 	sr_write_reg_async(dev, RCR, rx_ctl);
 }
 
-static int sr9700_set_mac_address(struct net_device *net, void *p)
+static int sr9700_set_mac_address(struct net_device *netdev, void *p)
 {
-	struct usbnet *dev = netdev_priv(net);
+	struct usbnet *dev = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data)) {
-		netdev_err(net, "not setting invalid mac address %pM\n",
+		netdev_err(netdev, "not setting invalid mac address %pM\n",
 			   addr->sa_data);
 		return -EINVAL;
 	}
 
-	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
-	sr_write_async(dev, PAR, 6, dev->net->dev_addr);
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	sr_write_async(dev, PAR, 6, netdev->dev_addr);
 
 	return 0;
 }
@@ -319,26 +322,31 @@ static const struct net_device_ops sr9700_netdev_ops = {
 
 static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
 {
+	struct net_device *netdev;
+	struct mii_if_info *mii;
 	int ret;
 
 	ret = usbnet_get_endpoints(dev, intf);
 	if (ret)
 		goto out;
 
-	dev->net->netdev_ops = &sr9700_netdev_ops;
-	dev->net->ethtool_ops = &sr9700_ethtool_ops;
-	dev->net->hard_header_len += SR_TX_OVERHEAD;
-	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+	netdev = dev->net;
+
+	netdev->netdev_ops = &sr9700_netdev_ops;
+	netdev->ethtool_ops = &sr9700_ethtool_ops;
+	netdev->hard_header_len += SR_TX_OVERHEAD;
+	dev->hard_mtu = netdev->mtu + netdev->hard_header_len;
 	/* bulkin buffer is preferably not less than 3K */
 	dev->rx_urb_size = 3072;
-	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = sr_mdio_read;
-	dev->mii.mdio_write = sr_mdio_write;
-	dev->mii.phy_id_mask = 0x1f;
-	dev->mii.reg_num_mask = 0x1f;
-
-	/* reset the sr9700 */
-	sr_write_reg(dev, NCR, 1);
+
+	mii = &dev->mii;
+	mii->dev = netdev;
+	mii->mdio_read = sr_mdio_read;
+	mii->mdio_write = sr_mdio_write;
+	mii->phy_id_mask = 0x1f;
+	mii->reg_num_mask = 0x1f;
+
+	sr_write_reg(dev, NCR, NCR_RST);
 	udelay(20);
 
 	/* read MAC
@@ -346,14 +354,14 @@ static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
 	 * EEPROM automatically to PAR. In case there is no EEPROM externally,
 	 * a default MAC address is stored in PAR for making chip work properly.
 	 */
-	if (sr_read(dev, PAR, ETH_ALEN, dev->net->dev_addr) < 0) {
-		netdev_err(dev->net, "Error reading MAC address\n");
+	if (sr_read(dev, PAR, ETH_ALEN, netdev->dev_addr) < 0) {
+		netdev_err(netdev, "Error reading MAC address\n");
 		ret = -ENODEV;
 		goto out;
 	}
 
 	/* power up and reset phy */
-	sr_write_reg(dev, PRR, 1);
+	sr_write_reg(dev, PRR, PRR_PHY_RST);
 	/* at least 10ms, here 20ms for safe */
 	mdelay(20);
 	sr_write_reg(dev, PRR, 0);
@@ -361,13 +369,12 @@ static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
 	udelay(2 * 1000);
 
 	/* receive broadcast packets */
-	sr9700_set_multicast(dev->net);
+	sr9700_set_multicast(netdev);
 
-	sr_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
-	sr_mdio_write(dev->net, dev->mii.phy_id,
-		      (MII_ADVERTISE, ADVERTISE_ALL |
-		       ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP));
-	mii_nway_restart(&dev->mii);
+	sr_mdio_write(netdev, mii->phy_id, MII_BMCR, BMCR_RESET);
+	sr_mdio_write(netdev, mii->phy_id, MII_ADVERTISE, ADVERTISE_ALL |
+		      ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+	mii_nway_restart(mii);
 
 out:
 	return ret;
@@ -415,7 +422,7 @@ static int sr9700_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		if (skb->len == (len + SR_RX_OVERHEAD))	{
 			skb_pull(skb, 3);
 			skb->len = len;
-			skb->tail = skb->data + len;
+			skb_set_tail_pointer(skb, len);
 			skb->truesize = len + sizeof(struct sk_buff);
 			return 2;
 		}
@@ -427,7 +434,7 @@ static int sr9700_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		sr_skb->len = len;
 		sr_skb->data = skb->data + 3;
-		sr_skb->tail = skb->data + len;
+		skb_set_tail_pointer(sr_skb, len - 3);
 		sr_skb->truesize = len + sizeof(struct sk_buff);
 		usbnet_skb_return(dev, sr_skb);
 
-- 
1.8.3.1
