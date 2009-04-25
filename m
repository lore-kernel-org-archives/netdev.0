From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v3 06/13] net: rework fsl_pq_mdio driver to use of_mdio
	infrastructure
Date: Sat, 25 Apr 2009 16:53:07 -0600
Message-ID: <20090425225307.32392.29114.stgit@localhost.localdomain>
References: <20090425224458.32392.31296.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:62952 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbZDYWxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 18:53:09 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1420774rvb.1
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 15:53:09 -0700 (PDT)
In-Reply-To: <20090425224458.32392.31296.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Tested on Freescale MPC8349emitxgp eval board

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Acked-by: Andy Fleming <afleming@freescale.com>
---

 drivers/net/fsl_pq_mdio.c |   51 +++------------------------------------------
 1 files changed, 3 insertions(+), 48 deletions(-)


diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index aa1eb88..b01daa1 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -34,6 +34,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/of.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/io.h>
@@ -154,44 +155,6 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-/* Allocate an array which provides irq #s for each PHY on the given bus */
-static int *create_irq_map(struct device_node *np)
-{
-	int *irqs;
-	int i;
-	struct device_node *child = NULL;
-
-	irqs = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
-
-	if (!irqs)
-		return NULL;
-
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		irqs[i] = PHY_POLL;
-
-	while ((child = of_get_next_child(np, child)) != NULL) {
-		int irq = irq_of_parse_and_map(child, 0);
-		const u32 *id;
-
-		if (irq == NO_IRQ)
-			continue;
-
-		id = of_get_property(child, "reg", NULL);
-
-		if (!id)
-			continue;
-
-		if (*id < PHY_MAX_ADDR && *id >= 0)
-			irqs[*id] = irq;
-		else
-			printk(KERN_WARNING "%s: "
-					"%d is not a valid PHY address\n",
-					np->full_name, *id);
-	}
-
-	return irqs;
-}
-
 void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
 {
 	const u32 *addr;
@@ -315,7 +278,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 
 	new_bus->priv = (void __force *)regs;
 
-	new_bus->irq = create_irq_map(np);
+	new_bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
 
 	if (NULL == new_bus->irq) {
 		err = -ENOMEM;
@@ -384,15 +347,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 
 	out_be32(tbipa, tbiaddr);
 
-	/*
-	 * The TBIPHY-only buses will find PHYs at every address,
-	 * so we mask them all but the TBI
-	 */
-	if (of_device_is_compatible(np, "fsl,gianfar-tbi"))
-		new_bus->phy_mask = ~(1 << tbiaddr);
-
-	err = mdiobus_register(new_bus);
-
+	err = of_mdiobus_register(new_bus, np);
 	if (err) {
 		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
 				new_bus->name);

