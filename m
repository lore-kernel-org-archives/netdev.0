From: Aurelien Jarno <aurelien@aurel32.net>
Subject: [PATCH 4/4][SSB] Implement ssb_cpu_clock()
Date: Mon, 6 Aug 2007 01:21:29 +0200
Message-ID: <20070805232129.GE13927@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Felix Fietkau <nbd@openwrt.org>
To: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:47577 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955AbXHEX4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 19:56:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below against 2.6.23-rc1-mm2 implements the ssb_cpu_clock()
currently doing nothing, and export it. This function is needed to
support the BCM947xx CPUs.

It originally comes from the OpenWrt patches.

Cc: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

--- a/drivers/ssb/driver_mipscore.c
+++ b/drivers/ssb/driver_mipscore.c
@@ -220,8 +220,37 @@
 	extif_write32(extif, SSB_EXTIF_PROG_WAITCNT, tmp);
 }
 
-static void ssb_cpu_clock(struct ssb_mipscore *mcore)
+void ssb_extif_get_clockcontrol(struct ssb_extif *extif,
+                                              u32 *pll_type, u32 *n, u32 *m)
 {
+	*pll_type = SSB_PLLTYPE_1;
+	*n = extif_read32(extif, SSB_EXTIF_CLOCK_N);
+	*m = extif_read32(extif, SSB_EXTIF_CLOCK_SB);
+}
+
+u32 ssb_cpu_clock(struct ssb_mipscore *mcore)
+{
+	struct ssb_bus *bus = mcore->dev->bus;
+	u32 pll_type, n, m, rate = 0;
+
+	if (bus->extif.dev) {
+		ssb_extif_get_clockcontrol(&bus->extif, &pll_type, &n, &m);
+	} else if (bus->chipco.dev) {
+		ssb_chipco_get_clockcpu(&bus->chipco, &pll_type, &n, &m);
+	} else
+		return 0;
+
+	if ((pll_type == SSB_PLLTYPE_5) || (bus->chip_id == 0x5365)) {
+		rate = 200000000;
+	} else {
+		rate = ssb_calc_clock_rate(pll_type, n, m);
+	}
+
+	if (pll_type == SSB_PLLTYPE_6) {
+		rate *= 2;
+	}
+
+	return rate;
 }
 
 void ssb_mipscore_init(struct ssb_mipscore *mcore)
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -819,12 +819,12 @@
 	u32 plltype;
 	u32 clkctl_n, clkctl_m;
 
-	//TODO if EXTIF: PLLTYPE == 1, read n from clockcontrol_n, m from clockcontrol_sb
-
-	if (bus->chipco.dev) {
+	if (bus->extif.dev)
+		ssb_extif_get_clockcontrol(&bus->extif, &plltype, &clkctl_n, &clkctl_m);
+	else if (bus->chipco.dev)
 		ssb_chipco_get_clockcontrol(&bus->chipco, &plltype,
 					    &clkctl_n, &clkctl_m);
-	} else
+	else
 		return 0;
 
 	if (bus->chip_id == 0x5365) {
--- a/include/linux/ssb/ssb_driver_extif.h
+++ b/include/linux/ssb/ssb_driver_extif.h	
@@ -156,5 +156,6 @@
 /* watchdog */
 #define SSB_EXTIF_WATCHDOG_CLK		48000000	/* Hz */
 
+extern void ssb_extif_get_clockcontrol(struct ssb_extif *, u32 *, u32 *, u32 *);
 
 #endif /* LINUX_SSB_EXTIFCORE_H_ */
--- a/include/linux/ssb/ssb_driver_mips.h
+++ b/include/linux/ssb/ssb_driver_mips.h
@@ -26,6 +26,7 @@
 };
 
 extern void ssb_mipscore_init(struct ssb_mipscore *mcore);
+extern u32 ssb_cpu_clock(struct ssb_mipscore *mcore);
 
 extern unsigned int ssb_mips_irq(struct ssb_device *dev);
 

-- 
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
