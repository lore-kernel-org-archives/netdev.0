From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: add tracepoint in br_fdb_update
Date: Wed, 30 Aug 2017 22:18:13 -0700
Message-ID: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        bridge@lists.linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36215 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdHaFSb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 01:18:31 -0400
Received: by mail-pf0-f182.google.com with SMTP id r187so4683776pfr.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 22:18:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This extends bridge fdb table tracepoints to also cover
learned fdb entries in the br_fdb_update path. Note that
unlike other tracepoints I have moved this to when the fdb
is modified because this is in the datapath and can generate
a lot of noise in the trace output. br_fdb_update is also called
from added_by_user context in the NTF_USE case which is already
traced ..hence the !added_by_user check.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/trace/events/bridge.h | 31 +++++++++++++++++++++++++++++++
 net/bridge/br_fdb.c           |  5 ++++-
 net/core/net-traces.c         |  1 +
 3 files changed, 36 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/bridge.h b/include/trace/events/bridge.h
index 0f1cde0..1bee3e7 100644
--- a/include/trace/events/bridge.h
+++ b/include/trace/events/bridge.h
@@ -92,6 +92,37 @@ TRACE_EVENT(fdb_delete,
 		  __entry->addr[4], __entry->addr[5], __entry->vid)
 );
 
+TRACE_EVENT(br_fdb_update,
+
+	TP_PROTO(struct net_bridge *br, struct net_bridge_port *source,
+		 const unsigned char *addr, u16 vid, bool added_by_user),
+
+	TP_ARGS(br, source, addr, vid, added_by_user),
+
+	TP_STRUCT__entry(
+		__string(br_dev, br->dev->name)
+		__string(dev, source->dev->name)
+		__array(unsigned char, addr, ETH_ALEN)
+		__field(u16, vid)
+		__field(bool, added_by_user)
+	),
+
+	TP_fast_assign(
+		__assign_str(br_dev, br->dev->name);
+		__assign_str(dev, source->dev->name);
+		memcpy(__entry->addr, addr, ETH_ALEN);
+		__entry->vid = vid;
+		__entry->added_by_user = added_by_user;
+	),
+
+	TP_printk("br_dev %s source %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u added_by_user %d",
+		  __get_str(br_dev), __get_str(dev), __entry->addr[0],
+		  __entry->addr[1], __entry->addr[2], __entry->addr[3],
+		  __entry->addr[4], __entry->addr[5], __entry->vid,
+		  __entry->added_by_user)
+);
+
+
 #endif /* _TRACE_BRIDGE_H */
 
 /* This part must be outside protection */
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index be5e1da..4ea5c8b 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -583,8 +583,10 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 				fdb->updated = now;
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
-			if (unlikely(fdb_modified))
+			if (unlikely(fdb_modified)) {
+				trace_br_fdb_update(br, source, addr, vid, added_by_user);
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
+			}
 		}
 	} else {
 		spin_lock(&br->hash_lock);
@@ -593,6 +595,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 			if (fdb) {
 				if (unlikely(added_by_user))
 					fdb->added_by_user = 1;
+				trace_br_fdb_update(br, source, addr, vid, added_by_user);
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 			}
 		}
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index 4a0292c..1132820 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -42,6 +42,7 @@ EXPORT_TRACEPOINT_SYMBOL_GPL(fib6_table_lookup);
 EXPORT_TRACEPOINT_SYMBOL_GPL(br_fdb_add);
 EXPORT_TRACEPOINT_SYMBOL_GPL(br_fdb_external_learn_add);
 EXPORT_TRACEPOINT_SYMBOL_GPL(fdb_delete);
+EXPORT_TRACEPOINT_SYMBOL_GPL(br_fdb_update);
 #endif
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
-- 
2.1.4
