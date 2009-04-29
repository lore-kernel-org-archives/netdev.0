From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/16] ethtool/mdio: Report MDIO mode support and link
	partner advertising
Date: Wed, 29 Apr 2009 19:21:53 +0100
Message-ID: <1241029313.3246.67.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jeff Garzik <jgarzik@pobox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:55766 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752035AbZD2SV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:21:57 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mdio_support and lp_advertising fields to ethtool_cmd.  Set these
in mdio45_ethtool_gset{,_npage}().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mdio.c      |   19 ++++++++++++-------
 include/linux/ethtool.h |    4 +++-
 include/linux/mdio.h    |    5 +++--
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 2fb0d16..ee383c2 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -173,6 +173,8 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 
 	ecmd->transceiver = XCVR_INTERNAL;
 	ecmd->phy_address = mdio->prtad;
+	ecmd->mdio_support =
+		mdio->mode_support & (MDIO_SUPPORTS_C45 | MDIO_SUPPORTS_C22);
 
 	reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
 			      MDIO_CTRL2);
@@ -235,16 +237,19 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 
 	if (ecmd->autoneg) {
 		u32 modes = 0;
+		int an_stat = mdio->mdio_read(mdio->dev, mdio->prtad,
+					      MDIO_MMD_AN, MDIO_STAT1);
 
 		/* If AN is complete and successful, report best common
 		 * mode, otherwise report best advertised mode. */
-		if (mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
-				    MDIO_STAT1) &
-		    MDIO_AN_STAT1_COMPLETE)
-			modes = (ecmd->advertising &
-				 (mdio45_get_an(mdio, MDIO_AN_LPA) |
-				  npage_lpa));
-		if (modes == 0)
+		if (an_stat & MDIO_AN_STAT1_COMPLETE) {
+			ecmd->lp_advertising =
+				mdio45_get_an(mdio, MDIO_AN_LPA) | npage_lpa;
+			if (an_stat & MDIO_AN_STAT1_LPABLE)
+				ecmd->lp_advertising |= ADVERTISED_Autoneg;
+			modes = ecmd->advertising & ecmd->lp_advertising;
+		}
+		if ((modes & ~ADVERTISED_Autoneg) == 0)
 			modes = ecmd->advertising;
 
 		if (modes & ADVERTISED_10000baseT_Full) {
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 5ccb6bd..14e6bc8 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -26,11 +26,13 @@ struct ethtool_cmd {
 	__u8	phy_address;
 	__u8	transceiver;	/* Which transceiver to use */
 	__u8	autoneg;	/* Enable or disable autonegotiation */
+	__u8	mdio_support;
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
 	__u16	reserved2;
-	__u32	reserved[3];
+	__u32	lp_advertising;	/* Features the link partner advertises */
+	__u32	reserved[2];
 };
 
 static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 5645c0f..1bff2f2 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -234,6 +234,9 @@ static inline __u16 mdio_phy_id_devad(int phy_id)
 	return phy_id & MDIO_PHY_ID_DEVAD;
 }
 
+#define MDIO_SUPPORTS_C22		1
+#define MDIO_SUPPORTS_C45		2
+
 #ifdef __KERNEL__ 
 
 /**
@@ -264,8 +267,6 @@ struct mdio_if_info {
 
 #define MDIO_PRTAD_NONE			(-1)
 #define MDIO_DEVAD_NONE			(-1)
-#define MDIO_SUPPORTS_C22		1
-#define MDIO_SUPPORTS_C45		2
 #define MDIO_EMULATE_C22		4
 
 struct ethtool_cmd;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

