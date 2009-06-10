From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/2] mdio: Expose 10GBASE-T MDI-X status via ethtool
Date: Wed, 10 Jun 2009 16:28:04 +0100
Message-ID: <1244647684.2848.8.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:52225 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752172AbZFJP2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 11:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is available in a standard MDIO register in 10GBASE-T PHYs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mdio.c   |   17 +++++++++++++++++
 include/linux/mdio.h |    9 +++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 6648303..dc45e98 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -296,6 +296,23 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 		ecmd->duplex = (reg & MDIO_CTRL1_FULLDPLX ||
 				ecmd->speed == SPEED_10000);
 	}
+
+	/* 10GBASE-T MDI/MDI-X */
+	if (ecmd->port == PORT_TP && ecmd->speed == SPEED_10000) {
+		switch (mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+					MDIO_PMA_10GBT_SWAPPOL)) {
+		case MDIO_PMA_10GBT_SWAPPOL_ABNX | MDIO_PMA_10GBT_SWAPPOL_CDNX:
+			ecmd->eth_tp_mdix = ETH_TP_MDI;
+			break;
+		case 0:
+			ecmd->eth_tp_mdix = ETH_TP_MDI_X;
+			break;
+		default:
+			/* It's complicated... */
+			ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+			break;
+		}
+	}
 }
 EXPORT_SYMBOL(mdio45_ethtool_gset_npage);
 
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 5685164..cfdf1df 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -45,6 +45,7 @@
 #define MDIO_PHYXS_LNSTAT	24	/* PHY XGXS lane state */
 
 /* Media-dependent registers. */
+#define MDIO_PMA_10GBT_SWAPPOL	130	/* 10GBASE-T pair swap & polarity */
 #define MDIO_PMA_10GBT_TXPWR	131	/* 10GBASE-T TX power control */
 #define MDIO_PMA_10GBT_SNR	133	/* 10GBASE-T SNR margin, lane A.
 					 * Lanes B-D are numbered 134-136. */
@@ -195,6 +196,14 @@
 #define MDIO_PHYXS_LNSTAT_SYNC3		0x0008
 #define MDIO_PHYXS_LNSTAT_ALIGN		0x1000
 
+/* PMA 10GBASE-T pair swap & polarity */
+#define MDIO_PMA_10GBT_SWAPPOL_ABNX	0x0001	/* Pair A/B uncrossed */
+#define MDIO_PMA_10GBT_SWAPPOL_CDNX	0x0002	/* Pair C/D uncrossed */
+#define MDIO_PMA_10GBT_SWAPPOL_AREV	0x0100	/* Pair A polarity reversed */
+#define MDIO_PMA_10GBT_SWAPPOL_BREV	0x0200	/* Pair B polarity reversed */
+#define MDIO_PMA_10GBT_SWAPPOL_CREV	0x0400	/* Pair C polarity reversed */
+#define MDIO_PMA_10GBT_SWAPPOL_DREV	0x0800	/* Pair D polarity reversed */
+
 /* PMA 10GBASE-T TX power register. */
 #define MDIO_PMA_10GBT_TXPWR_SHORT	0x0001	/* Short-reach mode */
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

