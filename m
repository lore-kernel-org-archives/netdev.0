From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/7] stmmac: Stop advertising 1000Base capabilties for non GMII iface (V3).
Date: Tue, 18 Oct 2011 10:42:05 +0200
Message-ID: <1318927331-20855-2-git-send-email-peppe.cavallaro@st.com>
References: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:33374 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932143Ab1JRInH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:43:07 -0400
In-Reply-To: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch stops advertising 1000Base capablities if GMAC is either
configured for MII or RMII mode and on board there is a GPHY plugged on.
Without this patch if an GBit switch is connected on MII interface,
Ethernet stops working at all.

Discovered as part of
https://bugzilla.stlinux.com/show_bug.cgi?id=14148 triage

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c0ee6b6..229fe44 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -304,7 +304,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	struct phy_device *phydev;
 	char phy_id[MII_BUS_ID_SIZE + 3];
 	char bus_id[MII_BUS_ID_SIZE];
-
+	int interface = priv->plat->interface;
 	priv->oldlink = 0;
 	priv->speed = 0;
 	priv->oldduplex = -1;
@@ -314,14 +314,21 @@ static int stmmac_init_phy(struct net_device *dev)
 		 priv->plat->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
 
-	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0,
-			     priv->plat->interface);
+	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0, interface);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(phydev);
 	}
 
+	/* Stop Advertising 1000BASE Capability if interface is not GMII */
+	if ((interface) && ((interface == PHY_INTERFACE_MODE_MII) ||
+	    (interface == PHY_INTERFACE_MODE_RMII))) {
+		phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+				      SUPPORTED_Asym_Pause);
+		priv->phydev->advertising = priv->phydev->supported;
+	}
+
 	/*
 	 * Broken HW is sometimes missing the pull-up resistor on the
 	 * MDIO line, which results in reads to non-existent devices returning
-- 
1.7.4.4
