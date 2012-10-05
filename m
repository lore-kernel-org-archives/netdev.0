From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 11/20 V2] drivers/net/irda/sh_sir.c: fix error return code
Date: Sat,  6 Oct 2012 00:10:49 +0200
Message-ID: <1349475053-11464-1-git-send-email-peter.senna@gmail.com>
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

The function sh_sir_probe() return 0 for success and negative value
for most of its internal tests failures. There are two exceptions
that are error cases going to err_mem_*:. For this two cases, the
function abort its success execution path, but returns non negative
value, making it dificult for a caller function to notice the error.

This patch fixes the error cases that do not return negative values.

This was found by Coccinelle, but the code change was made by hand.
This patch is not robot generated.

A simplified version of the semantic match that finds this problem is
as follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
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

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
Change from V1:
        Updated commit message. See:
        http://www.kernelhub.org/?p=2&msg=139319

 drivers/net/irda/sh_sir.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 7951094..624ac19 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -741,6 +741,7 @@ static int __devinit sh_sir_probe(struct platform_device *pdev)
 	self->clk = clk_get(&pdev->dev, clk_name);
 	if (IS_ERR(self->clk)) {
 		dev_err(&pdev->dev, "cannot get clock \"%s\"\n", clk_name);
+		err = -ENODEV;
 		goto err_mem_3;
 	}
 
@@ -760,8 +761,8 @@ static int __devinit sh_sir_probe(struct platform_device *pdev)
 		goto err_mem_4;
 
 	platform_set_drvdata(pdev, ndev);
-
-	if (request_irq(irq, sh_sir_irq, IRQF_DISABLED, "sh_sir", self)) {
+	err = request_irq(irq, sh_sir_irq, IRQF_DISABLED, "sh_sir", self);
+	if (err) {
 		dev_warn(&pdev->dev, "Unable to attach sh_sir interrupt\n");
 		goto err_mem_4;
 	}
