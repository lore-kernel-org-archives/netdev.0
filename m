From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next v2 2/9] net: use core MTU range checking in USB NIC drivers
Date: Thu, 20 Oct 2016 13:55:17 -0400
Message-ID: <20161020175524.6184-3-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        Hayes Wang <hayeswang@realtek.com>,
        Oliver Neukum <oneukum@suse.com>,
        Steve Glendinning <steve.glendinning@shawell.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161020175524.6184-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usbnet:
- Remove stale new_mtu <= 0 check in usbnet.c
- Set min_mtu = 0, max_mtu = 65535 (sub-drivers must set their own
  max_mtu and/or min_mtu as needed)

r8152:
- Set appropriate max_mtu for different variants (1500 or 9194)

lan78xx:
- Set max_mtu = 9000

asix_driver:
- max_mtu = 16384 for ax88178 variant

ax88179:
- max_mtu = 4088

cdc_ncm:
- max_mtu from hardware

cdc-phonet:
- min_mtu = 6, max_mtu = 65541

sierra_net:
- max_mtu = 1500, call usbnet_change_mtu directly
- sierra_net_change_mtu checked for MTU > 1500, then called
  usbnet_change_mtu, but if we set max_mtu to let the network core handle
  the range check, then we can simply call usbnet_change_mtu directly

smsc75xx:
- max_mtu = 9000

CC: netdev@vger.kernel.org
CC: Woojung Huh <woojung.huh@microchip.com>
CC: Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
CC: Hayes Wang <hayeswang@realtek.com>
CC: Oliver Neukum <oneukum@suse.com>
CC: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/usb/asix_devices.c |  4 +---
 drivers/net/usb/ax88179_178a.c |  4 +---
 drivers/net/usb/cdc-phonet.c   | 12 ++----------
 drivers/net/usb/cdc_ncm.c      |  5 +----
 drivers/net/usb/lan78xx.c      |  8 +++-----
 drivers/net/usb/r8152.c        | 15 ++++++++++++---
 drivers/net/usb/sierra_net.c   | 13 ++-----------
 drivers/net/usb/smsc75xx.c     |  4 +---
 drivers/net/usb/usbnet.c       |  4 ++--
 9 files changed, 25 insertions(+), 44 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index cce2495..7363cc5 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -1026,9 +1026,6 @@ static int ax88178_change_mtu(struct net_device *net, int new_mtu)
 
 	netdev_dbg(dev->net, "ax88178_change_mtu() new_mtu=%d\n", new_mtu);
 
-	if (new_mtu <= 0 || ll_mtu > 16384)
-		return -EINVAL;
-
 	if ((ll_mtu % dev->maxpacket) == 0)
 		return -EDOM;
 
@@ -1081,6 +1078,7 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev->net->netdev_ops = &ax88178_netdev_ops;
 	dev->net->ethtool_ops = &ax88178_ethtool_ops;
+	dev->net->max_mtu = 16384 - (dev->net->hard_header_len + 4);
 
 	/* Blink LEDS so users know driver saw dongle */
 	asix_sw_reset(dev, 0, 0);
diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index e6338c1..36c70d6 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -907,9 +907,6 @@ static int ax88179_change_mtu(struct net_device *net, int new_mtu)
 	struct usbnet *dev = netdev_priv(net);
 	u16 tmp16;
 
-	if (new_mtu <= 0 || new_mtu > 4088)
-		return -EINVAL;
-
 	net->mtu = new_mtu;
 	dev->hard_mtu = net->mtu + net->hard_header_len;
 
@@ -1266,6 +1263,7 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->netdev_ops = &ax88179_netdev_ops;
 	dev->net->ethtool_ops = &ax88179_ethtool_ops;
 	dev->net->needed_headroom = 8;
+	dev->net->max_mtu = 4088;
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index ff2270e..eb52de8 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -276,21 +276,11 @@ static int usbpn_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -ENOIOCTLCMD;
 }
 
-static int usbpn_set_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < PHONET_MIN_MTU) || (new_mtu > PHONET_MAX_MTU))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct net_device_ops usbpn_ops = {
 	.ndo_open	= usbpn_open,
 	.ndo_stop	= usbpn_close,
 	.ndo_start_xmit = usbpn_xmit,
 	.ndo_do_ioctl	= usbpn_ioctl,
-	.ndo_change_mtu = usbpn_set_mtu,
 };
 
 static void usbpn_setup(struct net_device *dev)
@@ -301,6 +291,8 @@ static void usbpn_setup(struct net_device *dev)
 	dev->type		= ARPHRD_PHONET;
 	dev->flags		= IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu		= PHONET_MAX_MTU;
