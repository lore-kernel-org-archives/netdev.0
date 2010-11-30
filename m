From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH -stable] Add USB PID for new MOSCHIP USB ethernet controller
 MCS7832 variant
Date: Tue, 30 Nov 2010 21:07:37 +0100
Message-ID: <20101130200737.GA5185@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, Arnd Bergmann <arnd@arndb.de>,
	dhollis@davehollis.com, Phil Chang <pchang23@sbcglobal.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gregkh@suse.de, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to active notification of the new MCS7832 version by the manufacturer
today (Mr. Milton; thanks!) -- quote: "functionality same as MCS7830",
I'm now submitting this patch, intended for networking.git and -stable.

ChangeLog:
- add MCS7832 USB PID to be able to support this new device variant, too
- add HIF_REG_EEPROM_STATUS definitions, comments


Patch created, "semi"-tested (via my existing MCS7830 only) on -rc3,
checkpatch.pl'd.
GIT history seems clean, should thus apply easily.

Thanks!

Signed-off-by: Andreas Mohr <andi@lisas.de>

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index a6281e3..3fbcb0d 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -1,5 +1,5 @@
 /*
- * MOSCHIP MCS7830 based USB 2.0 Ethernet Devices
+ * MOSCHIP MCS7830 based (7730/7830/7832) USB 2.0 Ethernet Devices
  *
  * based on usbnet.c, asix.c and the vendor provided mcs7830 driver
  *
@@ -11,8 +11,12 @@
  *
  * Definitions gathered from MOSCHIP, Data Sheet_7830DA.pdf (thanks!).
  *
+ * 2010-11-30: add 7832 USB PID ("functionality same as MCS7830"),
+ *             per active notification by manufacturer
+ *
  * TODO:
  * - support HIF_REG_CONFIG_SLEEPMODE/HIF_REG_CONFIG_TXENABLE (via autopm?)
+ * - support HIF_REG_FRAME_DROP_COUNTER, for interface statistics
  * - implement ethtool_ops get_pauseparam/set_pauseparam
  *   via HIF_REG_PAUSE_THRESHOLD (>= revision C only!)
  * - implement get_eeprom/[set_eeprom]
@@ -60,6 +64,7 @@
 #define MCS7830_MAX_MCAST	64
 
 #define MCS7830_VENDOR_ID	0x9710
+#define MCS7832_PRODUCT_ID	0x7832
 #define MCS7830_PRODUCT_ID	0x7830
 #define MCS7730_PRODUCT_ID	0x7730
 
@@ -97,6 +102,11 @@ enum {
 	HIF_REG_FRAME_DROP_COUNTER		= 0x15, /* 0..ff; reset: 0 */
 	HIF_REG_PAUSE_THRESHOLD			= 0x16,
 	   HIF_REG_PAUSE_THRESHOLD_DEFAULT	= 0,
+	HIF_REG_EEPROM_STATUS			= 0x17,
+	   /* "read in progress": bits 0/1/2 == 0 */
+	   HIF_REG_EEPROM_STATUS_SW_EEPROM_READ	= 0x04,
+	   HIF_REG_EEPROM_STATUS_READ_FAILED	= 0x02, /* ro! */
+	   HIF_REG_EEPROM_STATUS_READ_SUCCEEDED	= 0x01, /* ro! */
 };
 
 /* Trailing status byte in Ethernet Rx frame */
@@ -362,6 +372,11 @@ static int mcs7830_get_rev(struct usbnet *dev)
 {
 	u8 dummy[2];
 	int ret;
+	/* TODO?: 7832 _might_  have more registers (untested: no hardware).
+	   Might also be a better idea to gather revision from
+	   SEEPROM field "Release Number" (if reliably supported
+	   by all variants).
+	 */
 	ret = mcs7830_get_reg(dev, HIF_REG_FRAME_DROP_COUNTER, 2, dummy);
 	if (ret > 0)
 		return 2; /* Rev C or later */
@@ -626,7 +641,7 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 }
 
 static const struct driver_info moschip_info = {
-	.description	= "MOSCHIP 7830/7730 usb-NET adapter",
+	.description	= "MOSCHIP 7830/7832/7730 usb-NET adapter",
 	.bind		= mcs7830_bind,
 	.rx_fixup	= mcs7830_rx_fixup,
 	.flags		= FLAG_ETHER,
@@ -645,6 +660,10 @@ static const struct driver_info sitecom_info = {
 
 static const struct usb_device_id products[] = {
 	{
+		USB_DEVICE(MCS7830_VENDOR_ID, MCS7832_PRODUCT_ID),
+		.driver_info = (unsigned long) &moschip_info,
+	},
+	{
 		USB_DEVICE(MCS7830_VENDOR_ID, MCS7830_PRODUCT_ID),
 		.driver_info = (unsigned long) &moschip_info,
 	},
