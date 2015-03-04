From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: properly disable password matching
Date: Wed,  4 Mar 2015 11:43:03 -0800
Message-ID: <1425498183-28832-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:37036 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759457AbbCDToJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 14:44:09 -0500
Received: by paceu11 with SMTP id eu11so22088522pac.4
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 11:44:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_set_wol() correctly sets MPD_PW_EN when a password is specified
to match magic packets against, however, when we switch from a
password-matching to a matching without password we would leave this bit
turned on, and GENET would only match magic packets with passwords.

This can be reproduced using the following sequence:

ethtool -s eth0 wol g
ethtool -s eth0 wol s sopass 00:11:22:33:44:55
ethtool -s eth0 wol g

The simple fix is to clear the MPD_PWD_EN bit when WAKE_MAGICSECURE is
not set.

Fixes: c51de7f3976b ("net: bcmgenet: add Wake-on-LAN support code")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
index 149a0d70c108..b97122926d3a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
@@ -73,15 +73,17 @@ int bcmgenet_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~(WAKE_MAGIC | WAKE_MAGICSECURE))
 		return -EINVAL;
 
+	reg = bcmgenet_umac_readl(priv, UMAC_MPD_CTRL);
 	if (wol->wolopts & WAKE_MAGICSECURE) {
 		bcmgenet_umac_writel(priv, get_unaligned_be16(&wol->sopass[0]),
 				     UMAC_MPD_PW_MS);
 		bcmgenet_umac_writel(priv, get_unaligned_be32(&wol->sopass[2]),
 				     UMAC_MPD_PW_LS);
-		reg = bcmgenet_umac_readl(priv, UMAC_MPD_CTRL);
 		reg |= MPD_PW_EN;
-		bcmgenet_umac_writel(priv, reg, UMAC_MPD_CTRL);
+	} else {
+		reg &= ~MPD_PW_EN;
 	}
+	bcmgenet_umac_writel(priv, reg, UMAC_MPD_CTRL);
 
 	/* Flag the device and relevant IRQ as wakeup capable */
 	if (wol->wolopts) {
-- 
2.1.0
