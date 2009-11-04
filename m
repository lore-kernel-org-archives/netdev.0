From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/3] fsl_pq_mdio: Fix compiler/sparse warnings (part 2)
Date: Thu, 5 Nov 2009 01:52:57 +0300
Message-ID: <20091104225257.GB29537@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:11190 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932982AbZKDWwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 17:52:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes following warnings:

fsl_pq_mdio.c:112:38: warning: cast adds address space to expression (<asn:2>)
fsl_pq_mdio.c:124:38: warning: cast adds address space to expression (<asn:2>)
fsl_pq_mdio.c:133:38: warning: cast adds address space to expression (<asn:2>)
fsl_pq_mdio.c:414:11: warning: cast adds address space to expression (<asn:2>)

Instead of adding __force all over the place, introduce convenient
fsl_pq_mdio_get_regs() call that does the ugly casting just once.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/fsl_pq_mdio.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index fb8c8d9..b2ca596 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -103,13 +103,18 @@ int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
 	return value;
 }
 
+static struct fsl_pq_mdio __iomem *fsl_pq_mdio_get_regs(struct mii_bus *bus)
+{
+	return (void __iomem __force *)bus->priv;
+}
+
 /*
  * Write value to the PHY at mii_id at register regnum,
  * on the bus, waiting until the write is done before returning.
  */
 int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
 {
-	struct fsl_pq_mdio __iomem *regs = (void __iomem *)bus->priv;
+	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
 	/* Write to the local MII regs */
 	return(fsl_pq_local_mdio_write(regs, mii_id, regnum, value));
@@ -121,7 +126,7 @@ int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
  */
 int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
-	struct fsl_pq_mdio __iomem *regs = (void __iomem *)bus->priv;
+	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
 	/* Read the local MII regs */
 	return(fsl_pq_local_mdio_read(regs, mii_id, regnum));
@@ -130,7 +135,7 @@ int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 /* Reset the MIIM registers, and wait for the bus to free */
 static int fsl_pq_mdio_reset(struct mii_bus *bus)
 {
-	struct fsl_pq_mdio __iomem *regs = (void __iomem *)bus->priv;
+	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 	int timeout = PHY_INIT_TIMEOUT;
 
 	mutex_lock(&bus->mdio_lock);
@@ -404,7 +409,7 @@ static int fsl_pq_mdio_remove(struct of_device *ofdev)
 
 	dev_set_drvdata(device, NULL);
 
-	iounmap((void __iomem *)bus->priv);
+	iounmap(fsl_pq_mdio_get_regs(bus));
 	bus->priv = NULL;
 	mdiobus_free(bus);
 
-- 
1.6.3.3

