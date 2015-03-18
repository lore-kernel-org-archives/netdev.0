From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 2/3] tipc: do not report -EHOSTUNREACH for failed local delivery
Date: Wed, 18 Mar 2015 10:17:42 +0100
Message-ID: <1426670263-30358-3-git-send-email-erik.hugne@ericsson.com>
References: <1426670263-30358-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <richard.alpe@ericsson.com>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:63183 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbbCRJV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:21:57 -0400
In-Reply-To: <1426670263-30358-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Since commit 1186adf7df04 ("tipc: simplify message forwarding and
rejection in socket layer") -EHOSTUNREACH is propagated back to
the sending process if we fail to deliver the message to another
socket local to the node.
This is wrong, host unreachable should only be reported when the
destination port/name does not exist in the cluster, and that
check is always done before sending the message. Also, this
introduces inconsistent sendmsg() behavior for local/remote
destinations. Errors occurring on the receiving side should not
trickle up to the sender. If message delivery fails TIPC should
either discard the packet or reject it back to the sender based
on the destination droppable option.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/link.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index bc49120..8c98c4d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -845,8 +845,10 @@ int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dnode,
 	if (link)
 		return rc;
 
-	if (likely(in_own_node(net, dnode)))
-		return tipc_sk_rcv(net, list);
+	if (likely(in_own_node(net, dnode))) {
+		tipc_sk_rcv(net, list);
+		return 0;
+	}
 
 	__skb_queue_purge(list);
 	return rc;
-- 
2.1.4
