From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 1/3] caif: Kill debugfs vars for caif socket
Date: Fri,  3 Feb 2012 15:36:19 +0100
Message-ID: <1328279781-4745-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:58158 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756484Ab2BCOgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 09:36:38 -0500
Received: by lagu2 with SMTP id u2so1877407lag.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 06:36:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kill off the debug-fs exposed varaibles from caif_socket.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |  113 +---------------------------------------=
--------
 1 files changed, 1 insertions(+), 112 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index a97d97a..5016fa5 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -43,34 +43,9 @@ enum caif_states {
 #define TX_FLOW_ON_BIT	1
 #define RX_FLOW_ON_BIT	2
=20
-static struct dentry *debugfsdir;
-
-#ifdef CONFIG_DEBUG_FS
-struct debug_fs_counter {
-	atomic_t caif_nr_socks;
-	atomic_t caif_sock_create;
-	atomic_t num_connect_req;
-	atomic_t num_connect_resp;
-	atomic_t num_connect_fail_resp;
-	atomic_t num_disconnect;
-	atomic_t num_remote_shutdown_ind;
-	atomic_t num_tx_flow_off_ind;
-	atomic_t num_tx_flow_on_ind;
-	atomic_t num_rx_flow_off;
-	atomic_t num_rx_flow_on;
-};
-static struct debug_fs_counter cnt;
-#define	dbfs_atomic_inc(v) atomic_inc_return(v)
-#define	dbfs_atomic_dec(v) atomic_dec_return(v)
-#else
-#define	dbfs_atomic_inc(v) 0
-#define	dbfs_atomic_dec(v) 0
-#endif
-
 struct caifsock {
 	struct sock sk; /* must be first member */
 	struct cflayer layer;
-	char name[CAIF_LAYER_NAME_SZ]; /* Used for debugging */
 	u32 flow_state;
 	struct caif_connect_request conn_req;
 	struct mutex readlock;
@@ -161,7 +136,6 @@ static int caif_queue_rcv_skb(struct sock *sk, stru=
ct sk_buff *skb)
 					atomic_read(&cf_sk->sk.sk_rmem_alloc),
 					sk_rcvbuf_lowwater(cf_sk));
 		set_rx_flow_off(cf_sk);
-		dbfs_atomic_inc(&cnt.num_rx_flow_off);
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
=20
@@ -172,7 +146,6 @@ static int caif_queue_rcv_skb(struct sock *sk, stru=
ct sk_buff *skb)
 		set_rx_flow_off(cf_sk);
 		if (net_ratelimit())
 			pr_debug("sending flow OFF due to rmem_schedule\n");
-		dbfs_atomic_inc(&cnt.num_rx_flow_off);
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
 	skb->dev =3D NULL;
@@ -233,14 +206,12 @@ static void caif_ctrl_cb(struct cflayer *layr,
 	switch (flow) {
 	case CAIF_CTRLCMD_FLOW_ON_IND:
 		/* OK from modem to start sending again */
-		dbfs_atomic_inc(&cnt.num_tx_flow_on_ind);
 		set_tx_flow_on(cf_sk);
 		cf_sk->sk.sk_state_change(&cf_sk->sk);
 		break;
=20
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
 		/* Modem asks us to shut up */
-		dbfs_atomic_inc(&cnt.num_tx_flow_off_ind);
 		set_tx_flow_off(cf_sk);
 		cf_sk->sk.sk_state_change(&cf_sk->sk);
 		break;
@@ -249,7 +220,6 @@ static void caif_ctrl_cb(struct cflayer *layr,
 		/* We're now connected */
 		caif_client_register_refcnt(&cf_sk->layer,
 						cfsk_hold, cfsk_put);
-		dbfs_atomic_inc(&cnt.num_connect_resp);
 		cf_sk->sk.sk_state =3D CAIF_CONNECTED;
 		set_tx_flow_on(cf_sk);
 		cf_sk->sk.sk_state_change(&cf_sk->sk);
@@ -263,7 +233,6 @@ static void caif_ctrl_cb(struct cflayer *layr,
=20
 	case CAIF_CTRLCMD_INIT_FAIL_RSP:
 		/* Connect request failed */
-		dbfs_atomic_inc(&cnt.num_connect_fail_resp);
 		cf_sk->sk.sk_err =3D ECONNREFUSED;
 		cf_sk->sk.sk_state =3D CAIF_DISCONNECTED;
 		cf_sk->sk.sk_shutdown =3D SHUTDOWN_MASK;
@@ -277,7 +246,6 @@ static void caif_ctrl_cb(struct cflayer *layr,
=20
 	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
 		/* Modem has closed this connection, or device is down. */
-		dbfs_atomic_inc(&cnt.num_remote_shutdown_ind);
 		cf_sk->sk.sk_shutdown =3D SHUTDOWN_MASK;
 		cf_sk->sk.sk_err =3D ECONNRESET;
 		set_rx_flow_on(cf_sk);
@@ -297,7 +265,6 @@ static void caif_check_flow_release(struct sock *sk=
)
 		return;
=20
 	if (atomic_read(&sk->sk_rmem_alloc) <=3D sk_rcvbuf_lowwater(cf_sk)) {
-			dbfs_atomic_inc(&cnt.num_rx_flow_on);
 			set_rx_flow_on(cf_sk);
 			caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_ON_REQ);
 	}
@@ -856,7 +823,6 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uaddr,
 	/*ifindex =3D id of the interface.*/
 	cf_sk->conn_req.ifindex =3D cf_sk->sk.sk_bound_dev_if;
=20
-	dbfs_atomic_inc(&cnt.num_connect_req);
 	cf_sk->layer.receive =3D caif_sktrecv_cb;
=20
 	err =3D caif_connect_client(sock_net(sk), &cf_sk->conn_req,
@@ -945,8 +911,6 @@ static int caif_release(struct socket *sock)
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	sock->sk =3D NULL;
=20
-	dbfs_atomic_inc(&cnt.num_disconnect);
-
 	WARN_ON(IS_ERR(cf_sk->debugfs_socket_dir));
 	if (cf_sk->debugfs_socket_dir !=3D NULL)
 		debugfs_remove_recursive(cf_sk->debugfs_socket_dir);
@@ -1054,14 +1018,12 @@ static void caif_sock_destructor(struct sock *s=
k)
 		return;
 	}
 	sk_stream_kill_queues(&cf_sk->sk);
-	dbfs_atomic_dec(&cnt.caif_nr_socks);
 	caif_free_client(&cf_sk->layer);
 }
=20
 static int caif_create(struct net *net, struct socket *sock, int proto=
col,
 			int kern)
 {
-	int num;
 	struct sock *sk =3D NULL;
 	struct caifsock *cf_sk =3D NULL;
 	static struct proto prot =3D {.name =3D "PF_CAIF",
@@ -1122,34 +1084,6 @@ static int caif_create(struct net *net, struct s=
ocket *sock, int protocol,
 	cf_sk->sk.sk_priority =3D CAIF_PRIO_NORMAL;
 	cf_sk->conn_req.link_selector =3D CAIF_LINK_LOW_LATENCY;
 	cf_sk->conn_req.protocol =3D protocol;
-	/* Increase the number of sockets created. */
-	dbfs_atomic_inc(&cnt.caif_nr_socks);
-	num =3D dbfs_atomic_inc(&cnt.caif_sock_create);
-#ifdef CONFIG_DEBUG_FS
-	if (!IS_ERR(debugfsdir)) {
-
-		/* Fill in some information concerning the misc socket. */
-		snprintf(cf_sk->name, sizeof(cf_sk->name), "cfsk%d", num);
-
-		cf_sk->debugfs_socket_dir =3D
-			debugfs_create_dir(cf_sk->name, debugfsdir);
-
-		debugfs_create_u32("sk_state", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir,
-				(u32 *) &cf_sk->sk.sk_state);
-		debugfs_create_u32("flow_state", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir, &cf_sk->flow_state);
-		debugfs_create_u32("sk_rmem_alloc", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir,
-				(u32 *) &cf_sk->sk.sk_rmem_alloc);
-		debugfs_create_u32("sk_wmem_alloc", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir,
-				(u32 *) &cf_sk->sk.sk_wmem_alloc);
-		debugfs_create_u32("identity", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir,
-				(u32 *) &cf_sk->layer.id);
-	}
-#endif
 	release_sock(&cf_sk->sk);
 	return 0;
 }
@@ -1161,7 +1095,7 @@ static struct net_proto_family caif_family_ops =3D=
 {
 	.owner =3D THIS_MODULE,
 };
=20
-static int af_caif_init(void)
+static int __init caif_sktinit_module(void)
 {
 	int err =3D sock_register(&caif_family_ops);
 	if (!err)
@@ -1169,54 +1103,9 @@ static int af_caif_init(void)
 	return 0;
 }
=20
-static int __init caif_sktinit_module(void)
-{
-#ifdef CONFIG_DEBUG_FS
-	debugfsdir =3D debugfs_create_dir("caif_sk", NULL);
-	if (!IS_ERR(debugfsdir)) {
-		debugfs_create_u32("num_sockets", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.caif_nr_socks);
-		debugfs_create_u32("num_create", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.caif_sock_create);
-		debugfs_create_u32("num_connect_req", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_connect_req);
-		debugfs_create_u32("num_connect_resp", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_connect_resp);
-		debugfs_create_u32("num_connect_fail_resp", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_connect_fail_resp);
-		debugfs_create_u32("num_disconnect", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_disconnect);
-		debugfs_create_u32("num_remote_shutdown_ind",
-				S_IRUSR | S_IWUSR, debugfsdir,
-				(u32 *) &cnt.num_remote_shutdown_ind);
-		debugfs_create_u32("num_tx_flow_off_ind", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_tx_flow_off_ind);
-		debugfs_create_u32("num_tx_flow_on_ind", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_tx_flow_on_ind);
-		debugfs_create_u32("num_rx_flow_off", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_rx_flow_off);
-		debugfs_create_u32("num_rx_flow_on", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_rx_flow_on);
-	}
-#endif
-	return af_caif_init();
-}
-
 static void __exit caif_sktexit_module(void)
 {
 	sock_unregister(PF_CAIF);
-	if (debugfsdir !=3D NULL)
-		debugfs_remove_recursive(debugfsdir);
 }
 module_init(caif_sktinit_module);
 module_exit(caif_sktexit_module);
--=20
1.7.5.4
