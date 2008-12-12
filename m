From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/33] sfc: Remove MII extension cruft
Date: Fri, 12 Dec 2008 12:53:24 +0000
Message-ID: <20081212125323.GN10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:49411 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757203AbYLLMx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:53:27 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace efx_nic::link_options bitfield with link_speed (speed in
Mbit/s) and link_fd (full duplex flag).

Remove broken auto-negotiation functions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c         |   23 +------
 drivers/net/sfc/ethtool.c     |    1 -
 drivers/net/sfc/falcon.c      |   16 ++---
 drivers/net/sfc/falcon_xmac.c |    1 -
 drivers/net/sfc/gmii.h        |  137 +----------------------------------------
 drivers/net/sfc/net_driver.h  |    6 +-
 drivers/net/sfc/tenxpress.c   |    4 +-
 drivers/net/sfc/xfp_phy.c     |    4 +-
 8 files changed, 18 insertions(+), 174 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 183a440..844580f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -21,7 +21,6 @@
 #include <linux/ethtool.h>
 #include <linux/topology.h>
 #include "net_driver.h"
-#include "gmii.h"
 #include "ethtool.h"
 #include "tx.h"
 #include "rx.h"
@@ -551,26 +550,8 @@ static void efx_link_status_changed(struct efx_nic *efx)
 
 	/* Status message for kernel log */
 	if (efx->link_up) {
-		struct mii_if_info *gmii = &efx->mii;
-		unsigned adv, lpa;
-		/* NONE here means direct XAUI from the controller, with no
-		 * MDIO-attached device we can query. */
-		if (efx->phy_type != PHY_TYPE_NONE) {
-			adv = gmii_advertised(gmii);
-			lpa = gmii_lpa(gmii);
-		} else {
-			lpa = GM_LPA_10000 | LPA_DUPLEX;
-			adv = lpa;
-		}
-		EFX_INFO(efx, "link up at %dMbps %s-duplex "
-			 "(adv %04x lpa %04x) (MTU %d)%s\n",
-			 (efx->link_options & GM_LPA_10000 ? 10000 :
-			  (efx->link_options & GM_LPA_1000 ? 1000 :
-			   (efx->link_options & GM_LPA_100 ? 100 :
-			    10))),
-			 (efx->link_options & GM_LPA_DUPLEX ?
-			  "full" : "half"),
-			 adv, lpa,
+		EFX_INFO(efx, "link up at %uMbps %s-duplex (MTU %d)%s\n",
+			 efx->link_speed, efx->link_fd ? "full" : "half",
 			 efx->net_dev->mtu,
 			 (efx->promiscuous ? " [PROMISC]" : ""));
 	} else {
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 931ce14..43d6d8b 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -16,7 +16,6 @@
 #include "efx.h"
 #include "ethtool.h"
 #include "falcon.h"
-#include "gmii.h"
 #include "spi.h"
 #include "mac.h"
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index dbab9db..ac765cb 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -15,11 +15,11 @@
 #include <linux/seq_file.h>
 #include <linux/i2c.h>
 #include <linux/i2c-algo-bit.h>
+#include <linux/mii.h>
 #include "net_driver.h"
 #include "bitfield.h"
 #include "efx.h"
 #include "mac.h"
-#include "gmii.h"
 #include "spi.h"
 #include "falcon.h"
 #include "falcon_hwdefs.h"
@@ -1926,14 +1926,12 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	int link_speed;
 	bool tx_fc;
 
-	if (efx->link_options & GM_LPA_10000)
-		link_speed = 0x3;
-	else if (efx->link_options & GM_LPA_1000)
-		link_speed = 0x2;
-	else if (efx->link_options & GM_LPA_100)
-		link_speed = 0x1;
-	else
-		link_speed = 0x0;
+	switch (efx->link_speed) {
+	case 10000: link_speed = 3; break;
+	case 1000:  link_speed = 2; break;
+	case 100:   link_speed = 1; break;
+	default:    link_speed = 0; break;
+	}
 	/* MAC_LINK_STATUS controls MAC backpressure but doesn't work
 	 * as advertised.  Disable to ensure packets are not
 	 * indefinitely held and TX queue can be flushed at any point
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index d401231..4a54d09 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -15,7 +15,6 @@
 #include "falcon_hwdefs.h"
 #include "falcon_io.h"
 #include "mac.h"
-#include "gmii.h"
 #include "mdio_10g.h"
 #include "phy.h"
 #include "boards.h"
diff --git a/drivers/net/sfc/gmii.h b/drivers/net/sfc/gmii.h
index d25bbd1..dfccaa7 100644
--- a/drivers/net/sfc/gmii.h
+++ b/drivers/net/sfc/gmii.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006 Solarflare Communications Inc.
+ * Copyright 2006-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -57,139 +57,4 @@
 #define ISR_POLARITY_CHG	0x0002	/* Bit 1 - polarity changed */
 #define ISR_JABBER		0x0001	/* Bit 0 - jabber */
 
-/* Logically extended advertisement register */
-#define GM_ADVERTISE_SLCT		ADVERTISE_SLCT
-#define GM_ADVERTISE_CSMA		ADVERTISE_CSMA
-#define GM_ADVERTISE_10HALF		ADVERTISE_10HALF
-#define GM_ADVERTISE_1000XFULL		ADVERTISE_1000XFULL
-#define GM_ADVERTISE_10FULL		ADVERTISE_10FULL
-#define GM_ADVERTISE_1000XHALF		ADVERTISE_1000XHALF
-#define GM_ADVERTISE_100HALF		ADVERTISE_100HALF
-#define GM_ADVERTISE_1000XPAUSE		ADVERTISE_1000XPAUSE
-#define GM_ADVERTISE_100FULL		ADVERTISE_100FULL
-#define GM_ADVERTISE_1000XPSE_ASYM	ADVERTISE_1000XPSE_ASYM
-#define GM_ADVERTISE_100BASE4		ADVERTISE_100BASE4
-#define GM_ADVERTISE_PAUSE_CAP		ADVERTISE_PAUSE_CAP
-#define GM_ADVERTISE_PAUSE_ASYM		ADVERTISE_PAUSE_ASYM
-#define GM_ADVERTISE_RESV		ADVERTISE_RESV
-#define GM_ADVERTISE_RFAULT		ADVERTISE_RFAULT
-#define GM_ADVERTISE_LPACK		ADVERTISE_LPACK
-#define GM_ADVERTISE_NPAGE		ADVERTISE_NPAGE
-#define GM_ADVERTISE_1000FULL		(ADVERTISE_1000FULL << 8)
-#define GM_ADVERTISE_1000HALF		(ADVERTISE_1000HALF << 8)
-#define GM_ADVERTISE_1000		(GM_ADVERTISE_1000FULL | \
-					 GM_ADVERTISE_1000HALF)
-#define GM_ADVERTISE_FULL		(GM_ADVERTISE_1000FULL | \
-					 ADVERTISE_FULL)
-#define GM_ADVERTISE_ALL		(GM_ADVERTISE_1000FULL | \
-					 GM_ADVERTISE_1000HALF | \
-					 ADVERTISE_ALL)
-
-/* Logically extended link partner ability register */
-#define GM_LPA_SLCT			LPA_SLCT
-#define GM_LPA_10HALF			LPA_10HALF
-#define GM_LPA_1000XFULL		LPA_1000XFULL
-#define GM_LPA_10FULL			LPA_10FULL
-#define GM_LPA_1000XHALF		LPA_1000XHALF
-#define GM_LPA_100HALF			LPA_100HALF
-#define GM_LPA_1000XPAUSE		LPA_1000XPAUSE
-#define GM_LPA_100FULL			LPA_100FULL
-#define GM_LPA_1000XPAUSE_ASYM		LPA_1000XPAUSE_ASYM
-#define GM_LPA_100BASE4			LPA_100BASE4
-#define GM_LPA_PAUSE_CAP		LPA_PAUSE_CAP
-#define GM_LPA_PAUSE_ASYM		LPA_PAUSE_ASYM
-#define GM_LPA_RESV			LPA_RESV
-#define GM_LPA_RFAULT			LPA_RFAULT
-#define GM_LPA_LPACK			LPA_LPACK
-#define GM_LPA_NPAGE			LPA_NPAGE
-#define GM_LPA_1000FULL			(LPA_1000FULL << 6)
-#define GM_LPA_1000HALF			(LPA_1000HALF << 6)
-#define GM_LPA_10000FULL		0x00040000
-#define GM_LPA_10000HALF		0x00080000
-#define GM_LPA_DUPLEX			(GM_LPA_1000FULL | GM_LPA_10000FULL \
-					 | LPA_DUPLEX)
-#define GM_LPA_10			(LPA_10FULL | LPA_10HALF)
-#define GM_LPA_100			LPA_100
-#define GM_LPA_1000			(GM_LPA_1000FULL | GM_LPA_1000HALF)
-#define GM_LPA_10000			(GM_LPA_10000FULL | GM_LPA_10000HALF)
-
-/* Retrieve GMII autonegotiation advertised abilities
- *
- * The MII advertisment register (MII_ADVERTISE) is logically extended
- * to include advertisement bits ADVERTISE_1000FULL and
- * ADVERTISE_1000HALF from MII_CTRL1000.  The result can be tested
- * against the GM_ADVERTISE_xxx constants.
- */
-static inline unsigned int gmii_advertised(struct mii_if_info *gmii)
-{
-	unsigned int advertise;
-	unsigned int ctrl1000;
-
-	advertise = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_ADVERTISE);
-	ctrl1000 = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_CTRL1000);
-	return (((ctrl1000 << 8) & GM_ADVERTISE_1000) | advertise);
-}
-
-/* Retrieve GMII autonegotiation link partner abilities
- *
- * The MII link partner ability register (MII_LPA) is logically
- * extended by adding bits LPA_1000HALF and LPA_1000FULL from
- * MII_STAT1000.  The result can be tested against the GM_LPA_xxx
- * constants.
- */
-static inline unsigned int gmii_lpa(struct mii_if_info *gmii)
-{
-	unsigned int lpa;
-	unsigned int stat1000;
-
-	lpa = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_LPA);
-	stat1000 = gmii->mdio_read(gmii->dev, gmii->phy_id, MII_STAT1000);
-	return (((stat1000 << 6) & GM_LPA_1000) | lpa);
-}
-
-/* Calculate GMII autonegotiated link technology
- *
- * "negotiated" should be the result of gmii_advertised() logically
- * ANDed with the result of gmii_lpa().
- *
- * "tech" will be negotiated with the unused bits masked out.  For
- * example, if both ends of the link are capable of both
- * GM_LPA_1000FULL and GM_LPA_100FULL, GM_LPA_100FULL will be masked
- * out.
- */
-static inline unsigned int gmii_nway_result(unsigned int negotiated)
-{
-	unsigned int other_bits;
-
-	/* Mask out the speed and duplexity bits */
-	other_bits = negotiated & ~(GM_LPA_10 | GM_LPA_100 | GM_LPA_1000);
-
-	if (negotiated & GM_LPA_1000FULL)
-		return (other_bits | GM_LPA_1000FULL);
-	else if (negotiated & GM_LPA_1000HALF)
-		return (other_bits | GM_LPA_1000HALF);
-	else
-		return (other_bits | mii_nway_result(negotiated));
-}
-
-/* Calculate GMII non-autonegotiated link technology
- *
- * This provides an equivalent to gmii_nway_result for the case when
- * autonegotiation is disabled.
- */
-static inline unsigned int gmii_forced_result(unsigned int bmcr)
-{
-	unsigned int result;
-	int full_duplex;
-
-	full_duplex = bmcr & BMCR_FULLDPLX;
-	if (bmcr & BMCR_SPEED1000)
-		result = full_duplex ? GM_LPA_1000FULL : GM_LPA_1000HALF;
-	else if (bmcr & BMCR_SPEED100)
-		result = full_duplex ? GM_LPA_100FULL : GM_LPA_100HALF;
-	else
-		result = full_duplex ? GM_LPA_10FULL : GM_LPA_10HALF;
-	return result;
-}
-
 #endif /* EFX_GMII_H */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index abff908..6cac5ed 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -694,7 +694,8 @@ union efx_multicast_hash {
  * @mii: PHY interface
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
  * @link_up: Link status
