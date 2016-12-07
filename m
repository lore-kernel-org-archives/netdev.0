From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v5 04/13] net: ethernet: ti: cpts: fix unbalanced clk api usage in cpts_register/unregister
Date: Tue, 6 Dec 2016 18:00:36 -0600
Message-ID: <20161207000045.28333-5-grygorii.strashko@ti.com>
References: <20161207000045.28333-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207000045.28333-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two issues with TI CPTS code which are reproducible when TI
CPSW ethX device passes few up/down iterations:
- cpts refclk prepare counter continuously incremented after each
up/down iteration;
- devm_clk_get(dev, "cpts") is called many times.

Hence, fix these issues by using clk_disable_unprepare() in
cpts_clk_release() and skipping devm_clk_get() if cpts refclk has been
acquired already.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 8cb0369..61198f1 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -230,18 +230,20 @@ static void cpts_overflow_check(struct work_struct *work)
 
 static void cpts_clk_init(struct device *dev, struct cpts *cpts)
 {
-	cpts->refclk = devm_clk_get(dev, "cpts");
-	if (IS_ERR(cpts->refclk)) {
-		dev_err(dev, "Failed to get cpts refclk\n");
-		cpts->refclk = NULL;
-		return;
+	if (!cpts->refclk) {
+		cpts->refclk = devm_clk_get(dev, "cpts");
+		if (IS_ERR(cpts->refclk)) {
+			dev_err(dev, "Failed to get cpts refclk\n");
+			cpts->refclk = NULL;
+			return;
+		}
 	}
 	clk_prepare_enable(cpts->refclk);
 }
 
 static void cpts_clk_release(struct cpts *cpts)
 {
-	clk_disable(cpts->refclk);
+	clk_disable_unprepare(cpts->refclk);
 }
 
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
-- 
2.10.1
