From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/12] devlink: Move dpipe entry clear function into devlink
Date: Thu, 24 Aug 2017 08:40:03 +0200
Message-ID: <20170824064010.1646-6-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35739 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbdHXGkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:22 -0400
Received: by mail-wr0-f195.google.com with SMTP id n53so962175wrb.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:22 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The entry clear routine can be shared between the drivers, thus it is
moved inside devlink.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 24 ++--------------------
 include/net/devlink.h                              |  6 ++++++
 net/core/devlink.c                                 | 22 ++++++++++++++++++++
 3 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 9eb265b..1305df9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -114,26 +114,6 @@ static int mlxsw_sp_dpipe_table_erif_matches_dump(void *priv,
 	return devlink_dpipe_match_put(skb, &match);
 }
 
-static void mlxsw_sp_erif_entry_clear(struct devlink_dpipe_entry *entry)
-{
-	unsigned int value_count, value_index;
-	struct devlink_dpipe_value *value;
-
-	value = entry->action_values;
-	value_count = entry->action_values_count;
-	for (value_index = 0; value_index < value_count; value_index++) {
-		kfree(value[value_index].value);
-		kfree(value[value_index].mask);
-	}
-
-	value = entry->match_values;
-	value_count = entry->match_values_count;
-	for (value_index = 0; value_index < value_count; value_index++) {
-		kfree(value[value_index].value);
-		kfree(value[value_index].mask);
-	}
-}
-
 static void
 mlxsw_sp_erif_match_action_prepare(struct devlink_dpipe_match *match,
 				   struct devlink_dpipe_action *action)
@@ -270,12 +250,12 @@ mlxsw_sp_dpipe_table_erif_entries_dump(void *priv, bool counters_enabled,
 		goto start_again;
 	rtnl_unlock();
 
-	mlxsw_sp_erif_entry_clear(&entry);
+	devlink_dpipe_entry_clear(&entry);
 	return 0;
 err_entry_append:
 err_entry_get:
 	rtnl_unlock();
-	mlxsw_sp_erif_entry_clear(&entry);
+	devlink_dpipe_entry_clear(&entry);
 	return err;
 }
 
diff --git a/include/net/devlink.h b/include/net/devlink.h
index e96272b..047a0c5 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -323,6 +323,7 @@ int devlink_dpipe_entry_ctx_prepare(struct devlink_dpipe_dump_ctx *dump_ctx);
 int devlink_dpipe_entry_ctx_append(struct devlink_dpipe_dump_ctx *dump_ctx,
 				   struct devlink_dpipe_entry *entry);
 int devlink_dpipe_entry_ctx_close(struct devlink_dpipe_dump_ctx *dump_ctx);
+void devlink_dpipe_entry_clear(struct devlink_dpipe_entry *entry);
 int devlink_dpipe_action_put(struct sk_buff *skb,
 			     struct devlink_dpipe_action *action);
 int devlink_dpipe_match_put(struct sk_buff *skb,
@@ -448,6 +449,11 @@ devlink_dpipe_entry_ctx_close(struct devlink_dpipe_dump_ctx *dump_ctx)
 	return 0;
 }
 
+static inline void
+devlink_dpipe_entry_clear(struct devlink_dpipe_entry *entry)
+{
+}
+
 static inline int
 devlink_dpipe_action_put(struct sk_buff *skb,
 			 struct devlink_dpipe_action *action)
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 87062ff..194708a 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1996,6 +1996,28 @@ int devlink_dpipe_entry_ctx_close(struct devlink_dpipe_dump_ctx *dump_ctx)
 }
 EXPORT_SYMBOL_GPL(devlink_dpipe_entry_ctx_close);
 
+void devlink_dpipe_entry_clear(struct devlink_dpipe_entry *entry)
+
+{
+	unsigned int value_count, value_index;
+	struct devlink_dpipe_value *value;
+
+	value = entry->action_values;
+	value_count = entry->action_values_count;
+	for (value_index = 0; value_index < value_count; value_index++) {
+		kfree(value[value_index].value);
+		kfree(value[value_index].mask);
+	}
+
+	value = entry->match_values;
+	value_count = entry->match_values_count;
+	for (value_index = 0; value_index < value_count; value_index++) {
+		kfree(value[value_index].value);
+		kfree(value[value_index].mask);
+	}
+}
+EXPORT_SYMBOL(devlink_dpipe_entry_clear);
+
 static int devlink_dpipe_entries_fill(struct genl_info *info,
 				      enum devlink_command cmd, int flags,
 				      struct devlink_dpipe_table *table)
-- 
2.9.3
