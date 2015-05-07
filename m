From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 11/11] net: change behaviours of functions of creating and releasing kernel sockets
Date: Thu, 7 May 2015 16:52:50 +0800
Message-ID: <1430988770-28907-12-git-send-email-ying.xue@windriver.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <herbert@gondor.apana.org.au>,
	<xemul@openvz.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <ebiederm@xmission.com>,
	<maxk@qti.qualcomm.com>, <stephen@networkplumber.org>,
	<tgraf@suug.ch>, <nicolas.dichtel@6wind.com>,
	<tom@herbertland.com>, <jchapman@katalix.com>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35601 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbEGIyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:54:09 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far it's unnecessary to switch namespace when creating a kernel
socket with __sock_create() within a namespace which is different
with init_net. But after that, we have to explicitly decrease the
namespace's reference counter, and increase it again before release
the socket. To make code as simple as possible, we decide to change
the sock_create_kern() API by adding an extra argument - net that
represents in which namespace the kernel socket is created. If all
kernel modules create kernel sockets with the updated API, the
reference counters of sockets' namespaces which are different with
init_net will be put, and these sockets must be released with
sk_release_kernel() in which corresponding namespaces' reference
counters will be increased before they are released.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/block/drbd/drbd_receiver.c |    6 ++++--
 fs/afs/rxrpc.c                     |    3 ++-
 fs/dlm/lowcomms.c                  |   16 ++++++++--------
 include/linux/net.h                |    3 ++-
 include/net/inet_common.h          |    3 +--
 net/bluetooth/rfcomm/core.c        |    3 ++-
 net/ceph/messenger.c               |    4 ++--
 net/core/sock.c                    |    5 ++---
 net/ipv4/af_inet.c                 |    4 +---
 net/ipv4/udp_tunnel.c              |   10 +++-------
 net/ipv6/ip6_udp_tunnel.c          |    7 ++-----
 net/l2tp/l2tp_core.c               |   18 ++++++------------
 net/netfilter/ipvs/ip_vs_sync.c    |   36 ++++++++----------------------------
 net/rxrpc/ar-local.c               |    4 ++--
 net/socket.c                       |    9 +++++++--
 15 files changed, 52 insertions(+), 79 deletions(-)

diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index cee2035..8d86b28 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -598,7 +598,8 @@ static struct socket *drbd_try_connect(struct drbd_connection *connection)
 	memcpy(&peer_in6, &connection->peer_addr, peer_addr_len);
 
 	what = "sock_create_kern";
