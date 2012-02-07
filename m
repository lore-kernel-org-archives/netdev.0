From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/15] tipc: Minor optimization to rejection of connection-based messages
Date: Mon,  6 Feb 2012 19:52:48 -0500
Message-ID: <1328575968-20643-16-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50223 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535Ab2BGAxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:19 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies message rejection logic so that TIPC doesn't attempt to
send a FIN message to the rejecting port if it is known in advance
that there is no such message because the rejecting port doesn't exist.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index d91efc6..ba3268b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -400,15 +400,16 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 
 	/* send self-abort message when rejecting on a connected port */
 	if (msg_connected(msg)) {
-		struct sk_buff *abuf = NULL;
 		struct tipc_port *p_ptr = tipc_port_lock(msg_destport(msg));
 
 		if (p_ptr) {
+			struct sk_buff *abuf = NULL;
+
 			if (p_ptr->connected)
 				abuf = port_build_self_abort_msg(p_ptr, err);
 			tipc_port_unlock(p_ptr);
+			tipc_net_route_msg(abuf);
 		}
-		tipc_net_route_msg(abuf);
 	}
 
 	/* send returned message & dispose of rejected message */
-- 
1.7.9
