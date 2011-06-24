From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/20] tipc: Standardize exit logic for message rejection handling
Date: Fri, 24 Jun 2011 18:07:10 -0400
Message-ID: <1308953247-25266-4-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34349 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756947Ab1FXWHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:41 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies the routine that handles the rejection of payload messages
so that it has a single exit point that frees up the rejected message,
thereby eliminating some duplicated code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index c68dc95..3946b5b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -367,10 +367,8 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 		imp++;
 
 	/* discard rejected message if it shouldn't be returned to sender */
-	if (msg_errcode(msg) || msg_dest_droppable(msg)) {
-		buf_discard(buf);
-		return data_sz;
-	}
+	if (msg_errcode(msg) || msg_dest_droppable(msg))
+		goto exit;
 
 	/* construct rejected message */
 	if (msg_mcast(msg))
@@ -378,10 +376,9 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	else
 		hdr_sz = LONG_H_SIZE;
 	rbuf = tipc_buf_acquire(data_sz + hdr_sz);
-	if (rbuf == NULL) {
-		buf_discard(buf);
-		return data_sz;
-	}
+	if (rbuf == NULL)
+		goto exit;
+
 	rmsg = buf_msg(rbuf);
 	tipc_msg_init(rmsg, imp, msg_type(msg), hdr_sz, msg_orignode(msg));
 	msg_set_errcode(rmsg, err);
@@ -411,9 +408,11 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 		tipc_net_route_msg(abuf);
 	}
 
-	/* send rejected message */
-	buf_discard(buf);
+	/* send returned message & dispose of rejected message */
+
 	tipc_net_route_msg(rbuf);
+exit:
+	buf_discard(buf);
 	return data_sz;
 }
 
-- 
1.7.4.4

