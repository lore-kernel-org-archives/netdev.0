From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: power on MII block for all MII modes
Date: Fri, 26 Jun 2015 10:38:31 -0700
Message-ID: <1435340314-10229-2-git-send-email-f.fainelli@gmail.com>
References: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36696 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbbFZRkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:40:10 -0400
Received: by pdcu2 with SMTP id u2so78783244pdc.3
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:40:10 -0700 (PDT)
In-Reply-To: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RGMII block is currently only powered on when using RGMII or
RGMII_NO_ID, which is not correct when using the GENET interface in MII
or Reverse MII modes. We always need to power on the RGMII interface for
this block to properly work, regardless of the MII mode in which we
operate.

Fixes: aa09677cba423 ("net: bcmgenet: add MDIO routines")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David,

I am targetting "net" here since this is a bug fix, however, we have few
people using MII or Reverse MII with GENET, such that there is no need to
queue this for -stable unless you want to.

Thanks!

 drivers/net/ethernet/broadcom/genet/bcmmii.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index e7651b3c6c57..420949cc55aa 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -299,9 +299,6 @@ int bcmgenet_mii_config(struct net_device *dev, bool init)
 			phy_name = "external RGMII (no delay)";
 		else
 			phy_name = "external RGMII (TX delay)";
-		reg = bcmgenet_ext_readl(priv, EXT_RGMII_OOB_CTRL);
-		reg |= RGMII_MODE_EN | id_mode_dis;
-		bcmgenet_ext_writel(priv, reg, EXT_RGMII_OOB_CTRL);
 		bcmgenet_sys_writel(priv,
 				    PORT_MODE_EXT_GPHY, SYS_PORT_CTRL);
 		break;
@@ -310,6 +307,15 @@ int bcmgenet_mii_config(struct net_device *dev, bool init)
 		return -EINVAL;
 	}
 
+	/* This is an external PHY (xMII), so we need to enable the RGMII
+	 * block for the interface to work
+	 */
+	if (priv->ext_phy) {
+		reg = bcmgenet_ext_readl(priv, EXT_RGMII_OOB_CTRL);
+		reg |= RGMII_MODE_EN | id_mode_dis;
+		bcmgenet_ext_writel(priv, reg, EXT_RGMII_OOB_CTRL);
+	}
+
 	if (init)
 		dev_info(kdev, "configuring instance for %s\n", phy_name);
 
-- 
2.1.0
