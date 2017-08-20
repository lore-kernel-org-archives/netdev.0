From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH v2] net: ibm: emac: Fix some error handling path in 'emac_probe()'
Date: Sun, 20 Aug 2017 06:35:00 +0200
Message-ID: <20170820043500.24864-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: davem@davemloft.net, chunkeey@googlemail.com, jarod@redhat.com,
        ivan@de.ibm.com, ebiggers@google.com, tklauser@distanz.ch,
        tremyfr@gmail.com, robh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:46491 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbdHTEfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 00:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If 'irq_of_parse_and_map()' or 'of_address_to_resource()' fail, 'err' is
known to be 0 at this point.
So return -ENODEV instead in the first case and use 'of_iomap()' instead of
the equivalent 'of_address_to_resource()/ioremap()' combinaison in the 2nd
case.

Doing so, the 'rsrc_regs' field of the 'emac_instance struct' becomes
redundant and is removed.

While at it, turn a 'err != 0' test into an equivalent 'err' to be more
consistent.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
v2: use of_iomap() to simplify code
    remove 'rsrc_regs' field of the 'emac_instance struct'
    update comment
---
 drivers/net/ethernet/ibm/emac/core.c | 12 ++++--------
 drivers/net/ethernet/ibm/emac/core.h |  1 -
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 95135d20458f..7feff2450ed6 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -3032,7 +3032,7 @@ static int emac_probe(struct platform_device *ofdev)
 
 	/* Init various config data based on device-tree */
 	err = emac_init_config(dev);
-	if (err != 0)
+	if (err)
 		goto err_free;
 
 	/* Get interrupts. EMAC irq is mandatory, WOL irq is optional */
@@ -3040,18 +3040,14 @@ static int emac_probe(struct platform_device *ofdev)
 	dev->wol_irq = irq_of_parse_and_map(np, 1);
 	if (!dev->emac_irq) {
 		printk(KERN_ERR "%pOF: Can't map main interrupt\n", np);
+		err = -ENODEV;
 		goto err_free;
 	}
 	ndev->irq = dev->emac_irq;
 
 	/* Map EMAC regs */
-	if (of_address_to_resource(np, 0, &dev->rsrc_regs)) {
-		printk(KERN_ERR "%pOF: Can't get registers address\n", np);
-		goto err_irq_unmap;
-	}
-	// TODO : request_mem_region
-	dev->emacp = ioremap(dev->rsrc_regs.start,
-			     resource_size(&dev->rsrc_regs));
+	// TODO : platform_get_resource() and devm_ioremap_resource()
+	dev->emacp = of_iomap(np, 0);
 	if (dev->emacp == NULL) {
 		printk(KERN_ERR "%pOF: Can't map device registers!\n", np);
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index f10e156641d5..369de2cfb15b 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -167,7 +167,6 @@ struct emac_error_stats {
 
 struct emac_instance {
 	struct net_device		*ndev;
-	struct resource			rsrc_regs;
 	struct emac_regs		__iomem *emacp;
 	struct platform_device		*ofdev;
 	struct device_node		**blist; /* bootlist entry */
-- 
2.11.0
