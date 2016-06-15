From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] nl80211: improve nl80211_parse_mesh_config type checking
Date: Wed, 15 Jun 2016 22:29:41 +0200
Message-ID: <20160615203012.3544326-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building a kernel with W=1, the nl80211.c file causes a number of
warnings, all about the same problem:

net/wireless/nl80211.c: In function 'nl80211_parse_mesh_config':
net/wireless/nl80211.c:5287:103: error: comparison is always false due to limited range of data type [-Werror=type-limits]
net/wireless/nl80211.c:5290:96: error: comparison is always false due to limited range of data type [-Werror=type-limits]
net/wireless/nl80211.c:5293:124: error: comparison is always false due to limited range of data type [-Werror=type-limits]
net/wireless/nl80211.c:5295:148: error: comparison is always false due to limited range of data type [-Werror=type-limits]
net/wireless/nl80211.c:5298:106: error: comparison is always false due to limited range of data type [-Werror=type-limits]
net/wireless/nl80211.c:5305:116: error: comparison is always false due to limited range of data type [-Werror=type-limits]

The problem is that gcc does not notice that the check is generate
by a macro, so it complains about comparing an unsigned type against 0.

I've tried to come up with a way to rephrase that code in a way that
avoids the warnings and otherwise improves the code as well.

This uses a set of new helper functions that perform the range checking,
and should provide slightly better type safety than the older patch,
at the expense of adding 44 lines to the code. Binary code size is
basically unchanged though (20 bytes added to 126561 bytes .text).

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/wireless/nl80211.c | 104 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 74 insertions(+), 30 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index c503e96bfd5a..244d552d5647 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -5287,6 +5287,51 @@ static const struct nla_policy
 	[NL80211_MESH_SETUP_USERSPACE_AMPE] = { .type = NLA_FLAG },
 };
 
+static int nl80211_check_bool(const struct nlattr *nla, u8 min, u8 max, bool *out)
+{
+	u8 val = nla_get_u8(nla);
+	if (val < min || val > max)
+		return -EINVAL;
+	*out = val;
+	return 0;
+}
+
+static int nl80211_check_u8(const struct nlattr *nla, u8 min, u8 max, u8 *out)
+{
+	u8 val = nla_get_u8(nla);
+	if (val < min || val > max)
+		return -EINVAL;
+	*out = val;
+	return 0;
+}
+
+static int nl80211_check_u16(const struct nlattr *nla, u16 min, u16 max, u16 *out)
+{
+	u16 val = nla_get_u16(nla);
+	if (val < min || val > max)
+		return -EINVAL;
+	*out = val;
+	return 0;
+}
+
+static int nl80211_check_u32(const struct nlattr *nla, u32 min, u32 max, u32 *out)
+{
+	u32 val = nla_get_u32(nla);
+	if (val < min || val > max)
+		return -EINVAL;
+	*out = val;
+	return 0;
+}
+
+static int nl80211_check_s32(const struct nlattr *nla, s32 min, s32 max, s32 *out)
+{
+	s32 val = nla_get_s32(nla);
+	if (val < min || val > max)
+		return -EINVAL;
+	*out = val;
+	return 0;
+}
+
 static int nl80211_parse_mesh_config(struct genl_info *info,
 				     struct mesh_config *cfg,
 				     u32 *mask_out)
@@ -5297,9 +5342,8 @@ static int nl80211_parse_mesh_config(struct genl_info *info,
 #define FILL_IN_MESH_PARAM_IF_SET(tb, cfg, param, min, max, mask, attr, fn) \
 do {									    \
 	if (tb[attr]) {							    \
-		if (fn(tb[attr]) < min || fn(tb[attr]) > max)		    \
+		if (fn(tb[attr], min, max, &cfg->param))		    \
 			return -EINVAL;					    \
-		cfg->param = fn(tb[attr]);				    \
 		mask |= (1 << (attr - 1));				    \
 	}								    \
 } while (0)
@@ -5318,99 +5362,99 @@ do {									    \
 	/* Fill in the params struct */
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshRetryTimeout, 1, 255,
 				  mask, NL80211_MESHCONF_RETRY_TIMEOUT,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshConfirmTimeout, 1, 255,
 				  mask, NL80211_MESHCONF_CONFIRM_TIMEOUT,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHoldingTimeout, 1, 255,
 				  mask, NL80211_MESHCONF_HOLDING_TIMEOUT,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshMaxPeerLinks, 0, 255,
 				  mask, NL80211_MESHCONF_MAX_PEER_LINKS,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshMaxRetries, 0, 16,
 				  mask, NL80211_MESHCONF_MAX_RETRIES,
-				  nla_get_u8);
+				  nl80211_check_u8);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshTTL, 1, 255,
-				  mask, NL80211_MESHCONF_TTL, nla_get_u8);
+				  mask, NL80211_MESHCONF_TTL, nl80211_check_u8);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, element_ttl, 1, 255,
 				  mask, NL80211_MESHCONF_ELEMENT_TTL,
