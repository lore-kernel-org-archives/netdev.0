From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC net-next] ravb: use clock rate as basis for GTI.TIV
Date: Mon,  2 Nov 2015 10:40:39 +0900
Message-ID: <1446428439-10944-1-git-send-email-horms+renesas@verge.net.au>
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
the r8a7795/Slavator-X which is advertised as 133MHz but
may differ depending on the extal present on the Slavator-X.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
Tested on the topic/gen3-latest branch of Geert Uytterhoeven's
renesas-drivers tree on kernel.org: 3f5a88be9fea ("[WIP] arm64: renesas:
r8a7795: Convert to new CPG/MSSR bindings")
---
 drivers/net/ethernet/renesas/ravb.h      |  3 +++
 drivers/net/ethernet/renesas/ravb_main.c | 35 +++++++++++++++++++++++++++++++-
 2 files changed, 37 insertions(+), 1 deletion(-)

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
index 8cc5ec5ed19a..af52c88b8b8f 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1659,6 +1659,37 @@ static const struct of_device_id ravb_match_table[] = {
 };
 MODULE_DEVICE_TABLE(of, ravb_match_table);
 
+static int ravb_set_gti(struct net_device *ndev)
+{
+
+	struct device *dev = ndev->dev.parent;
+	struct device_node *np = dev->of_node;
+	unsigned long long rate;
+	unsigned long inc;
+	struct clk *clk;
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
+	inc = (1000000000ULL << 20) / rate;
+
+	if (inc < GTI_TIV_MIN || inc > GTI_TIV_MAX) {
+		dev_err(dev, "gti.tiv increment 0x%lx is outside the range 0x%x - 0x%x\n",
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
@@ -1755,7 +1786,9 @@ static int ravb_probe(struct platform_device *pdev)
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

