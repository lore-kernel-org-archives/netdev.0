From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 02/13 net-next-2.6] [TIPC]: Standardize error checking on incoming messages via native API
Date: Fri, 30 May 2008 14:20:37 -0400
Message-ID: <1212171648-27122-3-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50491 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752983AbYE3SXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:07 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch re-orders & re-groups the error checks performed on
messages being delivered to native API ports, in order to clarify the
similarities and differences required for the various message types.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/port.c |   25 +++++++++----------------
 1 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 0bd3e61..4dfef9e 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -841,14 +841,14 @@ static void port_dispatcher_sigh(void *dummy)
 				u32 peer_node = port_peernode(p_ptr);
 
 				tipc_port_unlock(p_ptr);
+				if (unlikely(!cb))
+					goto reject;
 				if (unlikely(!connected)) {
 					if (tipc_connect2port(dref, &orig))
 						goto reject;
 				} else if ((msg_origport(msg) != peer_port) ||
 					   (msg_orignode(msg) != peer_node))
 					goto reject;
-				if (unlikely(!cb))
-					goto reject;
 				if (unlikely(++p_ptr->publ.conn_unacked >=
 					     TIPC_FLOW_CONTROL_WIN))
 					tipc_acknowledge(dref,
@@ -862,9 +862,7 @@ static void port_dispatcher_sigh(void *dummy)
 				tipc_msg_event cb = up_ptr->msg_cb;
 
 				tipc_port_unlock(p_ptr);
-				if (unlikely(connected))
-					goto reject;
-				if (unlikely(!cb))
+				if (unlikely(!cb || connected))
 					goto reject;
 				skb_pull(buf, msg_hdr_sz(msg));
 				cb(usr_handle, dref, &buf, msg_data(msg),
@@ -877,11 +875,7 @@ static void port_dispatcher_sigh(void *dummy)
 				tipc_named_msg_event cb = up_ptr->named_msg_cb;
 
 				tipc_port_unlock(p_ptr);
-				if (unlikely(connected))
-					goto reject;
-				if (unlikely(!cb))
-					goto reject;
-				if (unlikely(!published))
+				if (unlikely(!cb || connected || !published))
 					goto reject;
 				dseq.type =  msg_nametype(msg);
 				dseq.lower = msg_nameinst(msg);
@@ -908,11 +902,10 @@ err:
 				u32 peer_node = port_peernode(p_ptr);
 
 				tipc_port_unlock(p_ptr);
-				if (!connected || !cb)
-					break;
-				if (msg_origport(msg) != peer_port)
+				if (!cb || !connected)
 					break;
-				if (msg_orignode(msg) != peer_node)
+				if ((msg_origport(msg) != peer_port) ||
+				    (msg_orignode(msg) != peer_node))
 					break;
 				tipc_disconnect(dref);
 				skb_pull(buf, msg_hdr_sz(msg));
@@ -924,7 +917,7 @@ err:
 				tipc_msg_err_event cb = up_ptr->err_cb;
 
 				tipc_port_unlock(p_ptr);
-				if (connected || !cb)
+				if (!cb || connected)
 					break;
 				skb_pull(buf, msg_hdr_sz(msg));
 				cb(usr_handle, dref, &buf, msg_data(msg),
@@ -937,7 +930,7 @@ err:
 					up_ptr->named_err_cb;
 
 				tipc_port_unlock(p_ptr);
-				if (connected || !cb)
+				if (!cb || connected)
 					break;
 				dseq.type =  msg_nametype(msg);
 				dseq.lower = msg_nameinst(msg);
-- 
1.5.3.2

