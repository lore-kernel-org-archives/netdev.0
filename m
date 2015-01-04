From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v1 3/7] net: mii: extend link mode support to 48 bits
Date: Sun,  4 Jan 2015 12:56:53 -0800
Message-ID: <1420405017-23278-4-git-send-email-ddecotig@gmail.com>
References: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
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
In-Reply-To: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/mii.c   | 52 +++++++++++++++++++++++++++++-----------------------
 include/linux/mii.h | 31 ++++++++++++++++---------------
 2 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 4a99c39..2be59ba 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -33,7 +33,7 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 
-static u32 mii_get_an(struct mii_if_info *mii, u16 addr)
+static ethtool_link_mode_mask_t mii_get_an(struct mii_if_info *mii, u16 addr)
 {
 	int advert;
 
@@ -56,14 +56,15 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 {
 	struct net_device *dev = mii->dev;
 	u16 bmcr, bmsr, ctrl1000 = 0, stat1000 = 0;
-	u32 nego;
+	ethtool_link_mode_mask_t supported_link_modes, advertising_link_modes;
+	ethtool_link_mode_mask_t nego;
 
-	ecmd->supported =
+	supported_link_modes =
 	    (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 	     SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 	     SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII);
 	if (mii->supports_gmii)
-		ecmd->supported |= SUPPORTED_1000baseT_Half |
+		supported_link_modes |= SUPPORTED_1000baseT_Half |
 			SUPPORTED_1000baseT_Full;
 
 	/* only supports twisted-pair */
@@ -76,7 +77,7 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 	ecmd->phy_address = mii->phy_id;
 	ecmd->mdio_support = ETH_MDIO_SUPPORTS_C22;
 
-	ecmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
+	advertising_link_modes = ADVERTISED_TP | ADVERTISED_MII;
 
 	bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
 	bmsr = mii->mdio_read(dev, mii->phy_id, MII_BMSR);
@@ -85,23 +86,25 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 		stat1000 = mii->mdio_read(dev, mii->phy_id, MII_STAT1000);
 	}
 	if (bmcr & BMCR_ANENABLE) {
-		ecmd->advertising |= ADVERTISED_Autoneg;
+		ethtool_link_mode_mask_t lp_adv;
+
+		advertising_link_modes |= ADVERTISED_Autoneg;
 		ecmd->autoneg = AUTONEG_ENABLE;
 
-		ecmd->advertising |= mii_get_an(mii, MII_ADVERTISE);
+		advertising_link_modes |= mii_get_an(mii, MII_ADVERTISE);
 		if (mii->supports_gmii)
-			ecmd->advertising |=
+			advertising_link_modes |=
 					mii_ctrl1000_to_ethtool_adv_t(ctrl1000);
 
 		if (bmsr & BMSR_ANEGCOMPLETE) {
-			ecmd->lp_advertising = mii_get_an(mii, MII_LPA);
-			ecmd->lp_advertising |=
-					mii_stat1000_to_ethtool_lpa_t(stat1000);
+			lp_adv = mii_get_an(mii, MII_LPA);
+			lp_adv |= mii_stat1000_to_ethtool_lpa_t(stat1000);
 		} else {
-			ecmd->lp_advertising = 0;
+			lp_adv = 0;
 		}
 
-		nego = ecmd->advertising & ecmd->lp_advertising;
+		ethtool_cmd_lp_advertising_set(ecmd, lp_adv);
+		nego = advertising_link_modes & lp_adv;
 
 		if (nego & (ADVERTISED_1000baseT_Full |
 			    ADVERTISED_1000baseT_Half)) {
@@ -128,6 +131,8 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 	}
 
 	mii->full_duplex = ecmd->duplex;
+	ethtool_cmd_supported_set(ecmd, supported_link_modes);
+	ethtool_cmd_advertising_set(ecmd, advertising_link_modes);
 
 	/* ignore maxtxpkt, maxrxpkt for now */
 
@@ -168,13 +173,15 @@ int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		u32 bmcr, advert, tmp;
 		u32 advert2 = 0, tmp2 = 0;
-
-		if ((ecmd->advertising & (ADVERTISED_10baseT_Half |
-					  ADVERTISED_10baseT_Full |
-					  ADVERTISED_100baseT_Half |
-					  ADVERTISED_100baseT_Full |
-					  ADVERTISED_1000baseT_Half |
-					  ADVERTISED_1000baseT_Full)) == 0)
+		ethtool_link_mode_mask_t ethtool_adv;
+
+		ethtool_adv = ethtool_cmd_advertising(ecmd);
+		if ((ethtool_adv & (ADVERTISED_10baseT_Half |
+				    ADVERTISED_10baseT_Full |
+				    ADVERTISED_100baseT_Half |
+				    ADVERTISED_100baseT_Full |
+				    ADVERTISED_1000baseT_Half |
+				    ADVERTISED_1000baseT_Full)) == 0)
 			return -EINVAL;
 
 		/* advertise only what has been requested */
@@ -184,11 +191,10 @@ int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 			advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
 			tmp2 = advert2 & ~(ADVERTISE_1000HALF | ADVERTISE_1000FULL);
 		}
-		tmp |= ethtool_adv_to_mii_adv_t(ecmd->advertising);
+		tmp |= ethtool_adv_to_mii_adv_t(ethtool_adv);
 
 		if (mii->supports_gmii)
-			tmp2 |=
-			      ethtool_adv_to_mii_ctrl1000_t(ecmd->advertising);
+			tmp2 |= ethtool_adv_to_mii_ctrl1000_t(ethtool_adv);
 		if (advert != tmp) {
 			mii->mdio_write(dev, mii->phy_id, MII_ADVERTISE, tmp);
 			mii->advertising = tmp;
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 47492c9..6f5336c 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -106,7 +106,7 @@ static inline unsigned int mii_duplex (unsigned int duplex_lock,
  * settings to phy autonegotiation advertisements for the
  * MII_ADVERTISE register.
  */
-static inline u32 ethtool_adv_to_mii_adv_t(u32 ethadv)
+static inline u32 ethtool_adv_to_mii_adv_t(ethtool_link_mode_mask_t ethadv)
 {
 	u32 result = 0;
 
@@ -133,9 +133,9 @@ static inline u32 ethtool_adv_to_mii_adv_t(u32 ethadv)
  * A small helper function that translates MII_ADVERTISE bits
  * to ethtool advertisement settings.
  */
-static inline u32 mii_adv_to_ethtool_adv_t(u32 adv)
+static inline ethtool_link_mode_mask_t mii_adv_to_ethtool_adv_t(u32 adv)
 {
-	u32 result = 0;
+	ethtool_link_mode_mask_t result = 0;
 
 	if (adv & ADVERTISE_10HALF)
 		result |= ADVERTISED_10baseT_Half;
@@ -161,7 +161,8 @@ static inline u32 mii_adv_to_ethtool_adv_t(u32 adv)
  * settings to phy autonegotiation advertisements for the
  * MII_CTRL1000 register when in 1000T mode.
  */
-static inline u32 ethtool_adv_to_mii_ctrl1000_t(u32 ethadv)
+static inline u32
+ethtool_adv_to_mii_ctrl1000_t(ethtool_link_mode_mask_t ethadv)
 {
 	u32 result = 0;
 
@@ -181,9 +182,9 @@ static inline u32 ethtool_adv_to_mii_ctrl1000_t(u32 ethadv)
  * bits, when in 1000Base-T mode, to ethtool
  * advertisement settings.
  */
-static inline u32 mii_ctrl1000_to_ethtool_adv_t(u32 adv)
+static inline ethtool_link_mode_mask_t mii_ctrl1000_to_ethtool_adv_t(u32 adv)
 {
-	u32 result = 0;
+	ethtool_link_mode_mask_t result = 0;
 
 	if (adv & ADVERTISE_1000HALF)
 		result |= ADVERTISED_1000baseT_Half;
@@ -201,9 +202,9 @@ static inline u32 mii_ctrl1000_to_ethtool_adv_t(u32 adv)
  * bits, when in 1000Base-T mode, to ethtool
  * LP advertisement settings.
  */
-static inline u32 mii_lpa_to_ethtool_lpa_t(u32 lpa)
+static inline ethtool_link_mode_mask_t mii_lpa_to_ethtool_lpa_t(u32 lpa)
 {
-	u32 result = 0;
+	ethtool_link_mode_mask_t result = 0;
 
 	if (lpa & LPA_LPACK)
 		result |= ADVERTISED_Autoneg;
@@ -219,9 +220,9 @@ static inline u32 mii_lpa_to_ethtool_lpa_t(u32 lpa)
  * bits, when in 1000Base-T mode, to ethtool
  * advertisement settings.
  */
-static inline u32 mii_stat1000_to_ethtool_lpa_t(u32 lpa)
+static inline ethtool_link_mode_mask_t mii_stat1000_to_ethtool_lpa_t(u32 lpa)
 {
-	u32 result = 0;
+	ethtool_link_mode_mask_t result = 0;
 
 	if (lpa & LPA_1000HALF)
 		result |= ADVERTISED_1000baseT_Half;
@@ -239,7 +240,7 @@ static inline u32 mii_stat1000_to_ethtool_lpa_t(u32 lpa)
  * settings to phy autonegotiation advertisements for the
  * MII_CTRL1000 register when in 1000Base-X mode.
  */
-static inline u32 ethtool_adv_to_mii_adv_x(u32 ethadv)
+static inline u32 ethtool_adv_to_mii_adv_x(ethtool_link_mode_mask_t ethadv)
 {
 	u32 result = 0;
 
@@ -263,9 +264,9 @@ static inline u32 ethtool_adv_to_mii_adv_x(u32 ethadv)
  * bits, when in 1000Base-X mode, to ethtool
  * advertisement settings.
  */
-static inline u32 mii_adv_to_ethtool_adv_x(u32 adv)
+static inline ethtool_link_mode_mask_t mii_adv_to_ethtool_adv_x(u32 adv)
 {
-	u32 result = 0;
+	ethtool_link_mode_mask_t result = 0;
 
 	if (adv & ADVERTISE_1000XHALF)
 		result |= ADVERTISED_1000baseT_Half;
@@ -287,9 +288,9 @@ static inline u32 mii_adv_to_ethtool_adv_x(u32 adv)
  * bits, when in 1000Base-X mode, to ethtool
  * LP advertisement settings.
  */
-static inline u32 mii_lpa_to_ethtool_lpa_x(u32 lpa)
+static inline ethtool_link_mode_mask_t mii_lpa_to_ethtool_lpa_x(u32 lpa)
 {
-	u32 result = 0;
+	ethtool_link_mode_mask_t result = 0;
 
 	if (lpa & LPA_LPACK)
 		result |= ADVERTISED_Autoneg;
-- 
2.2.0.rc0.207.ga3a616c
