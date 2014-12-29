From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 09/10] net: flow: Add eviction flags to table configuration
Date: Mon, 29 Dec 2014 11:15:39 +0900
Message-ID: <1419819340-19000-10-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:46379 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbaL2CQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:19 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so16186418pde.15
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:19 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intention is to allow run-time configuration of if and how
a switch or switch-like device may evict flows from tables in
the case of resource contention.

Inspired by a feature of the same name in in OpenFlow.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/uapi/linux/if_flow.h | 16 ++++++++++++++++
 net/core/flow_table.c        | 11 ++++++++---
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index bd29145..7264629 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -186,6 +186,7 @@
  * [NET_FLOW_TABLE_CONFIGS]
  *   [NET_FLOW_TABLE_CONFIG_TABLE]
  *     [NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID]
+ *     [NET_FLOW_TABLE_CONFIG_TABLE_ATTR_EVICTION]
  *   ...
  *
  * Set Flow Notification <Request>,
@@ -742,9 +743,11 @@ enum {
  * @brief flow table configuration
  *
  * @table unique identifier of table
+ * @eviction flags to control eviction. Bitmask of NET_FLOW_EVICTION_F_*
  */
 struct net_flow_table_config {
 	int table;
+	__u32 eviction;
 };
 
 enum {
@@ -757,10 +760,23 @@ enum {
 enum {
 	NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UNSPEC,
 	NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID,
+	NET_FLOW_TABLE_CONFIG_TABLE_ATTR_EVICTION,
 	__NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX,
 };
 #define NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX (__NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX - 1)
 
+
+enum {
+	/* Eviction enabled.
+	 * Must be set for any eviction to occur */
+	NET_FLOW_EVICTION_F_ENABLE	= (0 << 1),
+
+	/* Evict entries based on their importance */
+	NET_FLOW_EVICTION_F_IMPORTANCE	= (1 << 1),
+	/* Evict entries based on how close they are to timing out */
+	NET_FLOW_EVICTION_F_TIMEOUT	= (2 << 1),
+};
+
 enum {
 	NET_FLOW_REM_FLOW_UNSPEC,
 	NET_FLOW_REM_FLOW_TABLE,
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 6c44311..3030246 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1595,13 +1595,14 @@ static int net_flow_table_cmd_get_table_config(struct sk_buff *skb,
 		}
 
 		if (nla_put_u32(msg, NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID,
-				table)) {
+				table) ||
+			nla_put_u32(msg,
+				    NET_FLOW_TABLE_CONFIG_TABLE_ATTR_EVICTION,
+				    tc->eviction)) {
 			err = -ENOBUFS;
 			goto err;
 		}
 
-		/* Write other attributes of tc: Currently none are defined. */
-
 		nla_nest_end(msg, config);
 	}
 
@@ -1669,6 +1670,10 @@ static int net_flow_table_cmd_set_table_config(struct sk_buff *skb,
 
 		new_tc = *tc;
 
+		if (!tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_EVICTION]) {
+			new_tc.eviction = nla_get_u32(tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_EVICTION]);
+		}
+
 		err = dev->netdev_ops->ndo_flow_table_set_table_config(dev, &new_tc);
 		if (err)
 			goto out;
-- 
2.1.3
