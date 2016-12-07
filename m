From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v5 12/13] net: ethernet: ti: cpts: calc mult and shift from refclk freq
Date: Tue, 6 Dec 2016 18:00:44 -0600
Message-ID: <20161207000045.28333-13-grygorii.strashko@ti.com>
References: <20161207000045.28333-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        John Stultz <john.stultz@linaro.org>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207000045.28333-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cyclecounter mult and shift values can be calculated based on the
CPTS rfclk frequency and timekeepnig framework provides required algos
and API's.

Hence, calc mult and shift basing on CPTS rfclk frequency if both
cpts_clock_shift and cpts_clock_mult properties are not provided in DT (the
basis of calculation algorithm is borrowed from
__clocksource_update_freq_scale() commit 7d2f944a2b83 ("clocksource:
Provide a generic mult/shift factor calculation")). After this change
cpts_clock_shift and cpts_clock_mult DT properties will become optional.

Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  8 +++--
 drivers/net/ethernet/ti/cpts.c                 | 50 ++++++++++++++++++++++----
 2 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 5ad439f..ebda7c9 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -20,8 +20,6 @@ Required properties:
 - slaves		: Specifies number for slaves
 - active_slave		: Specifies the slave to use for time stamping,
 			  ethtool and SIOCGMIIPHY
-- cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
-- cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
 
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
@@ -35,7 +33,11 @@ Optional properties:
 			  For example in dra72x-evm, pcf gpio has to be
 			  driven low so that cpsw slave 0 and phy data
 			  lines are connected via mux.
-
+- cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
+- cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
+			  Mult and shift will be calculated basing on CPTS
+			  rftclk frequency if both cpts_clock_shift and
+			  cpts_clock_mult properties are not provided.
 
 Slave Properties:
 Required properties:
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index cb844ed..ebd413a 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -405,18 +405,52 @@ void cpts_unregister(struct cpts *cpts)
 }
 EXPORT_SYMBOL_GPL(cpts_unregister);
 
+static void cpts_calc_mult_shift(struct cpts *cpts)
+{
+	u64 frac, maxsec, ns;
+	u32 freq;
+
+	freq = clk_get_rate(cpts->refclk);
+
+	/* Calc the maximum number of seconds which we can run before
+	 * wrapping around.
+	 */
+	maxsec = cpts->cc.mask;
+	do_div(maxsec, freq);
+	/* limit conversation rate to 10 sec as higher values will produce
+	 * too small mult factors and so reduce the conversion accuracy
+	 */
+	if (maxsec > 10)
+		maxsec = 10;
+
+	if (cpts->cc.mult || cpts->cc.shift)
+		return;
+
+	clocks_calc_mult_shift(&cpts->cc.mult, &cpts->cc.shift,
+			       freq, NSEC_PER_SEC, maxsec);
+
+	frac = 0;
+	ns = cyclecounter_cyc2ns(&cpts->cc, freq, cpts->cc.mask, &frac);
+
+	dev_info(cpts->dev,
+		 "CPTS: ref_clk_freq:%u calc_mult:%u calc_shift:%u error:%lld nsec/sec\n",
+		 freq, cpts->cc.mult, cpts->cc.shift, (ns - NSEC_PER_SEC));
+}
+
 static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 {
 	int ret = -EINVAL;
 	u32 prop;
 
-	if (of_property_read_u32(node, "cpts_clock_mult", &prop))
-		goto  of_error;
-	cpts->cc.mult = prop;
+	if (!of_property_read_u32(node, "cpts_clock_mult", &prop))
+		cpts->cc.mult = prop;
 
-	if (of_property_read_u32(node, "cpts_clock_shift", &prop))
-		goto  of_error;
-	cpts->cc.shift = prop;
+	if (!of_property_read_u32(node, "cpts_clock_shift", &prop))
+		cpts->cc.shift = prop;
+
+	if ((cpts->cc.mult && !cpts->cc.shift) ||
+	    (!cpts->cc.mult && cpts->cc.shift))
+		goto of_error;
 
 	return 0;
 
@@ -454,11 +488,13 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 
 	cpts->cc.read = cpts_systim_read;
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
+	cpts->info = cpts_info;
+
+	cpts_calc_mult_shift(cpts);
 	/* save cc.mult original value as it can be modified
 	 * by cpts_ptp_adjfreq().
 	 */
 	cpts->cc_mult = cpts->cc.mult;
-	cpts->info = cpts_info;
 
 	return cpts;
 }
-- 
2.10.1
