From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/27] sfc: Rename Falcon-specific board code and types
Date: Fri, 23 Oct 2009 19:29:16 +0100
Message-ID: <1256322556.2785.9.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8536 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbZJWS3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:29:14 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Siena will require entirely different board code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Makefile                      |    2 +-
 drivers/net/sfc/boards.h                      |   10 +-----
 drivers/net/sfc/falcon.c                      |    2 +-
 drivers/net/sfc/{boards.c => falcon_boards.c} |   35 ++++++++++++++----------
 drivers/net/sfc/sfe4001.c                     |    2 +-
 5 files changed, 25 insertions(+), 26 deletions(-)
 rename drivers/net/sfc/{boards.c => falcon_boards.c} (90%)

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index b89f9be..eb217d3 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,6 +1,6 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_gmac.o \
 			   falcon_xmac.o selftest.o ethtool.o xfp_phy.o \
-			   mdio_10g.o tenxpress.o boards.o sfe4001.o
+			   mdio_10g.o tenxpress.o falcon_boards.o sfe4001.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index 44942de..c1a5710 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -10,15 +10,9 @@
 #ifndef EFX_BOARDS_H
 #define EFX_BOARDS_H
 
-/* Board IDs (must fit in 8 bits) */
-enum efx_board_type {
-	EFX_BOARD_SFE4001 = 1,
-	EFX_BOARD_SFE4002 = 2,
-	EFX_BOARD_SFN4111T = 0x51,
-	EFX_BOARD_SFN4112F = 0x52,
-};
+#define FALCON_BOARD_SFE4001 0x01
 
-extern void efx_set_board_info(struct efx_nic *efx, u16 revision_info);
+extern void falcon_probe_board(struct efx_nic *efx, u16 revision_info);
 
 /* SFE4001 (10GBASE-T) */
 extern int sfe4001_init(struct efx_nic *efx);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 57898fd..abc6b63 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2732,7 +2732,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 
 	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mdio.prtad);
 
-	efx_set_board_info(efx, board_rev);
+	falcon_probe_board(efx, board_rev);
 
 	kfree(nvconfig);
 	return 0;
diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/falcon_boards.c
similarity index 90%
rename from drivers/net/sfc/boards.c
rename to drivers/net/sfc/falcon_boards.c
index 4a4c74c..431b74c 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -15,9 +15,14 @@
 
 /* Macros for unpacking the board revision */
 /* The revision info is in host byte order. */
-#define BOARD_TYPE(_rev) (_rev >> 8)
-#define BOARD_MAJOR(_rev) ((_rev >> 4) & 0xf)
-#define BOARD_MINOR(_rev) (_rev & 0xf)
+#define FALCON_BOARD_TYPE(_rev) (_rev >> 8)
+#define FALCON_BOARD_MAJOR(_rev) ((_rev >> 4) & 0xf)
+#define FALCON_BOARD_MINOR(_rev) (_rev & 0xf)
+
+/* Board types */
+#define FALCON_BOARD_SFE4002 0x02
+#define FALCON_BOARD_SFN4111T 0x51
+#define FALCON_BOARD_SFN4112F 0x52
 
 /* Blink support. If the PHY has no auto-blink mode so we hang it off a timer */
 #define BLINK_INTERVAL (HZ/2)
@@ -286,31 +291,31 @@ static int sfn4112f_init(struct efx_nic *efx)
 
 /* This will get expanded as board-specific details get moved out of the
  * PHY drivers. */
-struct efx_board_data {
-	enum efx_board_type type;
+struct falcon_board_data {
+	u8 type;
 	const char *ref_model;
 	const char *gen_type;
 	int (*init) (struct efx_nic *nic);
 };
 

-static struct efx_board_data board_data[] = {
-	{ EFX_BOARD_SFE4001, "SFE4001", "10GBASE-T adapter", sfe4001_init },
-	{ EFX_BOARD_SFE4002, "SFE4002", "XFP adapter", sfe4002_init },
-	{ EFX_BOARD_SFN4111T, "SFN4111T", "100/1000/10GBASE-T adapter",
+static struct falcon_board_data board_data[] = {
+	{ FALCON_BOARD_SFE4001, "SFE4001", "10GBASE-T adapter", sfe4001_init },
+	{ FALCON_BOARD_SFE4002, "SFE4002", "XFP adapter", sfe4002_init },
+	{ FALCON_BOARD_SFN4111T, "SFN4111T", "100/1000/10GBASE-T adapter",
 	  sfn4111t_init },
-	{ EFX_BOARD_SFN4112F, "SFN4112F", "SFP+ adapter",
+	{ FALCON_BOARD_SFN4112F, "SFN4112F", "SFP+ adapter",
 	  sfn4112f_init },
 };
 
-void efx_set_board_info(struct efx_nic *efx, u16 revision_info)
+void falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 {
-	struct efx_board_data *data = NULL;
+	struct falcon_board_data *data = NULL;
 	int i;
 
-	efx->board_info.type = BOARD_TYPE(revision_info);
-	efx->board_info.major = BOARD_MAJOR(revision_info);
-	efx->board_info.minor = BOARD_MINOR(revision_info);
+	efx->board_info.type = FALCON_BOARD_TYPE(revision_info);
+	efx->board_info.major = FALCON_BOARD_MAJOR(revision_info);
+	efx->board_info.minor = FALCON_BOARD_MINOR(revision_info);
 
 	for (i = 0; i < ARRAY_SIZE(board_data); i++)
 		if (board_data[i].type == efx->board_info.type)
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index cee00ad..28a5504 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -241,7 +241,7 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 		efx->phy_mode = new_mode;
 		if (new_mode & PHY_MODE_SPECIAL)
 			efx_stats_disable(efx);
-		if (efx->board_info.type == EFX_BOARD_SFE4001)
+		if (efx->board_info.type == FALCON_BOARD_SFE4001)
 			err = sfe4001_poweron(efx);
 		else
 			err = sfn4111t_reset(efx);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

