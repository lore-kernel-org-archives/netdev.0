From: Michael Schmitz <schmitzmic@googlemail.com>
Subject: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c, take
 two
Date: Sun, 01 Apr 2012 20:49:52 +1200
Message-ID: <4F7816B0.3090802@gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>	<4F4B2BB6.900@gmail.com>	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com> <CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com> <4F5A0679.1020604@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F5A0679.1020604@windriver.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul, Geert,
> And on re-reading the comments in the other part of the patch, i.e.
> "...emulates the card interrupt via a timer"  --perhaps the driver
> should be just fixed to support generic netpoll, instead of adding
> an arch specific thing that amounts to netpoll.  Then anyone can
> attempt to limp along and use one of these ancient relics w/o IRQ.
>   
Here's take two of my patch to convert the m68k Atari ROM port Ethernet 
driver to use mainstream ne.c, with minimal changes to the core NE2000 
code.

In particular:

Changes to core net code:
* add a platform specific IRQ flag, so ne.c can share a hardware or 
timer interrupt with some other interrupt source.

Changes to arch/m68k code:
* register the 8390 platform device on Atari only if the hardware is present
* retain the old driver (atari_ethernec.c in Geert's tree) under a 
different config option, to be removed soon.

Regarding your suggestion that netpoll be used instead of a dedicated 
timer interrupt: no changes to ne.c or 8390p.c are required to use 
netpoll, it all works out of the box. All that is needed to use the 
driver with netpoll is setting the device interrupt to some source that  
can be registered, and enabling CONFIG_NETPOLL. Interrupt rate and hence 
throughput is lower with netpoll though, which is why I still prefer the 
dedicated timer option.

Comments?

Cheers,

  Michael Schmitz

Signed-off-by: Michael Schmitz <schmitz@debian.org>

--
 arch/m68k/atari/config.c                   |   41 
+++++++++++++++++++++++++---
 drivers/net/Space.c                        |    2 +-
 drivers/net/ethernet/8390/8390.h           |    8 +++++
 drivers/net/ethernet/8390/Kconfig          |   18 +++++++++++-
 drivers/net/ethernet/8390/Makefile         |    3 +-
 drivers/net/ethernet/8390/atari_ethernec.c |    6 ++--
 drivers/net/ethernet/8390/ne.c             |    5 ++-
 7 files changed, 71 insertions(+), 12 deletions(-)

diff --git a/arch/m68k/atari/config.c b/arch/m68k/atari/config.c
index 22375e0..6cff09f 100644
--- a/arch/m68k/atari/config.c
+++ b/arch/m68k/atari/config.c
@@ -664,6 +664,35 @@ static void atari_get_hardware_list(struct seq_file *m)
  */
 
 #define ATARI_ETHERNEC_PHYS_ADDR    0xfffa0000
+#define ATARI_ETHERNEC_BASE        0x300
+#define ATARI_ETHERNEC_IRQ        IRQ_MFP_TIMD
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
+static struct platform_device *atari_ethernec_devices[] __initdata = {
+    &rtl8019_device
+};
+
 
 #define ATARI_ETHERNAT_PHYS_ADDR    0x80000000
 #define ATARI_ETHERNAT_IRQ        196
@@ -690,6 +719,7 @@ static struct platform_device smc91x_device = {
     .resource    = smc91x_resources,
 };
 
+
 #define ATARI_USB_PHYS_ADDR    0x80000010
 #define ATARI_USB_IRQ        195
 
@@ -753,7 +783,8 @@ static struct platform_device 
*atari_ethernat_devices[] __initdata = {
     &isp1160_device
 };
 
-#if IS_ENABLED(CONFIG_ATARI_ETHERNEC) || IS_ENABLED(CONFIG_ATARI_ETHERNAT)
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC) || 
IS_ENABLED(CONFIG_ATARI_ETHERNAT) \
+ || IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
 irqreturn_t atari_timerd_interrupt(int irq, void *dev_id)
 {
     return IRQ_HANDLED;
@@ -762,16 +793,17 @@ irqreturn_t atari_timerd_interrupt(int irq, void 
*dev_id)
 
 int __init atari_platform_init(void)
 {
-    int rv = -ENODEV, ret, need_timer = 0;
+    int rv = -ENODEV, rv1 = -ENODEV, need_timer = 0;
     unsigned char *enatc_virt, *enec_virt;
 
     if (!MACH_IS_ATARI)
         return -ENODEV;
 
-#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC) || 
IS_ENABLED(CONFIG_ATARI_ETHERNEC_OLD)
     enec_virt = (unsigned char *)ioremap((ATARI_ETHERNEC_PHYS_ADDR), 0xf);
     if (hwreg_present(enec_virt)) {
         need_timer = 1;
+        rv1 = platform_add_devices(atari_ethernec_devices, 
ARRAY_SIZE(atari_ethernec_devices));
     }
     iounmap(enec_virt);
 #endif
@@ -788,6 +820,7 @@ int __init atari_platform_init(void)
 #endif
 
     if (need_timer) {
+        int ret;
         const char *name = "Timer D dummy interrupt";
 
         /* timer routine set up in atari_ethernec_probe() */
@@ -802,7 +835,7 @@ int __init atari_platform_init(void)
         }
     }
 
-    if (ret) return ret;
+    if (rv1) return rv1;
     return rv;   
 }
 
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
diff --git a/drivers/net/ethernet/8390/8390.h 
b/drivers/net/ethernet/8390/8390.h
index ef325ff..9416245 100644
--- a/drivers/net/ethernet/8390/8390.h
+++ b/drivers/net/ethernet/8390/8390.h
@@ -32,6 +32,14 @@ extern void ei_poll(struct net_device *dev);
 extern void eip_poll(struct net_device *dev);
 #endif
 
