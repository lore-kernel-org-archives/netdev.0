From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/7] net: bcmgenet: implement GPHY power down sequence
Date: Mon, 23 Mar 2015 15:03:49 -0700
Message-ID: <1427148231-18902-6-git-send-email-f.fainelli@gmail.com>
References: <1427148231-18902-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34067 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbbCWWEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:04:42 -0400
Received: by pdbni2 with SMTP id ni2so200353682pdb.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:04:41 -0700 (PDT)
In-Reply-To: <1427148231-18902-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the GPHY power down sequence by setting all power down bits, putting
the GPHY in reset, and finally cutting the 25Mhz reference clock.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index c26c0757d755..77d6a18707c3 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -177,6 +177,7 @@ static void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 	if (!GENET_IS_V4(priv))
 		return;
 
+	reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
 	if (enable) {
 		reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
 		reg &= ~EXT_CK25_DIS;
@@ -189,9 +190,14 @@ static void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 		mdelay(1);
 
 		reg &= ~EXT_GPHY_RESET;
+	} else {
+		reg |= EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN | EXT_GPHY_RESET;
 		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-		udelay(60);
+		mdelay(1);
+		reg |= EXT_CK25_DIS;
 	}
+	bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+	udelay(60);
 }
 
 static void bcmgenet_internal_phy_setup(struct net_device *dev)
-- 
2.1.0
