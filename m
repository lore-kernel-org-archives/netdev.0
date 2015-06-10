From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/2] net: bcmgenet: handle broken turn-around for specific PHYs
Date: Wed, 10 Jun 2015 12:24:10 -0700
Message-ID: <1433964251-17338-2-git-send-email-f.fainelli@gmail.com>
References: <1433964251-17338-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:36848 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933727AbbFJTZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 15:25:17 -0400
Received: by qgep100 with SMTP id p100so19865362qge.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 12:25:17 -0700 (PDT)
In-Reply-To: <1433964251-17338-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet PHYs/switches such as Broadcom's BCM53125 have a hardware
bug which makes them not release the MDIO line during turn-around time.
This gets flagged by the GENET MDIO controller as a read failure, and we
fail the read transaction.

Check the MDIO bus phy_ignore_ta_mask bitmask for the PHY we are reading
from and if it is listed in this bitmask, ignore the read failure and
proceed with returning the data we read out of the controller.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 420949cc55aa..6bef04e2f735 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -47,7 +47,12 @@ static int bcmgenet_mii_read(struct mii_bus *bus, int phy_id, int location)
 			   HZ / 100);
 	ret = bcmgenet_umac_readl(priv, UMAC_MDIO_CMD);
 
-	if (ret & MDIO_READ_FAIL)
+	/* Some broken devices are known not to release the line during
+	 * turn-around, e.g: Broadcom BCM53125 external switches, so check for
+	 * that condition here and ignore the MDIO controller read failure
+	 * indication.
+	 */
+	if (!(bus->phy_ignore_ta_mask & 1 << phy_id) && (ret & MDIO_READ_FAIL))
 		return -EIO;
 
 	return ret & 0xffff;
-- 
2.1.0
