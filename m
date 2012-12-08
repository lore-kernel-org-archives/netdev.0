From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/9] tipc: standardize across connect/disconnect function naming
Date: Fri, 7 Dec 2012 20:19:13 -0500
Message-ID: <1354929558-16948-5-git-send-email-paul.gortmaker@windriver.com>
References: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63587 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757476Ab2LHBTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 20:19:37 -0500
In-Reply-To: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have tipc_disconnect and tipc_disconnect_port.  It is
not clear from the names alone, what they do or how they differ.
It turns out that tipc_disconnect just deals with the port locking
and then calls tipc_disconnect_port which does all the work.

If we rename as follows: tipc_disconnect_port --> __tipc_disconnect
then we will be following typical linux convention, where:

   __tipc_disconnect: "raw" function that does all the work.

   tipc_disconnect: wrapper that deals with locking and then calls
		    the real core __tipc_disconnect function

With this, the difference is immediately evident, and locking
violations are more apt to be spotted by chance while working on,
or even just while reading the code.

On the connect side of things, we currently only have the single
"tipc_connect2port" function.  It does both the locking at enter/exit,
and the core of the work.  Pending changes will make it desireable to
have the connect be a two part locking wrapper + worker function,
just like the disconnect is already.

Here, we make the connect look just like the updated disconnect case,
for the above reason, and for consistency.  In the process, we also
get rid of the "2port" suffix that was on the original name, since
it adds no descriptive value.

On close examination, one might notice that the above connect
changes implicitly move the call to tipc_link_get_max_pkt() to be
within the scope of tipc_port_lock() protected region; when it was
not previously.  We don't see any issues with this, and it is in
keeping with __tipc_connect doing the work and tipc_connect just
handling the locking.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c   | 32 +++++++++++++++++++++++---------
 net/tipc/port.h   |  6 ++++--
 net/tipc/socket.c |  6 +++---
 net/tipc/subscr.c |  2 +-
 4 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 07c42fb..18098ca 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -726,7 +726,7 @@ static void port_dispatcher_sigh(void *dummy)
 				if (unlikely(!cb))
 					goto reject;
 				if (unlikely(!connected)) {
-					if (tipc_connect2port(dref, &orig))
+					if (tipc_connect(dref, &orig))
 						goto reject;
 				} else if (peer_invalid)
 					goto reject;
@@ -1036,15 +1036,30 @@ int tipc_withdraw(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 	return res;
 }
 
-int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
+int tipc_connect(u32 ref, struct tipc_portid const *peer)
 {
 	struct tipc_port *p_ptr;
-	struct tipc_msg *msg;
-	int res = -EINVAL;
+	int res;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
+	res = __tipc_connect(ref, p_ptr, peer);
+	tipc_port_unlock(p_ptr);
+	return res;
+}
+
+/*
+ * __tipc_connect - connect to a remote peer
+ *
+ * Port must be locked.
+ */
+int __tipc_connect(u32 ref, struct tipc_port *p_ptr,
+			struct tipc_portid const *peer)
+{
+	struct tipc_msg *msg;
+	int res = -EINVAL;
+
 	if (p_ptr->published || p_ptr->connected)
 		goto exit;
 	if (!peer->ref)
@@ -1067,17 +1082,16 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 			  (net_ev_handler)port_handle_node_down);
 	res = 0;
 exit:
-	tipc_port_unlock(p_ptr);
 	p_ptr->max_pkt = tipc_link_get_max_pkt(peer->node, ref);
 	return res;
 }
 
-/**
- * tipc_disconnect_port - disconnect port from peer
+/*
+ * __tipc_disconnect - disconnect port from peer
  *
  * Port must be locked.
  */
-int tipc_disconnect_port(struct tipc_port *tp_ptr)
+int __tipc_disconnect(struct tipc_port *tp_ptr)
 {
 	int res;
 
@@ -1104,7 +1118,7 @@ int tipc_disconnect(u32 ref)
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	res = tipc_disconnect_port(p_ptr);
+	res = __tipc_disconnect(p_ptr);
 	tipc_port_unlock(p_ptr);
 	return res;
 }
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 4660e30..fb66e2e 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -190,7 +190,7 @@ int tipc_publish(u32 portref, unsigned int scope,
 int tipc_withdraw(u32 portref, unsigned int scope,
 		struct tipc_name_seq const *name_seq);
 
-int tipc_connect2port(u32 portref, struct tipc_portid const *port);
+int tipc_connect(u32 portref, struct tipc_portid const *port);
 
 int tipc_disconnect(u32 portref);
 
@@ -200,7 +200,9 @@ int tipc_shutdown(u32 ref);
 /*
  * The following routines require that the port be locked on entry
  */
-int tipc_disconnect_port(struct tipc_port *tp_ptr);
+int __tipc_disconnect(struct tipc_port *tp_ptr);
+int __tipc_connect(u32 ref, struct tipc_port *p_ptr,
+		   struct tipc_portid const *peer);
 int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f553fde..b630f38 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -783,7 +783,7 @@ static int auto_connect(struct socket *sock, struct tipc_msg *msg)
 
 	tsock->peer_name.ref = msg_origport(msg);
 	tsock->peer_name.node = msg_orignode(msg);
-	tipc_connect2port(tsock->p->ref, &tsock->peer_name);
+	tipc_connect(tsock->p->ref, &tsock->peer_name);
 	tipc_set_portimportance(tsock->p->ref, msg_importance(msg));
 	sock->state = SS_CONNECTED;
 	return 0;
@@ -1246,7 +1246,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	/* Initiate connection termination for an incoming 'FIN' */
 	if (unlikely(msg_errcode(msg) && (sock->state == SS_CONNECTED))) {
 		sock->state = SS_DISCONNECTING;
-		tipc_disconnect_port(tipc_sk_port(sk));
+		__tipc_disconnect(tipc_sk_port(sk));
 	}
 
 	sk->sk_data_ready(sk, 0);
@@ -1506,7 +1506,7 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 		/* Connect new socket to it's peer */
 		new_tsock->peer_name.ref = msg_origport(msg);
 		new_tsock->peer_name.node = msg_orignode(msg);
-		tipc_connect2port(new_ref, &new_tsock->peer_name);
+		tipc_connect(new_ref, &new_tsock->peer_name);
 		new_sock->state = SS_CONNECTED;
 
 		tipc_set_portimportance(new_ref, msg_importance(msg));
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 0f7d0d0..6b42d47 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -462,7 +462,7 @@ static void subscr_named_msg_event(void *usr_handle,
 		kfree(subscriber);
 		return;
 	}
-	tipc_connect2port(subscriber->port_ref, orig);
+	tipc_connect(subscriber->port_ref, orig);
 
 	/* Lock server port (& save lock address for future use) */
 	subscriber->lock = tipc_port_lock(subscriber->port_ref)->lock;
-- 
1.7.12.1
