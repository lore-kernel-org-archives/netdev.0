From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: [PATCH 2/2] net/fsl_pq_mdio: fix computed address for the TBI register
Date: Fri,  9 Oct 2015 17:15:08 +0200
Message-ID: <1444403708-16576-2-git-send-email-gerlando.falauto@keymile.com>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
 <1444403708-16576-1-git-send-email-gerlando.falauto@keymile.com>
Cc: ogabbay@advaoptical.com, bigeasy@linutronix.de,
	Gerlando Falauto <gerlando.falauto@keymile.com>,
	Timur Tabi <timur@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>
To: netdev@vger.kernel.org, timur@tabi.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:33754 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbbJIPWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 11:22:01 -0400
In-Reply-To: <1444403708-16576-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit afae5ad78b342f401c28b0bb1adb3cd494cb125a
  "net/fsl_pq_mdio: streamline probing of MDIO nodes"

added support for different types of MDIO devices:
1) Gianfar MDIO nodes that only map the MII registers
2) Gianfar MDIO nodes that map the full MDIO register set
3) eTSEC2 MDIO nodes (which map the full MDIO register set)
4) QE MDIO nodes (which map only the MII registers)

However, the implementation for types 1 and 4 would mistakenly assume
a mapping of the full MDIO register set, thereby computing the address
for the TBI register starting from the containing structure.
The TBI register would therefore be accessed at a wrong (much bigger)
address, not giving the expected result at all.
This patch restores the correct behavior we had prior to the above one.

The consequences of this bug are apparent when trying to access a PHY
with the same address as the value contained in the initial value of
the TBI register (normally 0); in that case you'll get answers from the
internal TBI device (even though MDIO/MDC pins are actually *also*
toggling on the physical bus!).
Beware that you also need to add a fake tbi node to your device tree
with an unused address.

Notice how this fix is related to commit
220669495bf8b68130a8218607147c7b74c28d2b
  "powerpc: Add TBI PHY node to first MDIO bus"

which fixed the behavior in kernel 3.3, which was later broken by the
above commit on kernel 3.7.

Change-Id: If78651268435aaed1f07ebdef374c46c0a528429
Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
Cc: Timur Tabi <timur@freescale.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Andy Fleming <afleming@freescale.com>
Cc: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 4618011..9e12e02 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -198,11 +198,13 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 
 #if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
 /*
+ * Return the TBIPA address, starting from the address
+ * of the mapped GFAR MDIO registers (struct gfar)
  * This is mildly evil, but so is our hardware for doing this.
  * Also, we have to cast back to struct gfar because of
  * definition weirdness done in gianfar.h.
  */
-static uint32_t __iomem *get_gfar_tbipa(void __iomem *p)
+static uint32_t __iomem *get_gfar_tbipa_from_mdio(void __iomem *p)
 {
 	struct gfar __iomem *enet_regs = p;
 
@@ -210,6 +212,15 @@ static uint32_t __iomem *get_gfar_tbipa(void __iomem *p)
 }
 
 /*
+ * Return the TBIPA address, starting from the address
+ * of the mapped GFAR MII registers (gfar_mii_regs[] within struct gfar)
+ */
+static uint32_t __iomem *get_gfar_tbipa_from_mii(void __iomem *p)
+{
+	return get_gfar_tbipa_from_mdio(container_of(p, struct gfar, gfar_mii_regs));
+}
+
+/*
  * Return the TBIPAR address for an eTSEC2 node
  */
 static uint32_t __iomem *get_etsec_tbipa(void __iomem *p)
@@ -220,11 +231,12 @@ static uint32_t __iomem *get_etsec_tbipa(void __iomem *p)
 
 #if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
 /*
- * Return the TBIPAR address for a QE MDIO node
+ * Return the TBIPAR address for a QE MDIO node, starting from the address
+ * of the mapped MII registers (struct fsl_pq_mii)
  */
 static uint32_t __iomem *get_ucc_tbipa(void __iomem *p)
 {
-	struct fsl_pq_mdio __iomem *mdio = p;
+	struct fsl_pq_mdio __iomem *mdio = container_of(p, struct fsl_pq_mdio, mii);
 
 	return &mdio->utbipar;
 }
@@ -300,14 +312,14 @@ static const struct of_device_id fsl_pq_mdio_match[] = {
 		.compatible = "fsl,gianfar-tbi",
 		.data = &(struct fsl_pq_mdio_data) {
 			.mii_offset = 0,
-			.get_tbipa = get_gfar_tbipa,
+			.get_tbipa = get_gfar_tbipa_from_mii,
 		},
 	},
 	{
 		.compatible = "fsl,gianfar-mdio",
 		.data = &(struct fsl_pq_mdio_data) {
 			.mii_offset = 0,
-			.get_tbipa = get_gfar_tbipa,
+			.get_tbipa = get_gfar_tbipa_from_mii,
 		},
 	},
 	{
@@ -315,7 +327,7 @@ static const struct of_device_id fsl_pq_mdio_match[] = {
 		.compatible = "gianfar",
 		.data = &(struct fsl_pq_mdio_data) {
 			.mii_offset = offsetof(struct fsl_pq_mdio, mii),
-			.get_tbipa = get_gfar_tbipa,
+			.get_tbipa = get_gfar_tbipa_from_mdio,
 		},
 	},
 	{
-- 
1.8.0.1
