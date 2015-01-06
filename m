From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v2 5/8] net: mdio: extend link mode support to 48 bits
Date: Mon,  5 Jan 2015 18:54:07 -0800
Message-ID: <1420512850-24699-6-git-send-email-ddecotig@gmail.com>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Cc: David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: Amir Vadai <amirv@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/mdio.c   | 59 +++++++++++++++++++++++++++++-----------------------
 include/linux/mdio.h | 15 +++++++------
 2 files changed, 42 insertions(+), 32 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 3e027ed..5cac2ac 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -148,9 +148,10 @@ int mdio45_nway_restart(const struct mdio_if_info *mdio)
 }
 EXPORT_SYMBOL(mdio45_nway_restart);
 
-static u32 mdio45_get_an(const struct mdio_if_info *mdio, u16 addr)
+static ethtool_link_mode_mask_t
+mdio45_get_an(const struct mdio_if_info *mdio, u16 addr)
 {
-	u32 result = 0;
+	ethtool_link_mode_mask_t result = 0;
 	int reg;
 
 	reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN, addr);
@@ -185,9 +186,11 @@ static u32 mdio45_get_an(const struct mdio_if_info *mdio, u16 addr)
  */
 void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 			       struct ethtool_cmd *ecmd,
-			       u32 npage_adv, u32 npage_lpa)
+			       ethtool_link_mode_mask_t npage_adv,
+			       ethtool_link_mode_mask_t npage_lpa)
 {
 	int reg;
+	ethtool_link_mode_mask_t supported_link_modes, advertising_link_modes;
 	u32 speed;
 
 	BUILD_BUG_ON(MDIO_SUPPORTS_C22 != ETH_MDIO_SUPPORTS_C22);
@@ -206,64 +209,64 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 	case MDIO_PMA_CTRL2_100BTX:
 	case MDIO_PMA_CTRL2_10BT:
 		ecmd->port = PORT_TP;
-		ecmd->supported = SUPPORTED_TP;
+		supported_link_modes = SUPPORTED_TP;
 		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
 				      MDIO_SPEED);
 		if (reg & MDIO_SPEED_10G)
-			ecmd->supported |= SUPPORTED_10000baseT_Full;
+			supported_link_modes |= SUPPORTED_10000baseT_Full;
 		if (reg & MDIO_PMA_SPEED_1000)
