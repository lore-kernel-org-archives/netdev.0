From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 18/20] tipc: split variable assignments out of conditional expressions
Date: Fri, 31 Dec 2010 23:59:33 -0500
Message-ID: <1293857975-30267-19-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53347 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab1AAFAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:15 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Cleans up TIPC's source code to eliminate assigning values to variables
within conditional expressions, improving code readability and reducing
warnings from various code checker tools.

These changes are purely cosmetic and do not alter the operation of TIPC
in any way.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    3 ++-
 net/tipc/core.c   |   33 +++++++++++++++++++++------------
 net/tipc/link.c   |   16 ++++++++++------
 net/tipc/socket.c |   36 +++++++++++++++++++++++-------------
 4 files changed, 56 insertions(+), 32 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 040f3ed..e9136f0 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -251,7 +251,8 @@ static int bearer_name_validate(const char *name,
 	/* ensure all component parts of bearer name are present */
 
 	media_name = name_copy;
-	if ((if_name = strchr(media_name, ':')) == NULL)
+	if_name = strchr(media_name, ':');
+	if (if_name == NULL)
 		return 0;
 	*(if_name++) = 0;
 	media_len = if_name - media_name;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 60b85ec..e071579 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -115,10 +115,11 @@ int tipc_core_start_net(unsigned long addr)
 {
 	int res;
 
-	if ((res = tipc_net_start(addr)) ||
-	    (res = tipc_eth_media_start())) {
+	res = tipc_net_start(addr);
+	if (!res)
+		res = tipc_eth_media_start();
+	if (res)
 		tipc_core_stop_net();
-	}
 	return res;
 }
 
@@ -157,15 +158,22 @@ static int tipc_core_start(void)
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
 	tipc_mode = TIPC_NODE_MODE;
 
-	if ((res = tipc_handler_start()) ||
-	    (res = tipc_ref_table_init(tipc_max_ports, tipc_random)) ||
-	    (res = tipc_nametbl_init()) ||
-	    (res = tipc_k_signal((Handler)tipc_subscr_start, 0)) ||
-	    (res = tipc_k_signal((Handler)tipc_cfg_init, 0)) ||
-	    (res = tipc_netlink_start()) ||
-	    (res = tipc_socket_init())) {
+	res = tipc_handler_start();
+	if (!res)
+		res = tipc_ref_table_init(tipc_max_ports, tipc_random);
+	if (!res)
+		res = tipc_nametbl_init();
+	if (!res)
+		res = tipc_k_signal((Handler)tipc_subscr_start, 0);
+	if (!res)
+		res = tipc_k_signal((Handler)tipc_cfg_init, 0);
+	if (!res)
+		res = tipc_netlink_start();
+	if (!res)
+		res = tipc_socket_init();
+	if (res)
 		tipc_core_stop();
-	}
+
 	return res;
 }
 
@@ -188,7 +196,8 @@ static int __init tipc_init(void)
 	tipc_max_nodes = CONFIG_TIPC_NODES;
 	tipc_net_id = 4711;
 
-	if ((res = tipc_core_start()))
+	res = tipc_core_start();
+	if (res)
 		err("Unable to start in single node mode\n");
 	else
 		info("Started in single node mode\n");
diff --git a/net/tipc/link.c b/net/tipc/link.c
index ef203a1..de9d491 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -187,14 +187,17 @@ static int link_name_validate(const char *name, struct link_name *name_parts)
 	/* ensure all component parts of link name are present */
 
 	addr_local = name_copy;
-	if ((if_local = strchr(addr_local, ':')) == NULL)
+	if_local = strchr(addr_local, ':');
+	if (if_local == NULL)
 		return 0;
 	*(if_local++) = 0;
-	if ((addr_peer = strchr(if_local, '-')) == NULL)
+	addr_peer = strchr(if_local, '-');
+	if (addr_peer == NULL)
 		return 0;
 	*(addr_peer++) = 0;
 	if_local_len = addr_peer - if_local;
-	if ((if_peer = strchr(addr_peer, ':')) == NULL)
+	if_peer = strchr(addr_peer, ':');
+	if (if_peer == NULL)
 		return 0;
 	*(if_peer++) = 0;
 	if_peer_len = strlen(if_peer) + 1;
