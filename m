From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 14/17] tipc: remove source file
	port.c
Date: Fri, 22 Aug 2014 18:09:17 -0400
Message-ID: <1408745360-23560-15-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we move the remaining functions in port.c to
socket.c, and give them new names that correspond to their new
location. We then remove the file port.c.

There are only cosmetic changes to the moved functions.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/Makefile |    2 +-
 net/tipc/port.c   |  123 -----------------------------------------------------
 net/tipc/socket.c |  102 +++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 97 insertions(+), 130 deletions(-)
 delete mode 100644 net/tipc/port.c

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index a080c66..5206a44 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_TIPC) := tipc.o
 tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   core.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
-	   netlink.o node.o node_subscr.o port.o ref.o  \
+	   netlink.o node.o node_subscr.o ref.o  \
 	   socket.o log.o eth_media.o server.o
 
 tipc-$(CONFIG_TIPC_MEDIA_IB)	+= ib_media.o
diff --git a/net/tipc/port.c b/net/tipc/port.c
deleted file mode 100644
index cea3730..0000000
--- a/net/tipc/port.c
+++ /dev/null
@@ -1,123 +0,0 @@
-/*
- * net/tipc/port.c: TIPC port code
- *
- * Copyright (c) 1992-2007, 2014, Ericsson AB
- * Copyright (c) 2004-2008, 2010-2013, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include "core.h"
-#include "config.h"
-#include "port.h"
-#include "name_table.h"
-#include "socket.h"
-
-#define MAX_REJECT_SIZE 1024
-
-/**
- * tipc_port_peer_msg - verify message was sent by connected port's peer
- *
- * Handles cases where the node's network address has changed from
- * the default of <0.0.0> to its configured setting.
- */
-int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg)
-{
-	u32 peernode;
-	u32 orignode;
-
-	if (msg_origport(msg) != tipc_port_peerport(p_ptr))
-		return 0;
-
-	orignode = msg_orignode(msg);
-	peernode = tipc_port_peernode(p_ptr);
-	return (orignode == peernode) ||
-		(!orignode && (peernode == tipc_own_addr)) ||
-		(!peernode && (orignode == tipc_own_addr));
-}
-
-int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
-		 struct tipc_name_seq const *seq)
-{
-	struct publication *publ;
-	u32 key;
-
-	if (p_ptr->connected)
-		return -EINVAL;
-	key = p_ptr->ref + p_ptr->pub_count + 1;
-	if (key == p_ptr->ref)
-		return -EADDRINUSE;
-
-	publ = tipc_nametbl_publish(seq->type, seq->lower, seq->upper,
-				    scope, p_ptr->ref, key);
-	if (publ) {
-		list_add(&publ->pport_list, &p_ptr->publications);
-		p_ptr->pub_count++;
-		p_ptr->published = 1;
-		return 0;
-	}
-	return -EINVAL;
-}
-
-int tipc_withdraw(struct tipc_port *p_ptr, unsigned int scope,
-		  struct tipc_name_seq const *seq)
-{
-	struct publication *publ;
-	struct publication *tpubl;
-	int res = -EINVAL;
-
-	if (!seq) {
-		list_for_each_entry_safe(publ, tpubl,
-					 &p_ptr->publications, pport_list) {
-			tipc_nametbl_withdraw(publ->type, publ->lower,
-					      publ->ref, publ->key);
-		}
-		res = 0;
-	} else {
-		list_for_each_entry_safe(publ, tpubl,
-					 &p_ptr->publications, pport_list) {
-			if (publ->scope != scope)
-				continue;
-			if (publ->type != seq->type)
-				continue;
-			if (publ->lower != seq->lower)
-				continue;
-			if (publ->upper != seq->upper)
-				break;
-			tipc_nametbl_withdraw(publ->type, publ->lower,
-					      publ->ref, publ->key);
-			res = 0;
-			break;
-		}
-	}
-	if (list_empty(&p_ptr->publications))
-		p_ptr->published = 0;
-	return res;
-}
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7e6240e..ea33eab 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -57,6 +57,10 @@ static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p);
 static void tipc_sk_timeout(unsigned long ref);
+static int tipc_sk_publish(struct tipc_port *port, uint scope,
+			   struct tipc_name_seq const *seq);
+static int tipc_sk_withdraw(struct tipc_port *port, uint scope,
+			    struct tipc_name_seq const *seq);
 
 static const struct proto_ops packet_ops;
 static const struct proto_ops stream_ops;
@@ -138,6 +142,38 @@ static void reject_rx_queue(struct sock *sk)
 	}
 }
 
