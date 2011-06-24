From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 19/20] tipc: Don't create payload message using connection protocol routine
Date: Fri, 24 Jun 2011 18:07:26 -0400
Message-ID: <1308953247-25266-20-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34427 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757689Ab1FXWHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:55 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies the logic that creates a connection termination payload
message so that it no longer (mis)uses a routine that creates a
connection protocol message. The revised code is now more easily
understood, and avoids setting several fields that are either not
present in payload messages or were being set more than once.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 1b20b96..ab0a8e9 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -539,14 +539,15 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 	if (!p_ptr || !p_ptr->connected ||
 	    (port_peernode(p_ptr) != orignode) ||
 	    (port_peerport(p_ptr) != origport)) {
-		r_buf = port_build_proto_msg(origport,
-					     orignode,
-					     destport,
-					     tipc_own_addr,
-					     TIPC_HIGH_IMPORTANCE,
-					     TIPC_CONN_MSG,
-					     TIPC_ERR_NO_PORT,
-					     0);
+		r_buf = tipc_buf_acquire(BASIC_H_SIZE);
+		if (r_buf) {
+			msg = buf_msg(r_buf);
+			tipc_msg_init(msg, TIPC_HIGH_IMPORTANCE, TIPC_CONN_MSG,
+				      BASIC_H_SIZE, orignode);
+			msg_set_errcode(msg, TIPC_ERR_NO_PORT);
+			msg_set_origport(msg, destport);
+			msg_set_destport(msg, origport);
+		}
 		if (p_ptr)
 			tipc_port_unlock(p_ptr);
 		goto exit;
-- 
1.7.4.4

