From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 10/17] mv643xx_eth: smi sharing is a per-unit property, not a per-port one
Date: Wed,  3 Sep 2008 14:29:37 +0200
Message-ID: <1220444984-20150-11-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52900 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752556AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Which top-level unit's SMI interface to use should be a property of
the top-level unit, not of the individual ports.  This patch moves the
->shared_smi pointer from the per-port platform data to the global
platform data.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 arch/arm/mach-mv78xx0/common.c |    6 +++---
 drivers/net/mv643xx_eth.c      |   19 +++++++++++--------
 include/linux/mv643xx_eth.h    |    2 +-
 3 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/arch/arm/mach-mv78xx0/common.c b/arch/arm/mach-mv78xx0/common.c
index 953a26c..5842d3b 100644
--- a/arch/arm/mach-mv78xx0/common.c
+++ b/arch/arm/mach-mv78xx0/common.c
@@ -330,6 +330,7 @@ void __init mv78xx0_ge00_init(struct mv643xx_eth_platform_data *eth_data)
 struct mv643xx_eth_shared_platform_data mv78xx0_ge01_shared_data = {
 	.t_clk		= 0,
 	.dram		= &mv78xx0_mbus_dram_info,
+	.shared_smi	= &mv78xx0_ge00_shared,
 };
 
 static struct resource mv78xx0_ge01_shared_resources[] = {
@@ -370,7 +371,6 @@ static struct platform_device mv78xx0_ge01 = {
 void __init mv78xx0_ge01_init(struct mv643xx_eth_platform_data *eth_data)
 {
 	eth_data->shared = &mv78xx0_ge01_shared;
-	eth_data->shared_smi = &mv78xx0_ge00_shared;
 	mv78xx0_ge01.dev.platform_data = eth_data;
 
 	platform_device_register(&mv78xx0_ge01_shared);
@@ -384,6 +384,7 @@ void __init mv78xx0_ge01_init(struct mv643xx_eth_platform_data *eth_data)
 struct mv643xx_eth_shared_platform_data mv78xx0_ge10_shared_data = {
 	.t_clk		= 0,
 	.dram		= &mv78xx0_mbus_dram_info,
+	.shared_smi	= &mv78xx0_ge00_shared,
 };
 
 static struct resource mv78xx0_ge10_shared_resources[] = {
@@ -424,7 +425,6 @@ static struct platform_device mv78xx0_ge10 = {
 void __init mv78xx0_ge10_init(struct mv643xx_eth_platform_data *eth_data)
 {
 	eth_data->shared = &mv78xx0_ge10_shared;
-	eth_data->shared_smi = &mv78xx0_ge00_shared;
 	mv78xx0_ge10.dev.platform_data = eth_data;
 
 	platform_device_register(&mv78xx0_ge10_shared);
@@ -438,6 +438,7 @@ void __init mv78xx0_ge10_init(struct mv643xx_eth_platform_data *eth_data)
 struct mv643xx_eth_shared_platform_data mv78xx0_ge11_shared_data = {
 	.t_clk		= 0,
 	.dram		= &mv78xx0_mbus_dram_info,
+	.shared_smi	= &mv78xx0_ge00_shared,
 };
 
 static struct resource mv78xx0_ge11_shared_resources[] = {
@@ -478,7 +479,6 @@ static struct platform_device mv78xx0_ge11 = {
 void __init mv78xx0_ge11_init(struct mv643xx_eth_platform_data *eth_data)
 {
 	eth_data->shared = &mv78xx0_ge11_shared;
-	eth_data->shared_smi = &mv78xx0_ge00_shared;
 	mv78xx0_ge11.dev.platform_data = eth_data;
 
 	platform_device_register(&mv78xx0_ge11_shared);
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c41541d..6d3da78 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -248,6 +248,11 @@ struct mv643xx_eth_shared_private {
 	void __iomem *base;
 
 	/*
+	 * Points at the right SMI instance to use.
+	 */
+	struct mv643xx_eth_shared_private *smi;
+
+	/*
 	 * Protects access to SMI_REG, which is shared between ports.
 	 */
 	struct mutex phy_lock;
@@ -345,7 +350,6 @@ struct mv643xx_eth_private {
 
 	struct net_device *dev;
 
-	struct mv643xx_eth_shared_private *shared_smi;
 	int phy_addr;
 
 	spinlock_t lock;
@@ -1015,7 +1019,7 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
 static int smi_reg_read(struct mv643xx_eth_private *mp,
 			unsigned int addr, unsigned int reg)
 {
-	struct mv643xx_eth_shared_private *msp = mp->shared_smi;
+	struct mv643xx_eth_shared_private *msp = mp->shared->smi;
 	void __iomem *smi_reg = msp->base + SMI_REG;
 	int ret;
 
@@ -1053,7 +1057,7 @@ out:
 static int smi_reg_write(struct mv643xx_eth_private *mp, unsigned int addr,
 			 unsigned int reg, unsigned int value)
 {
-	struct mv643xx_eth_shared_private *msp = mp->shared_smi;
+	struct mv643xx_eth_shared_private *msp = mp->shared->smi;
 	void __iomem *smi_reg = msp->base + SMI_REG;
 
 	mutex_lock(&msp->phy_lock);
@@ -2311,6 +2315,10 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
+	msp->smi = msp;
+	if (pd != NULL && pd->shared_smi != NULL)
+		msp->smi = platform_get_drvdata(pd->shared_smi);
+
 	mutex_init(&msp->phy_lock);
 
 	msp->err_interrupt = NO_IRQ;
@@ -2405,13 +2413,8 @@ static void set_params(struct mv643xx_eth_private *mp,
 		uc_addr_get(mp, dev->dev_addr);
 
 	if (pd->phy_addr == -1) {
-		mp->shared_smi = NULL;
 		mp->phy_addr = -1;
 	} else {
-		mp->shared_smi = mp->shared;
-		if (pd->shared_smi != NULL)
-			mp->shared_smi = platform_get_drvdata(pd->shared_smi);
-
 		if (pd->force_phy_addr || pd->phy_addr) {
 			mp->phy_addr = pd->phy_addr & 0x3f;
 			phy_addr_set(mp, mp->phy_addr);
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index eb78b00..12339eb 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -17,6 +17,7 @@
 
 struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
+	struct platform_device	*shared_smi;
 	unsigned int		t_clk;
 };
 
@@ -30,7 +31,6 @@ struct mv643xx_eth_platform_data {
 	/*
 	 * Whether a PHY is present, and if yes, at which address.
 	 */
-	struct platform_device	*shared_smi;
 	int			force_phy_addr;
 	int			phy_addr;
 
-- 
1.5.6.4

