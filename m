From: Loic Domaigne <loic.domaigne-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: RFC: [PATCH 3/3] usb: cdc_ncm: MirrorLink booster for N60x,70x
Date: Fri, 8 Mar 2013 22:03:24 +0100
Message-ID: <20130308210324.GA4796@feynman.loic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch allows to boost the performance if used for MirrorLink(TM). It
is derived from a patch provided by Nokia-LC/Berlin. It optimizes the transfer
speed for the Nokia N60x,70x. which requires special settings (jumbo frame, 
no batching)

This patch applies to longterm kernel version 3.4.35.

Signed-Off-By: Loic Domaigne <loic.domaigne-NEfzRHNIQpPQT0dZR+AlfA@public.gmane.org> 

--- linux-3.4.35/drivers/net/usb/cdc_ncm.c.patch2	2013-03-05 10:34:56.639566116 +0100
+++ linux-3.4.35/drivers/net/usb/cdc_ncm.c	2013-03-05 10:54:33.941773425 +0100
@@ -38,6 +38,22 @@
  * SUCH DAMAGE.
  */
 
+/* MirrorLink(TM) Booster patch
+ *
+ * Copyright (c) jambit GmbH
+ * Contact: Loic Domaigne <loic.domaigne-NEfzRHNIQpPQT0dZR+AlfA@public.gmane.org>
+ *
+ * Contribution:
+ * Part of this work is derived from a patch provided by Nokia-LC/Berlin
+ * (thanks Juan!), which was licensed under the terms of the GNU General
+ * Public License (GPL) Version 2
+ *
+ * Licensing:
+ * This patch is available to you under the terms of the GNU General Public
+ * License (GPL) Version 2
+ *
+ * Disclaimer: same as above.
+ */
 #include <linux/version.h> /* LINUX_VERSION_CODE and KERNEL_VERSION macro */
 #include <linux/module.h>
 #include <linux/init.h>
@@ -52,7 +68,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"14-Mar-2012"
+#define	DRIVER_VERSION				"08-June-2012"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -182,6 +198,38 @@ cdc_ncm_get_drvinfo(struct net_device *n
 	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
 }
 
+void mirrorlink_booster(struct cdc_ncm_ctx *ctx, struct usbnet *dev)
+{
+#define NOKIA 0x0421
+#define N6x7x 0x1419
+
+	if (ctx->udev->descriptor.idVendor == NOKIA) {
+
+		switch (ctx->udev->descriptor.idProduct) {
+		case N6x7x:
+			/* The Nokia N60x,70x (productId 0x1419) needs:
+			 * - Jumbo Frame (MTU 8kB)
+			 * - Disable TX batching to improve latency
+			 */
+			if (dev != NULL)
+				/* called during NCM bind */
+				dev->hard_mtu = 8192+ETH_HLEN;
+			else {
+				/* called during NCM setup */
+				pr_info(KBUILD_MODNAME ":  jambit MirrorLink booster for "
+					"Nokia 60x,70x family");
+				ctx->tx_max_datagrams  = 1;
+				ctx->max_datagram_size = 8192+ETH_HLEN;
+			}
+			break;
+
+		default:
+			/* no other Nokia yet */
+			break;
+		}
+	}
+}
+
 static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 {
 	u32 val;
@@ -414,9 +462,10 @@ size_err:
 	}
 
 max_dgram_err:
+	mirrorlink_booster(ctx, NULL);
 	if (ctx->netdev->mtu != (ctx->max_datagram_size - ETH_HLEN))
 		ctx->netdev->mtu = ctx->max_datagram_size - ETH_HLEN;