+/* Some platforms may need special IRQ flags */
+#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
+#  define EI_IRQ_FLAGS    IRQF_SHARED
+#endif
+
+#ifndef EI_IRQ_FLAGS
+#  define EI_IRQ_FLAGS    0
+#endif
 
 /* Without I/O delay - non ISA or later chips */
 extern void NS8390_init(struct net_device *dev, int startp);
diff --git a/drivers/net/ethernet/8390/Kconfig 
b/drivers/net/ethernet/8390/Kconfig
index b801056..75875f2 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -226,11 +226,27 @@ config APNE
 config ATARI_ETHERNEC
     tristate "Atari EtherNEC Ethernet support"
     depends on ATARI_ROM_ISA
-    help
+    select CRC32
+    ---help---
+      Say Y to include support for the EtherNEC network adapter for the
+      ROM port. The driver works by polling instead of interrupts, so it
+      is quite slow.
+
+      To compile this driver as a module, choose M here: the module
+      will be called ne.
+
+config ATARI_ETHERNEC_OLD
+    tristate "Atari EtherNEC Ethernet support - obsolete driver"
+    depends on ATARI_ROM_ISA
+    select CRC32
+    ---help---
       Say Y to include support for the EtherNEC network adapter for the
       ROM port. The driver works by polling instead of interrupts, so it
       is quite slow.
 
+      To compile this driver as a module, choose M here: the module
+      will be called atari_ethernec.
+
 config NE3210
     tristate "Novell/Eagle/Microdyne NE3210 EISA support (EXPERIMENTAL)"
     depends on PCI && EISA && EXPERIMENTAL
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
index 086d968..5e8fb97 100644
--- a/drivers/net/ethernet/8390/atari_ethernec.c
+++ b/drivers/net/ethernet/8390/atari_ethernec.c
@@ -185,13 +185,13 @@ bad_clone_list[] __initdata = {
 #  define DCR_VAL 0x4b
 #elif defined(CONFIG_PLAT_OAKS32R)  || \
    defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938) 
|| \
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
@@ -357,7 +357,7 @@ struct net_device * __init atari_ethernec_probe(int 
unit)
     sprintf(dev->name, "eth%d", unit);
     netdev_boot_setup_check(dev);
 
-#if defined(CONFIG_ATARI_ETHERNEC)
+#if defined(CONFIG_ATARI_ETHERNEC_OLD)
     dev->base_addr = ETHERNEC_RTL_8019_BASE;
     dev->irq = ETHERNEC_RTL_8019_IRQ;
 #endif
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index f92ea2a..39678fc 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -165,7 +165,8 @@ bad_clone_list[] __initdata = {
 #if defined(CONFIG_PLAT_MAPPI)
 #  define DCR_VAL 0x4b
 #elif defined(CONFIG_PLAT_OAKS32R)  || \
-   defined(CONFIG_MACH_TX49XX)
+   defined(CONFIG_MACH_TX49XX) || \
+   IS_ENABLED(CONFIG_ATARI_ETHERNEC)
 #  define DCR_VAL 0x48        /* 8-bit mode */
 #else
 #  define DCR_VAL 0x49
@@ -492,7 +493,7 @@ static int __init ne_probe1(struct net_device *dev, 
unsigned long ioaddr)
 
     /* Snarf the interrupt now.  There's no point in waiting since we 
cannot
        share and the board will usually be enabled. */
-    ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
+    ret = request_irq(dev->irq, eip_interrupt, EI_IRQ_FLAGS, name, dev);
     if (ret) {
         printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
         goto err_out;
