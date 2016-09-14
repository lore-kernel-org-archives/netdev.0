From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 7/9] net: ethernet: ti: cpts: calc mult and shift from refclk freq
Date: Wed, 14 Sep 2016 16:02:29 +0300
Message-ID: <20160914130231.3035-8-grygorii.strashko@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914130231.3035-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cyclecounter mult and shift values can be calculated based on the
CPTS rftclk frequency and timekeepnig framework provides required algos
and API's.

Hence, calc mult and shift basing on CPTS rftclk frequency if both
cpts_clock_shift and cpts_clock_mult properties are not provided in DT
(the basis of calculation algorithm is borrowed from
__clocksource_update_freq_scale()). After this change cpts_clock_shift
and cpts_clock_mult DT properties will become optional.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  4 +-
 drivers/net/ethernet/ti/cpts.c                 | 56 +++++++++++++++++++++++---
 2 files changed, 52 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 5ad439f..88f81c7 100644
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
@@ -35,6 +33,8 @@ Optional properties:
 			  For example in dra72x-evm, pcf gpio has to be
 			  driven low so that cpsw slave 0 and phy data
 			  lines are connected via mux.
+- cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
+- cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
 
 
 Slave Properties:
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index ff8bb85..8046a21 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -418,18 +418,60 @@ void cpts_unregister(struct cpts *cpts)
 	clk_disable(cpts->refclk);
 }
 
+static void cpts_calc_mult_shift(struct cpts *cpts)
+{
+	u64 maxsec;
+	u32 freq;
+	u32 mult;
+	u32 shift;
+	u64 ns;
+	u64 frac;
+
+	if (cpts->cc_mult || cpts->cc.shift)
+		return;
+
+	freq = clk_get_rate(cpts->refclk);
+
+	/* Calc the maximum number of seconds which we can run before
+	 * wrapping around.
+	 */
+	maxsec = cpts->cc.mask;
+	do_div(maxsec, freq);
+	if (!maxsec)
+		maxsec = 1;
+	else if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
+		maxsec = 600;
+
+	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
+
+	cpts->cc_mult = mult;
+	cpts->cc.mult = mult;
+	cpts->cc.shift = shift;
+	/* Check calculations and inform if not precise */
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
 
-	if (of_property_read_u32(node, "cpts_clock_shift", &prop))
-		goto  of_error;
-	cpts->cc.shift = prop;
+	cpts->cc.shift = 0;
+	if (!of_property_read_u32(node, "cpts_clock_shift", &prop))
+		cpts->cc.shift = prop;
+
+	if ((cpts->cc_mult && !cpts->cc.shift) ||
+	    (!cpts->cc_mult && cpts->cc.shift))
+		goto of_error;
 
 	return 0;
 
@@ -471,6 +513,8 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	cpts->cc.read = cpts_systim_read;
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
 
+	cpts_calc_mult_shift(cpts);
+
 	return cpts;
 }
 
-- 
2.9.3
