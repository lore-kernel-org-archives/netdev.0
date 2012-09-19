From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH v2] USB: remove dbg() usage in USB networking drivers
Date: Wed, 19 Sep 2012 20:46:14 +0100
Message-ID: <20120919194614.GA17585@kroah.com>
References: <20120919171316.GA12248@kroah.com>
 <1348077212.22122.13.camel@joe2Laptop>
 <20120919193536.GA13933@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120919193536.GA13933@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

The dbg() USB macro is so old, it predates me.  The USB networking drivers are
the last hold-out using this macro, and we want to get rid of it, so replace
the usage of it with the proper netdev_dbg() or dev_dbg() (depending on the
context) calls.

Some places we end up using a local variable for the debug call, so also
convert the other existing dev_* calls to use it as well, to save tiny amounts
of code space.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
v2: Addressed review comments from Joe Perches

Again, I am glad to take this in the usb-next tree if wanted, whatever is
easiest.

 drivers/net/usb/asix_devices.c |  36 ++++++++++++++------------
 drivers/net/usb/catc.c         |  55 ++++++++++++++++++++++-----------------
 drivers/net/usb/gl620a.c       |  10 +++++---
 drivers/net/usb/kaweth.c       | 134 ++++++++++++++++++++++++++++++++++++++++++++++++------------------------------------------------
 drivers/net/usb/net1080.c      |  48 +++++++++++++++++------------------
 drivers/net/usb/rtl8150.c      |   6 ++---
 6 files changed, 152 insertions(+), 137 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 4fd48df..8d5fdf1 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -221,7 +221,8 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* Get the MAC address */
 	ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
 	if (ret < 0) {
-		dbg("read AX_CMD_READ_NODE_ID failed: %d", ret);
+		netdev_dbg(dev->net, "read AX_CMD_READ_NODE_ID failed: %d\n",
+			   ret);
 		goto out;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
@@ -303,7 +304,7 @@ static int ax88772_reset(struct usbnet *dev)
 
 	ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
 	if (ret < 0) {
-		dbg("Select PHY #1 failed: %d", ret);
+		netdev_dbg(dev->net, "Select PHY #1 failed: %d\n", ret);
 		goto out;
 	}
 
@@ -331,13 +332,13 @@ static int ax88772_reset(struct usbnet *dev)
 
 	msleep(150);
 	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x after software reset", rx_ctl);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset\n", rx_ctl);
 	ret = asix_write_rx_ctl(dev, 0x0000);
 	if (ret < 0)
 		goto out;
 
 	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000\n", rx_ctl);
 
 	ret = asix_sw_reset(dev, AX_SWRESET_PRL);
 	if (ret < 0)
@@ -364,7 +365,7 @@ static int ax88772_reset(struct usbnet *dev)
 				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
 				AX88772_IPG2_DEFAULT, 0, NULL);
 	if (ret < 0) {
-		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
+		netdev_dbg(dev->net, "Write IPG,IPG1,IPG2 failed: %d\n", ret);
 		goto out;
 	}
 
@@ -381,10 +382,13 @@ static int ax88772_reset(struct usbnet *dev)
 		goto out;
 
 	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x after all initializations", rx_ctl);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations\n",
+		   rx_ctl);
 
 	rx_ctl = asix_read_medium_status(dev);
-	dbg("Medium Status is 0x%04x after all initializations", rx_ctl);
+	netdev_dbg(dev->net,
+		   "Medium Status is 0x%04x after all initializations\n",
+		   rx_ctl);
 
 	return 0;
 
@@ -416,7 +420,7 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* Get the MAC address */
 	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
 	if (ret < 0) {
-		dbg("Failed to read MAC address: %d", ret);
+		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
@@ -439,7 +443,7 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* Reset the PHY to normal operation mode */
 	ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
 	if (ret < 0) {
-		dbg("Select PHY #1 failed: %d", ret);
+		netdev_dbg(dev->net, "Select PHY #1 failed: %d\n", ret);
 		return ret;
 	}
 
@@ -459,7 +463,7 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* Read PHYID register *AFTER* the PHY was reset properly */
 	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
+	netdev_dbg(dev->net, "PHYID=0x%08x\n", phyid);
 
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
@@ -575,13 +579,13 @@ static int ax88178_reset(struct usbnet *dev)
 	u32 phyid;
 
 	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
-	dbg("GPIO Status: 0x%04x", status);
+	netdev_dbg(dev->net, "GPIO Status: 0x%04x\n", status);
 
 	asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
 	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
 	asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL);
 
-	dbg("EEPROM index 0x17 is 0x%04x", eeprom);
+	netdev_dbg(dev->net, "EEPROM index 0x17 is 0x%04x\n", eeprom);
 
 	if (eeprom == cpu_to_le16(0xffff)) {
 		data->phymode = PHY_MODE_MARVELL;
@@ -592,7 +596,7 @@ static int ax88178_reset(struct usbnet *dev)
 		data->ledmode = le16_to_cpu(eeprom) >> 8;
 		gpio0 = (le16_to_cpu(eeprom) & 0x80) ? 0 : 1;
 	}
