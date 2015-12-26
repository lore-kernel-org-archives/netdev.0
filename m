From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [PATCH 6/7 v2] drivers: net: cpsw: fix error return code
Date: Sat, 26 Dec 2015 20:12:13 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1512262011220.2070@localhost6.localdomain6>
References: <1451143726-28195-1-git-send-email-Julia.Lawall@lip6.fr> <1451143726-28195-7-git-send-email-Julia.Lawall@lip6.fr> <567ED019.3000407@cogentembedded.com> <alpine.DEB.2.02.1512261838330.2064@localhost6.localdomain6>
 <567ED36A.9000701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <567ED36A.9000701@cogentembedded.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Propagate the return value of platform_get_irq on failure.

A simplified version of the semantic match that finds the two cases where
no error code is returned at all is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
v2: propagate platform_get_irq return value, at all calls

 drivers/net/ethernet/ti/cpsw.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3409e80..34ce7dc 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2427,7 +2427,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	ndev->irq = platform_get_irq(pdev, 1);
 	if (ndev->irq < 0) {
 		dev_err(priv->dev, "error getting irq resource\n");
-		ret = -ENOENT;
+		ret = ndev->irq;
 		goto clean_ale_ret;
 	}
 
@@ -2448,8 +2448,10 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	/* RX IRQ */
 	irq = platform_get_irq(pdev, 1);
-	if (irq < 0)
+	if (irq < 0) {
+		ret = irq;
 		goto clean_ale_ret;
+	}
 
 	priv->irqs_table[0] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
@@ -2461,8 +2463,10 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	/* TX IRQ */
 	irq = platform_get_irq(pdev, 2);
-	if (irq < 0)
+	if (irq < 0) {
+		ret = irq;
 		goto clean_ale_ret;
+	}
 
 	priv->irqs_table[1] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
