From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 7/8] ethoc: rework mdio read/write
Date: Wed, 24 Nov 2010 14:40:57 +0100
Message-ID: <1290606058-26703-8-git-send-email-jonas@southpole.se>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38153 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369Ab0KXOCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:49 -0500
In-Reply-To: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MDIO read and write were checking whether a timeout had expired to determine
whether to recheck the result of the MDIO operation.  Under heavy CPU usage,
however, it was possible for the timeout to expire before the routine got
around to be able to check a second time even, thus erroneousy returning an
-EBUSY.

This patch changes the the MDIO IO routines to try up to five times to complete
the operation before giving up, thus lessening the dependency on CPU load.

This resolves a problem whereby a ping flood would keep the CPU so busy that
the above problem would manifest itself; the MDIO command to check link status
would fail and the interface would erroneously be shut down.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 70ca2f3..4f7c9ad 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -616,13 +616,13 @@ static int ethoc_poll(struct napi_struct *napi, int budget)
 
 static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
 {
-	unsigned long timeout = jiffies + ETHOC_MII_TIMEOUT;
 	struct ethoc *priv = bus->priv;
+	int i;
 
 	ethoc_write(priv, MIIADDRESS, MIIADDRESS_ADDR(phy, reg));
 	ethoc_write(priv, MIICOMMAND, MIICOMMAND_READ);
 
-	while (time_before(jiffies, timeout)) {
+	for (i=0; i < 5; i++) {
 		u32 status = ethoc_read(priv, MIISTATUS);
 		if (!(status & MIISTATUS_BUSY)) {
 			u32 data = ethoc_read(priv, MIIRX_DATA);
@@ -630,8 +630,7 @@ static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
 			ethoc_write(priv, MIICOMMAND, 0);
 			return data;
 		}
-
-		schedule();
+		usleep_range(100,200);
 	}
 
 	return -EBUSY;
@@ -639,22 +638,21 @@ static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
 
 static int ethoc_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 {
-	unsigned long timeout = jiffies + ETHOC_MII_TIMEOUT;
 	struct ethoc *priv = bus->priv;
+	int i;
 
 	ethoc_write(priv, MIIADDRESS, MIIADDRESS_ADDR(phy, reg));
 	ethoc_write(priv, MIITX_DATA, val);
 	ethoc_write(priv, MIICOMMAND, MIICOMMAND_WRITE);
 
-	while (time_before(jiffies, timeout)) {
+	for (i=0; i < 5; i++) {
 		u32 stat = ethoc_read(priv, MIISTATUS);
 		if (!(stat & MIISTATUS_BUSY)) {
 			/* reset MII command register */
 			ethoc_write(priv, MIICOMMAND, 0);
 			return 0;
 		}
-
-		schedule();
+		usleep_range(100,200);
 	}
 
 	return -EBUSY;
-- 
1.7.1

