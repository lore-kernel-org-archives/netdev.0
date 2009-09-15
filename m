From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH] mlx4: Fix access to freed memory
Date: Tue, 15 Sep 2009 14:52:40 +0400
Message-ID: <200909151452.41206.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Roland Dreier <rolandd@cisco.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3886 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950AbZIOLiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 07:38:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

catas_reset() uses pointer to mlx4_priv, but mlx4_priv is not valid after
call mlx4_restart_one().

Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

diff --git a/drivers/net/mlx4/catas.c b/drivers/net/mlx4/catas.c
index aa9674b..f599294 100644
--- a/drivers/net/mlx4/catas.c
+++ b/drivers/net/mlx4/catas.c
@@ -96,12 +96,17 @@ static void catas_reset(struct work_struct *work)
 	spin_unlock_irq(&catas_lock);
 
 	list_for_each_entry_safe(priv, tmppriv, &tlist, catas_err.list) {
+		struct pci_dev *pdev = priv->dev.pdev;
+
 		ret = mlx4_restart_one(priv->dev.pdev);
-		dev = &priv->dev;
+		/* 'priv' now is not valid */
 		if (ret)
-			mlx4_err(dev, "Reset failed (%d)\n", ret);
-		else
+			printk(KERN_ERR "mlx4 %s: Reset failed (%d)\n",
+				pci_name(pdev), ret);
+		else {
+			dev  = pci_get_drvdata(pdev);
 			mlx4_dbg(dev, "Reset succeeded\n");
+		}
 	}
 }
 
