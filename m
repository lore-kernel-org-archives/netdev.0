From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v2 2/8] net: ethtool: extend link mode support to 48 bits
Date: Mon,  5 Jan 2015 18:54:04 -0800
Message-ID: <1420512850-24699-3-git-send-email-ddecotig@gmail.com>
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

This patch also ensures that requests from userspace asking to
advertise >= 32b link mode masks will be rejected, unless the driver
explicitly supports this.

Signed-off-by: David Decotigny <decot@googlers.com>
---
 include/linux/ethtool.h      |  12 +++-
 include/uapi/linux/ethtool.h | 131 ++++++++++++++++++++++++++++++++++++-------
 net/core/ethtool.c           |  44 +++++++++++++++
 3 files changed, 164 insertions(+), 23 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index dcb08c1..9baa80f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -45,15 +45,21 @@ extern int __ethtool_get_settings(struct net_device *dev,
 
 /**
  * enum ethtool_compat_flags - bit indices used for %get_compat_flags() bitmaps
- * @__ETHTOOL_COMPAT_PLACEHOLDER_BIT: to avoid a compiler error,
- *                                    superseded by next patches
+ * @ETHTOOL_COMPAT_SUPPORT_LINK_MODE_48b_BIT: when set, the driver
+ *      handles 48-bit link mode requests from userspace. In its
+ *      absence, the generic %ethtool_set_settings/%ethtool_set_eee
+ *      ioctl handlers will reject the request if user passed an
+ *      advertising link mode with any of the bits 32..47 set.
  */
 enum ethtool_compat_flags {
-	__ETHTOOL_COMPAT_PLACEHOLDER_BIT,
+	ETHTOOL_COMPAT_SUPPORT_LINK_MODE_48b_BIT,
 };
 
 #define __ETH_COMPAT_MASK(name)	(1UL << (ETHTOOL_COMPAT_ ## name ## _BIT))
 
+#define ETH_COMPAT_SUPPORT_LINK_MODE_48b	\
+	__ETH_COMPAT_MASK(SUPPORT_LINK_MODE_48b)
+
 /**
  * enum ethtool_phys_id_state - indicator state for physical identification
  * @ETHTOOL_ID_INACTIVE: Physical ID indicator should be deactivated
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index d063368..ab7c11d 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -23,14 +23,16 @@
 /**
  * struct ethtool_cmd - link control and status
  * @cmd: Command number = %ETHTOOL_GSET or %ETHTOOL_SSET
- * @supported: Bitmask of %SUPPORTED_* flags for the link modes,
- *	physical connectors and other link features for which the
- *	interface supports autonegotiation or auto-detection.
- *	Read-only.
- * @advertising: Bitmask of %ADVERTISED_* flags for the link modes,
- *	physical connectors and other link features that are
- *	advertised through autonegotiation or enabled for
- *	auto-detection.
+ * @supported: Low bits of bitmask of %SUPPORTED_* flags for the link
+ *	modes, physical connectors and other link features for which
+ *	the interface supports autonegotiation or auto-detection.
+ *	Read-only. Please do not access this field directly, use the
+ *	%ethtool_cmd_supported_* family of functions instead.
+ * @advertising: Low bits of bitmask of %ADVERTISED_* flags for the
+ *	link modes, physical connectors and other link features that
+ *	are advertised through autonegotiation or enabled for
+ *	auto-detection. Please do not access this field directly, use
+ *	the %ethtool_cmd_advertising_* family of functions instead.
  * @speed: Low bits of the speed
  * @duplex: Duplex mode; one of %DUPLEX_*
  * @port: Physical connector type; one of %PORT_*
@@ -56,10 +58,22 @@
  *	yield %ETH_TP_MDI_INVALID and writes may be ignored or rejected.
  *	When written successfully, the link should be renegotiated if
  *	necessary.
- * @lp_advertising: Bitmask of %ADVERTISED_* flags for the link modes
- *	and other link features that the link partner advertised
- *	through autonegotiation; 0 if unknown or not applicable.
- *	Read-only.
+ * @lp_advertising: Low bits of bitmask of %ADVERTISED_* flags for the
+ *      link modes and other link features that the link partner
+ *      advertised through autonegotiation; 0 if unknown or not
+ *      applicable.  Read-only. Please do not access this field
+ *      directly, use the %ethtool_cmd_lp_advertising_* family of
+ *      functions instead.
+ * @supported_hi: High bits of bitmask of %SUPPORTED_* flags. See
+ *      %supported. Read-only. Please do not access this field directly,
+ *      use the %ethtool_cmd_supported_* family of functions instead.
+ * @advertising_hi: High bits of bitmask of %ADVERTISING_* flags. See
+ *      %advertising. Please do not access this field directly, use the
+ *      %ethtool_cmd_advertising_* family of functions instead.
+ * @lp_advertising_hi: High bits of bitmask of %ADVERTISING_* flags.
+ *      See %lp_advertising. Read-only. Please do not access this
+ *      field directly, use the %ethtool_cmd_lp_advertising_* family
+ *      of functions instead.
  *
  * The link speed in Mbps is split between @speed and @speed_hi.  Use
  * the ethtool_cmd_speed() and ethtool_cmd_speed_set() functions to
@@ -108,7 +122,10 @@ struct ethtool_cmd {
 	__u8	eth_tp_mdix;
 	__u8	eth_tp_mdix_ctrl;
 	__u32	lp_advertising;
-	__u32	reserved[2];
+	__u16	supported_hi;
+	__u16	advertising_hi;
+	__u16	lp_advertising_hi;
+	__u16	reserved;
 };
 
 static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
@@ -124,6 +141,45 @@ static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 	return (ep->speed_hi << 16) | ep->speed;
 }
 
+/**
+ * ETHTOOL_MAKE_LINK_MODE_ACCESSORS - create the link_mode accessors
+ * Macro to generate the %ethtool_cmd_supported_*,
+ * %ethtool_cmd_advertising_*, %ethtool_cmd_lp_advertising_*,
+ * %ethtool_eee_supported_*, %ethtool_eee_advertised_*,
+ * %ethtool_eee_lp_advertised_* families of functions.
+ *
+ *  @struct_name: either %ethtool_cmd or %ethtool_eee
+ *  @field_name: name of the fields in %struct_name to
+ *      access. supported/advertising/lp_advertising for ethtool_cmd,
+ *      supported/advertised/lp_advertised for ethtool_eee
+ *
+ * Generates the following static functions:
+ *  ethtool_cmd_supported(const struct ethtool_cmd*): returns
+ *      the 64b value of %supported fields (the upper bits 63..48 are 0)
+ *  ethtool_cmd_supported_set(struct ethtool_cmd*,
+ *      ethtool_link_mode_mask_t value): set the %supported fields to
+ *      given %value (only the lower 48 bits used, upper bits 63..48
+ *      ignored)
+ *
+ * Same doc for all the other functions.
+ */
+#define ETHTOOL_MAKE_LINK_MODE_ACCESSORS(struct_name, field_name)	\
+	static inline ethtool_link_mode_mask_t				\
+	struct_name ## _ ## field_name(const struct struct_name *cmd)	\
+	{ ethtool_link_mode_mask_t r = cmd->field_name;			\
+	  r |= ((__u64)cmd->field_name ## _hi) << 32; return r; }	\
+	static inline void						\
+	struct_name ## _ ## field_name ## _set(struct struct_name *cmd,	\
+					       ethtool_link_mode_mask_t mask) \
+	{ cmd->field_name = mask & 0xffffffff;				\
+	  cmd->field_name ## _hi = (mask >> 32) & 0xffff; }
+
+typedef __u64 ethtool_link_mode_mask_t;
+
+ETHTOOL_MAKE_LINK_MODE_ACCESSORS(ethtool_cmd, supported);
+ETHTOOL_MAKE_LINK_MODE_ACCESSORS(ethtool_cmd, advertising);
+ETHTOOL_MAKE_LINK_MODE_ACCESSORS(ethtool_cmd, lp_advertising);
+
 /* Device supports clause 22 register access to PHY or peripherals
  * using the interface defined in <linux/mii.h>.  This should not be
  * set if there are known to be no such peripherals present or if
@@ -288,12 +344,18 @@ struct ethtool_eeprom {
 /**
  * struct ethtool_eee - Energy Efficient Ethernet information
  * @cmd: ETHTOOL_{G,S}EEE
- * @supported: Mask of %SUPPORTED_* flags for the speed/duplex combinations
- *	for which there is EEE support.
- * @advertised: Mask of %ADVERTISED_* flags for the speed/duplex combinations
- *	advertised as eee capable.
- * @lp_advertised: Mask of %ADVERTISED_* flags for the speed/duplex
- *	combinations advertised by the link partner as eee capable.
+ * @supported: Low bits of mask of %SUPPORTED_* flags for the
+ *	speed/duplex combinations for which there is EEE
+ *	support. Please do not access this field directly, use the
+ *	%ethtool_eee_supported_* family of functions instead.
+ * @advertised: Low bits of mask of %ADVERTISED_* flags for the
+ *	speed/duplex combinations advertised as eee capable. Please do
+ *	not access this field directly, use the
+ *	%ethtool_eee_advertised_* family of functions instead.
+ * @lp_advertised: Low bits of mask of %ADVERTISED_* flags for the
+ *	speed/duplex combinations advertised by the link partner as
+ *	eee capable.  Please do not access this field directly, use
+ *	the %ethtool_eee_lp_advertised_* family of functions instead.
  * @eee_active: Result of the eee auto negotiation.
  * @eee_enabled: EEE configured mode (enabled/disabled).
  * @tx_lpi_enabled: Whether the interface should assert its tx lpi, given
@@ -301,6 +363,16 @@ struct ethtool_eeprom {
  * @tx_lpi_timer: Time in microseconds the interface delays prior to asserting
  *	its tx lpi (after reaching 'idle' state). Effective only when eee
  *	was negotiated and tx_lpi_enabled was set.
+ * @supported_hi: High bits of mask of %SUPPORTED_* flags. See
+ *      %supported. Please do not access this field directly, use the
+ *      %ethtool_eee_supported_* family of functions instead.
+ * @advertised_hi: High bits of mask of %ADVERTISING_* flags. See
+ *      %advertising. Please do not access this field directly, use
+ *      the %ethtool_eee_advertising_* family of functions instead.
+ * @lp_advertised_hi: High bits of mask of %ADVERTISING_* flags.
+ *      See %lp_advertising. Please do not access this field directly,
+ *      use the %ethtool_eee_lp_advertising_* family of functions
+ *      instead.
  *
  * Deprecated and reserved fields should be ignored by both users and
  * drivers. If reserved fields must be set, store the value 0 in them.
@@ -314,9 +386,17 @@ struct ethtool_eee {
 	__u32	eee_enabled;
 	__u32	tx_lpi_enabled;
 	__u32	tx_lpi_timer;
-	__u32	reserved[2];
+	__u16	supported_hi;
+	__u16	advertised_hi;
+	__u16	lp_advertised_hi;
+	__u16	reserved;
 };
 
+ETHTOOL_MAKE_LINK_MODE_ACCESSORS(ethtool_eee, supported);
+ETHTOOL_MAKE_LINK_MODE_ACCESSORS(ethtool_eee, advertised);
+ETHTOOL_MAKE_LINK_MODE_ACCESSORS(ethtool_eee, lp_advertised);
+
+
 /**
  * struct ethtool_modinfo - plugin module eeprom information
  * @cmd: %ETHTOOL_GMODULEINFO
@@ -1196,6 +1276,11 @@ enum ethtool_sfeatures_retval_bits {
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
 
+/*
+ * Do not use the following macros directly to update
+ * ethtool_cmd::supported, ethtool_eee::supported. Please use
+ * ethtool_(cmd|eee)_supported(|_set) instead.
+ */
 #define SUPPORTED_10baseT_Half		(1 << 0)
 #define SUPPORTED_10baseT_Full		(1 << 1)
 #define SUPPORTED_100baseT_Half		(1 << 2)
@@ -1228,6 +1313,12 @@ enum ethtool_sfeatures_retval_bits {
 #define SUPPORTED_56000baseSR4_Full	(1 << 29)
 #define SUPPORTED_56000baseLR4_Full	(1 << 30)
 
+/*
+ * Do not use the following macros directly to update
+ * ethtool_cmd::advertising, ethtool_cmd::lp_advertising,
+ * ethtool_eee::advertised, ethtool_eee::lp_advertised. Please use
+ * ethtool_(cmd|eee)_*(|_set).
+ */
 #define ADVERTISED_10baseT_Half		(1 << 0)
 #define ADVERTISED_10baseT_Full		(1 << 1)
 #define ADVERTISED_100baseT_Half	(1 << 2)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 550892c..462a8f4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -362,6 +362,19 @@ static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 	if (err < 0)
 		return err;
 
+	/* Log a warning if driver reports high link mode bits when
+	 * it's not officially supporting them
+	 */
+	if (!dev->ethtool_ops->get_compat_flags ||
+	    !(dev->ethtool_ops->get_compat_flags(dev)
+	      & ETH_COMPAT_SUPPORT_LINK_MODE_48b)) {
+		WARN_ONCE((0 != cmd.supported_hi) ||
+			  (0 != cmd.advertising_hi) ||
+			  (0 != cmd.lp_advertising_hi),
+			  "%s: using ethtool link mode high bits",
+			  netdev_name(dev));
+	}
+
 	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
 		return -EFAULT;
 	return 0;
@@ -377,6 +390,15 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
 
+	/* Reject the high advertising bits if driver doesn't support
+	 * them
+	 */
+	if (cmd.advertising_hi &&
+	    (!dev->ethtool_ops->get_compat_flags ||
+	     !(dev->ethtool_ops->get_compat_flags(dev)
+	       & ETH_COMPAT_SUPPORT_LINK_MODE_48b)))
+		return -EINVAL;
+
 	return dev->ethtool_ops->set_settings(dev, &cmd);
 }
 
@@ -955,6 +977,19 @@ static int ethtool_get_eee(struct net_device *dev, char __user *useraddr)
 	if (rc)
 		return rc;
 
+	/* Log a warning if driver reports high link mode bits when
+	 * it's not officially supporting them
+	 */
+	if (!dev->ethtool_ops->get_compat_flags ||
+	    !(dev->ethtool_ops->get_compat_flags(dev)
+	      & ETH_COMPAT_SUPPORT_LINK_MODE_48b)) {
+		WARN_ONCE((0 != edata.supported_hi) ||
+			  (0 != edata.advertised_hi) ||
+			  (0 != edata.lp_advertised_hi),
+			  "%s: using ethtool EEE link mode high bits",
+			  netdev_name(dev));
+	}
+
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
 
@@ -971,6 +1006,15 @@ static int ethtool_set_eee(struct net_device *dev, char __user *useraddr)
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
 
+	/* Reject the high advertising bits if driver doesn't support
+	 * them
+	 */
+	if (edata.advertised_hi &&
+	    (!dev->ethtool_ops->get_compat_flags ||
+	     !(dev->ethtool_ops->get_compat_flags(dev)
+		     & ETH_COMPAT_SUPPORT_LINK_MODE_48b)))
+		return -EINVAL;
+
 	return dev->ethtool_ops->set_eee(dev, &edata);
 }
 
-- 
2.2.0.rc0.207.ga3a616c
