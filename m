From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 1/3] fsl_pq_mdio: Fix compiler/sparse warnings (part 1)
Date: Thu, 5 Nov 2009 01:52:56 +0300
Message-ID: <20091104225256.GA29537@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:11184 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932781AbZKDWww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 17:52:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1d2397d742b7a2b39b2f09dd9da3b9d1463f55e9 ("fsl_pq_mdio: Add
Suport for etsec2.0 devices") introduced the following warnings:

  CHECK   fsl_pq_mdio.c
fsl_pq_mdio.c:287:22: warning: incorrect type in initializer (different base types)
fsl_pq_mdio.c:287:22:    expected unknown type 11 const *__mptr
fsl_pq_mdio.c:287:22:    got unsigned long long [unsigned] [assigned] [usertype] addr
fsl_pq_mdio.c:287:19: warning: incorrect type in assignment (different base types)
fsl_pq_mdio.c:287:19:    expected unsigned long long [unsigned] [usertype] ioremap_miimcfg
fsl_pq_mdio.c:287:19:    got struct fsl_pq_mdio *<noident>
  CC      fsl_pq_mdio.o
fsl_pq_mdio.c: In function 'fsl_pq_mdio_probe':
fsl_pq_mdio.c:287: warning: initialization makes pointer from integer without a cast
fsl_pq_mdio.c:287: warning: assignment makes integer from pointer without a cast

These warnings are not easy to fix without ugly __force casts. So,
instead of introducing the casts, rework the code to substitute an
offset from an already mapped area. This makes the code a lot simpler
and less duplicated.

Plus, from now on we don't actually map reserved registers on
non-etsec2.0 devices, so we have more chances to catch programming
errors.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/fsl_pq_mdio.c |   31 ++++++++++++-------------------
 1 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index 4065b7c..fb8c8d9 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -262,10 +262,11 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	struct device_node *np = ofdev->node;
 	struct device_node *tbi;
 	struct fsl_pq_mdio __iomem *regs = NULL;
+	void __iomem *map;
 	u32 __iomem *tbipa;
 	struct mii_bus *new_bus;
 	int tbiaddr = -1;
-	u64 addr = 0, size = 0, ioremap_miimcfg = 0;
+	u64 addr = 0, size = 0;
 	int err = 0;
 
 	new_bus = mdiobus_alloc();
@@ -279,28 +280,20 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	fsl_pq_mdio_bus_name(new_bus->id, np);
 
 	/* Set the PHY base address */
-	if (of_device_is_compatible(np,"fsl,gianfar-mdio") ||
-		of_device_is_compatible(np, "fsl,gianfar-tbi") ||
-		of_device_is_compatible(np, "fsl,ucc-mdio") ||
-		of_device_is_compatible(np,"ucc_geth_phy" )) {
-		addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
-		ioremap_miimcfg =  container_of(addr, struct fsl_pq_mdio, miimcfg);
-		regs = ioremap(ioremap_miimcfg, size +
-				offsetof(struct fsl_pq_mdio, miimcfg));
-	} else if (of_device_is_compatible(np,"fsl,etsec2-mdio") ||
-			of_device_is_compatible(np, "fsl,etsec2-tbi")) {
-		addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
-		regs = ioremap(addr, size);
-	} else {
-		err = -EINVAL;
-		goto err_free_bus;
-	}
-
-	if (NULL == regs) {
+	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
+	map = ioremap(addr, size);
+	if (!map) {
 		err = -ENOMEM;
 		goto err_free_bus;
 	}
 
+	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
+			of_device_is_compatible(np, "fsl,gianfar-tbi") ||
+			of_device_is_compatible(np, "fsl,ucc-mdio") ||
+			of_device_is_compatible(np, "ucc_geth_phy"))
+		map -= offsetof(struct fsl_pq_mdio, miimcfg);
+	regs = map;
+
 	new_bus->priv = (void __force *)regs;
 
 	new_bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
-- 
1.6.3.3

