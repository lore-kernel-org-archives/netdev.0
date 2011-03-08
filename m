From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 4/6] net: sh_eth: modify the PHY_INTERFACE_MODE
Date: Tue, 08 Mar 2011 16:59:45 +0900
Message-ID: <4D75E1F1.5090306@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:60729 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755710Ab1CHH7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 02:59:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous code had hardcoded the PHY_INTERFACE_MODE_MII of phy_connect.
So some Gigabit PHYs will not behave correctly.
The patch adds the phy_interface in sh_eth_plat_data, so we can select
the phy interface.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 This patch are based on net-next-2.6.git.

 arch/sh/include/asm/sh_eth.h |    3 +++
 drivers/net/sh_eth.c         |    3 ++-
 drivers/net/sh_eth.h         |    1 +
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/arch/sh/include/asm/sh_eth.h b/arch/sh/include/asm/sh_eth.h
index 1557696..e86c880 100644
--- a/arch/sh/include/asm/sh_eth.h
+++ b/arch/sh/include/asm/sh_eth.h
@@ -1,6 +1,8 @@
 #ifndef __ASM_SH_ETH_H__
 #define __ASM_SH_ETH_H__

+#include <linux/phy.h>
+
 enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
 enum {
 	SH_ETH_REG_GIGABIT,
@@ -12,6 +14,7 @@ struct sh_eth_plat_data {
 	int phy;
 	int edmac_endian;
 	int register_type;
+	phy_interface_t phy_interface;

 	unsigned char mac_addr[6];
 	unsigned no_ether_link:1;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 6734311..5d28ce6 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1071,7 +1071,7 @@ static int sh_eth_phy_init(struct net_device *ndev)

 	/* Try connect to PHY */
 	phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
-				0, PHY_INTERFACE_MODE_MII);
+				0, mdp->phy_interface);
 	if (IS_ERR(phydev)) {
 		dev_err(&ndev->dev, "phy_connect failed\n");
 		return PTR_ERR(phydev);
@@ -1669,6 +1669,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	pd = (struct sh_eth_plat_data *)(pdev->dev.platform_data);
 	/* get PHY ID */
 	mdp->phy_id = pd->phy;
+	mdp->phy_interface = pd->phy_interface;
 	/* EDMAC endian */
 	mdp->edmac_endian = pd->edmac_endian;
 	mdp->no_ether_link = pd->no_ether_link;
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index b349c5e..c3048a6 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -781,6 +781,7 @@ struct sh_eth_private {
 	struct mii_bus *mii_bus;	/* MDIO bus control */
 	struct phy_device *phydev;	/* PHY device control */
 	enum phy_state link;
+	phy_interface_t phy_interface;
 	int msg_enable;
 	int speed;
 	int duplex;
-- 
1.7.1
