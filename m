From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] Revert "net: fsl_pq_mdio: fix non tbi phy access"
Date: Fri, 2 Dec 2011 01:05:48 -0600
Message-ID: <1322809549-32622-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:15340
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751894Ab1LBHGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 02:06:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit c3e072f8a6c5625028531c40ec65f7e301531be2.

The TBI PHY Address must always be set to something sensible.
If not, the value currently in the register may interfere
with MDIO transactions to that address. The architected
solution is to have a TBI node in the device tree, which corresponds
to the desired address (and which should be chosen so that it does
not conflict with other PHYs on the bus). If that node is not there,
it is incorrect to just continue. We must return an error, so that
developers have a chance to realize they've mis-configured their
device trees. A separate patch has been submitted to add such
a node to the device trees for boards which were missing that node.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index f109602..6ff124c 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -356,16 +356,16 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 
 		if (prop)
 			tbiaddr = *prop;
+	}
 
-		if (tbiaddr == -1) {
-			err = -EBUSY;
+	if (tbiaddr == -1) {
+		err = -EBUSY;
 
-			goto err_free_irqs;
-		} else {
-			out_be32(tbipa, tbiaddr);
-		}
+		goto err_free_irqs;
 	}
 
+	out_be32(tbipa, tbiaddr);
+
 	err = of_mdiobus_register(new_bus, np);
 	if (err) {
 		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
-- 
1.7.3.4
