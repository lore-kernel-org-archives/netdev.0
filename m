From: George Cherian <george.cherian@ti.com>
Subject: [PATCH v2 2/6] drivers: net: cpts: Remove hardcoded clock name for CPTS
Date: Fri, 2 May 2014 12:02:00 +0530
Message-ID: <1399012324-20737-3-git-send-email-george.cherian@ti.com>
References: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <richardcochran@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <tklauser@distanz.ch>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>, <zonque@gmail.com>, <balbi@ti.com>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <t-kristo@ti.com>,
	<mturquette@linaro.org>, <linux@arm.linux.org.uk>,
	<galak@codeaurora.org>, <ijc+devicetree@hellion.org.uk>,
	<mark.rutland@arm.com>, <pawel.moll@arm.com>, <robh+dt@kernel.org>,
	<tony@atomide.com>, <bcousson@baylibre.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CPTS refclk name is hardcoded, which makes it fail in case of DRA7x
Remove the hardcoded clock name for CPTS refclk and get the same from DT.

Signed-off-by: George Cherian <george.cherian@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 2435139..6b56f85 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -236,13 +236,11 @@ static void cpts_overflow_check(struct work_struct *work)
 	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
 }
 
-#define CPTS_REF_CLOCK_NAME "cpsw_cpts_rft_clk"
-
-static void cpts_clk_init(struct cpts *cpts)
+static void cpts_clk_init(struct device *dev, struct cpts *cpts)
 {
-	cpts->refclk = clk_get(NULL, CPTS_REF_CLOCK_NAME);
+	cpts->refclk = devm_clk_get(dev, "cpts");
 	if (IS_ERR(cpts->refclk)) {
-		pr_err("Failed to clk_get %s\n", CPTS_REF_CLOCK_NAME);
+		dev_err(dev, "Failed to get cpts refclk\n");
 		cpts->refclk = NULL;
 		return;
 	}
@@ -252,7 +250,6 @@ static void cpts_clk_init(struct cpts *cpts)
 static void cpts_clk_release(struct cpts *cpts)
 {
 	clk_disable(cpts->refclk);
-	clk_put(cpts->refclk);
 }
 
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
@@ -390,7 +387,7 @@ int cpts_register(struct device *dev, struct cpts *cpts,
 	for (i = 0; i < CPTS_MAX_EVENTS; i++)
 		list_add(&cpts->pool_data[i].list, &cpts->pool);
 
-	cpts_clk_init(cpts);
+	cpts_clk_init(dev, cpts);
 	cpts_write32(cpts, CPTS_EN, control);
 	cpts_write32(cpts, TS_PEND_EN, int_enable);
 
-- 
1.8.3.1

