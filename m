From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 17/33] sfc: Clean up board identification
Date: Fri, 12 Dec 2008 12:54:19 +0000
Message-ID: <20081212125418.GQ10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:57020 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757321AbYLLMyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:54:23 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove kluge for development boards with unspecified board type.

Remove assumption of contiguous board type code assignments.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c |   68 ++++++++++++---------------------------------
 drivers/net/sfc/boards.h |    7 +---
 2 files changed, 20 insertions(+), 55 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index edf0262..08fa4e3 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007 Solarflare Communications Inc.
+ * Copyright 2007-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -231,70 +231,38 @@ static int sfe4002_init(struct efx_nic *efx)
 /* This will get expanded as board-specific details get moved out of the
  * PHY drivers. */
 struct efx_board_data {
+	enum efx_board_type type;
 	const char *ref_model;
 	const char *gen_type;
 	int (*init) (struct efx_nic *nic);
 };
 
-static int dummy_init(struct efx_nic *nic)
-{
-	return 0;
-}
 
 static struct efx_board_data board_data[] = {
-	[EFX_BOARD_INVALID] =
-	{NULL,	    NULL,                  dummy_init},
-	[EFX_BOARD_SFE4001] =
-	{"SFE4001", "10GBASE-T adapter",   sfe4001_init},
-	[EFX_BOARD_SFE4002] =
-	{"SFE4002", "XFP adapter",         sfe4002_init},
+	{ EFX_BOARD_SFE4001, "SFE4001", "10GBASE-T adapter", sfe4001_init },
+	{ EFX_BOARD_SFE4002, "SFE4002", "XFP adapter", sfe4002_init },
 };
 
-int efx_set_board_info(struct efx_nic *efx, u16 revision_info)
+void efx_set_board_info(struct efx_nic *efx, u16 revision_info)
 {
-	int rc = 0;
-	struct efx_board_data *data;
+	struct efx_board_data *data = NULL;
+	int i;
 
-	if (BOARD_TYPE(revision_info) >= EFX_BOARD_MAX) {
-		EFX_ERR(efx, "squashing unknown board type %d\n",
-			BOARD_TYPE(revision_info));
-		revision_info = 0;
-	}
-
-	if (BOARD_TYPE(revision_info) == 0) {
-		efx->board_info.major = 0;
-		efx->board_info.minor = 0;
-		/* For early boards that don't have revision info. there is
-		 * only 1 board for each PHY type, so we can work it out, with
-		 * the exception of the PHY-less boards. */
-		switch (efx->phy_type) {
-		case PHY_TYPE_10XPRESS:
-			efx->board_info.type = EFX_BOARD_SFE4001;
-			break;
-		case PHY_TYPE_XFP:
-			efx->board_info.type = EFX_BOARD_SFE4002;
-			break;
-		default:
-			efx->board_info.type = 0;
-			break;
-		}
-	} else {
-		efx->board_info.type = BOARD_TYPE(revision_info);
-		efx->board_info.major = BOARD_MAJOR(revision_info);
-		efx->board_info.minor = BOARD_MINOR(revision_info);
-	}
+	efx->board_info.type = BOARD_TYPE(revision_info);
+	efx->board_info.major = BOARD_MAJOR(revision_info);
+	efx->board_info.minor = BOARD_MINOR(revision_info);
 
-	data = &board_data[efx->board_info.type];
+	for (i = 0; i < ARRAY_SIZE(board_data); i++)
+		if (board_data[i].type == efx->board_info.type)
+			data = &board_data[i];
 
-	/* Report the board model number or generic type for recognisable
-	 * boards. */
-	if (efx->board_info.type != 0)
+	if (data) {
 		EFX_INFO(efx, "board is %s rev %c%d\n",
 			 (efx->pci_dev->subsystem_vendor == EFX_VENDID_SFC)
 			 ? data->ref_model : data->gen_type,
 			 'A' + efx->board_info.major, efx->board_info.minor);
-
-	efx->board_info.init = data->init;
-
-	return rc;
+		efx->board_info.init = data->init;
+	} else {
+		EFX_ERR(efx, "unknown board type %d\n", efx->board_info.type);
+	}
 }
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index c6e01b6..5e0dde5 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007 Solarflare Communications Inc.
+ * Copyright 2007-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -12,14 +12,11 @@
 
 /* Board IDs (must fit in 8 bits) */
 enum efx_board_type {
-	EFX_BOARD_INVALID = 0,
 	EFX_BOARD_SFE4001 = 1,   /* SFE4001 (10GBASE-T) */
 	EFX_BOARD_SFE4002 = 2,
-	/* Insert new types before here */
-	EFX_BOARD_MAX
 };
 
-extern int efx_set_board_info(struct efx_nic *efx, u16 revision_info);
+extern void efx_set_board_info(struct efx_nic *efx, u16 revision_info);
 extern int sfe4001_init(struct efx_nic *efx);
 
 #endif
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
