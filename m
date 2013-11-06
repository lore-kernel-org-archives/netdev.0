From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v3 1/3] tipc: don't reroute message fragments
Date: Wed, 6 Nov 2013 09:28:05 +0100
Message-ID: <1383726487-27929-2-git-send-email-erik.hugne@ericsson.com>
References: <1383726487-27929-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:49471 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241Ab3KFI3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 03:29:50 -0500
In-Reply-To: <1383726487-27929-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When a message fragment is received in a broadcast or unicast link,
the reception code will append the fragment payload to a big reassembly
buffer through a call to the function tipc_recv_fragm(). However, after
the return of that call, the logics goes on and passes the fragment
buffer to the function tipc_net_route_msg(), which will simply drop it.
This behavior is a remnant from the now obsolete multi-cluster
functionality, and has no relevance in the current code base.

Although currently harmless, this unnecessary call would be fatal
after applying the next patch in this series, which introduces
a completely new reassembly algorithm. So we change the code to
eliminate the redundant call.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |    6 ++++--
 net/tipc/link.c  |    3 ++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 716de1a..766a6eb 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -487,11 +487,13 @@ receive:
 			spin_lock_bh(&bc_lock);
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_fragments++;
-			if (ret > 0)
+			if (ret > 0) {
 				bcl->stats.recv_fragmented++;
+				spin_unlock_bh(&bc_lock);
+				goto receive;
+			}
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
-			tipc_net_route_msg(buf);
 		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
 			spin_lock_bh(&bc_lock);
 			bclink_accept_pkt(node, seqno);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 54163f9..ada8cad 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1657,7 +1657,8 @@ deliver:
 			}
 			if (ret == -1)
 				l_ptr->next_in_no--;
-			break;
+			tipc_node_unlock(n_ptr);
+			continue;
 		case CHANGEOVER_PROTOCOL:
 			type = msg_type(msg);
 			if (link_recv_changeover_msg(&l_ptr, &buf)) {
-- 
1.7.9.5
