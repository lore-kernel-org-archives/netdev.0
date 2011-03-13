From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/26] tipc: Fix redundant link field handling in link protocol message
Date: Sun, 13 Mar 2011 17:34:03 -0400
Message-ID: <1300052054-7531-16-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49909 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232Ab1CMVeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:50 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Ensures that the "redundant link exists" field of the LINK_PROTOCOL
messages sent by a link endpoint is set if and only if the sending
node has at least one other working link to the peer node. Previously,
the bit was set only if there were at least 2 working links to the peer
node, meaning the bit was incorrectly left unset in messages sent by a
non-working link endpoint when exactly one alternate working link was
available. The revised code now takes the state of the link sending
the message into account when deciding if an alternate link exists.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6ffae0e..e5f96d5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1898,6 +1898,7 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg = l_ptr->pmsg;
 	u32 msg_size = sizeof(l_ptr->proto_msg);
+	int r_flag;
 
 	if (link_blocked(l_ptr))
 		return;
@@ -1954,7 +1955,8 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 		msg_set_max_pkt(msg, l_ptr->max_pkt_target);
 	}
 
-	msg_set_redundant_link(msg, tipc_node_redundant_links(l_ptr->owner));
+	r_flag = (l_ptr->owner->working_links > tipc_link_is_up(l_ptr));
+	msg_set_redundant_link(msg, r_flag);
 	msg_set_linkprio(msg, l_ptr->priority);
 
 	/* Ensure sequence number will not fit : */
-- 
1.7.3.3

