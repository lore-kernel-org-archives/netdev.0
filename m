From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH v3] usbnet: use eth%d name for known ethernet devices
Date: Fri, 1 Apr 2011 17:06:36 +0200
Message-ID: <201104011706.36873.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Linux USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Nicolas Pitre <nicolas.pitre-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linux USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The documentation for the USB ethernet devices suggests that
only some devices are supposed to use usb0 as the network interface
name instead of eth0. The logic used there, and documented in
Kconfig for CDC is that eth0 will be used when the mac address
is a globally assigned one, but usb0 is used for the locally
managed range that is typically used on point-to-point links.

Unfortunately, this has caused a lot of pain on the smsc95xx
device that is used on the popular pandaboard without an
EEPROM to store the MAC address, which causes the driver to
call random_ether_address().

Obviously, there should be a proper MAC addressed assigned to
the device, and discussions are ongoing about how to solve
this, but this patch at least makes sure that the default
interface naming gets a little saner and matches what the
user can expect based on the documentation, including for
new devices.

The approach taken here is to flag whether a device might be a
point-to-point link with the new FLAG_POINTTOPOINT setting in
the usbnet driver_info. A driver can set both FLAG_POINTTOPOINT
and FLAG_ETHER if it is not sure (e.g. cdc_ether), or just one
of the two.  The usbnet framework only looks at the MAC address
for device naming if both flags are set, otherwise it trusts the
flag.

