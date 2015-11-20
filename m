From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v3 net-next] ravb: use clock rate as basis for GTI.TIV
Date: Fri, 20 Nov 2015 11:29:39 -0800
Message-ID: <1448047779-21242-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The GTI.TIV may be set to 2GHz^2 / rate, where rate is
that of the clock of the device. Rather than assuming a
rate of 130MHz use the actual rate of the clock.

The motivation for this is to use the correct rate on
the r8a7795/Salvator-X which is advertised as 133MHz but
may differ depending on the extal present on the Salvator-X.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2
* Corrected typos in changelog, as pointed out by Geert Uytterhoeven
* Use do_div() rather than 64-bit division to allow compilation on
  32-bit ARM

v3
* Dropped RFC prefix
---
 drivers/net/ethernet/renesas/ravb.h      |  3 +++
 drivers/net/ethernet/renesas/ravb_main.c | 38 +++++++++++++++++++++++++++++++-
 2 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index 0623fff932e4..f9dee7436e81 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -576,6 +576,9 @@ enum GTI_BIT {
 	GTI_TIV		= 0x0FFFFFFF,
 };
 
+#define GTI_TIV_MAX	GTI_TIV
+#define GTI_TIV_MIN	0x20
+
 /* GIC */
 enum GIC_BIT {
 	GIC_PTCE	= 0x00000001,	/* Undocumented? */
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index ee8d1ec61fab..990dc55cdada 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -32,6 +32,8 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 
+#include <asm/div64.h>
+
 #include "ravb.h"
 
 #define RAVB_DEF_MSG_ENABLE \
@@ -1659,6 +1661,38 @@ static const struct of_device_id ravb_match_table[] = {
 };
 MODULE_DEVICE_TABLE(of, ravb_match_table);
 
+static int ravb_set_gti(struct net_device *ndev)
+{
+
+	struct device *dev = ndev->dev.parent;
+	struct device_node *np = dev->of_node;
+	unsigned long rate;
+	struct clk *clk;
+	uint64_t inc;
+
+	clk = of_clk_get(np, 0);
+	if (IS_ERR(clk)) {
+		dev_err(dev, "could not get clock\n");
+		return PTR_ERR(clk);
+	}
+
+	rate = clk_get_rate(clk);
+	clk_put(clk);
+
+	inc = 1000000000ULL << 20;
+	do_div(inc, rate);
+
+	if (inc < GTI_TIV_MIN || inc > GTI_TIV_MAX) {
+		dev_err(dev, "gti.tiv increment 0x%llx is outside the range 0x%x - 0x%x\n",
+			inc, GTI_TIV_MIN, GTI_TIV_MAX);
+		return -EINVAL;
+	}
+
+	ravb_write(ndev, inc, GTI);
+
+	return 0;
+}
+
 static int ravb_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -1755,7 +1789,9 @@ static int ravb_probe(struct platform_device *pdev)
 		   CCC);
 
 	/* Set GTI value */
-	ravb_write(ndev, ((1000 << 20) / 130) & GTI_TIV, GTI);
+	error = ravb_set_gti(ndev);
+	if (error)
+		goto out_release;
 
 	/* Request GTI loading */
 	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LTI, GCCR);
-- 
2.1.4

