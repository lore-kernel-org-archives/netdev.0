From: Joe Perches <joe@perches.com>
Subject: [PATCH] ssb: Use pr_fmt and pr_<level>, remove CONFIG_SSB_SILENT
Date: Tue, 05 Apr 2011 15:30:16 -0700
Message-ID: <1302042616.1683.4.camel@Joe-Laptop>
References: <1302033463-1846-1-git-send-email-zajec5@gmail.com>
	 <1302032137.3969.10.camel@Joe-Laptop>
	 <BANLkTimTmqop-xzFsWr1=2RXv5z6iTre4Q@mail.gmail.com>
	 (sfid-20110405_221605_148029_FFFFFFFFFD5E0FFF)  <1302035106.1923.7.camel@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-embedded <linux-embedded@vger.kernel.org>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4536 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795Ab1DEWaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 18:30:18 -0400
In-Reply-To: <1302035106.1923.7.camel@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the more common logging styles.
Remove CONFIG_SSB_SILENT which doesn't appear particularly useful.
Remove "ERROR: " prefixes from pr_err messages.

Signed-off-by: Joe Perches <joe@perches.com>

---

 drivers/ssb/Kconfig                 |   14 +---------
 drivers/ssb/driver_chipcommon.c     |    2 +-
 drivers/ssb/driver_chipcommon_pmu.c |   27 +++++++++---------
 drivers/ssb/driver_mipscore.c       |   22 ++++++++-------
 drivers/ssb/driver_pcicore.c        |   15 +++++-----
 drivers/ssb/main.c                  |   48 +++++++++++++++-----------------
 drivers/ssb/pci.c                   |   49 +++++++++++++++-----------------
 drivers/ssb/pcmcia.c                |   52 +++++++++++++++--------------------
 drivers/ssb/scan.c                  |   36 ++++++++++--------------
 drivers/ssb/sprom.c                 |    6 +++-
 drivers/ssb/ssb_private.h           |   10 +------
 include/linux/ssb/ssb.h             |    4 +-
 12 files changed, 124 insertions(+), 161 deletions(-)

diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index 42cdaa9..9c2ef55 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -80,21 +80,9 @@ config SSB_SDIOHOST
 
 	  If unsure, say N
 
-config SSB_SILENT
-	bool "No SSB kernel messages"
-	depends on SSB && EXPERT
-	help
-	  This option turns off all Sonics Silicon Backplane printks.
-	  Note that you won't be able to identify problems, once
-	  messages are turned off.
-	  This might only be desired for production kernels on
-	  embedded devices to reduce the kernel size.
-
-	  Say N
-
 config SSB_DEBUG
 	bool "SSB debugging"
-	depends on SSB && !SSB_SILENT
+	depends on SSB
 	help
 	  This turns on additional runtime checks and debugging
 	  messages. Turn this on for SSB troubleshooting.
diff --git a/drivers/ssb/driver_chipcommon.c b/drivers/ssb/driver_chipcommon.c
index 7c031fd..65a99e3 100644
--- a/drivers/ssb/driver_chipcommon.c
+++ b/drivers/ssb/driver_chipcommon.c
@@ -259,7 +259,7 @@ void ssb_chipcommon_init(struct ssb_chipcommon *cc)
 		return; /* We don't have a ChipCommon */
 	if (cc->dev->id.revision >= 11)
 		cc->status = chipco_read32(cc, SSB_CHIPCO_CHIPSTAT);
-	ssb_dprintk(KERN_INFO PFX "chipcommon status is 0x%x\n", cc->status);
+	pr_debug("chipcommon status is 0x%x\n", cc->status);
 	ssb_pmu_init(cc);
 	chipco_powercontrol_init(cc);
 	ssb_chipco_set_clockmode(cc, SSB_CLKMODE_FAST);
diff --git a/drivers/ssb/driver_chipcommon_pmu.c b/drivers/ssb/driver_chipcommon_pmu.c
index 5732bb2..c501615 100644
--- a/drivers/ssb/driver_chipcommon_pmu.c
+++ b/drivers/ssb/driver_chipcommon_pmu.c
@@ -8,6 +8,8 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ssb/ssb.h>
 #include <linux/ssb/ssb_regs.h>
 #include <linux/ssb/ssb_driver_chipcommon.h>
@@ -110,8 +112,8 @@ static void ssb_pmu0_pllinit_r0(struct ssb_chipcommon *cc,
 		return;
 	}
 
