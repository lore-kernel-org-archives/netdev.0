From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix two bugs in secondary destination lookup
Date: Fri, 27 Mar 2015 10:19:19 -0400
Message-ID: <1427465959-19598-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.bf1.yahoo.com ([98.139.221.61]:35594 "EHLO
	smtp102.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbbC0OUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 10:20:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A message sent to a node after a successful name table lookup may still
find that the destination socket has disappeared, because distribution
of name table updates is non-atomic. If so, the message will be rejected
back to the sender with error code TIPC_ERR_NO_PORT. If the source
socket of the message has disappeared in the meantime, the message
should be dropped.

However, in the currrent code, the message will instead be subject to an
unwanted tertiary lookup, because the function tipc_msg_lookup_dest()
doesn't check if there is an error code present in the message before
performing the lookup. In the worst case, the message may now find the
old destination again, and be redirected once more, instead of being
dropped directly as it should be.

A second bug in this function is that the "prev_node" field in the message
is not updated after successful lookup, something that may have
unpredictable consequences.

The problems arising from those bugs occur very infrequently.

The third change in this function; the test on msg_reroute_msg_cnt() is
purely cosmetic, reflecting that the returned value never can be negative.

This commit corrects the two bugs described above.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/addr.c | 7 +++++++
 net/tipc/addr.h | 1 +
 net/tipc/msg.c  | 7 ++++++-
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 48fd3b5..ba7daa8 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -38,6 +38,13 @@
 #include "addr.h"
 #include "core.h"
 
+u32 tipc_own_addr(struct net *net)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	return tn->own_addr;
+}
+
 /**
  * in_own_cluster - test for cluster inclusion; <0.0.0> always matches
  */
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index c700c2d..7ba6d5c 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -55,6 +55,7 @@ static inline u32 tipc_cluster_mask(u32 addr)
 	return addr & TIPC_CLUSTER_MASK;
 }
 
+u32 tipc_own_addr(struct net *net);
 int in_own_cluster(struct net *net, u32 addr);
 int in_own_cluster_exact(struct net *net, u32 addr);
 int in_own_node(struct net *net, u32 addr);
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 0c6dad8..3bb499c 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -511,15 +511,18 @@ bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb,
 {
 	struct tipc_msg *msg = buf_msg(skb);
 	u32 dport;
+	u32 own_addr = tipc_own_addr(net);
 
 	if (!msg_isdata(msg))
 		return false;
 	if (!msg_named(msg))
 		return false;
+	if (msg_errcode(msg))
+		return false;
 	*err = -TIPC_ERR_NO_NAME;
 	if (skb_linearize(skb))
 		return false;
-	if (msg_reroute_cnt(msg) > 0)
+	if (msg_reroute_cnt(msg))
 		return false;
 	*dnode = addr_domain(net, msg_lookup_scope(msg));
 	dport = tipc_nametbl_translate(net, msg_nametype(msg),
@@ -527,6 +530,8 @@ bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb,
 	if (!dport)
 		return false;
 	msg_incr_reroute_cnt(msg);
+	if (*dnode != own_addr)
+		msg_set_prevnode(msg, own_addr);
 	msg_set_destnode(msg, *dnode);
 	msg_set_destport(msg, dport);
 	*err = TIPC_OK;
-- 
1.9.1
