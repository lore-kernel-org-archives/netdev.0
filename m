From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v1 2/7] net: phy: extend link mode support to 48 bits
Date: Sun,  4 Jan 2015 12:56:52 -0800
Message-ID: <1420405017-23278-3-git-send-email-ddecotig@gmail.com>
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
 drivers/net/phy/phy.c        | 29 ++++++++++++++---------------
 drivers/net/phy/phy_device.c |  4 ++--
 include/linux/phy.h          | 10 +++++-----
 3 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 767cd11..e9c8499 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -132,7 +132,7 @@ static inline int phy_aneg_done(struct phy_device *phydev)
 struct phy_setting {
 	int speed;
 	int duplex;
-	u32 setting;
+	ethtool_link_mode_mask_t setting;
 };
 
 /* A mapping of all SUPPORTED settings to speed/duplex */
@@ -227,7 +227,8 @@ static inline unsigned int phy_find_setting(int speed, int duplex)
  *   the mask in features.  Returns the index of the last setting
  *   if nothing else matches.
  */
-static inline unsigned int phy_find_valid(unsigned int idx, u32 features)
+static inline unsigned int phy_find_valid(unsigned int idx,
+					  ethtool_link_mode_mask_t features)
 {
 	while (idx < MAX_NUM_SETTINGS && !(settings[idx].setting & features))
 		idx++;
@@ -245,7 +246,7 @@ static inline unsigned int phy_find_valid(unsigned int idx, u32 features)
  */
 static void phy_sanitize_settings(struct phy_device *phydev)
 {
-	u32 features = phydev->supported;
+	ethtool_link_mode_mask_t features = phydev->supported;
 	unsigned int idx;
 
 	/* Sanitize settings based on PHY capabilities */
@@ -279,13 +280,13 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 		return -EINVAL;
 
 	/* We make sure that we don't pass unsupported values in to the PHY */
-	cmd->advertising &= phydev->supported;
+	phydev->advertising = ethtool_cmd_advertising(cmd) & phydev->supported;
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
+	if (cmd->autoneg == AUTONEG_ENABLE && phydev->advertising == 0)
 		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_DISABLE &&
@@ -300,8 +301,6 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	phydev->speed = speed;
 
-	phydev->advertising = cmd->advertising;
-
 	if (AUTONEG_ENABLE == cmd->autoneg)
 		phydev->advertising |= ADVERTISED_Autoneg;
 	else
@@ -318,10 +317,10 @@ EXPORT_SYMBOL(phy_ethtool_sset);
 
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
-	cmd->supported = phydev->supported;
+	ethtool_cmd_supported_set(cmd, phydev->supported);
 
-	cmd->advertising = phydev->advertising;
-	cmd->lp_advertising = phydev->lp_advertising;
+	ethtool_cmd_advertising_set(cmd, phydev->advertising);
+	ethtool_cmd_lp_advertising_set(cmd, phydev->lp_advertising);
 
 	ethtool_cmd_speed_set(cmd, phydev->speed);
 	cmd->duplex = phydev->duplex;
@@ -1040,7 +1039,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
 	     phy_is_internal(phydev))) {
 		int eee_lp, eee_cap, eee_adv;
-		u32 lp, cap, adv;
+		ethtool_link_mode_mask_t cap, adv, lp;
 		int status;
 		unsigned int idx;
 
@@ -1132,21 +1131,21 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data)
 				    MDIO_MMD_PCS, phydev->addr);
 	if (val < 0)
 		return val;
-	data->supported = mmd_eee_cap_to_ethtool_sup_t(val);
+	ethtool_eee_supported_set(data, mmd_eee_cap_to_ethtool_sup_t(val));
 
 	/* Get advertisement EEE */
 	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
 				    MDIO_MMD_AN, phydev->addr);
 	if (val < 0)
 		return val;
-	data->advertised = mmd_eee_adv_to_ethtool_adv_t(val);
+	ethtool_eee_advertised_set(data, mmd_eee_adv_to_ethtool_adv_t(val));
 
 	/* Get LP advertisement EEE */
 	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
 				    MDIO_MMD_AN, phydev->addr);
 	if (val < 0)
 		return val;
-	data->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(val);
+	ethtool_eee_lp_advertised_set(data, mmd_eee_adv_to_ethtool_adv_t(val));
 
 	return 0;
 }
@@ -1161,7 +1160,7 @@ EXPORT_SYMBOL(phy_ethtool_get_eee);
  */
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
-	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
+	int val = ethtool_adv_to_mmd_eee_adv_t(ethtool_eee_advertised(data));
 
 	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
 			       phydev->addr, val);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3fc91e8..4391dc7 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -734,7 +734,7 @@ EXPORT_SYMBOL(phy_resume);
  */
 static int genphy_config_advert(struct phy_device *phydev)
 {
-	u32 advertise;
+	ethtool_link_mode_mask_t advertise;
 	int oldadv, adv, bmsr;
 	int err, changed = 0;
 
@@ -1086,7 +1086,7 @@ EXPORT_SYMBOL(genphy_soft_reset);
 int genphy_config_init(struct phy_device *phydev)
 {
 	int val;
-	u32 features;
+	ethtool_link_mode_mask_t features;
 
 	features = (SUPPORTED_TP | SUPPORTED_MII
 			| SUPPORTED_AUI | SUPPORTED_FIBRE |
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 22af8f8..aabf808 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -390,10 +390,10 @@ struct phy_device {
 	u32 interrupts;
 
 	/* Union of PHY and Attached devices' supported modes */
-	/* See mii.h for more info */
-	u32 supported;
-	u32 advertising;
-	u32 lp_advertising;
+	/* See ethtool.h for more info */
+	ethtool_link_mode_mask_t supported;
+	ethtool_link_mode_mask_t advertising;
+	ethtool_link_mode_mask_t lp_advertising;
 
 	int autoneg;
 
@@ -447,7 +447,7 @@ struct phy_driver {
 	u32 phy_id;
 	char *name;
 	unsigned int phy_id_mask;
-	u32 features;
+	ethtool_link_mode_mask_t features;
 	u32 flags;
 	const void *driver_data;
 
-- 
2.2.0.rc0.207.ga3a616c
