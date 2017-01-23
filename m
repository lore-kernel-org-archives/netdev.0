From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] phy: marvell: remove conflicting initializer
Date: Mon, 23 Jan 2017 17:09:39 +0100
Message-ID: <7242508.n9OCrlbXLu@wuerfel>
References: <20170123121905.3245589-1-arnd@arndb.de> <20170123151941.GG10895@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>,
        Clemens Gruber <clemens.gruber@pqgruber.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170123151941.GG10895@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, January 23, 2017 4:19:41 PM CET Andrew Lunn wrote:
> On Mon, Jan 23, 2017 at 01:18:41PM +0100, Arnd Bergmann wrote:
> > One line was apparently pasted incorrectly during a new feature patch:
> > 
> > drivers/net/phy/marvell.c:2090:15: error: initialized field overwritten [-Werror=override-init]
> >    .features = PHY_GBIT_FEATURES,
> > 
> > I'm removing the extraneous line here to avoid the W=1 warning and restore
> > the previous flags value, and I'm slightly reordering the lines for consistency
> > to make it less likely to happen again in the future. The ordering in the
> > array is still not the same as in the structure definition, instead I picked
> > the order that is most common in this file and that seems to make more sense
> > here.
> > 
> > Fixes: 0b04680fdae4 ("phy: marvell: Add support for temperature sensor")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Hi Arnd
> 
> Thanks for this. I found one bug in my code while testing due to
> duplicate probe initialisation. I was surprised at the time the
> compiler did not warn me. I didn't think to try W=1. Is there any
> legitimate need to allow multiple initialisation of a field? Can this
> warning be made always on instead of only W=1?
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> 

Great question! I have sent out patches for a couple of actual bugs that
came from this warning in the past few months.

I still have a couple of patches that I have not sent out so far,
I think they are all false-positives, and I have not found a good
workaround for most of them other than disabling the warning locally.

Once we get the patches below (or some other workaround) into the
kernel, we should definitely enable the warning by default.

	Arnd

 arch/arm64/kernel/sys.c                       |    1 +
 arch/arm64/kernel/sys32.c                     |    1 +
 arch/arm64/kernel/traps.c                     |    1 +
 arch/x86/kernel/cpu/common.c                  |    1 +
 drivers/block/drbd/drbd_main.c                |    7 +++----
 drivers/gpu/drm/gma500/Makefile               |    1 +
 drivers/gpu/drm/i915/Makefile                 |    1 +
 drivers/gpu/drm/omapdrm/omap_fbdev.c          |    3 +++
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c |    1 -
 drivers/net/ethernet/renesas/sh_eth.c         |    1 +
 fs/proc/task_mmu.c                            |    2 ++
 include/linux/libata.h                        |    1 +
 include/linux/perf/arm_pmu.h                  |    1 +
 kernel/bpf/core.c                             |    2 ++
 net/wimax/stack.c                             |    6 +++---
 sound/usb/quirks-table.h                      |    3 ++-
 17 files changed, 30 insertions(+), 16 deletions(-)

>From b85020cd2c0da34c940b6a7d5d04a39e01fa3bf9 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 24 Jun 2016 15:04:14 +0200
Subject: [PATCH] arm64: turn off -Woverride-init false positives

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/arch/arm64/kernel/sys.c b/arch/arm64/kernel/sys.c
index 26fe8ea93ea2..ce84c7b821f9 100644
--- a/arch/arm64/kernel/sys.c
+++ b/arch/arm64/kernel/sys.c
@@ -55,6 +55,7 @@ asmlinkage long sys_rt_sigreturn_wrapper(void);
 #undef __SYSCALL
 #define __SYSCALL(nr, sym)	[nr] = sym,
 
