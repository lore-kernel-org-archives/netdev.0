From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 1/8] MIPS: Octeon: Add octeon_io_clk_delay() function.
Date: Tue, 21 Aug 2012 11:45:05 -0700
Message-ID: <1345574712-21444-2-git-send-email-ddaney.cavm@gmail.com>
References: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        David Daney <ddaney@caviumnetworks.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>

Also cleanup and fix octeon_init_cvmcount()

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 arch/mips/cavium-octeon/csrc-octeon.c | 93 ++++++++++++++++++++++++-----------
 arch/mips/cavium-octeon/setup.c       |  3 +-
 arch/mips/include/asm/octeon/octeon.h |  1 +
 3 files changed, 66 insertions(+), 31 deletions(-)

diff --git a/arch/mips/cavium-octeon/csrc-octeon.c b/arch/mips/cavium-octeon/csrc-octeon.c
index ce6483a..0219395 100644
--- a/arch/mips/cavium-octeon/csrc-octeon.c
+++ b/arch/mips/cavium-octeon/csrc-octeon.c
@@ -4,7 +4,7 @@
  * for more details.
  *
  * Copyright (C) 2007 by Ralf Baechle
- * Copyright (C) 2009, 2010 Cavium Networks, Inc.
+ * Copyright (C) 2009, 2012 Cavium, Inc.
  */
 #include <linux/clocksource.h>
 #include <linux/export.h>
@@ -18,6 +18,33 @@
 #include <asm/octeon/cvmx-ipd-defs.h>
 #include <asm/octeon/cvmx-mio-defs.h>
 
+
+static u64 f;
+static u64 rdiv;
+static u64 sdiv;
+static u64 octeon_udelay_factor;
+static u64 octeon_ndelay_factor;
+
+void __init octeon_setup_delays(void)
+{
+	octeon_udelay_factor = octeon_get_clock_rate() / 1000000;
+	/*
+	 * For __ndelay we divide by 2^16, so the factor is multiplied
+	 * by the same amount.
+	 */
+	octeon_ndelay_factor = (octeon_udelay_factor * 0x10000ull) / 1000ull;
+
+	preset_lpj = octeon_get_clock_rate() / HZ;
+
+	if (current_cpu_type() == CPU_CAVIUM_OCTEON2) {
+		union cvmx_mio_rst_boot rst_boot;
+		rst_boot.u64 = cvmx_read_csr(CVMX_MIO_RST_BOOT);
+		rdiv = rst_boot.s.c_mul;	/* CPU clock */
+		sdiv = rst_boot.s.pnr_mul;	/* I/O clock */
+		f = (0x8000000000000000ull / sdiv) * 2;
+	}
+}
+
 /*
  * Set the current core's cvmcount counter to the value of the
  * IPD_CLK_COUNT.  We do this on all cores as they are brought
@@ -30,17 +57,6 @@ void octeon_init_cvmcount(void)
 {
 	unsigned long flags;
 	unsigned loops = 2;
-	u64 f = 0;
-	u64 rdiv = 0;
-	u64 sdiv = 0;
-	if (current_cpu_type() == CPU_CAVIUM_OCTEON2) {
-		union cvmx_mio_rst_boot rst_boot;
-		rst_boot.u64 = cvmx_read_csr(CVMX_MIO_RST_BOOT);
-		rdiv = rst_boot.s.c_mul;	/* CPU clock */
-		sdiv = rst_boot.s.pnr_mul;	/* I/O clock */
-		f = (0x8000000000000000ull / sdiv) * 2;
-	}
-
 
 	/* Clobber loops so GCC will not unroll the following while loop. */
 	asm("" : "+r" (loops));
@@ -57,9 +73,9 @@ void octeon_init_cvmcount(void)
 			if (f != 0) {
 				asm("dmultu\t%[cnt],%[f]\n\t"
 				    "mfhi\t%[cnt]"
-				    : [cnt] "+r" (ipd_clk_count),
-				      [f] "=r" (f)
-				    : : "hi", "lo");
+				    : [cnt] "+r" (ipd_clk_count)
+				    : [f] "r" (f)
+				    : "hi", "lo");
 			}
 		}
 		write_c0_cvmcount(ipd_clk_count);
@@ -109,21 +125,6 @@ void __init plat_time_init(void)
 	clocksource_register_hz(&clocksource_mips, octeon_get_clock_rate());
 }
 
-static u64 octeon_udelay_factor;
-static u64 octeon_ndelay_factor;
-
-void __init octeon_setup_delays(void)
-{
-	octeon_udelay_factor = octeon_get_clock_rate() / 1000000;
-	/*
-	 * For __ndelay we divide by 2^16, so the factor is multiplied
-	 * by the same amount.
-	 */
-	octeon_ndelay_factor = (octeon_udelay_factor * 0x10000ull) / 1000ull;
-
-	preset_lpj = octeon_get_clock_rate() / HZ;
-}
-
 void __udelay(unsigned long us)
 {
 	u64 cur, end, inc;
@@ -163,3 +164,35 @@ void __delay(unsigned long loops)
 		cur = read_c0_cvmcount();
 }
 EXPORT_SYMBOL(__delay);
+
+
+/**
+ * octeon_io_clk_delay - wait for a given number of io clock cycles to pass.
+ *
+ * We scale the wait by the clock ratio, and then wait for the
+ * corresponding number of core clocks.
+ *
+ * @count: The number of clocks to wait.
+ */
+void octeon_io_clk_delay(unsigned long count)
+{
+	u64 cur, end;
+
+	cur = read_c0_cvmcount();
+	if (rdiv != 0) {
+		end = count * rdiv;
+		if (f != 0) {
+			asm("dmultu\t%[cnt],%[f]\n\t"
+				"mfhi\t%[cnt]"
+				: [cnt] "+r" (end)
+				: [f] "r" (f)
+				: "hi", "lo");
+		}
+		end = cur + end;
+	} else {
+		end = cur + count;
+	}
+	while (end > cur)
+		cur = read_c0_cvmcount();
+}
+EXPORT_SYMBOL(octeon_io_clk_delay);
diff --git a/arch/mips/cavium-octeon/setup.c b/arch/mips/cavium-octeon/setup.c
index 919b0fb..04dd8ff 100644
--- a/arch/mips/cavium-octeon/setup.c
+++ b/arch/mips/cavium-octeon/setup.c
@@ -548,6 +548,8 @@ void __init prom_init(void)
 	}
 #endif
 
+	octeon_setup_delays();
+
 	/*
 	 * BIST should always be enabled when doing a soft reset. L2
 	 * Cache locking for instance is not cleared unless BIST is
@@ -611,7 +613,6 @@ void __init prom_init(void)
 	mips_hpt_frequency = octeon_get_clock_rate();
 
 	octeon_init_cvmcount();
-	octeon_setup_delays();
 
 	_machine_restart = octeon_restart;
 	_machine_halt = octeon_halt;
diff --git a/arch/mips/include/asm/octeon/octeon.h b/arch/mips/include/asm/octeon/octeon.h
index a31288e..96e58a5 100644
--- a/arch/mips/include/asm/octeon/octeon.h
+++ b/arch/mips/include/asm/octeon/octeon.h
@@ -52,6 +52,7 @@ extern asmlinkage void octeon_cop2_restore(struct octeon_cop2_state *task);
 
 extern void octeon_init_cvmcount(void);
 extern void octeon_setup_delays(void);
+extern void octeon_io_clk_delay(unsigned long);
 
 #define OCTEON_ARGV_MAX_ARGS	64
 #define OCTOEN_SERIAL_LEN	20
-- 
1.7.11.4
