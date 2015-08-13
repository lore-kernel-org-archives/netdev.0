From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net] gianfar: Restore link state settings after MAC reset
Date: Thu, 13 Aug 2015 16:50:37 +0300
Message-ID: <1439473837-30442-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0112.outbound.protection.outlook.com ([207.46.100.112]:6109
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751820AbbHMNwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 09:52:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some MAC registers that need to be kept in sync
with the link state parameters, see adjust_link().
However, after a MAC soft reset default values for
these registers are assumed.  In some cases (excepting
if down/ if up for example) adjust_link() does not see
that these values were reset to default because the
priv->old* link parameters were left unchanged.
So, reset the priv->old* link params as well during a
MAC reset to let adjust_link() restore the MAC link
settings to the actual link state values.

Fixes following case, for example:
Setting link to 100M, changing MTU (implies MAC reset),
link state remains unchanged to 100M but MAC registers
were reset to default (1G) breaking the connectivity w/
the PHY.  Closing and re-opening the interface would
restore the MAC link parameters to the correct values.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2b7610f..10b3bbbb 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2102,6 +2102,11 @@ int startup_gfar(struct net_device *ndev)
 	/* Start Rx/Tx DMA and enable the interrupts */
 	gfar_start(priv);
 
+	/* force link state update after mac reset */
+	priv->oldlink = 0;
+	priv->oldspeed = 0;
+	priv->oldduplex = -1;
+
 	phy_start(priv->phydev);
 
 	enable_napi(priv);
-- 
1.7.11.7
