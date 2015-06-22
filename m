From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [Patch v1] ax88179_178a: add reset functionality in reset_resume
Date: Mon, 22 Jun 2015 12:33:42 +0200
Message-ID: <1434969222.660.3.camel@suse.com>
References: <CA+vmRF7nC2Ndzzt+QRj2YG7yQEtHw=3ZBuNBCqyM7nqErFoU-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vivek Bhagat <vivek.bhagat89-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+vmRF7nC2Ndzzt+QRj2YG7yQEtHw=3ZBuNBCqyM7nqErFoU-g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-06-21 at 11:46 +0530, Vivek Bhagat wrote:
> Without reset functionality in reset_resume, iperf connection does not
> establish after suspend/resume however ping works at the same time.
> iperf connection fails with wrong checksum error shown by tcpdump.
> 
> reset function inside reset_resume solves above bug. We have verified
> this issue on ASIX based ST Lab, Cadyce dongle.

Well, you the experiment rules. This highlights, however, a lot
of duplication in the code paths for reset and bind.
Does this patch on top of yours work for you?

	Regards
		Oliver

>From 0ae01a2eacf4db10d5d299c6567fd3272ad9a1c2 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Date: Mon, 22 Jun 2015 12:28:55 +0200
Subject: [PATCH] ax88179: unify common code in bind and reset

In both code paths the device is set up anew.
So let's unify them.

Signed-off-by: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/usb/ax88179_178a.c | 152 ++++++++++++++---------------------------
 1 file changed, 52 insertions(+), 100 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 00928c0..02c9f5c 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1220,21 +1220,15 @@ static int ax88179_led_setting(struct usbnet *dev)
 	return 0;
 }
 
-static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
+static void setup_chip(struct usbnet *dev, bool phy_auto_detach)
 {
 	u8 buf[5];
 	u16 *tmp16;
 	u8 *tmp;
-	struct ax88179_data *ax179_data = (struct ax88179_data *)dev->data;
-	struct ethtool_eee eee_data;
-
-	usbnet_get_endpoints(dev, intf);
 
 	tmp16 = (u16 *)buf;
 	tmp = (u8 *)buf;
 
-	memset(ax179_data, 0, sizeof(*ax179_data));
-
 	/* Power up ethernet PHY */
 	*tmp16 = 0;
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
@@ -1246,6 +1240,11 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp);
 	msleep(100);
 
+	if (phy_auto_detach) {
+		/* Ethernet PHY Auto Detach*/
+		ax88179_auto_detach(dev, 0);
+	}
+
 	ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN,
 			 ETH_ALEN, dev->net->dev_addr);
 	memcpy(dev->net->perm_addr, dev->net->dev_addr, ETH_ALEN);
@@ -1254,27 +1253,24 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	memcpy(tmp, &AX88179_BULKIN_SIZE[0], 5);
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_BULKIN_QCTRL, 5, 5, tmp);
 
-	dev->rx_urb_size = 1024 * 20;
-
 	*tmp = 0x34;
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PAUSE_WATERLVL_LOW, 1, 1, tmp);
 
 	*tmp = 0x52;
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PAUSE_WATERLVL_HIGH,
 			  1, 1, tmp);
+}
 
-	dev->net->netdev_ops = &ax88179_netdev_ops;
-	dev->net->ethtool_ops = &ax88179_ethtool_ops;
-	dev->net->needed_headroom = 8;
+static void start_chip(struct usbnet *dev)
+{
+	u8 buf[5];
+	u16 *tmp16;
+	u8 *tmp;
+	struct ethtool_eee eee_data;
+	struct ax88179_data *ax179_data = (struct ax88179_data *)dev->data;
 
-	/* Initialize MII structure */
-	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = ax88179_mdio_read;
-	dev->mii.mdio_write = ax88179_mdio_write;
-	dev->mii.phy_id_mask = 0xff;
-	dev->mii.reg_num_mask = 0xff;
-	dev->mii.phy_id = 0x03;
-	dev->mii.supports_gmii = 1;
+	tmp16 = (u16 *)buf;
+	tmp = (u8 *)buf;
 
 	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			      NETIF_F_RXCSUM;
@@ -1322,6 +1318,40 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	mii_nway_restart(&dev->mii);
 
 	usbnet_link_change(dev, 0, 0);
+}
+
+static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	u8 buf[5];
+	u16 *tmp16;
+	u8 *tmp;
+	struct ax88179_data *ax179_data = (struct ax88179_data *)dev->data;
+
+	usbnet_get_endpoints(dev, intf);
+
+	tmp16 = (u16 *)buf;
+	tmp = (u8 *)buf;
+
+	memset(ax179_data, 0, sizeof(*ax179_data));
+
+	setup_chip(dev, false);
+
+	dev->rx_urb_size = 1024 * 20;
+
+	dev->net->netdev_ops = &ax88179_netdev_ops;
+	dev->net->ethtool_ops = &ax88179_ethtool_ops;
+	dev->net->needed_headroom = 8;
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax88179_mdio_read;
+	dev->mii.mdio_write = ax88179_mdio_write;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;
+	dev->mii.phy_id = 0x03;
+	dev->mii.supports_gmii = 1;
+
+	start_chip(dev);
 
 	return 0;
 }
