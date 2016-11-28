From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH  v2 12/13] net: ethernet: ti: cpts: calc mult and shift from refclk freq
Date: Mon, 28 Nov 2016 17:03:36 -0600
Message-ID: <20161128230337.6731-13-grygorii.strashko@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161128230337.6731-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  8 +++--
 drivers/net/ethernet/ti/cpts.c                 | 50 ++++++++++++++++++++++----
 2 files changed, 49 insertions(+), 9 deletions(-)

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
index da3339b..4761d8c 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -406,18 +406,54 @@ void cpts_unregister(struct cpts *cpts)
 }
 EXPORT_SYMBOL_GPL(cpts_unregister);
 
+static void cpts_calc_mult_shift(struct cpts *cpts)
+{
+	u64 frac, maxsec, ns;
+	u32 freq, mult, shift;
+
+	freq = clk_get_rate(cpts->refclk);
+
+	/* Calc the maximum number of seconds which we can run before
+	 * wrapping around.
+	 */
+	maxsec = cpts->cc.mask;
+	do_div(maxsec, freq);
+	if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
+		maxsec = 600;
+
+	if (cpts->cc_mult || cpts->cc.shift)
+		return;
+
+	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
+
+	cpts->cc_mult = mult;
+	cpts->cc.mult = mult;
+	cpts->cc.shift = shift;
+
+	frac = 0;
+	ns = cyclecounter_cyc2ns(&cpts->cc, freq, cpts->cc.mask, &frac);
+
+	dev_info(cpts->dev,
+		 "CPTS: ref_clk_freq:%u calc_mult:%u calc_shift:%u error:%lld nsec/sec\n",
+		 freq, cpts->cc_mult, cpts->cc.shift, (ns - NSEC_PER_SEC));
+}
+
 static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 {
 	int ret = -EINVAL;
 	u32 prop;
 
-	if (of_property_read_u32(node, "cpts_clock_mult", &prop))
-		goto  of_error;
-	cpts->cc_mult = prop;
+	cpts->cc_mult = 0;
+	if (!of_property_read_u32(node, "cpts_clock_mult", &prop))
+		cpts->cc_mult = prop;
+
+	cpts->cc.shift = 0;
+	if (!of_property_read_u32(node, "cpts_clock_shift", &prop))
+		cpts->cc.shift = prop;
 
-	if (of_property_read_u32(node, "cpts_clock_shift", &prop))
-		goto  of_error;
-	cpts->cc.shift = prop;
+	if ((cpts->cc_mult && !cpts->cc.shift) ||
+	    (!cpts->cc_mult && cpts->cc.shift))
+		goto of_error;
 
 	return 0;
 
@@ -460,6 +496,8 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
 	cpts->info = cpts_info;
 
+	cpts_calc_mult_shift(cpts);
+
 	return cpts;
 }
 EXPORT_SYMBOL_GPL(cpts_create);
-- 
2.10.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
