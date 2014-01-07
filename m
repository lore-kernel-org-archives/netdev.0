From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 13/17] openvswitch: Drop user features if
	old user space attempted to create datapath
Date: Mon,  6 Jan 2014 16:16:12 -0800
Message-ID: <1389053776-62865-14-git-send-email-jesse@nicira.com>
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

Drop user features if an outdated user space instance that does not
understand the concept of user_features attempted to create a new
datapath.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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
index 6a9b0cb..497b2fd 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1148,6 +1148,18 @@ static struct datapath *lookup_datapath(struct net *net,
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
@@ -1220,6 +1232,15 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
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
1.8.3.2