@@ -2044,8 +2047,8 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 
 		strcpy((strrchr(l_ptr->name, ':') + 1), (char *)msg_data(msg));
 
-		if ((msg_tol = msg_link_tolerance(msg)) &&
-		    (msg_tol > l_ptr->tolerance))
+		msg_tol = msg_link_tolerance(msg);
+		if (msg_tol > l_ptr->tolerance)
 			link_set_supervision_props(l_ptr, msg_tol);
 
 		if (msg_linkprio(msg) > l_ptr->priority)
@@ -2074,7 +2077,8 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 		break;
 	case STATE_MSG:
 
-		if ((msg_tol = msg_link_tolerance(msg)))
+		msg_tol = msg_link_tolerance(msg);
+		if (msg_tol)
 			link_set_supervision_props(l_ptr, msg_tol);
 
 		if (msg_linkprio(msg) &&
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e9fc5df..0895dec 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -563,7 +563,8 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 
 	do {
 		if (dest->addrtype == TIPC_ADDR_NAME) {
-			if ((res = dest_name_check(dest, m)))
+			res = dest_name_check(dest, m);
+			if (res)
 				break;
 			res = tipc_send2name(tport->ref,
 					     &dest->addr.name.name,
@@ -580,7 +581,8 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 				res = -EOPNOTSUPP;
 				break;
 			}
-			if ((res = dest_name_check(dest, m)))
+			res = dest_name_check(dest, m);
+			if (res)
 				break;
 			res = tipc_multicast(tport->ref,
 					     &dest->addr.nameseq,
@@ -750,7 +752,8 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 				bytes_to_send = curr_left;
 			my_iov.iov_base = curr_start;
 			my_iov.iov_len = bytes_to_send;
-			if ((res = send_packet(NULL, sock, &my_msg, 0)) < 0) {
+			res = send_packet(NULL, sock, &my_msg, 0);
+			if (res < 0) {
 				if (bytes_sent)
 					res = bytes_sent;
 				goto exit;
@@ -845,12 +848,15 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	if (unlikely(err)) {
 		anc_data[0] = err;
 		anc_data[1] = msg_data_sz(msg);
-		if ((res = put_cmsg(m, SOL_TIPC, TIPC_ERRINFO, 8, anc_data)))
-			return res;
-		if (anc_data[1] &&
-		    (res = put_cmsg(m, SOL_TIPC, TIPC_RETDATA, anc_data[1],
-				    msg_data(msg))))
+		res = put_cmsg(m, SOL_TIPC, TIPC_ERRINFO, 8, anc_data);
+		if (res)
 			return res;
+		if (anc_data[1]) {
+			res = put_cmsg(m, SOL_TIPC, TIPC_RETDATA, anc_data[1],
+				       msg_data(msg));
+			if (res)
+				return res;
+		}
 	}
 
 	/* Optionally capture message destination object */
@@ -878,9 +884,11 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	default:
 		has_name = 0;
 	}
-	if (has_name &&
-	    (res = put_cmsg(m, SOL_TIPC, TIPC_DESTNAME, 12, anc_data)))
-		return res;
+	if (has_name) {
+		res = put_cmsg(m, SOL_TIPC, TIPC_DESTNAME, 12, anc_data);
+		if (res)
+			return res;
+	}
 
 	return 0;
 }
@@ -1664,7 +1672,8 @@ static int setsockopt(struct socket *sock,
 		return -ENOPROTOOPT;
 	if (ol < sizeof(value))
 		return -EINVAL;
-	if ((res = get_user(value, (u32 __user *)ov)))
+	res = get_user(value, (u32 __user *)ov);
+	if (res)
 		return res;
 
 	lock_sock(sk);
@@ -1722,7 +1731,8 @@ static int getsockopt(struct socket *sock,
 		return put_user(0, ol);
 	if (lvl != SOL_TIPC)
 		return -ENOPROTOOPT;
-	if ((res = get_user(len, ol)))
+	res = get_user(len, ol);
+	if (res)
 		return res;
 
 	lock_sock(sk);
-- 
1.7.3.3

