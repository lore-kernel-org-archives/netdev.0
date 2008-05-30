From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 04/13 net-next-2.6] [TIPC]: Fix minor bugs in link session number handling
Date: Fri, 30 May 2008 14:20:39 -0400
Message-ID: <1212171648-27122-5-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50507 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753035AbYE3SXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:07 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a new, out-of-range value to indicate that
a link endpoint does not have an existing session established
with its peer, eliminating the risk that the previously used
"invalid session number" value (i.e. zero) might eventually be
assigned as a valid session number and cause incorrect link
behavior.

The patch also introduces explicit bit masking when assigning a
new link session number to ensure it does not exceed 16 bits.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/link.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index bd206eb..b8c1231 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -51,6 +51,12 @@
 
 
 /*
+ * Out-of-range value for link session numbers
+ */
+
+#define INVALID_SESSION 0x10000
+
+/*
  * Limit for deferred reception queue:
  */
 
@@ -464,7 +470,7 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 	msg = l_ptr->pmsg;
 	msg_init(msg, LINK_PROTOCOL, RESET_MSG, TIPC_OK, INT_H_SIZE, l_ptr->addr);
 	msg_set_size(msg, sizeof(l_ptr->proto_msg));
-	msg_set_session(msg, tipc_random);
+	msg_set_session(msg, (tipc_random & 0xffff));
 	msg_set_bearer_id(msg, b_ptr->identity);
 	strcpy((char *)msg_data(msg), if_name);
 
@@ -705,10 +711,10 @@ void tipc_link_reset(struct link *l_ptr)
 	u32 checkpoint = l_ptr->next_in_no;
 	int was_active_link = tipc_link_is_active(l_ptr);
 
-	msg_set_session(l_ptr->pmsg, msg_session(l_ptr->pmsg) + 1);
+	msg_set_session(l_ptr->pmsg, ((msg_session(l_ptr->pmsg) + 1) & 0xffff));
 
-	/* Link is down, accept any session: */
-	l_ptr->peer_session = 0;
+	/* Link is down, accept any session */
+	l_ptr->peer_session = INVALID_SESSION;
 
 	/* Prepare for max packet size negotiation */
 	link_init_max_pkt(l_ptr);
@@ -2275,7 +2281,8 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 	switch (msg_type(msg)) {
 
 	case RESET_MSG:
-		if (!link_working_unknown(l_ptr) && l_ptr->peer_session) {
+		if (!link_working_unknown(l_ptr) &&
+		    (l_ptr->peer_session != INVALID_SESSION)) {
 			if (msg_session(msg) == l_ptr->peer_session) {
 				dbg("Duplicate RESET: %u<->%u\n",
 				    msg_session(msg), l_ptr->peer_session);
-- 
1.5.3.2

