From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Thu, 29 Apr 2010 08:54:22 +0200
Message-ID: <20100429065422.GA5803@riccoc20.at.omicron.at>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <20100427102025.GA6471@riccoc20.at.omicron.at> <4BD6E837.2040505@grandegger.com> <4BD70EC9.7080004@grandegger.com> <20100428054706.GA4516@riccoc20.at.omicron.at> <4BD83D37.4060301@grandegger.com> <4BD846C7.1050006@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:62597 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757891Ab0D3SHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:07:20 -0400
Received: by fg-out-1718.google.com with SMTP id d23so209266fga.1
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:07:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4BD846C7.1050006@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 28, 2010 at 04:31:35PM +0200, Wolfgang Grandegger wrote:
> That's because some 1588_PPS related bits are not yet setup in the
> platform code of mainline kernel.

So did you get it working?

I am reworking this patch set to post again, but perhaps you might
take a look at the patch below. It configures the gianfar PTP clock
parameters via the device tree.

Richard

[PATCH] ptp: gianfar clock uses device tree parameters
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 arch/powerpc/boot/dts/mpc8313erdb.dts |   14 +++++
 arch/powerpc/boot/dts/p2020ds.dts     |   13 ++++
 arch/powerpc/boot/dts/p2020rdb.dts    |   14 +++++
 drivers/net/gianfar_ptp.c             |  102 ++++++++++++++++++++++----------
 4 files changed, 111 insertions(+), 32 deletions(-)

diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boot/dts/mpc8313erdb.dts
index 183f2aa..b760aee 100644
--- a/arch/powerpc/boot/dts/mpc8313erdb.dts
+++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
@@ -208,6 +208,20 @@
 			sleep = <&pmc 0x00300000>;
 		};
 
+		ptp_clock@24E00 {
+			device_type = "ptp_clock";
+			model = "eTSEC";
+			reg = <0x24E00 0xB0>;
+			interrupts = <0x0C 2 0x0D 2>;
+			interrupt-parent = < &ipic >;
+			tclk_period = <10>;
+			tmr_prsc    = <100>;
+			tmr_add     = <0x999999A4>;
+			cksel       = <0x1>;
+			tmr_fiper1  = <0x3B9AC9F6>;
+			tmr_fiper2  = <0x00018696>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/p2020ds.dts b/arch/powerpc/boot/dts/p2020ds.dts
index 1101914..1dcf790 100644
--- a/arch/powerpc/boot/dts/p2020ds.dts
+++ b/arch/powerpc/boot/dts/p2020ds.dts
@@ -336,6 +336,19 @@
 			phy_type = "ulpi";
 		};
 
+		ptp_clock@24E00 {
+			device_type = "ptp_clock";
+			model = "eTSEC";
+			reg = <0x24E00 0xB0>;
+			interrupts = <0x0C 2 0x0D 2>;
+			interrupt-parent = < &mpic >;
+			tclk_period = <5>;
+			tmr_prsc = <200>;
+			tmr_add = <0xCCCCCCCD>;
+			tmr_fiper1 = <0x3B9AC9FB>;
+			tmr_fiper2 = <0x0001869B>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/p2020rdb.dts b/arch/powerpc/boot/dts/p2020rdb.dts
index da4cb0d..ba61e8e 100644
--- a/arch/powerpc/boot/dts/p2020rdb.dts
+++ b/arch/powerpc/boot/dts/p2020rdb.dts
@@ -396,6 +396,20 @@
 			phy_type = "ulpi";
 		};
 
+		ptp_clock@24E00 {
+			device_type = "ptp_clock";
+			model = "eTSEC";
+			reg = <0x24E00 0xB0>;
+			interrupts = <0x0C 2 0x0D 2>;
+			interrupt-parent = < &mpic >;
+			tclk_period = <5>;
+			tmr_prsc = <200>;
+			tmr_add = <0xCCCCCCCD>;
+			cksel = <1>;
+			tmr_fiper1 = <0x3B9AC9FB>;
+			tmr_fiper2 = <0x0001869B>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/gianfar_ptp.c
index eed3246..ed6234c 100644
--- a/drivers/net/gianfar_ptp.c
+++ b/drivers/net/gianfar_ptp.c
@@ -22,6 +22,8 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
 #include <linux/timex.h>
 #include <asm/io.h>
 
@@ -29,29 +31,16 @@
 
 #include "gianfar_ptp_reg.h"
 
-/*
- *
- * TODO - get the following from device tree
- *
- */
-#define TMR_BASE_KERNEL	0xe0024e00 // CONFIG_PPC_85xx 0xffe24e00
-#define TIMER_OSC	166666666
-#define TCLK_PERIOD	10
-#define NOMINAL_FREQ	100000000
-#define DEF_TMR_PRSC	100
-#define DEF_TMR_ADD	0x999999A4
-#define DEFAULT_CKSEL   1
-
 #define REG_SIZE	(4 + TMR_ETTS2_L)
 
 struct etsects {
 	void *regs;
-	u32 timer_osc;    /* Hz */
 	u32 tclk_period;  /* nanoseconds */
-	s64 nominal_freq; /* Hz */
 	u32 tmr_prsc;
 	u32 tmr_add;
 	u32 cksel;
+	u32 tmr_fiper1;
+	u32 tmr_fiper2;
 };
 
 /* Private globals */
@@ -111,8 +100,8 @@ static void set_fipers(struct etsects *etsects)
 
 	reg_write(etsects, TMR_CTRL,   tmr_ctrl & (~TE));
 	reg_write(etsects, TMR_PRSC,   etsects->tmr_prsc);
-	reg_write(etsects, TMR_FIPER1, 0x3B9AC9F6);
-	reg_write(etsects, TMR_FIPER2, 0x00018696);
+	reg_write(etsects, TMR_FIPER1, etsects->tmr_fiper1);
+	reg_write(etsects, TMR_FIPER2, etsects->tmr_fiper2);
 	set_alarm(etsects);
 	reg_write(etsects, TMR_CTRL,   tmr_ctrl|TE);
 }
