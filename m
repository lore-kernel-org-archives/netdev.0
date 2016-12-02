From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v3 04/13] net: ethernet: ti: cpts: fix unbalanced clk api usage in cpts_register/unregister
Date: Fri, 2 Dec 2016 14:30:14 -0600
Message-ID: <20161202203023.25526-5-grygorii.strashko@ti.com>
References: <20161202203023.25526-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161202203023.25526-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There are two issues with TI CPTS code which are reproducible when TI
CPSW ethX device passes few up/down iterations:
- cpts refclk prepare counter continuously incremented after each
up/down iteration;
- devm_clk_get(dev, "cpts") is called many times.

Hence, fix these issues by using clk_disable_unprepare() in
cpts_clk_release() and skipping devm_clk_get() if cpts refclk has been
acquired already.

Acked-by: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
