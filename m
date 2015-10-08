From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] openvswitch: report features supported by the kernel datapath
Date: Thu,  8 Oct 2015 15:53:04 +0200
Message-ID: <f035dbc85f4fb7e8c8691801849a9db286154bde.1444312374.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932876AbbJHNx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 09:53:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the user space to query what features are supported by the openvswitch
module. This will be used to allow or disallow certain configurations and/or
switch between newer and older APIs depending on what the kernel supports.

Two features are reported as supported by this patch: lwtunnel and IPv6
tunneling support. Theoretically, we could merge these two, as any of them
implies the other with this patch applied, but it's better to keep them
separate: kernel 4.3 supports lwtunnels but not IPv6 for ovs, and the
separation of the two flags allows us to backport a version of this patch
to 4.3 should the need arise.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
This is intentionally submitted to net-next. Kernel 4.3 will be fine without
this feature (but despite that, I'd like to keep the two flags separate).
---
 include/uapi/linux/openvswitch.h | 12 ++++++++++++
 net/openvswitch/datapath.c       | 21 ++++++++++++++++++---
 2 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 32e07d8cbaf4..3d8d00b6e55d 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -73,6 +73,10 @@ enum ovs_datapath_cmd {
  * datapath.  Always present in notifications.
  * @OVS_DP_ATTR_MEGAFLOW_STATS: Statistics about mega flow masks usage for the
  * datapath. Always present in notifications.
+ * @OVS_DP_ATTR_KERNEL_FEATURES: Bitmask of features that the datapath
+ * supports.  When creating a datapath, this is a minimal feature set
+ * requested, the request will fail if it cannot be honored.  On get
+ * operations, this contains all features supported by the datapath.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_DP_* commands.
@@ -84,6 +88,7 @@ enum ovs_datapath_attr {
 	OVS_DP_ATTR_STATS,		/* struct ovs_dp_stats */
 	OVS_DP_ATTR_MEGAFLOW_STATS,	/* struct ovs_dp_megaflow_stats */
 	OVS_DP_ATTR_USER_FEATURES,	/* OVS_DP_F_*  */
+	OVS_DP_ATTR_KERNEL_FEATURES,	/* OVS_DP_KF_* */
 	__OVS_DP_ATTR_MAX
 };
 
@@ -121,6 +126,13 @@ struct ovs_vport_stats {
 /* Allow datapath to associate multiple Netlink PIDs to each vport */
 #define OVS_DP_F_VPORT_PIDS	(1 << 1)
 
+/* Datapath features */
+#define OVS_DP_KF_LWTUNNEL	(1ULL << 0)  /* lwtunnel interface supported */
+#define OVS_DP_KF_IPV6_TUNNEL	(1ULL << 1)  /* IPv6 tunneling supported */
+
+#define OVS_DP_KF_ALL		(OVS_DP_KF_LWTUNNEL | \
+				 OVS_DP_KF_IPV6_TUNNEL)
+
 /* Fixed logical ports. */
 #define OVSP_LOCAL      ((__u32)0)
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index a75828091e21..896435779fc8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1439,6 +1439,7 @@ static size_t ovs_dp_cmd_msg_size(void)
 	msgsize += nla_total_size(sizeof(struct ovs_dp_stats));
 	msgsize += nla_total_size(sizeof(struct ovs_dp_megaflow_stats));
 	msgsize += nla_total_size(sizeof(u32)); /* OVS_DP_ATTR_USER_FEATURES */
+	msgsize += nla_total_size(sizeof(u64)); /* OVS_DP_ATTR_KERNEL_FEATURES */
 
 	return msgsize;
 }
@@ -1476,6 +1477,9 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 	if (nla_put_u32(skb, OVS_DP_ATTR_USER_FEATURES, dp->user_features))
 		goto nla_put_failure;
 
+	if (nla_put_u64(skb, OVS_DP_ATTR_KERNEL_FEATURES, OVS_DP_KF_ALL))
+		goto nla_put_failure;
+
 	genlmsg_end(skb, ovs_header);
 	return 0;
 
@@ -1526,6 +1530,13 @@ static void ovs_dp_change(struct datapath *dp, struct nlattr *a[])
 		dp->user_features = nla_get_u32(a[OVS_DP_ATTR_USER_FEATURES]);
 }
 
+static bool ovs_dp_kernel_features_ok(struct nlattr *a[])
+{
+	if (!a[OVS_DP_ATTR_KERNEL_FEATURES])
+		return true;
+	return !(nla_get_u64(a[OVS_DP_ATTR_KERNEL_FEATURES]) & ~OVS_DP_KF_ALL);
+}
+
 static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -1536,9 +1547,10 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct ovs_net *ovs_net;
 	int err, i;
 
-	err = -EINVAL;
 	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
-		goto err;
+		return -EINVAL;
+	if (!ovs_dp_kernel_features_ok(a))
+		return -EOPNOTSUPP;
 
 	reply = ovs_dp_cmd_alloc_info(info);
 	if (!reply)
@@ -1626,7 +1638,6 @@ err_free_dp:
 	kfree(dp);
 err_free_reply:
 	kfree_skb(reply);
-err:
 	return err;
 }
 
@@ -1694,6 +1705,9 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
+	if (!ovs_dp_kernel_features_ok(info->attrs))
+		return -EOPNOTSUPP;
+
 	reply = ovs_dp_cmd_alloc_info(info);
 	if (!reply)
 		return -ENOMEM;
@@ -1777,6 +1791,7 @@ static const struct nla_policy datapath_policy[OVS_DP_ATTR_MAX + 1] = {
 	[OVS_DP_ATTR_NAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
 	[OVS_DP_ATTR_UPCALL_PID] = { .type = NLA_U32 },
 	[OVS_DP_ATTR_USER_FEATURES] = { .type = NLA_U32 },
+	[OVS_DP_ATTR_KERNEL_FEATURES] = { .type = NLA_U64 },
 };
 
 static const struct genl_ops dp_datapath_genl_ops[] = {
-- 
1.8.3.1
