From: Dmitry Antipov <dmitry.antipov-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] smsc95xx: use usleep_range(), get rid out of jiffies
Date: Tue, 17 Jan 2012 16:54:12 +0400
Message-ID: <1326804852-17742-1-git-send-email-dmitry.antipov@linaro.org>
Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linaro-dev-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	Dmitry Antipov <dmitry.antipov-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use usleep_range() with return value to implement time-bounded
wait-for hardware loop where delay is applicable; use ktime
instead of jiffies for a busy-wait loop.

Signed-off-by: Dmitry Antipov <dmitry.antipov-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/usb/smsc95xx.c |   52 ++++++++++++++++++++-----------------------
 1 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d45520e..7264090 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -114,19 +114,18 @@ static int smsc95xx_write_reg(struct usbnet *dev, u32 index, u32 data)
 	return ret;
 }
 
-/* Loop until the read is completed with timeout
- * called with phy_mutex held */
+/* Busy-wait loop until the read is completed, but
+   no longer than 10ms. Called with phy_mutex held. */
 static int smsc95xx_phy_wait_not_busy(struct usbnet *dev)
 {
-	unsigned long start_time = jiffies;
+	ktime_t start = ktime_get();
 	u32 val;
 
-	do {
+	while (ktime_us_delta(ktime_get(), start) < 10000) {
 		smsc95xx_read_reg(dev, MII_ADDR, &val);
 		if (!(val & MII_BUSY_))
 			return 0;
-	} while (!time_after(jiffies, start_time + HZ));
-
+	}
 	return -EIO;
 }
 
@@ -195,15 +194,15 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 
 static int smsc95xx_wait_eeprom(struct usbnet *dev)
 {
-	unsigned long start_time = jiffies;
+	unsigned long timeout = 0;
 	u32 val;
 
 	do {
 		smsc95xx_read_reg(dev, E2P_CMD, &val);
 		if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
 			break;
-		udelay(40);
-	} while (!time_after(jiffies, start_time + HZ));
+		timeout += usleep_range(40, 50);
+	} while (timeout < USEC_PER_MSEC * 10);
 
 	if (val & (E2P_CMD_TIMEOUT_ | E2P_CMD_BUSY_)) {
 		netdev_warn(dev->net, "EEPROM read operation timeout\n");
@@ -215,17 +214,15 @@ static int smsc95xx_wait_eeprom(struct usbnet *dev)
 
 static int smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 {
-	unsigned long start_time = jiffies;
+	unsigned long timeout = 0;
 	u32 val;
 
 	do {
 		smsc95xx_read_reg(dev, E2P_CMD, &val);
-
 		if (!(val & E2P_CMD_BUSY_))
 			return 0;
-
-		udelay(40);
-	} while (!time_after(jiffies, start_time + HZ));
+		timeout += usleep_range(40, 50);
+	} while (timeout < USEC_PER_MSEC * 10);
 
 	netdev_warn(dev->net, "EEPROM is busy\n");
 	return -EIO;
@@ -674,7 +671,8 @@ static void smsc95xx_start_rx_path(struct usbnet *dev)
 
 static int smsc95xx_phy_initialize(struct usbnet *dev)
 {
-	int bmcr, timeout = 0;
+	int bmcr;
+	unsigned long timeout = 0;
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
@@ -688,12 +686,11 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
 
 	do {
-		msleep(10);
+		timeout += usleep_range(10000, 15000);
 		bmcr = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
-		timeout++;
-	} while ((bmcr & BMCR_RESET) && (timeout < 100));
+	} while ((bmcr & BMCR_RESET) && (timeout < USEC_PER_SEC));
 
-	if (timeout >= 100) {
+	if (timeout >= USEC_PER_SEC) {
 		netdev_warn(dev->net, "timeout on PHY Reset");
 		return -EIO;
 	}
@@ -717,7 +714,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	u32 read_buf, write_buf, burst_cap;
-	int ret = 0, timeout;
+	unsigned long timeout;
+	int ret = 0;
 
 	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
 
@@ -736,11 +734,10 @@ static int smsc95xx_reset(struct usbnet *dev)
 			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 			return ret;
 		}
-		msleep(10);
-		timeout++;
-	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
+		timeout += usleep_range(10000, 15000);
+	} while ((read_buf & HW_CFG_LRST_) && (timeout < USEC_PER_SEC));
 
-	if (timeout >= 100) {
+	if (timeout >= USEC_PER_SEC) {
 		netdev_warn(dev->net, "timeout waiting for completion of Lite Reset\n");
 		return ret;
 	}
@@ -759,11 +756,10 @@ static int smsc95xx_reset(struct usbnet *dev)
 			netdev_warn(dev->net, "Failed to read PM_CTRL: %d\n", ret);
 			return ret;
 		}
-		msleep(10);
-		timeout++;
-	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
+		timeout += usleep_range(10000, 15000);
+	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < USEC_PER_SEC));
 
-	if (timeout >= 100) {
+	if (timeout >= USEC_PER_SEC) {
 		netdev_warn(dev->net, "timeout waiting for PHY Reset\n");
 		return ret;
 	}
-- 
1.7.7.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
