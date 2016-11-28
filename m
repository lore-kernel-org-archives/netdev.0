From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH  v2 04/13] net: ethernet: ti: cpts: fix unbalanced clk api usage in cpts_register/unregister
Date: Mon, 28 Nov 2016 17:03:28 -0600
Message-ID: <20161128230337.6731-5-grygorii.strashko@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:62362 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755868AbcK1XDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 18:03:45 -0500
In-Reply-To: <20161128230337.6731-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two issues with TI CPTS code which are reproducible when TI
CPSW ethX device passes few up/down iterations:
- cpts refclk prepare counter continuously incremented after each
up/down iteration;
- devm_clk_get(dev, "cpts") is called many times.

Hence, fix these issues by using clk_disable_unprepare() in
cpts_clk_release() and skipping devm_clk_get() if cpts refclk has been
acquired already.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index b26d6fe..101e17b 100644
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
