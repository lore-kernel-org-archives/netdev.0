From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] net/sh-eth: Check return value of sh_eth_reset when chip reset fail
Date: Tue, 26 Jun 2012 12:35:12 +0900
Message-ID: <1340681712-2212-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: florian@openwrt.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60332 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756128Ab2FZD1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 23:27:37 -0400
Received: by pbbrp8 with SMTP id rp8so7422857pbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 20:27:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sh_eth_reset function resets chip, but this performs nothing when failed.
This changes sh_eth_reset return an error, when this failed in reset.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   88 +++++++++++++++++++++------------
 1 file changed, 56 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 8d696e0..326cb91 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -130,6 +130,8 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
 #define SH_ETH_HAS_BOTH_MODULES	1
 #define SH_ETH_HAS_TSU	1
+static int sh_eth_check_reset(struct net_device *ndev);
+
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -204,23 +206,19 @@ static void sh_eth_chip_reset_giga(struct net_device *ndev)
 }
 
 static int sh_eth_is_gether(struct sh_eth_private *mdp);
-static void sh_eth_reset(struct net_device *ndev)
+static int sh_eth_reset(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	int cnt = 100;
+	int ret = 0;
 
 	if (sh_eth_is_gether(mdp)) {
 		sh_eth_write(ndev, 0x03, EDSR);
 		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
 				EDMR);
-		while (cnt > 0) {
-			if (!(sh_eth_read(ndev, EDMR) & 0x3))
-				break;
-			mdelay(1);
-			cnt--;
-		}
-		if (cnt < 0)
-			printk(KERN_ERR "Device reset fail\n");
+
+		ret = sh_eth_check_reset(ndev);
+		if (ret)
+			goto out;
 
 		/* Table Init */
 		sh_eth_write(ndev, 0x0, TDLAR);
@@ -238,6 +236,9 @@ static void sh_eth_reset(struct net_device *ndev)
 		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER,
 				EDMR);
 	}
+
+out:
+	return ret;
 }
 
 static void sh_eth_set_duplex_giga(struct net_device *ndev)
@@ -310,6 +311,7 @@ static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763)
 #define SH_ETH_HAS_TSU	1
+static int sh_eth_check_reset(struct net_device *ndev);
 static void sh_eth_reset_hw_crc(struct net_device *ndev);
 
 static void sh_eth_chip_reset(struct net_device *ndev)
@@ -381,20 +383,16 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #endif
 };
 
-static void sh_eth_reset(struct net_device *ndev)
+static int sh_eth_reset(struct net_device *ndev)
 {
-	int cnt = 100;
+	int ret = 0;
 
 	sh_eth_write(ndev, EDSR_ENALL, EDSR);
 	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDMR);
-	while (cnt > 0) {
-		if (!(sh_eth_read(ndev, EDMR) & 0x3))
-			break;
-		mdelay(1);
-		cnt--;
-	}
-	if (cnt == 0)
-		printk(KERN_ERR "Device reset fail\n");
+
+	ret = sh_eth_check_reset(ndev);
+	if (ret)
+		goto out;
 
 	/* Table Init */
 	sh_eth_write(ndev, 0x0, TDLAR);
@@ -412,6 +410,8 @@ static void sh_eth_reset(struct net_device *ndev)
 	/* Select MII mode */
 	if (sh_eth_my_cpu_data.select_mii)
 		sh_eth_select_mii(ndev);
+out:
+	return ret;
 }
 
 static void sh_eth_reset_hw_crc(struct net_device *ndev)
@@ -422,6 +422,8 @@ static void sh_eth_reset_hw_crc(struct net_device *ndev)
 
 #elif defined(CONFIG_ARCH_R8A7740)
 #define SH_ETH_HAS_TSU	1
+static int sh_eth_check_reset(struct net_device *ndev);
+
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -433,20 +435,16 @@ static void sh_eth_chip_reset(struct net_device *ndev)
 	sh_eth_select_mii(ndev);
 }
 
-static void sh_eth_reset(struct net_device *ndev)
+static int sh_eth_reset(struct net_device *ndev)
 {
-	int cnt = 100;
+	int ret = 0;
 
 	sh_eth_write(ndev, EDSR_ENALL, EDSR);
 	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDMR);
-	while (cnt > 0) {
-		if (!(sh_eth_read(ndev, EDMR) & 0x3))
-			break;
-		mdelay(1);
-		cnt--;
-	}
-	if (cnt == 0)
-		printk(KERN_ERR "Device reset fail\n");
+
+	ret = sh_eth_check_reset(ndev);
+	if (ret)
+		goto out;
 
 	/* Table Init */
 	sh_eth_write(ndev, 0x0, TDLAR);
@@ -457,6 +455,9 @@ static void sh_eth_reset(struct net_device *ndev)
 	sh_eth_write(ndev, 0x0, RDFAR);
 	sh_eth_write(ndev, 0x0, RDFXR);
 	sh_eth_write(ndev, 0x0, RDFFR);
+
+out:
+	return ret;
 }
 
 static void sh_eth_set_duplex(struct net_device *ndev)
@@ -565,11 +566,31 @@ static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
 
 #if defined(SH_ETH_RESET_DEFAULT)
 /* Chip Reset */
-static void sh_eth_reset(struct net_device *ndev)
+static int  sh_eth_reset(struct net_device *ndev)
 {
 	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_ETHER, EDMR);
 	mdelay(3);
 	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER, EDMR);
+
+	return 0;
+}
+#else
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
+		printk(KERN_ERR "Device reset fail\n");
+		ret = -ETIMEDOUT;
+	}
+	return ret;
 }
 #endif
 
@@ -924,7 +945,9 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	u32 val;
 
 	/* Soft Reset */
-	sh_eth_reset(ndev);
+	ret = sh_eth_reset(ndev);
+	if (ret)
+		goto out;
 
 	/* Descriptor format */
 	sh_eth_ring_format(ndev);
@@ -998,6 +1021,7 @@ static int sh_eth_dev_init(struct net_device *ndev)
 
 	netif_start_queue(ndev);
 
+out:
 	return ret;
 }
 
-- 
1.7.10
