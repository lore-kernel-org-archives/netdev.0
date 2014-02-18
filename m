From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: failed transmissions should return error
Date: Tue, 18 Feb 2014 14:29:50 +0100
Message-ID: <1392730190-20050-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <ying.xue@windriver.com>,
	<paul.gortmaker@windriver.com>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:57480 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbaBRNaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:30:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When a message could not be sent out because the destination
node or link could not be found, the full message size is
returned from sendmsg() as if it had been sent successfully.
An application will then get a false indication that it's
making forward progress. This problem has existed since the
initial commit in 2.6.16.

We change this to return -ENETUNREACH if the message cannot be
delivered due to the destination node/link being unavailable.
We also get rid of the redundant tipc_reject_msg call since
freeing the buffer and doing a tipc_port_reject_sections
accomplishes exactly the same thing.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 5422e96..e79f0f4 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1016,12 +1016,9 @@ exit:
 	read_unlock_bh(&tipc_net_lock);
 
 	/* Couldn't find a link to the destination node */
-	if (buf)
-		return tipc_reject_msg(buf, TIPC_ERR_NO_NODE);
-	if (res >= 0)
-		return tipc_port_reject_sections(sender, hdr, msg_sect,
-						 len, TIPC_ERR_NO_NODE);
-	return res;
+	kfree_skb(buf);
+	tipc_port_reject_sections(sender, hdr, msg_sect, len, TIPC_ERR_NO_NODE);
+	return -ENETUNREACH;
 }
 
 /*
@@ -1159,8 +1156,9 @@ error:
 	} else {
 reject:
 		kfree_skb_list(buf_chain);
-		return tipc_port_reject_sections(sender, hdr, msg_sect,
-						 len, TIPC_ERR_NO_NODE);
+		tipc_port_reject_sections(sender, hdr, msg_sect,
+					  len, TIPC_ERR_NO_NODE);
+		return -ENETUNREACH;
 	}
 
 	/* Append chain of fragments to send queue & send them */
-- 
1.7.9.5