-	err = sock_create_kern(((struct sockaddr *)&src_in6)->sa_family,
+	err = sock_create_kern(&init_net,
+			       ((struct sockaddr *)&src_in6)->sa_family,
 			       SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (err < 0) {
 		sock = NULL;
@@ -693,7 +694,8 @@ static int prepare_listen_socket(struct drbd_connection *connection, struct acce
 	memcpy(&my_addr, &connection->my_addr, my_addr_len);
 
 	what = "sock_create_kern";
-	err = sock_create_kern(((struct sockaddr *)&my_addr)->sa_family,
+	err = sock_create_kern(&init_net,
+			       ((struct sockaddr *)&my_addr)->sa_family,
 			       SOCK_STREAM, IPPROTO_TCP, &s_listen);
 	if (err) {
 		s_listen = NULL;
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 3a57a1b..69486ca 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -85,7 +85,8 @@ int afs_open_socket(void)
 		return -ENOMEM;
 	}
 
-	ret = sock_create_kern(AF_RXRPC, SOCK_DGRAM, PF_INET, &socket);
+	ret = sock_create_kern(&init_net, AF_RXRPC, SOCK_DGRAM, PF_INET,
+			       &socket);
 	if (ret < 0) {
 		destroy_workqueue(afs_async_calls);
 		_leave(" = %d [socket]", ret);
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index d08e079..754fd6c 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -921,8 +921,8 @@ static int tcp_accept_from_sock(struct connection *con)
 	mutex_unlock(&connections_lock);
 
 	memset(&peeraddr, 0, sizeof(peeraddr));
-	result = sock_create_kern(dlm_local_addr[0]->ss_family, SOCK_STREAM,
-				  IPPROTO_TCP, &newsock);
+	result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
+				  SOCK_STREAM, IPPROTO_TCP, &newsock);
 	if (result < 0)
 		return -ENOMEM;
 
@@ -1173,8 +1173,8 @@ static void tcp_connect_to_sock(struct connection *con)
 		goto out;
 
 	/* Create a socket to communicate with */
-	result = sock_create_kern(dlm_local_addr[0]->ss_family, SOCK_STREAM,
-				  IPPROTO_TCP, &sock);
+	result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
+				  SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (result < 0)
 		goto out_err;
 
@@ -1258,8 +1258,8 @@ static struct socket *tcp_create_listen_sock(struct connection *con,
 		addr_len = sizeof(struct sockaddr_in6);
 
 	/* Create a socket to communicate with */
-	result = sock_create_kern(dlm_local_addr[0]->ss_family, SOCK_STREAM,
-				  IPPROTO_TCP, &sock);
+	result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
+				  SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (result < 0) {
 		log_print("Can't create listening comms socket");
 		goto create_out;
@@ -1365,8 +1365,8 @@ static int sctp_listen_for_all(void)
 
 	log_print("Using SCTP for communications");
 
-	result = sock_create_kern(dlm_local_addr[0]->ss_family, SOCK_SEQPACKET,
-				  IPPROTO_SCTP, &sock);
+	result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
+				  SOCK_SEQPACKET, IPPROTO_SCTP, &sock);
 	if (result < 0) {
 		log_print("Can't create comms socket, check SCTP is loaded");
 		goto out;
diff --git a/include/linux/net.h b/include/linux/net.h
index 738ea48..fc1fdc2 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -208,7 +208,8 @@ void sock_unregister(int family);
 int __sock_create(struct net *net, int family, int type, int proto,
 		  struct socket **res, int kern);
 int sock_create(int family, int type, int proto, struct socket **res);
-int sock_create_kern(int family, int type, int proto, struct socket **res);
+int sock_create_kern(struct net *net, int family, int type, int proto,
+		     struct socket **res);
 int sock_create_lite(int family, int type, int proto, struct socket **res);
 void sock_release(struct socket *sock);
 int sock_sendmsg(struct socket *sock, struct msghdr *msg);
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index cedc7c7..4a92423 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -41,8 +41,7 @@ int inet_recv_error(struct sock *sk, struct msghdr *msg, int len,
 
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
-	get_net(sock_net(sk));
-	sock_release(sk->sk_socket);
+	sk_release_kernel(sk);
 }
 
 #endif
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 4fea242..6b4bbfb 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -200,7 +200,8 @@ static int rfcomm_l2sock_create(struct socket **sock)
 
 	BT_DBG("");
 
-	err = sock_create_kern(PF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_L2CAP, sock);
+	err = sock_create_kern(&init_net, PF_BLUETOOTH, SOCK_SEQPACKET,
+			       BTPROTO_L2CAP, sock);
 	if (!err) {
 		struct sock *sk = (*sock)->sk;
 		sk->sk_data_ready   = rfcomm_l2data_ready;
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 967080a..073262f 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -480,8 +480,8 @@ static int ceph_tcp_connect(struct ceph_connection *con)
 	int ret;
 
 	BUG_ON(con->sock);
-	ret = sock_create_kern(con->peer_addr.in_addr.ss_family, SOCK_STREAM,
-			       IPPROTO_TCP, &sock);
+	ret = sock_create_kern(&init_net, con->peer_addr.in_addr.ss_family,
+			       SOCK_STREAM, IPPROTO_TCP, &sock);
 	if (ret)
 		return ret;
 	sock->sk->sk_allocation = GFP_NOFS;
diff --git a/net/core/sock.c b/net/core/sock.c
index e891bcf..41aa188 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1473,10 +1473,9 @@ void sk_release_kernel(struct sock *sk)
 	if (sk == NULL || sk->sk_socket == NULL)
 		return;
 
-	sock_hold(sk);
-	sock_net_set(sk, get_net(&init_net));
+	if (!net_eq(&init_net, sock_net(sk)))
+		get_net(sock_net(sk));
 	sock_release(sk->sk_socket);
-	sock_put(sk);
 }
 EXPORT_SYMBOL(sk_release_kernel);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 50e6292..ddc8369 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1430,7 +1430,7 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 struct net *net)
 {
 	struct socket *sock;
-	int rc = __sock_create(net, family, type, protocol, &sock, 1);
+	int rc = sock_create_kern(net, family, type, protocol, &sock);
 
 	if (rc == 0) {
 		*sk = sock->sk;
@@ -1440,8 +1440,6 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 		 * we do not wish this socket to see incoming packets.
 		 */
 		(*sk)->sk_prot->unhash(*sk);
-
-		put_net(sock_net(*sk));
 	}
 	return rc;
 }
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 720ab82..de4e134 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -15,12 +15,10 @@ int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 	struct socket *sock = NULL;
 	struct sockaddr_in udp_addr;
 
-	err = __sock_create(net, AF_INET, SOCK_DGRAM, 0, &sock, 1);
+	err = sock_create_kern(net, AF_INET, SOCK_DGRAM, 0, &sock);
 	if (err < 0)
 		goto error;
 
-	put_net(sock_net(sock->sk));
-
 	udp_addr.sin_family = AF_INET;
 	udp_addr.sin_addr = cfg->local_ip;
 	udp_addr.sin_port = cfg->local_udp_port;
@@ -47,8 +45,7 @@ int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 error:
 	if (sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		get_net(sock_net(sock->sk));
-		sock_release(sock);
+		sk_release_kernel(sock->sk);
 	}
 	*sockp = NULL;
 	return err;
@@ -102,8 +99,7 @@ void udp_tunnel_sock_release(struct socket *sock)
 {
 	rcu_assign_sk_user_data(sock->sk, NULL);
 	kernel_sock_shutdown(sock, SHUT_RDWR);
-	get_net(sock_net(sock->sk));
-	sock_release(sock);
+	sk_release_kernel(sock->sk);
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_sock_release);
 
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index 4da0bc5..b35c5cd 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -19,12 +19,10 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 	int err;
 	struct socket *sock = NULL;
 
-	err = __sock_create(net, AF_INET6, SOCK_DGRAM, 0, &sock, 1);
+	err = sock_create_kern(net, AF_INET6, SOCK_DGRAM, 0, &sock);
 	if (err < 0)
 		goto error;
 
-	put_net(sock_net(sock->sk));
-
 	udp6_addr.sin6_family = AF_INET6;
 	memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
 	       sizeof(udp6_addr.sin6_addr));
@@ -55,8 +53,7 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 error:
 	if (sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		get_net(sock_net(sock->sk));
-		sock_release(sock);
+		sk_release_kernel(sock->sk);
 	}
 	*sockp = NULL;
 	return err;
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index aa01daac..7e1f736 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1336,8 +1336,7 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	} else {
 		if (sock)
 			kernel_sock_shutdown(sock, SHUT_RDWR);
-		get_net(sock_net(sk));
-		sock_release(sock);
+		sk_release_kernel(sk);
 	}
 
 	l2tp_tunnel_sock_put(sk);
@@ -1400,13 +1399,11 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		if (cfg->local_ip6 && cfg->peer_ip6) {
 			struct sockaddr_l2tpip6 ip6_addr = {0};
 
-			err = __sock_create(net, AF_INET6, SOCK_DGRAM,
-					    IPPROTO_L2TP, &sock, 1);
+			err = sock_create_kern(net, AF_INET6, SOCK_DGRAM,
+					       IPPROTO_L2TP, &sock);
 			if (err < 0)
 				goto out;
 
-			put_net(sock_net(sock->sk));
-
 			ip6_addr.l2tp_family = AF_INET6;
 			memcpy(&ip6_addr.l2tp_addr, cfg->local_ip6,
 			       sizeof(ip6_addr.l2tp_addr));
@@ -1430,13 +1427,11 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		{
 			struct sockaddr_l2tpip ip_addr = {0};
 
-			err = __sock_create(net, AF_INET, SOCK_DGRAM,
-					    IPPROTO_L2TP, &sock, 1);
+			err = sock_create_kern(net, AF_INET, SOCK_DGRAM,
+					       IPPROTO_L2TP, &sock);
 			if (err < 0)
 				goto out;
 
-			put_net(sock_net(sock->sk));
-
 			ip_addr.l2tp_family = AF_INET;
 			ip_addr.l2tp_addr = cfg->local_ip;
 			ip_addr.l2tp_conn_id = tunnel_id;
@@ -1463,8 +1458,7 @@ out:
 	*sockp = sock;
 	if ((err < 0) && sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		get_net(sock_net(sock->sk));
-		sock_release(sock);
+		sk_release_kernel(sock->sk);
 		*sockp = NULL;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 4472fa0..de52dc8 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1458,18 +1458,11 @@ static struct socket *make_send_sock(struct net *net, int id)
 	int result;
 
 	/* First create a socket move it to right name space later */
-	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
+	result = sock_create_kern(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-	/*
-	 * Kernel sockets that are a part of a namespace, should not
-	 * hold a reference to a namespace in order to allow to stop it.
-	 * After the reference is decreased here with put_net(), it should
-	 * be increased again using get_net() before the socket is released.
-	 */
-	put_net(sock_net(sock->sk));
 	result = set_mcast_if(sock->sk, ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
@@ -1498,8 +1491,7 @@ static struct socket *make_send_sock(struct net *net, int id)
 	return sock;
 
 error:
-	get_net(sock_net(sock->sk));
-	sock_release(sock);
+	sk_release_kernel(sock->sk);
 	return ERR_PTR(result);
 }
 
@@ -1520,18 +1512,11 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	int result;
 
 	/* First create a socket */
-	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
+	result = sock_create_kern(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-	/*
-	 * Kernel sockets that are a part of a namespace, should not
-	 * hold a reference to a namespace in order to allow to stop it.
-	 * After the reference is decreased here with put_net(), it should
-	 * be increased again using get_net() before the socket is released.
-	 */
-	put_net(sock_net(sock->sk));
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = SK_CAN_REUSE;
 	result = sysctl_sync_sock_size(ipvs);
@@ -1557,8 +1542,7 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	return sock;
 
 error:
-	get_net(sock_net(sock->sk));
-	sock_release(sock);
+	sk_release_kernel(sock->sk);
 	return ERR_PTR(result);
 }
 
@@ -1696,8 +1680,7 @@ done:
 		ip_vs_sync_buff_release(sb);
 
 	/* release the sending multicast socket */
-	get_net(sock_net(tinfo->sock->sk));
-	sock_release(tinfo->sock);
+	sk_release_kernel(tinfo->sock->sk);
 	kfree(tinfo);
 
 	return 0;
@@ -1734,8 +1717,7 @@ static int sync_thread_backup(void *data)
 	}
 
 	/* release the sending multicast socket */
-	get_net(sock_net(tinfo->sock->sk));
-	sock_release(tinfo->sock);
+	sk_release_kernel(tinfo->sock->sk);
 	kfree(tinfo->buf);
 	kfree(tinfo);
 
@@ -1860,13 +1842,11 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	return 0;
 
 outsocket:
-	get_net(sock_net(sock->sk));
-	sock_release(sock);
+	sk_release_kernel(sock->sk);
 
 outtinfo:
 	if (tinfo) {
-		get_net(sock_net(tinfo->sock->sk));
-		sock_release(tinfo->sock);
+		sk_release_kernel(tinfo->sock->sk);
 		kfree(tinfo->buf);
 		kfree(tinfo);
 	}
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index ca904ed..78483b4 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -73,8 +73,8 @@ static int rxrpc_create_local(struct rxrpc_local *local)
 	_enter("%p{%d}", local, local->srx.transport_type);
 
 	/* create a socket to represent the local endpoint */
-	ret = sock_create_kern(PF_INET, local->srx.transport_type, IPPROTO_UDP,
-			       &local->socket);
+	ret = sock_create_kern(&init_net, PF_INET, local->srx.transport_type,
+			       IPPROTO_UDP, &local->socket);
 	if (ret < 0) {
 		_leave(" = %d [socket]", ret);
 		return ret;
diff --git a/net/socket.c b/net/socket.c
index 884e329..09414d7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1213,9 +1213,14 @@ int sock_create(int family, int type, int protocol, struct socket **res)
 }
 EXPORT_SYMBOL(sock_create);
 
-int sock_create_kern(int family, int type, int protocol, struct socket **res)
+int sock_create_kern(struct net *net, int family, int type, int protocol,
+		     struct socket **res)
 {
-	return __sock_create(&init_net, family, type, protocol, res, 1);
+	int err = __sock_create(net, family, type, protocol, res, 1);
+
+	if (!err && !net_eq(&init_net, net))
+		put_net(sock_net((*res)->sk));
+	return err;
 }
 EXPORT_SYMBOL(sock_create_kern);
 
-- 
1.7.9.5
