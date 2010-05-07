From: Bryan Wu <bryan.wu@canonical.com>
Subject: [PATCH 1/2] netdev/fec: fix performance impact from mdio poll operation
Date: Fri,  7 May 2010 10:27:18 +0800
Message-ID: <1273199239-11057-2-git-send-email-bryan.wu@canonical.com>
References: <1273199239-11057-1-git-send-email-bryan.wu@canonical.com>
To: davem@davemloft.net, Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Amit Kucheria <amit.kucheria@canonical.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:51864 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab0EGCaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 22:30:19 -0400
In-Reply-To: <1273199239-11057-1-git-send-email-bryan.wu@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BugLink: http://bugs.launchpad.net/bugs/546649
BugLink: http://bugs.launchpad.net/bugs/457878

After introducing phylib supporting, users experienced performace drop. That is
because of the mdio polling operation of phylib. Use msleep to replace the busy
waiting cpu_relax() and remove the warning message.

Signed-off-by: Bryan Wu <bryan.wu@canonical.com>
Acked-by: Andy Whitcroft <apw@canonical.com>
---
 drivers/net/fec.c |   45 +++++++++++++++++++++------------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 2b1651a..9c58f6b 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -203,7 +203,7 @@ static void fec_stop(struct net_device *dev);
 #define FEC_MMFR_TA		(2 << 16)
 #define FEC_MMFR_DATA(v)	(v & 0xffff)
 
-#define FEC_MII_TIMEOUT		10000
+#define FEC_MII_TIMEOUT		10
 
 /* Transmitter timeout */
 #define TX_TIMEOUT (2 * HZ)
@@ -611,13 +611,29 @@ spin_unlock:
 /*
  * NOTE: a MII transaction is during around 25 us, so polling it...
  */
-static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int fec_enet_mdio_poll(struct fec_enet_private *fep)
 {
-	struct fec_enet_private *fep = bus->priv;
 	int timeout = FEC_MII_TIMEOUT;
 
 	fep->mii_timeout = 0;
 
+	/* wait for end of transfer */
+	while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) {
+		msleep(1);
+		if (timeout-- < 0) {
+			fep->mii_timeout = 1;
+			break;
+		}
+	}
+
+	return 0;
+}
+
+static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct fec_enet_private *fep = bus->priv;
+
+
 	/* clear MII end of transfer bit*/
 	writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
 
@@ -626,15 +642,7 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 		FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) |
 		FEC_MMFR_TA, fep->hwp + FEC_MII_DATA);
 
-	/* wait for end of transfer */
-	while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) {
-		cpu_relax();
-		if (timeout-- < 0) {
-			fep->mii_timeout = 1;
-			printk(KERN_ERR "FEC: MDIO read timeout\n");
-			return -ETIMEDOUT;
-		}
-	}
+	fec_enet_mdio_poll(fep);
 
 	/* return value */
 	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
@@ -644,9 +652,6 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 			   u16 value)
 {
 	struct fec_enet_private *fep = bus->priv;
-	int timeout = FEC_MII_TIMEOUT;
-
-	fep->mii_timeout = 0;
 
 	/* clear MII end of transfer bit*/
 	writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
@@ -657,15 +662,7 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 		FEC_MMFR_TA | FEC_MMFR_DATA(value),
 		fep->hwp + FEC_MII_DATA);
 
-	/* wait for end of transfer */
-	while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) {
-		cpu_relax();
-		if (timeout-- < 0) {
-			fep->mii_timeout = 1;
-			printk(KERN_ERR "FEC: MDIO write timeout\n");
-			return -ETIMEDOUT;
-		}
-	}
+	fec_enet_mdio_poll(fep);
 
 	return 0;
 }
-- 
1.7.0.1

