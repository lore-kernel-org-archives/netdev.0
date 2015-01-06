From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 1/8] net: ethtool: internal compatibility flags to reject non-zero reserved fields
Date: Mon,  5 Jan 2015 18:54:03 -0800
Message-ID: <1420512850-24699-2-git-send-email-ddecotig@gmail.com>
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

The public ethtool API progressively shrinks "reserved" fields to
expand some other fields (eg. link mode masks). This patch allows
drivers to declare that they fully support expanded fields. When they
don't do so, the generic ethtool layer may reject (-EINVAL) userspace
requests that assign values utilizing the newly allocated areas in
these expanded fields (ie. when some reserved field receives != 0).

Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
---
 include/linux/ethtool.h      | 19 +++++++++++++++++--
 include/uapi/linux/ethtool.h |  6 +++++-
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c..dcb08c1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -44,6 +44,17 @@ extern int __ethtool_get_settings(struct net_device *dev,
 				  struct ethtool_cmd *cmd);
 
 /**
+ * enum ethtool_compat_flags - bit indices used for %get_compat_flags() bitmaps
+ * @__ETHTOOL_COMPAT_PLACEHOLDER_BIT: to avoid a compiler error,
+ *                                    superseded by next patches
+ */
+enum ethtool_compat_flags {
+	__ETHTOOL_COMPAT_PLACEHOLDER_BIT,
+};
+
+#define __ETH_COMPAT_MASK(name)	(1UL << (ETHTOOL_COMPAT_ ## name ## _BIT))
+
+/**
  * enum ethtool_phys_id_state - indicator state for physical identification
  * @ETHTOOL_ID_INACTIVE: Physical ID indicator should be deactivated
  * @ETHTOOL_ID_ACTIVE: Physical ID indicator should be activated
@@ -99,6 +110,11 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
 
 /**
  * struct ethtool_ops - optional netdev operations
+ * @get_compat_flags: Internal function. Returns the internal ethtool
+ *      compatibility flags: in the absence of this method, or of
+ *      specific compatilibilty flags, the generic layer enforces
+ *      additional constraints on the user space values before
+ *      calling the callbacks below.
  * @get_settings: Get various device settings including Ethernet link
  *	settings. The @cmd parameter is expected to have been cleared
  *	before get_settings is called. Returns a negative error code or
@@ -279,7 +295,6 @@ struct ethtool_ops {
 			       const struct ethtool_tunable *, void *);
 	int	(*set_tunable)(struct net_device *,
 			       const struct ethtool_tunable *, const void *);
-
-
+	u32	(*get_compat_flags)(struct net_device *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f66d9c..d063368 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -88,7 +88,8 @@
  * other than @cmd that are not described as read-only or deprecated,
  * and must ignore all fields described as read-only.
  *
- * Deprecated fields should be ignored by both users and drivers.
+ * Deprecated and reserved fields should be ignored by both users and
+ * drivers. If reserved fields must be set, store the value 0 in them.
  */
 struct ethtool_cmd {
 	__u32	cmd;
@@ -300,6 +301,9 @@ struct ethtool_eeprom {
  * @tx_lpi_timer: Time in microseconds the interface delays prior to asserting
  *	its tx lpi (after reaching 'idle' state). Effective only when eee
  *	was negotiated and tx_lpi_enabled was set.
+ *
+ * Deprecated and reserved fields should be ignored by both users and
+ * drivers. If reserved fields must be set, store the value 0 in them.
  */
 struct ethtool_eee {
 	__u32	cmd;
-- 
2.2.0.rc0.207.ga3a616c
