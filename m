From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/2] net: ethernet: cpsw: fix interrupt lookup logic in cpsw_probe()
Date: Tue,  2 Sep 2014 18:44:05 +0200
Message-ID: <1409676245-13897-2-git-send-email-zonque@gmail.com>
References: <1409676245-13897-1-git-send-email-zonque@gmail.com>
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org, mugunthanvnm@ti.com,
	george.cherian@ti.com, Daniel Mack <zonque@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:42154 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856AbaIBQoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:44:16 -0400
Received: by mail-wg0-f45.google.com with SMTP id k14so7067796wgh.28
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 09:44:15 -0700 (PDT)
In-Reply-To: <1409676245-13897-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in cpsw_probe() currently iterates over the available
interrupt resources and requests each of them.  While doing so, it
keeps track of their indices through priv->irqs_table.

However, the code currently only remembers the last interrupt in
a resource, and will leak the others if there is more than one.
This can only happen for board-file driven platforms and not via DT,
however.

Also, there is currently no bounds check, while priv->irqs_table is a
fixed-size array. If we are passed more than 4 resources, we're in
trouble.

This patch introduces a bounds check and changes the way interrupt
indices are kept. Tested on a Beagle Bone Black board only.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index cdbbb58..e747e55 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2233,13 +2233,18 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
 		for (i = res->start; i <= res->end; i++) {
+			if (priv->num_irqs >= ARRAY_SIZE(priv->irqs_table)) {
+				ret = -EINVAL;
+				goto clean_irq_ret;
+			}
+
 			if (request_irq(i, cpsw_interrupt, 0,
 					dev_name(&pdev->dev), priv)) {
 				dev_err(priv->dev, "error attaching irq\n");
 				goto clean_irq_ret;
 			}
-			priv->irqs_table[k] = i;
-			priv->num_irqs = k + 1;
+			priv->irqs_table[priv->num_irqs] = i;
+			priv->num_irqs++;
 		}
 		k++;
 	}
-- 
2.1.0
