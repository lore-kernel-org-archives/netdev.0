From: Loic Domaigne <loic.domaigne-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: RFC: [PATCH 2/3] usb: cdc_ncm: patch for multi kernel versions
Date: Fri, 8 Mar 2013 22:03:22 +0100
Message-ID: <20130308210322.GA4795@feynman.loic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch allows to have a single source for many kernel versions. As the
NCM driver at jambit runs on a wide range of embedded linux (from 
2.6.35 to 3.4.x) we devised this convenient patch.

This patch applies to longterm kernel version 3.4.35.

Signed-Off-By: Loic Domaigne <loic.domaigne-NEfzRHNIQpPQT0dZR+AlfA@public.gmane.org>

--- linux-3.4.35/drivers/net/usb/cdc_ncm.c.patch1	2013-03-05 10:22:14.361091251 +0100
+++ linux-3.4.35/drivers/net/usb/cdc_ncm.c	2013-03-05 10:33:33.169861281 +0100
@@ -38,6 +38,7 @@
  * SUCH DAMAGE.
  */
 
+#include <linux/version.h> /* LINUX_VERSION_CODE and KERNEL_VERSION macro */
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -48,7 +49,6 @@
 #include <linux/crc32.h>
 #include <linux/usb.h>
 #include <linux/hrtimer.h>
-#include <linux/atomic.h>
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
@@ -1244,8 +1244,30 @@ static const struct ethtool_ops cdc_ncm_
 	.nway_reset = usbnet_nway_reset,
 };
 
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(3, 3, 0))
+
 module_usb_driver(cdc_ncm_driver);
 
+#else
+
+static int __init cdc_ncm_init(void)
+{
+	pr_info(KBUILD_MODNAME ": " DRIVER_VERSION "\n");
+	pr_info(KBUILD_MODNAME ": MirrorLink booster by Jambit\n");
+	return usb_register(&cdc_ncm_driver);
+}
+
+module_init(cdc_ncm_init);
+
+static void __exit cdc_ncm_exit(void)
+{
+	usb_deregister(&cdc_ncm_driver);
+}
+
+module_exit(cdc_ncm_exit);
+
+#endif
+
 MODULE_AUTHOR("Hans Petter Selasky");
 MODULE_DESCRIPTION("USB CDC NCM host driver");
 MODULE_LICENSE("Dual BSD/GPL");
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