-				  nla_get_u8);
+				  nl80211_check_u8);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, auto_open_plinks, 0, 1,
 				  mask, NL80211_MESHCONF_AUTO_OPEN_PLINKS,
-				  nla_get_u8);
+				  nl80211_check_bool);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshNbrOffsetMaxNeighbor,
 				  1, 255, mask,
 				  NL80211_MESHCONF_SYNC_OFFSET_MAX_NEIGHBOR,
-				  nla_get_u32);
+				  nl80211_check_u32);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMPmaxPREQretries, 0, 255,
 				  mask, NL80211_MESHCONF_HWMP_MAX_PREQ_RETRIES,
-				  nla_get_u8);
+				  nl80211_check_u8);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, path_refresh_time, 1, 65535,
 				  mask, NL80211_MESHCONF_PATH_REFRESH_TIME,
-				  nla_get_u32);
+				  nl80211_check_u32);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, min_discovery_timeout, 1, 65535,
 				  mask, NL80211_MESHCONF_MIN_DISCOVERY_TIMEOUT,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMPactivePathTimeout,
 				  1, 65535, mask,
 				  NL80211_MESHCONF_HWMP_ACTIVE_PATH_TIMEOUT,
-				  nla_get_u32);
+				  nl80211_check_u32);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMPpreqMinInterval,
 				  1, 65535, mask,
 				  NL80211_MESHCONF_HWMP_PREQ_MIN_INTERVAL,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMPperrMinInterval,
 				  1, 65535, mask,
 				  NL80211_MESHCONF_HWMP_PERR_MIN_INTERVAL,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg,
 				  dot11MeshHWMPnetDiameterTraversalTime,
 				  1, 65535, mask,
 				  NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMPRootMode, 0, 4,
 				  mask, NL80211_MESHCONF_HWMP_ROOTMODE,
-				  nla_get_u8);
+				  nl80211_check_u8);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMPRannInterval, 1, 65535,
 				  mask, NL80211_MESHCONF_HWMP_RANN_INTERVAL,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg,
 				  dot11MeshGateAnnouncementProtocol, 0, 1,
 				  mask, NL80211_MESHCONF_GATE_ANNOUNCEMENTS,
-				  nla_get_u8);
+				  nl80211_check_bool);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshForwarding, 0, 1,
 				  mask, NL80211_MESHCONF_FORWARDING,
-				  nla_get_u8);
+				  nl80211_check_bool);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, rssi_threshold, -255, 0,
 				  mask, NL80211_MESHCONF_RSSI_THRESHOLD,
-				  nla_get_s32);
+				  nl80211_check_s32);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, ht_opmode, 0, 16,
 				  mask, NL80211_MESHCONF_HT_OPMODE,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMPactivePathToRootTimeout,
 				  1, 65535, mask,
 				  NL80211_MESHCONF_HWMP_PATH_TO_ROOT_TIMEOUT,
-				  nla_get_u32);
+				  nl80211_check_u32);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshHWMProotInterval, 1, 65535,
 				  mask, NL80211_MESHCONF_HWMP_ROOT_INTERVAL,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg,
 				  dot11MeshHWMPconfirmationInterval,
 				  1, 65535, mask,
 				  NL80211_MESHCONF_HWMP_CONFIRMATION_INTERVAL,
-				  nla_get_u16);
+				  nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, power_mode,
 				  NL80211_MESH_POWER_ACTIVE,
 				  NL80211_MESH_POWER_MAX,
 				  mask, NL80211_MESHCONF_POWER_MODE,
-				  nla_get_u32);
+				  nl80211_check_u32);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, dot11MeshAwakeWindowDuration,
 				  0, 65535, mask,
-				  NL80211_MESHCONF_AWAKE_WINDOW, nla_get_u16);
+				  NL80211_MESHCONF_AWAKE_WINDOW, nl80211_check_u16);
 	FILL_IN_MESH_PARAM_IF_SET(tb, cfg, plink_timeout, 0, 0xffffffff,
 				  mask, NL80211_MESHCONF_PLINK_TIMEOUT,
-				  nla_get_u32);
+				  nl80211_check_u32);
 	if (mask_out)
 		*mask_out = mask;
 
-- 
2.9.0
