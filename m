From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH 3/8] net: sh-eth: Remove duplicate sh_eth_set_duplex()
Date: Thu, 18 Apr 2013 16:01:45 +0900
Message-ID: <1366268510-8121-3-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:62752 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab3DRHCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 03:02:06 -0400
Received: by mail-pa0-f42.google.com with SMTP id kq13so1388202pab.15
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 00:02:06 -0700 (PDT)
In-Reply-To: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   65 ++++++---------------------------
 1 file changed, 12 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 313d6ef..5c4e82c 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -341,9 +341,11 @@ static void sh_eth_select_mii(struct net_device *ndev)
 }
 #endif
 
-/* There is CPU dependent code */
-#if defined(CONFIG_ARCH_R8A7779)
-#define SH_ETH_RESET_DEFAULT	1
+#if defined(CONFIG_CPU_SUBTYPE_SH7619) || \
+	defined(CONFIG_CPU_SUBTYPE_SH7710) || \
+	defined(CONFIG_CPU_SUBTYPE_SH7712)
+#  define sh_eth_set_duplex NULL
+#else
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -353,7 +355,11 @@ static void sh_eth_set_duplex(struct net_device *ndev)
 	else		/* Half */
 		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
 }
+#endif
 
+/* There is CPU dependent code */
+#if defined(CONFIG_ARCH_R8A7779)
+#define SH_ETH_RESET_DEFAULT	1
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -391,15 +397,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7724)
 #define SH_ETH_RESET_DEFAULT	1
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
 
 static void sh_eth_set_rate(struct net_device *ndev)
 {
@@ -443,16 +440,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -552,16 +539,6 @@ out:
 	return ret;
 }
 
-static void sh_eth_set_duplex_giga(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate_giga(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -584,7 +561,7 @@ static void sh_eth_set_rate_giga(struct net_device *ndev)
 /* SH7757(GETHERC) */
 static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.chip_reset	= sh_eth_chip_reset_giga,
-	.set_duplex	= sh_eth_set_duplex_giga,
+	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_giga,
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
@@ -635,16 +612,6 @@ static void sh_eth_chip_reset(struct net_device *ndev)
 	mdelay(1);
 }
 
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -774,16 +741,6 @@ out:
 	return ret;
 }
 
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -834,6 +791,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
 #define SH_ETH_RESET_DEFAULT	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+	.set_duplex = sh_eth_set_duplex,
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
 	.apr		= 1,
@@ -845,6 +803,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #define SH_ETH_RESET_DEFAULT	1
 #define SH_ETH_HAS_TSU	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+	.set_duplex = sh_eth_set_duplex,
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
 	.tsu_multi_reg	= 1,
-- 
1.7.10.4