- * @link_options: Link options (MII/GMII format)
+ * @link_fd: Link is full duplex
+ * @link_speed: Link speed (Mbps)
  * @n_link_state_changes: Number of times the link has changed state
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
  * @multicast_hash: Multicast hash table
@@ -772,7 +773,8 @@ struct efx_nic {
 	enum efx_phy_mode phy_mode;
 
 	bool link_up;
-	unsigned int link_options;
+	bool link_fd;
+	unsigned int link_speed;
 	unsigned int n_link_state_changes;
 
 	bool promiscuous;
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 8d41c29..3fa7ccb 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -10,7 +10,6 @@
 #include <linux/delay.h>
 #include <linux/seq_file.h>
 #include "efx.h"
-#include "gmii.h"
 #include "mdio_10g.h"
 #include "falcon.h"
 #include "phy.h"
@@ -362,7 +361,8 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 	phy_data->loopback_mode = efx->loopback_mode;
 	phy_data->phy_mode = efx->phy_mode;
 	efx->link_up = tenxpress_link_ok(efx, false);
-	efx->link_options = GM_LPA_10000FULL;
+	efx->link_speed = 10000;
+	efx->link_fd = true;
 }
 
 static void tenxpress_phy_clear_interrupt(struct efx_nic *efx)
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 91f0246..971a24b 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -14,7 +14,6 @@
 #include <linux/timer.h>
 #include <linux/delay.h>
 #include "efx.h"
-#include "gmii.h"
 #include "mdio_10g.h"
 #include "xenpack.h"
 #include "phy.h"
@@ -154,7 +153,8 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 
 	phy_data->phy_mode = efx->phy_mode;
 	efx->link_up = xfp_link_ok(efx);
-	efx->link_options = GM_LPA_10000FULL;
+	efx->link_speed = 10000;
+	efx->link_fd = true;
 }
 
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
