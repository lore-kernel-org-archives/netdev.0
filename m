From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 07/13] tipc: introduce message evaluation function
Date: Wed, 25 Jun 2014 20:41:36 -0500
Message-ID: <1403746902-20408-8-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24158 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757329AbaFZBs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:59 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a message arrives in a node and finds no destination
socket, we may need to drop it, reject it, or forward it after
a secondary destination lookup. The latter two cases currently
results in a code path that is perceived as complex, because it
follows a deep call chain via obscure functions such as
net_route_named_msg() and net_route_msg().

We now introduce a function, tipc_msg_eval(), that takes the
decision about whether such a message should be rejected or
forwarded, but leaves it to the caller to actually perform
the indicated action.

If the decision is 'reject', it is still the task of the recently
introduced function tipc_msg_reverse() to take the final decision
about whether the message is rejectable or not. In the latter case
it drops the message.

As a result of this change, we can finally eliminate the function
net_route_named_msg(), and hence become independent of net_route_msg().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/msg.c    |   38 ++++++++++++++++++++++++++++++++++++++
 net/tipc/msg.h    |    2 ++
 net/tipc/net.c    |   33 ++++++---------------------------
 net/tipc/socket.c |   16 +++++-----------
 4 files changed, 51 insertions(+), 38 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 6070dd0..7bfc442 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -36,6 +36,8 @@
 
 #include "core.h"
 #include "msg.h"
+#include "addr.h"
+#include "name_table.h"
 
 #define MAX_FORWARD_SIZE 1024
 
@@ -370,3 +372,39 @@ exit:
 	kfree_skb(buf);
 	return false;
 }
+
+/**
+ * tipc_msg_eval: determine fate of message that found no destination
+ * @buf: the buffer containing the message.
+ * @dnode: return value: next-hop node, if message to be forwarded
+ * @err: error code to use, if message to be rejected
+ *
+ * Does not consume buffer
+ * Returns 0 (TIPC_OK) if message ok and we can try again, -TIPC error
+ * code if message to be rejected
+ */
+int tipc_msg_eval(struct sk_buff *buf, u32 *dnode)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+	u32 dport;
+
+	if (msg_type(msg) != TIPC_NAMED_MSG)
+		return -TIPC_ERR_NO_PORT;
+	if (skb_linearize(buf))
+		return -TIPC_ERR_NO_NAME;
+	if (msg_data_sz(msg) > MAX_FORWARD_SIZE)
+		return -TIPC_ERR_NO_NAME;
+	if (msg_reroute_cnt(msg) > 0)
+		return -TIPC_ERR_NO_NAME;
+
+	*dnode = addr_domain(msg_lookup_scope(msg));
+	dport = tipc_nametbl_translate(msg_nametype(msg),
+				       msg_nameinst(msg),
+				       dnode);
+	if (!dport)
+		return -TIPC_ERR_NO_NAME;
+	msg_incr_reroute_cnt(msg);
+	msg_set_destnode(msg, *dnode);
+	msg_set_destport(msg, dport);
+	return TIPC_OK;
+}
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 3805094..7d57434 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -727,6 +727,8 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 
 bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err);
 
+int tipc_msg_eval(struct sk_buff *buf, u32 *dnode);
+
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index f64375e..5f7d6ff 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/net.c: TIPC network routing code
  *
- * Copyright (c) 1995-2006, Ericsson AB
+ * Copyright (c) 1995-2006, 2014, Ericsson AB
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -103,29 +103,6 @@
  *       This is always used within the scope of a tipc_nametbl_lock(read).
  *     - A local spin_lock protecting the queue of subscriber events.
 */
-
-static void net_route_named_msg(struct sk_buff *buf)
-{
-	struct tipc_msg *msg = buf_msg(buf);
-	u32 dnode;
-	u32 dport;
-
-	if (!msg_named(msg)) {
-		kfree_skb(buf);
-		return;
-	}
-
-	dnode = addr_domain(msg_lookup_scope(msg));
-	dport = tipc_nametbl_translate(msg_nametype(msg), msg_nameinst(msg), &dnode);
-	if (dport) {
-		msg_set_destnode(msg, dnode);
-		msg_set_destport(msg, dport);
-		tipc_net_route_msg(buf);
-		return;
-	}
-	tipc_reject_msg(buf, TIPC_ERR_NO_NAME);
-}
-
 void tipc_net_route_msg(struct sk_buff *buf)
 {
 	struct tipc_msg *msg;
@@ -141,10 +118,12 @@ void tipc_net_route_msg(struct sk_buff *buf)
 		if (msg_isdata(msg)) {
 			if (msg_mcast(msg))
 				tipc_port_mcast_rcv(buf, NULL);
-			else if (msg_destport(msg))
+			else if (msg_destport(msg)) {
 				tipc_sk_rcv(buf);
-			else
-				net_route_named_msg(buf);
+			} else {
+				pr_warn("Cannot route msg; no destination\n");
+				kfree_skb(buf);
+			}
 			return;
 		}
 		switch (msg_user(msg)) {
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 5961a63..e642ed5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1466,16 +1466,10 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	uint limit;
 	u32 dnode;
 
-	/* Forward unresolved named message */
-	if (unlikely(!dport)) {
-		tipc_net_route_msg(buf);
-		return 0;
-	}
-
-	/* Validate destination */
+	/* Validate destination and message */
 	port = tipc_port_lock(dport);
 	if (unlikely(!port)) {
-		rc = -TIPC_ERR_NO_PORT;
+		rc = tipc_msg_eval(buf, &dnode);
 		goto exit;
 	}
 
@@ -1494,17 +1488,17 @@ int tipc_sk_rcv(struct sk_buff *buf)
 		if (sk_add_backlog(sk, buf, limit))
 			rc = -TIPC_ERR_OVERLOAD;
 	}
-
 	bh_unlock_sock(sk);
 	tipc_port_unlock(port);
 
 	if (likely(!rc))
 		return 0;
 exit:
-	if (!tipc_msg_reverse(buf, &dnode, -rc))
+	if ((rc < 0) && !tipc_msg_reverse(buf, &dnode, -rc))
 		return -EHOSTUNREACH;
+
 	tipc_link_xmit2(buf, dnode, 0);
-	return -EHOSTUNREACH;
+	return (rc < 0) ? -EHOSTUNREACH : 0;
 }
 
 static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
-- 
1.7.9.5