@@ -213,34 +202,51 @@ struct ptp_clock_info ptp_gianfar_caps = {
 	.enable		= ptp_gianfar_enable,
 };
 
-/* module operations */
+/* OF device tree */
 
-static void __exit ptp_gianfar_exit(void)
+static int get_of_u32(struct device_node *node, char *str, u32 *val)
 {
-	ptp_clock_unregister(&ptp_gianfar_caps);
-	iounmap(the_clock.regs);
+	int plen;
+	const u32 *prop = of_get_property(node, str, &plen);
+
+	if (!prop || plen != sizeof(*prop))
+		return -1;
+	*val = *prop;
+	return 0;
 }
 
-static int __init ptp_gianfar_init(void)
+static int gianfar_ptp_probe(struct of_device* dev,
+			     const struct of_device_id *match)
 {
+	u64 addr, size;
+	struct device_node *node = dev->node;
 	struct etsects *etsects = &the_clock;
 	struct timespec now;
-	phys_addr_t reg_addr = TMR_BASE_KERNEL;
-	unsigned long reg_size = REG_SIZE;
+	phys_addr_t reg_addr;
+	unsigned long reg_size;
 	u32 tmr_ctrl;
 	int err;
 
+	if (get_of_u32(node, "tclk_period", &etsects->tclk_period) ||
+	    get_of_u32(node, "tmr_prsc", &etsects->tmr_prsc) ||
+	    get_of_u32(node, "tmr_add", &etsects->tmr_add) ||
+	    get_of_u32(node, "cksel", &etsects->cksel) ||
+	    get_of_u32(node, "tmr_fiper1", &etsects->tmr_fiper1) ||
+	    get_of_u32(node, "tmr_fiper2", &etsects->tmr_fiper2))
+		return -ENODEV;
+
+	addr = of_translate_address(node, of_get_address(node, 0, &size, NULL));
+	reg_addr = addr;
+	reg_size = size;
+	if (reg_size < REG_SIZE) {
+		pr_warning("device tree reg range %lu too small\n", reg_size);
+		reg_size = REG_SIZE;
+	}
 	etsects->regs = ioremap(reg_addr, reg_size);
 	if (!etsects->regs) {
 		pr_err("ioremap ptp registers failed\n");
 		return -EINVAL;
 	}
-	etsects->timer_osc = TIMER_OSC;
-	etsects->tclk_period = TCLK_PERIOD;
-	etsects->nominal_freq = NOMINAL_FREQ;
-	etsects->tmr_prsc = DEF_TMR_PRSC;
-	etsects->tmr_add = DEF_TMR_ADD;
-	etsects->cksel = DEFAULT_CKSEL;
 
 	tmr_ctrl =
 	  (etsects->tclk_period & TCLK_PERIOD_MASK) << TCLK_PERIOD_SHIFT |
@@ -252,8 +258,8 @@ static int __init ptp_gianfar_init(void)
 	reg_write(etsects, TMR_CTRL,   tmr_ctrl);
 	reg_write(etsects, TMR_ADD,    etsects->tmr_add);
 	reg_write(etsects, TMR_PRSC,   etsects->tmr_prsc);
-	reg_write(etsects, TMR_FIPER1, 0x3B9AC9F6);
-	reg_write(etsects, TMR_FIPER2, 0x00018696);
+	reg_write(etsects, TMR_FIPER1, etsects->tmr_fiper1);
+	reg_write(etsects, TMR_FIPER2, etsects->tmr_fiper2);
 	set_alarm(etsects);
 	reg_write(etsects, TMR_CTRL,   tmr_ctrl|FS|RTPE|TE);
 
@@ -261,6 +267,38 @@ static int __init ptp_gianfar_init(void)
 	return err;
 }
 
+static int gianfar_ptp_remove(struct of_device* dev)
+{
+	ptp_clock_unregister(&ptp_gianfar_caps);
+	iounmap(the_clock.regs);
+	return 0;
+}
+
+static struct of_device_id match_table[] = {
+	{ .type = "ptp_clock" },
+	{},
+};
+
+static struct of_platform_driver gianfar_ptp_driver = {
+	.name        = "gianfar_ptp",
+	.match_table = match_table,
+	.owner       = THIS_MODULE,
+	.probe       = gianfar_ptp_probe,
+	.remove      = gianfar_ptp_remove,
+};
+
+/* module operations */
+
+static void __exit ptp_gianfar_exit(void)
+{
+	of_unregister_platform_driver(&gianfar_ptp_driver);
+}
+
+static int __init ptp_gianfar_init(void)
+{
+	return of_register_platform_driver(&gianfar_ptp_driver);
+}
+
 subsys_initcall(ptp_gianfar_init);
 module_exit(ptp_gianfar_exit);
 
-- 
1.6.0.4

