From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 9/9] net: sh-eth: Rewrite sh_eth_reset function
Date: Tue,  7 May 2013 14:17:55 +0900
Message-ID: <1367903875-32606-9-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:50585 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab3EGFSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:32 -0400
Received: by mail-pb0-f49.google.com with SMTP id rp8so133910pbb.8
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:31 -0700 (PDT)
In-Reply-To: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver has sh_eth_reset function each CPU.
And this function is almost the same. This is summarized in
single function.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V3:
  no change.
V2:
  no change.
 drivers/net/ethernet/renesas/sh_eth.c |  194 +++++++++++----------------------
 1 file changed, 61 insertions(+), 133 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 664a236..ee600f0 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -349,7 +349,6 @@ static void sh_eth_set_duplex(struct net_device *ndev)
 
 /* There is CPU dependent code */
 #if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
-#define SH_ETH_RESET_DEFAULT	1
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -386,7 +385,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.hw_swap	= 1,
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7724)
-#define SH_ETH_RESET_DEFAULT	1
 
 static void sh_eth_set_rate(struct net_device *ndev)
 {
@@ -427,7 +425,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
 #define SH_ETH_HAS_BOTH_MODULES	1
-static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_set_rate(struct net_device *ndev)
 {
@@ -494,40 +491,6 @@ static void sh_eth_chip_reset_giga(struct net_device *ndev)
 }
 
 static int sh_eth_is_gether(struct sh_eth_private *mdp);
-static int sh_eth_reset(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-	int ret = 0;
-
-	if (sh_eth_is_gether(mdp)) {
-		sh_eth_write(ndev, EDSR_ENALL, EDSR);
-		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
-				EDMR);
-
-		ret = sh_eth_check_reset(ndev);
-		if (ret)
-			goto out;
-
-		/* Table Init */
-		sh_eth_write(ndev, 0x0, TDLAR);
-		sh_eth_write(ndev, 0x0, TDFAR);
-		sh_eth_write(ndev, 0x0, TDFXR);
-		sh_eth_write(ndev, 0x0, TDFFR);
-		sh_eth_write(ndev, 0x0, RDLAR);
-		sh_eth_write(ndev, 0x0, RDFAR);
-		sh_eth_write(ndev, 0x0, RDFXR);
-		sh_eth_write(ndev, 0x0, RDFFR);
-	} else {
-		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_ETHER,
-				EDMR);
-		mdelay(3);
-		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER,
-				EDMR);
-	}
-
-out:
-	return ret;
-}
 
 static void sh_eth_set_rate_giga(struct net_device *ndev)
 {
@@ -590,8 +553,6 @@ static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
 }
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763)
-static int sh_eth_check_reset(struct net_device *ndev);
-static void sh_eth_reset_hw_crc(struct net_device *ndev);
 
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
@@ -655,45 +616,8 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #endif
 };
 
-static int sh_eth_reset(struct net_device *ndev)
-{
-	int ret = 0;
-
-	sh_eth_write(ndev, EDSR_ENALL, EDSR);
-	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDMR);
-
-	ret = sh_eth_check_reset(ndev);
-	if (ret)
-		goto out;
-
-	/* Table Init */
-	sh_eth_write(ndev, 0x0, TDLAR);
-	sh_eth_write(ndev, 0x0, TDFAR);
-	sh_eth_write(ndev, 0x0, TDFXR);
-	sh_eth_write(ndev, 0x0, TDFFR);
-	sh_eth_write(ndev, 0x0, RDLAR);
-	sh_eth_write(ndev, 0x0, RDFAR);
-	sh_eth_write(ndev, 0x0, RDFXR);
-	sh_eth_write(ndev, 0x0, RDFFR);
-
-	/* Reset HW CRC register */
-	sh_eth_reset_hw_crc(ndev);
-
-	/* Select MII mode */
-	if (sh_eth_my_cpu_data.select_mii)
-		sh_eth_select_mii(ndev);
-out:
-	return ret;
-}
-
-static void sh_eth_reset_hw_crc(struct net_device *ndev)
-{
-	if (sh_eth_my_cpu_data.hw_crc)
-		sh_eth_write(ndev, 0x0, CSMR);
-}
 
 #elif defined(CONFIG_ARCH_R8A7740)