+#pragma GCC diagnostic ignored "-Woverride-init"
 /*
  * The sys_call_table array must be 4K aligned to be accessible from
  * kernel/entry.S.
diff --git a/arch/arm64/kernel/sys32.c b/arch/arm64/kernel/sys32.c
index a40b1343b819..78c768c9fe23 100644
--- a/arch/arm64/kernel/sys32.c
+++ b/arch/arm64/kernel/sys32.c
@@ -42,6 +42,7 @@ asmlinkage long compat_sys_mmap2_wrapper(void);
 #undef __SYSCALL
 #define __SYSCALL(nr, sym)	[nr] = sym,
 
+#pragma GCC diagnostic ignored "-Woverride-init"
 /*
  * The sys_call_table array must be 4K aligned to be accessible from
  * kernel/entry.S.
diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
index ff290d569f41..d7c4e1088d49 100644
--- a/arch/arm64/kernel/traps.c
+++ b/arch/arm64/kernel/traps.c
@@ -558,6 +558,7 @@ asmlinkage long do_ni_syscall(struct pt_regs *regs)
 	return sys_ni_syscall();
 }
 
+#pragma GCC diagnostic ignored "-Woverride-init"
 static const char *esr_class_str[] = {
 	[0 ... ESR_ELx_EC_MAX]		= "UNRECOGNIZED EC",
 	[ESR_ELx_EC_UNKNOWN]		= "Unknown/Uncategorized",

>From 975b03637d5362bbf99ad46d59dbf94b495cb78f Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 3 Jan 2017 15:35:07 +0100
Subject: [PATCH] drm: fix override-init warnings

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/gpu/drm/gma500/Makefile b/drivers/gpu/drm/gma500/Makefile
index 190e55f2f891..3ff5f58db4f4 100644
--- a/drivers/gpu/drm/gma500/Makefile
+++ b/drivers/gpu/drm/gma500/Makefile
@@ -2,6 +2,7 @@
 #	KMS driver for the GMA500
 #
 ccflags-y += -I$(srctree)/include/drm
+CFLAGS_framebuffer.o += $(call cc-disable-warning, override-init)
 
 gma500_gfx-y += \
 	  accel_2d.o \
diff --git a/drivers/gpu/drm/i915/Makefile b/drivers/gpu/drm/i915/Makefile
index 74ca2e8b2494..fb1342d59a7c 100644
--- a/drivers/gpu/drm/i915/Makefile
+++ b/drivers/gpu/drm/i915/Makefile
@@ -5,6 +5,7 @@
 subdir-ccflags-$(CONFIG_DRM_I915_WERROR) := -Werror
 subdir-ccflags-y += \
 	$(call as-instr,movntdqa (%eax)$(comma)%xmm0,-DCONFIG_AS_MOVNTDQA)
+subdir-ccflags-y += $(call cc-disable-warning, override-init)
 
 # Please keep these build lists sorted!
 

>From af178eec23da3e549b7ac5360c213955059d9f16 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 15 Nov 2016 14:10:37 +0100
Subject: [PATCH] [HACK] drm: omapdrm: field override

../drivers/gpu/drm/omapdrm/omap_fbdev.c:96:20: error: initialized field overwritten [-Werror=override-init]
  .fb_pan_display = omap_fbdev_pan_display,
                    ^~~~~~~~~~~~~~~~~~~~~~
../drivers/gpu/drm/omapdrm/omap_fbdev.c:96:20: note: (near initialization for 'omap_fb_ops.fb_pan_display')

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/gpu/drm/omapdrm/omap_fbdev.c b/drivers/gpu/drm/omapdrm/omap_fbdev.c
index 2a839956dae6..d953186142d1 100644
--- a/drivers/gpu/drm/omapdrm/omap_fbdev.c
+++ b/drivers/gpu/drm/omapdrm/omap_fbdev.c
@@ -80,6 +80,8 @@ static int omap_fbdev_pan_display(struct fb_var_screeninfo *var,
 	return drm_fb_helper_pan_display(var, fbi);
 }
 
+#pragma GCC diagnostic push
+#pragma GCC diagnostic ignored "-Woverride-init"
 static struct fb_ops omap_fb_ops = {
 	.owner = THIS_MODULE,
 	DRM_FB_HELPER_DEFAULT_OPS,
@@ -95,6 +97,7 @@ static struct fb_ops omap_fb_ops = {
 
 	.fb_pan_display = omap_fbdev_pan_display,
 };
+#pragma GCC diagnostic pop
 
 static int omap_fbdev_create(struct drm_fb_helper *helper,
 		struct drm_fb_helper_surface_size *sizes)

>From a9c01cba0336e2907d78953226a5d985edcf1ee1 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 13:44:51 +0200
Subject: [PATCH] procfs: disable -Woverride-init warning

This warning finds some actual bugs, but the usage in procfs is intended,
so we get a false positive output many lines like:

fs/proc/task_mmu.c: In function 'show_smap_vma_flags':
fs/proc/task_mmu.c:629:2403: error: initialized field overwritten [-Werror=override-init]
fs/proc/task_mmu.c:629:2403: note: (near initialization for 'mnemonics[0]')
fs/proc/task_mmu.c:630:2403: error: initialized field overwritten [-Werror=override-init]
fs/proc/task_mmu.c:630:2403: note: (near initialization for 'mnemonics[1]')
fs/proc/task_mmu.c:631:2403: error: initialized field overwritten [-Werror=override-init]
fs/proc/task_mmu.c:631:2403: note: (near initialization for 'mnemonics[2]')

This uses a #pragma to turn off the warning, as a preparation for
eventually enabling the gcc flag by default for the kernel.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ee3efb229ef6..661dca5a0042 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -616,6 +616,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return 0;
 }
 
+#pragma GCC diagnostic ignored "-Woverride-init"
 static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 {
 	/*
@@ -682,6 +683,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 	}
 	seq_putc(m, '\n');
 }
+#pragma GCC diagnostic warning "-Woverride-init"
 
 #ifdef CONFIG_HUGETLB_PAGE
 static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,

>From 85cbf32994e826a9b3f4b0e6c481d85d77c7ad19 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 13:08:55 +0200
Subject: [PATCH] sh_eth: disable -Woverride-init warning

-Woverride-init is part of a 'make W=1' build and it might be nice
to enable it in normal builds as it catches real bugs, but it
causes hundreds of identical false positive warnings in the sh_eth
driver:

ethernet/renesas/sh_eth.c:63:11: error: initialized field overwritten [-Werror=override-init]
ethernet/renesas/sh_eth.c:63:11: note: (near initialization for 'sh_eth_offset_gigabit[0]')
ethernet/renesas/sh_eth.c:64:11: error: initialized field overwritten [-Werror=override-init]
ethernet/renesas/sh_eth.c:64:11: note: (near initialization for 'sh_eth_offset_gigabit[1]')
ethernet/renesas/sh_eth.c:65:12: error: initialized field overwritten [-Werror=override-init]
ethernet/renesas/sh_eth.c:65:12: note: (near initialization for 'sh_eth_offset_gigabit[2]')
ethernet/renesas/sh_eth.c:66:12: error: initialized field overwritten [-Werror=override-init]
ethernet/renesas/sh_eth.c:66:12: note: (near initialization for 'sh_eth_offset_gigabit[3]')
ethernet/renesas/sh_eth.c:67:11: error: initialized field overwritten [-Werror=override-init]
ethernet/renesas/sh_eth.c:67:11: note: (near initialization for 'sh_eth_offset_gigabit[4]')

This turns off the particular warning for this file, overriding the
C flags.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 45a7a6ba7644..1980cbcef066 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -57,6 +57,7 @@
 #define SH_ETH_OFFSET_DEFAULTS			\
 	[0 ... SH_ETH_MAX_REGISTER_OFFSET - 1] = SH_ETH_OFFSET_INVALID
 
+#pragma GCC diagnostic ignored "-Woverride-init"
 static const u16 sh_eth_offset_gigabit[SH_ETH_MAX_REGISTER_OFFSET] = {
 	SH_ETH_OFFSET_DEFAULTS,
 

>From 14e1d7313bb030decc1a7ac0618c4c95474fc116 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 10:46:40 +0200
Subject: [PATCH] perf: arm-pmu: shut up -Woverride-init warning

gcc -Woverride-init provides useful warnings about bugs in some drivers,
but it warns about an intentional duplicate inialization in the ARM
pmu header:

arch/arm/kernel/perf_event_v7.c:159:31: error: initialized field overwritten [-Werror=override-init]
arch/arm/kernel/perf_event_v7.c:159:31: note: (near initialization for 'armv7_a8_perf_map[0]')
arch/arm/kernel/perf_event_v7.c:160:33: error: initialized field overwritten [-Werror=override-init]
arch/arm/kernel/perf_event_v7.c:160:33: note: (near initialization for 'armv7_a8_perf_map[1]')
arch/arm/kernel/perf_event_v7.c:161:37: error: initialized field overwritten [-Werror=override-init]
arch/arm/kernel/perf_event_v7.c:161:37: note: (near initialization for 'armv7_a8_perf_map[2]')
arch/arm/kernel/perf_event_v7.c:162:33: error: initialized field overwritten [-Werror=override-init]
arch/arm/kernel/perf_event_v7.c:162:33: note: (near initialization for 'armv7_a8_perf_map[3]')
arch/arm/kernel/perf_event_v7.c:163:40: error: initialized field overwritten [-Werror=override-init]
arch/arm/kernel/perf_event_v7.c:163:40: note: (near initialization for 'armv7_a8_perf_map[4]')
...

This uses a #pragma to shut up that warning, as a preparation for enabling
the warning by default in the future.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/include/linux/perf/arm_pmu.h b/include/linux/perf/arm_pmu.h
index 8462da266089..f61462cd362a 100644
--- a/include/linux/perf/arm_pmu.h
+++ b/include/linux/perf/arm_pmu.h
@@ -41,6 +41,7 @@ struct arm_pmu_platdata {
 #define C(_x)				PERF_COUNT_HW_CACHE_##_x
 #define CACHE_OP_UNSUPPORTED		0xFFFF
 
+#pragma GCC diagnostic ignored "-Woverride-init"
 #define PERF_MAP_ALL_UNSUPPORTED					\
 	[0 ... PERF_COUNT_HW_MAX - 1] = HW_OP_UNSUPPORTED
 

>From e2f45688890614c67fef699a8612283ad4c44b06 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 10:46:40 +0200
Subject: [PATCH] bpf: shut up -Woverride-init warning

gcc -Woverride-init provides useful warnings about bugs in some drivers,
but it warns about an intentional duplicate inialization in the bpf
code:

kernel/bpf/core.c: In function '__bpf_prog_run':
kernel/bpf/core.c:476:26: error: initialized field overwritten [-Werror=override-init]
kernel/bpf/core.c:476:26: note: (near initialization for 'jumptable[12]')
kernel/bpf/core.c:477:26: error: initialized field overwritten [-Werror=override-init]
kernel/bpf/core.c:477:26: note: (near initialization for 'jumptable[4]')
kernel/bpf/core.c:478:26: error: initialized field overwritten [-Werror=override-init]
kernel/bpf/core.c:478:26: note: (near initialization for 'jumptable[28]')
kernel/bpf/core.c:479:26: error: initialized field overwritten [-Werror=override-init]
kernel/bpf/core.c:479:26: note: (near initialization for 'jumptable[20]')
kernel/bpf/core.c:480:26: error: initialized field overwritten [-Werror=override-init]
kernel/bpf/core.c:480:26: note: (near initialization for 'jumptable[92]')
kernel/bpf/core.c:481:26: error: initialized field overwritten [-Werror=override-init]

This uses a #pragma to shut up that warning, as a preparation for enabling
the warning by default in the future.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 503d4211988a..8944778d9c13 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -547,6 +547,7 @@ EXPORT_SYMBOL_GPL(__bpf_call_base);
  *
  * Decode and execute eBPF instructions.
  */
