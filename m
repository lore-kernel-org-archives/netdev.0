From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 09/10] caif: Bugfix debugfs directory name must be unique.
Date: Fri, 13 May 2011 14:44:07 +0200
Message-ID: <1305290648-9613-10-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:52862 "EHLO
	slow1.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759213Ab1EMNBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:01:02 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow1.isp.as2116.net (Postfix) with ESMTP id 34C8880157
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:17 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Race condition caused debugfs_create_dir() to fail due to duplicate
name. Use atomic counter to create unique directory name.

net_ratelimit() is introduced to limit debug printouts.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   34 ++++++++++++++++++++++------------
 1 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 7baae11..5cf9c73 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -48,6 +48,7 @@ static struct dentry *debugfsdir;
 #ifdef CONFIG_DEBUG_FS
 struct debug_fs_counter {
 	atomic_t caif_nr_socks;
+	atomic_t caif_sock_create;
 	atomic_t num_connect_req;
 	atomic_t num_connect_resp;
 	atomic_t num_connect_fail_resp;
@@ -59,11 +60,11 @@ struct debug_fs_counter {
 	atomic_t num_rx_flow_on;
 };
 static struct debug_fs_counter cnt;
-#define	dbfs_atomic_inc(v) atomic_inc(v)
-#define	dbfs_atomic_dec(v) atomic_dec(v)
+#define	dbfs_atomic_inc(v) atomic_inc_return(v)
+#define	dbfs_atomic_dec(v) atomic_dec_return(v)
 #else
-#define	dbfs_atomic_inc(v)
-#define	dbfs_atomic_dec(v)
+#define	dbfs_atomic_inc(v) 0
+#define	dbfs_atomic_dec(v) 0
 #endif
=20
 struct caifsock {
@@ -155,9 +156,10 @@ static int caif_queue_rcv_skb(struct sock *sk, str=
uct sk_buff *skb)
=20
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
 		(unsigned)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
-		pr_debug("sending flow OFF (queue len =3D %d %d)\n",
-			atomic_read(&cf_sk->sk.sk_rmem_alloc),
-			sk_rcvbuf_lowwater(cf_sk));
+		if (net_ratelimit())
+			pr_debug("sending flow OFF (queue len =3D %d %d)\n",
+					atomic_read(&cf_sk->sk.sk_rmem_alloc),
+					sk_rcvbuf_lowwater(cf_sk));
 		set_rx_flow_off(cf_sk);
 		dbfs_atomic_inc(&cnt.num_rx_flow_off);
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
@@ -168,7 +170,8 @@ static int caif_queue_rcv_skb(struct sock *sk, stru=
ct sk_buff *skb)
 		return err;
 	if (!sk_rmem_schedule(sk, skb->truesize) && rx_flow_is_on(cf_sk)) {
 		set_rx_flow_off(cf_sk);
-		pr_debug("sending flow OFF due to rmem_schedule\n");
+		if (net_ratelimit())
+			pr_debug("sending flow OFF due to rmem_schedule\n");
 		dbfs_atomic_inc(&cnt.num_rx_flow_off);
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
@@ -838,7 +841,7 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uaddr,
 	sock->state =3D SS_CONNECTING;
 	sk->sk_state =3D CAIF_CONNECTING;
=20
-	/* Check priority value coming from socket */
+	/* Check priority value comming from socket */
 	/* if priority value is out of range it will be ajusted */
 	if (cf_sk->sk.sk_priority > CAIF_PRIO_MAX)
 		cf_sk->conn_req.priority =3D CAIF_PRIO_MAX;
@@ -942,6 +945,7 @@ static int caif_release(struct socket *sock)
=20
 	dbfs_atomic_inc(&cnt.num_disconnect);
=20
+	WARN_ON(IS_ERR(cf_sk->debugfs_socket_dir));
 	if (cf_sk->debugfs_socket_dir !=3D NULL)
 		debugfs_remove_recursive(cf_sk->debugfs_socket_dir);
=20
@@ -1047,7 +1051,7 @@ static void caif_sock_destructor(struct sock *sk)
 	caif_assert(sk_unhashed(sk));
 	caif_assert(!sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		pr_info("Attempt to release alive CAIF socket: %p\n", sk);
+		pr_debug("Attempt to release alive CAIF socket: %p\n", sk);
 		return;
 	}
 	sk_stream_kill_queues(&cf_sk->sk);
@@ -1058,6 +1062,7 @@ static void caif_sock_destructor(struct sock *sk)
 static int caif_create(struct net *net, struct socket *sock, int proto=
col,
 			int kern)
 {
+	int num;
 	struct sock *sk =3D NULL;
 	struct caifsock *cf_sk =3D NULL;
 	static struct proto prot =3D {.name =3D "PF_CAIF",
@@ -1120,14 +1125,16 @@ static int caif_create(struct net *net, struct =
socket *sock, int protocol,
 	cf_sk->conn_req.protocol =3D protocol;
 	/* Increase the number of sockets created. */
 	dbfs_atomic_inc(&cnt.caif_nr_socks);
+	num =3D dbfs_atomic_inc(&cnt.caif_sock_create);
 #ifdef CONFIG_DEBUG_FS
 	if (!IS_ERR(debugfsdir)) {
+
 		/* Fill in some information concerning the misc socket. */
-		snprintf(cf_sk->name, sizeof(cf_sk->name), "cfsk%d",
-				atomic_read(&cnt.caif_nr_socks));
+		snprintf(cf_sk->name, sizeof(cf_sk->name), "cfsk%d", num);
=20
 		cf_sk->debugfs_socket_dir =3D
 			debugfs_create_dir(cf_sk->name, debugfsdir);
+
 		debugfs_create_u32("sk_state", S_IRUSR | S_IWUSR,
 				cf_sk->debugfs_socket_dir,
 				(u32 *) &cf_sk->sk.sk_state);
@@ -1171,6 +1178,9 @@ static int __init caif_sktinit_module(void)
 		debugfs_create_u32("num_sockets", S_IRUSR | S_IWUSR,
 				debugfsdir,
 				(u32 *) &cnt.caif_nr_socks);
+		debugfs_create_u32("num_create", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.caif_sock_create);
 		debugfs_create_u32("num_connect_req", S_IRUSR | S_IWUSR,
 				debugfsdir,
 				(u32 *) &cnt.num_connect_req);
--=20
1.7.1

