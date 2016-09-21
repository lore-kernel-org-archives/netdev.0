From: Gavin Schenk <g.schenk@eckelmann.de>
Subject: [PATCH] net: fec: set mac address unconditionally
Date: Wed, 21 Sep 2016 15:30:55 +0200
Message-ID: <1474464655-126940-1-git-send-email-g.schenk@eckelmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: <netdev@vger.kernel.org>, <kernel@pengutronix.de>,
        Gavin Schenk <g.schenk@eckelmann.de>
To: <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mail.eckelmann.de ([217.19.183.89]:50404 "EHLO
        mail.eckelmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933922AbcIUNin (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 09:38:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 9638d19e4816 ("net: fec: add netif status check before set mac address")

If the mac address origin is not dt, you can only safe assign a
mac address after "link up" of the device. If the link is down the
clocks are disabled and because of issues assigning registers when
clocks are down the new mac address is discarded on some soc's. This fix
sets the mac address unconditionally in fec_restart(...) and ensures
consistens between fec registers and the network layer.

Signed-off-by: Gavin Schenk <g.schenk@eckelmann.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 2a03857cca18..bdabea6cd981 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -903,13 +903,11 @@ fec_restart(struct net_device *ndev)
 	 * enet-mac reset will reset mac address registers too,
 	 * so need to reconfigure it.
 	 */
-	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
-		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
-		writel((__force u32)cpu_to_be32(temp_mac[0]),
-		       fep->hwp + FEC_ADDR_LOW);
-		writel((__force u32)cpu_to_be32(temp_mac[1]),
-		       fep->hwp + FEC_ADDR_HIGH);
-	}
+	memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
+	writel((__force u32)cpu_to_be32(temp_mac[0]),
+	       fep->hwp + FEC_ADDR_LOW);
+	writel((__force u32)cpu_to_be32(temp_mac[1]),
+	       fep->hwp + FEC_ADDR_HIGH);
 
 	/* Clear any outstanding interrupt. */
 	writel(0xffffffff, fep->hwp + FEC_IEVENT);
-- 
1.9.1


Eckelmann AG
Vorstand: Dipl.-Ing. Peter Frankenbach (Sprecher) Dipl.-Wi.-Ing. Philipp Eckelmann
Dr.-Ing. Frank-Thomas Mellert Dr.-Ing. Marco Münchhof Dr.-Ing. Frank Uhlemann
Vorsitzender des Aufsichtsrats: Hubertus G. Krossa
Sitz der Gesellschaft: Berliner Str. 161, 65205 Wiesbaden, Amtsgericht Wiesbaden HRB 12636
http://www.eckelmann.de 
