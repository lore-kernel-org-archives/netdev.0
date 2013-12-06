From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 7/9] net: pxa168_eth: use phy_init_hw for PHY reset
Date: Fri, 6 Dec 2013 13:01:36 -0800
Message-ID: <1386363698-8407-8-git-send-email-f.fainelli@gmail.com>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:55560 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758387Ab3LFVDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:03:44 -0500
In-Reply-To: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of open-coding a PHY reset through the MII BMCR register, use
phy_init_hw() which does this for us and ensures that PHY device fixups
are also applied. We also remove a call to ethernet_phy_reset() which is
now unncessary since phy_attach() calls phy_attach_direct() which in
turns calls phy_init_hw().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes since v2:
- improve commit message and explain why ethernet_phy_reset() can go away
  entirely

 drivers/net/ethernet/marvell/pxa168_eth.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 2ad3241..452e81d 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -320,23 +320,6 @@ static void ethernet_phy_set_addr(struct pxa168_eth_private *pep, int phy_addr)
 	wrl(pep, PHY_ADDRESS, reg_data);
 }
 
-static void ethernet_phy_reset(struct pxa168_eth_private *pep)
-{
-	int data;
-
-	data = phy_read(pep->phy, MII_BMCR);
-	if (data < 0)
-		return;
-
-	data |= BMCR_RESET;
-	if (phy_write(pep->phy, MII_BMCR, data) < 0)
-		return;
-
-	do {
-		data = phy_read(pep->phy, MII_BMCR);
-	} while (data >= 0 && data & BMCR_RESET);
-}
-
 static void rxq_refill(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
@@ -645,7 +628,7 @@ static void eth_port_start(struct net_device *dev)
 		struct ethtool_cmd cmd;
 
 		pxa168_get_settings(pep->dev, &cmd);
-		ethernet_phy_reset(pep);
+		phy_init_hw(pep->phy);
 		pxa168_set_settings(pep->dev, &cmd);
 	}
 
@@ -1382,7 +1365,6 @@ static struct phy_device *phy_scan(struct pxa168_eth_private *pep, int phy_addr)
 static void phy_init(struct pxa168_eth_private *pep, int speed, int duplex)
 {
 	struct phy_device *phy = pep->phy;
-	ethernet_phy_reset(pep);
 
 	phy_attach(pep->dev, dev_name(&phy->dev), PHY_INTERFACE_MODE_MII);
 
-- 
1.8.3.2
