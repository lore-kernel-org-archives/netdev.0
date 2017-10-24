From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/7] devlink: Add per devlink instance lock
Date: Tue, 24 Oct 2017 11:22:40 +0200
Message-ID: <20171024092245.1386-3-jiri@resnulli.us>
References: <20171024092245.1386-1-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:57039 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751905AbdJXJWt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:49 -0400
Received: by mail-wm0-f66.google.com with SMTP id z3so7858151wme.5
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:49 -0700 (PDT)
In-Reply-To: <20171024092245.1386-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This is a preparation before introducing hot reload support. Currently
there is one global lock protecting all devlink access. This patch adds
per devlink instance lock which protects the internal members which are
the sb/dpipe/resources.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h |  1 +
 net/core/devlink.c    | 50 +++++++++++++++++++++++++++++++++++---------------
 2 files changed, 36 insertions(+), 15 deletions(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index fe57534..789e606 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -31,6 +31,7 @@ struct devlink {
 	const struct devlink_ops *ops;
 	struct device *dev;
 	possible_net_t _net;
+	struct mutex lock;
 	char priv[0] __aligned(NETDEV_ALIGN);
 };
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index a48dcd6..86dfec9 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -336,6 +336,8 @@ devlink_sb_tc_index_get_from_info(struct devlink_sb *devlink_sb,
 #define DEVLINK_NL_FLAG_NEED_PORT	BIT(1)
 #define DEVLINK_NL_FLAG_NEED_SB		BIT(2)
 #define DEVLINK_NL_FLAG_LOCK_PORTS	BIT(3)
+#define DEVLINK_NL_FLAG_NO_LOCK		BIT(4)
+
 	/* port is not needed but we need to ensure they don't
 	 * change in the middle of command
 	 */
@@ -380,15 +382,24 @@ static int devlink_nl_pre_doit(const struct genl_ops *ops,
 		}
 		info->user_ptr[1] = devlink_sb;
 	}
+	if (!(ops->internal_flags & DEVLINK_NL_FLAG_NO_LOCK))
+		mutex_lock(&devlink->lock);
+
 	return 0;
 }
 
 static void devlink_nl_post_doit(const struct genl_ops *ops,
 				 struct sk_buff *skb, struct genl_info *info)
 {
+	struct devlink *devlink;
+
+	devlink = devlink_get_from_info(info);
+
 	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_PORT ||
 	    ops->internal_flags & DEVLINK_NL_FLAG_LOCK_PORTS)
 		mutex_unlock(&devlink_port_mutex);
+	if (!(ops->internal_flags & DEVLINK_NL_FLAG_NO_LOCK))
+		mutex_unlock(&devlink->lock);
 	mutex_unlock(&devlink_mutex);
 }
 
@@ -801,6 +812,7 @@ static int devlink_nl_cmd_sb_get_dumpit(struct sk_buff *msg,
 	list_for_each_entry(devlink, &devlink_list, list) {
 		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)))
 			continue;
+		mutex_lock(&devlink->lock);
 		list_for_each_entry(devlink_sb, &devlink->sb_list, list) {
 			if (idx < start) {
 				idx++;
@@ -811,10 +823,13 @@ static int devlink_nl_cmd_sb_get_dumpit(struct sk_buff *msg,
 						 NETLINK_CB(cb->skb).portid,
 						 cb->nlh->nlmsg_seq,
 						 NLM_F_MULTI);
-			if (err)
+			if (err) {
+				mutex_unlock(&devlink->lock);
 				goto out;
+			}
 			idx++;
 		}
+		mutex_unlock(&devlink->lock);
 	}
 out:
 	mutex_unlock(&devlink_mutex);
@@ -935,14 +950,18 @@ static int devlink_nl_cmd_sb_pool_get_dumpit(struct sk_buff *msg,
 		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)) ||
 		    !devlink->ops || !devlink->ops->sb_pool_get)
 			continue;
+		mutex_lock(&devlink->lock);
 		list_for_each_entry(devlink_sb, &devlink->sb_list, list) {
 			err = __sb_pool_get_dumpit(msg, start, &idx, devlink,
 						   devlink_sb,
 						   NETLINK_CB(cb->skb).portid,
 						   cb->nlh->nlmsg_seq);
-			if (err && err != -EOPNOTSUPP)
+			if (err && err != -EOPNOTSUPP) {
+				mutex_unlock(&devlink->lock);
 				goto out;
+			}
 		}
