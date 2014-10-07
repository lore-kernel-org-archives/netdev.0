From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net v2 2/8] net/fsl_pq_mdio: Use ioread/iowrite32be() portable accessors
Date: Tue, 7 Oct 2014 10:44:29 +0300
Message-ID: <1412667875-18225-3-git-send-email-claudiu.manoil@freescale.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.169.139] ([65.55.169.139]:31859 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752870AbaJGHrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:47:10 -0400
In-Reply-To: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in_be32()/out_be32() are not defined by ARM.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2 - none

 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 32136f0..a422838 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -107,14 +107,14 @@ static int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	u32 status;
 
 	/* Set the PHY address and the register address we want to write */
-	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
+	iowrite32be((mii_id << 8) | regnum, &regs->miimadd);
 
 	/* Write out the value we want */
-	out_be32(&regs->miimcon, value);
+	iowrite32be(value, &regs->miimcon);
 
 	/* Wait for the transaction to finish */
-	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
-				    MII_TIMEOUT, 0);
+	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
+				    MIIMIND_BUSY), MII_TIMEOUT, 0);
 
 	return status ? 0 : -ETIMEDOUT;
 }
@@ -137,21 +137,21 @@ static int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	u16 value;
 
 	/* Set the PHY address and the register address we want to read */
-	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
+	iowrite32be((mii_id << 8) | regnum, &regs->miimadd);
 
 	/* Clear miimcom, and then initiate a read */
-	out_be32(&regs->miimcom, 0);
-	out_be32(&regs->miimcom, MII_READ_COMMAND);
+	iowrite32be(0, &regs->miimcom);
+	iowrite32be(MII_READ_COMMAND, &regs->miimcom);
 
 	/* Wait for the transaction to finish, normally less than 100us */
-	status = spin_event_timeout(!(in_be32(&regs->miimind) &
+	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
 				    (MIIMIND_NOTVALID | MIIMIND_BUSY)),
 				    MII_TIMEOUT, 0);
 	if (!status)
 		return -ETIMEDOUT;
 
 	/* Grab the value of the register from miimstat */
-	value = in_be32(&regs->miimstat);
+	value = ioread32be(&regs->miimstat);
 
 	dev_dbg(&bus->dev, "read %04x from address %x/%x\n", value, mii_id, regnum);
 	return value;
@@ -167,14 +167,14 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	mutex_lock(&bus->mdio_lock);
 
 	/* Reset the management interface */
-	out_be32(&regs->miimcfg, MIIMCFG_RESET);
+	iowrite32be(MIIMCFG_RESET, &regs->miimcfg);
 
 	/* Setup the MII Mgmt clock speed */
-	out_be32(&regs->miimcfg, MIIMCFG_INIT_VALUE);
+	iowrite32be(MIIMCFG_INIT_VALUE, &regs->miimcfg);
 
 	/* Wait until the bus is free */
-	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
-				    MII_TIMEOUT, 0);
+	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
+				    MIIMIND_BUSY), MII_TIMEOUT, 0);
 
 	mutex_unlock(&bus->mdio_lock);
 
@@ -435,7 +435,7 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 
 			tbipa = data->get_tbipa(priv->map);
 
-			out_be32(tbipa, be32_to_cpup(prop));
+			iowrite32be(be32_to_cpup(prop), tbipa);
 		}
 	}
 
-- 
1.7.11.7
