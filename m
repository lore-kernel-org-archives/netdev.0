From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH] USB: net: Fix asix read transfer buffer
	allocations.
Date: Mon, 22 Oct 2007 19:50:53 +0400
Message-ID: <20071022155053.GA28526@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-usb-devel@lists.sourceforge.net
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
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
directly using variables on stack.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/usb/asix.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff -pruN linux-2.6.orig/drivers/net/usb/asix.c linux-2.6/drivers/net/usb/asix.c
--- linux-2.6.orig/drivers/net/usb/asix.c	2007-10-19 20:10:18.000000000 +0400
+++ linux-2.6/drivers/net/usb/asix.c	2007-10-19 20:35:33.000000000 +0400
@@ -568,12 +568,20 @@ static void asix_set_multicast(struct ne
 static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 {
 	struct usbnet *dev = netdev_priv(netdev);
+	void *buf;
 	u16 res;
 
 	mutex_lock(&dev->phy_mutex);
 	asix_set_sw_mii(dev);
+
+	buf = kmalloc(2, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
 	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
-				(__u16)loc, 2, (u16 *)&res);
+				(__u16)loc, 2, buf);
+	res = *((u16 *)buf);
+	kfree(buf);
+
 	asix_set_hw_mii(dev);
 	mutex_unlock(&dev->phy_mutex);
 
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
