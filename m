From: Martin Michlmayr <tbm@cyrius.com>
Subject: [RFC] [PATCH 2/2] Driver to remember ethernet MAC values: NSLU2 support
Date: Mon, 20 Feb 2006 01:01:57 +0000
Message-ID: <20060220010157.GA19342@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932492AbWBTBCQ@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Bowler <jbowler@acm.org>

Implement maclist support for the Linksys NSLU2.  The MAC address is read
from the RedBoot partition in flash.

Signed-off-by: John Bowler <jbowler@acm.org>
Signed-off-by: Martin Michlmayr <tbm@cyrius.com>
Signed-off-by: Alessandro Zummo <a.zummo@towertech.it>
Signed-off-by: Rod Whitby <rod@whitby.id.au>

--

 arch/arm/mach-ixp4xx/Kconfig       |    4 +--
 arch/arm/mach-ixp4xx/nslu2-setup.c |   39 +++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 2 deletions(-)

--- linux-nslu2.orig/arch/arm/mach-ixp4xx/nslu2-setup.c	2006-02-06 22:34:55.000000000 +0100
+++ linux-nslu2/arch/arm/mach-ixp4xx/nslu2-setup.c	2006-02-06 22:35:31.000000000 +0100
@@ -16,11 +16,14 @@
 #include <linux/kernel.h>
 #include <linux/serial.h>
 #include <linux/serial_8250.h>
+#include <linux/mtd/mtd.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/flash.h>
 
+#include <net/maclist.h>
+
 static struct flash_platform_data nslu2_flash_data = {
 	.map_name		= "cfi_probe",
 	.width			= 2,
@@ -117,6 +120,37 @@ static void nslu2_power_off(void)
 	gpio_line_set(NSLU2_PO_GPIO, IXP4XX_GPIO_HIGH);
 }
 
+/*
+ * When the RedBoot partition is added the MAC address is read from
+ * it.
+ */
+static void nslu2_flash_add(struct mtd_info *mtd) {
+	if (strcmp(mtd->name, "RedBoot") == 0) {
+		size_t retlen;
+		u_char mac[6];
+
+		/* The MAC is at a known offset... */
+		if (mtd->read(mtd, 0x3FFB0, 6, &retlen, mac) == 0 && retlen == 6) {
+			printk(KERN_INFO "NSLU2 MAC: %.2x:%.2x:%.2x:%.2x:%.2x:%.2x\n",
+				mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+			maclist_add(mac);
+		} else {
+			printk(KERN_ERR "NSLU2 MAC: read failed\n");
+		}
+	}
+}
+
+/*
+ * Nothing to do on remove at present.
+ */
+static void nslu2_flash_remove(struct mtd_info *mtd) {
+}
+
+static struct mtd_notifier nslu2_flash_notifier = {
+	.add = nslu2_flash_add,
+	.remove = nslu2_flash_remove,
+};
+
 static void __init nslu2_init(void)
 {
 	/* The NSLU2 has a 33MHz crystal on board - 1.01% different
@@ -124,6 +158,11 @@ static void __init nslu2_init(void)
 	 */
 	ixp4xx_set_board_tick_rate(66000000);
 
+	/* The flash has an ethernet MAC embedded in it which we need,
+	 * that is all this notifier does.
+	 */
+	register_mtd_user(&nslu2_flash_notifier);
+
 	ixp4xx_sys_init();
 
 	pm_power_off = nslu2_power_off;

-- 
Martin Michlmayr
http://www.cyrius.com/
