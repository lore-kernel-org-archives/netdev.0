From: Gavin Schenk <g.schenk@eckelmann.de>
Subject: [PATCH v2] net: fec: set mac address unconditionally
Date: Fri, 30 Sep 2016 11:46:10 +0200
Message-ID: <1475228770-17504-1-git-send-email-g.schenk@eckelmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <kernel@pengutronix.de>,
        Gavin Schenk <g.schenk@eckelmann.de>
To: <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mail.eckelmann.de ([217.19.183.89]:59281 "EHLO
        mail.eckelmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932413AbcI3J4u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 05:56:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the mac address origin is not dt, you can only safely assign a mac
address after "link up" of the device. If the link is off the clocks are
disabled and because of issues assigning registers when clocks are off the
new mac address cannot be written in .ndo_set_mac_address() on some soc's.
This fix sets the mac address unconditionally in fec_restart(...) and
ensures consistency between fec registers and the network layer.

Signed-off-by: Gavin Schenk <g.schenk@eckelmann.de>
Acked-by: Fugang Duan <fugang.duan@nxp.com>
Acked-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
Fixes: 9638d19e4816 ("net: fec: add netif status check before set mac address")
---
Changes since (implicit) v1:
- reword commit log as suggested by Uwe
- added Acks

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
