From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 5/32] [TIPC] Allow ports to receive multicast messages through native API.
Date: Thu, 22 Jun 2006 15:59:18 +0200
Message-ID: <1150984785421-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:40634 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030635AbWFVN7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This fix prevents a kernel panic if an application mistakenly sends a
multicast message to  TIPC's topology service or configuration service.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/port.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 67e96cb..360920b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -810,18 +810,20 @@ static void port_dispatcher_sigh(void *d
 		void *usr_handle;
 		int connected;
 		int published;
+		u32 message_type;
 
 		struct sk_buff *next = buf->next;
 		struct tipc_msg *msg = buf_msg(buf);
 		u32 dref = msg_destport(msg);
 		
+		message_type = msg_type(msg);
+		if (message_type > TIPC_DIRECT_MSG)
+			goto reject;	/* Unsupported message type */
+
 		p_ptr = tipc_port_lock(dref);
-		if (!p_ptr) {
-			/* Port deleted while msg in queue */
-			tipc_reject_msg(buf, TIPC_ERR_NO_PORT);
-			buf = next;
-			continue;
-		}
+		if (!p_ptr)
+			goto reject;	/* Port deleted while msg in queue */
+
 		orig.ref = msg_origport(msg);
 		orig.node = msg_orignode(msg);
 		up_ptr = p_ptr->user_port;
@@ -832,7 +834,7 @@ static void port_dispatcher_sigh(void *d
 		if (unlikely(msg_errcode(msg)))
 			goto err;
 
-		switch (msg_type(msg)) {
+		switch (message_type) {
 		
 		case TIPC_CONN_MSG:{
 				tipc_conn_msg_event cb = up_ptr->conn_msg_cb;
@@ -874,6 +876,7 @@ static void port_dispatcher_sigh(void *d
 				   &orig);
 				break;
 			}
+		case TIPC_MCAST_MSG:
 		case TIPC_NAMED_MSG:{
 				tipc_named_msg_event cb = up_ptr->named_msg_cb;
 
@@ -886,7 +889,8 @@ static void port_dispatcher_sigh(void *d
 					goto reject;
 				dseq.type =  msg_nametype(msg);
 				dseq.lower = msg_nameinst(msg);
-				dseq.upper = dseq.lower;
+				dseq.upper = (message_type == TIPC_NAMED_MSG)
+					? dseq.lower : msg_nameupper(msg);
 				skb_pull(buf, msg_hdr_sz(msg));
 				cb(usr_handle, dref, &buf, msg_data(msg), 
 				   msg_data_sz(msg), msg_importance(msg),
@@ -899,7 +903,7 @@ static void port_dispatcher_sigh(void *d
 		buf = next;
 		continue;
 err:
-		switch (msg_type(msg)) {
+		switch (message_type) {
 		
 		case TIPC_CONN_MSG:{
 				tipc_conn_shutdown_event cb = 
@@ -931,6 +935,7 @@ err:
 				   msg_data_sz(msg), msg_errcode(msg), &orig);
 				break;
 			}
+		case TIPC_MCAST_MSG:
 		case TIPC_NAMED_MSG:{
 				tipc_named_msg_err_event cb = 
 					up_ptr->named_err_cb;
@@ -940,7 +945,8 @@ err:
 					break;
 				dseq.type =  msg_nametype(msg);
 				dseq.lower = msg_nameinst(msg);
-				dseq.upper = dseq.lower;
+				dseq.upper = (message_type == TIPC_NAMED_MSG)
+					? dseq.lower : msg_nameupper(msg);
 				skb_pull(buf, msg_hdr_sz(msg));
 				cb(usr_handle, dref, &buf, msg_data(msg), 
 				   msg_data_sz(msg), msg_errcode(msg), &dseq);
-- 
1.4.0

