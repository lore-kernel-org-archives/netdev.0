From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] net: ibm: emac: Fix some error handling path in 'emac_probe()'
Date: Sat, 19 Aug 2017 01:07:57 +0200
Message-ID: <20170818230757.10934-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: davem@davemloft.net, chunkeey@googlemail.com, jarod@redhat.com,
        ivan@de.ibm.com, ebiggers@google.com, tklauser@distanz.ch,
        tremyfr@gmail.com, robh@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If 'irq_of_parse_and_map()' or 'of_address_to_resource()' fail, 'err' is
known to be 0 at this point.
So return -ENODEV instead in the first case and propagate the error
returned by 'of_address_to_resource()' in the 2nd case.

While at it, turn a 'err != 0' test into an equivalent 'err' to be more
consistent.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/ibm/emac/core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 95135d20458f..1af56a97fb47 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -3032,7 +3032,7 @@ static int emac_probe(struct platform_device *ofdev)
 
 	/* Init various config data based on device-tree */
 	err = emac_init_config(dev);
-	if (err != 0)
+	if (err)
 		goto err_free;
 
 	/* Get interrupts. EMAC irq is mandatory, WOL irq is optional */
@@ -3040,12 +3040,14 @@ static int emac_probe(struct platform_device *ofdev)
 	dev->wol_irq = irq_of_parse_and_map(np, 1);
 	if (!dev->emac_irq) {
 		printk(KERN_ERR "%pOF: Can't map main interrupt\n", np);
+		err = -ENODEV;
 		goto err_free;
 	}
 	ndev->irq = dev->emac_irq;
 
 	/* Map EMAC regs */
-	if (of_address_to_resource(np, 0, &dev->rsrc_regs)) {
+	err = of_address_to_resource(np, 0, &dev->rsrc_regs);
+	if (err) {
 		printk(KERN_ERR "%pOF: Can't get registers address\n", np);
 		goto err_irq_unmap;
 	}
-- 
2.11.0
