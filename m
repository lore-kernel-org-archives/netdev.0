From: David Daney <david.daney@cavium.com>
Subject: [PATCH 5/7] MIPS: Octeon: Automatically provision CVMSEG space.
Date: Wed,  1 Nov 2017 17:36:04 -0700
Message-ID: <20171102003606.19913-6-david.daney@cavium.com>
References: <20171102003606.19913-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        devicetree@vger.kernel.org, David Daney <david.daney@cavium.com>,
        Carlos Munoz <cmunoz@caviumnetworks.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@mips.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171102003606.19913-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE and automatically calculate
the amount of CVMSEG space needed.

1st 128-bytes: Use by IOBDMA
2nd 128-bytes: Reserved by kernel for scratch/TLS emulation.
3rd 128-bytes: OCTEON-III LMTLINE

New config variable CONFIG_CAVIUM_OCTEON_EXTRA_CVMSEG provisions
additional lines, defaults to zero.

Signed-off-by: David Daney <david.daney@cavium.com>
Signed-off-by: Carlos Munoz <cmunoz@caviumnetworks.com>
---
 arch/mips/cavium-octeon/Kconfig                    | 27 ++++++++++++--------
 arch/mips/cavium-octeon/setup.c                    | 16 ++++++------
 .../asm/mach-cavium-octeon/kernel-entry-init.h     | 20 +++++++++------
 arch/mips/include/asm/mipsregs.h                   |  2 ++
 arch/mips/include/asm/octeon/octeon.h              |  2 ++
 arch/mips/include/asm/processor.h                  |  2 +-
 arch/mips/kernel/octeon_switch.S                   |  2 --
 arch/mips/kernel/unaligned.c                       |  3 +++
 arch/mips/mm/tlbex.c                               | 29 ++++++----------------
 9 files changed, 52 insertions(+), 51 deletions(-)

diff --git a/arch/mips/cavium-octeon/Kconfig b/arch/mips/cavium-octeon/Kconfig
index 211ef5b57214..fc6a1b44605b 100644
--- a/arch/mips/cavium-octeon/Kconfig
+++ b/arch/mips/cavium-octeon/Kconfig
@@ -10,21 +10,26 @@ config CAVIUM_CN63XXP1
 	  non-CN63XXP1 hardware, so it is recommended to select "n"
 	  unless it is known the workarounds are needed.
 
-config CAVIUM_OCTEON_CVMSEG_SIZE
-	int "Number of L1 cache lines reserved for CVMSEG memory"
-	range 0 54
-	default 1
-	help
-	  CVMSEG LM is a segment that accesses portions of the dcache as a
-	  local memory; the larger CVMSEG is, the smaller the cache is.
-	  This selects the size of CVMSEG LM, which is in cache blocks. The
-	  legally range is from zero to 54 cache blocks (i.e. CVMSEG LM is
-	  between zero and 6192 bytes).
-
 endif # CPU_CAVIUM_OCTEON
 
 if CAVIUM_OCTEON_SOC
 
+config CAVIUM_OCTEON_EXTRA_CVMSEG
+	int "Number of extra L1 cache lines reserved for CVMSEG memory"
+	range 0 50
+	default 0
+	help
+	  CVMSEG LM is a segment that accesses portions of the dcache
+	  as a local memory; the larger CVMSEG is, the smaller the
+	  cache is.  The kernel uses two or three blocks (one for TLB
+	  exception handlers, one for driver IOBDMA operations, and on
+	  models that need it, one for LMTDMA operations). This
+	  selects an optional extra number of CVMSEG lines for use by
+	  other software.
+
+	  Normally no extra lines are required, and this parameter
+	  should be set to zero.
+
 config CAVIUM_OCTEON_LOCK_L2
 	bool "Lock often used kernel code in the L2"
 	default "y"
diff --git a/arch/mips/cavium-octeon/setup.c b/arch/mips/cavium-octeon/setup.c
index 99e6a68bc652..51c4d3c3cada 100644
--- a/arch/mips/cavium-octeon/setup.c
+++ b/arch/mips/cavium-octeon/setup.c
@@ -68,6 +68,12 @@ extern void pci_console_init(const char *arg);
 static unsigned long long max_memory = ULLONG_MAX;
 static unsigned long long reserve_low_mem;
 
+/*
+ * modified in hernel-entry-init.h, must have an initial value to keep
+ * it from being clobbered when bss is zeroed.
+ */
+u32 octeon_cvmseg_lines = 2;
+
 DEFINE_SEMAPHORE(octeon_bootbus_sem);
 EXPORT_SYMBOL(octeon_bootbus_sem);
 
