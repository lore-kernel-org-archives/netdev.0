From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/5] drivers/net/ethernet/freescale/fs_enet: fix error return code
Date: Tue, 14 Aug 2012 14:58:33 +0200
Message-ID: <1344949115-13266-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1344949115-13266-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344949115-13266-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert a 0 error return code to a negative one, as returned elsewhere in the
function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret;
expression e,e1,e2,e3,e4,x;
@@

(
if (\(ret != 0\|ret < 0\) || ...) { ... return ...; }
|
ret = 0
)
... when != ret = e1
*x = \(kmalloc\|kzalloc\|kcalloc\|devm_kzalloc\|ioremap\|ioremap_nocache\|devm_ioremap\|devm_ioremap_nocache\)(...);
... when != x = e2
    when != ret = e3
*if (x == NULL || ...)
{
  ... when != ret = e4
*  return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c |    4 +++-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c     |    8 ++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 0f2d1a7..1514533 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -174,8 +174,10 @@ static int __devinit fs_enet_mdio_probe(struct platform_device *ofdev)
 
 	new_bus->phy_mask = ~0;
 	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (!new_bus->irq)
+	if (!new_bus->irq) {
+		ret = -ENOMEM;
 		goto out_unmap_regs;
+	}
 
 	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index 55bb867..cdf702a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -137,8 +137,10 @@ static int __devinit fs_enet_mdio_probe(struct platform_device *ofdev)
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
 	fec->fecp = ioremap(res.start, resource_size(&res));
-	if (!fec->fecp)
+	if (!fec->fecp) {
+		ret = -ENOMEM;
 		goto out_fec;
+	}
 
 	if (get_bus_freq) {
 		clock = get_bus_freq(ofdev->dev.of_node);
@@ -172,8 +174,10 @@ static int __devinit fs_enet_mdio_probe(struct platform_device *ofdev)
 
 	new_bus->phy_mask = ~0;
 	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (!new_bus->irq)
+	if (!new_bus->irq) {
+		ret = -ENOMEM;
 		goto out_unmap_regs;
+	}
 
 	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
