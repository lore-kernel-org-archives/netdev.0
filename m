From: David Miller <davem@davemloft.net>
Subject: [PATCH] niu: Fix warnings due to -Wunused-but-set-variable
Date: Mon, 11 Apr 2011 15:50:01 -0700 (PDT)
Message-ID: <20110411.155001.116390911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756018Ab1DKWug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 18:50:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4EEE024C088
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 15:50:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Most of these were legitimate, and once case was a real bug
(not propagating errors from ->xcvr_init() methods).

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 9e6330b..3fa1e9c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -1233,7 +1233,7 @@ static int link_status_1g_rgmii(struct niu *np, int *link_up_p)
 
 	bmsr = err;
 	if (bmsr & BMSR_LSTATUS) {
-		u16 adv, lpa, common, estat;
+		u16 adv, lpa;
 
 		err = mii_read(np, np->phy_addr, MII_ADVERTISE);
 		if (err < 0)
@@ -1245,12 +1245,9 @@ static int link_status_1g_rgmii(struct niu *np, int *link_up_p)
 			goto out;
 		lpa = err;
 
-		common = adv & lpa;
-
 		err = mii_read(np, np->phy_addr, MII_ESTATUS);
 		if (err < 0)
 			goto out;
-		estat = err;
 		link_up = 1;
 		current_speed = SPEED_1000;
 		current_duplex = DUPLEX_FULL;
@@ -1650,7 +1647,7 @@ static int xcvr_init_10g(struct niu *np)
 		break;
 	}
 
-	return 0;
+	return err;
 }
 
 static int mii_reset(struct niu *np)
@@ -2381,17 +2378,14 @@ static int serdes_init_10g_serdes(struct niu *np)
 	struct niu_link_config *lp = &np->link_config;
 	unsigned long ctrl_reg, test_cfg_reg, pll_cfg, i;
 	u64 ctrl_val, test_cfg_val, sig, mask, val;
-	u64 reset_val;
 
 	switch (np->port) {
 	case 0:
-		reset_val =  ENET_SERDES_RESET_0;
 		ctrl_reg = ENET_SERDES_0_CTRL_CFG;
 		test_cfg_reg = ENET_SERDES_0_TEST_CFG;
 		pll_cfg = ENET_SERDES_0_PLL_CFG;
 		break;
 	case 1:
-		reset_val =  ENET_SERDES_RESET_1;
 		ctrl_reg = ENET_SERDES_1_CTRL_CFG;
 		test_cfg_reg = ENET_SERDES_1_TEST_CFG;
 		pll_cfg = ENET_SERDES_1_PLL_CFG;
@@ -8135,7 +8129,7 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 	netif_printk(np, probe, KERN_DEBUG, np->dev,
 		     "VPD_SCAN: start[%x] end[%x]\n", start, end);
 	while (start < end) {
-		int len, err, instance, type, prop_len;
+		int len, err, prop_len;
 		char namebuf[64];
 		u8 *prop_buf;
 		int max_len;
@@ -8151,8 +8145,6 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 		len = err;
 		start += 3;
 
-		instance = niu_pci_eeprom_read(np, start);
-		type = niu_pci_eeprom_read(np, start + 3);
 		prop_len = niu_pci_eeprom_read(np, start + 4);
 		err = niu_pci_vpd_get_propname(np, start + 5, namebuf, 64);
 		if (err < 0)
-- 
1.7.4.3