+#pragma GCC diagnostic ignored "-Woverride-init"
 static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 {
 	u64 stack[MAX_BPF_STACK / sizeof(u64)];
@@ -1003,6 +1004,7 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 		WARN_RATELIMIT(1, "unknown opcode %02x\n", insn->code);
 		return 0;
 }
+#pragma GCC diagnostic warning "-Woverride-init"
 STACK_FRAME_NON_STANDARD(__bpf_prog_run); /* jump table */
 
 bool bpf_prog_array_compatible(struct bpf_array *array,

>From 092549ed4782679e220357a3990bb5087e7d277f Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 10:41:06 +0200
Subject: [PATCH] libata: shut up -Woverride-init warning

In general, the -Woverride-init is helpful to catch bugs with drivers that
unintentially initialize the same field in a structure more than once.
In case of libata, it conflicts with the intended use of the ATA_BASE_SHT()
macro, causing warnings about code that works as designed:

drivers/ata/ahci.c:107:555: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci.c:107:685: error: initialized field overwritten [-Werror=override-init]
drivers/ata/acard-ahci.c:86:567: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_platform.c:37:555: error: initialized field overwritten [-Werror=override-init]
drivers/ata/sata_sil24.c:388:15: error: initialized field overwritten [-Werror=override-init]
drivers/ata/sata_highbank.c:456:573: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_brcmstb.c:282:565: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_ceva.c:162:565: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_imx.c:526:563: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_mvebu.c:98:567: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_sunxi.c:175:567: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_st.c:145:561: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_tegra.c:295:567: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_xgene.c:731:567: error: initialized field overwritten [-Werror=override-init]
drivers/ata/ahci_qoriq.c:148:567: error: initialized field overwritten [-Werror=override-init]
drivers/ata/sata_mv.c:683:15: error: initialized field overwritten [-Werror=override-init]
drivers/ata/sata_nv.c:395:15: error: initialized field overwritten [-Werror=override-init]
drivers/ata/sata_nv.c:398:21: error: initialized field overwritten [-Werror=override-init]
drivers/ata/sata_nv.c:403:15: error: initialized field overwritten [-Werror=override-init]
drivers/ata/sata_nv.c:406:21: error: initialized field overwritten [-Werror=override-init]
drivers/ata/pata_atiixp.c:254:18: error: initialized field overwritten [-Werror=override-init]
drivers/ata/pata_cs5520.c:107:18: error: initialized field overwritten [-Werror=override-init]
drivers/ata/pata_sc1200.c:210:18: error: initialized field overwritten [-Werror=override-init]
drivers/ata/pata_serverworks.c:256:18: error: initialized field overwritten [-Werror=override-init]

This adds a #pragma GCC diagnostic ignored "-Woverride-init" next to the
definition to let gcc know that it shouldn't warn about duplicate initializers
in files that include this header.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/include/linux/libata.h b/include/linux/libata.h
index 0e8a8000b45f..038b1ee7485f 100644
--- a/include/linux/libata.h
+++ b/include/linux/libata.h
@@ -1342,6 +1342,7 @@ extern struct device_attribute *ata_common_sdev_attrs[];
  * edge driver's module reference, otherwise the driver can be unloaded
  * even if the scsi_device is being accessed.
  */
+#pragma GCC diagnostic ignored "-Woverride-init"
 #define ATA_BASE_SHT(drv_name)					\
 	.module			= THIS_MODULE,			\
 	.name			= drv_name,			\

>From bafaf130a03ac21377fe7c142ad7ce7417ebcfe3 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 9 Jun 2016 23:20:58 +0200
Subject: [PATCH] qede: remove duplicate initializer

../drivers/net/ethernet/qlogic/qede/qede_dcbnl.c:327:13: error: initialized field overwritten [-Werror=override-init]
  .getdcbx = qede_dcbnl_getdcbx,
             ^~~~~~~~~~~~~~~~~~
../drivers/net/ethernet/qlogic/qede/qede_dcbnl.c:327:13: note: (near initialization for 'qede_dcbnl_ops.getdcbx')

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
index 03e8c0212433..318f0cbd58ed 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
@@ -308,7 +308,6 @@ static const struct dcbnl_rtnl_ops qede_dcbnl_ops = {
 	.ieee_setets = qede_dcbnl_ieee_setets,
 	.ieee_getapp = qede_dcbnl_ieee_getapp,
 	.ieee_setapp = qede_dcbnl_ieee_setapp,
-	.getdcbx = qede_dcbnl_getdcbx,
 	.ieee_peer_getpfc = qede_dcbnl_ieee_peer_getpfc,
 	.ieee_peer_getets = qede_dcbnl_ieee_peer_getets,
 	.getstate = qede_dcbnl_getstate,

>From 657078acc9b9e8abc17aa7eb2d93877194e085ef Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 10:31:59 +0200
Subject: [PATCH] [RFC] wimax: remove duplicate entries in wimax_gnl_policy

gcc -Wextra warns about duplicate initializations here:

net/wimax/stack.c:408:29: error: initialized field overwritten [-Werror=override-init]
net/wimax/stack.c:408:29: note: (near initialization for 'wimax_gnl_policy[1]')
net/wimax/stack.c:412:28: error: initialized field overwritten [-Werror=override-init]
net/wimax/stack.c:412:28: note: (near initialization for 'wimax_gnl_policy[1]')
net/wimax/stack.c:413:26: error: initialized field overwritten [-Werror=override-init]
net/wimax/stack.c:413:26: note: (near initialization for 'wimax_gnl_policy[1]')

This was introduced by b61a5eea5904 ("wimax: use
genl_register_family_with_ops()"), which consolidated four existing
genl_ops tables into one as a simplification.

I do not understand the reasoning behind that earlier patch, as it seems
to apply the superset of the four policy to all commands. If it was
indeed correct, we can either remove or comment out the duplicate entries
as I do here.

It's also possible that we want a partial revert of the patch that
introduced this, or a broader rework.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 5db731512014..1c118def3713 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -404,12 +404,12 @@ void wimax_dev_init(struct wimax_dev *wimax_dev)
 EXPORT_SYMBOL_GPL(wimax_dev_init);
 
 static const struct nla_policy wimax_gnl_policy[WIMAX_GNL_ATTR_MAX + 1] = {
-	[WIMAX_GNL_RESET_IFIDX] = { .type = NLA_U32, },
-	[WIMAX_GNL_RFKILL_IFIDX] = { .type = NLA_U32, },
+/*	[WIMAX_GNL_RESET_IFIDX] = { .type = NLA_U32, },	 */
+/*	[WIMAX_GNL_RFKILL_IFIDX] = { .type = NLA_U32, }, */
 	[WIMAX_GNL_RFKILL_STATE] = {
 		.type = NLA_U32		/* enum wimax_rf_state */
 	},
-	[WIMAX_GNL_STGET_IFIDX] = { .type = NLA_U32, },
+/*	[WIMAX_GNL_STGET_IFIDX] = { .type = NLA_U32, },  */
 	[WIMAX_GNL_MSG_IFIDX] = { .type = NLA_U32, },
 	[WIMAX_GNL_MSG_DATA] = {
 		.type = NLA_UNSPEC,	/* libnl doesn't grok BINARY yet */

>From ad1e6c0987c3e03fe9177d6f1a5aaeb9732f80f5 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 10:23:51 +0200
Subject: [PATCH] drbd: sanitize cmdnames table

gcc -Wextra warns about a duplicate entry in cmdnames[]:

drivers/block/drbd/drbd_main.c: In function 'cmdname':
drivers/block/drbd/drbd_main.c:3680:21: error: initialized field overwritten [-Werror=override-init]
drivers/block/drbd/drbd_main.c:3680:21: note: (near initialization for 'cmdnames[44]')

Apparently, there are two entries for P_RETRY_WRITE, so I'm removing the
one that ended up unused. I also checked the table to ensure that all
other entries are there and sorted them by numeric value.

I see that there is no entry for P_TRIM, so I've added that
but left it commented out. Please uncomment if that entry should
be there.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index f6fbdac2391d..5aec73fbf2ba 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -3719,7 +3719,6 @@ const char *cmdname(enum drbd_packet cmd)
 	static const char *cmdnames[] = {
 		[P_DATA]	        = "Data",
 		[P_WSAME]	        = "WriteSame",
-		[P_TRIM]	        = "Trim",
 		[P_DATA_REPLY]	        = "DataReply",
 		[P_RS_DATA_REPLY]	= "RSDataReply",
 		[P_BARRIER]	        = "Barrier",
@@ -3730,7 +3729,6 @@ const char *cmdname(enum drbd_packet cmd)
 		[P_DATA_REQUEST]	= "DataRequest",
 		[P_RS_DATA_REQUEST]     = "RSDataRequest",
 		[P_SYNC_PARAM]	        = "SyncParam",
-		[P_SYNC_PARAM89]	= "SyncParam89",
 		[P_PROTOCOL]            = "ReportProtocol",
 		[P_UUIDS]	        = "ReportUUIDs",
 		[P_SIZES]	        = "ReportSizes",
@@ -3738,6 +3736,7 @@ const char *cmdname(enum drbd_packet cmd)
 		[P_SYNC_UUID]           = "ReportSyncUUID",
 		[P_AUTH_CHALLENGE]      = "AuthChallenge",
 		[P_AUTH_RESPONSE]	= "AuthResponse",
+		[P_STATE_CHG_REQ]       = "StateChgRequest",
 		[P_PING]		= "Ping",
 		[P_PING_ACK]	        = "PingAck",
 		[P_RECV_ACK]	        = "RecvAck",
@@ -3748,22 +3747,22 @@ const char *cmdname(enum drbd_packet cmd)
 		[P_NEG_DREPLY]	        = "NegDReply",
 		[P_NEG_RS_DREPLY]	= "NegRSDReply",
 		[P_BARRIER_ACK]	        = "BarrierAck",
-		[P_STATE_CHG_REQ]       = "StateChgRequest",
 		[P_STATE_CHG_REPLY]     = "StateChgReply",
 		[P_OV_REQUEST]          = "OVRequest",
 		[P_OV_REPLY]            = "OVReply",
 		[P_OV_RESULT]           = "OVResult",
 		[P_CSUM_RS_REQUEST]     = "CsumRSRequest",
 		[P_RS_IS_IN_SYNC]	= "CsumRSIsInSync",
+		[P_SYNC_PARAM89]	= "SyncParam89",
 		[P_COMPRESSED_BITMAP]   = "CBitmap",
 		[P_DELAY_PROBE]         = "DelayProbe",
 		[P_OUT_OF_SYNC]		= "OutOfSync",
-		[P_RETRY_WRITE]		= "RetryWrite",
 		[P_RS_CANCEL]		= "RSCancel",
 		[P_CONN_ST_CHG_REQ]	= "conn_st_chg_req",
 		[P_CONN_ST_CHG_REPLY]	= "conn_st_chg_reply",
 		[P_RETRY_WRITE]		= "retry_write",
 		[P_PROTOCOL_UPDATE]	= "protocol_update",
+		[P_TRIM]	        = "Trim",
 		[P_RS_THIN_REQ]         = "rs_thin_req",
 		[P_RS_DEALLOCATED]      = "rs_deallocated",
 

>From 860d00e7a5220f9bc44bf8d6529c04dbb8856451 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 15 Jun 2016 09:10:07 +0200
Subject: [PATCH] x86: don't warn about duplicate initializion of stack sizes
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

arch/x86/include/asm/page_64_types.h:18:21: error: initialized field overwritten [-Werror=override-init]
 #define DEBUG_STKSZ (PAGE_SIZE << DEBUG_STACK_ORDER)
                     ^
arch/x86/kernel/cpu/common.c:1304:26: note: in expansion of macro ‘DEBUG_STKSZ’
    [DEBUG_STACK - 1]   = DEBUG_STKSZ
                          ^
arch/x86/include/asm/page_64_types.h:18:21: note: (near initialization for ‘exception_stack_sizes[2]’)
 #define DEBUG_STKSZ (PAGE_SIZE << DEBUG_STACK_ORDER)
                     ^
arch/x86/kernel/cpu/common.c:1304:26: note: in expansion of macro ‘DEBUG_STKSZ’
    [DEBUG_STACK - 1]   = DEBUG_STKSZ

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 5ba74f280448..ebc909203a38 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1268,6 +1268,7 @@ EXPORT_PER_CPU_SYMBOL(__preempt_count);
  * limit), all of them are 4K, except the debug stack which
  * is 8K.
  */
+#pragma GCC diagnostic ignored "-Woverride-init"
 static const unsigned int exception_stack_sizes[N_EXCEPTION_STACKS] = {
 	  [0 ... N_EXCEPTION_STACKS - 1]	= EXCEPTION_STKSZ,
 	  [DEBUG_STACK - 1]			= DEBUG_STKSZ

>From 01fc760fe7fbee1163f4a0c25cd722014054de70 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Jun 2016 10:22:51 +0200
Subject: [PATCH] alsa: usb: avoid duplicate initializers in quirks table

sound/usb/quirks-table.h:2892:125: error: initialized field overwritten [-Werror=override-init]
sound/usb/quirks-table.h:2892:125: note: (near initialization for 'usb_audio_ids[230].match_flags')
sound/usb/quirks-table.h:2892:181: error: initialized field overwritten [-Werror=override-init]
sound/usb/quirks-table.h:2892:181: note: (near initialization for 'usb_audio_ids[230].bInterfaceClass')
sound/usb/quirks-table.h:2893:125: error: initialized field overwritten [-Werror=override-init]
sound/usb/quirks-table.h:2893:125: note: (near initialization for 'usb_audio_ids[231].match_flags')
sound/usb/quirks-table.h:2893:181: error: initialized field overwritten [-Werror=override-init]
sound/usb/quirks-table.h:2893:181: note: (near initialization for 'usb_audio_ids[231].bInterfaceClass')
sound/usb/quirks-table.h:2894:125: error: initialized field overwritten [-Werror=override-init]
sound/usb/quirks-table.h:2894:125: note: (near initialization for 'usb_audio_ids[232].match_flags')
sound/usb/quirks-table.h:2894:181: error: initialized field overwritten [-Werror=override-init]

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/sound/usb/quirks-table.h b/sound/usb/quirks-table.h
index 8a59d4782a0f..8d302ef764a3 100644
--- a/sound/usb/quirks-table.h
+++ b/sound/usb/quirks-table.h
@@ -2875,10 +2875,11 @@ YAMAHA_DEVICE(0x7010, "UB99"),
  */
 
 #define AU0828_DEVICE(vid, pid, vname, pname) { \
-	USB_DEVICE_VENDOR_SPEC(vid, pid), \
 	.match_flags = USB_DEVICE_ID_MATCH_DEVICE | \
 		       USB_DEVICE_ID_MATCH_INT_CLASS | \
 		       USB_DEVICE_ID_MATCH_INT_SUBCLASS, \
+	.idVendor = vid, \
+	.idProduct = pid, \
 	.bInterfaceClass = USB_CLASS_AUDIO, \
 	.bInterfaceSubClass = USB_SUBCLASS_AUDIOCONTROL, \
 	.driver_info = (unsigned long) &(const struct snd_usb_audio_quirk) { \
