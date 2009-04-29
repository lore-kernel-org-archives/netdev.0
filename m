From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/16] ethtool/mdio: Support backplane mode negotiation
Date: Wed, 29 Apr 2009 19:25:57 +0100
Message-ID: <1241029557.3246.71.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jeff Garzik <jgarzik@pobox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60087 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755425AbZD2S0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:26:03 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This should be tested with some actual backplane-Ethernet hardware.  If
no-one does that I can resubmit just the header changes for now.

Ben.

 drivers/net/mdio.c      |   30 +++++++++++++++++++++++++-----
 include/linux/ethtool.h |   10 ++++++++++
 include/linux/mdio.h    |    5 +++++
 3 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index ee383c2..6648303 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -202,12 +202,29 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 		break;
 
 	case MDIO_PMA_CTRL2_10GBCX4:
+		ecmd->port = PORT_OTHER;
+		ecmd->supported = 0;
+		ecmd->advertising = 0;
+		break;
+
 	case MDIO_PMA_CTRL2_10GBKX4:
 	case MDIO_PMA_CTRL2_10GBKR:
 	case MDIO_PMA_CTRL2_1000BKX:
 		ecmd->port = PORT_OTHER;
-		ecmd->supported = 0;
-		ecmd->advertising = 0;
+		ecmd->supported = SUPPORTED_Backplane;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_PMA_EXTABLE);
+		if (reg & MDIO_PMA_EXTABLE_10GBKX4)
+			ecmd->supported |= SUPPORTED_10000baseKX4_Full;
+		if (reg & MDIO_PMA_EXTABLE_10GBKR)
+			ecmd->supported |= SUPPORTED_10000baseKR_Full;
+		if (reg & MDIO_PMA_EXTABLE_1000BKX)
+			ecmd->supported |= SUPPORTED_1000baseKX_Full;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_PMA_10GBR_FECABLE);
+		if (reg & MDIO_PMA_10GBR_FECABLE_ABLE)
+			ecmd->supported |= SUPPORTED_10000baseR_FEC;
+		ecmd->advertising = ADVERTISED_Backplane;
 		break;
 
 	/* All the other defined modes are flavours of optical */
@@ -252,13 +269,16 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 		if ((modes & ~ADVERTISED_Autoneg) == 0)
 			modes = ecmd->advertising;
 
-		if (modes & ADVERTISED_10000baseT_Full) {
+		if (modes & (ADVERTISED_10000baseT_Full |
+			     ADVERTISED_10000baseKX4_Full |
+			     ADVERTISED_10000baseKR_Full)) {
 			ecmd->speed = SPEED_10000;
 			ecmd->duplex = DUPLEX_FULL;
 		} else if (modes & (ADVERTISED_1000baseT_Full |
-				    ADVERTISED_1000baseT_Half)) {
+				    ADVERTISED_1000baseT_Half |
+				    ADVERTISED_1000baseKX_Full)) {
 			ecmd->speed = SPEED_1000;
-			ecmd->duplex = !!(modes & ADVERTISED_1000baseT_Full);
+			ecmd->duplex = !(modes & ADVERTISED_1000baseT_Half);
 		} else if (modes & (ADVERTISED_100baseT_Full |
 				    ADVERTISED_100baseT_Half)) {
 			ecmd->speed = SPEED_100;
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 14e6bc8..380b042 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -565,6 +565,11 @@ struct ethtool_ops {
 #define SUPPORTED_Pause			(1 << 13)
 #define SUPPORTED_Asym_Pause		(1 << 14)
 #define SUPPORTED_2500baseX_Full	(1 << 15)
+#define SUPPORTED_Backplane		(1 << 16)
+#define SUPPORTED_1000baseKX_Full	(1 << 17)
+#define SUPPORTED_10000baseKX4_Full	(1 << 18)
+#define SUPPORTED_10000baseKR_Full	(1 << 19)
+#define SUPPORTED_10000baseR_FEC	(1 << 20)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -583,6 +588,11 @@ struct ethtool_ops {
 #define ADVERTISED_Pause		(1 << 13)
 #define ADVERTISED_Asym_Pause		(1 << 14)
 #define ADVERTISED_2500baseX_Full	(1 << 15)
+#define ADVERTISED_Backplane		(1 << 16)
+#define ADVERTISED_1000baseKX_Full	(1 << 17)
+#define ADVERTISED_10000baseKX4_Full	(1 << 18)
+#define ADVERTISED_10000baseKR_Full	(1 << 19)
+#define ADVERTISED_10000baseR_FEC	(1 << 20)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 1bff2f2..26b4eb3 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -46,6 +46,7 @@
 
 /* Media-dependent registers. */
 #define MDIO_PMA_10GBT_TXPWR	131	/* 10GBASE-T TX power control */
+#define MDIO_PMA_10GBR_FECABLE	170	/* 10GBASE-R FEC ability */
 #define MDIO_PCS_10GBX_STAT1	24	/* 10GBASE-X PCS status 1 */
 #define MDIO_PCS_10GBRT_STAT1	32	/* 10GBASE-R/-T PCS status 1 */
 #define MDIO_PCS_10GBRT_STAT2	33	/* 10GBASE-R/-T PCS status 2 */
@@ -187,6 +188,10 @@
 /* PMA 10GBASE-T TX power register. */
 #define MDIO_PMA_10GBT_TXPWR_SHORT	0x0001	/* Short-reach mode */
 
+/* PMA 10GBASE-R FEC ability register. */
+#define MDIO_PMA_10GBR_FECABLE_ABLE	0x0001	/* FEC ability */
+#define MDIO_PMA_10GBR_FECABLE_ERRABLE	0x0002	/* FEC error indic. ability */
+
 /* PCS 10GBASE-R/-T status register 1. */
 #define MDIO_PCS_10GBRT_STAT1_BLKLK	0x0001	/* Block lock attained */
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

