From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/17] tipc: Remove support for per-connection message sequence numbering
Date: Wed, 23 Feb 2011 20:26:43 -0500
Message-ID: <1298510805-20630-16-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34538 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932141Ab1BXB1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:17 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates TIPC's prototype support for message sequence numbering
on routable connections (i.e. connections requiring more than one hop).
This capability isn't currently used, and can be removed since TIPC
only supports systems in which all inter-node communication can be
achieved in a single hop.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.c  |    6 +-----
 net/tipc/msg.h  |   12 +-----------
 net/tipc/port.c |   29 +----------------------------
 net/tipc/port.h |    2 --
 4 files changed, 3 insertions(+), 46 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index bb6180c..e56b9b8 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -2,7 +2,7 @@
  * net/tipc/msg.c: TIPC message header routines
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -381,14 +381,10 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, ":OPRT(%u):", msg_origport(msg));
 			tipc_printf(buf, ":DPRT(%u):", msg_destport(msg));
 		}
-		if (msg_routed(msg) && !msg_non_seq(msg))
-			tipc_printf(buf, ":TSEQN(%u)", msg_transp_seqno(msg));
 	}
 	if (msg_user(msg) == NAME_DISTRIBUTOR) {
 		tipc_printf(buf, ":ONOD(%x):", msg_orignode(msg));
 		tipc_printf(buf, ":DNOD(%x):", msg_destnode(msg));
-		if (msg_routed(msg))
-			tipc_printf(buf, ":CSEQN(%u)", msg_transp_seqno(msg));
 	}
 
 	if (msg_user(msg) ==  LINK_CONFIG) {
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 92c4c4f..b1438c7 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -2,7 +2,7 @@
  * net/tipc/msg.h: Include file for TIPC message header routines
  *
  * Copyright (c) 2000-2007, Ericsson AB
- * Copyright (c) 2005-2008, Wind River Systems
+ * Copyright (c) 2005-2008, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -438,11 +438,6 @@ static inline void msg_set_nametype(struct tipc_msg *m, u32 n)
 	msg_set_word(m, 8, n);
 }
 
-static inline u32 msg_transp_seqno(struct tipc_msg *m)
-{
-	return msg_word(m, 8);
-}
-
 static inline void msg_set_timestamp(struct tipc_msg *m, u32 n)
 {
 	msg_set_word(m, 8, n);
@@ -453,11 +448,6 @@ static inline u32 msg_timestamp(struct tipc_msg *m)
 	return msg_word(m, 8);
 }
 
-static inline void msg_set_transp_seqno(struct tipc_msg *m, u32 n)
-{
-	msg_set_word(m, 8, n);
-}
-
 static inline u32 msg_nameinst(struct tipc_msg *m)
 {
 	return msg_word(m, 9);
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 3e5122c..6ff78f9 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -69,20 +69,6 @@ static u32 port_peerport(struct tipc_port *p_ptr)
 	return msg_destport(&p_ptr->phdr);
 }
 
-static u32 port_out_seqno(struct tipc_port *p_ptr)
-{
-	return msg_transp_seqno(&p_ptr->phdr);
-}
-
-static void port_incr_out_seqno(struct tipc_port *p_ptr)
-{
-	struct tipc_msg *m = &p_ptr->phdr;
-
-	if (likely(!msg_routed(m)))
-		return;
-	msg_set_transp_seqno(m, (msg_transp_seqno(m) + 1));
-}
-
 /**
  * tipc_multicast - send a multicast message to local and remote destinations
  */
@@ -233,7 +219,6 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	msg = &p_ptr->phdr;
 	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
 	msg_set_origport(msg, ref);
-	p_ptr->last_in_seqno = 41;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
 	p_ptr->dispatcher = dispatcher;
@@ -344,7 +329,7 @@ int tipc_set_portunreturnable(u32 ref, unsigned int isunrejectable)
 static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 					    u32 origport, u32 orignode,
 					    u32 usr, u32 type, u32 err,
-					    u32 seqno, u32 ack)
+					    u32 ack)
 {
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
@@ -357,7 +342,6 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 		msg_set_destport(msg, destport);
 		msg_set_origport(msg, origport);
 		msg_set_orignode(msg, orignode);
-		msg_set_transp_seqno(msg, seqno);
 		msg_set_msgcnt(msg, ack);
 	}
 	return buf;
@@ -467,9 +451,7 @@ static void port_timeout(unsigned long ref)
 					   CONN_MANAGER,
 					   CONN_PROBE,
 					   TIPC_OK,
-					   port_out_seqno(p_ptr),
 					   0);
-		port_incr_out_seqno(p_ptr);
 		p_ptr->probing_state = PROBING;
 		k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
 	}
@@ -506,7 +488,6 @@ static struct sk_buff *port_build_self_abort_msg(struct tipc_port *p_ptr, u32 er
 				    imp,
 				    TIPC_CONN_MSG,
 				    err,
-				    p_ptr->last_in_seqno + 1,
 				    0);
 }
 
@@ -526,7 +507,6 @@ static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 er
 				    imp,
 				    TIPC_CONN_MSG,
 				    err,
-				    port_out_seqno(p_ptr),
 				    0);
 }
 
@@ -568,7 +548,6 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 					     TIPC_HIGH_IMPORTANCE,
 					     TIPC_CONN_MSG,
 					     err,
-					     0,
 					     0);
 		goto exit;
 	}
@@ -582,11 +561,9 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 					     CONN_MANAGER,
 					     CONN_PROBE_REPLY,
 					     TIPC_OK,
-					     port_out_seqno(p_ptr),
 					     0);
 	}
 	p_ptr->probing_state = CONFIRMED;
-	port_incr_out_seqno(p_ptr);
 exit:
 	if (p_ptr)
 		tipc_port_unlock(p_ptr);
@@ -914,7 +891,6 @@ void tipc_acknowledge(u32 ref, u32 ack)
 					   CONN_MANAGER,
 					   CONN_ACK,
 					   TIPC_OK,
-					   port_out_seqno(p_ptr),
 					   ack);
 	}
 	tipc_port_unlock(p_ptr);
@@ -1088,7 +1064,6 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	msg_set_destport(msg, peer->ref);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_origport(msg, p_ptr->ref);
-	msg_set_transp_seqno(msg, 42);
 	msg_set_type(msg, TIPC_CONN_MSG);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
@@ -1170,7 +1145,6 @@ int tipc_shutdown(u32 ref)
 					   imp,
 					   TIPC_CONN_MSG,
 					   TIPC_CONN_SHUTDOWN,
-					   port_out_seqno(p_ptr),
 					   0);
 	}
 	tipc_port_unlock(p_ptr);
@@ -1220,7 +1194,6 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 			res = tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
 
 		if (likely(res != -ELINKCONG)) {
-			port_incr_out_seqno(p_ptr);
 			p_ptr->congested = 0;
 			if (res > 0)
 				p_ptr->sent++;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 34ccb7c..87b9424 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -119,7 +119,6 @@ struct user_port {
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
  * @probing_interval:
- * @last_in_seqno:
  * @timer_ref:
  * @subscription: "node down" subscription used to terminate failed connections
  */
@@ -147,7 +146,6 @@ struct tipc_port {
 	u32 pub_count;
 	u32 probing_state;
 	u32 probing_interval;
-	u32 last_in_seqno;
 	struct timer_list timer;
 	struct tipc_node_subscr subscription;
 };
-- 
1.7.3.3

