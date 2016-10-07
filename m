From: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Subject: [PATCH v5 3/4] cfg80211: configure multicast to unicast for AP interfaces
Date: Fri,  7 Oct 2016 20:39:33 +0200
Message-ID: <1475865574-5384-3-git-send-email-michael-dev@fami-braun.de>
References: <1475865574-5384-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475865574-5384-1-git-send-email-michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This add a userspace toggle to configure multicast to unicast.

Signed-off-by: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
---
 include/net/cfg80211.h       |  6 ++++++
 include/uapi/linux/nl80211.h | 10 ++++++++++
 net/wireless/nl80211.c       | 36 ++++++++++++++++++++++++++++++++++++
 net/wireless/rdev-ops.h      | 12 ++++++++++++
 net/wireless/trace.h         | 19 +++++++++++++++++++
 5 files changed, 83 insertions(+)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 7ce6223..7b0941d 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2460,6 +2460,8 @@ struct cfg80211_qos_map {
  *
  * @set_wds_peer: set the WDS peer for a WDS interface
  *
+ * @set_multicast_to_unicast: configure multicast to unicast conversion for BSS
+ *
  * @rfkill_poll: polls the hw rfkill line, use cfg80211 reporting
  *	functions to adjust rfkill hw state
  *
@@ -2722,6 +2724,10 @@ struct cfg80211_ops {
 	int	(*set_wds_peer)(struct wiphy *wiphy, struct net_device *dev,
 				const u8 *addr);
 
+	int	(*set_multicast_to_unicast)(struct wiphy *wiphy,
+					    struct net_device *dev,
+					    const bool enabled);
+
 	void	(*rfkill_poll)(struct wiphy *wiphy);
 
 #ifdef CONFIG_NL80211_TESTMODE
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 2206941..1b9e87b 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -599,6 +599,9 @@
  *
  * @NL80211_CMD_SET_WDS_PEER: Set the MAC address of the peer on a WDS interface.
  *
+ * @NL80211_CMD_SET_MULTICAST_TO_UNICAST: Configure if AP interface should
+ *      perform multicast to unicast conversion (per-BSS).
+ *
  * @NL80211_CMD_JOIN_MESH: Join a mesh. The mesh ID must be given, and initial
  *	mesh config parameters may be given.
  * @NL80211_CMD_LEAVE_MESH: Leave the mesh network -- no special arguments, the
@@ -1026,6 +1029,8 @@ enum nl80211_commands {
 
 	NL80211_CMD_ABORT_SCAN,
 
+	NL80211_CMD_SET_MULTICAST_TO_UNICAST,
+
 	/* add new commands above here */
 
 	/* used to define NL80211_CMD_MAX below */
@@ -1867,6 +1872,9 @@ enum nl80211_commands {
  * @NL80211_ATTR_MESH_PEER_AID: Association ID for the mesh peer (u16). This is
  *	used to pull the stored data for mesh peer in power save state.
  *
+ * @NL80211_ATTR_MULTICAST_TO_UNICAST_ENABLED: Multicast packets should be
+ *      send out as unicast to all stations.
+ *
  * @NUM_NL80211_ATTR: total number of nl80211_attrs available
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
@@ -2261,6 +2269,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_MESH_PEER_AID,
 
+	NL80211_ATTR_MULTICAST_TO_UNICAST_ENABLED,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index f02653a..57b5d70 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -409,6 +409,7 @@ static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 		.len = VHT_MUMIMO_GROUPS_DATA_LEN
 	},
 	[NL80211_ATTR_MU_MIMO_FOLLOW_MAC_ADDR] = { .len = ETH_ALEN },
+	[NL80211_ATTR_MULTICAST_TO_UNICAST_ENABLED] = { .type = NLA_U8, },
 };
 
 /* policy for the key attributes */
@@ -1538,6 +1539,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 				goto nla_put_failure;
 		}
 		CMD(set_wds_peer, SET_WDS_PEER);
+		CMD(set_multicast_to_unicast, SET_MULTICAST_TO_UNICAST);
 		if (rdev->wiphy.flags & WIPHY_FLAG_SUPPORTS_TDLS) {
 			CMD(tdls_mgmt, TDLS_MGMT);
 			CMD(tdls_oper, TDLS_OPER);
@@ -2164,6 +2166,32 @@ static int nl80211_set_wds_peer(struct sk_buff *skb, struct genl_info *info)
 	return rdev_set_wds_peer(rdev, dev, bssid);
 }
 
+static int nl80211_set_multicast_to_unicast(struct sk_buff *skb,
+					    struct genl_info *info)
+{
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+	const struct nlattr *nla;
+	bool enabled;
+
+	if (!info->attrs[NL80211_ATTR_MULTICAST_TO_UNICAST_ENABLED])
+		return -EINVAL;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	if (!rdev->ops->set_multicast_to_unicast)
+		return -EOPNOTSUPP;
+
+	if (wdev->iftype != NL80211_IFTYPE_AP)
+		return -EOPNOTSUPP;
+
+	nla = info->attrs[NL80211_ATTR_MULTICAST_TO_UNICAST_ENABLED];
+	enabled = nla_get_flag(nla);
+	return rdev_set_multicast_to_unicast(rdev, dev, enabled);
+}
+
 static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev;
@@ -11574,6 +11602,14 @@ static const struct genl_ops nl80211_ops[] = {
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
+		.cmd = NL80211_CMD_SET_MULTICAST_TO_UNICAST,
+		.doit = nl80211_set_multicast_to_unicast,
+		.policy = nl80211_policy,
+		.flags = GENL_UNS_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
+	},
+	{
 		.cmd = NL80211_CMD_JOIN_MESH,
 		.doit = nl80211_join_mesh,
 		.policy = nl80211_policy,
diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
index 85ff30b..7d93c3d 100644
--- a/net/wireless/rdev-ops.h
+++ b/net/wireless/rdev-ops.h
@@ -562,6 +562,18 @@ static inline int rdev_set_wds_peer(struct cfg80211_registered_device *rdev,
 	return ret;
 }
 
+static inline int
+rdev_set_multicast_to_unicast(struct cfg80211_registered_device *rdev,
+			      struct net_device *dev,
+			      const bool enabled)
+{
+	int ret;
+	trace_rdev_set_multicast_to_unicast(&rdev->wiphy, dev, enabled);
+	ret = rdev->ops->set_multicast_to_unicast(&rdev->wiphy, dev, enabled);
+	trace_rdev_return_int(&rdev->wiphy, ret);
+	return ret;
+}
+
 static inline void rdev_rfkill_poll(struct cfg80211_registered_device *rdev)
 {
 	trace_rdev_rfkill_poll(&rdev->wiphy);
diff --git a/net/wireless/trace.h b/net/wireless/trace.h
index 72b5255..8c9aa57 100644
--- a/net/wireless/trace.h
+++ b/net/wireless/trace.h
@@ -2940,6 +2940,25 @@ DEFINE_EVENT(wiphy_wdev_evt, rdev_abort_scan,
 	TP_PROTO(struct wiphy *wiphy, struct wireless_dev *wdev),
 	TP_ARGS(wiphy, wdev)
 );
+
+TRACE_EVENT(rdev_set_multicast_to_unicast,
+	TP_PROTO(struct wiphy *wiphy, struct net_device *netdev,
+		 const bool enabled),
+	TP_ARGS(wiphy, netdev, enabled),
+	TP_STRUCT__entry(
+		WIPHY_ENTRY
+		NETDEV_ENTRY
+		__field(bool, enabled)
+	),
+	TP_fast_assign(
+		WIPHY_ASSIGN;
+		NETDEV_ASSIGN;
+		__entry->enabled = enabled;
+	),
+	TP_printk(WIPHY_PR_FMT ", " NETDEV_PR_FMT ", unicast: %s",
+		  WIPHY_PR_ARG, NETDEV_PR_ARG,
+		  BOOL_TO_STR(__entry->enabled))
+);
 #endif /* !__RDEV_OPS_TRACE || TRACE_HEADER_MULTI_READ */
 
 #undef TRACE_INCLUDE_PATH
-- 
2.1.4
