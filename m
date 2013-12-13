From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 3/6] openvswitch: Drop user features if old user space attempted to create datapath
Date: Fri, 13 Dec 2013 15:22:19 +0100
Message-ID: <e28d8f29aaa038bf4bc98abfc5a4cf054a07586d.1386943635.git.tgraf@suug.ch>
References: <cover.1386943635.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, eric.dumazet@gmail.com, fleitner@redhat.com,
	ffusco@redhat.com, dborkmann@redhat.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:43935 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744Ab3LMOWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 09:22:42 -0500
In-Reply-To: <cover.1386943635.git.tgraf@suug.ch>
In-Reply-To: <cover.1386943635.git.tgraf@suug.ch>
References: <cover.1386943635.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop user features if an outdated user space instance that does not
understand the concept of user_features attempted to create a new
datapath.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
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