-	ssb_printk(KERN_INFO PFX "Programming PLL to %u.%03u MHz\n",
-		   (crystalfreq / 1000), (crystalfreq % 1000));
+	pr_info("Programming PLL to %u.%03u MHz\n",
+		(crystalfreq / 1000), (crystalfreq % 1000));
 
 	/* First turn the PLL off. */
 	switch (bus->chip_id) {
@@ -138,7 +140,7 @@ static void ssb_pmu0_pllinit_r0(struct ssb_chipcommon *cc,
 	}
 	tmp = chipco_read32(cc, SSB_CHIPCO_CLKCTLST);
 	if (tmp & SSB_CHIPCO_CLKCTLST_HAVEHT)
-		ssb_printk(KERN_EMERG PFX "Failed to turn the PLL off!\n");
+		pr_emerg("Failed to turn the PLL off!\n");
 
 	/* Set PDIV in PLL control 0. */
 	pllctl = ssb_chipco_pll_read(cc, SSB_PMU0_PLLCTL0);
@@ -249,8 +251,8 @@ static void ssb_pmu1_pllinit_r0(struct ssb_chipcommon *cc,
 		return;
 	}
 
-	ssb_printk(KERN_INFO PFX "Programming PLL to %u.%03u MHz\n",
-		   (crystalfreq / 1000), (crystalfreq % 1000));
+	pr_info("Programming PLL to %u.%03u MHz\n",
+		(crystalfreq / 1000), (crystalfreq % 1000));
 
 	/* First turn the PLL off. */
 	switch (bus->chip_id) {
@@ -275,7 +277,7 @@ static void ssb_pmu1_pllinit_r0(struct ssb_chipcommon *cc,
 	}
 	tmp = chipco_read32(cc, SSB_CHIPCO_CLKCTLST);
 	if (tmp & SSB_CHIPCO_CLKCTLST_HAVEHT)
-		ssb_printk(KERN_EMERG PFX "Failed to turn the PLL off!\n");
+		pr_emerg("Failed to turn the PLL off!\n");
 
 	/* Set p1div and p2div. */
 	pllctl = ssb_chipco_pll_read(cc, SSB_PMU1_PLLCTL0);
@@ -339,9 +341,7 @@ static void ssb_pmu_pll_init(struct ssb_chipcommon *cc)
 		}
 		break;
 	default:
-		ssb_printk(KERN_ERR PFX
-			   "ERROR: PLL init unknown for device %04X\n",
-			   bus->chip_id);
+		pr_err("PLL init unknown for device %04X\n", bus->chip_id);
 	}
 }
 
@@ -459,9 +459,8 @@ static void ssb_pmu_resources_init(struct ssb_chipcommon *cc)
 		max_msk = 0xFFFFF;
 		break;
 	default:
-		ssb_printk(KERN_ERR PFX
-			   "ERROR: PMU resource config unknown for device %04X\n",
-			   bus->chip_id);
+		pr_err("PMU resource config unknown for device %04X\n",
+		       bus->chip_id);
 	}
 
 	if (updown_tab) {
@@ -513,8 +512,8 @@ void ssb_pmu_init(struct ssb_chipcommon *cc)
 	pmucap = chipco_read32(cc, SSB_CHIPCO_PMU_CAP);
 	cc->pmu.rev = (pmucap & SSB_CHIPCO_PMU_CAP_REVISION);
 
-	ssb_dprintk(KERN_DEBUG PFX "Found rev %u PMU (capabilities 0x%08X)\n",
-		    cc->pmu.rev, pmucap);
+	pr_debug("Found rev %u PMU (capabilities 0x%08X)\n",
+		 cc->pmu.rev, pmucap);
 
 	if (cc->pmu.rev == 1)
 		chipco_mask32(cc, SSB_CHIPCO_PMU_CTL,
diff --git a/drivers/ssb/driver_mipscore.c b/drivers/ssb/driver_mipscore.c
index 97efce1..97520ff 100644
--- a/drivers/ssb/driver_mipscore.c
+++ b/drivers/ssb/driver_mipscore.c
@@ -147,21 +147,23 @@ static void set_irq(struct ssb_device *dev, unsigned int irq)
 		irqflag |= (ipsflag & ~ipsflag_irq_mask[irq]);
 		ssb_write32(mdev, SSB_IPSFLAG, irqflag);
 	}
-	ssb_dprintk(KERN_INFO PFX
-		    "set_irq: core 0x%04x, irq %d => %d\n",
-		    dev->id.coreid, oldirq+2, irq+2);
+	pr_debug("set_irq: core 0x%04x, irq %d => %d\n",
+		 dev->id.coreid, oldirq+2, irq+2);
 }
 
 static void print_irq(struct ssb_device *dev, unsigned int irq)
 {
+#ifdef DEBUG
 	int i;
-	static const char *irq_name[] = {"2(S)", "3", "4", "5", "6", "D", "I"};
-	ssb_dprintk(KERN_INFO PFX
-		"core 0x%04x, irq :", dev->id.coreid);
+	static const char * const irq_name[] = {
+		"2(S)", "3", "4", "5", "6", "D", "I"
+	};
+	pr_debug("core 0x%04x, irq :", dev->id.coreid);
 	for (i = 0; i <= 6; i++) {
-		ssb_dprintk(" %s%s", irq_name[i], i==irq?"*":" ");
+		pr_cont(" %s%s", irq_name[i], i==irq?"*":" ");
 	}
-	ssb_dprintk("\n");
+	pr_cont("\n");
+#endif
 }
 
 static void dump_irq(struct ssb_bus *bus)
@@ -238,7 +240,7 @@ void ssb_mipscore_init(struct ssb_mipscore *mcore)
 	if (!mcore->dev)
 		return; /* We don't have a MIPS core */
 
