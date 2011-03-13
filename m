From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/26] tipc: Give Tx of discovery responses priority over link messages
Date: Sun, 13 Mar 2011 17:34:05 -0400
Message-ID: <1300052054-7531-18-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49917 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab1CMVew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:52 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Delay releasing the node lock when processing a neighbor discovery
message until after the optional discovery response message has been
sent. This helps ensure that any link protocol messages sent by a
link endpoint created as a result of a neighbor discovery request
are received after the discovery response is received, thereby
giving the receiving node a chance to create a peer link endpoint to
consume those link protocol messages, if one does not already exist.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 2345268..580b50a 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -201,14 +201,16 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 
 	/* Accept discovery message & send response, if necessary */
 	link_fully_up = link_working_working(link);
-	tipc_node_unlock(n_ptr);
-	if ((type == DSC_RESP_MSG) || link_fully_up)
-		return;
-	rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
-	if (rbuf != NULL) {
-		b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
-		buf_discard(rbuf);
+
+	if ((type == DSC_REQ_MSG) && !link_fully_up) {
+		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
+		if (rbuf) {
+			b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
+			buf_discard(rbuf);
+		}
 	}
+
+	tipc_node_unlock(n_ptr);
 }
 
 /**
-- 
1.7.3.3