-	dbg("GPIO0: %d, PhyMode: %d", gpio0, data->phymode);
+	netdev_dbg(dev->net, "GPIO0: %d, PhyMode: %d\n", gpio0, data->phymode);
 
 	/* Power up external GigaPHY through AX88178 GPIO pin */
 	asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
@@ -601,14 +605,14 @@ static int ax88178_reset(struct usbnet *dev)
 		asix_write_gpio(dev, 0x001c, 300);
 		asix_write_gpio(dev, 0x003c, 30);
 	} else {
-		dbg("gpio phymode == 1 path");
+		netdev_dbg(dev->net, "gpio phymode == 1 path\n");
 		asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
 		asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30);
 	}
 
 	/* Read PHYID register *AFTER* powering up PHY */
 	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
+	netdev_dbg(dev->net, "PHYID=0x%08x\n", phyid);
 
 	/* Set AX88178 to enable MII/GMII/RGMII interface for external PHY */
 	asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 0, NULL);
@@ -770,7 +774,7 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* Get the MAC address */
 	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
 	if (ret < 0) {
-		dbg("Failed to read MAC address: %d", ret);
+		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 26c5beb..18d9579 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -236,7 +236,8 @@ static void catc_rx_done(struct urb *urb)
 	}
 
 	if (status) {
-		dbg("rx_done, status %d, length %d", status, urb->actual_length);
+		dev_dbg(&urb->dev->dev, "rx_done, status %d, length %d\n",
+			status, urb->actual_length);
 		return;
 	}
 
