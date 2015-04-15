From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: [PATCH v2 1/1] stmmac: fix oops on rmmod after assigning ip addr
Date: Wed, 15 Apr 2015 02:07:46 +0100
Message-ID: <1429060066-9156-2-git-send-email-pure.logic@nexus-software.ie>
References: <1429060066-9156-1-git-send-email-pure.logic@nexus-software.ie>
Cc: andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org,
	Bryan O'Donoghue <pure.logic@nexus-software.ie>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-smtp05.blacknight.com ([81.17.249.38]:57321 "EHLO
	outbound-smtp05.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933224AbbDOBHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 21:07:50 -0400
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id C68EE98B3B
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 01:07:48 +0000 (UTC)
In-Reply-To: <1429060066-9156-1-git-send-email-pure.logic@nexus-software.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An oops exists in the flow of stmmac_release().
phy_ethtool_get_wol() depends on phydev->drv.
phydev->drv will be null after stmmac_mdio_unreg() completes.

Steps to reproduce on Quark X1000:

1. ifconfig eth0 192.168.0.1
2. rmmod stmmac_pci

To fix this stmmac_mdio_unreg() should be run after unregister_netdev().

Signed-off-by: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Reported-by: Dan O'Donovan <dan.odonovan@emutex.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a0ea84f..3ab3e4a8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2958,14 +2958,14 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
-	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
-	    priv->pcs != STMMAC_PCS_RTBI)
-		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	if (priv->stmmac_rst)
 		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->stmmac_clk);
+	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
+	    priv->pcs != STMMAC_PCS_RTBI)
+		stmmac_mdio_unregister(ndev);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.9.1