+	dev->min_mtu		= PHONET_MIN_MTU;
+	dev->max_mtu		= PHONET_MAX_MTU;
 	dev->hard_header_len	= 1;
 	dev->dev_addr[0]	= PN_MEDIA_USB;
 	dev->addr_len		= 1;
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 877c951..7141817 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -740,10 +740,6 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 int cdc_ncm_change_mtu(struct net_device *net, int new_mtu)
 {
 	struct usbnet *dev = netdev_priv(net);
-	int maxmtu = cdc_ncm_max_dgram_size(dev) - cdc_ncm_eth_hlen(dev);
-
-	if (new_mtu <= 0 || new_mtu > maxmtu)
-		return -EINVAL;
 
 	net->mtu = new_mtu;
 	cdc_ncm_set_dgram_size(dev, new_mtu + cdc_ncm_eth_hlen(dev));
@@ -909,6 +905,7 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_
 
 	/* must handle MTU changes */
 	dev->net->netdev_ops = &cdc_ncm_netdev_ops;
+	dev->net->max_mtu = cdc_ncm_max_dgram_size(dev) - cdc_ncm_eth_hlen(dev);
 
 	return 0;
 
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 13f033c..c4e748e 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1980,11 +1980,6 @@ static int lan78xx_change_mtu(struct net_device *netdev, int new_mtu)
 	int old_rx_urb_size = dev->rx_urb_size;
 	int ret;
 
-	if (new_mtu > MAX_SINGLE_PACKET_SIZE)
-		return -EINVAL;
-
-	if (new_mtu <= 0)
-		return -EINVAL;
 	/* no second zero-length packet read wanted after mtu-sized packets */
 	if ((ll_mtu % dev->maxpacket) == 0)
 		return -EDOM;
@@ -3388,6 +3383,9 @@ static int lan78xx_probe(struct usb_interface *intf,
 	if (netdev->mtu > (dev->hard_mtu - netdev->hard_header_len))
 		netdev->mtu = dev->hard_mtu - netdev->hard_header_len;
 
+	/* MTU range: 68 - 9000 */
+	netdev->max_mtu = MAX_SINGLE_PACKET_SIZE;
+
 	dev->ep_blkin = (intf->cur_altsetting)->endpoint + 0;
 	dev->ep_blkout = (intf->cur_altsetting)->endpoint + 1;
 	dev->ep_intr = (intf->cur_altsetting)->endpoint + 2;
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8d6e13c..4213c28 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4119,9 +4119,6 @@ static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 		break;
 	}
 
-	if (new_mtu < 68 || new_mtu > RTL8153_MAX_MTU)
-		return -EINVAL;
-
 	ret = usb_autopm_get_interface(tp->intf);
 	if (ret < 0)
 		return ret;
@@ -4311,6 +4308,18 @@ static int rtl8152_probe(struct usb_interface *intf,
 	netdev->ethtool_ops = &ops;
 	netif_set_gso_max_size(netdev, RTL_LIMITED_TSO_SIZE);
 
+	/* MTU range: 68 - 1500 or 9194 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	switch (tp->version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		netdev->max_mtu = ETH_DATA_LEN;
+		break;
+	default:
+		netdev->max_mtu = RTL8153_MAX_MTU;
+		break;
+	}
+
 	tp->mii.dev = netdev;
 	tp->mii.mdio_read = read_mii_word;
 	tp->mii.mdio_write = write_mii_word;
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index a2515887..12071f1 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -165,7 +165,6 @@ struct lsi_umts {
 
 /* Forward definitions */
 static void sierra_sync_timer(unsigned long syncdata);
-static int sierra_net_change_mtu(struct net_device *net, int new_mtu);
 
 /* Our own net device operations structure */
 static const struct net_device_ops sierra_net_device_ops = {
@@ -173,7 +172,7 @@ static const struct net_device_ops sierra_net_device_ops = {
 	.ndo_stop               = usbnet_stop,
 	.ndo_start_xmit         = usbnet_start_xmit,
 	.ndo_tx_timeout         = usbnet_tx_timeout,
-	.ndo_change_mtu         = sierra_net_change_mtu,
+	.ndo_change_mtu         = usbnet_change_mtu,
 	.ndo_set_mac_address    = eth_mac_addr,
 	.ndo_validate_addr      = eth_validate_addr,
 };
@@ -622,15 +621,6 @@ static const struct ethtool_ops sierra_net_ethtool_ops = {
 	.nway_reset = usbnet_nway_reset,
 };
 
-/* MTU can not be more than 1500 bytes, enforce it. */
-static int sierra_net_change_mtu(struct net_device *net, int new_mtu)
-{
-	if (new_mtu > SIERRA_NET_MAX_SUPPORTED_MTU)
-		return -EINVAL;
-
-	return usbnet_change_mtu(net, new_mtu);
-}
-
 static int sierra_net_get_fw_attr(struct usbnet *dev, u16 *datap)
 {
 	int result = 0;
@@ -720,6 +710,7 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev->net->hard_header_len += SIERRA_NET_HIP_EXT_HDR_LEN;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+	dev->net->max_mtu = SIERRA_NET_MAX_SUPPORTED_MTU;
 
 	/* Set up the netdev */
 	dev->net->flags |= IFF_NOARP;
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 9af9799..0b17b40 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -925,9 +925,6 @@ static int smsc75xx_change_mtu(struct net_device *netdev, int new_mtu)
 	struct usbnet *dev = netdev_priv(netdev);
 	int ret;
 
-	if (new_mtu > MAX_SINGLE_PACKET_SIZE)
-		return -EINVAL;
-
 	ret = smsc75xx_set_rx_max_frame_length(dev, new_mtu + ETH_HLEN);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to set mac rx frame length\n");
@@ -1448,6 +1445,7 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC75XX_TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+	dev->net->max_mtu = MAX_SINGLE_PACKET_SIZE;
 	return 0;
 }
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index d5071e3..3de65ea 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -384,8 +384,6 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 	int		old_hard_mtu = dev->hard_mtu;
 	int		old_rx_urb_size = dev->rx_urb_size;
 
-	if (new_mtu <= 0)
-		return -EINVAL;
 	// no second zero-length packet read wanted after mtu-sized packets
 	if ((ll_mtu % dev->maxpacket) == 0)
 		return -EDOM;
@@ -1669,6 +1667,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	 * bind() should set rx_urb_size in that case.
 	 */
 	dev->hard_mtu = net->mtu + net->hard_header_len;
+	net->min_mtu = 0;
+	net->max_mtu = ETH_MAX_MTU;
 
 	net->netdev_ops = &usbnet_netdev_ops;
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
-- 
2.10.0
