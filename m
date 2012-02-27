From: Michael Schmitz <schmitzmic@googlemail.com>
Subject: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c
Date: Mon, 27 Feb 2012 20:07:34 +1300
Message-ID: <4F4B2BB6.900@gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

after much prodding from Geert, and a bit of bouncing ideas back and 
forth, I've rewritten the Atari EtherNEC ethercard driver to use work 
with only minimal patches to ne.c (instead of duplicating ne.c as 
atari_ethernec.c).

The EtherNEC adapter is a solution to use a RTL8019 ISA card on the 
cartridge (ROM) port of m68k Atari computers. The cartridge port does 
not support generating interrupts. To service card interrupts, the 8390 
interrupt handler is called periodically from a dedicated hardware timer 
which needs to be shared with other users (the SMC91C111 EtherNAT 
driver, and a dummy handler dedicated to preventing interference from 
the interrupt watchdog if the card is idle).

netdev subscribers please focus on the patch to ne.c at the top. Changes 
to ne.c are twofold: to select 8-bit mode for the driver, and to ensure 
the interrupt can be shared with aforementioned other users if the 
driver is used on Atari.

This patch applies on top of Geert's current linux-m68k. It won't 
cleanly apply on top of, or work if built from Linus' tree, as it relies 
on further patches relating to bus access quirks that are pending in 
Geert's tree.

The old EtherNEC driver is retained as-is, to be removed from Geert's 
tree after this code has been accepted. It can still be built by 
selecting the CONFIG_ATARI_ETHERNEC_OLD option.

Comments to linux-m68k or me, please - I'm not subscribed to netdev.

Cheers,

   Michael


diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index f92ea2a..28b8781 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -55,6 +55,9 @@ static const char version2[] =

  #include <asm/system.h>
  #include <asm/io.h>
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
+#include <asm/atariints.h>
+#endif

  #include "8390.h"

