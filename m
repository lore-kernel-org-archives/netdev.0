From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v2 03/17] net: ethtool: add new ETHTOOL_GSETTINGS/SSETTINGS API
Date: Wed,  4 Feb 2015 11:53:27 -0800
Message-ID: <1423079621-1374-4-git-send-email-ddecotig@gmail.com>
References: <1423079621-1374-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Eugenia Emantayev <eugenia@mellanox.co.il>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Eyal Perry <eyalpe@mellanox.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Ed Swierk <eswierk@skyportsystems.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Robert Love <robert.w.love@intel.com>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>,
        Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-api@vger.kernel.org,
        linux-mips@linux-mips.org, fcoe-devel@open-fcoe.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1423079621-1374-1-git-send-email-ddecotig@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

This patch defines a new ETHTOOL_GSETTINGS/SSETTINGS API, handled by
the new get_ksettings/set_ksettings callbacks. This API provides
support for most legacy ethtool_cmd fields, adds support for larger
link mode masks (up to 4064 bits, variable length), and removes
ethtool_cmd deprecated fields (transceiver/maxrxpkt/maxtxpkt).

This API is deprecating the legacy ETHTOOL_GSET/SSET API and provides
the following backward compatibility properties:
 - legacy ethtool with legacy drivers: no change, still using the
   get_settings/set_settings callbacks.
 - legacy ethtool with new get/set_ksettings drivers: the new driver
   callbacks are used, data internally converted to legacy
   ethtool_cmd. ETHTOOL_GSET will return only the 1st 32b of each link
   mode mask. ETHTOOL_SSET will fail if user tries to set the
   ethtool_cmd deprecated fields to non-0
   (transceiver/maxrxpkt/maxtxpkt). A kernel warning is printed if
   driver exports higher bits or if user request changes in deprecated
   fields mentioned earlier.
 - future ethtool with legacy drivers: no change, still using the
   get_settings/set_settings callbacks, internally converted to new
   data structure. Note that that "future" ethtool tool will not allow
   changes to deprecated fields (transceiver/maxrxpkt/maxtxpkt), as
   they cannot be expressed for the kernel.
 - future ethtool with new drivers: direct call to the new callbacks.

By "future" ethtool, what is meant is:
 - query: first try ETHTOOL_GSETTINGS, and revert to ETHTOOL_GSET if fails
 - set: query first and remember which of ETHTOOL_GSETTINGS or
   ETHTOOL_GSET was successful
   - if ETHTOOL_GSETTINGS was successful, then change config with
     ETHTOOL_SSETTINGS. A failure there is final (do not try ETHTOOL_SSET).
   - otherwise ETHTOOL_GSET was successful, change config with ETHTOOL_SSET.
     A failure there is final (do not try ETHTOOL_SSETTINGS).

The interaction user/kernel via the new API requires a small
ETHTOOL_GSETTINGS handshake first to agree on the length of the link
mode bitmaps. If kernel doesn't agree with user, it returns the bitmap
length it is expecting from user as a negative length (and cmd field
is 0). When kernel and user agree, kernel returns valid info in all
fields (ie. link mode length > 0 and cmd is ETHTOOL_GSETTINGS).

Data structure crossing user/kernel boundary is 32/64-bit
agnostic. Converted internally to a legal kernel bitmap.

The internal __ethtool_get_settings kernel helper will gradually be
replaced by __ethtool_get_ksettings by the time the first ksettings
drivers start to appear. So this patch doesn't change it, it will be
removed before it needs to be changed.

Signed-off-by: David Decotigny <decot@googlers.com>
---
 include/linux/ethtool.h      | 100 ++++++++-
 include/uapi/linux/ethtool.h | 319 ++++++++++++++++++++++------
 net/core/ethtool.c           | 489 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 828 insertions(+), 80 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c..49881b6 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -12,6 +12,7 @@
 #ifndef _LINUX_ETHTOOL_H
 #define _LINUX_ETHTOOL_H
 
+#include <linux/bitmap.h>
 #include <linux/compat.h>
 #include <uapi/linux/ethtool.h>
 
