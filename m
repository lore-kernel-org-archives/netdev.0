From: Guennadi Liakhovetski <lg@denx.de>
Subject: [PATCH] smc911x: Add support for LAN921{5,7,8} chips from SMSC
Date: Sat, 11 Oct 2008 23:13:30 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810112311030.4965@axis700.grange>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
 <87vdx5gjzo.fsf@macbook.be.48ers.dk> <Pine.LNX.4.64.0810110125540.10196@axis700.grange>
 <871vynr3yb.fsf@macbook.be.48ers.dk> <Pine.LNX.4.64.0810111057030.4425@axis700.grange>
 <87k5cfoz7b.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:41787 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753851AbYJKVNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2008 17:13:30 -0400
In-Reply-To: <87k5cfoz7b.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LAN92{5,7,8} chips from SMSC are register compatible with LAN911{5,6,7,8}
controllers, and only add support for HP Auto-MDIX. LAN9218 doesn't have
an external MII interface. Also fixes a couple of minor style issues.

Signed-off-by: Guennadi Liakhovetski <lg@denx.de>
---
against 2.6.27

 drivers/net/smc911x.c |   15 +++++++--------
 drivers/net/smc911x.h |   14 ++++++++++----
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index dbc51e9..428b852 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -685,8 +685,10 @@ static void smc911x_phy_detect(struct net_device *dev)
 	 * PHY#1 to PHY#31, and then PHY#0 last.
 	 */
 	switch(lp->version) {
-		case 0x115:
-		case 0x117:
+		case CHIP_9115:
+		case CHIP_9117:
+		case CHIP_9215:
+		case CHIP_9217:
 			cfg = SMC_GET_HW_CFG(lp);
 			if (cfg & HW_CFG_EXT_PHY_DET_) {
 				cfg &= ~HW_CFG_PHY_CLK_SEL_;
@@ -995,7 +997,7 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 
 	smc911x_phy_check_media(dev, 0);
 	/* read to clear status bits */
-	SMC_GET_PHY_INT_SRC(lp, phyaddr,status);
+	SMC_GET_PHY_INT_SRC(lp, phyaddr, status);
 	DBG(SMC_DEBUG_MISC, "%s: PHY interrupt status 0x%04x\n",
 		dev->name, status & 0xffff);
 	DBG(SMC_DEBUG_MISC, "%s: AFC_CFG 0x%08x\n",
@@ -1033,7 +1035,6 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	/* set a timeout value, so I don't stay here forever */
 	timeout = 8;
 
-
 	do {
 		status = SMC_GET_INT(lp);
 
@@ -1172,12 +1173,10 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	/* restore mask state */
 	SMC_SET_INT_EN(lp, mask);
 
-	DBG(SMC_DEBUG_MISC, "%s: Interrupt done (%d loops)\n",
-		dev->name, 8-timeout);
-
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	DBG(3, "%s: Interrupt done (%d loops)\n", dev->name, 8-timeout);
+	DBG(SMC_DEBUG_MISC, "%s: Interrupt done (%d loops)\n",
+		dev->name, 8-timeout);
 
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 2abfc28..bf6240f 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -666,10 +666,13 @@ smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
 #define LAN911X_INTERNAL_PHY_ID		(0x0007C000)
 
 /* Chip ID values */
-#define CHIP_9115	0x115
-#define CHIP_9116	0x116
-#define CHIP_9117	0x117
-#define CHIP_9118	0x118
+#define CHIP_9115	0x0115
+#define CHIP_9116	0x0116
+#define CHIP_9117	0x0117
+#define CHIP_9118	0x0118
+#define CHIP_9215	0x115A
+#define CHIP_9217	0x117A
+#define CHIP_9218	0x118A
 
 struct chip_id {
 	u16 id;
@@ -681,6 +684,9 @@ static const struct chip_id chip_ids[] =  {
 	{ CHIP_9116, "LAN9116" },
 	{ CHIP_9117, "LAN9117" },
 	{ CHIP_9118, "LAN9118" },
+	{ CHIP_9215, "LAN9215" },
+	{ CHIP_9217, "LAN9217" },
+	{ CHIP_9218, "LAN9218" },
 	{ 0, NULL },
 };
 
-- 
1.5.4