-	ssb_dprintk(KERN_INFO PFX "Initializing MIPS core...\n");
+	pr_debug("Initializing MIPS core...\n");
 
 	bus = mcore->dev->bus;
 	hz = ssb_clockspeed(bus);
@@ -286,7 +288,7 @@ void ssb_mipscore_init(struct ssb_mipscore *mcore)
 			break;
 		}
 	}
-	ssb_dprintk(KERN_INFO PFX "after irq reconfiguration\n");
+	pr_debug("after irq reconfiguration\n");
 	dump_irq(bus);
 
 	ssb_mips_serial_init(mcore);
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 1ba9f0e..38d7215 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -8,6 +8,8 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ssb/ssb.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
@@ -262,8 +264,7 @@ int ssb_pcicore_plat_dev_init(struct pci_dev *d)
 		return -ENODEV;
 	}
 
-	ssb_printk(KERN_INFO "PCI: Fixing up device %s\n",
-		   pci_name(d));
+	pr_info("PCI: Fixing up device %s\n", pci_name(d));
 
 	/* Fix up interrupt lines */
 	d->irq = ssb_mips_irq(extpci_core->dev) + 2;
@@ -284,12 +285,12 @@ static void ssb_pcicore_fixup_pcibridge(struct pci_dev *dev)
 	if (dev->bus->number != 0 || PCI_SLOT(dev->devfn) != 0)
 		return;
 
-	ssb_printk(KERN_INFO "PCI: Fixing up bridge %s\n", pci_name(dev));
+	pr_info("PCI: Fixing up bridge %s\n", pci_name(dev));
 
 	/* Enable PCI bridge bus mastering and memory space */
 	pci_set_master(dev);
 	if (pcibios_enable_device(dev, ~0) < 0) {
-		ssb_printk(KERN_ERR "PCI: SSB bridge enable failed\n");
+		pr_err("PCI: SSB bridge enable failed\n");
 		return;
 	}
 
@@ -298,7 +299,7 @@ static void ssb_pcicore_fixup_pcibridge(struct pci_dev *dev)
 
 	/* Make sure our latency is high enough to handle the devices behind us */
 	lat = 168;
-	ssb_printk(KERN_INFO "PCI: Fixing latency timer of device %s to %u\n",
+	pr_info("PCI: Fixing latency timer of device %s to %u\n",
 		   pci_name(dev), lat);
 	pci_write_config_byte(dev, PCI_LATENCY_TIMER, lat);
 }
@@ -322,7 +323,7 @@ static void ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
 		return;
 	extpci_core = pc;
 
-	ssb_dprintk(KERN_INFO PFX "PCIcore in host mode found\n");
+	pr_debug("PCIcore in host mode found\n");
 	/* Reset devices on the external PCI bus */
 	val = SSB_PCICORE_CTL_RST_OE;
 	val |= SSB_PCICORE_CTL_CLK_OE;