@@ -604,11 +610,7 @@ void octeon_user_io_init(void)
 
 	/* R/W If set, CVMSEG is available for loads/stores in
 	 * kernel/debug mode. */
-#if CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE > 0
 	cvmmemctl.s.cvmsegenak = 1;
-#else
-	cvmmemctl.s.cvmsegenak = 0;
-#endif
 	if (OCTEON_IS_OCTEON3()) {
 		/* Enable LMTDMA */
 		cvmmemctl.s.lmtena = 1;
@@ -626,9 +628,9 @@ void octeon_user_io_init(void)
 
 	/* Setup of CVMSEG is done in kernel-entry-init.h */
 	if (smp_processor_id() == 0)
-		pr_notice("CVMSEG size: %d cache lines (%d bytes)\n",
-			  CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE,
-			  CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE * 128);
+		pr_notice("CVMSEG size: %u cache lines (%u bytes)\n",
+			  octeon_cvmseg_lines,
+			  octeon_cvmseg_lines * 128);
 
 	if (octeon_has_feature(OCTEON_FEATURE_FAU)) {
 		union cvmx_iob_fau_timeout fau_timeout;
diff --git a/arch/mips/include/asm/mach-cavium-octeon/kernel-entry-init.h b/arch/mips/include/asm/mach-cavium-octeon/kernel-entry-init.h
index c38b38ce5a3d..cdcca60978a2 100644
--- a/arch/mips/include/asm/mach-cavium-octeon/kernel-entry-init.h
+++ b/arch/mips/include/asm/mach-cavium-octeon/kernel-entry-init.h
@@ -26,11 +26,18 @@
 	# a3 = address of boot descriptor block
 	.set push
 	.set arch=octeon
+	mfc0	v1, CP0_PRID_REG
+	andi	v1, 0xff00
+	li	v0, 0x9500		# cn78XX or later
+	subu	v1, v1, v0
+	li	t2, 2 + CONFIG_CAVIUM_OCTEON_EXTRA_CVMSEG
+	bltz	v1, 1f
+	addiu	t2, 1			# t2 has cvmseg_size
+1:
 	# Read the cavium mem control register
 	dmfc0	v0, CP0_CVMMEMCTL_REG
 	# Clear the lower 6 bits, the CVMSEG size
-	dins	v0, $0, 0, 6
-	ori	v0, CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE
+	dins	v0, t2, 0, 6
 	dmtc0	v0, CP0_CVMMEMCTL_REG	# Write the cavium mem control register
 	dmfc0	v0, CP0_CVMCTL_REG	# Read the cavium control register
 	# Disable unaligned load/store support but leave HW fixup enabled
@@ -70,7 +77,7 @@
 	# Flush dcache after config change
 	cache	9, 0($0)
 	# Zero all of CVMSEG to make sure parity is correct
-	dli	v0, CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE
+	move	v0, t2
 	dsll	v0, 7
 	beqz	v0, 2f
 1:	dsubu	v0, 8
@@ -126,12 +133,7 @@
 	LONG_L	sp, (t0)
 	# Set the SP global variable to zero so the master knows we've started
 	LONG_S	zero, (t0)
-#ifdef __OCTEON__
-	syncw
-	syncw
-#else
 	sync
-#endif
 	# Jump to the normal Linux SMP entry point
 	j   smp_bootstrap
 	nop
@@ -148,6 +150,8 @@
 
 #endif /* CONFIG_SMP */
 octeon_main_processor:
+	dla	v0, octeon_cvmseg_lines
+	sw	t2, 0(v0)
 	.set pop
 .endm
 
diff --git a/arch/mips/include/asm/mipsregs.h b/arch/mips/include/asm/mipsregs.h
index a6810923b3f0..df7654d7333d 100644
--- a/arch/mips/include/asm/mipsregs.h
+++ b/arch/mips/include/asm/mipsregs.h
@@ -1126,6 +1126,8 @@
 #define FPU_CSR_RD	0x3	/* towards -Infinity */
 
 
+#define CAVIUM_OCTEON_SCRATCH_OFFSET (2 * 128 - 16 - 32768)
+
 #ifndef __ASSEMBLY__
 
 /*
diff --git a/arch/mips/include/asm/octeon/octeon.h b/arch/mips/include/asm/octeon/octeon.h
index d184592e6515..02eb194b2cdc 100644
--- a/arch/mips/include/asm/octeon/octeon.h
+++ b/arch/mips/include/asm/octeon/octeon.h
@@ -392,6 +392,8 @@ static inline uint32_t octeon_npi_read32(uint64_t address)
 
 extern struct cvmx_bootinfo *octeon_bootinfo;
 
+extern u32 octeon_cvmseg_lines;
+
 extern uint64_t octeon_bootloader_entry_addr;
 
 extern void (*octeon_irq_setup_secondary)(void);
diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
index 95b8c471f572..3d264008afcb 100644
--- a/arch/mips/include/asm/processor.h
+++ b/arch/mips/include/asm/processor.h
@@ -216,7 +216,7 @@ struct octeon_cop2_state {
 	.cp2			= {0,},
 
 struct octeon_cvmseg_state {
-	unsigned long cvmseg[CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE]
+	unsigned long cvmseg[CONFIG_CAVIUM_OCTEON_EXTRA_CVMSEG + 3]
 			    [cpu_dcache_line_size() / sizeof(unsigned long)];
 };
 
diff --git a/arch/mips/kernel/octeon_switch.S b/arch/mips/kernel/octeon_switch.S
index e42113fe2762..4f56902d5ee7 100644
--- a/arch/mips/kernel/octeon_switch.S
+++ b/arch/mips/kernel/octeon_switch.S
@@ -29,7 +29,6 @@
 	cpu_save_nonscratch a0
 	LONG_S	ra, THREAD_REG31(a0)
 
-#if CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE > 0
 	/* Check if we need to store CVMSEG state */
 	dmfc0	t0, $11,7	/* CvmMemCtl */
 	bbit0	t0, 6, 3f	/* Is user access enabled? */
@@ -58,7 +57,6 @@
 	dmfc0	t0, $11,7	/* CvmMemCtl */
 	xori	t0, t0, 0x40	/* Bit 6 is CVMSEG user enable */
 	dmtc0	t0, $11,7	/* CvmMemCtl */
-#endif
 3:
 
 #if defined(CONFIG_CC_STACKPROTECTOR) && !defined(CONFIG_SMP)
diff --git a/arch/mips/kernel/unaligned.c b/arch/mips/kernel/unaligned.c
index 2d0b912f9e3e..610f9b4ccdae 100644
--- a/arch/mips/kernel/unaligned.c
+++ b/arch/mips/kernel/unaligned.c
@@ -2281,6 +2281,9 @@ static void emulate_load_store_MIPS16e(struct pt_regs *regs, void __user * addr)
 	force_sig(SIGILL, current);
 }
 
+#ifdef CONFIG_CPU_CAVIUM_OCTEON
+#include <asm/octeon/octeon.h>
+#endif
 asmlinkage void do_ade(struct pt_regs *regs)
 {
 	enum ctx_state prev_state;
diff --git a/arch/mips/mm/tlbex.c b/arch/mips/mm/tlbex.c
index 79b9f2ad3ff5..3d3dfba465ae 100644
--- a/arch/mips/mm/tlbex.c
+++ b/arch/mips/mm/tlbex.c
@@ -115,33 +115,17 @@ static int use_lwx_insns(void)
 		return 0;
 	}
 }