@@ -165,7 +168,8 @@ bad_clone_list[] __initdata = {
  #if defined(CONFIG_PLAT_MAPPI)
  #  define DCR_VAL 0x4b
  #elif defined(CONFIG_PLAT_OAKS32R)  || \
-   defined(CONFIG_MACH_TX49XX)
+   defined(CONFIG_MACH_TX49XX) || \
+   IS_ENABLED(CONFIG_ATARI_ETHERNEC)
  #  define DCR_VAL 0x48        /* 8-bit mode */
  #else
  #  define DCR_VAL 0x49
@@ -492,7 +496,16 @@ static int __init ne_probe1(struct net_device *dev, 
unsigned long ioaddr)

      /* Snarf the interrupt now.  There's no point in waiting since we 
cannot
         share and the board will usually be enabled. */
-    ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
+    if (MACH_IS_ATARI) {
+        /* Atari EtherNEC emulates the card interrupt via a timer -
+           this needs to be shared with the smc91C111 driver and with
+           a dummy handler to catch unhandled interrupts ! */
+        ret = request_irq(dev->irq, eip_interrupt, IRQF_SHARED, name, dev);
+    } else
+#endif
+        ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
+
      if (ret) {
          printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
          goto err_out;
diff --git a/arch/m68k/atari/config.c b/arch/m68k/atari/config.c
index af78731..3ff7231 100644
--- a/arch/m68k/atari/config.c
+++ b/arch/m68k/atari/config.c
@@ -687,13 +687,67 @@ static struct platform_device smc91x_device = {
      .resource    = smc91x_resources,
  };

+
+#define ATARI_ETHERNEC_BASE 0x300
+#define ATARI_ETHERNEC_IRQ IRQ_MFP_TIMD
+
+
+static struct resource rtl8019_resources[] = {
+    [0] = {
+        .name    = "rtl9019-regs",
+        .start    = ATARI_ETHERNEC_BASE,
+        .end    = ATARI_ETHERNEC_BASE + 0x20 - 1,
+        .flags    = IORESOURCE_IO,
+    },
+    [1] = {
+        .name    = "rtl9019-irq",
+        .start    = ATARI_ETHERNEC_IRQ,
+        .end    = ATARI_ETHERNEC_IRQ,
+        .flags    = IORESOURCE_IRQ,
+    },
+};
+
+static struct platform_device rtl8019_device = {
+    .name        = "ne",
+    .id        = -1,
+    .num_resources    = ARRAY_SIZE(rtl8019_resources),
+    .resource    = rtl8019_resources,
+};
+
+
  static struct platform_device *atari_platform_devices[] __initdata = {
- &smc91x_device
+ &smc91x_device,
+ &rtl8019_device
  };

+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC) || IS_ENABLED(CONFIG_ATARI_ETHERNAT)
+irqreturn_t atari_timerd_interrupt(int irq, void *dev_id)
+{
+    return IRQ_HANDLED;
+}
+#endif
+
  int __init atari_platform_init(void)
  {
-    return platform_add_devices(atari_platform_devices, 
ARRAY_SIZE(atari_platform_devices));
+
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC) || IS_ENABLED(CONFIG_ATARI_ETHERNAT)
+    if (hwreg_present(0xfffa0000) || hwreg_present(0x80000000)) {
+        int ret;
+        const char *name = "Timer D dummy interrupt";
+        /* timer routine set up in atari_ethernec_probe() */
+        /* set Timer D data Register */
+        st_mfp.tim_dt_d = 123;    /* 200 Hz */
+        /* start timer D, div = 1:100 */
+        st_mfp.tim_ct_cd = (st_mfp.tim_ct_cd & 0xf0) | 0x6;
+        /* Must make this shared in case other timer ints are needed */
+        ret = request_irq(IRQ_MFP_TIMD, atari_timerd_interrupt, 
IRQF_SHARED, name, atari_timerd_interrupt);
+        if (ret) {
+            printk(KERN_ERR "atari_platform_init: failed to register 
dummy timer interrupt for EtherNEC/EtherNAT!\n");
+        }
+        return platform_add_devices(atari_platform_devices, 
ARRAY_SIZE(atari_platform_devices));
+    }
+#endif
+    return 0;
  }

  arch_initcall(atari_platform_init);
diff --git a/arch/m68k/configs/atari_defconfig 
b/arch/m68k/configs/atari_defconfig
index 6e86de1..5f8e91f 100644
--- a/arch/m68k/configs/atari_defconfig
+++ b/arch/m68k/configs/atari_defconfig
@@ -201,7 +201,7 @@ CONFIG_NET_ETHERNET=y
  CONFIG_MII=y
  CONFIG_ATARILANCE=y
  CONFIG_ATARI_ETHERNAT=m
-CONFIG_ATARI_ETHERNEC=y
+CONFIG_ATARI_ETHERNEC=m
  # CONFIG_NETDEV_1000 is not set
  # CONFIG_NETDEV_10000 is not set
  CONFIG_PPP=m
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index d5e8882..548b73b 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -243,7 +243,7 @@ static struct devprobe2 m68k_probes[] __initdata = {
  #ifdef CONFIG_ATARILANCE    /* Lance-based Atari ethernet boards */
      {atarilance_probe, 0},
  #endif
-#ifdef CONFIG_ATARI_ETHERNEC    /* NE2000 based ROM port ethernet cards */
+#ifdef CONFIG_ATARI_ETHERNEC_OLD    /* NE2000 based ROM port ethernet 
cards */
      {atari_ethernec_probe, 0},
  #endif
  #ifdef CONFIG_SUN3LANCE         /* sun3 onboard Lance chip */
diff --git a/drivers/net/ethernet/8390/Kconfig 
b/drivers/net/ethernet/8390/Kconfig
index b801056..ca5adab 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -223,9 +223,18 @@ config APNE
        To compile this driver as a module, choose M here: the module
        will be called apne.

+config ATARI_ETHERNEC_OLD
+    tristate "Atari EtherNEC Ethernet support - old driver"
+    depends on ATARI_ROM_ISA
+    help
+      Say Y to include support for the EtherNEC network adapter for the
+      ROM port. The driver works by polling instead of interrupts, so it
+      is quite slow.
+
  config ATARI_ETHERNEC
-    tristate "Atari EtherNEC Ethernet support"
+    tristate "Atari EtherNEC Ethernet support - mainstream NE2000 driver"
      depends on ATARI_ROM_ISA
+    select CRC32
      help
        Say Y to include support for the EtherNEC network adapter for the
        ROM port. The driver works by polling instead of interrupts, so it
diff --git a/drivers/net/ethernet/8390/Makefile 
b/drivers/net/ethernet/8390/Makefile
index d896466..e620355 100644
--- a/drivers/net/ethernet/8390/Makefile
+++ b/drivers/net/ethernet/8390/Makefile
@@ -6,7 +6,8 @@ obj-$(CONFIG_MAC8390) += mac8390.o
  obj-$(CONFIG_AC3200) += ac3200.o 8390.o
  obj-$(CONFIG_APNE) += apne.o 8390.o
  obj-$(CONFIG_ARM_ETHERH) += etherh.o
-obj-$(CONFIG_ATARI_ETHERNEC) += atari_ethernec.o 8390.o
+obj-$(CONFIG_ATARI_ETHERNEC_OLD) += atari_ethernec.o 8390.o
+obj-$(CONFIG_ATARI_ETHERNEC) += ne.o 8390p.o
  obj-$(CONFIG_AX88796) += ax88796.o
  obj-$(CONFIG_E2100) += e2100.o 8390.o
  obj-$(CONFIG_EL2) += 3c503.o 8390p.o
diff --git a/drivers/net/ethernet/8390/atari_ethernec.c 
b/drivers/net/ethernet/8390/atari_ethernec.c
index 086d968..e051094 100644
--- a/drivers/net/ethernet/8390/atari_ethernec.c
+++ b/drivers/net/ethernet/8390/atari_ethernec.c
@@ -93,6 +93,7 @@ static const char version2[] =
  #include <linux/init.h>
  #include <linux/interrupt.h>
  #include <linux/delay.h>
+#include <linux/platform_device.h>
  #include <linux/netdevice.h>
  #include <linux/etherdevice.h>
  #include <linux/jiffies.h>
@@ -185,13 +186,13 @@ bad_clone_list[] __initdata = {
  #  define DCR_VAL 0x4b
  #elif defined(CONFIG_PLAT_OAKS32R)  || \
     defined(CONFIG_TOSHIBA_RBTX4927) || 
defined(CONFIG_TOSHIBA_RBTX4938) || \
-   defined(CONFIG_ATARI_ETHERNEC) || defined(CONFIG_ATARI_ETHERNEC_MODULE)
+   IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
  #  define DCR_VAL 0x48        /* 8-bit mode */
  #else
  #  define DCR_VAL 0x49
  #endif

-#if defined(CONFIG_ATARI_ETHERNEC) || defined(CONFIG_ATARI_ETHERNEC_MODULE)
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
  #  define ETHERNEC_RTL_8019_BASE 0x300
  #  define ETHERNEC_RTL_8019_IRQ IRQ_MFP_TIMD
  #endif
@@ -229,7 +230,7 @@ irqreturn_t atari_ei_interrupt(int irq, void *dev_id)
      struct net_device *dev = dev_id;
      if (netif_running(dev))
          return ei_interrupt(dev->irq, dev);
-    return IRQ_NONE;
+    return IRQ_HANDLED;
  }

  static void atari_ethernec_int(struct work_struct *work)
@@ -357,7 +358,7 @@ struct net_device * __init atari_ethernec_probe(int 
unit)
      sprintf(dev->name, "eth%d", unit);
      netdev_boot_setup_check(dev);

-#if defined(CONFIG_ATARI_ETHERNEC)
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
      dev->base_addr = ETHERNEC_RTL_8019_BASE;
      dev->irq = ETHERNEC_RTL_8019_IRQ;
  #endif
@@ -456,7 +457,7 @@ static int __init ne_probe1(struct net_device *dev, 
int ioaddr)
      }

      if (ei_debug && version_printed++ == 0)
-        printk(KERN_INFO "%s" KERN_INFO "%s", version1, version2);
+        printk(KERN_INFO "%s%s", version1, version2);

      /* A user with a poor card that fails to ack the reset, or that
         does not have a valid 0x57,0x57 signature can still use this
@@ -941,9 +942,10 @@ module_param(use_poll, int, 0);
  MODULE_PARM_DESC(io, "I/O base address(es),required");
  MODULE_PARM_DESC(irq, "IRQ number(s)");
  MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
-MODULE_PARM_DESC(use_poll, "Use timer interrupt to poll driver");
+MODULE_PARM_DESC(use_poll, "Use system timer to poll driver");
  MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
  MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:8390");

  /* This is set up so that no ISA autoprobe takes place. We can't guarantee
  that the ne2k probe is the last 8390 based probe to take place (as it