+		mutex_unlock(&devlink->lock);
 	}
 out:
 	mutex_unlock(&devlink_mutex);
@@ -2695,6 +2714,7 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size)
 	INIT_LIST_HEAD(&devlink->sb_list);
 	INIT_LIST_HEAD_RCU(&devlink->dpipe_table_list);
 	INIT_LIST_HEAD(&devlink->resource_list);
+	mutex_init(&devlink->lock);
 	return devlink;
 }
 EXPORT_SYMBOL_GPL(devlink_alloc);
@@ -2858,7 +2878,7 @@ int devlink_sb_register(struct devlink *devlink, unsigned int sb_index,
 	struct devlink_sb *devlink_sb;
 	int err = 0;
 
-	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink->lock);
 	if (devlink_sb_index_exists(devlink, sb_index)) {
 		err = -EEXIST;
 		goto unlock;
@@ -2877,7 +2897,7 @@ int devlink_sb_register(struct devlink *devlink, unsigned int sb_index,
 	devlink_sb->egress_tc_count = egress_tc_count;
 	list_add_tail(&devlink_sb->list, &devlink->sb_list);
 unlock:
-	mutex_unlock(&devlink_mutex);
+	mutex_unlock(&devlink->lock);
 	return err;
 }
 EXPORT_SYMBOL_GPL(devlink_sb_register);
@@ -2886,11 +2906,11 @@ void devlink_sb_unregister(struct devlink *devlink, unsigned int sb_index)
 {
 	struct devlink_sb *devlink_sb;
 
-	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink->lock);
 	devlink_sb = devlink_sb_get_by_index(devlink, sb_index);
 	WARN_ON(!devlink_sb);
 	list_del(&devlink_sb->list);
-	mutex_unlock(&devlink_mutex);
+	mutex_unlock(&devlink->lock);
 	kfree(devlink_sb);
 }
 EXPORT_SYMBOL_GPL(devlink_sb_unregister);
@@ -2906,9 +2926,9 @@ EXPORT_SYMBOL_GPL(devlink_sb_unregister);
 int devlink_dpipe_headers_register(struct devlink *devlink,
 				   struct devlink_dpipe_headers *dpipe_headers)
 {
-	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink->lock);
 	devlink->dpipe_headers = dpipe_headers;
-	mutex_unlock(&devlink_mutex);
+	mutex_unlock(&devlink->lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(devlink_dpipe_headers_register);
@@ -2922,9 +2942,9 @@ EXPORT_SYMBOL_GPL(devlink_dpipe_headers_register);
  */
 void devlink_dpipe_headers_unregister(struct devlink *devlink)
 {
-	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink->lock);
 	devlink->dpipe_headers = NULL;
-	mutex_unlock(&devlink_mutex);
+	mutex_unlock(&devlink->lock);
 }
 EXPORT_SYMBOL_GPL(devlink_dpipe_headers_unregister);
 
@@ -2990,9 +3010,9 @@ int devlink_dpipe_table_register(struct devlink *devlink,
 	table->priv = priv;
 	table->counter_control_extern = counter_control_extern;
 
-	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink->lock);
 	list_add_tail_rcu(&table->list, &devlink->dpipe_table_list);
-	mutex_unlock(&devlink_mutex);
+	mutex_unlock(&devlink->lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(devlink_dpipe_table_register);
@@ -3008,17 +3028,17 @@ void devlink_dpipe_table_unregister(struct devlink *devlink,
 {
 	struct devlink_dpipe_table *table;
 
-	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink->lock);
 	table = devlink_dpipe_table_find(&devlink->dpipe_table_list,
 					 table_name);
 	if (!table)
 		goto unlock;
 	list_del_rcu(&table->list);
-	mutex_unlock(&devlink_mutex);
+	mutex_unlock(&devlink->lock);
 	kfree_rcu(table, rcu);
 	return;
 unlock:
-	mutex_unlock(&devlink_mutex);
+	mutex_unlock(&devlink->lock);
 }
 EXPORT_SYMBOL_GPL(devlink_dpipe_table_unregister);
 
-- 
2.9.5
