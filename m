From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/20] tipc: Optimize routing of returned payload messages
Date: Fri, 24 Jun 2011 18:07:12 -0400
Message-ID: <1308953247-25266-6-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34359 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052Ab1FXWHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:43 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Reduces the work involved in transmitting a returned payload message
by doing only the work necessary to route such a message directly to
the specified destination port, rather than invoking the code used
to route an arbitrary message to an arbitrary destination.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 756e64c..70ecdfd 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -360,6 +360,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	int hdr_sz;
 	u32 imp = msg_importance(msg);
 	u32 data_sz = msg_data_sz(msg);
+	u32 src_node;
 
 	if (data_sz > MAX_REJECT_SIZE)
 		data_sz = MAX_REJECT_SIZE;
@@ -416,7 +417,11 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 
 	/* send returned message & dispose of rejected message */
 
-	tipc_net_route_msg(rbuf);
+	src_node = msg_prevnode(msg);
+	if (src_node == tipc_own_addr)
+		tipc_port_recv_msg(rbuf);
+	else
+		tipc_link_send(rbuf, src_node, msg_link_selector(rmsg));
 exit:
 	buf_discard(buf);
 	return data_sz;
-- 
1.7.4.4