Signed-off-by: Arnd Bergmann <arnd.bergmann-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Tested-by: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
---
 drivers/net/usb/cdc_eem.c    |    2 +-
 drivers/net/usb/cdc_ether.c  |    2 +-
 drivers/net/usb/cdc_ncm.c    |    2 +-
 drivers/net/usb/cdc_subset.c |    8 ++++++++
 drivers/net/usb/gl620a.c     |    2 +-
 drivers/net/usb/net1080.c    |    2 +-
 drivers/net/usb/plusb.c      |    2 +-
 drivers/net/usb/rndis_host.c |    2 +-
 drivers/net/usb/usbnet.c     |    3 ++-
 drivers/net/usb/zaurus.c     |    8 ++++----
 include/linux/usb/usbnet.h   |    2 ++
 11 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 5f3b976..8f12854 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -340,7 +340,7 @@ next:
 
 static const struct driver_info eem_info = {
 	.description =	"CDC EEM Device",
-	.flags =	FLAG_ETHER,
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
 	.bind =		eem_bind,
 	.rx_fixup =	eem_rx_fixup,
 	.tx_fixup =	eem_tx_fixup,
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 9a60e41..98b2bbd 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -450,7 +450,7 @@ static int cdc_manage_power(struct usbnet *dev, int on)
 
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
-	.flags =	FLAG_ETHER,
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
 	// .check_connect = cdc_check_connect,
 	.bind =		cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 7113168..967371f 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1237,7 +1237,7 @@ static int cdc_ncm_manage_power(struct usbnet *dev, int status)
 
 static const struct driver_info cdc_ncm_info = {
 	.description = "CDC NCM",
-	.flags = FLAG_NO_SETINT | FLAG_MULTI_PACKET,
+	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
 	.bind = cdc_ncm_bind,
 	.unbind = cdc_ncm_unbind,
 	.check_connect = cdc_ncm_check_connect,
diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
index ca39ace..fc5f13d 100644
--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -89,6 +89,7 @@ static int always_connected (struct usbnet *dev)
 
 static const struct driver_info	ali_m5632_info = {
 	.description =	"ALi M5632",
+	.flags       = FLAG_POINTTOPOINT,
 };
 
 #endif
@@ -110,6 +111,7 @@ static const struct driver_info	ali_m5632_info = {
 
 static const struct driver_info	an2720_info = {
 	.description =	"AnchorChips/Cypress 2720",
+	.flags       = FLAG_POINTTOPOINT,
 	// no reset available!
 	// no check_connect available!
 
@@ -132,6 +134,7 @@ static const struct driver_info	an2720_info = {
 
 static const struct driver_info	belkin_info = {
 	.description =	"Belkin, eTEK, or compatible",
+	.flags       = FLAG_POINTTOPOINT,
 };
 
 #endif	/* CONFIG_USB_BELKIN */
@@ -157,6 +160,7 @@ static const struct driver_info	belkin_info = {
 static const struct driver_info	epson2888_info = {
 	.description =	"Epson USB Device",
 	.check_connect = always_connected,
+	.flags = FLAG_POINTTOPOINT,
 
 	.in = 4, .out = 3,
 };
@@ -173,6 +177,7 @@ static const struct driver_info	epson2888_info = {
 #define HAVE_HARDWARE
 static const struct driver_info kc2190_info = {
 	.description =  "KC Technology KC-190",
+	.flags = FLAG_POINTTOPOINT,
 };
 #endif /* CONFIG_USB_KC2190 */
 
@@ -200,16 +205,19 @@ static const struct driver_info kc2190_info = {
 static const struct driver_info	linuxdev_info = {
 	.description =	"Linux Device",
 	.check_connect = always_connected,
+	.flags = FLAG_POINTTOPOINT,
 };
 
 static const struct driver_info	yopy_info = {
 	.description =	"Yopy",
 	.check_connect = always_connected,
+	.flags = FLAG_POINTTOPOINT,
 };
 
 static const struct driver_info	blob_info = {
 	.description =	"Boot Loader OBject",
 	.check_connect = always_connected,
+	.flags = FLAG_POINTTOPOINT,
 };
 
 #endif	/* CONFIG_USB_ARMLINUX */
diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
index dcd57c3..c4cfd1d 100644
--- a/drivers/net/usb/gl620a.c
+++ b/drivers/net/usb/gl620a.c
@@ -193,7 +193,7 @@ static int genelink_bind(struct usbnet *dev, struct usb_interface *intf)
 
 static const struct driver_info	genelink_info = {
 	.description =	"Genesys GeneLink",
-	.flags =	FLAG_FRAMING_GL | FLAG_NO_SETINT,
+	.flags =	FLAG_POINTTOPOINT | FLAG_FRAMING_GL | FLAG_NO_SETINT,
 	.bind =		genelink_bind,
 	.rx_fixup =	genelink_rx_fixup,
 	.tx_fixup =	genelink_tx_fixup,
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index ba72a72..01db460 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -560,7 +560,7 @@ static int net1080_bind(struct usbnet *dev, struct usb_interface *intf)
 
 static const struct driver_info	net1080_info = {
 	.description =	"NetChip TurboCONNECT",
-	.flags =	FLAG_FRAMING_NC,
+	.flags =	FLAG_POINTTOPOINT | FLAG_FRAMING_NC,
 	.bind =		net1080_bind,
 	.reset =	net1080_reset,
 	.check_connect = net1080_check_connect,
diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 08ad269..823c537 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -96,7 +96,7 @@ static int pl_reset(struct usbnet *dev)
 
 static const struct driver_info	prolific_info = {
 	.description =	"Prolific PL-2301/PL-2302",
-	.flags =	FLAG_NO_SETINT,
+	.flags =	FLAG_POINTTOPOINT | FLAG_NO_SETINT,
 		/* some PL-2302 versions seem to fail usb_set_interface() */
 	.reset =	pl_reset,
 };
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index dd8a4ad..5994a25 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -573,7 +573,7 @@ EXPORT_SYMBOL_GPL(rndis_tx_fixup);
 
 static const struct driver_info	rndis_info = {
 	.description =	"RNDIS device",
-	.flags =	FLAG_ETHER | FLAG_FRAMING_RN | FLAG_NO_SETINT,
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT | FLAG_FRAMING_RN | FLAG_NO_SETINT,
 	.bind =		rndis_bind,
 	.unbind =	rndis_unbind,
 	.status =	rndis_status,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 95c41d5..c5b6cfb 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1376,7 +1376,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		// else "eth%d" when there's reasonable doubt.  userspace
 		// can rename the link if it knows better.
 		if ((dev->driver_info->flags & FLAG_ETHER) != 0 &&
-		    (net->dev_addr [0] & 0x02) == 0)
+		    ((dev->driver_info->flags & FLAG_POINTTOPOINT) == 0 ||
+		     (net->dev_addr [0] & 0x02) == 0))
 			strcpy (net->name, "eth%d");
 		/* WLAN devices should always be named "wlan%d" */
 		if ((dev->driver_info->flags & FLAG_WLAN) != 0)
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 3eb0b16..241756e 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -102,7 +102,7 @@ static int always_connected (struct usbnet *dev)
 
 static const struct driver_info	zaurus_sl5x00_info = {
 	.description =	"Sharp Zaurus SL-5x00",
-	.flags =	FLAG_FRAMING_Z,
+	.flags =	FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
 	.check_connect = always_connected,
 	.bind =		zaurus_bind,
 	.unbind =	usbnet_cdc_unbind,
@@ -112,7 +112,7 @@ static const struct driver_info	zaurus_sl5x00_info = {
 
 static const struct driver_info	zaurus_pxa_info = {
 	.description =	"Sharp Zaurus, PXA-2xx based",
-	.flags =	FLAG_FRAMING_Z,
+	.flags =	FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
 	.check_connect = always_connected,
 	.bind =		zaurus_bind,
 	.unbind =	usbnet_cdc_unbind,
@@ -122,7 +122,7 @@ static const struct driver_info	zaurus_pxa_info = {
 
 static const struct driver_info	olympus_mxl_info = {
 	.description =	"Olympus R1000",
-	.flags =	FLAG_FRAMING_Z,
+	.flags =	FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
 	.check_connect = always_connected,
 	.bind =		zaurus_bind,
 	.unbind =	usbnet_cdc_unbind,
@@ -258,7 +258,7 @@ bad_desc:
 
 static const struct driver_info	bogus_mdlm_info = {
 	.description =	"pseudo-MDLM (BLAN) device",
-	.flags =	FLAG_FRAMING_Z,
+	.flags =	FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
 	.check_connect = always_connected,
 	.tx_fixup =	zaurus_tx_fixup,
 	.bind =		blan_mdlm_bind,
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 44842c8..1ef9aa0 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -97,6 +97,8 @@ struct driver_info {
 
 #define FLAG_LINK_INTR	0x0800		/* updates link (carrier) status */
 
+#define FLAG_POINTTOPOINT 0x1000	/* possibly use "usb%d" names */
+
 /*
  * Indicates to usbnet, that USB driver accumulates multiple IP packets.
  * Affects statistic (counters) and short packet handling.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
