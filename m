From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] net: sh-eth: Add flag to determine the type of TSU register
Date: Thu, 18 Apr 2013 10:26:11 +0900
Message-ID: <1366248372-28791-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54157 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab3DRB0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 21:26:22 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so1167603pdj.16
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 18:26:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some sh-eth devices may have two ether devices in the inside.
And the function of TSU is accessed from each ether device.
In this case, sh-eth need to remap address using devm_ioremap(),
without using devm_ioremap_resource().
acl_multi_reg of sh_eth_cpu_data is used for this control.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   11 ++++++++++-
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a7499cb..d9458ae 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -610,6 +610,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.no_trimd	= 1,
 	.no_ade		= 1,
 	.tsu		= 1,
+	.tsu_multi_reg	= 1,
 };
 
 static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
@@ -691,6 +692,8 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #if defined(CONFIG_CPU_SUBTYPE_SH7734)
 	.hw_crc     = 1,
 	.select_mii = 1,
+#else
+	.tsu_multi_reg	= 1,
 #endif
 };
 
@@ -844,6 +847,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
+	.tsu_multi_reg	= 1,
 };
 #endif
 
@@ -2743,7 +2747,12 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 			ret = -ENODEV;
 			goto out_release;
 		}
-		mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
+
+		if (mdp->cd->tsu_multi_reg)
+			mdp->tsu_addr = devm_ioremap(&pdev->dev, rtsu->start,
+					resource_size(rtsu));
+		else
+			mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
 		if (IS_ERR(mdp->tsu_addr)) {
 			ret = PTR_ERR(mdp->tsu_addr);
 			goto out_release;
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 1ddc9f2..6f9a997 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -472,6 +472,7 @@ struct sh_eth_cpu_data {
 	unsigned tpauser:1;		/* EtherC have TPAUSER */
 	unsigned bculr:1;		/* EtherC have BCULR */
 	unsigned tsu:1;			/* EtherC have TSU */
+	unsigned tsu_multi_reg:1; /* EtherC have TSU multi register */
 	unsigned hw_swap:1;		/* E-DMAC have DE bit in EDMR */
 	unsigned rpadir:1;		/* E-DMAC have RPADIR */
 	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */
-- 
1.7.10.4