-			ecmd->supported |= (SUPPORTED_1000baseT_Full |
+			supported_link_modes |= (SUPPORTED_1000baseT_Full |
 					    SUPPORTED_1000baseT_Half);
 		if (reg & MDIO_PMA_SPEED_100)
-			ecmd->supported |= (SUPPORTED_100baseT_Full |
+			supported_link_modes |= (SUPPORTED_100baseT_Full |
 					    SUPPORTED_100baseT_Half);
 		if (reg & MDIO_PMA_SPEED_10)
-			ecmd->supported |= (SUPPORTED_10baseT_Full |
+			supported_link_modes |= (SUPPORTED_10baseT_Full |
 					    SUPPORTED_10baseT_Half);
-		ecmd->advertising = ADVERTISED_TP;
+		advertising_link_modes = ADVERTISED_TP;
 		break;
 
 	case MDIO_PMA_CTRL2_10GBCX4:
 		ecmd->port = PORT_OTHER;
-		ecmd->supported = 0;
-		ecmd->advertising = 0;
+		supported_link_modes = 0;
+		advertising_link_modes = 0;
 		break;
 
 	case MDIO_PMA_CTRL2_10GBKX4:
 	case MDIO_PMA_CTRL2_10GBKR:
 	case MDIO_PMA_CTRL2_1000BKX:
 		ecmd->port = PORT_OTHER;
-		ecmd->supported = SUPPORTED_Backplane;
+		supported_link_modes = SUPPORTED_Backplane;
 		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
 				      MDIO_PMA_EXTABLE);
 		if (reg & MDIO_PMA_EXTABLE_10GBKX4)
-			ecmd->supported |= SUPPORTED_10000baseKX4_Full;
+			supported_link_modes |= SUPPORTED_10000baseKX4_Full;
 		if (reg & MDIO_PMA_EXTABLE_10GBKR)
-			ecmd->supported |= SUPPORTED_10000baseKR_Full;
+			supported_link_modes |= SUPPORTED_10000baseKR_Full;
 		if (reg & MDIO_PMA_EXTABLE_1000BKX)
-			ecmd->supported |= SUPPORTED_1000baseKX_Full;
+			supported_link_modes |= SUPPORTED_1000baseKX_Full;
 		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
 				      MDIO_PMA_10GBR_FECABLE);
 		if (reg & MDIO_PMA_10GBR_FECABLE_ABLE)
-			ecmd->supported |= SUPPORTED_10000baseR_FEC;
-		ecmd->advertising = ADVERTISED_Backplane;
+			supported_link_modes |= SUPPORTED_10000baseR_FEC;
+		advertising_link_modes = ADVERTISED_Backplane;
 		break;
 
 	/* All the other defined modes are flavours of optical */
 	default:
 		ecmd->port = PORT_FIBRE;
-		ecmd->supported = SUPPORTED_FIBRE;
-		ecmd->advertising = ADVERTISED_FIBRE;
+		supported_link_modes = SUPPORTED_FIBRE;
+		advertising_link_modes = ADVERTISED_FIBRE;
 		break;
 	}
 
 	if (mdio->mmds & MDIO_DEVS_AN) {
-		ecmd->supported |= SUPPORTED_Autoneg;
+		supported_link_modes |= SUPPORTED_Autoneg;
 		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
 				      MDIO_CTRL1);
 		if (reg & MDIO_AN_CTRL1_ENABLE) {
 			ecmd->autoneg = AUTONEG_ENABLE;
-			ecmd->advertising |=
+			advertising_link_modes |=
 				ADVERTISED_Autoneg |
 				mdio45_get_an(mdio, MDIO_AN_ADVERTISE) |
 				npage_adv;
@@ -275,21 +278,22 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 	}
 
 	if (ecmd->autoneg) {
-		u32 modes = 0;
+		ethtool_link_mode_mask_t modes = 0;
 		int an_stat = mdio->mdio_read(mdio->dev, mdio->prtad,
 					      MDIO_MMD_AN, MDIO_STAT1);
 
 		/* If AN is complete and successful, report best common
 		 * mode, otherwise report best advertised mode. */
 		if (an_stat & MDIO_AN_STAT1_COMPLETE) {
-			ecmd->lp_advertising =
+			ethtool_link_mode_mask_t lp_adv =
 				mdio45_get_an(mdio, MDIO_AN_LPA) | npage_lpa;
 			if (an_stat & MDIO_AN_STAT1_LPABLE)
-				ecmd->lp_advertising |= ADVERTISED_Autoneg;
-			modes = ecmd->advertising & ecmd->lp_advertising;
+				lp_adv |= ADVERTISED_Autoneg;
+			ethtool_cmd_lp_advertising_set(ecmd, lp_adv);
+			modes = advertising_link_modes & lp_adv;
 		}
 		if ((modes & ~ADVERTISED_Autoneg) == 0)
-			modes = ecmd->advertising;
+			modes = advertising_link_modes;
 
 		if (modes & (ADVERTISED_10000baseT_Full |
 			     ADVERTISED_10000baseKX4_Full |
@@ -338,6 +342,9 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 			break;
 		}
 	}
+
+	ethtool_cmd_supported_set(ecmd, supported_link_modes);
+	ethtool_cmd_advertising_set(ecmd, advertising_link_modes);
 }
 EXPORT_SYMBOL(mdio45_ethtool_gset_npage);
 
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index b42963b..18c649a 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -69,7 +69,8 @@ extern int mdio45_links_ok(const struct mdio_if_info *mdio, u32 mmds);
 extern int mdio45_nway_restart(const struct mdio_if_info *mdio);
 extern void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 				      struct ethtool_cmd *ecmd,
-				      u32 npage_adv, u32 npage_lpa);
+				      ethtool_link_mode_mask_t npage_adv,
+				      ethtool_link_mode_mask_t npage_lpa);
 
 /**
  * mdio45_ethtool_gset - get settings for ETHTOOL_GSET
@@ -97,9 +98,10 @@ extern int mdio_mii_ioctl(const struct mdio_if_info *mdio,
  * A small helper function that translates MMD EEE Capability (3.20) bits
  * to ethtool supported settings.
  */
-static inline u32 mmd_eee_cap_to_ethtool_sup_t(u16 eee_cap)
+static inline ethtool_link_mode_mask_t
+mmd_eee_cap_to_ethtool_sup_t(u16 eee_cap)
 {
-	u32 supported = 0;
+	ethtool_link_mode_mask_t supported = 0;
 
 	if (eee_cap & MDIO_EEE_100TX)
 		supported |= SUPPORTED_100baseT_Full;
@@ -125,9 +127,10 @@ static inline u32 mmd_eee_cap_to_ethtool_sup_t(u16 eee_cap)
  * and MMD EEE Link Partner Ability (7.61) bits to ethtool advertisement
  * settings.
  */
-static inline u32 mmd_eee_adv_to_ethtool_adv_t(u16 eee_adv)
+static inline ethtool_link_mode_mask_t
+mmd_eee_adv_to_ethtool_adv_t(u16 eee_adv)
 {
-	u32 adv = 0;
+	ethtool_link_mode_mask_t adv = 0;
 
 	if (eee_adv & MDIO_EEE_100TX)
 		adv |= ADVERTISED_100baseT_Full;
@@ -153,7 +156,7 @@ static inline u32 mmd_eee_adv_to_ethtool_adv_t(u16 eee_adv)
  * to EEE advertisements for the MMD EEE Advertisement (7.60) and
  * MMD EEE Link Partner Ability (7.61) registers.
  */
-static inline u16 ethtool_adv_to_mmd_eee_adv_t(u32 adv)
+static inline u16 ethtool_adv_to_mmd_eee_adv_t(ethtool_link_mode_mask_t adv)
 {
 	u16 reg = 0;
 
-- 
2.2.0.rc0.207.ga3a616c