+/* tipc_sk_peer_msg - verify if message was sent by connected port's peer
+ *
+ * Handles cases where the node's network address has changed from
+ * the default of <0.0.0> to its configured setting.
+ */
+static bool tipc_sk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
+{
+	u32 peer_port = tipc_port_peerport(&tsk->port);
+	u32 orig_node;
+	u32 peer_node;
+
+	if (unlikely(!tsk->port.connected))
+		return false;
+
+	if (unlikely(msg_origport(msg) != peer_port))
+		return false;
+
+	orig_node = msg_orignode(msg);
+	peer_node = tipc_port_peernode(&tsk->port);
+
+	if (likely(orig_node == peer_node))
+		return true;
+
+	if (!orig_node && (peer_node == tipc_own_addr))
+		return true;
+
+	if (!peer_node && (orig_node == tipc_own_addr))
+		return true;
+
+	return false;
+}
+
 /**
  * tipc_sk_create - create a TIPC socket
  * @net: network namespace (must be default network)
@@ -356,7 +392,7 @@ static int tipc_release(struct socket *sock)
 		}
 	}
 
-	tipc_withdraw(port, 0, NULL);
+	tipc_sk_withdraw(port, 0, NULL);
 	tipc_ref_discard(port->ref);
 	k_cancel_timer(&port->timer);
 	if (port->connected) {
@@ -407,7 +443,7 @@ static int tipc_bind(struct socket *sock, struct sockaddr *uaddr,
 
 	lock_sock(sk);
 	if (unlikely(!uaddr_len)) {
-		res = tipc_withdraw(&tsk->port, 0, NULL);
+		res = tipc_sk_withdraw(&tsk->port, 0, NULL);
 		goto exit;
 	}
 
@@ -435,8 +471,8 @@ static int tipc_bind(struct socket *sock, struct sockaddr *uaddr,
 	}
 
 	res = (addr->scope > 0) ?
-		tipc_publish(&tsk->port, addr->scope, &addr->addr.nameseq) :
-		tipc_withdraw(&tsk->port, -addr->scope, &addr->addr.nameseq);
+		tipc_sk_publish(&tsk->port, addr->scope, &addr->addr.nameseq) :
+		tipc_sk_withdraw(&tsk->port, -addr->scope, &addr->addr.nameseq);
 exit:
 	release_sock(sk);
 	return res;
@@ -663,7 +699,7 @@ static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
 	int conn_cong;
 
 	/* Ignore if connection cannot be validated: */
-	if (!port->connected || !tipc_port_peer_msg(port, msg))
+	if (!tipc_sk_peer_msg(tsk, msg))
 		goto exit;
 
 	port->probing_state = TIPC_CONN_OK;
@@ -1444,7 +1480,7 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 	switch ((int)sock->state) {
 	case SS_CONNECTED:
 		/* Accept only connection-based messages sent by peer */
-		if (msg_connected(msg) && tipc_port_peer_msg(port, msg)) {
+		if (tipc_sk_peer_msg(tsk, msg)) {
 			if (unlikely(msg_errcode(msg))) {
 				sock->state = SS_DISCONNECTING;
 				port->connected = 0;
@@ -2027,6 +2063,60 @@ exit:
 	tipc_sk_put(tsk);
 }
 
+static int tipc_sk_publish(struct tipc_port *port, uint scope,
+			   struct tipc_name_seq const *seq)
+{
+	struct publication *publ;
+	u32 key;
+
+	if (port->connected)
+		return -EINVAL;
+	key = port->ref + port->pub_count + 1;
+	if (key == port->ref)
+		return -EADDRINUSE;
+
+	publ = tipc_nametbl_publish(seq->type, seq->lower, seq->upper,
+				    scope, port->ref, key);
+	if (unlikely(!publ))
+		return -EINVAL;
+
+	list_add(&publ->pport_list, &port->publications);
+	port->pub_count++;
+	port->published = 1;
+	return 0;
+}
+
+static int tipc_sk_withdraw(struct tipc_port *port, uint scope,
+			    struct tipc_name_seq const *seq)
+{
+	struct publication *publ;
+	struct publication *safe;
+	int rc = -EINVAL;
+
+	list_for_each_entry_safe(publ, safe, &port->publications, pport_list) {
+		if (seq) {
+			if (publ->scope != scope)
+				continue;
+			if (publ->type != seq->type)
+				continue;
+			if (publ->lower != seq->lower)
+				continue;
+			if (publ->upper != seq->upper)
+				break;
+			tipc_nametbl_withdraw(publ->type, publ->lower,
+					      publ->ref, publ->key);
+			rc = 0;
+			break;
+		}
+		tipc_nametbl_withdraw(publ->type, publ->lower,
+				      publ->ref, publ->key);
+		rc = 0;
+	}
+	if (list_empty(&port->publications))
+		port->published = 0;
+	return rc;
+}
+
 static int tipc_sk_show(struct tipc_port *port, char *buf,
 			int len, int full_id)
 {
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
