From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 14/20] drivers/net/ethernet/amd/au1000_eth.c: fix error return code
Date: Wed,  3 Oct 2012 18:18:07 +0200
Message-ID: <1349281090-10013-17-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, danny.kukawka@bisect.de,
	mcuos.com@gmail.com, joe@perches.com, florian@openwrt.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/ethernet/amd/au1000_eth.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 397596b..f195acf 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1174,8 +1174,10 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		pdev->name, aup->mac_id);
 	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	if (aup->mii_bus->irq == NULL)
+	if (aup->mii_bus->irq == NULL) {
+		err = -ENOMEM;
 		goto err_out;
+	}
 
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
 		aup->mii_bus->irq[i] = PHY_POLL;
@@ -1190,7 +1192,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		goto err_mdiobus_reg;
 	}
 
-	if (au1000_mii_probe(dev) != 0)
+	err = au1000_mii_probe(dev);
+	if (err != 0)
 		goto err_out;
 
 	pDBfree = NULL;
@@ -1205,6 +1208,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 	aup->pDBfree = pDBfree;
 
+	err = -ENODEV;
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		pDB = au1000_GetFreeDB(aup);
 		if (!pDB)
@@ -1213,6 +1217,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		aup->rx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
 		aup->rx_db_inuse[i] = pDB;
 	}
+
+	err = -ENODEV;
 	for (i = 0; i < NUM_TX_DMA; i++) {
 		pDB = au1000_GetFreeDB(aup);
 		if (!pDB)
