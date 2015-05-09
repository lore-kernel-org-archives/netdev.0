From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/6] net: Modify sk_alloc to not reference count the netns of kernel sockets.
Date: Fri, 08 May 2015 21:10:31 -0500
Message-ID: <87d22a1ox4.fsf_-_@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
	<87383633pu.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, eric.dumazet@gmail.com,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43077 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbbEICPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 22:15:05 -0400
In-Reply-To: <87383633pu.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 08 May 2015 21:05:33 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that sk_alloc knows when a kernel socket is being allocated modify
it to not reference count the network namespace of kernel sockets.

Keep track of if a socket needs reference counting by adding a flag to
struct sock called sk_net_refcnt.

Update all of the callers of sock_create_kern to stop using
sk_change_net and sk_release_kernel as those hacks are no longer
needed, to avoid reference counting a kernel socket.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/inet_common.h       |  2 +-
 include/net/sock.h              |  2 ++
 net/core/sock.c                 |  8 ++++++--
 net/ipv4/af_inet.c              |  4 +---
 net/ipv4/udp_tunnel.c           |  8 +++-----
 net/ipv6/ip6_udp_tunnel.c       |  6 ++----
 net/l2tp/l2tp_core.c            | 15 ++++++---------
 net/netfilter/ipvs/ip_vs_sync.c | 30 +++++++++---------------------
 8 files changed, 30 insertions(+), 45 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 4a92423eefa5..279f83591971 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -41,7 +41,7 @@ int inet_recv_error(struct sock *sk, struct msghdr *msg, int len,
 
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
-	sk_release_kernel(sk);
+	sock_release(sk->sk_socket);
 }
 
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index d8dcf91732b0..9e6b2c0b4741 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -184,6 +184,7 @@ struct sock_common {
 	unsigned char		skc_reuse:4;
 	unsigned char		skc_reuseport:1;
 	unsigned char		skc_ipv6only:1;
+	unsigned char		skc_net_refcnt:1;
 	int			skc_bound_dev_if;
 	union {
 		struct hlist_node	skc_bind_node;
@@ -323,6 +324,7 @@ struct sock {
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_reuseport		__sk_common.skc_reuseport
 #define sk_ipv6only		__sk_common.skc_ipv6only
+#define sk_net_refcnt		__sk_common.skc_net_refcnt
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
diff --git a/net/core/sock.c b/net/core/sock.c
index cbc3789b830c..9e8968e9ebeb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1412,7 +1412,10 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		 */
 		sk->sk_prot = sk->sk_prot_creator = prot;
 		sock_lock_init(sk);
-		sock_net_set(sk, get_net(net));
+		sk->sk_net_refcnt = kern ? 0 : 1;
+		if (likely(sk->sk_net_refcnt))
+			get_net(net);
+		sock_net_set(sk, net);
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
@@ -1446,7 +1449,8 @@ static void __sk_free(struct sock *sk)
 	if (sk->sk_peer_cred)
 		put_cred(sk->sk_peer_cred);
 	put_pid(sk->sk_peer_pid);
-	put_net(sock_net(sk));
+	if (likely(sk->sk_net_refcnt))
+		put_net(sock_net(sk));
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e2dd9cb99d61..235d36afece3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1430,7 +1430,7 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 struct net *net)
 {
 	struct socket *sock;
-	int rc = sock_create_kern(&init_net, family, type, protocol, &sock);
+	int rc = sock_create_kern(net, family, type, protocol, &sock);
 
 	if (rc == 0) {
 		*sk = sock->sk;
@@ -1440,8 +1440,6 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 		 * we do not wish this socket to see incoming packets.
 		 */
 		(*sk)->sk_prot->unhash(*sk);
-
-		sk_change_net(*sk, net);
 	}
 	return rc;
 }
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 4e2837476967..933ea903f7b8 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -15,12 +15,10 @@ int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 	struct socket *sock = NULL;
 	struct sockaddr_in udp_addr;
 
-	err = sock_create_kern(&init_net, AF_INET, SOCK_DGRAM, 0, &sock);
+	err = sock_create_kern(net, AF_INET, SOCK_DGRAM, 0, &sock);
 	if (err < 0)
 		goto error;
 
-	sk_change_net(sock->sk, net);
-
 	udp_addr.sin_family = AF_INET;
 	udp_addr.sin_addr = cfg->local_ip;
 	udp_addr.sin_port = cfg->local_udp_port;
@@ -47,7 +45,7 @@ int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 error:
 	if (sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sock->sk);
+		sock_release(sock);
 	}
 	*sockp = NULL;
 	return err;
@@ -101,7 +99,7 @@ void udp_tunnel_sock_release(struct socket *sock)
 {
 	rcu_assign_sk_user_data(sock->sk, NULL);
 	kernel_sock_shutdown(sock, SHUT_RDWR);
-	sk_release_kernel(sock->sk);
+	sock_release(sock);
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_sock_release);
 
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index 478576b61214..e1a1136bda7c 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -19,12 +19,10 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 	int err;
 	struct socket *sock = NULL;
 
-	err = sock_create_kern(&init_net, AF_INET6, SOCK_DGRAM, 0, &sock);
+	err = sock_create_kern(net, AF_INET6, SOCK_DGRAM, 0, &sock);
 	if (err < 0)
 		goto error;
 
-	sk_change_net(sock->sk, net);
-
 	udp6_addr.sin6_family = AF_INET6;
 	memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
 	       sizeof(udp6_addr.sin6_addr));