-#if defined(CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE) && \
-    CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE > 0
-static bool scratchpad_available(void)
-{
-	return true;
-}
-static int scratchpad_offset(int i)
-{
-	/*
-	 * CVMSEG starts at address -32768 and extends for
-	 * CAVIUM_OCTEON_CVMSEG_SIZE 128 byte cache lines.
-	 */
-	i += 1; /* Kernel use starts at the top and works down. */
-	return CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE * 128 - (8 * i) - 32768;
-}
-#else
-static bool scratchpad_available(void)
-{
-	return false;
-}
+
 static int scratchpad_offset(int i)
 {
+	if (IS_ENABLED(CONFIG_CPU_CAVIUM_OCTEON))
+		return (CAVIUM_OCTEON_SCRATCH_OFFSET - (8 * i));
+
 	BUG();
 	/* Really unreachable, but evidently some GCC want this. */
 	return 0;
 }
-#endif
+
 /*
  * Found by experiment: At least some revisions of the 4kc throw under
  * some circumstances a machine check exception, triggered by invalid
@@ -1302,7 +1286,8 @@ static void build_r4000_tlb_refill_handler(void)
 	memset(relocs, 0, sizeof(relocs));
 	memset(final_handler, 0, sizeof(final_handler));
 
-	if (IS_ENABLED(CONFIG_64BIT) && (scratch_reg >= 0 || scratchpad_available()) && use_bbit_insns()) {
+	if (IS_ENABLED(CONFIG_64BIT) && use_bbit_insns() &&
+	   (scratch_reg >= 0 || IS_ENABLED(CONFIG_CPU_CAVIUM_OCTEON))) {
 		htlb_info = build_fast_tlb_refill_handler(&p, &l, &r, K0, K1,
 							  scratch_reg);
 		vmalloc_mode = refill_scratch;
-- 
2.13.6