@@ -275,10 +276,11 @@ static void catc_rx_done(struct urb *urb)
 		if (atomic_read(&catc->recq_sz)) {
 			int state;
 			atomic_dec(&catc->recq_sz);
-			dbg("getting extra packet");
+			netdev_dbg(catc->netdev, "getting extra packet\n");
 			urb->dev = catc->usbdev;
 			if ((state = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
-				dbg("submit(rx_urb) status %d", state);
+				netdev_dbg(catc->netdev,
+					   "submit(rx_urb) status %d\n", state);
 			}
 		} else {
 			clear_bit(RX_RUNNING, &catc->flags);
@@ -317,18 +319,20 @@ static void catc_irq_done(struct urb *urb)
 		return;
 	/* -EPIPE:  should clear the halt */
 	default:		/* error */
-		dbg("irq_done, status %d, data %02x %02x.", status, data[0], data[1]);
+		dev_dbg(&urb->dev->dev,
+			"irq_done, status %d, data %02x %02x.\n",
+			status, data[0], data[1]);
 		goto resubmit;
 	}
 
 	if (linksts == LinkGood) {
 		netif_carrier_on(catc->netdev);
-		dbg("link ok");
+		netdev_dbg(catc->netdev, "link ok\n");
 	}
 
 	if (linksts == LinkBad) {
 		netif_carrier_off(catc->netdev);
-		dbg("link bad");
+		netdev_dbg(catc->netdev, "link bad\n");
 	}
 
 	if (hasdata) {
@@ -385,7 +389,7 @@ static void catc_tx_done(struct urb *urb)
 	int r, status = urb->status;
 
 	if (status == -ECONNRESET) {
-		dbg("Tx Reset.");
+		dev_dbg(&urb->dev->dev, "Tx Reset.\n");
 		urb->status = 0;
 		catc->netdev->trans_start = jiffies;
 		catc->netdev->stats.tx_errors++;
@@ -395,7 +399,8 @@ static void catc_tx_done(struct urb *urb)
 	}
 
 	if (status) {
-		dbg("tx_done, status %d, length %d", status, urb->actual_length);
+		dev_dbg(&urb->dev->dev, "tx_done, status %d, length %d\n",
+			status, urb->actual_length);
 		return;
 	}
 
@@ -511,7 +516,8 @@ static void catc_ctrl_done(struct urb *urb)
 	int status = urb->status;
 
 	if (status)
-		dbg("ctrl_done, status %d, len %d.", status, urb->actual_length);
+		dev_dbg(&urb->dev->dev, "ctrl_done, status %d, len %d.\n",
+			status, urb->actual_length);
 
 	spin_lock_irqsave(&catc->ctrl_lock, flags);
 
@@ -667,7 +673,9 @@ static void catc_set_multicast_list(struct net_device *netdev)
 		f5u011_mchash_async(catc, catc->multicast);
 		if (catc->rxmode[0] != rx) {
 			catc->rxmode[0] = rx;
-			dbg("Setting RX mode to %2.2X %2.2X", catc->rxmode[0], catc->rxmode[1]);
+			netdev_dbg(catc->netdev,
+				   "Setting RX mode to %2.2X %2.2X\n",
+				   catc->rxmode[0], catc->rxmode[1]);
 			f5u011_rxmode_async(catc, catc->rxmode);
 		}
 	}
@@ -766,6 +774,7 @@ static const struct net_device_ops catc_netdev_ops = {
 
 static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
+	struct device *dev = &intf->dev;
 	struct usb_device *usbdev = interface_to_usbdev(intf);
 	struct net_device *netdev;
 	struct catc *catc;
@@ -774,7 +783,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 
 	if (usb_set_interface(usbdev,
 			intf->altsetting->desc.bInterfaceNumber, 1)) {
-                dev_err(&intf->dev, "Can't set altsetting 1.\n");
+		dev_err(dev, "Can't set altsetting 1.\n");
 		return -EIO;
 	}
 
@@ -817,7 +826,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	if (le16_to_cpu(usbdev->descriptor.idVendor) == 0x0423 && 
 	    le16_to_cpu(usbdev->descriptor.idProduct) == 0xa &&
 	    le16_to_cpu(catc->usbdev->descriptor.bcdDevice) == 0x0130) {
-		dbg("Testing for f5u011");
+		dev_dbg(dev, "Testing for f5u011\n");
 		catc->is_f5u011 = 1;		
 		atomic_set(&catc->recq_sz, 0);
 		pktsz = RX_PKT_SZ;
@@ -838,7 +847,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
                 catc->irq_buf, 2, catc_irq_done, catc, 1);
 
 	if (!catc->is_f5u011) {
-		dbg("Checking memory size\n");
+		dev_dbg(dev, "Checking memory size\n");
 
 		i = 0x12345678;
 		catc_write_mem(catc, 0x7a80, &i, 4);
@@ -850,7 +859,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 		case 0x12345678:
 			catc_set_reg(catc, TxBufCount, 8);
 			catc_set_reg(catc, RxBufCount, 32);
-			dbg("64k Memory\n");
+			dev_dbg(dev, "64k Memory\n");
 			break;
 		default:
 			dev_warn(&intf->dev,
@@ -858,49 +867,49 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 		case 0x87654321:
 			catc_set_reg(catc, TxBufCount, 4);
 			catc_set_reg(catc, RxBufCount, 16);
-			dbg("32k Memory\n");
+			dev_dbg(dev, "32k Memory\n");
 			break;
 		}
 	  
-		dbg("Getting MAC from SEEROM.");
+		dev_dbg(dev, "Getting MAC from SEEROM.\n");
 	  
 		catc_get_mac(catc, netdev->dev_addr);
 		
-		dbg("Setting MAC into registers.");
+		dev_dbg(dev, "Setting MAC into registers.\n");
 	  
 		for (i = 0; i < 6; i++)
 			catc_set_reg(catc, StationAddr0 - i, netdev->dev_addr[i]);
 		
-		dbg("Filling the multicast list.");
+		dev_dbg(dev, "Filling the multicast list.\n");
 	  
 		memset(broadcast, 0xff, 6);
 		catc_multicast(broadcast, catc->multicast);
 		catc_multicast(netdev->dev_addr, catc->multicast);
 		catc_write_mem(catc, 0xfa80, catc->multicast, 64);
 		
-		dbg("Clearing error counters.");
+		dev_dbg(dev, "Clearing error counters.\n");
 		
 		for (i = 0; i < 8; i++)
 			catc_set_reg(catc, EthStats + i, 0);
 		catc->last_stats = jiffies;
 		
-		dbg("Enabling.");
+		dev_dbg(dev, "Enabling.\n");
 		
 		catc_set_reg(catc, MaxBurst, RX_MAX_BURST);
 		catc_set_reg(catc, OpModes, OpTxMerge | OpRxMerge | OpLenInclude | Op3MemWaits);
 		catc_set_reg(catc, LEDCtrl, LEDLink);
 		catc_set_reg(catc, RxUnit, RxEnable | RxPolarity | RxMultiCast);
 	} else {
-		dbg("Performing reset\n");
+		dev_dbg(dev, "Performing reset\n");
 		catc_reset(catc);
 		catc_get_mac(catc, netdev->dev_addr);
 		
-		dbg("Setting RX Mode");
+		dev_dbg(dev, "Setting RX Mode\n");
 		catc->rxmode[0] = RxEnable | RxPolarity | RxMultiCast;
 		catc->rxmode[1] = 0;
 		f5u011_rxmode(catc, catc->rxmode);
 	}
-	dbg("Init done.");
+	dev_dbg(dev, "Init done.\n");
 	printk(KERN_INFO "%s: %s USB Ethernet at usb-%s-%s, %pM.\n",
 	       netdev->name, (catc->is_f5u011) ? "Belkin F5U011" : "CATC EL1210A NetMate",
 	       usbdev->bus->bus_name, usbdev->devpath, netdev->dev_addr);
diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
index db3c802..a7e3f4e 100644
--- a/drivers/net/usb/gl620a.c
+++ b/drivers/net/usb/gl620a.c
@@ -91,7 +91,9 @@ static int genelink_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	// get the packet count of the received skb
 	count = le32_to_cpu(header->packet_count);
 	if (count > GL_MAX_TRANSMIT_PACKETS) {
-		dbg("genelink: invalid received packet count %u", count);
+		netdev_dbg(dev->net,
+			   "genelink: invalid received packet count %u\n",
+			   count);
 		return 0;
 	}
 
@@ -107,7 +109,8 @@ static int genelink_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		// this may be a broken packet
 		if (size > GL_MAX_PACKET_LEN) {
-			dbg("genelink: invalid rx length %d", size);
+			netdev_dbg(dev->net, "genelink: invalid rx length %d\n",
+				   size);
 			return 0;
 		}
 
@@ -133,7 +136,8 @@ static int genelink_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	skb_pull(skb, 4);
 
 	if (skb->len > GL_MAX_PACKET_LEN) {
-		dbg("genelink: invalid rx length %d", skb->len);
+		netdev_dbg(dev->net, "genelink: invalid rx length %d\n",
+			   skb->len);
 		return 0;
 	}
 	return 1;
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index c3d0349..c75e11e 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -267,19 +267,16 @@ static int kaweth_control(struct kaweth_device *kaweth,
 	struct usb_ctrlrequest *dr;
 	int retval;
 
-	dbg("kaweth_control()");
+	netdev_dbg(kaweth->net, "kaweth_control()\n");
 
 	if(in_interrupt()) {
-		dbg("in_interrupt()");
+		netdev_dbg(kaweth->net, "in_interrupt()\n");
 		return -EBUSY;
 	}
 
 	dr = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
-
-	if (!dr) {
-		dbg("kmalloc() failed");
+	if (!dr)
 		return -ENOMEM;
-	}
 
 	dr->bRequestType = requesttype;
 	dr->bRequest = request;
@@ -305,7 +302,7 @@ static int kaweth_read_configuration(struct kaweth_device *kaweth)
 {
 	int retval;
 
-	dbg("Reading kaweth configuration");
+	netdev_dbg(kaweth->net, "Reading kaweth configuration\n");
 
 	retval = kaweth_control(kaweth,
 				usb_rcvctrlpipe(kaweth->dev, 0),
@@ -327,7 +324,7 @@ static int kaweth_set_urb_size(struct kaweth_device *kaweth, __u16 urb_size)
 {
 	int retval;
 
-	dbg("Setting URB size to %d", (unsigned)urb_size);
+	netdev_dbg(kaweth->net, "Setting URB size to %d\n", (unsigned)urb_size);
 
 	retval = kaweth_control(kaweth,
 				usb_sndctrlpipe(kaweth->dev, 0),
@@ -349,7 +346,7 @@ static int kaweth_set_sofs_wait(struct kaweth_device *kaweth, __u16 sofs_wait)
 {
 	int retval;
 
-	dbg("Set SOFS wait to %d", (unsigned)sofs_wait);
+	netdev_dbg(kaweth->net, "Set SOFS wait to %d\n", (unsigned)sofs_wait);
 
 	retval = kaweth_control(kaweth,
 				usb_sndctrlpipe(kaweth->dev, 0),
@@ -372,7 +369,8 @@ static int kaweth_set_receive_filter(struct kaweth_device *kaweth,
 {
 	int retval;
 
-	dbg("Set receive filter to %d", (unsigned)receive_filter);
+	netdev_dbg(kaweth->net, "Set receive filter to %d\n",
+		   (unsigned)receive_filter);
 
 	retval = kaweth_control(kaweth,
 				usb_sndctrlpipe(kaweth->dev, 0),
@@ -421,12 +419,13 @@ static int kaweth_download_firmware(struct kaweth_device *kaweth,
 	kaweth->firmware_buf[4] = type;
 	kaweth->firmware_buf[5] = interrupt;
 
-	dbg("High: %i, Low:%i", kaweth->firmware_buf[3],
+	netdev_dbg(kaweth->net, "High: %i, Low:%i\n", kaweth->firmware_buf[3],
 		   kaweth->firmware_buf[2]);
 
-	dbg("Downloading firmware at %p to kaweth device at %p",
-	    fw->data, kaweth);
-	dbg("Firmware length: %d", data_len);
+	netdev_dbg(kaweth->net,
+		   "Downloading firmware at %p to kaweth device at %p\n",
+		   fw->data, kaweth);
+	netdev_dbg(kaweth->net, "Firmware length: %d\n", data_len);
 
 	return kaweth_control(kaweth,
 		              usb_sndctrlpipe(kaweth->dev, 0),
@@ -454,7 +453,7 @@ static int kaweth_trigger_firmware(struct kaweth_device *kaweth,
 	kaweth->firmware_buf[6] = 0x00;
 	kaweth->firmware_buf[7] = 0x00;
 
-	dbg("Triggering firmware");
+	netdev_dbg(kaweth->net, "Triggering firmware\n");
 
 	return kaweth_control(kaweth,
 			      usb_sndctrlpipe(kaweth->dev, 0),
@@ -474,11 +473,11 @@ static int kaweth_reset(struct kaweth_device *kaweth)
 {
 	int result;
 
-	dbg("kaweth_reset(%p)", kaweth);
+	netdev_dbg(kaweth->net, "kaweth_reset(%p)\n", kaweth);
 	result = usb_reset_configuration(kaweth->dev);
 	mdelay(10);
 
-	dbg("kaweth_reset() returns %d.",result);
+	netdev_dbg(kaweth->net, "kaweth_reset() returns %d.\n", result);
 
 	return result;
 }
@@ -595,6 +594,7 @@ static void kaweth_async_set_rx_mode(struct kaweth_device *kaweth);
  ****************************************************************/
 static void kaweth_usb_receive(struct urb *urb)
 {
+	struct device *dev = &urb->dev->dev;
 	struct kaweth_device *kaweth = urb->context;
 	struct net_device *net = kaweth->net;
 	int status = urb->status;
@@ -610,25 +610,25 @@ static void kaweth_usb_receive(struct urb *urb)
 		kaweth->stats.rx_errors++;
 		kaweth->end = 1;
 		wake_up(&kaweth->term_wait);
-		dbg("Status was -EPIPE.");
+		dev_dbg(dev, "Status was -EPIPE.\n");
 		return;
 	}
 	if (unlikely(status == -ECONNRESET || status == -ESHUTDOWN)) {
 		/* we are killed - set a flag and wake the disconnect handler */
 		kaweth->end = 1;
 		wake_up(&kaweth->term_wait);
-		dbg("Status was -ECONNRESET or -ESHUTDOWN.");
+		dev_dbg(dev, "Status was -ECONNRESET or -ESHUTDOWN.\n");
 		return;
 	}
 	if (unlikely(status == -EPROTO || status == -ETIME ||
 		     status == -EILSEQ)) {
 		kaweth->stats.rx_errors++;
-		dbg("Status was -EPROTO, -ETIME, or -EILSEQ.");
+		dev_dbg(dev, "Status was -EPROTO, -ETIME, or -EILSEQ.\n");
 		return;
 	}
 	if (unlikely(status == -EOVERFLOW)) {
 		kaweth->stats.rx_errors++;
-		dbg("Status was -EOVERFLOW.");
+		dev_dbg(dev, "Status was -EOVERFLOW.\n");
 	}
 	spin_lock(&kaweth->device_lock);
 	if (IS_BLOCKED(kaweth->status)) {
@@ -687,7 +687,7 @@ static int kaweth_open(struct net_device *net)
 	struct kaweth_device *kaweth = netdev_priv(net);
 	int res;
 
-	dbg("Opening network device.");
+	netdev_dbg(kaweth->net, "Opening network device.\n");
 
 	res = usb_autopm_get_interface(kaweth->intf);
 	if (res) {
@@ -787,7 +787,8 @@ static void kaweth_usb_transmit_complete(struct urb *urb)
 
 	if (unlikely(status != 0))
 		if (status != -ENOENT)
-			dbg("%s: TX status %d.", kaweth->net->name, status);
+			dev_dbg(&urb->dev->dev, "%s: TX status %d.\n",
+				kaweth->net->name, status);
 
 	netif_wake_queue(kaweth->net);
 	dev_kfree_skb_irq(skb);
@@ -871,7 +872,7 @@ static void kaweth_set_rx_mode(struct net_device *net)
                                      KAWETH_PACKET_FILTER_BROADCAST |
 		                     KAWETH_PACKET_FILTER_MULTICAST;
 
-	dbg("Setting Rx mode to %d", packet_filter_bitmap);
+	netdev_dbg(net, "Setting Rx mode to %d\n", packet_filter_bitmap);
 
 	netif_stop_queue(net);
 
@@ -916,7 +917,8 @@ static void kaweth_async_set_rx_mode(struct kaweth_device *kaweth)
 			result);
 	}
 	else {
-		dbg("Set Rx mode to %d", packet_filter_bitmap);
+		netdev_dbg(kaweth->net, "Set Rx mode to %d\n",
+			   packet_filter_bitmap);
 	}
 }
 
@@ -951,7 +953,7 @@ static int kaweth_suspend(struct usb_interface *intf, pm_message_t message)
 	struct kaweth_device *kaweth = usb_get_intfdata(intf);
 	unsigned long flags;
 
-	dbg("Suspending device");
+	dev_dbg(&intf->dev, "Suspending device\n");
 	spin_lock_irqsave(&kaweth->device_lock, flags);
 	kaweth->status |= KAWETH_STATUS_SUSPENDING;
 	spin_unlock_irqrestore(&kaweth->device_lock, flags);
@@ -968,7 +970,7 @@ static int kaweth_resume(struct usb_interface *intf)
 	struct kaweth_device *kaweth = usb_get_intfdata(intf);
 	unsigned long flags;
 
-	dbg("Resuming device");
+	dev_dbg(&intf->dev, "Resuming device\n");
 	spin_lock_irqsave(&kaweth->device_lock, flags);
 	kaweth->status &= ~KAWETH_STATUS_SUSPENDING;
 	spin_unlock_irqrestore(&kaweth->device_lock, flags);
@@ -1003,36 +1005,37 @@ static int kaweth_probe(
 		const struct usb_device_id *id      /* from id_table */
 	)
 {
-	struct usb_device *dev = interface_to_usbdev(intf);
+	struct device *dev = &intf->dev;
+	struct usb_device *udev = interface_to_usbdev(intf);
 	struct kaweth_device *kaweth;
 	struct net_device *netdev;
 	const eth_addr_t bcast_addr = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 	int result = 0;
 
-	dbg("Kawasaki Device Probe (Device number:%d): 0x%4.4x:0x%4.4x:0x%4.4x",
-		 dev->devnum,
-		 le16_to_cpu(dev->descriptor.idVendor),
-		 le16_to_cpu(dev->descriptor.idProduct),
-		 le16_to_cpu(dev->descriptor.bcdDevice));
+	dev_dbg(dev,
+		"Kawasaki Device Probe (Device number:%d): 0x%4.4x:0x%4.4x:0x%4.4x\n",
+		udev->devnum, le16_to_cpu(udev->descriptor.idVendor),
+		le16_to_cpu(udev->descriptor.idProduct),
+		le16_to_cpu(udev->descriptor.bcdDevice));
 
-	dbg("Device at %p", dev);
+	dev_dbg(dev, "Device at %p\n", udev);
 
-	dbg("Descriptor length: %x type: %x",
-		 (int)dev->descriptor.bLength,
-		 (int)dev->descriptor.bDescriptorType);
+	dev_dbg(dev, "Descriptor length: %x type: %x\n",
+		(int)udev->descriptor.bLength,
+		(int)udev->descriptor.bDescriptorType);
 
 	netdev = alloc_etherdev(sizeof(*kaweth));
 	if (!netdev)
 		return -ENOMEM;
 
 	kaweth = netdev_priv(netdev);
-	kaweth->dev = dev;
+	kaweth->dev = udev;
 	kaweth->net = netdev;
 
 	spin_lock_init(&kaweth->device_lock);
 	init_waitqueue_head(&kaweth->term_wait);
 
-	dbg("Resetting.");
+	dev_dbg(dev, "Resetting.\n");
 
 	kaweth_reset(kaweth);
 
@@ -1041,17 +1044,17 @@ static int kaweth_probe(
 	 * downloaded. Don't try to do it again, or we'll hang the device.
 	 */
 
-	if (le16_to_cpu(dev->descriptor.bcdDevice) >> 8) {
-		dev_info(&intf->dev, "Firmware present in device.\n");
+	if (le16_to_cpu(udev->descriptor.bcdDevice) >> 8) {
+		dev_info(dev, "Firmware present in device.\n");
 	} else {
 		/* Download the firmware */
-		dev_info(&intf->dev, "Downloading firmware...\n");
+		dev_info(dev, "Downloading firmware...\n");
 		kaweth->firmware_buf = (__u8 *)__get_free_page(GFP_KERNEL);
 		if ((result = kaweth_download_firmware(kaweth,
 						      "kaweth/new_code.bin",
 						      100,
 						      2)) < 0) {
-			dev_err(&intf->dev, "Error downloading firmware (%d)\n",
+			dev_err(dev, "Error downloading firmware (%d)\n",
 				result);
 			goto err_fw;
 		}
@@ -1060,8 +1063,7 @@ static int kaweth_probe(
 						      "kaweth/new_code_fix.bin",
 						      100,
 						      3)) < 0) {
-			dev_err(&intf->dev,
-				"Error downloading firmware fix (%d)\n",
+			dev_err(dev, "Error downloading firmware fix (%d)\n",
 				result);
 			goto err_fw;
 		}
@@ -1070,8 +1072,7 @@ static int kaweth_probe(
 						      "kaweth/trigger_code.bin",
 						      126,
 						      2)) < 0) {
-			dev_err(&intf->dev,
-				"Error downloading trigger code (%d)\n",
+			dev_err(dev, "Error downloading trigger code (%d)\n",
 				result);
 			goto err_fw;
 
@@ -1081,19 +1082,18 @@ static int kaweth_probe(
 						      "kaweth/trigger_code_fix.bin",
 						      126,
 						      3)) < 0) {
-			dev_err(&intf->dev, "Error downloading trigger code fix (%d)\n", result);
+			dev_err(dev, "Error downloading trigger code fix (%d)\n", result);
 			goto err_fw;
 		}
 
 
 		if ((result = kaweth_trigger_firmware(kaweth, 126)) < 0) {
-			dev_err(&intf->dev, "Error triggering firmware (%d)\n",
-				result);
+			dev_err(dev, "Error triggering firmware (%d)\n", result);
 			goto err_fw;
 		}
 
 		/* Device will now disappear for a moment...  */
-		dev_info(&intf->dev, "Firmware loaded.  I'll be back...\n");
+		dev_info(dev, "Firmware loaded.  I'll be back...\n");
 err_fw:
 		free_page((unsigned long)kaweth->firmware_buf);
 		free_netdev(netdev);
@@ -1103,29 +1103,29 @@ err_fw:
 	result = kaweth_read_configuration(kaweth);
 
 	if(result < 0) {
-		dev_err(&intf->dev, "Error reading configuration (%d), no net device created\n", result);
+		dev_err(dev, "Error reading configuration (%d), no net device created\n", result);
 		goto err_free_netdev;
 	}
 
-	dev_info(&intf->dev, "Statistics collection: %x\n", kaweth->configuration.statistics_mask);
-	dev_info(&intf->dev, "Multicast filter limit: %x\n", kaweth->configuration.max_multicast_filters & ((1 << 15) - 1));
-	dev_info(&intf->dev, "MTU: %d\n", le16_to_cpu(kaweth->configuration.segment_size));
-	dev_info(&intf->dev, "Read MAC address %pM\n", kaweth->configuration.hw_addr);
+	dev_info(dev, "Statistics collection: %x\n", kaweth->configuration.statistics_mask);
+	dev_info(dev, "Multicast filter limit: %x\n", kaweth->configuration.max_multicast_filters & ((1 << 15) - 1));
+	dev_info(dev, "MTU: %d\n", le16_to_cpu(kaweth->configuration.segment_size));
+	dev_info(dev, "Read MAC address %pM\n", kaweth->configuration.hw_addr);
 
 	if(!memcmp(&kaweth->configuration.hw_addr,
                    &bcast_addr,
 		   sizeof(bcast_addr))) {
-		dev_err(&intf->dev, "Firmware not functioning properly, no net device created\n");
+		dev_err(dev, "Firmware not functioning properly, no net device created\n");
 		goto err_free_netdev;
 	}
 
 	if(kaweth_set_urb_size(kaweth, KAWETH_BUF_SIZE) < 0) {
-		dbg("Error setting URB size");
+		dev_dbg(dev, "Error setting URB size\n");
 		goto err_free_netdev;
 	}
 
 	if(kaweth_set_sofs_wait(kaweth, KAWETH_SOFS_TO_WAIT) < 0) {
-		dev_err(&intf->dev, "Error setting SOFS wait\n");
+		dev_err(dev, "Error setting SOFS wait\n");
 		goto err_free_netdev;
 	}
 
@@ -1135,11 +1135,11 @@ err_fw:
                                            KAWETH_PACKET_FILTER_MULTICAST);
 
 	if(result < 0) {
-		dev_err(&intf->dev, "Error setting receive filter\n");
+		dev_err(dev, "Error setting receive filter\n");
 		goto err_free_netdev;
 	}
 
-	dbg("Initializing net device.");
+	dev_dbg(dev, "Initializing net device.\n");
 
 	kaweth->intf = intf;
 
@@ -1181,20 +1181,20 @@ err_fw:
 
 #if 0
 // dma_supported() is deeply broken on almost all architectures
-	if (dma_supported (&intf->dev, 0xffffffffffffffffULL))
+	if (dma_supported (dev, 0xffffffffffffffffULL))
 		kaweth->net->features |= NETIF_F_HIGHDMA;
 #endif
 
-	SET_NETDEV_DEV(netdev, &intf->dev);
+	SET_NETDEV_DEV(netdev, dev);
 	if (register_netdev(netdev) != 0) {
-		dev_err(&intf->dev, "Error registering netdev.\n");
+		dev_err(dev, "Error registering netdev.\n");
 		goto err_intfdata;
 	}
 
-	dev_info(&intf->dev, "kaweth interface created at %s\n",
+	dev_info(dev, "kaweth interface created at %s\n",
 		 kaweth->net->name);
 
-	dbg("Kaweth probe returning.");
+	dev_dbg(dev, "Kaweth probe returning.\n");
 
 	return 0;
 
@@ -1232,7 +1232,7 @@ static void kaweth_disconnect(struct usb_interface *intf)
 	}
 	netdev = kaweth->net;
 
-	dbg("Unregistering net device");
+	netdev_dbg(kaweth->net, "Unregistering net device\n");
 	unregister_netdev(netdev);
 
 	usb_free_urb(kaweth->rx_urb);
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 28c4d51..29e06e1 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -155,12 +155,10 @@ static void nc_dump_registers(struct usbnet *dev)
 	u8	reg;
 	u16	*vp = kmalloc(sizeof (u16));
 
-	if (!vp) {
-		dbg("no memory?");
+	if (!vp)
 		return;
-	}
 
-	dbg("%s registers:", dev->net->name);
+	netdev_dbg(dev->net, "registers:\n");
 	for (reg = 0; reg < 0x20; reg++) {
 		int retval;
 
@@ -172,11 +170,10 @@ static void nc_dump_registers(struct usbnet *dev)
 
 		retval = nc_register_read(dev, reg, vp);
 		if (retval < 0)
-			dbg("%s reg [0x%x] ==> error %d",
-				dev->net->name, reg, retval);
+			netdev_dbg(dev->net, "reg [0x%x] ==> error %d\n",
+				   reg, retval);
 		else
-			dbg("%s reg [0x%x] = 0x%x",
-				dev->net->name, reg, *vp);
+			netdev_dbg(dev->net, "reg [0x%x] = 0x%x\n", reg, *vp);
 	}
 	kfree(vp);
 }
@@ -300,15 +297,15 @@ static int net1080_reset(struct usbnet *dev)
 	// nc_dump_registers(dev);
 
 	if ((retval = nc_register_read(dev, REG_STATUS, vp)) < 0) {
-		dbg("can't read %s-%s status: %d",
-			dev->udev->bus->bus_name, dev->udev->devpath, retval);
+		netdev_dbg(dev->net, "can't read %s-%s status: %d\n",
+			   dev->udev->bus->bus_name, dev->udev->devpath, retval);
 		goto done;
 	}
 	status = *vp;
 	nc_dump_status(dev, status);
 
 	if ((retval = nc_register_read(dev, REG_USBCTL, vp)) < 0) {
-		dbg("can't read USBCTL, %d", retval);
+		netdev_dbg(dev->net, "can't read USBCTL, %d\n", retval);
 		goto done;
 	}
 	usbctl = *vp;
@@ -318,7 +315,7 @@ static int net1080_reset(struct usbnet *dev)
 			USBCTL_FLUSH_THIS | USBCTL_FLUSH_OTHER);
 
 	if ((retval = nc_register_read(dev, REG_TTL, vp)) < 0) {
-		dbg("can't read TTL, %d", retval);
+		netdev_dbg(dev->net, "can't read TTL, %d\n", retval);
 		goto done;
 	}
 	ttl = *vp;
@@ -326,7 +323,7 @@ static int net1080_reset(struct usbnet *dev)
 
 	nc_register_write(dev, REG_TTL,
 			MK_TTL(NC_READ_TTL_MS, TTL_OTHER(ttl)) );
-	dbg("%s: assigned TTL, %d ms", dev->net->name, NC_READ_TTL_MS);
+	netdev_dbg(dev->net, "assigned TTL, %d ms\n", NC_READ_TTL_MS);
 
 	netif_info(dev, link, dev->net, "port %c, peer %sconnected\n",
 		   (status & STATUS_PORT_A) ? 'A' : 'B',
@@ -350,7 +347,7 @@ static int net1080_check_connect(struct usbnet *dev)
 	status = *vp;
 	kfree(vp);
 	if (retval != 0) {
-		dbg("%s net1080_check_conn read - %d", dev->net->name, retval);
+		netdev_dbg(dev->net, "net1080_check_conn read - %d\n", retval);
 		return retval;
 	}
 	if ((status & STATUS_CONN_OTHER) != STATUS_CONN_OTHER)
@@ -422,8 +419,9 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	if (!(skb->len & 0x01)) {
 #ifdef DEBUG
 		struct net_device	*net = dev->net;
-		dbg("rx framesize %d range %d..%d mtu %d", skb->len,
-			net->hard_header_len, dev->hard_mtu, net->mtu);
+		netdev_dbg(dev->net, "rx framesize %d range %d..%d mtu %d\n",
+			   skb->len, net->hard_header_len, dev->hard_mtu,
+			   net->mtu);
 #endif
 		dev->net->stats.rx_frame_errors++;
 		nc_ensure_sync(dev);
@@ -435,17 +433,17 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	packet_len = le16_to_cpup(&header->packet_len);
 	if (FRAMED_SIZE(packet_len) > NC_MAX_PACKET) {
 		dev->net->stats.rx_frame_errors++;
-		dbg("packet too big, %d", packet_len);
+		netdev_dbg(dev->net, "packet too big, %d\n", packet_len);
 		nc_ensure_sync(dev);
 		return 0;
 	} else if (hdr_len < MIN_HEADER) {
 		dev->net->stats.rx_frame_errors++;
-		dbg("header too short, %d", hdr_len);
+		netdev_dbg(dev->net, "header too short, %d\n", hdr_len);
 		nc_ensure_sync(dev);
 		return 0;
 	} else if (hdr_len > MIN_HEADER) {
 		// out of band data for us?
-		dbg("header OOB, %d bytes", hdr_len - MIN_HEADER);
+		netdev_dbg(dev->net, "header OOB, %d bytes\n", hdr_len - MIN_HEADER);
 		nc_ensure_sync(dev);
 		// switch (vendor/product ids) { ... }
 	}
@@ -458,23 +456,23 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	if ((packet_len & 0x01) == 0) {
 		if (skb->data [packet_len] != PAD_BYTE) {
 			dev->net->stats.rx_frame_errors++;
-			dbg("bad pad");
+			netdev_dbg(dev->net, "bad pad\n");
 			return 0;
 		}
 		skb_trim(skb, skb->len - 1);
 	}
 	if (skb->len != packet_len) {
 		dev->net->stats.rx_frame_errors++;
-		dbg("bad packet len %d (expected %d)",
-			skb->len, packet_len);
+		netdev_dbg(dev->net, "bad packet len %d (expected %d)\n",
+			   skb->len, packet_len);
 		nc_ensure_sync(dev);
 		return 0;
 	}
 	if (header->packet_id != get_unaligned(&trailer->packet_id)) {
 		dev->net->stats.rx_fifo_errors++;
-		dbg("(2+ dropped) rx packet_id mismatch 0x%x 0x%x",
-			le16_to_cpu(header->packet_id),
-			le16_to_cpu(trailer->packet_id));
+		netdev_dbg(dev->net, "(2+ dropped) rx packet_id mismatch 0x%x 0x%x\n",
+			   le16_to_cpu(header->packet_id),
+			   le16_to_cpu(trailer->packet_id));
 		return 0;
 	}
 #if 0
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 0e2c92e..5f39a3b 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -275,7 +275,7 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
 		return -EBUSY;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	dbg("%s: Setting MAC address to %pM\n", netdev->name, netdev->dev_addr);
+	netdev_dbg(netdev, "Setting MAC address to %pM\n", netdev->dev_addr);
 	/* Set the IDR registers. */
 	set_registers(dev, IDR, netdev->addr_len, netdev->dev_addr);
 #ifdef EEPROM_WRITE
@@ -503,12 +503,12 @@ static void intr_callback(struct urb *urb)
 	if ((d[INT_MSR] & MSR_LINK) == 0) {
 		if (netif_carrier_ok(dev->netdev)) {
 			netif_carrier_off(dev->netdev);
-			dbg("%s: LINK LOST\n", __func__);
+			netdev_dbg(dev->netdev, "%s: LINK LOST\n", __func__);
 		}
 	} else {
 		if (!netif_carrier_ok(dev->netdev)) {
 			netif_carrier_on(dev->netdev);
-			dbg("%s: LINK CAME BACK\n", __func__);
+			netdev_dbg(dev->netdev, "%s: LINK CAME BACK\n", __func__);
 		}
 	}
 
