From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] ravb: Use common error handling code in ravb_probe()
Date: Sat, 28 Oct 2017 19:19:19 +0200
Message-ID: <2839c3c2-0116-7549-6ff4-a49eb0a52298@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eugeniu Rosca <erosca@de.adit-jv.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Oct 2017 19:10:08 +0200

Add a jump target so that a bit of exception handling can be better reused
at the end of this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/renesas/ravb_main.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index a8822a756e08..62dbdf7de6cd 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -2069,10 +2069,9 @@ static int ravb_probe(struct platform_device *pdev)
 		irq = platform_get_irq_byname(pdev, "ch22");
 	else
 		irq = platform_get_irq(pdev, 0);
-	if (irq < 0) {
-		error = irq;
-		goto out_release;
-	}
+	if (irq < 0)
+		goto failure_indication;
+
 	ndev->irq = irq;
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
@@ -2101,25 +2100,22 @@ static int ravb_probe(struct platform_device *pdev)
 
 	if (chip_id == RCAR_GEN3) {
 		irq = platform_get_irq_byname(pdev, "ch24");
-		if (irq < 0) {
-			error = irq;
-			goto out_release;
-		}
+		if (irq < 0)
+			goto failure_indication;
+
 		priv->emac_irq = irq;
 		for (i = 0; i < NUM_RX_QUEUE; i++) {
 			irq = platform_get_irq_byname(pdev, ravb_rx_irqs[i]);
-			if (irq < 0) {
-				error = irq;
-				goto out_release;
-			}
+			if (irq < 0)
+				goto failure_indication;
+
 			priv->rx_irqs[i] = irq;
 		}
 		for (i = 0; i < NUM_TX_QUEUE; i++) {
 			irq = platform_get_irq_byname(pdev, ravb_tx_irqs[i]);
-			if (irq < 0) {
-				error = irq;
-				goto out_release;
-			}
+			if (irq < 0)
+				goto failure_indication;
+
 			priv->tx_irqs[i] = irq;
 		}
 	}
@@ -2226,6 +2222,10 @@ static int ravb_probe(struct platform_device *pdev)
 	pm_runtime_put(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 	return error;
+
+failure_indication:
+	error = irq;
+	goto out_release;
 }
 
 static int ravb_remove(struct platform_device *pdev)
-- 
2.14.3
