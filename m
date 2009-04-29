From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/16] s2io: Use generic MDIO definitions
Date: Wed, 29 Apr 2009 19:13:29 +0100
Message-ID: <1241028809.3246.52.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	Santosh Rastapur <santosh.rastapur@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:35991 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756349AbZD2SNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:13:37 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/s2io-regs.h |    5 -----
 drivers/net/s2io.c      |   21 +++++++++++----------
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/net/s2io-regs.h b/drivers/net/s2io-regs.h
index f8274f8..416669f 100644
--- a/drivers/net/s2io-regs.h
+++ b/drivers/net/s2io-regs.h
@@ -271,11 +271,6 @@ struct XENA_dev_config {
 	u64 mdio_control;
 #define MDIO_MMD_INDX_ADDR(val)		vBIT(val, 0, 16)
 #define MDIO_MMD_DEV_ADDR(val)		vBIT(val, 19, 5)
-#define MDIO_MMD_PMA_DEV_ADDR		0x1
-#define MDIO_MMD_PMD_DEV_ADDR		0x1
-#define MDIO_MMD_WIS_DEV_ADDR		0x2
-#define MDIO_MMD_PCS_DEV_ADDR		0x3
-#define MDIO_MMD_PHYXS_DEV_ADDR		0x4
 #define MDIO_MMS_PRT_ADDR(val)		vBIT(val, 27, 5)
 #define MDIO_CTRL_START_TRANS(val)	vBIT(val, 56, 4)
 #define MDIO_OP(val)			vBIT(val, 60, 2)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 1a4979f..80562ea 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -63,6 +63,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/mdio.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/delay.h>
@@ -3328,9 +3329,9 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	struct stat_block *stat_info = sp->mac_control.stats_info;
 
 	/* Check the communication with the MDIO slave */
-	addr = 0x0000;
+	addr = MDIO_CTRL1;
 	val64 = 0x0;
-	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
 	if((val64 == 0xFFFF) || (val64 == 0x0000))
 	{
 		DBG_PRINT(ERR_DBG, "ERR: MDIO slave access failed - "
@@ -3338,24 +3339,24 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 		return;
 	}
 
-	/* Check for the expecte value of 2040 at PMA address 0x0000 */
-	if(val64 != 0x2040)
+	/* Check for the expected value of control reg 1 */
+	if(val64 != MDIO_CTRL1_SPEED10G)
 	{
 		DBG_PRINT(ERR_DBG, "Incorrect value at PMA address 0x0000 - ");
-		DBG_PRINT(ERR_DBG, "Returned: %llx- Expected: 0x2040\n",
-			  (unsigned long long)val64);
+		DBG_PRINT(ERR_DBG, "Returned: %llx- Expected: 0x%x\n",
+			  (unsigned long long)val64, MDIO_CTRL1_SPEED10G);
 		return;
 	}
 
 	/* Loading the DOM register to MDIO register */
 	addr = 0xA100;
-	s2io_mdio_write(MDIO_MMD_PMA_DEV_ADDR, addr, val16, dev);
-	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+	s2io_mdio_write(MDIO_MMD_PMAPMD, addr, val16, dev);
+	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
 
 	/* Reading the Alarm flags */
 	addr = 0xA070;
 	val64 = 0x0;
-	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
 
 	flag = CHECKBIT(val64, 0x7);
 	type = 1;
@@ -3387,7 +3388,7 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	/* Reading the Warning flags */
 	addr = 0xA074;
 	val64 = 0x0;
-	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
 
 	if(CHECKBIT(val64, 0x7))
 		stat_info->xpak_stat.warn_transceiver_temp_high++;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

