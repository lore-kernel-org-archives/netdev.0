From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: [PATCH v2 1/2] nl80211: Allow privileged operations from user namespaces
Date: Mon,  9 May 2016 18:33:58 +0200
Message-ID: <1462811639-29906-2-git-send-email-martin@strongswan.org>
References: <1462811639-29906-1-git-send-email-martin@strongswan.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462811639-29906-1-git-send-email-martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

While a wiphy can be transferred to network namespaces, a process having
CAP_NET_ADMIN in a non-initial user namespace can not administrate such
devices due to the genetlink GENL_ADMIN_PERM restrictions.

For openvswitch having the same issue, a new GENL_UNS_ADMIN_PERM flag has
been introduced, commit 4a92602aa1cd ("openvswitch: allow management from
inside user namespaces"). This patch changes all privileged operations
operating on a wiphy, dev or wdev to allow their administration using the
same mechanism. All operations use either NEED_WIPHY, NEED_WDEV or
NEED_NETDEV, which implies a namespace aware lookup of the device. The only
exception is NL80211_CMD_SET_WIPHY, which explicitly uses a namespace aware
phy lookup.

Signed-off-by: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
---
 net/wireless/nl80211.c | 150 ++++++++++++++++++++++++-------------------------
 1 file changed, 75 insertions(+), 75 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 9bc84a2..df4c897 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -10945,7 +10945,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_WIPHY,
 		.doit = nl80211_set_wiphy,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -10961,7 +10961,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_INTERFACE,
 		.doit = nl80211_set_interface,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -10969,7 +10969,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_NEW_INTERFACE,
 		.doit = nl80211_new_interface,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WIPHY |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -10977,7 +10977,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DEL_INTERFACE,
 		.doit = nl80211_del_interface,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -10985,7 +10985,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_GET_KEY,
 		.doit = nl80211_get_key,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -10993,7 +10993,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_KEY,
 		.doit = nl80211_set_key,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL |
 				  NL80211_FLAG_CLEAR_SKB,
@@ -11002,7 +11002,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_NEW_KEY,
 		.doit = nl80211_new_key,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL |
 				  NL80211_FLAG_CLEAR_SKB,
@@ -11011,14 +11011,14 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DEL_KEY,
 		.doit = nl80211_del_key,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_BEACON,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.doit = nl80211_set_beacon,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
@@ -11026,7 +11026,7 @@ static const struct genl_ops nl80211_ops[] = {
 	{
 		.cmd = NL80211_CMD_START_AP,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.doit = nl80211_start_ap,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
@@ -11034,7 +11034,7 @@ static const struct genl_ops nl80211_ops[] = {
 	{
 		.cmd = NL80211_CMD_STOP_AP,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.doit = nl80211_stop_ap,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
@@ -11051,7 +11051,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_STATION,
 		.doit = nl80211_set_station,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11059,7 +11059,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_NEW_STATION,
 		.doit = nl80211_new_station,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11067,7 +11067,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DEL_STATION,
 		.doit = nl80211_del_station,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11076,7 +11076,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_get_mpath,
 		.dumpit = nl80211_dump_mpath,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11085,7 +11085,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_get_mpp,
 		.dumpit = nl80211_dump_mpp,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11093,7 +11093,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_MPATH,
 		.doit = nl80211_set_mpath,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11101,7 +11101,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_NEW_MPATH,
 		.doit = nl80211_new_mpath,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11109,7 +11109,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DEL_MPATH,
 		.doit = nl80211_del_mpath,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11117,7 +11117,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_BSS,
 		.doit = nl80211_set_bss,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11156,7 +11156,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_MESH_CONFIG,
 		.doit = nl80211_update_mesh_config,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11164,7 +11164,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_TRIGGER_SCAN,
 		.doit = nl80211_trigger_scan,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11185,7 +11185,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_START_SCHED_SCAN,
 		.doit = nl80211_start_sched_scan,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11193,7 +11193,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_STOP_SCHED_SCAN,
 		.doit = nl80211_stop_sched_scan,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11201,7 +11201,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_AUTHENTICATE,
 		.doit = nl80211_authenticate,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL |
 				  NL80211_FLAG_CLEAR_SKB,
@@ -11210,7 +11210,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_ASSOCIATE,
 		.doit = nl80211_associate,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11218,7 +11218,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DEAUTHENTICATE,
 		.doit = nl80211_deauthenticate,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11226,7 +11226,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DISASSOCIATE,
 		.doit = nl80211_disassociate,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11234,7 +11234,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_JOIN_IBSS,
 		.doit = nl80211_join_ibss,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11242,7 +11242,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_LEAVE_IBSS,
 		.doit = nl80211_leave_ibss,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11252,7 +11252,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_testmode_do,
 		.dumpit = nl80211_testmode_dump,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WIPHY |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11261,7 +11261,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_CONNECT,
 		.doit = nl80211_connect,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11269,7 +11269,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DISCONNECT,
 		.doit = nl80211_disconnect,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11277,7 +11277,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_WIPHY_NETNS,
 		.doit = nl80211_wiphy_netns,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WIPHY |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11290,7 +11290,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_PMKSA,
 		.doit = nl80211_setdel_pmksa,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11298,7 +11298,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DEL_PMKSA,
 		.doit = nl80211_setdel_pmksa,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11306,7 +11306,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_FLUSH_PMKSA,
 		.doit = nl80211_flush_pmksa,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11314,7 +11314,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_REMAIN_ON_CHANNEL,
 		.doit = nl80211_remain_on_channel,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11322,7 +11322,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_CANCEL_REMAIN_ON_CHANNEL,
 		.doit = nl80211_cancel_remain_on_channel,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11330,7 +11330,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_TX_BITRATE_MASK,
 		.doit = nl80211_set_tx_bitrate_mask,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11338,7 +11338,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_REGISTER_FRAME,
 		.doit = nl80211_register_mgmt,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11346,7 +11346,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_FRAME,
 		.doit = nl80211_tx_mgmt,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11354,7 +11354,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_FRAME_WAIT_CANCEL,
 		.doit = nl80211_tx_mgmt_cancel_wait,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11362,7 +11362,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_POWER_SAVE,
 		.doit = nl80211_set_power_save,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11378,7 +11378,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_CQM,
 		.doit = nl80211_set_cqm,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11386,7 +11386,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_CHANNEL,
 		.doit = nl80211_set_channel,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11394,7 +11394,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_WDS_PEER,
 		.doit = nl80211_set_wds_peer,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11402,7 +11402,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_JOIN_MESH,
 		.doit = nl80211_join_mesh,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11410,7 +11410,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_LEAVE_MESH,
 		.doit = nl80211_leave_mesh,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11418,7 +11418,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_JOIN_OCB,
 		.doit = nl80211_join_ocb,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11426,7 +11426,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_LEAVE_OCB,
 		.doit = nl80211_leave_ocb,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11443,7 +11443,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_WOWLAN,
 		.doit = nl80211_set_wowlan,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WIPHY |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11452,7 +11452,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_REKEY_OFFLOAD,
 		.doit = nl80211_set_rekey_data,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL |
 				  NL80211_FLAG_CLEAR_SKB,
@@ -11461,7 +11461,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_TDLS_MGMT,
 		.doit = nl80211_tdls_mgmt,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11469,7 +11469,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_TDLS_OPER,
 		.doit = nl80211_tdls_oper,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11477,7 +11477,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_UNEXPECTED_FRAME,
 		.doit = nl80211_register_unexpected_frame,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11485,7 +11485,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_PROBE_CLIENT,
 		.doit = nl80211_probe_client,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11493,7 +11493,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_REGISTER_BEACONS,
 		.doit = nl80211_register_beacons,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WIPHY |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11501,7 +11501,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_NOACK_MAP,
 		.doit = nl80211_set_noack_map,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11509,7 +11509,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_START_P2P_DEVICE,
 		.doit = nl80211_start_p2p_device,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11517,7 +11517,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_STOP_P2P_DEVICE,
 		.doit = nl80211_stop_p2p_device,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11525,7 +11525,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_MCAST_RATE,
 		.doit = nl80211_set_mcast_rate,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11533,7 +11533,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_MAC_ACL,
 		.doit = nl80211_set_mac_acl,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11541,7 +11541,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_RADAR_DETECT,
 		.doit = nl80211_start_radar_detection,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11554,7 +11554,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_UPDATE_FT_IES,
 		.doit = nl80211_update_ft_ies,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11562,7 +11562,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_CRIT_PROTOCOL_START,
 		.doit = nl80211_crit_protocol_start,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11570,7 +11570,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_CRIT_PROTOCOL_STOP,
 		.doit = nl80211_crit_protocol_stop,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11585,7 +11585,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_COALESCE,
 		.doit = nl80211_set_coalesce,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WIPHY |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11593,7 +11593,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_CHANNEL_SWITCH,
 		.doit = nl80211_channel_switch,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11602,7 +11602,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_vendor_cmd,
 		.dumpit = nl80211_vendor_cmd_dump,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_WIPHY |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11610,7 +11610,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_SET_QOS_MAP,
 		.doit = nl80211_set_qos_map,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11618,7 +11618,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_ADD_TX_TS,
 		.doit = nl80211_add_tx_ts,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11626,7 +11626,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_DEL_TX_TS,
 		.doit = nl80211_del_tx_ts,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11634,7 +11634,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_TDLS_CHANNEL_SWITCH,
 		.doit = nl80211_tdls_channel_switch,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
@@ -11642,7 +11642,7 @@ static const struct genl_ops nl80211_ops[] = {
 		.cmd = NL80211_CMD_TDLS_CANCEL_CHANNEL_SWITCH,
 		.doit = nl80211_tdls_cancel_channel_switch,
 		.policy = nl80211_policy,
-		.flags = GENL_ADMIN_PERM,
+		.flags = GENL_UNS_ADMIN_PERM,
 		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
