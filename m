From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [Stlinux-devel] [PATCH linux-stm 1/4] net:stmmac: Add check if mdiobus is registered in stmmac_mdio_unregister
Date: Thu, 30 Aug 2012 16:49:58 +0100
Message-ID: <1346341798-19704-1-git-send-email-srinivas.kandagatla@st.com>
Cc: peppe.cavallaro@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:39996 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752544Ab2H3Puu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 11:50:50 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A9343EC
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 15:50:48 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 47C314E48
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 15:50:48 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds a basic check in stmmac_mdio_unregister to see if mdio
bus registeration for this driver was actually sucessfull or not.

Use case here is, if BSP considers using mdio-gpio bus along with stmmac
driver by passing mdio_bus_data as NULL in platform data.
Call to stmmac_mdio_register with mdio_bus_data as NULL returns 0, which
is a considered sucessfull call form stmmac. Then again when we unload
the driver we just call stmmac_mdio_unregister, this is were the actual
problem is stmmac-mdio code dont really know at this instance of calling
that stmmac_mdio_register was actually successful.

So Adding a check in stmmac_mdio_unregister is always safe.

Without this patch stmmac driver calls stmmac_mdio_register from
stmmac_release which Segfaults as mii bus was never registered at the
first point.

Originally the this bug was found when unloading an stmmac driver
instance which uses mdio-gpio for smi access.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index ade1082..e1f3d04 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -258,6 +258,9 @@ int stmmac_mdio_unregister(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
+	if (!priv->mii)
+		return 0;
+
 	mdiobus_unregister(priv->mii);
 	priv->mii->priv = NULL;
 	mdiobus_free(priv->mii);
-- 
1.7.0.4