@@ -40,9 +41,6 @@ struct compat_ethtool_rxnfc {
 
 #include <linux/rculist.h>
 
-extern int __ethtool_get_settings(struct net_device *dev,
-				  struct ethtool_cmd *cmd);
-
 /**
  * enum ethtool_phys_id_state - indicator state for physical identification
  * @ETHTOOL_ID_INACTIVE: Physical ID indicator should be deactivated
@@ -97,13 +95,84 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
 	return index % n_rx_rings;
 }
 
+/* number of link mode bits handled internally by kernel */
+#define __ETHTOOL_LINK_MODE_MASK_NBITS (__ETHTOOL_LINK_MODE_LAST+1)
+
+#define __ETHTOOL_LINK_MODE_IS_VALID_BIT(indice)	\
+	((indice) >= 0 && (indice) < __ETHTOOL_LINK_MODE_MASK_NBITS)
+
+typedef struct {
+	unsigned long mask[BITS_TO_LONGS(__ETHTOOL_LINK_MODE_MASK_NBITS)];
+} ethtool_link_mode_mask_t;
+
+/* drivers must ignore parent.cmd and parent.link_mode_masks_nwords
+ * fields, but they are allowed to overwrite them (will be ignored) */
+struct ethtool_ksettings {
+	struct ethtool_settings parent;
+	struct {
+		ethtool_link_mode_mask_t supported;
+		ethtool_link_mode_mask_t advertising;
+		ethtool_link_mode_mask_t lp_advertising;
+	} link_modes;
+};
+
+/* helper function for ethtool_build_link_mode and ethtool_add_link_modes */
+static inline int
+__ethtool_add_link_modes(ethtool_link_mode_mask_t *dst,
+			 unsigned nindices,
+			 const enum ethtool_link_mode_bit_indices *indices) {
+	unsigned i;
+	int rv = 0;
+
+	for (i = 0 ; i < nindices ; ++i) {
+		if (__ETHTOOL_LINK_MODE_IS_VALID_BIT(indices[i]))
+			set_bit(indices[i], dst->mask);
+		else
+			rv = -1;
+	}
+	return rv;
+}
+
+/* build link mode mask from variadic list of bit indices, return 0
+ * when all indices are valid, -1 otherwise
+ */
+#define ethtool_build_link_mode(dst, ...)				\
+	({								\
+		const enum ethtool_link_mode_bit_indices indices[] = {	\
+			__VA_ARGS__ };					\
+		bitmap_zero((dst)->mask,				\
+			    __ETHTOOL_LINK_MODE_MASK_NBITS);		\
+		__ethtool_add_link_modes((dst),				\
+					 ARRAY_SIZE(indices), indices); \
+	})
+
+/* update link mode mask by setting variadic list of bit indices,
+ * return 0 when all indices are valid, -1 otherwise
+ */
+#define ethtool_add_link_modes(dst, ...)				\
+	({								\
+		const enum ethtool_link_mode_bit_indices indices[] = {	\
+			__VA_ARGS__ };					\
+		__ethtool_add_link_modes((dst),				\
+					 ARRAY_SIZE(indices), indices); \
+	})
+
+extern int __ethtool_get_ksettings(struct net_device *dev,
+				   struct ethtool_ksettings *ksettings);
+
+/* DEPRECATED, use __ethtool_get_ksettings */
+extern int __ethtool_get_settings(struct net_device *dev,
+				  struct ethtool_cmd *cmd);
+
 /**
  * struct ethtool_ops - optional netdev operations
- * @get_settings: Get various device settings including Ethernet link
+ * @get_settings: DEPRECATED, use %get_ksettings/%set_ksettings
+ *	API. Get various device settings including Ethernet link
  *	settings. The @cmd parameter is expected to have been cleared
- *	before get_settings is called. Returns a negative error code or
- *	zero.
- * @set_settings: Set various device settings including Ethernet link
+ *	before get_settings is called. Returns a negative error code
+ *	or zero.
+ * @set_settings: DEPRECATED, use %get_ksettings/%set_ksettings
+ *	API. Set various device settings including Ethernet link
  *	settings.  Returns a negative error code or zero.
  * @get_drvinfo: Report driver/device information.  Should only set the
  *	@driver, @version, @fw_version and @bus_info fields.  If not
@@ -201,6 +270,18 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @get_module_eeprom: Get the eeprom information from the plug-in module
  * @get_eee: Get Energy-Efficient (EEE) supported and status.
  * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
+ * @get_ksettings: When defined, takes precedence over the
+ *	%get_settings method. Get various device settings including Ethernet
+ *	link settings. The %cmd and %link_mode_masks_nwords fields should be
+ *	ignored (use %__ETHTOOL_LINK_MODE_MASK_NBITS instead of the latter),
+ *	any change to them will be overwritten by kernel. Returns a negative
+ *	error code or zero.
+ * @set_ksettings: When defined, takes precedence over the
+ *	%set_settings method. Set various device settings including
+ *	Ethernet link settings. The %cmd and %link_mode_masks_nwords fields
+ *	should be ignored (use %__ETHTOOL_LINK_MODE_MASK_NBITS instead of
+ *	the latter), any change to them will be overwritten by
+ *	kernel. Returns a negative error code or zero.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -280,6 +361,9 @@ struct ethtool_ops {
 	int	(*set_tunable)(struct net_device *,
 			       const struct ethtool_tunable *, const void *);
 
-
+	int	(*get_ksettings)(struct net_device *,
+				 struct ethtool_ksettings *);
+	int	(*set_ksettings)(struct net_device *,
+				 const struct ethtool_ksettings *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f66d9c..c85cc2f 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -21,7 +21,8 @@
  */
 
 /**
- * struct ethtool_cmd - link control and status
+ * struct ethtool_cmd - DEPRECATED, link control and status
+ * This structure is DEPRECATED, please use struct ethtool_settings.
  * @cmd: Command number = %ETHTOOL_GSET or %ETHTOOL_SSET
  * @supported: Bitmask of %SUPPORTED_* flags for the link modes,
  *	physical connectors and other link features for which the
@@ -1108,8 +1109,10 @@ enum ethtool_sfeatures_retval_bits {
 
 
 /* CMDs currently supported */
-#define ETHTOOL_GSET		0x00000001 /* Get settings. */
-#define ETHTOOL_SSET		0x00000002 /* Set settings. */
+#define ETHTOOL_GSET		0x00000001 /* DEPRECATED, Get settings.
+					      Please use ETHTOOL_GSETTINGS */
+#define ETHTOOL_SSET		0x00000002 /* DEPRECATED, Set settings.
+					      Please use ETHTOOL_SSETTINGS */
 #define ETHTOOL_GDRVINFO	0x00000003 /* Get driver info. */
 #define ETHTOOL_GREGS		0x00000004 /* Get NIC registers. */
 #define ETHTOOL_GWOL		0x00000005 /* Get wake-on-lan options. */
@@ -1188,73 +1191,137 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 
+#define ETHTOOL_GSETTINGS	0x0000004a /* Get ethtool_settings */
+#define ETHTOOL_SSETTINGS	0x0000004b /* Set ethtool_settings */
+
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
 
-#define SUPPORTED_10baseT_Half		(1 << 0)
-#define SUPPORTED_10baseT_Full		(1 << 1)
-#define SUPPORTED_100baseT_Half		(1 << 2)
-#define SUPPORTED_100baseT_Full		(1 << 3)
-#define SUPPORTED_1000baseT_Half	(1 << 4)
-#define SUPPORTED_1000baseT_Full	(1 << 5)
-#define SUPPORTED_Autoneg		(1 << 6)
-#define SUPPORTED_TP			(1 << 7)
-#define SUPPORTED_AUI			(1 << 8)
-#define SUPPORTED_MII			(1 << 9)
-#define SUPPORTED_FIBRE			(1 << 10)
-#define SUPPORTED_BNC			(1 << 11)
-#define SUPPORTED_10000baseT_Full	(1 << 12)
-#define SUPPORTED_Pause			(1 << 13)
-#define SUPPORTED_Asym_Pause		(1 << 14)
-#define SUPPORTED_2500baseX_Full	(1 << 15)
-#define SUPPORTED_Backplane		(1 << 16)
-#define SUPPORTED_1000baseKX_Full	(1 << 17)
-#define SUPPORTED_10000baseKX4_Full	(1 << 18)
-#define SUPPORTED_10000baseKR_Full	(1 << 19)
-#define SUPPORTED_10000baseR_FEC	(1 << 20)
-#define SUPPORTED_20000baseMLD2_Full	(1 << 21)
-#define SUPPORTED_20000baseKR2_Full	(1 << 22)
-#define SUPPORTED_40000baseKR4_Full	(1 << 23)
-#define SUPPORTED_40000baseCR4_Full	(1 << 24)
-#define SUPPORTED_40000baseSR4_Full	(1 << 25)
-#define SUPPORTED_40000baseLR4_Full	(1 << 26)
-#define SUPPORTED_56000baseKR4_Full	(1 << 27)
-#define SUPPORTED_56000baseCR4_Full	(1 << 28)
-#define SUPPORTED_56000baseSR4_Full	(1 << 29)
-#define SUPPORTED_56000baseLR4_Full	(1 << 30)
-
-#define ADVERTISED_10baseT_Half		(1 << 0)
-#define ADVERTISED_10baseT_Full		(1 << 1)
-#define ADVERTISED_100baseT_Half	(1 << 2)
-#define ADVERTISED_100baseT_Full	(1 << 3)
-#define ADVERTISED_1000baseT_Half	(1 << 4)
-#define ADVERTISED_1000baseT_Full	(1 << 5)
-#define ADVERTISED_Autoneg		(1 << 6)
-#define ADVERTISED_TP			(1 << 7)
-#define ADVERTISED_AUI			(1 << 8)
-#define ADVERTISED_MII			(1 << 9)
-#define ADVERTISED_FIBRE		(1 << 10)
-#define ADVERTISED_BNC			(1 << 11)
-#define ADVERTISED_10000baseT_Full	(1 << 12)
-#define ADVERTISED_Pause		(1 << 13)
-#define ADVERTISED_Asym_Pause		(1 << 14)
-#define ADVERTISED_2500baseX_Full	(1 << 15)
-#define ADVERTISED_Backplane		(1 << 16)
-#define ADVERTISED_1000baseKX_Full	(1 << 17)
-#define ADVERTISED_10000baseKX4_Full	(1 << 18)
-#define ADVERTISED_10000baseKR_Full	(1 << 19)
-#define ADVERTISED_10000baseR_FEC	(1 << 20)
-#define ADVERTISED_20000baseMLD2_Full	(1 << 21)
-#define ADVERTISED_20000baseKR2_Full	(1 << 22)
-#define ADVERTISED_40000baseKR4_Full	(1 << 23)
-#define ADVERTISED_40000baseCR4_Full	(1 << 24)
-#define ADVERTISED_40000baseSR4_Full	(1 << 25)
-#define ADVERTISED_40000baseLR4_Full	(1 << 26)
-#define ADVERTISED_56000baseKR4_Full	(1 << 27)
-#define ADVERTISED_56000baseCR4_Full	(1 << 28)
-#define ADVERTISED_56000baseSR4_Full	(1 << 29)
-#define ADVERTISED_56000baseLR4_Full	(1 << 30)
+/* Link mode bit indices */
+enum ethtool_link_mode_bit_indices {
+	ETHTOOL_LINK_MODE_10baseT_Half_BIT	= 0,
+	ETHTOOL_LINK_MODE_10baseT_Full_BIT	= 1,
+	ETHTOOL_LINK_MODE_100baseT_Half_BIT	= 2,
+	ETHTOOL_LINK_MODE_100baseT_Full_BIT	= 3,
+	ETHTOOL_LINK_MODE_1000baseT_Half_BIT	= 4,
+	ETHTOOL_LINK_MODE_1000baseT_Full_BIT	= 5,
+	ETHTOOL_LINK_MODE_Autoneg_BIT		= 6,
+	ETHTOOL_LINK_MODE_TP_BIT		= 7,
+	ETHTOOL_LINK_MODE_AUI_BIT		= 8,
+	ETHTOOL_LINK_MODE_MII_BIT		= 9,
+	ETHTOOL_LINK_MODE_FIBRE_BIT		= 10,
+	ETHTOOL_LINK_MODE_BNC_BIT		= 11,
+	ETHTOOL_LINK_MODE_10000baseT_Full_BIT	= 12,
+	ETHTOOL_LINK_MODE_Pause_BIT		= 13,
+	ETHTOOL_LINK_MODE_Asym_Pause_BIT	= 14,
+	ETHTOOL_LINK_MODE_2500baseX_Full_BIT	= 15,
+	ETHTOOL_LINK_MODE_Backplane_BIT		= 16,
+	ETHTOOL_LINK_MODE_1000baseKX_Full_BIT	= 17,
+	ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT	= 18,
+	ETHTOOL_LINK_MODE_10000baseKR_Full_BIT	= 19,
+	ETHTOOL_LINK_MODE_10000baseR_FEC_BIT	= 20,
+	ETHTOOL_LINK_MODE_20000baseMLD2_Full_BIT = 21,
+	ETHTOOL_LINK_MODE_20000baseKR2_Full_BIT	= 22,
+	ETHTOOL_LINK_MODE_40000baseKR4_Full_BIT	= 23,
+	ETHTOOL_LINK_MODE_40000baseCR4_Full_BIT	= 24,
+	ETHTOOL_LINK_MODE_40000baseSR4_Full_BIT	= 25,
+	ETHTOOL_LINK_MODE_40000baseLR4_Full_BIT	= 26,
+	ETHTOOL_LINK_MODE_56000baseKR4_Full_BIT	= 27,
+	ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT	= 28,
+	ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT	= 29,
+	ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT	= 30,
+
+	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
+	   31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
+	   macro for bits > 31. The only way to use indices > 31 is to
+	   use the new ETHTOOL_GSETTINGS/ETHTOOL_SSETTINGS API */
+
+	__ETHTOOL_LINK_MODE_LAST
+	  = ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
+};
+
+#define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
+	(1UL << (ETHTOOL_LINK_MODE_ ## base_name ## _BIT))
+
+/* DEPRECATED macros. Please migrate to
+   ETHTOOL_GSETTINGS/ETHTOOL_SSETTINGS API. Please do NOT define any new
+   SUPPORTED_* macro for bits > 31.  */
+#define SUPPORTED_10baseT_Half		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Half)
+#define SUPPORTED_10baseT_Full		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Full)
+#define SUPPORTED_100baseT_Half		__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Half)
+#define SUPPORTED_100baseT_Full		__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Full)
+#define SUPPORTED_1000baseT_Half	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Half)
+#define SUPPORTED_1000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Full)
+#define SUPPORTED_Autoneg		__ETHTOOL_LINK_MODE_LEGACY_MASK(Autoneg)
+#define SUPPORTED_TP			__ETHTOOL_LINK_MODE_LEGACY_MASK(TP)
+#define SUPPORTED_AUI			__ETHTOOL_LINK_MODE_LEGACY_MASK(AUI)
+#define SUPPORTED_MII			__ETHTOOL_LINK_MODE_LEGACY_MASK(MII)
+#define SUPPORTED_FIBRE			__ETHTOOL_LINK_MODE_LEGACY_MASK(FIBRE)
+#define SUPPORTED_BNC			__ETHTOOL_LINK_MODE_LEGACY_MASK(BNC)
+#define SUPPORTED_10000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseT_Full)
+#define SUPPORTED_Pause			__ETHTOOL_LINK_MODE_LEGACY_MASK(Pause)
+#define SUPPORTED_Asym_Pause		__ETHTOOL_LINK_MODE_LEGACY_MASK(Asym_Pause)
+#define SUPPORTED_2500baseX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(2500baseX_Full)
+#define SUPPORTED_Backplane		__ETHTOOL_LINK_MODE_LEGACY_MASK(Backplane)
+#define SUPPORTED_1000baseKX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseKX_Full)
+#define SUPPORTED_10000baseKX4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKX4_Full)
+#define SUPPORTED_10000baseKR_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKR_Full)
+#define SUPPORTED_10000baseR_FEC	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseR_FEC)
+#define SUPPORTED_20000baseMLD2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseMLD2_Full)
+#define SUPPORTED_20000baseKR2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseKR2_Full)
+#define SUPPORTED_40000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseKR4_Full)
+#define SUPPORTED_40000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseCR4_Full)
+#define SUPPORTED_40000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseSR4_Full)
+#define SUPPORTED_40000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseLR4_Full)
+#define SUPPORTED_56000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseKR4_Full)
+#define SUPPORTED_56000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseCR4_Full)
+#define SUPPORTED_56000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseSR4_Full)
+#define SUPPORTED_56000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseLR4_Full)
+/* Please do not define any new SUPPORTED_* macro for bits > 31, see
+ * notice above.
+ */
+
+/*
+ * DEPRECATED macros. Please migrate to
+ * ETHTOOL_GSETTINGS/ETHTOOL_SSETTINGS API. Please do NOT define any new
+ * ADERTISE_* macro for bits > 31.
+ */
+#define ADVERTISED_10baseT_Half		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Half)
+#define ADVERTISED_10baseT_Full		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Full)
+#define ADVERTISED_100baseT_Half	__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Half)
+#define ADVERTISED_100baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Full)
+#define ADVERTISED_1000baseT_Half	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Half)
+#define ADVERTISED_1000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Full)
+#define ADVERTISED_Autoneg		__ETHTOOL_LINK_MODE_LEGACY_MASK(Autoneg)
+#define ADVERTISED_TP			__ETHTOOL_LINK_MODE_LEGACY_MASK(TP)
+#define ADVERTISED_AUI			__ETHTOOL_LINK_MODE_LEGACY_MASK(AUI)
+#define ADVERTISED_MII			__ETHTOOL_LINK_MODE_LEGACY_MASK(MII)
+#define ADVERTISED_FIBRE		__ETHTOOL_LINK_MODE_LEGACY_MASK(FIBRE)
+#define ADVERTISED_BNC			__ETHTOOL_LINK_MODE_LEGACY_MASK(BNC)
+#define ADVERTISED_10000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseT_Full)
+#define ADVERTISED_Pause		__ETHTOOL_LINK_MODE_LEGACY_MASK(Pause)
+#define ADVERTISED_Asym_Pause		__ETHTOOL_LINK_MODE_LEGACY_MASK(Asym_Pause)
+#define ADVERTISED_2500baseX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(2500baseX_Full)
+#define ADVERTISED_Backplane		__ETHTOOL_LINK_MODE_LEGACY_MASK(Backplane)
+#define ADVERTISED_1000baseKX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseKX_Full)
+#define ADVERTISED_10000baseKX4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKX4_Full)
+#define ADVERTISED_10000baseKR_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKR_Full)
+#define ADVERTISED_10000baseR_FEC	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseR_FEC)
+#define ADVERTISED_20000baseMLD2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseMLD2_Full)
+#define ADVERTISED_20000baseKR2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseKR2_Full)
+#define ADVERTISED_40000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseKR4_Full)
+#define ADVERTISED_40000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseCR4_Full)
+#define ADVERTISED_40000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseSR4_Full)
+#define ADVERTISED_40000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseLR4_Full)
+#define ADVERTISED_56000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseKR4_Full)
+#define ADVERTISED_56000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseCR4_Full)
+#define ADVERTISED_56000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseSR4_Full)
+#define ADVERTISED_56000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseLR4_Full)
+/* Please do not define any new ADVERTISED_* macro for bits > 31, see
+ * notice above.
+ */
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
@@ -1396,4 +1463,124 @@ enum ethtool_reset_flags {
 };
 #define ETH_RESET_SHARED_SHIFT	16
 
+
+/**
+ * struct ethtool_settings - link control and status
+ * This structure deprecates struct %ethtool_cmd.
+ *
+ * IMPORTANT, Backward compatibility notice: When implementing new
+ *	user-space tools, please first try %ETHTOOL_GSETTINGS, and if
+ *	it succeeds use %ETHTOOL_SSETTINGS to change settings; do not
+ *	use %ETHTOOL_SSET if %ETHTOOL_GSETTINGS succeeded: stick to
+ *	%ETHTOOL_GSETTINGS/%SSETTINGS in that case.  Conversely, if
+ *	%ETHTOOL_GSETTINGS fails, use %ETHTOOL_GSET to query and
+ *	%ETHTOOL_SSET to change settings; do not use
+ *	%ETHTOOL_SSETTINGS if %ETHTOOL_GSETTINGS failed: stick to
+ *	%ETHTOOL_GSET/%ETHTOOL_SSET in that case.
+ *
+ * @cmd: Command number = %ETHTOOL_GSETTINGS or %ETHTOOL_SSETTINGS
+ * @speed: Link speed (Mbps)
+ * @duplex: Duplex mode; one of %DUPLEX_*
+ * @port: Physical connector type; one of %PORT_*
+ * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
+ *	applicable.  For clause 45 PHYs this is the PRTAD.
+ * @autoneg: Enable/disable autonegotiation and auto-detection;
+ *	either %AUTONEG_DISABLE or %AUTONEG_ENABLE
+ * @mdio_support: Bitmask of %ETH_MDIO_SUPPORTS_* flags for the MDIO
+ *	protocols supported by the interface; 0 if unknown.
+ *	Read-only.
+ * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
+ *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
+ *	value will be %ETH_TP_MDI_INVALID.  Read-only.
+ * @eth_tp_mdix_ctrl: Ethernet twisted pair MDI(-X) control; one of
+ *	%ETH_TP_MDI_*.  If MDI(-X) control is not implemented, reads
+ *	yield %ETH_TP_MDI_INVALID and writes may be ignored or rejected.
+ *	When written successfully, the link should be renegotiated if
+ *	necessary.
+ * @link_mode_masks_nwords: Number of 32-bit words for each of the
+ *	supported, advertising, lp_advertising link mode bitmaps. For
+ *	%ETHTOOL_GSETTINGS: on entry, number of words passed by user
+ *	(>= 0); on return, if handshake in progress, negative if
+ *	request size unsupported by kernel: absolute value indicates
+ *	kernel recommended size and cmd field is 0, as well as all the
+ *	other fields; otherwise (handshake completed), strictly
+ *	positive to indicate size used by kernel and cmd field is
+ *	%ETHTOOL_GSETTINGS, all other fields populated by driver. For
+ *	%ETHTOOL_SSETTINGS: must be valid on entry, ie. a positive
+ *	value returned previously by %ETHTOOL_GSETTINGS, otherwise
+ *	refused. For drivers: ignore this field (use kernel's
+ *	__ETHTOOL_LINK_MODE_MASK_NBITS instead), any change to it will
+ *	be overwritten by kernel.
+ * @supported: Bitmap with each bit meaning given by
+ *	%ethtool_link_mode_bit_indices for the link modes, physical
+ *	connectors and other link features for which the interface
+ *	supports autonegotiation or auto-detection.  Read-only.
+ * @advertising: Bitmap with each bit meaning given by
+ *	%ethtool_link_mode_bit_indices for the link modes, physical
+ *	connectors and other link features that are advertised through
+ *	autonegotiation or enabled for auto-detection.
+ * @lp_advertising: Bitmap with each bit meaning given by
+ *	%ethtool_link_mode_bit_indices for the link modes, and other
+ *	link features that the link partner advertised through
+ *	autonegotiation; 0 if unknown or not applicable.  Read-only.
+ *
+ * If autonegotiation is disabled, the speed and @duplex represent the
+ * fixed link mode and are writable if the driver supports multiple
+ * link modes.  If it is enabled then they are read-only; if the link
+ * is up they represent the negotiated link mode; if the link is down,
+ * the speed is 0, %SPEED_UNKNOWN or the highest enabled speed and
+ * @duplex is %DUPLEX_UNKNOWN or the best enabled duplex mode.
+ *
+ * Some hardware interfaces may have multiple PHYs and/or physical
+ * connectors fitted or do not allow the driver to detect which are
+ * fitted.  For these interfaces @port and/or @phy_address may be
+ * writable, possibly dependent on @autoneg being %AUTONEG_DISABLE.
+ * Otherwise, attempts to write different values may be ignored or
+ * rejected.
+ *
+ * Deprecated %ethtool_cmd fields transceiver, maxtxpkt and maxrxpkt
+ * are not available in %ethtool_settings. Until all drivers are
+ * converted to ignore them or to the new %ethtool_settings API, for
+ * both queries and changes, users should always try
+ * %ETHTOOL_GSETTINGS first, and if it fails with -ENOTSUPP stick only
+ * to %ETHTOOL_GSET and %ETHTOOL_SSET consistently. If it succeeds,
+ * then users should stick to %ETHTOOL_GSETTINGS and
+ * %ETHTOOL_SSETTINGS (which would support drivers implementing either
+ * %ethtool_cmd or %ethtool_settings).
+ *
+ * Users should assume that all fields not marked read-only are
+ * writable and subject to validation by the driver.  They should use
+ * %ETHTOOL_GSETTINGS to get the current values before making specific
+ * changes and then applying them with %ETHTOOL_SSETTINGS.
+ *
+ * Drivers that implement %get_ksettings and/or %set_ksettings should
+ * ignore the @cmd and @link_mode_masks_nwords fields (any change to
+ * them overwritten by kernel), and rely only on kernel's internal
+ * %__ETHTOOL_LINK_MODE_MASK_NBITS and
+ * %ethtool_link_mode_mask_t. Drivers that implement %set_ksettings()
+ * should validate all fields other than @cmd
+ * and @link_mode_masks_nwords that are not described as read-only or
+ * deprecated, and must ignore all fields described as read-only.
+ *
+ * Deprecated fields should be ignored by both users and drivers.
+ */
+struct ethtool_settings {
+	__u32	cmd;
+	__u32	speed;
+	__u8	duplex;
+	__u8	port;
+	__u8	phy_address;
+	__u8	autoneg;
+	__u8	mdio_support;
+	__u8	eth_tp_mdix;
+	__u8	eth_tp_mdix_ctrl;
+	__s8	link_mode_masks_nwords;
+	__u32	reserved[8];
+	__u32	link_mode_masks[0];
+	/* layout of link_mode_masks fields:
+	 * __u32 map_supported[link_mode_masks_nwords];
+	 * __u32 map_advertising[link_mode_masks_nwords];
+	 * __u32 map_lp_advertising[link_mode_masks_nwords];
+	 */
+};
 #endif /* _UAPI_LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 91f74f3..11cb1c9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -340,6 +340,388 @@ static int __ethtool_set_flags(struct net_device *dev, u32 data)
 	return 0;
 }
 
+/* TODO: remove when %ETHTOOL_GSET/%ETHTOOL_SSET disappear */
+static void convert_legacy_u32_to_link_mode(ethtool_link_mode_mask_t *dst,
+					    u32 legacy_u32)
+{
+	bitmap_zero(dst->mask, __ETHTOOL_LINK_MODE_MASK_NBITS);
+	dst->mask[0] = legacy_u32;
+}
+
+/* return false if src had higher bits set. lower bits always updated.
+ * TODO: remove when %ETHTOOL_GSET/%ETHTOOL_SSET disappear
+ */
+static bool convert_link_mode_to_legacy_u32(u32 *legacy_u32,
+					    const ethtool_link_mode_mask_t *src)
+{
+	bool retval = true;
+
+	/* TODO: following test will soon always be true */
+	if (__ETHTOOL_LINK_MODE_MASK_NBITS > 32) {
+		ethtool_link_mode_mask_t ext;
+
+		bitmap_zero(ext.mask, __ETHTOOL_LINK_MODE_MASK_NBITS);
+		bitmap_fill(ext.mask, 32);
+		bitmap_complement(ext.mask, ext.mask,
+				  __ETHTOOL_LINK_MODE_MASK_NBITS);
+		if (bitmap_intersects(ext.mask, src->mask,
+				      __ETHTOOL_LINK_MODE_MASK_NBITS)) {
+			/* src mask goes beyond bit 31 */
+			retval = false;
+		}
+	}
+	*legacy_u32 = src->mask[0];
+	return retval;
+}
+
+/* return false if legacy contained non-0 deprecated fields
+ * transceiver/maxtxpkt/maxrxpkt. rest of ksettings always updated
+ * TODO: remove when %ETHTOOL_GSET/%ETHTOOL_SSET disappear
+ */
+static bool
+convert_legacy_settings_to_ksettings(struct ethtool_ksettings *ksettings,
+				     const struct ethtool_cmd *legacy_settings)
+{
+	bool retval = true;
+
+	memset(ksettings, 0, sizeof(*ksettings));
+
+	/* This is used to tell users that driver is still using these
+	 * deprecated legacy fields, and they should not use
+	 * %ETHTOOL_GSETTINGS/%ETHTOOL_SSETTINGS
+	 */
+	if (legacy_settings->transceiver ||
+	    legacy_settings->maxtxpkt ||
+	    legacy_settings->maxrxpkt)
+		retval = false;
+
+	convert_legacy_u32_to_link_mode(&ksettings->link_modes.supported,
+					legacy_settings->supported);
+	convert_legacy_u32_to_link_mode(&ksettings->link_modes.advertising,
+					legacy_settings->advertising);
+	convert_legacy_u32_to_link_mode(&ksettings->link_modes.lp_advertising,
+					legacy_settings->lp_advertising);
+	ksettings->parent.speed = ethtool_cmd_speed(legacy_settings);
+	ksettings->parent.duplex = legacy_settings->duplex;
+	ksettings->parent.port = legacy_settings->port;
+	ksettings->parent.phy_address = legacy_settings->phy_address;
+	ksettings->parent.autoneg = legacy_settings->autoneg;
+	ksettings->parent.mdio_support = legacy_settings->mdio_support;
+	ksettings->parent.eth_tp_mdix = legacy_settings->eth_tp_mdix;
+	ksettings->parent.eth_tp_mdix_ctrl = legacy_settings->eth_tp_mdix_ctrl;
+	return retval;
+}
+
+/* return false if ksettings link modes had higher bits
+ * set. legacy_settings always updated (best effort)
+ * TODO: remove when %ETHTOOL_GSET/%ETHTOOL_SSET disappear
+ */
+static bool
+convert_ksettings_to_legacy_settings(struct ethtool_cmd *legacy_settings,
+				     const struct ethtool_ksettings *ksettings)
+{
+	bool retval = true;
+
+	memset(legacy_settings, 0, sizeof(*legacy_settings));
+	/* this also clears the deprecated fields in legacy structure:
+	 * __u8		transceiver;
+	 * __u32	maxtxpkt;
+	 * __u32	maxrxpkt;
+	 */
+
+	retval &= convert_link_mode_to_legacy_u32(
+		&legacy_settings->supported,
+		&ksettings->link_modes.supported);
+	retval &= convert_link_mode_to_legacy_u32(
+		&legacy_settings->advertising,
+		&ksettings->link_modes.advertising);
+	retval &= convert_link_mode_to_legacy_u32(
+		&legacy_settings->lp_advertising,
+		&ksettings->link_modes.lp_advertising);
+	ethtool_cmd_speed_set(legacy_settings, ksettings->parent.speed);
+	legacy_settings->duplex = ksettings->parent.duplex;
+	legacy_settings->port = ksettings->parent.port;
+	legacy_settings->phy_address = ksettings->parent.phy_address;
+	legacy_settings->autoneg = ksettings->parent.autoneg;
+	legacy_settings->mdio_support = ksettings->parent.mdio_support;
+	legacy_settings->eth_tp_mdix = ksettings->parent.eth_tp_mdix;
+	legacy_settings->eth_tp_mdix_ctrl = ksettings->parent.eth_tp_mdix_ctrl;
+	return retval;
+}
+
+/* number of 32-bit words to store the user's link mode bitmaps */
+#define __ETHTOOL_LINK_MODE_MASK_NU32			\
+	((__ETHTOOL_LINK_MODE_MASK_NBITS + 31) / 32)
+
+/* layout of the struct passed from/to userland */
+struct ethtool_usettings {
+	struct ethtool_settings parent;
+	struct {
+		__u32 supported[__ETHTOOL_LINK_MODE_MASK_NU32] __aligned(4);
+		__u32 advertising[__ETHTOOL_LINK_MODE_MASK_NU32] __aligned(4);
+		__u32 lp_advertising[
+			__ETHTOOL_LINK_MODE_MASK_NU32]__aligned(4);
+	} link_modes;
+};
+
+/* Internal kernel helper to query a device ethtool_settings.
+ *
+ * Backward compatibility note: for compatibility with legacy drivers
+ * that implement only the ethtool_cmd API, this has to work with both
+ * drivers implementing get_ksettings API and drivers implementing
+ * get_settings API. When drivers implement get_settings and report
+ * ethtool_cmd deprecated fields (transceiver/maxrxpkt/maxtxpkt),
+ * these fields are silently ignored because the resulting struct
+ * ethtool_settings does not report them.
+ */
+int __ethtool_get_ksettings(struct net_device *dev,
+			    struct ethtool_ksettings *ksettings)
+{
+	int err;
+	struct ethtool_cmd cmd;
+
+	ASSERT_RTNL();
+
+	if (dev->ethtool_ops->get_ksettings) {
+		memset(ksettings, 0, sizeof(*ksettings));
+		return dev->ethtool_ops->get_ksettings(dev, ksettings);
+	}
+
+	/* TODO: remove what follows when ethtool_ops::get_settings
+	 * disappears internally
+	 */
+
+	/* driver doesn't support %ethtool_ksettings API. revert to
+	 * legacy %ethtool_cmd API, unless it's not supported either.
+	 * TODO: remove when ethtool_ops::get_settings disappears internally
+	 */
+	err = __ethtool_get_settings(dev, &cmd);
+	if (err < 0)
+		return err;
+
+	/* we ignore deprecated fields transceiver/maxrxpkt/maxtxpkt
+	 */
+	convert_legacy_settings_to_ksettings(ksettings, &cmd);
+	return err;
+}
+EXPORT_SYMBOL(__ethtool_get_ksettings);
+
+#if BITS_PER_LONG == 64
+static unsigned long _shl32(__u32 v)
+{
+	return ((unsigned long)v) << 32;
+}
+#endif
+
+/* convert a user's __u32[] bitmap in user space to a kernel internal
+ * bitmap. return 0 on success, errno on error. this assumes that
+ * link_mode_masks_nwords was already verified
+ */
+static int load_ksettings_from_user(struct ethtool_ksettings *to,
+				    const void __user *from)
+{
+	struct ethtool_usettings usettings;
+#if BITS_PER_LONG != 32
+	unsigned i;
+#endif
+
+	if (copy_from_user(&usettings, from, sizeof(usettings)))
+		return -EFAULT;
+
+	/* make sure we didn't receive garbage between last allowed bit
+	 * and end of last u32 word
+	 */
+	if (__ETHTOOL_LINK_MODE_MASK_NBITS % 32) {
+		const u32 allowed = (
+			1U << (__ETHTOOL_LINK_MODE_MASK_NBITS % 32)) - 1;
+		if (usettings.link_modes.supported[
+			    __ETHTOOL_LINK_MODE_MASK_NU32-1] & ~allowed)
+			return -EINVAL;
+		if (usettings.link_modes.advertising[
+			    __ETHTOOL_LINK_MODE_MASK_NU32-1] & ~allowed)
+			return -EINVAL;
+		if (usettings.link_modes.lp_advertising[
+			    __ETHTOOL_LINK_MODE_MASK_NU32-1] & ~allowed)
+			return -EINVAL;
+	}
+
+#if BITS_PER_LONG == 32
+	compiletime_assert(sizeof(*to) == sizeof(usettings),
+			   "sizeof(ulong) != 32");
+	memcpy(to, &usettings, sizeof(*to));
+#elif BITS_PER_LONG == 64
+	memset(to, 0, sizeof(*to));
+	memcpy(&to->parent, &usettings.parent, sizeof(to->parent));
+	for (i = 0 ; i < __ETHTOOL_LINK_MODE_MASK_NU32 ; ++i) {
+		if (0 == (i & 1)) {
+			to->link_modes.supported.mask[i>>1]
+				= usettings.link_modes.supported[i];
+			to->link_modes.advertising.mask[i>>1]
+				= usettings.link_modes.advertising[i];
+			to->link_modes.lp_advertising.mask[i>>1]
+				= usettings.link_modes.lp_advertising[i];
+		} else {
+			to->link_modes.supported.mask[i>>1] |= _shl32(
+				usettings.link_modes.supported[i]);
+			to->link_modes.advertising.mask[i>>1] |= _shl32(
+				usettings.link_modes.advertising[i]);
+			to->link_modes.lp_advertising.mask[i>>1] |= _shl32(
+				usettings.link_modes.lp_advertising[i]);
+		}
+	}
+#else
+# error "unsupported ulong width"
+#endif
+	return 0;
+}
+
+/* convert a kernel internal bitmap to a user space __u32[]
+ * bitmap. return 0 on success, errno on error.
+ */
+static int store_ksettings_for_user(void __user *to,
+				    const struct ethtool_ksettings *from)
+{
+	struct ethtool_usettings usettings;
+#if BITS_PER_LONG != 32
+	unsigned i;
+#endif
+
+	compiletime_assert(__ETHTOOL_LINK_MODE_MASK_NU32 <= S8_MAX,
+			   "need too many bits for link modes!");
+
+#if BITS_PER_LONG == 32
+	compiletime_assert(sizeof(*from) == sizeof(usettings),
+			   "sizeof(ulong) != 32");
+	memcpy(&usettings, from, sizeof(usettings));
+#elif BITS_PER_LONG == 64
+	memset(&usettings, 0, sizeof(usettings));
+	memcpy(&usettings.parent, &from->parent, sizeof(usettings));
+	for (i = 0 ; i < __ETHTOOL_LINK_MODE_MASK_NU32 ; ++i) {
+		if (0 == (i & 1)) {
+			usettings.link_modes.supported[i] = lower_32_bits(
+				from->link_modes.supported.mask[i>>1]);
+			usettings.link_modes.advertising[i] = lower_32_bits(
+				from->link_modes.advertising.mask[i>>1]);
+			usettings.link_modes.lp_advertising[i] = lower_32_bits(
+				from->link_modes.lp_advertising.mask[i>>1]);
+		} else {
+			usettings.link_modes.supported[i] = upper_32_bits(
+				from->link_modes.supported.mask[i>>1]);
+			usettings.link_modes.advertising[i] = upper_32_bits(
+				from->link_modes.advertising.mask[i>>1]);
+			usettings.link_modes.lp_advertising[i] = upper_32_bits(
+				from->link_modes.lp_advertising.mask[i>>1]);
+		}
+	}
+#else
+# error "unsupported ulong width"
+#endif
+	if (copy_to_user(to, &usettings, sizeof(usettings)))
+		return -EFAULT;
+
+	return 0;
+}
+
+/* Query device for its ethtool_settings.
+ *
+ * Backward compatibility note: this function must fail when driver
+ * does not implement ethtool::get_ksettings, even if legacy
+ * ethtool_ops::get_settings is implemented. This tells new versions
+ * of ethtool that they should use the legacy API %ETHTOOL_GSET for
+ * this driver, so that they can correctly access the ethtool_cmd
+ * deprecated fields (transceiver/maxrxpkt/maxtxpkt), until no driver
+ * implements ethtool_ops::get_settings anymore.
+ */
+static int ethtool_get_ksettings(struct net_device *dev, void __user *useraddr)
+{
+	int err;
+	struct ethtool_ksettings ksettings;
+
+	if (!dev->ethtool_ops->get_ksettings)
+		return -EOPNOTSUPP;
+
+	/* handle bitmap nbits handshake */
+	if (copy_from_user(&ksettings.parent, useraddr,
+			   sizeof(ksettings.parent)))
+		return -EFAULT;
+
+	if (__ETHTOOL_LINK_MODE_MASK_NU32
+	    != ksettings.parent.link_mode_masks_nwords) {
+		/* wrong link mode nbits requested */
+		memset(&ksettings, 0, sizeof(ksettings));
+		/* keep cmd field reset to 0 */
+		/* send back number of words required as negative val */
+		ksettings.parent.link_mode_masks_nwords
+			= -((s8)__ETHTOOL_LINK_MODE_MASK_NU32);
+		err = 0;
+	} else {
+		memset(&ksettings, 0, sizeof(ksettings));
+		err = dev->ethtool_ops->get_ksettings(dev, &ksettings);
+		if (err < 0)
+			return err;
+
+		/* make sure we tell the right values to user */
+		ksettings.parent.cmd = ETHTOOL_GSETTINGS;
+		ksettings.parent.link_mode_masks_nwords
+			= __ETHTOOL_LINK_MODE_MASK_NU32;
+	}
+
+	return store_ksettings_for_user(useraddr, &ksettings);
+}
+
+/* Update device ethtool_settings.
+ *
+ * Backward compatibility note: this function must fail when driver
+ * does not implement ethtool::set_ksettings, even if legacy
+ * ethtool_ops::set_settings is implemented. This tells new versions
+ * of ethtool that they should use the legacy API %ETHTOOL_SSET for
+ * this driver, so that they can correctly update the ethtool_cmd
+ * deprecated fields (transceiver/maxrxpkt/maxtxpkt), until no driver
+ * implements ethtool_ops::get_settings anymore.
+ */
+static int ethtool_set_ksettings(struct net_device *dev, void __user *useraddr)
+{
+	int err;
+	struct ethtool_ksettings ksettings;
+
+	if (!dev->ethtool_ops->set_ksettings)
+		return -EOPNOTSUPP;
+
+	/* make sure nbits field has expected value */
+	if (copy_from_user(&ksettings.parent, useraddr,
+			   sizeof(ksettings.parent)))
+		return -EFAULT;
+
+	if (__ETHTOOL_LINK_MODE_MASK_NU32
+	    != ksettings.parent.link_mode_masks_nwords)
+		return -EINVAL;
+
+	/* copy the whole structure, now that we know it has expected
+	 * format
+	 */
+	err = load_ksettings_from_user(&ksettings, useraddr);
+	if (err)
+		return err;
+
+	/* re-check nwords field, just in case */
+	if (__ETHTOOL_LINK_MODE_MASK_NU32
+	    != ksettings.parent.link_mode_masks_nwords)
+		return -EINVAL;
+
+	return dev->ethtool_ops->set_ksettings(dev, &ksettings);
+}
+
+/* Internal kernel helper to query a device ethtool_cmd settings.
+ *
+ * Note about transition to ethtool_settings API: We do not need (or
+ * want) this function to support "dev" instances that implement the
+ * ethtool_settings API as we will update the drivers calling this
+ * function to call __ethtool_get_ksettings instead, before the first
+ * drivers implement ethtool_ops::get_ksettings.
+ *
+ * TODO 1: at least make this function static when no driver is using it
+ * TODO 2: remove when ethtool_ops::get_settings disappears internally
+ */
 int __ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	ASSERT_RTNL();
@@ -353,30 +735,119 @@ int __ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 }
 EXPORT_SYMBOL(__ethtool_get_settings);
 
+/* Query device for its ethtool_cmd settings.
+ *
+ * Backward compatibility note: for compatibility with legacy ethtool,
+ * this has to work with both drivers implementing get_ksettings API
+ * and drivers implementing get_settings API. When drivers implement
+ * get_ksettings and report higher link mode bits, a kernel warning is
+ * logged once (with name of 1st driver/device) to recommend user to
+ * upgrade ethtool, but the command is successful (only the lower link
+ * mode bits reported back to user).
+ *
+ * TODO: remove when %ETHTOOL_GSET/%ETHTOOL_SSET disappear
+ */
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 {
-	int err;
 	struct ethtool_cmd cmd;
 
-	err = __ethtool_get_settings(dev, &cmd);
-	if (err < 0)
-		return err;
+	ASSERT_RTNL();
+
+	if (dev->ethtool_ops->get_ksettings) {
+		/* First, use ksettings API if it is supported */
+		int err;
+		struct ethtool_ksettings ksettings;
+
+		memset(&ksettings, 0, sizeof(ksettings));
+		err = dev->ethtool_ops->get_ksettings(dev, &ksettings);
+		if (err < 0)
+			return err;
+		if (!convert_ksettings_to_legacy_settings(&cmd, &ksettings)) {
+			static int __warned;
+
+			/* not all bitmaps could be translated
+			 * acurately to legacy API: print warning with
+			 * netdev name, but does still succeed
+			 */
+			if (!__warned)
+				netdev_warn(dev, "please upgrade ethtool\n");
+			__warned = 1;
+		}
+		/* send a sensible cmd tag back to user */
+		cmd.cmd = ETHTOOL_GSET;
+	} else {
+		int err;
+		/* TODO: return -EOPNOTSUPP when
+		 * ethtool_ops::get_settings disappears internally
+		 */
+
+		/* driver doesn't support %ethtool_ksettings
+		 * API. revert to legacy %ethtool_cmd API, unless it's
+		 * not supported either.
+		 */
+		err = __ethtool_get_settings(dev, &cmd);
+		if (err < 0)
+			return err;
+	}
 
 	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
 		return -EFAULT;
+
 	return 0;
 }
 
+/* Update device settings with given ethtool_cmd.
+ *
+ * Backward compatibility note: for compatibility with legacy ethtool,
+ * this has to work with both drivers implementing set_ksettings API
+ * and drivers implementing set_settings API. When drivers implement
+ * set_ksettings and user's request updates deprecated ethtool_cmd
+ * fields (transceiver/maxrxpkt/maxtxpkt), a kernel warning is logged
+ * once (with name of 1st driver/device) to recommend user to upgrade
+ * ethtool, and the request is rejected.
+ *
+ * TODO: remove when %ETHTOOL_GSET/%ETHTOOL_SSET disappear
+ */
 static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_cmd cmd;
 
-	if (!dev->ethtool_ops->set_settings)
-		return -EOPNOTSUPP;
+	ASSERT_RTNL();
 
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
 
+	/* first, try new %ethtool_ksettings API. */
+	if (dev->ethtool_ops->set_ksettings) {
+		struct ethtool_ksettings ksettings;
+
+		if (!convert_legacy_settings_to_ksettings(&ksettings, &cmd)) {
+			static int __warned;
+
+			/* rejecting setting deprecated fields
+			 * transceiver/maxtxpkt/maxrxpkt
+			 */
+			if (!__warned)
+				netdev_warn(dev, "please upgrade ethtool");
+			__warned = 1;
+			return -EINVAL;
+		}
+
+		ksettings.parent.cmd = ETHTOOL_SSETTINGS;
+		ksettings.parent.link_mode_masks_nwords
+			= __ETHTOOL_LINK_MODE_MASK_NU32;
+		return dev->ethtool_ops->set_ksettings(dev, &ksettings);
+	}
+
+	/* legacy %ethtool_cmd API */
+
+	/* TODO: return -EOPNOTSUPP when ethtool_ops::get_settings
+	 * disappears internally
+	 */
+
+	if (!dev->ethtool_ops->set_settings)
+		return -EOPNOTSUPP;
+
 	return dev->ethtool_ops->set_settings(dev, &cmd);
 }
 
@@ -1979,6 +2450,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_STUNABLE:
 		rc = ethtool_set_tunable(dev, useraddr);
 		break;
+	case ETHTOOL_GSETTINGS:
+		rc = ethtool_get_ksettings(dev, useraddr);
+		break;
+	case ETHTOOL_SSETTINGS:
+		rc = ethtool_set_ksettings(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.2.0.rc0.207.ga3a616c
