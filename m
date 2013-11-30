From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next 6/7] openvswitch: Drop user features if old user space attempted to create datapath
Date: Sat, 30 Nov 2013 13:21:35 +0100
Message-ID: <eae8cb8b9741f6150a205244a7dc3fdfd128950c.1385813891.git.tgraf@suug.ch>
References: <cover.1385813891.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:59199 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab3K3MVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 07:21:55 -0500
In-Reply-To: <cover.1385813891.git.tgraf@suug.ch>
In-Reply-To: <cover.1385813891.git.tgraf@suug.ch>
References: <cover.1385813891.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop user features if an outdated user space instance that does not
understand the concept of user_features attempted to create a new
datapath.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/uapi/linux/openvswitch.h | 10 +++++++++-
 net/openvswitch/datapath.c       | 21 +++++++++++++++++++++
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 07ef2c3..970553c 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -40,7 +40,15 @@ struct ovs_header {
 
 #define OVS_DATAPATH_FAMILY  "ovs_datapath"
 #define OVS_DATAPATH_MCGROUP "ovs_datapath"
-#define OVS_DATAPATH_VERSION 0x1
+
+/* V2:
+ *   - API users are expected to provide OVS_DP_ATTR_USER_FEATURES
+ *     when creating the datapath.
+ */
+#define OVS_DATAPATH_VERSION 2
+
+/* First OVS datapath version to support features */
+#define OVS_DP_VER_FEATURES 2
 
 enum ovs_datapath_cmd {
 	OVS_DP_CMD_UNSPEC,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 95d4424..8eaa39a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1175,6 +1175,18 @@ static struct datapath *lookup_datapath(struct net *net,
 	return dp ? dp : ERR_PTR(-ENODEV);
 }
 
+static void ovs_dp_reset_user_features(struct sk_buff *skb, struct genl_info *info)
+{
+	struct datapath *dp;
+
+	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
+	if (!dp)
+		return;
+
+	WARN(dp->user_features, "Dropping previously announced user features\n");
+	dp->user_features = 0;
+}
+
 static void ovs_dp_change(struct datapath *dp, struct nlattr **a)
 {
 	if (a[OVS_DP_ATTR_USER_FEATURES])
@@ -1247,6 +1259,15 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		if (err == -EBUSY)
 			err = -EEXIST;
 
+		if (err == -EEXIST) {
+			/* An outdated user space instance that does not understand
+			 * the concept of user_features has attempted to create a new
+			 * datapath and is likely to reuse it. Drop all user features.
+			 */
+			if (info->genlhdr->version < OVS_DP_VER_FEATURES)
+				ovs_dp_reset_user_features(skb, info);
+		}
+
 		goto err_destroy_ports_array;
 	}
 
-- 
1.8.3.1
