From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 3/8] net: phy: extend link mode support to 48 bits
Date: Mon,  5 Jan 2015 18:54:05 -0800
Message-ID: <1420512850-24699-4-git-send-email-ddecotig@gmail.com>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Cc: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Masatake YAMATO <yamato-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Xi Wang <xii-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>
To: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420512850-24699-1-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
---
 drivers/net/phy/phy.c        | 30 ++++++++++++++++--------------
 drivers/net/phy/phy_device.c |  4 ++--
 include/linux/phy.h          | 10 +++++-----
 3 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 767cd11..77d4eb9 100644
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
@@ -274,18 +275,19 @@ static void phy_sanitize_settings(struct phy_device *phydev)
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
 	u32 speed = ethtool_cmd_speed(cmd);
+	ethtool_link_mode_mask_t eth_adv = ethtool_cmd_advertising(cmd);
 
 	if (cmd->phy_address != phydev->addr)
 		return -EINVAL;
 
 	/* We make sure that we don't pass unsupported values in to the PHY */
-	cmd->advertising &= phydev->supported;
+	eth_adv &= phydev->supported;
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
+	if (cmd->autoneg == AUTONEG_ENABLE && eth_adv == 0)
 		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_DISABLE &&
@@ -300,7 +302,7 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	phydev->speed = speed;
 
-	phydev->advertising = cmd->advertising;
+	phydev->advertising = eth_adv;
 
 	if (AUTONEG_ENABLE == cmd->autoneg)
 		phydev->advertising |= ADVERTISED_Autoneg;
@@ -318,10 +320,10 @@ EXPORT_SYMBOL(phy_ethtool_sset);
 
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
@@ -1040,7 +1042,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
 	     phy_is_internal(phydev))) {
 		int eee_lp, eee_cap, eee_adv;
-		u32 lp, cap, adv;
+		ethtool_link_mode_mask_t cap, adv, lp;
 		int status;
 		unsigned int idx;
 
@@ -1132,21 +1134,21 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data)
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
@@ -1161,7 +1163,7 @@ EXPORT_SYMBOL(phy_ethtool_get_eee);
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
