From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 6/8] openvswitch: Allow update of dp with OVS_DP_CMD_NEW if NLM_F_REPLACE is set
Date: Fri, 22 Nov 2013 17:56:09 +0100
Message-ID: <2b77b94f043dbed36a08dcc0a876830d6ad1a97a.1385137618.git.tgraf@suug.ch>
References: <cover.1385137618.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51499 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755907Ab3KVQ4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 11:56:31 -0500
In-Reply-To: <cover.1385137618.git.tgraf@suug.ch>
In-Reply-To: <cover.1385137618.git.tgraf@suug.ch>
References: <cover.1385137618.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidates ovs_dp_cmd_new() and ovs_dp_cmd_set() to simplify
handling and avoid code duplication.

Allows user space to specify NLM_F_REPLACE with OVS_DP_CMD_NEW and
overwrite the settings such as the user features of an existing
datapath.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/openvswitch/datapath.c | 83 +++++++++++++++++++++++-----------------------
 1 file changed, 42 insertions(+), 41 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 95d4424..3f1fb87 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1175,13 +1175,8 @@ static struct datapath *lookup_datapath(struct net *net,
 	return dp ? dp : ERR_PTR(-ENODEV);
 }
 
-static void ovs_dp_change(struct datapath *dp, struct nlattr **a)
-{
-	if (a[OVS_DP_ATTR_USER_FEATURES])
-		dp->user_features = nla_get_u32(a[OVS_DP_ATTR_USER_FEATURES]);
-}
-
-static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
+static int ovs_dp_create_or_update(struct sk_buff *skb, struct genl_info *info,
+				   bool create)
 {
 	struct nlattr **a = info->attrs;
 	struct vport_parms parms;
@@ -1190,6 +1185,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct vport *vport;
 	struct ovs_net *ovs_net;
 	int err, i;
+	bool allocated = false;
 
 	err = -EINVAL;
 	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
@@ -1197,11 +1193,26 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_lock();
 
+	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
+	if (!IS_ERR(dp)) {
+		if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
+			goto update;
+
+		err = -EEXIST;
+		goto err_unlock_ovs;
+	}
+
+	if (!create) {
+		err = PTR_ERR(dp);
+		goto err_unlock_ovs;
+	}
+
 	err = -ENOMEM;
 	dp = kzalloc(sizeof(*dp), GFP_KERNEL);
 	if (dp == NULL)
 		goto err_unlock_ovs;
 
+	allocated = true;
 	ovs_dp_set_net(dp, hold_net(sock_net(skb->sk)));
 
 	/* Allocate table. */
@@ -1239,8 +1250,6 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.port_no = OVSP_LOCAL;
 	parms.upcall_portid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
 
-	ovs_dp_change(dp, a);
-
 	vport = new_vport(&parms);
 	if (IS_ERR(vport)) {
 		err = PTR_ERR(vport);
@@ -1250,13 +1259,27 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_ports_array;
 	}
 
+update:
+	if (a[OVS_DP_ATTR_USER_FEATURES])
+		dp->user_features = nla_get_u32(a[OVS_DP_ATTR_USER_FEATURES]);
+
 	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
 	err = PTR_ERR(reply);
-	if (IS_ERR(reply))
-		goto err_destroy_local_port;
+	if (IS_ERR(reply)) {
+		if (allocated)
+			goto err_destroy_local_port;
+		else {
+			err = 0;
+			genl_set_err(&dp_datapath_genl_family, sock_net(skb->sk), 0,
+				     0, err);
+			goto err_unlock_ovs;
+		}
+	}
 
-	ovs_net = net_generic(ovs_dp_get_net(dp), ovs_net_id);
-	list_add_tail_rcu(&dp->list_node, &ovs_net->dps);
+	if (allocated) {
+		ovs_net = net_generic(ovs_dp_get_net(dp), ovs_net_id);
+		list_add_tail_rcu(&dp->list_node, &ovs_net->dps);
+	}
 
 	ovs_unlock();
 
@@ -1280,6 +1303,11 @@ err:
 	return err;
 }
 
+static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
+{
+	return ovs_dp_create_or_update(skb, info, true);
+}
+
 /* Called with ovs_mutex. */
 static void __dp_destroy(struct datapath *dp)
 {
@@ -1334,34 +1362,7 @@ unlock:
 
 static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 {
-	struct sk_buff *reply;
-	struct datapath *dp;
-	int err;
-
-	ovs_lock();
-	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
-	err = PTR_ERR(dp);
-	if (IS_ERR(dp))
-		goto unlock;
-
-	ovs_dp_change(dp, info->attrs);
-
-	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
-	if (IS_ERR(reply)) {
-		err = PTR_ERR(reply);
-		genl_set_err(&dp_datapath_genl_family, sock_net(skb->sk), 0,
-			     0, err);
-		err = 0;
-		goto unlock;
-	}
-
-	ovs_unlock();
-	ovs_notify(&dp_datapath_genl_family, reply, info);
-
-	return 0;
-unlock:
-	ovs_unlock();
-	return err;
+	return ovs_dp_create_or_update(skb, info, false);
 }
 
 static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
-- 
1.8.3.1
