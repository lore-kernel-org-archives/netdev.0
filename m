From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/28] tipc: Discard incoming broadcast messages that are unexpected
Date: Sat, 17 Sep 2011 23:32:09 -0400
Message-ID: <1316316744-29514-14-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49981 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756281Ab1IRDcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:51 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies TIPC's incoming broadcast packet handler to discard messages
that cannot legally be sent over the broadcast link, including:

- broadcast protocol messages that do no contain state information
- payload messages that are not named multicast messages
- any other form of message except for bundled messages, fragmented
  messages, and name distribution messages.

These checks are needed to prevent TIPC from handing an unexpected
message to a routine that isn't prepared to handle it, which could
lead to incorrect processing (up to and including invalid memory
references caused by attempts to access message fields that aren't
present in the message).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 8d29852..bead28b 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -39,6 +39,7 @@
 #include "link.h"
 #include "port.h"
 #include "bcast.h"
+#include "name_distr.h"
 
 #define MAX_PKT_DEFAULT_MCAST 1500	/* bcast link max packet size (fixed) */
 
@@ -445,6 +446,8 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 		goto unlock;
 
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL)) {
+		if (msg_type(msg) != STATE_MSG)
+			goto unlock;
 		if (msg_destnode(msg) == tipc_own_addr) {
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
 			tipc_node_unlock(node);
@@ -480,7 +483,10 @@ receive:
 		}
 		if (likely(msg_isdata(msg))) {
 			tipc_node_unlock(node);
-			tipc_port_recv_mcast(buf, NULL);
+			if (likely(msg_mcast(msg)))
+				tipc_port_recv_mcast(buf, NULL);
+			else
+				buf_discard(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
 			bcl->stats.recv_bundles++;
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
@@ -493,9 +499,12 @@ receive:
 				bcl->stats.recv_fragmented++;
 			tipc_node_unlock(node);
 			tipc_net_route_msg(buf);
+		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
+			tipc_node_unlock(node);
+			tipc_named_recv(buf);
 		} else {
 			tipc_node_unlock(node);
-			tipc_net_route_msg(buf);
+			buf_discard(buf);
 		}
 		buf = NULL;
 		tipc_node_lock(node);
-- 
1.7.4.4
