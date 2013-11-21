From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 7/8] openvswitch: Drop user features if old user space attempted to create datapath
Date: Thu, 21 Nov 2013 19:13:38 +0100
Message-ID: <68ddfb6e0ef4401f246f2599ade5c15b25063736.1385057355.git.tgraf@suug.ch>
References: <cover.1385057355.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:54633 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702Ab3KUSN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:13:59 -0500
In-Reply-To: <cover.1385057355.git.tgraf@suug.ch>
In-Reply-To: <cover.1385057355.git.tgraf@suug.ch>
References: <cover.1385057355.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop user features if an outdated user space instance that does not
understand the concept of user_features attempted to create a new
datapath.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/uapi/linux/openvswitch.h | 11 ++++++++++-
 net/openvswitch/datapath.c       | 10 ++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 07ef2c3..4f74c2c 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -40,7 +40,16 @@ struct ovs_header {
 
 #define OVS_DATAPATH_FAMILY  "ovs_datapath"
 #define OVS_DATAPATH_MCGROUP "ovs_datapath"
-#define OVS_DATAPATH_VERSION 0x1
+
+/**
+ * V2:
+ *   - API users are expected to provide OVS_DP_ATTR_USER_FEATURES
+ *     with NLM_F_REPLACE when creating the datapath.
+ */
+#define OVS_DATAPATH_VERSION 2
+
+/* First OVS datapath version to support features */
+#define OVS_DP_VER_FEATURES 2
 
 enum ovs_datapath_cmd {
 	OVS_DP_CMD_UNSPEC,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 3f1fb87..72cdffb 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1198,6 +1198,16 @@ static int ovs_dp_create_or_update(struct sk_buff *skb, struct genl_info *info,
 		if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
 			goto update;
 
+		/* An outdated user space instance that does not understand
+		 * the concept of user_features has attempted to create a new
+		 * datapath. Drop all user features.
+		 */
+		if (info->genlhdr->version < OVS_DP_VER_FEATURES) {
+			WARN_ONCE(dp->user_features, "Dropping previously "
+				  "announced user features");
+			dp->user_features = 0;
+		}
+
 		err = -EEXIST;
 		goto err_unlock_ovs;
 	}
-- 
1.8.3.1
