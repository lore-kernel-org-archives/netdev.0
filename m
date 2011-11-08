From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] net: fsl_pq_mdio: fix oops when using uninitialized mutex
Date: Tue,  8 Nov 2011 09:23:44 +0200
Message-ID: <59b050a97a9b5382918b66f2850a80c86e52f409.1320736936.git.baruch@tkos.co.il>
Cc: linuxppc-dev@lists.ozlabs.org, Baruch Siach <baruch@tkos.co.il>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:39648 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592Ab1KHHYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 02:24:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The get_phy_id() routine (called via fsl_pq_mdio_find_free()) tries to acquire
the mdio_lock mutex which is only initialized when of_mdiobus_register() gets
called later. This causes the following oops:

Unable to handle kernel paging request for data at address 0x00000000
Faulting instruction address: 0xc02eda74
Oops: Kernel access of bad area, sig: 11 [#1]
P1020 RDB
NIP: c02eda74 LR: c01b3aa4 CTR: 00000007
REGS: cf039d70 TRAP: 0300   Not tainted  (3.2.0-rc1-00004-gdc9d867-dirty)
MSR: 00029000 <EE,ME,CE>  CR: 24024028  XER: 00000000
DEAR: 00000000, ESR: 00800000
TASK = cf034000[1] 'swapper' THREAD: cf038000
GPR00: cf039e28 cf039e20 cf034000 cf368228 00000020 00000002 ffeb02ad 000000d0
GPR08: 00001083 00000000 d1080000 cf039e90 00000000 100ae780 00000000 00000000
GPR16: c0000900 00000012 0fffffff 00ffa000 00000015 00000001 c0470000 00000000
GPR24: 00000000 00000000 c03b4e89 d1072030 cf034000 00000020 cf36822c cf368228
NIP [c02eda74] __mutex_lock_slowpath+0x30/0xb0
LR [c01b3aa4] mdiobus_read+0x38/0x68
Call Trace:
[cf039e20] [ffeb0000] 0xffeb0000 (unreliable)
[cf039e50] [c01b3aa4] mdiobus_read+0x38/0x68
[cf039e70] [c01b2af0] get_phy_id+0x24/0x70
[cf039e90] [c01b4128] fsl_pq_mdio_probe+0x364/0x414
[cf039ec0] [c0195050] platform_drv_probe+0x20/0x30
[cf039ed0] [c0193a70] driver_probe_device+0xc8/0x170
[cf039ef0] [c0193b88] __driver_attach+0x70/0x98
[cf039f10] [c019294c] bus_for_each_dev+0x60/0x90
[cf039f40] [c0193cc8] driver_attach+0x24/0x34
[cf039f50] [c0192f88] bus_add_driver+0xbc/0x230
[cf039f70] [c0194594] driver_register+0xb8/0x13c
[cf039f90] [c0195b40] platform_driver_register+0x6c/0x7c
[cf039fa0] [c03e433c] fsl_pq_mdio_init+0x18/0x28
[cf039fb0] [c03ce824] do_one_initcall+0xdc/0x1b4
[cf039fe0] [c03ce984] kernel_init+0x88/0x118
[cf039ff0] [c000bd5c] kernel_thread+0x4c/0x68
Instruction dump:
9421ffd0 7c0802a6 81230008 bf61001c 3bc30004 7c7f1b78 90010034 38010008
7c5c1378 90030008 93c10008 9121000c
 3800ffff 90410010 7d201828

Fix this by moving the of_mdiobus_register() call earlier.

Cc: Andy Fleming <afleming@freescale.com>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 52f4e8a..e17fd2f 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -385,6 +385,13 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 			tbiaddr = *prop;
 	}
 
+	err = of_mdiobus_register(new_bus, np);
+	if (err) {
+		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
+				new_bus->name);
+		goto err_free_irqs;
+	}
+
 	if (tbiaddr == -1) {
 		out_be32(tbipa, 0);
 
@@ -403,13 +410,6 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 
 	out_be32(tbipa, tbiaddr);
 
-	err = of_mdiobus_register(new_bus, np);
-	if (err) {
-		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
-				new_bus->name);
-		goto err_free_irqs;
-	}
-
 	return 0;
 
 err_free_irqs:
-- 
1.7.7.1
