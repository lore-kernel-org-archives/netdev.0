From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 09/14] tipc: more cleanup of tunnelling reception function
Date: Thu, 13 Feb 2014 17:29:13 -0500
Message-ID: <1392330558-19048-10-git-send-email-jon.maloy@ericsson.com>
References: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.ne1.yahoo.com ([98.138.207.10]:21063 "HELO
	smtp103.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752511AbaBMW3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:29:43 -0500
In-Reply-To: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We simplify and slim down the code in function tipc_tunnel_rcv()
No impact on the users of this function.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index f9f9068..3136788 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2180,9 +2180,10 @@ static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 	struct sk_buff *tunnel_buf = *buf;
 	struct tipc_link *dest_link;
 	struct tipc_msg *tunnel_msg = buf_msg(tunnel_buf);
-	u32 msg_typ = msg_type(tunnel_msg);
 	u32 bearer_id = msg_bearer_id(tunnel_msg);
 
+	*buf = NULL;
+
 	if (bearer_id >= MAX_BEARERS)
 		goto exit;
 
@@ -2190,24 +2191,16 @@ static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 	if (!dest_link)
 		goto exit;
 
-	if (msg_typ == DUPLICATE_MSG) {
+	if (msg_type(tunnel_msg) == DUPLICATE_MSG)
 		tipc_link_dup_rcv(dest_link, tunnel_buf);
-		goto exit;
-	}
-
-	if (msg_type(tunnel_msg) == ORIGINAL_MSG) {
+	else if (msg_type(tunnel_msg) == ORIGINAL_MSG)
 		*buf = tipc_link_failover_rcv(dest_link, tunnel_buf);
+	else
+		pr_warn("%sunknown tunnel pkt received\n", link_co_err);
 
-		/* Do we have a buffer/buffer chain to return? */
-		if (*buf != NULL) {
-			kfree_skb(tunnel_buf);
-			return 1;
-		}
-	}
 exit:
-	*buf = NULL;
 	kfree_skb(tunnel_buf);
-	return 0;
+	return *buf != NULL;
 }
 
 /*
-- 
1.7.9.5
