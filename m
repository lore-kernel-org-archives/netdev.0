From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 12/17] openvswitch: Allow user space to
	announce ability to accept unaligned Netlink messages
Date: Mon,  6 Jan 2014 16:16:11 -0800
Message-ID: <1389053776-62865-13-git-send-email-jesse@nicira.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Reviewed-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 include/uapi/linux/openvswitch.h |  4 ++++
 net/openvswitch/datapath.c       | 14 ++++++++++++++
 net/openvswitch/datapath.h       |  2 ++
 3 files changed, 20 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index d120f9f..07ef2c3 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -75,6 +75,7 @@ enum ovs_datapath_attr {
 	OVS_DP_ATTR_UPCALL_PID,		/* Netlink PID to receive upcalls */
 	OVS_DP_ATTR_STATS,		/* struct ovs_dp_stats */
 	OVS_DP_ATTR_MEGAFLOW_STATS,	/* struct ovs_dp_megaflow_stats */
+	OVS_DP_ATTR_USER_FEATURES,	/* OVS_DP_F_*  */
 	__OVS_DP_ATTR_MAX
 };
 
@@ -106,6 +107,9 @@ struct ovs_vport_stats {
 	__u64   tx_dropped;		/* no space available in linux  */
 };
 
+/* Allow last Netlink attribute to be unaligned */
+#define OVS_DP_F_UNALIGNED	(1 << 0)
+
 /* Fixed logical ports. */
 #define OVSP_LOCAL      ((__u32)0)
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 50d7782..6a9b0cb 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1040,6 +1040,7 @@ static const struct genl_ops dp_flow_genl_ops[] = {
 static const struct nla_policy datapath_policy[OVS_DP_ATTR_MAX + 1] = {
 	[OVS_DP_ATTR_NAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
 	[OVS_DP_ATTR_UPCALL_PID] = { .type = NLA_U32 },
+	[OVS_DP_ATTR_USER_FEATURES] = { .type = NLA_U32 },
 };
 
 static struct genl_family dp_datapath_genl_family = {
@@ -1098,6 +1099,9 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 			&dp_megaflow_stats))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, OVS_DP_ATTR_USER_FEATURES, dp->user_features))
+		goto nla_put_failure;
+
 	return genlmsg_end(skb, ovs_header);
 
 nla_put_failure:
@@ -1144,6 +1148,12 @@ static struct datapath *lookup_datapath(struct net *net,
 	return dp ? dp : ERR_PTR(-ENODEV);
 }
 
+static void ovs_dp_change(struct datapath *dp, struct nlattr **a)
+{
+	if (a[OVS_DP_ATTR_USER_FEATURES])
+		dp->user_features = nla_get_u32(a[OVS_DP_ATTR_USER_FEATURES]);
+}
+
 static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -1202,6 +1212,8 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.port_no = OVSP_LOCAL;
 	parms.upcall_portid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
 
+	ovs_dp_change(dp, a);
+
 	vport = new_vport(&parms);
 	if (IS_ERR(vport)) {
 		err = PTR_ERR(vport);
@@ -1305,6 +1317,8 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		goto unlock;
 
+	ovs_dp_change(dp, info->attrs);
+
 	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index ba13be4..62619a4 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -88,6 +88,8 @@ struct datapath {
 	/* Network namespace ref. */
 	struct net *net;
 #endif
+
+	u32 user_features;
 };
 
 /**
-- 
1.8.3.2
