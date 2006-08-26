From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] bcm43xx-d80211: 4311 support
Date: Sat, 26 Aug 2006 15:16:02 +0200
Message-ID: <200608261516.03170.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply this to wireless-dev.

--

This adds support for the 4311 cards.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-26 13:34:45.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-26 14:06:11.000000000 +0200
@@ -129,6 +129,8 @@ static struct pci_device_id bcm43xx_pci_
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4311 802.11a/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4311, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4312 802.11a/b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4312, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4318 802.11b/g */
@@ -2301,7 +2303,9 @@ static int bcm43xx_wireless_core_init(st
 	u32 sbimconfiglow;
 	u8 limit;
 
-	if (bcm->ssb.chip_rev < 5) {
+	assert(bcm->core_pci);
+	if (bcm->core_pci->cc == SSB_CC_PCI &&
+	    bcm->core_pci->rev <= 5) {
 		sbimconfiglow = bcm43xx_read32(bcm, SSB_IMCFGLO);
 		sbimconfiglow &= ~SSB_IMCFGLO_REQTO;
 		sbimconfiglow &= ~SSB_IMCFGLO_SERTO;
@@ -2712,6 +2716,7 @@ static int bcm43xx_probe_cores(struct bc
 
 		switch (core->cc) {
 		case SSB_CC_PCI:
+		case SSB_CC_PCIE:
 			if (bcm->core_pci) {
 				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
 				break;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c	2006-08-24 22:18:03.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c	2006-08-26 15:05:21.000000000 +0200
@@ -153,8 +153,6 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	int err, maxfreq;
 	struct ssb_core *old_core;
 
-	if (!(bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL))
-		return 0;
 	if (!bcm->core_chipcommon)
 		return 0;
 
@@ -163,11 +161,26 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	if (err)
 		goto out;
 
-	maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
-	bcm43xx_write32(bcm, SSB_CHIPCOMMON_PLLONDELAY,
-			(maxfreq * 150 + 999999) / 1000000);
-	bcm43xx_write32(bcm, SSB_CHIPCOMMON_FREFSELDELAY,
-			(maxfreq * 15 + 999999) / 1000000);
+	if (bcm->ssb.chip_id == 0x4321) {
+		if (bcm->ssb.chip_rev == 0)
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_CHIPCTL, 0x03A4);
+		else if (bcm->ssb.chip_rev == 1)
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_CHIPCTL, 0x00A4);
+	}
+	if (bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL) {
+		if (bcm->core_chipcommon->rev >= 10) {
+			/* Set Idle Power clock rate to 1Mhz */
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_SYSCLKCTL,
+					(bcm43xx_read32(bcm, SSB_CHIPCOMMON_SYSCLKCTL) &
+					 0x0000FFFF) | 0x00040000);
+		} else {
+			maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_PLLONDELAY,
+					(maxfreq * 150 + 999999) / 1000000);
+			bcm43xx_write32(bcm, SSB_CHIPCOMMON_FREFSELDELAY,
+					(maxfreq * 15 + 999999) / 1000000);
+		}
+	}
 
 	err = ssb_switch_core(&bcm->ssb, old_core);
 	assert(err == 0);
Index: wireless-dev/include/linux/ssb.h
===================================================================
--- wireless-dev.orig/include/linux/ssb.h	2006-08-26 13:40:11.000000000 +0200
+++ wireless-dev/include/linux/ssb.h	2006-08-26 14:57:44.000000000 +0200
@@ -279,12 +279,40 @@ enum {
 #define  SSB_CHIPCOMMON_CAP_64BIT	0x08000000	/* 64-bit Backplane */
 #define SSB_CHIPCOMMON_CORECTL		0x0008
 #define SSB_CHIPCOMMON_BIST		0x000C
+#define SSB_CHIPCOMMON_OTPSTAT		0x0010
+#define SSB_CHIPCOMMON_OTPCTL		0x0014
+#define SSB_CHIPCOMMON_OTPPRG		0x0018
+#define SSB_CHIPCOMMON_IRQSTAT		0x0020
+#define SSB_CHIPCOMMON_IRQMASK		0x0024
+#define SSB_CHIPCOMMON_CHIPCTL		0x0028	/* Rev >= 11 only */
+#define SSB_CHIPCOMMON_CHIPSTAT		0x002C	/* Rev >= 11 only */
+#define SSB_CHIPCOMMON_JTAGCMD		0x0030	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_JTAGIR		0x0034	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_JTAGDR		0x0038	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_JTAGCTL		0x003C	/* Rev >= 10 only */
+#define SSB_CHIPCOMMON_FLASHCTL		0x0040
+#define SSB_CHIPCOMMON_FLASHADDR	0x0044
+#define SSB_CHIPCOMMON_FLASHDATA	0x0048
 #define SSB_CHIPCOMMON_BCAST_ADDR	0x0050
 #define SSB_CHIPCOMMON_BCAST_DATA	0x0054
-#define SSB_CHIPCOMMON_PLLONDELAY	0x00B0
-#define SSB_CHIPCOMMON_FREFSELDELAY	0x00B4
-#define SSB_CHIPCOMMON_SLOWCLKCTL	0x00B8
-#define SSB_CHIPCOMMON_SYSCLKCTL	0x00C0
+#define SSB_CHIPCOMMON_GPIOIN		0x0060
+#define SSB_CHIPCOMMON_GPIOOUT		0x0064
+#define SSB_CHIPCOMMON_GPIOOUTEN	0x0068
+#define SSB_CHIPCOMMON_GPIOCTL		0x006C
+#define SSB_CHIPCOMMON_GPIOPOL		0x0070
+#define SSB_CHIPCOMMON_GPIOIRQ		0x0074
+#define SSB_CHIPCOMMON_WATCHDOG		0x0080
+#define SSB_CHIPCOMMON_CLOCK_N		0x0090
+#define SSB_CHIPCOMMON_CLOCK_SB		0x0094
+#define SSB_CHIPCOMMON_CLOCK_PCI	0x0098
+#define SSB_CHIPCOMMON_CLOCK_M2		0x009C
+#define SSB_CHIPCOMMON_CLOCK_MIPS	0x00A0
+#define SSB_CHIPCOMMON_UARTCLKDIV	0x00A4	/* Rev >= 3 only */
+#define SSB_CHIPCOMMON_PLLONDELAY	0x00B0	/* Rev >= 4 only */
+#define SSB_CHIPCOMMON_FREFSELDELAY	0x00B4	/* Rev >= 4 only */
+#define SSB_CHIPCOMMON_SLOWCLKCTL	0x00B8	/* 6 <= Rev <= 9 only */
+#define SSB_CHIPCOMMON_SYSCLKCTL	0x00C0	/* Rev >= 3 only */
+#define SSB_CHIPCOMMON_CLKSTSTR		0x00C4	/* Rev >= 3 only */
 
 /* PCI core registers. */
 #define SSB_PCICORE_CTL		0x0000	/* PCI Control */


-- 
Greetings Michael.
