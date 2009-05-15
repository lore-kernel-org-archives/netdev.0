From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/3] sfc: Use generic XENPAK register definitions
Date: Fri, 15 May 2009 17:06:16 +0100
Message-ID: <1242403576.3262.4.camel@achroite>
References: <1242403452.3262.0.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:54120 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754652AbZEOQGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 12:06:17 -0400
In-Reply-To: <1242403452.3262.0.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |   16 +----------
 drivers/net/sfc/xenpack.h   |   57 -------------------------------------------
 drivers/net/sfc/xfp_phy.c   |    4 +-
 3 files changed, 4 insertions(+), 73 deletions(-)
 delete mode 100644 drivers/net/sfc/xenpack.h

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 0421190..db723c5 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -44,18 +44,6 @@
  */
 #define MAX_BAD_LP_TRIES	(5)
 
-/* LASI Control */
-#define PMA_PMD_LASI_CTRL	36866
-#define PMA_PMD_LASI_STATUS	36869
-#define PMA_PMD_LS_ALARM_LBN	0
-#define PMA_PMD_LS_ALARM_WIDTH	1
-#define PMA_PMD_TX_ALARM_LBN	1
-#define PMA_PMD_TX_ALARM_WIDTH	1
-#define PMA_PMD_RX_ALARM_LBN	2
-#define PMA_PMD_RX_ALARM_WIDTH	1
-#define PMA_PMD_AN_ALARM_LBN	3
-#define PMA_PMD_AN_ALARM_WIDTH	1
-
 /* Extended control register */
 #define PMA_PMD_XCONTROL_REG	49152
 #define PMA_PMD_EXT_GMII_EN_LBN	1
@@ -579,8 +567,8 @@ static void tenxpress_phy_poll(struct efx_nic *efx)
 			change = true;
 	} else {
 		int status = efx_mdio_read(efx, MDIO_MMD_PMAPMD,
-					   PMA_PMD_LASI_STATUS);
-		if (status & (1 << PMA_PMD_LS_ALARM_LBN))
+					   MDIO_PMA_LASI_STAT);
+		if (status & MDIO_PMA_LASI_LSALARM)
 			change = true;
 	}
 
diff --git a/drivers/net/sfc/xenpack.h b/drivers/net/sfc/xenpack.h
deleted file mode 100644
index 4e52286..0000000
--- a/drivers/net/sfc/xenpack.h
+++ /dev/null
@@ -1,57 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_XENPACK_H
-#define EFX_XENPACK_H
-
-/* Exported functions from Xenpack standard PHY control */
-
-#include "mdio_10g.h"
-
-/****************************************************************************/
-/* XENPACK MDIO register extensions */
-#define MDIO_XP_LASI_RX_CTRL	(0x9000)
-#define MDIO_XP_LASI_TX_CTRL	(0x9001)
-#define MDIO_XP_LASI_CTRL	(0x9002)
-#define MDIO_XP_LASI_RX_STAT	(0x9003)
-#define MDIO_XP_LASI_TX_STAT	(0x9004)
-#define MDIO_XP_LASI_STAT	(0x9005)
-
-/* Control/Status bits */
-#define XP_LASI_LS_ALARM	(1 << 0)
-#define XP_LASI_TX_ALARM	(1 << 1)
-#define XP_LASI_RX_ALARM	(1 << 2)
-/* These two are Quake vendor extensions to the standard XENPACK defines */
-#define XP_LASI_LS_INTB		(1 << 3)
-#define XP_LASI_TEST		(1 << 7)
-
-/* Enable LASI interrupts for PHY */
-static inline void xenpack_enable_lasi_irqs(struct efx_nic *efx)
-{
-	/* Read to clear LASI status register */
-	efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_STAT);
-
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_CTRL,
-		       XP_LASI_LS_ALARM);
-}
-
-/* Read the LASI interrupt status to clear the interrupt. */
-static inline int xenpack_clear_lasi_irqs(struct efx_nic *efx)
-{
-	/* Read to clear link status alarm */
-	return efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_STAT);
-}
-
-/* Turn off LASI interrupts */
-static inline void xenpack_disable_lasi_irqs(struct efx_nic *efx)
-{
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_CTRL, 0);
-}
-
-#endif /* EFX_XENPACK_H */
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index aad2dca..bb2e6af 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -15,7 +15,6 @@
 #include <linux/delay.h>
 #include "efx.h"
 #include "mdio_10g.h"
-#include "xenpack.h"
 #include "phy.h"
 #include "falcon.h"
 
@@ -169,7 +168,8 @@ static int xfp_phy_init(struct efx_nic *efx)
 
 static void xfp_phy_clear_interrupt(struct efx_nic *efx)
 {
-	xenpack_clear_lasi_irqs(efx);
+	/* Read to clear link status alarm */
+	efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT);
 }
 
 static int xfp_link_ok(struct efx_nic *efx)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