@@ -337,7 +338,7 @@ static void ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
 	udelay(1); /* Assertion time demanded by the PCI standard */
 
 	if (pc->dev->bus->has_cardbus_slot) {
-		ssb_dprintk(KERN_INFO PFX "CardBus slot detected\n");
+		pr_debug("CardBus slot detected\n");
 		pc->cardbusmode = 1;
 		/* GPIO 1 resets the bridge */
 		ssb_gpio_out(pc->dev->bus, 1, 1);
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index e05ba6e..be4fc17 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -8,6 +8,8 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ssb_private.h"
 
 #include <linux/delay.h>
@@ -288,8 +290,8 @@ int ssb_devices_thaw(struct ssb_freeze_context *ctx)
 
 		err = sdrv->probe(sdev, &sdev->id);
 		if (err) {
-			ssb_printk(KERN_ERR PFX "Failed to thaw device %s\n",
-				   dev_name(sdev->dev));
+			pr_err("Failed to thaw device %s\n",
+			       dev_name(sdev->dev));
 			result = err;
 		}
 		ssb_driver_put(sdrv);
@@ -497,8 +499,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 
 		devwrap = kzalloc(sizeof(*devwrap), GFP_KERNEL);
 		if (!devwrap) {
-			ssb_printk(KERN_ERR PFX
-				   "Could not allocate device\n");
+			pr_err("Could not allocate device\n");
 			err = -ENOMEM;
 			goto error;
 		}
@@ -537,9 +538,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 		sdev->dev = dev;
 		err = device_register(dev);
 		if (err) {
-			ssb_printk(KERN_ERR PFX
-				   "Could not register %s\n",
-				   dev_name(dev));
+			pr_err("Could not register %s\n", dev_name(dev));
 			/* Set dev to NULL to not unregister
 			 * dev on error unwinding. */
 			sdev->dev = NULL;
@@ -862,11 +861,11 @@ int ssb_bus_pcibus_register(struct ssb_bus *bus,
 
 	err = ssb_bus_register(bus, ssb_pci_get_invariants, 0);
 	if (!err) {
-		ssb_printk(KERN_INFO PFX "Sonics Silicon Backplane found on "
-			   "PCI device %s\n", dev_name(&host_pci->dev));
+		pr_info("Sonics Silicon Backplane found on PCI device %s\n",
+			dev_name(&host_pci->dev));
 	} else {
-		ssb_printk(KERN_ERR PFX "Failed to register PCI version"
-			   " of SSB with error %d\n", err);
+		pr_err("Failed to register PCI version of SSB with error %d\n",
+		       err);
 	}
 
 	return err;
@@ -887,8 +886,8 @@ int ssb_bus_pcmciabus_register(struct ssb_bus *bus,
 
 	err = ssb_bus_register(bus, ssb_pcmcia_get_invariants, baseaddr);
 	if (!err) {
-		ssb_printk(KERN_INFO PFX "Sonics Silicon Backplane found on "
-			   "PCMCIA device %s\n", pcmcia_dev->devname);
+		pr_info("Sonics Silicon Backplane found on PCMCIA device %s\n",
+			pcmcia_dev->devname);
 	}
 
 	return err;
@@ -909,8 +908,8 @@ int ssb_bus_sdiobus_register(struct ssb_bus *bus, struct sdio_func *func,
 
 	err = ssb_bus_register(bus, ssb_sdio_get_invariants, ~0);
 	if (!err) {
-		ssb_printk(KERN_INFO PFX "Sonics Silicon Backplane found on "
-			   "SDIO device %s\n", sdio_func_id(func));
+		pr_info("Sonics Silicon Backplane found on SDIO device %s\n",
+			sdio_func_id(func));
 	}
 
 	return err;
@@ -929,8 +928,8 @@ int ssb_bus_ssbbus_register(struct ssb_bus *bus,
 
 	err = ssb_bus_register(bus, get_invariants, baseaddr);
 	if (!err) {
-		ssb_printk(KERN_INFO PFX "Sonics Silicon Backplane found at "
-			   "address 0x%08lX\n", baseaddr);
+		pr_info("Sonics Silicon Backplane found at address 0x%08lX\n",
+			baseaddr);
 	}
 
 	return err;
@@ -1130,7 +1129,7 @@ static u32 ssb_tmslow_reject_bitmask(struct ssb_device *dev)
 	case SSB_IDLOW_SSBREV_27:     /* same here */
 		return SSB_TMSLOW_REJECT_23;	/* this is a guess */
 	default:
-		printk(KERN_INFO "ssb: Backplane Revision 0x%.8X\n", rev);
+		pr_info("Backplane Revision 0x%.8X\n", rev);
 		WARN_ON(1);
 	}
 	return (SSB_TMSLOW_REJECT_22 | SSB_TMSLOW_REJECT_23);
@@ -1211,8 +1210,7 @@ static int ssb_wait_bits(struct ssb_device *dev, u16 reg, u32 bitmask,
 		}
 		udelay(10);
 	}
-	printk(KERN_ERR PFX "Timeout waiting for bitmask %08X on "
-			    "register %04X to %s.\n",
+	pr_err("Timeout waiting for bitmask %08X on register %04X to %s\n",
 	       bitmask, reg, (set ? "set" : "clear"));
 
 	return -ETIMEDOUT;
@@ -1302,7 +1300,7 @@ out:
 #endif
 	return err;
 error:
-	ssb_printk(KERN_ERR PFX "Bus powerdown failed\n");
+	pr_err("Bus powerdown failed\n");
 	goto out;
 }
 EXPORT_SYMBOL(ssb_bus_may_powerdown);
@@ -1325,7 +1323,7 @@ int ssb_bus_powerup(struct ssb_bus *bus, bool dynamic_pctl)
 #endif
 	return 0;
 error:
-	ssb_printk(KERN_ERR PFX "Bus powerup failed\n");
+	pr_err("Bus powerup failed\n");
 	return err;
 }
 EXPORT_SYMBOL(ssb_bus_powerup);
@@ -1402,15 +1400,13 @@ static int __init ssb_modinit(void)
 
 	err = b43_pci_ssb_bridge_init();
 	if (err) {
-		ssb_printk(KERN_ERR "Broadcom 43xx PCI-SSB-bridge "
-			   "initialization failed\n");
+		pr_err("Broadcom 43xx PCI-SSB-bridge initialization failed\n");
 		/* don't fail SSB init because of this */
 		err = 0;
 	}
 	err = ssb_gige_init();
 	if (err) {
-		ssb_printk(KERN_ERR "SSB Broadcom Gigabit Ethernet "
-			   "driver initialization failed\n");
+		pr_err("SSB Broadcom Gigabit Ethernet driver initialization failed\n");
 		/* don't fail SSB init because of this */
 		err = 0;
 	}
diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
index a467b20..04a2834 100644
--- a/drivers/ssb/pci.c
+++ b/drivers/ssb/pci.c
@@ -15,6 +15,8 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ssb/ssb.h>
 #include <linux/ssb/ssb_regs.h>
 #include <linux/slab.h>
@@ -56,7 +58,7 @@ int ssb_pci_switch_coreidx(struct ssb_bus *bus, u8 coreidx)
 	}
 	return 0;
 error:
-	ssb_printk(KERN_ERR PFX "Failed to switch to core %u\n", coreidx);
+	pr_err("Failed to switch to core %u\n", coreidx);
 	return -ENODEV;
 }
 
@@ -67,10 +69,8 @@ int ssb_pci_switch_core(struct ssb_bus *bus,
 	unsigned long flags;
 
 #if SSB_VERBOSE_PCICORESWITCH_DEBUG
-	ssb_printk(KERN_INFO PFX
-		   "Switching to %s core, index %d\n",
-		   ssb_core_name(dev->id.coreid),
-		   dev->core_index);
+	pr_info("Switching to %s core, index %d\n",
+		ssb_core_name(dev->id.coreid), dev->core_index);
 #endif
 
 	spin_lock_irqsave(&bus->bar_lock, flags);
@@ -162,7 +162,7 @@ out:
 	return err;
 
 err_pci:
-	printk(KERN_ERR PFX "Error: ssb_pci_xtal() could not access PCI config space!\n");
+	pr_err("Error: ssb_pci_xtal() could not access PCI config space!\n");
 	err = -EBUSY;
 	goto out;
 }
@@ -266,7 +266,7 @@ static int sprom_do_write(struct ssb_bus *bus, const u16 *sprom)
 	u32 spromctl;
 	u16 size = bus->sprom_size;
 
-	ssb_printk(KERN_NOTICE PFX "Writing SPROM. Do NOT turn off the power! Please stand by...\n");
+	pr_notice("Writing SPROM. Do NOT turn off the power! Please stand by...\n");
 	err = pci_read_config_dword(pdev, SSB_SPROMCTL, &spromctl);
 	if (err)
 		goto err_ctlreg;
@@ -274,17 +274,17 @@ static int sprom_do_write(struct ssb_bus *bus, const u16 *sprom)
 	err = pci_write_config_dword(pdev, SSB_SPROMCTL, spromctl);
 	if (err)
 		goto err_ctlreg;
-	ssb_printk(KERN_NOTICE PFX "[ 0%%");
+	pr_notice("[ 0%%");
 	msleep(500);
 	for (i = 0; i < size; i++) {
 		if (i == size / 4)
-			ssb_printk("25%%");
+			printk("25%%");
 		else if (i == size / 2)
-			ssb_printk("50%%");
+			printk("50%%");
 		else if (i == (size * 3) / 4)
-			ssb_printk("75%%");
+			printk("75%%");
 		else if (i % 2)
-			ssb_printk(".");
+			printk(".");
 		writew(sprom[i], bus->mmio + bus->sprom_offset + (i * 2));
 		mmiowb();
 		msleep(20);
@@ -297,12 +297,12 @@ static int sprom_do_write(struct ssb_bus *bus, const u16 *sprom)
 	if (err)
 		goto err_ctlreg;
 	msleep(500);
-	ssb_printk("100%% ]\n");
-	ssb_printk(KERN_NOTICE PFX "SPROM written.\n");
+	printk("100%% ]\n");
+	pr_notice("SPROM written\n");
 
 	return 0;
 err_ctlreg:
-	ssb_printk(KERN_ERR PFX "Could not access SPROM control register.\n");
+	pr_err("Could not access SPROM control register\n");
 	return err;
 }
 
@@ -618,7 +618,7 @@ static int sprom_extract(struct ssb_bus *bus, struct ssb_sprom *out,
 	memset(out, 0, sizeof(*out));
 
 	out->revision = in[size - 1] & 0x00FF;
-	ssb_dprintk(KERN_DEBUG PFX "SPROM revision %d detected.\n", out->revision);
+	pr_debug("SPROM revision %d detected\n", out->revision);
 	memset(out->et0mac, 0xFF, 6);		/* preset et0 and et1 mac */
 	memset(out->et1mac, 0xFF, 6);
 
@@ -627,7 +627,7 @@ static int sprom_extract(struct ssb_bus *bus, struct ssb_sprom *out,
 		 * number stored in the SPROM.
 		 * Always extract r1. */
 		out->revision = 1;
-		ssb_dprintk(KERN_DEBUG PFX "SPROM treated as revision %d\n", out->revision);
+		pr_debug("SPROM treated as revision %d\n", out->revision);
 	}
 
 	switch (out->revision) {
@@ -644,9 +644,8 @@ static int sprom_extract(struct ssb_bus *bus, struct ssb_sprom *out,
 		sprom_extract_r8(out, in);
 		break;
 	default:
-		ssb_printk(KERN_WARNING PFX "Unsupported SPROM"
-			   " revision %d detected. Will extract"
-			   " v1\n", out->revision);
+		pr_warn("Unsupported SPROM revision %d detected. Will extract v1\n",
+			out->revision);
 		out->revision = 1;
 		sprom_extract_r123(out, in);
 	}
@@ -667,7 +666,7 @@ static int ssb_pci_sprom_get(struct ssb_bus *bus,
 	u16 *buf;
 
 	if (!ssb_is_sprom_available(bus)) {
-		ssb_printk(KERN_ERR PFX "No SPROM available!\n");
+		pr_err("No SPROM available!\n");
 		return -ENODEV;
 	}
 	if (bus->chipco.dev) {	/* can be unavailible! */
@@ -686,7 +685,7 @@ static int ssb_pci_sprom_get(struct ssb_bus *bus,
 	} else {
 		bus->sprom_offset = SSB_SPROM_BASE1;
 	}
-	ssb_dprintk(KERN_INFO PFX "SPROM offset is 0x%x\n", bus->sprom_offset);
+	pr_debug("SPROM offset is 0x%x\n", bus->sprom_offset);
 
 	buf = kcalloc(SSB_SPROMSIZE_WORDS_R123, sizeof(u16), GFP_KERNEL);
 	if (!buf)
@@ -714,8 +713,7 @@ static int ssb_pci_sprom_get(struct ssb_bus *bus,
 				err = 0;
 				goto out_free;
 			}
-			ssb_printk(KERN_WARNING PFX "WARNING: Invalid"
-				   " SPROM CRC (corrupt SPROM)\n");
+			pr_warn("WARNING: Invalid SPROM CRC (corrupt SPROM)\n");
 		}
 	}
 	err = sprom_extract(bus, sprom, buf, bus->sprom_size);
@@ -756,8 +754,7 @@ static int ssb_pci_assert_buspower(struct ssb_bus *bus)
 	if (likely(bus->powered_up))
 		return 0;
 
-	printk(KERN_ERR PFX "FATAL ERROR: Bus powered down "
-	       "while accessing PCI MMIO space\n");
+	pr_err("FATAL ERROR: Bus powered down while accessing PCI MMIO space\n");
 	if (bus->power_warn_count <= 10) {
 		bus->power_warn_count++;
 		dump_stack();
diff --git a/drivers/ssb/pcmcia.c b/drivers/ssb/pcmcia.c
index f853379..03cf0a0 100644
--- a/drivers/ssb/pcmcia.c
+++ b/drivers/ssb/pcmcia.c
@@ -8,6 +8,8 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ssb/ssb.h>
 #include <linux/delay.h>
 #include <linux/io.h>
@@ -143,7 +145,7 @@ int ssb_pcmcia_switch_coreidx(struct ssb_bus *bus,
 
 	return 0;
 error:
-	ssb_printk(KERN_ERR PFX "Failed to switch to core %u\n", coreidx);
+	pr_err("Failed to switch to core %u\n", coreidx);
 	return err;
 }
 
@@ -153,10 +155,8 @@ int ssb_pcmcia_switch_core(struct ssb_bus *bus,
 	int err;
 
 #if SSB_VERBOSE_PCMCIACORESWITCH_DEBUG
-	ssb_printk(KERN_INFO PFX
-		   "Switching to %s core, index %d\n",
-		   ssb_core_name(dev->id.coreid),
-		   dev->core_index);
+	pr_info("Switching to %s core, index %d\n",
+		ssb_core_name(dev->id.coreid), dev->core_index);
 #endif
 
 	err = ssb_pcmcia_switch_coreidx(bus, dev->core_index);
@@ -192,7 +192,7 @@ int ssb_pcmcia_switch_segment(struct ssb_bus *bus, u8 seg)
 
 	return 0;
 error:
-	ssb_printk(KERN_ERR PFX "Failed to switch pcmcia segment\n");
+	pr_err("Failed to switch pcmcia segment\n");
 	return err;
 }
 
@@ -549,44 +549,39 @@ static int ssb_pcmcia_sprom_write_all(struct ssb_bus *bus, const u16 *sprom)
 	bool failed = 0;
 	size_t size = SSB_PCMCIA_SPROM_SIZE;
 
-	ssb_printk(KERN_NOTICE PFX
-		   "Writing SPROM. Do NOT turn off the power! "
-		   "Please stand by...\n");
+	pr_notice("Writing SPROM. Do NOT turn off the power! Please stand by...\n");
 	err = ssb_pcmcia_sprom_command(bus, SSB_PCMCIA_SPROMCTL_WRITEEN);
 	if (err) {
-		ssb_printk(KERN_NOTICE PFX
-			   "Could not enable SPROM write access.\n");
+		pr_notice("Could not enable SPROM write access\n");
 		return -EBUSY;
 	}
-	ssb_printk(KERN_NOTICE PFX "[ 0%%");
+	pr_notice("[ 0%%");
 	msleep(500);
 	for (i = 0; i < size; i++) {
 		if (i == size / 4)
-			ssb_printk("25%%");
+			printk("25%%");
 		else if (i == size / 2)
-			ssb_printk("50%%");
+			printk("50%%");
 		else if (i == (size * 3) / 4)
-			ssb_printk("75%%");
+			printk("75%%");
 		else if (i % 2)
-			ssb_printk(".");
+			printk(".");
 		err = ssb_pcmcia_sprom_write(bus, i, sprom[i]);
 		if (err) {
-			ssb_printk(KERN_NOTICE PFX
-				   "Failed to write to SPROM.\n");
+			pr_notice("Failed to write to SPROM\n");
 			failed = 1;
 			break;
 		}
 	}
 	err = ssb_pcmcia_sprom_command(bus, SSB_PCMCIA_SPROMCTL_WRITEDIS);
 	if (err) {
-		ssb_printk(KERN_NOTICE PFX
-			   "Could not disable SPROM write access.\n");
+		pr_notice("Could not disable SPROM write access\n");
 		failed = 1;
 	}
 	msleep(500);
 	if (!failed) {
-		ssb_printk("100%% ]\n");
-		ssb_printk(KERN_NOTICE PFX "SPROM written.\n");
+		printk("100%% ]\n");
+		pr_notice("SPROM written\n");
 	}
 
 	return failed ? -EBUSY : 0;
@@ -704,9 +699,8 @@ static int ssb_pcmcia_do_get_invariants(struct pcmcia_device *p_dev,
 	return -ENOSPC; /* continue with next entry */
 
 error:
-	ssb_printk(KERN_ERR PFX
-		   "PCMCIA: Failed to fetch device invariants: %s\n",
-		   error_description);
+	pr_err("PCMCIA: Failed to fetch device invariants: %s\n",
+	       error_description);
 	return -ENODEV;
 }
 
@@ -726,8 +720,7 @@ int ssb_pcmcia_get_invariants(struct ssb_bus *bus,
 	res = pcmcia_loop_tuple(bus->host_pcmcia, CISTPL_FUNCE,
 				ssb_pcmcia_get_mac, sprom);
 	if (res != 0) {
-		ssb_printk(KERN_ERR PFX
-			"PCMCIA: Failed to fetch MAC address\n");
+		pr_err("PCMCIA: Failed to fetch MAC address\n");
 		return -ENODEV;
 	}
 
@@ -737,8 +730,7 @@ int ssb_pcmcia_get_invariants(struct ssb_bus *bus,
 	if ((res == 0) || (res == -ENOSPC))
 		return 0;
 
-	ssb_printk(KERN_ERR PFX
-			"PCMCIA: Failed to fetch device invariants\n");
+	pr_err("PCMCIA: Failed to fetch device invariants\n");
 	return -ENODEV;
 }
 
@@ -847,6 +839,6 @@ int ssb_pcmcia_init(struct ssb_bus *bus)
 
 	return 0;
 error:
-	ssb_printk(KERN_ERR PFX "Failed to initialize PCMCIA host device\n");
+	pr_err("Failed to initialize PCMCIA host device\n");
 	return err;
 }
diff --git a/drivers/ssb/scan.c b/drivers/ssb/scan.c
index 7dca719..3e670f4 100644
--- a/drivers/ssb/scan.c
+++ b/drivers/ssb/scan.c
@@ -12,6 +12,8 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ssb/ssb.h>
 #include <linux/ssb/ssb_regs.h>
 #include <linux/pci.h>
@@ -123,8 +125,7 @@ static u16 pcidev_to_chipid(struct pci_dev *pci_dev)
 		chipid_fallback = 0x4401;
 		break;
 	default:
-		ssb_printk(KERN_ERR PFX
-			   "PCI-ID not in fallback list\n");
+		pr_err("PCI-ID not in fallback list\n");
 	}
 
 	return chipid_fallback;
@@ -150,8 +151,7 @@ static u8 chipid_to_nrcores(u16 chipid)
 	case 0x4704:
 		return 9;
 	default:
-		ssb_printk(KERN_ERR PFX
-			   "CHIPID not in nrcores fallback list\n");
+		pr_err("CHIPID not in nrcores fallback list\n");
 	}
 
 	return 1;
@@ -319,9 +319,8 @@ int ssb_bus_scan(struct ssb_bus *bus,
 	if (!bus->nr_devices)
 		bus->nr_devices = chipid_to_nrcores(bus->chip_id);
 	if (bus->nr_devices > ARRAY_SIZE(bus->devices)) {
-		ssb_printk(KERN_ERR PFX
-			   "More than %d ssb cores found (%d)\n",
-			   SSB_MAX_NR_CORES, bus->nr_devices);
+		pr_err("More than %d ssb cores found (%d)\n",
+		       SSB_MAX_NR_CORES, bus->nr_devices);
 		goto err_unmap;
 	}
 	if (bus->bustype == SSB_BUSTYPE_SSB) {
@@ -353,18 +352,17 @@ int ssb_bus_scan(struct ssb_bus *bus,
 		dev->ops = bus->ops;
 
 		printk(KERN_DEBUG PFX
-			    "Core %d found: %s "
-			    "(cc 0x%03X, rev 0x%02X, vendor 0x%04X)\n",
-			    i, ssb_core_name(dev->id.coreid),
-			    dev->id.coreid, dev->id.revision, dev->id.vendor);
+		       "Core %d found: %s "
+		       "(cc 0x%03X, rev 0x%02X, vendor 0x%04X)\n",
+		       i, ssb_core_name(dev->id.coreid),
+		       dev->id.coreid, dev->id.revision, dev->id.vendor);
 
 		switch (dev->id.coreid) {
 		case SSB_DEV_80211:
 			nr_80211_cores++;
 			if (nr_80211_cores > 1) {
 				if (!we_support_multiple_80211_cores(bus)) {
-					ssb_dprintk(KERN_INFO PFX "Ignoring additional "
-						    "802.11 core\n");
+					pr_debug("Ignoring additional 802.11 core\n");
 					continue;
 				}
 			}
@@ -372,8 +370,7 @@ int ssb_bus_scan(struct ssb_bus *bus,
 		case SSB_DEV_EXTIF:
 #ifdef CONFIG_SSB_DRIVER_EXTIF
 			if (bus->extif.dev) {
-				ssb_printk(KERN_WARNING PFX
-					   "WARNING: Multiple EXTIFs found\n");
+				pr_warn("WARNING: Multiple EXTIFs found\n");
 				break;
 			}
 			bus->extif.dev = dev;
@@ -381,8 +378,7 @@ int ssb_bus_scan(struct ssb_bus *bus,
 			break;
 		case SSB_DEV_CHIPCOMMON:
 			if (bus->chipco.dev) {
-				ssb_printk(KERN_WARNING PFX
-					   "WARNING: Multiple ChipCommon found\n");
+				pr_warn("WARNING: Multiple ChipCommon found\n");
 				break;
 			}
 			bus->chipco.dev = dev;
@@ -391,8 +387,7 @@ int ssb_bus_scan(struct ssb_bus *bus,
 		case SSB_DEV_MIPS_3302:
 #ifdef CONFIG_SSB_DRIVER_MIPS
 			if (bus->mipscore.dev) {
-				ssb_printk(KERN_WARNING PFX
-					   "WARNING: Multiple MIPS cores found\n");
+				pr_warn("WARNING: Multiple MIPS cores found\n");
 				break;
 			}
 			bus->mipscore.dev = dev;
@@ -413,8 +408,7 @@ int ssb_bus_scan(struct ssb_bus *bus,
 				}
 			}
 			if (bus->pcicore.dev) {
-				ssb_printk(KERN_WARNING PFX
-					   "WARNING: Multiple PCI(E) cores found\n");
+				pr_warn("WARNING: Multiple PCI(E) cores found\n");
 				break;
 			}
 			bus->pcicore.dev = dev;
diff --git a/drivers/ssb/sprom.c b/drivers/ssb/sprom.c
index 4f7cc8d..ca86c68 100644
--- a/drivers/ssb/sprom.c
+++ b/drivers/ssb/sprom.c
@@ -11,6 +11,8 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ssb_private.h"
 
 #include <linux/ctype.h>
@@ -127,13 +129,13 @@ ssize_t ssb_attr_sprom_store(struct ssb_bus *bus,
 		goto out_kfree;
 	err = ssb_devices_freeze(bus, &freeze);
 	if (err) {
-		ssb_printk(KERN_ERR PFX "SPROM write: Could not freeze all devices\n");
+		pr_err("SPROM write: Could not freeze all devices\n");
 		goto out_unlock;
 	}
 	res = sprom_write(bus, sprom);
 	err = ssb_devices_thaw(&freeze);
 	if (err)
-		ssb_printk(KERN_ERR PFX "SPROM write: Could not thaw all devices\n");
+		pr_err("SPROM write: Could not thaw all devices\n");
 out_unlock:
 	mutex_unlock(&bus->sprom_mutex);
 out_kfree:
diff --git a/drivers/ssb/ssb_private.h b/drivers/ssb/ssb_private.h
index 0331139..30f0ca5 100644
--- a/drivers/ssb/ssb_private.h
+++ b/drivers/ssb/ssb_private.h
@@ -7,17 +7,9 @@
 
 #define PFX	"ssb: "
 
-#ifdef CONFIG_SSB_SILENT
-# define ssb_printk(fmt, x...)	do { /* nothing */ } while (0)
-#else
-# define ssb_printk		printk
-#endif /* CONFIG_SSB_SILENT */
-
 /* dprintk: Debugging printk; vanishes for non-debug compilation */
 #ifdef CONFIG_SSB_DEBUG
-# define ssb_dprintk(fmt, x...)	ssb_printk(fmt , ##x)
-#else
-# define ssb_dprintk(fmt, x...)	do { /* nothing */ } while (0)
+# define DEBUG
 #endif
 
 #ifdef CONFIG_SSB_DEBUG
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index 7e99b34..7d65330 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -477,8 +477,8 @@ extern u32 ssb_dma_translation(struct ssb_device *dev);
 static inline void __cold __ssb_dma_not_implemented(struct ssb_device *dev)
 {
 #ifdef CONFIG_SSB_DEBUG
-	printk(KERN_ERR "SSB: BUG! Calling DMA API for "
-	       "unsupported bustype %d\n", dev->bus->bustype);
+	pr_err("BUG! Calling DMA API for unsupported bustype %d\n",
+	       dev->bus->bustype);
 #endif /* DEBUG */
 }
 