@@ -1529,90 +1559,12 @@ static int ax88179_reset(struct usbnet *dev)
 	u8 buf[5];
 	u16 *tmp16;
 	u8 *tmp;
-	struct ax88179_data *ax179_data = (struct ax88179_data *)dev->data;
-	struct ethtool_eee eee_data;
 
 	tmp16 = (u16 *)buf;
 	tmp = (u8 *)buf;
 
-	/* Power up ethernet PHY */
-	*tmp16 = 0;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
-
-	*tmp16 = AX_PHYPWR_RSTCTL_IPRL;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
-	msleep(200);
-
-	*tmp = AX_CLK_SELECT_ACS | AX_CLK_SELECT_BCS;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp);
-	msleep(100);
-
-	/* Ethernet PHY Auto Detach*/
-	ax88179_auto_detach(dev, 0);
-
-	ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN, ETH_ALEN,
-			 dev->net->dev_addr);
-	memcpy(dev->net->perm_addr, dev->net->dev_addr, ETH_ALEN);
-
-	/* RX bulk configuration */
-	memcpy(tmp, &AX88179_BULKIN_SIZE[0], 5);
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_BULKIN_QCTRL, 5, 5, tmp);
-
-	dev->rx_urb_size = 1024 * 20;
-
-	*tmp = 0x34;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PAUSE_WATERLVL_LOW, 1, 1, tmp);
-
-	*tmp = 0x52;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PAUSE_WATERLVL_HIGH,
-			  1, 1, tmp);
-
-	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			      NETIF_F_RXCSUM;
-
-	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				 NETIF_F_RXCSUM;
-
-	/* Enable checksum offload */
-	*tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
-	       AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RXCOE_CTL, 1, 1, tmp);
-
-	*tmp = AX_TXCOE_IP | AX_TXCOE_TCP | AX_TXCOE_UDP |
-	       AX_TXCOE_TCPV6 | AX_TXCOE_UDPV6;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
-
-	/* Configure RX control register => start operation */
-	*tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_IPE | AX_RX_CTL_START |
-		 AX_RX_CTL_AP | AX_RX_CTL_AMALL | AX_RX_CTL_AB;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_CTL, 2, 2, tmp16);
-
-	*tmp = AX_MONITOR_MODE_PMETYPE | AX_MONITOR_MODE_PMEPOL |
-	       AX_MONITOR_MODE_RWMP;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MONITOR_MOD, 1, 1, tmp);
-
-	/* Configure default medium type => giga */
-	*tmp16 = AX_MEDIUM_RECEIVE_EN | AX_MEDIUM_TXFLOW_CTRLEN |
-		 AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_FULL_DUPLEX |
-		 AX_MEDIUM_GIGAMODE;
-	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MEDIUM_STATUS_MODE,
-			  2, 2, tmp16);
-
-	ax88179_led_setting(dev);
-
-	ax179_data->eee_enabled = 0;
-	ax179_data->eee_active = 0;
-
-	ax88179_disable_eee(dev);
-
-	ax88179_ethtool_get_eee(dev, &eee_data);
-	eee_data.advertised = 0;
-	ax88179_ethtool_set_eee(dev, &eee_data);
-
-	/* Restart autoneg */
-	mii_nway_restart(&dev->mii);