@@ -55,7 +53,7 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 error:
 	if (sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sock->sk);
+		sock_release(sock);
 	}
 	*sockp = NULL;
 	return err;
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ae513a2fe7f3..f6b090df3930 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1334,9 +1334,10 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 		if (sock)
 			inet_shutdown(sock, 2);
 	} else {
-		if (sock)
+		if (sock) {
 			kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sk);
+			sock_release(sock);
+		}
 	}
 
 	l2tp_tunnel_sock_put(sk);
@@ -1399,13 +1400,11 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		if (cfg->local_ip6 && cfg->peer_ip6) {
 			struct sockaddr_l2tpip6 ip6_addr = {0};
 
-			err = sock_create_kern(&init_net, AF_INET6, SOCK_DGRAM,
+			err = sock_create_kern(net, AF_INET6, SOCK_DGRAM,
 					  IPPROTO_L2TP, &sock);
 			if (err < 0)
 				goto out;
 
-			sk_change_net(sock->sk, net);
-
 			ip6_addr.l2tp_family = AF_INET6;
 			memcpy(&ip6_addr.l2tp_addr, cfg->local_ip6,
 			       sizeof(ip6_addr.l2tp_addr));
@@ -1429,13 +1428,11 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		{
 			struct sockaddr_l2tpip ip_addr = {0};
 
-			err = sock_create_kern(&init_net, AF_INET, SOCK_DGRAM,
+			err = sock_create_kern(net, AF_INET, SOCK_DGRAM,
 					  IPPROTO_L2TP, &sock);
 			if (err < 0)
 				goto out;
 
-			sk_change_net(sock->sk, net);
-
 			ip_addr.l2tp_family = AF_INET;
 			ip_addr.l2tp_addr = cfg->local_ip;
 			ip_addr.l2tp_conn_id = tunnel_id;
@@ -1462,7 +1459,7 @@ out:
 	*sockp = sock;
 	if ((err < 0) && sock) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
-		sk_release_kernel(sock->sk);
+		sock_release(sock);
 		*sockp = NULL;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2e9a5b5d1239..b08ba9538d12 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1457,18 +1457,12 @@ static struct socket *make_send_sock(struct net *net, int id)
 	struct socket *sock;
 	int result;
 
-	/* First create a socket move it to right name space later */
-	result = sock_create_kern(&init_net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	/* First create a socket */
+	result = sock_create_kern(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-	/*
-	 * Kernel sockets that are a part of a namespace, should not
-	 * hold a reference to a namespace in order to allow to stop it.
-	 * After sk_change_net should be released using sk_release_kernel.
-	 */
-	sk_change_net(sock->sk, net);
 	result = set_mcast_if(sock->sk, ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
@@ -1497,7 +1491,7 @@ static struct socket *make_send_sock(struct net *net, int id)
 	return sock;
 
 error:
-	sk_release_kernel(sock->sk);
+	sock_release(sock);
 	return ERR_PTR(result);
 }
 
@@ -1518,17 +1512,11 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	int result;
 
 	/* First create a socket */
-	result = sock_create_kern(&init_net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = sock_create_kern(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-	/*
-	 * Kernel sockets that are a part of a namespace, should not
-	 * hold a reference to a namespace in order to allow to stop it.
-	 * After sk_change_net should be released using sk_release_kernel.
-	 */
-	sk_change_net(sock->sk, net);
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = SK_CAN_REUSE;
 	result = sysctl_sync_sock_size(ipvs);
@@ -1554,7 +1542,7 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	return sock;
 
 error:
-	sk_release_kernel(sock->sk);
+	sock_release(sock);
 	return ERR_PTR(result);
 }
 
@@ -1692,7 +1680,7 @@ done:
 		ip_vs_sync_buff_release(sb);
 
 	/* release the sending multicast socket */
-	sk_release_kernel(tinfo->sock->sk);
+	sock_release(tinfo->sock);
 	kfree(tinfo);
 
 	return 0;
@@ -1729,7 +1717,7 @@ static int sync_thread_backup(void *data)
 	}
 
 	/* release the sending multicast socket */
-	sk_release_kernel(tinfo->sock->sk);
+	sock_release(tinfo->sock);
 	kfree(tinfo->buf);
 	kfree(tinfo);
 
@@ -1854,11 +1842,11 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	return 0;
 
 outsocket:
-	sk_release_kernel(sock->sk);
+	sock_release(sock);
 
 outtinfo:
 	if (tinfo) {
-		sk_release_kernel(tinfo->sock->sk);
+		sock_release(tinfo->sock);
 		kfree(tinfo->buf);
 		kfree(tinfo);
 	}
-- 
2.2.1
