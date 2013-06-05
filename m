From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v4 7/8] sh_eth: consolidate sh_eth_reset()
Date: Thu, 6 Jun 2013 01:19:30 +0400
Message-ID: <201306060119.30971.sergei.shtylyov@cogentembedded.com>
References: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:47348 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932591Ab3FEVT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 17:19:27 -0400
Received: by mail-la0-f44.google.com with SMTP id er20so1925189lab.31
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 14:19:25 -0700 (PDT)
In-Reply-To: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

This driver has sh_eth_reset() function for each SoC and this function is almost
always the same, except for the several a bit different variations for Gigabit
Ethernet.  Consolidate every variation into a single function -- which allows
us to get rid of some more #ifdef'fery.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: moved the new sh_eth_reset() upper to decrease the patch  size,  fixed
function call continuation lines' indentation, reworded the changelog, reworded
the subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 4:
- moved the new sh_eth_reset() upper to desrease the patch size;
- fixed function call continuation lines' indentation;
- refreshed the patch;
- reworded the summary;
- reworded the subject, changing the prefix.

 drivers/net/ethernet/renesas/sh_eth.c |  158 +++++++++-------------------------
 1 file changed, 43 insertions(+), 115 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -349,7 +349,6 @@ static void __maybe_unused sh_eth_set_du
 
 /* There is CPU dependent code */
 #if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
-#define SH_ETH_RESET_DEFAULT	1
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -386,7 +385,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.hw_swap	= 1,
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7724)
-#define SH_ETH_RESET_DEFAULT	1
 
 static void sh_eth_set_rate(struct net_device *ndev)
 {
@@ -427,7 +425,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
 #define SH_ETH_HAS_BOTH_MODULES	1
-static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_set_rate(struct net_device *ndev)
 {
@@ -494,40 +491,6 @@ static void sh_eth_chip_reset_giga(struc
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
@@ -589,8 +552,6 @@ static struct sh_eth_cpu_data *sh_eth_ge
 }
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763)
-static int sh_eth_check_reset(struct net_device *ndev);
-static void sh_eth_reset_hw_crc(struct net_device *ndev);
 
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
@@ -653,45 +614,8 @@ static struct sh_eth_cpu_data sh_eth_my_
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
@@ -704,31 +628,6 @@ static void sh_eth_chip_reset(struct net
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
@@ -777,7 +676,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 };
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
-#define SH_ETH_RESET_DEFAULT	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
@@ -787,7 +685,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.hw_swap	= 1,
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
-#define SH_ETH_RESET_DEFAULT	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
@@ -822,17 +719,6 @@ static void sh_eth_set_default_cpu_data(
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
 static int sh_eth_check_reset(struct net_device *ndev)
 {
 	int ret = 0;
@@ -850,7 +736,49 @@ static int sh_eth_check_reset(struct net
 	}
 	return ret;
 }
-#endif
+
+static int sh_eth_reset(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret = 0;
+
+	if (sh_eth_is_gether(mdp)) {
+		sh_eth_write(ndev, EDSR_ENALL, EDSR);
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
+			     EDMR);
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
+			     EDMR);
+		mdelay(3);
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER,
+			     EDMR);
+	}
+
+out:
+	return ret;
+}
 
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
 static void sh_eth_set_receive_align(struct sk_buff *skb)