-static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
@@ -706,31 +630,6 @@ static void sh_eth_chip_reset(struct net_device *ndev)
 	sh_eth_select_mii(ndev);
 }
 
-static int sh_eth_reset(struct net_device *ndev)
-{
-	int ret = 0;
-
-	sh_eth_write(ndev, EDSR_ENALL, EDSR);
-	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDMR);
-
-	ret = sh_eth_check_reset(ndev);
-	if (ret)
-		goto out;
-
-	/* Table Init */
-	sh_eth_write(ndev, 0x0, TDLAR);
-	sh_eth_write(ndev, 0x0, TDFAR);
-	sh_eth_write(ndev, 0x0, TDFXR);
-	sh_eth_write(ndev, 0x0, TDFFR);
-	sh_eth_write(ndev, 0x0, RDLAR);
-	sh_eth_write(ndev, 0x0, RDFAR);
-	sh_eth_write(ndev, 0x0, RDFXR);
-	sh_eth_write(ndev, 0x0, RDFFR);
-
-out:
-	return ret;
-}
-
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -779,7 +678,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 };
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
-#define SH_ETH_RESET_DEFAULT	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
@@ -789,7 +687,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.hw_swap	= 1,
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
-#define SH_ETH_RESET_DEFAULT	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
@@ -825,36 +722,6 @@ static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
 		cd->tx_error_check = DEFAULT_TX_ERROR_CHECK;
 }
 
-#if defined(SH_ETH_RESET_DEFAULT)
-/* Chip Reset */
-static int  sh_eth_reset(struct net_device *ndev)
-{
-	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_ETHER, EDMR);
-	mdelay(3);
-	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER, EDMR);
-
-	return 0;
-}
-#else
-static int sh_eth_check_reset(struct net_device *ndev)
-{
-	int ret = 0;
-	int cnt = 100;
-
-	while (cnt > 0) {
-		if (!(sh_eth_read(ndev, EDMR) & 0x3))
-			break;
-		mdelay(1);
-		cnt--;
-	}
-	if (cnt < 0) {
-		pr_err("Device reset fail\n");
-		ret = -ETIMEDOUT;
-	}
-	return ret;
-}
-#endif
-
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
 static void sh_eth_set_receive_align(struct sk_buff *skb)
 {
@@ -945,6 +812,67 @@ static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
 		return EDTRR_TRNS_ETHER;
 }
 
+static int sh_eth_check_reset(struct net_device *ndev)
+{
+	int ret = 0;
+	int cnt = 100;
+
+	while (cnt > 0) {
+		if (!(sh_eth_read(ndev, EDMR) & 0x3))
+			break;
+		mdelay(1);
+		cnt--;
+	}
+	if (cnt < 0) {
+		pr_err("Device reset fail\n");
+		ret = -ETIMEDOUT;
+	}
+	return ret;
+}
+
+static int sh_eth_reset(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret = 0;
+
+	if (sh_eth_is_gether(mdp)) {
+		sh_eth_write(ndev, EDSR_ENALL, EDSR);
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
+				EDMR);
+
+		ret = sh_eth_check_reset(ndev);
+		if (ret)
+			goto out;
+
+		/* Table Init */
+		sh_eth_write(ndev, 0x0, TDLAR);
+		sh_eth_write(ndev, 0x0, TDFAR);
+		sh_eth_write(ndev, 0x0, TDFXR);
+		sh_eth_write(ndev, 0x0, TDFFR);
+		sh_eth_write(ndev, 0x0, RDLAR);
+		sh_eth_write(ndev, 0x0, RDFAR);
+		sh_eth_write(ndev, 0x0, RDFXR);
+		sh_eth_write(ndev, 0x0, RDFFR);
+
+		/* Reset HW CRC register */
+		if (mdp->cd->hw_crc)
+			sh_eth_write(ndev, 0x0, CSMR);
+
+		/* Select MII mode */
+		if (mdp->cd->select_mii)
+			sh_eth_select_mii(ndev);
+	} else {
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_ETHER,
+				EDMR);
+		mdelay(3);
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER,
+				EDMR);
+	}
+
+out:
+	return ret;
+}
+
 struct bb_info {
 	void (*set_gate)(void *addr);
 	struct mdiobb_ctrl ctrl;
-- 
1.7.10.4
