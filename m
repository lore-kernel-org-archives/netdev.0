From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 1/5] orinoco: Remove conditionals that are useless in the
 kernel drivers.
Date: Fri, 16 Sep 2005 02:15:13 -0400
Message-ID: <1126851313.3056.2.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree 7c5bc25c778643f8cdf930ad8391b9eac24a16e4 (from 065d9cac98a5406ecd5a1368f8fd38f55739dee9)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Fri Sep 16 00:49:05 2005 -0400

    Remove conditionals that are useless in the kernel drivers.
    
    Kernel drivers are never compiled against pcmcia-cs headers.
    Firmware is never embedded into spectrum_cs module.

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -12,13 +12,10 @@
 
 #define DRIVER_NAME "orinoco_cs"
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-#ifdef  __IN_PCMCIA_PACKAGE__
-#include <pcmcia/k_compat.h>
-#endif /* __IN_PCMCIA_PACKAGE__ */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/sched.h>
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -20,13 +20,10 @@
 
 #define DRIVER_NAME "spectrum_cs"
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-#ifdef  __IN_PCMCIA_PACKAGE__
-#include <pcmcia/k_compat.h>
-#endif /* __IN_PCMCIA_PACKAGE__ */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/sched.h>
@@ -36,10 +33,11 @@
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/firmware.h>
 
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
@@ -49,33 +47,14 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
 #include "orinoco.h"
 
-/*
- * If SPECTRUM_FW_INCLUDED is defined, the firmware is hardcoded into
- * the driver.  Use get_symbol_fw script to generate spectrum_fw.h and
- * copy it to the same directory as spectrum_cs.c.
- *
- * If SPECTRUM_FW_INCLUDED is not defined, the firmware is loaded at the
- * runtime using hotplug.  Use the same get_symbol_fw script to generate
- * files symbol_sp24t_prim_fw symbol_sp24t_sec_fw, copy them to the
- * hotplug firmware directory (typically /usr/lib/hotplug/firmware) and
- * make sure that you have hotplug installed and enabled in the kernel.
- */
-/* #define SPECTRUM_FW_INCLUDED 1 */
-
-#ifdef SPECTRUM_FW_INCLUDED
-/* Header with the firmware */
-#include "spectrum_fw.h"
-#else	/* !SPECTRUM_FW_INCLUDED */
-#include <linux/firmware.h>
 static unsigned char *primsym;
 static unsigned char *secsym;
 static const char primary_fw_name[] = "symbol_sp24t_prim_fw";
 static const char secondary_fw_name[] = "symbol_sp24t_sec_fw";
-#endif	/* !SPECTRUM_FW_INCLUDED */
 
 /********************************************************************/
 /* Module stuff							    */
 /********************************************************************/
 
@@ -569,12 +548,10 @@ spectrum_dl_image(hermes_t *hw, dev_link
 static int
 spectrum_dl_firmware(hermes_t *hw, dev_link_t *link)
 {
 	int ret;
 	client_handle_t handle = link->handle;
-
-#ifndef SPECTRUM_FW_INCLUDED
 	const struct firmware *fw_entry;
 
 	if (request_firmware(&fw_entry, primary_fw_name,
 			     &handle_to_dev(handle)) == 0) {
 		primsym = fw_entry->data;
@@ -590,11 +567,10 @@ spectrum_dl_firmware(hermes_t *hw, dev_l
 	} else {
 		printk(KERN_ERR PFX "Cannot find firmware: %s\n",
 		       secondary_fw_name);
 		return -ENOENT;
 	}
-#endif
 
 	/* Load primary firmware */
 	ret = spectrum_dl_image(hw, link, primsym);
 	if (ret) {
 		printk(KERN_ERR PFX "Primary firmware download failed\n");


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
