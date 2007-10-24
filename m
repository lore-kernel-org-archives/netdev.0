From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH] USB: net: Fix asix read transfer buffer
	allocations.
Date: Wed, 24 Oct 2007 15:33:44 +0400
Message-ID: <20071024113344.GA6757@ru.mvista.com>
References: <20071023200034.BB2B923A4FD@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-usb-devel@lists.sourceforge.net
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20071023200034.BB2B923A4FD@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On systems with noncoherent cache, allocating dma buffers
on the stack for USB IN transfers causes kernel crash,
because usb map_urb_for_dma() code calls dma_map_single(),
that invalidates data cache for DMA_FROM_DEVICE transfer direction
and causes stack data loss if transfer size is less than cache line
and not cache-line aligned. This patch makes asix usb network
driver allocate USB IN transfer buffers with kmalloc instead of
directly using variables on stack. It also sets data parameter to NULL
for zero-length transfers and uses ETH_ALEN size for allocating MAC 
address buffer.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/usb/asix.c |   44 +++++++++++++++++++++++++++++++-------------
 1 files changed, 31 insertions(+), 13 deletions(-)

diff -pruN linux-2.6.orig/drivers/net/usb/asix.c linux-2.6/drivers/net/usb/asix.c
--- linux-2.6.orig/drivers/net/usb/asix.c	2007-10-23 20:52:11.000000000 +0400
+++ linux-2.6/drivers/net/usb/asix.c	2007-10-23 20:57:38.000000000 +0400
@@ -568,15 +568,23 @@ static void asix_set_multicast(struct ne
 static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 {
 	struct usbnet *dev = netdev_priv(netdev);
+	void *buf;
 	u16 res;
 
+	buf = kmalloc(2, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
 	mutex_lock(&dev->phy_mutex);
 	asix_set_sw_mii(dev);
 	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
-				(__u16)loc, 2, (u16 *)&res);
+				(__u16)loc, 2, buf);
 	asix_set_hw_mii(dev);
 	mutex_unlock(&dev->phy_mutex);
 
+	res = *((u16 *)buf);
+	kfree(buf);
+
 	devdbg(dev, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x", phy_id, loc, le16_to_cpu(res & 0xffff));
 
 	return le16_to_cpu(res & 0xffff);
@@ -622,13 +630,22 @@ static void
 asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
 {
 	struct usbnet *dev = netdev_priv(net);
+	void *buf;
 	u8 opt;
 
-	if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
+	buf = kmalloc(1, GFP_KERNEL);
+	if (!buf)
+		return;
+
+	if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, buf) < 0) {
 		wolinfo->supported = 0;
 		wolinfo->wolopts = 0;
+		kfree(buf);
 		return;
 	}
+	opt = *((u8 *)buf);
+	kfree(buf);
+
 	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
 	wolinfo->wolopts = 0;
 	if (opt & AX_MONITOR_MODE) {
@@ -644,7 +661,6 @@ asix_set_wol(struct net_device *net, str
 {
 	struct usbnet *dev = netdev_priv(net);
 	u8 opt = 0;
-	u8 buf[1];
 
 	if (wolinfo->wolopts & WAKE_PHY)
 		opt |= AX_MONITOR_LINK;
@@ -654,7 +670,7 @@ asix_set_wol(struct net_device *net, str
 		opt |= AX_MONITOR_MODE;
 
 	if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
-			      opt, 0, 0, &buf) < 0)
+			      opt, 0, 0, NULL) < 0)
 		return -EINVAL;
 
 	return 0;
@@ -820,7 +836,7 @@ static int ax88172_bind(struct usbnet *d
 	for (i = 2; i >= 0; i--) {
 		if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS,
 					(gpio_bits >> (i * 8)) & 0xff, 0, 0,
-					buf)) < 0)
+					NULL)) < 0)
 			goto out2;
 		msleep(5);
 	}
@@ -831,7 +847,7 @@ static int ax88172_bind(struct usbnet *d
 	/* Get the MAC address */
 	memset(buf, 0, ETH_ALEN);
 	if ((ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID,
-				0, 0, 6, buf)) < 0) {
+				0, 0, ETH_ALEN, buf)) < 0) {
 		dbg("read AX_CMD_READ_NODE_ID failed: %d", ret);
 		goto out2;
 	}
@@ -909,7 +925,7 @@ static int ax88772_bind(struct usbnet *d
 
 	usbnet_get_endpoints(dev,intf);
 
-	buf = kmalloc(6, GFP_KERNEL);
+	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
 	if(!buf) {
 		dbg ("Cannot allocate memory for buffer");
 		ret = -ENOMEM;
@@ -923,7 +939,7 @@ static int ax88772_bind(struct usbnet *d
 	/* 0x10 is the phy id of the embedded 10/100 ethernet phy */
 	embd_phy = ((asix_get_phy_addr(dev) & 0x1f) == 0x10 ? 1 : 0);
 	if ((ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT,
-				embd_phy, 0, 0, buf)) < 0) {
+				embd_phy, 0, 0, NULL)) < 0) {
 		dbg("Select PHY #1 failed: %d", ret);
 		goto out2;
 	}
@@ -998,7 +1014,7 @@ static int ax88772_bind(struct usbnet *d
 
 	if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
 				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
-				AX88772_IPG2_DEFAULT, 0, buf)) < 0) {
+				AX88772_IPG2_DEFAULT, 0, NULL)) < 0) {
 		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
 		goto out2;
 	}
@@ -1202,20 +1218,22 @@ static int ax88178_bind(struct usbnet *d
 
 	usbnet_get_endpoints(dev,intf);
 
-	buf = kmalloc(6, GFP_KERNEL);
+	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
 	if(!buf) {
 		dbg ("Cannot allocate memory for buffer");
 		ret = -ENOMEM;
 		goto out1;
 	}
 
-	eeprom = 0;
-	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &eeprom);
+	memset(buf, 0, ETH_ALEN);
+	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, buf);
+	eeprom = *(u8 *)buf;
 	dbg("GPIO Status: 0x%04x", eeprom);
 
 	asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
-	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
+	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, buf);
 	asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL);
+	eeprom = *(u16 *)buf;
 
 	dbg("EEPROM index 0x17 is 0x%04x", eeprom);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
