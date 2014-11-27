From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH] stmmac: platform: Move plat_dat checking earlier
Date: Thu, 27 Nov 2014 11:14:32 +0800
Message-ID: <1417058072-22527-1-git-send-email-chenhc@lemote.com>
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Huacai Chen <chenhc@lemote.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:62019 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbaK0DOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 22:14:42 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so4049127pdi.2
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 19:14:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original code only check/alloc plat_dat for the CONFIG_OF case, this
patch check/alloc it earlier and unconditionally to avoid kernel build
warnings:

drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:275
stmmac_pltfr_probe() warn: variable dereferenced before check 'plat_dat'

Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 5b0da39..d254950 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -265,6 +265,15 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	plat_dat = dev_get_platdata(&pdev->dev);
 
+	if (!plat_dat)
+		plat_dat = devm_kzalloc(&pdev->dev,
+				sizeof(struct plat_stmmacenet_data),
+				GFP_KERNEL);
+	if (!plat_dat) {
+		pr_err("%s: ERROR: no memory", __func__);
+		return  -ENOMEM;
+	}
+
 	/* Set default value for multicast hash bins */
 	plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
 
@@ -272,15 +281,6 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	plat_dat->unicast_filter_entries = 1;
 
 	if (pdev->dev.of_node) {
-		if (!plat_dat)
-			plat_dat = devm_kzalloc(&pdev->dev,
-					sizeof(struct plat_stmmacenet_data),
-					GFP_KERNEL);
-		if (!plat_dat) {
-			pr_err("%s: ERROR: no memory", __func__);
-			return  -ENOMEM;
-		}
-
 		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
 		if (ret) {
 			pr_err("%s: main dt probe failed", __func__);
-- 
1.7.7.3
