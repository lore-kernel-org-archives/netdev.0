From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v2] net: sh-eth: Add flag to determine the type of TSU register
Date: Tue,  7 May 2013 14:08:11 +0900
Message-ID: <1367903291-32323-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:59089 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758511Ab3EGFIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:08:22 -0400
Received: by mail-pd0-f179.google.com with SMTP id q10so131722pdj.38
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:08:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some sh-eth devices may have two ether devices inside.
And the function of TSU is accessed from each ether device.
In this case, sh-eth need to remap address using devm_ioremap(),
without using devm_ioremap_resource().
tsu_shared_reg of sh_eth_cpu_data is used for this control.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V2:
  - Change variable name from tsu_multi_reg to tsu_shared_reg.
  - Update commit message.

 drivers/net/ethernet/renesas/sh_eth.c |   11 ++++++++++-
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33dc6f2..489be0e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -610,6 +610,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.no_trimd	= 1,
 	.no_ade		= 1,
 	.tsu		= 1,
+	.tsu_shared_reg	= 1,
 };
 
 static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
@@ -691,6 +692,8 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #if defined(CONFIG_CPU_SUBTYPE_SH7734)
 	.hw_crc     = 1,
 	.select_mii = 1,
+#else
+	.tsu_shared_reg	= 1,
 #endif
 };
 
@@ -844,6 +847,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
+	.tsu_shared_reg	= 1,
 };
 #endif
 
@@ -2750,7 +2754,12 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 			ret = -ENODEV;
 			goto out_release;
 		}
-		mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
+
+		if (mdp->cd->tsu_shared_reg)
+			mdp->tsu_addr = devm_ioremap(&pdev->dev, rtsu->start,
+					resource_size(rtsu));
+		else
+			mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
 		if (IS_ERR(mdp->tsu_addr)) {
 			ret = PTR_ERR(mdp->tsu_addr);
 			goto out_release;
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 1ddc9f2..26cb8a0 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -472,6 +472,7 @@ struct sh_eth_cpu_data {
 	unsigned tpauser:1;		/* EtherC have TPAUSER */
 	unsigned bculr:1;		/* EtherC have BCULR */
 	unsigned tsu:1;			/* EtherC have TSU */
+	unsigned tsu_shared_reg:1;	/* EtherC have TSU shared register */
 	unsigned hw_swap:1;		/* E-DMAC have DE bit in EDMR */
 	unsigned rpadir:1;		/* E-DMAC have RPADIR */
 	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */
-- 
1.7.10.4
