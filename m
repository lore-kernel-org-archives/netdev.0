From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/11] [NET] Convert sk_zapped into SOCK_ZAPPED flag
Date: Wed, 9 Mar 2005 20:47:12 +0100
Message-ID: <20050309194711.GJ31837@postel.suug.ch>
References: <20050309194521.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050309194521.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc4.orig/include/net/sock.h linux-2.6.11-rc4/include/net/sock.h
--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-08 18:11:24.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-08 23:56:08.000000000 +0100
@@ -115,7 +115,6 @@
 /**
   *	struct sock - network layer representation of sockets
   *	@__sk_common - shared layout with tcp_tw_bucket
-  *	@sk_zapped - ax25 & ipx means !linked
   *	@sk_shutdown - mask of %SEND_SHUTDOWN and/or %RCV_SHUTDOWN
   *	@sk_use_write_queue - wheter to call sk->sk_write_space in sock_wfree
   *	@sk_userlocks - %SO_SNDBUF and %SO_RCVBUF settings
@@ -191,7 +190,6 @@
 #define sk_node			__sk_common.skc_node
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_refcnt		__sk_common.skc_refcnt
-	volatile unsigned char	sk_zapped;
 	unsigned char		sk_shutdown;
 	unsigned char		sk_use_write_queue;
 	unsigned char		sk_userlocks;
@@ -391,6 +389,7 @@
 	SOCK_DESTROY,
 	SOCK_BROADCAST,
 	SOCK_TIMESTAMP,
+	SOCK_ZAPPED,
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
diff -Nru linux-2.6.11-rc4.orig/net/appletalk/ddp.c linux-2.6.11-rc4/net/appletalk/ddp.c
--- linux-2.6.11-rc4.orig/net/appletalk/ddp.c	2005-03-08 18:11:29.000000000 +0100
+++ linux-2.6.11-rc4/net/appletalk/ddp.c	2005-03-08 23:51:06.000000000 +0100
@@ -1041,7 +1041,7 @@
 	sk_set_owner(sk, THIS_MODULE);
 
 	/* Checksums on by default */
-	sk->sk_zapped = 1;
+	sock_set_flag(sk, SOCK_ZAPPED);
 out:
 	return rc;
 }
@@ -1120,7 +1120,7 @@
 
 	n = atalk_pick_and_bind_port(sk, &sat);
 	if (!n)
-		sk->sk_zapped = 0;
+		sock_reset_flag(sk, SOCK_ZAPPED);
 out:
 	return n;
 }
@@ -1132,7 +1132,8 @@
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
 
-	if (!sk->sk_zapped || addr_len != sizeof(struct sockaddr_at))
+	if (!sock_flag(sk, SOCK_ZAPPED) ||
+	    addr_len != sizeof(struct sockaddr_at))
 		return -EINVAL;
 
 	if (addr->sat_family != AF_APPLETALK)
@@ -1167,7 +1168,7 @@
 			return -EADDRINUSE;
 	}
 
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	return 0;
 }
 
@@ -1202,7 +1203,7 @@
 #endif			
 	}
 
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		if (atalk_autobind(sk) < 0)
 			return -EBUSY;
 
@@ -1229,7 +1230,7 @@
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
 
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		if (atalk_autobind(sk) < 0)
 			return -ENOBUFS;
 
@@ -1551,7 +1552,7 @@
 		return -EMSGSIZE;
 
 	if (usat) {
-		if (sk->sk_zapped)
+		if (sock_flag(sk, SOCK_ZAPPED))
 			if (atalk_autobind(sk) < 0)
 				return -EBUSY;
 
diff -Nru linux-2.6.11-rc4.orig/net/ax25/af_ax25.c linux-2.6.11-rc4/net/ax25/af_ax25.c
--- linux-2.6.11-rc4.orig/net/ax25/af_ax25.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ax25/af_ax25.c	2005-03-08 23:51:06.000000000 +0100
@@ -871,7 +871,9 @@
 	sk->sk_debug    = osk->sk_debug;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
-	sk->sk_zapped   = osk->sk_zapped;
+
+	if (sock_flag(osk, SOCK_ZAPPED))
+		sock_set_flag(sk, SOCK_ZAPPED);
 
 	oax25 = ax25_sk(osk);
 
@@ -1025,7 +1027,7 @@
 	lock_sock(sk);
 
 	ax25 = ax25_sk(sk);
-	if (!sk->sk_zapped) {
+	if (!sock_flag(sk, SOCK_ZAPPED)) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -1059,7 +1061,7 @@
 
 done:
 	ax25_cb_add(ax25);
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 
 out:
 	release_sock(sk);
@@ -1172,7 +1174,7 @@
 	 *	the socket is already bound, check to see if the device has
 	 *	been filled in, error if it hasn't.
 	 */
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		/* check if we can remove this feature. It is broken. */
 		printk(KERN_WARNING "ax25_connect(): %s uses autobind, please contact jreuter@yaina.de\n",
 			current->comm);
@@ -1420,7 +1422,7 @@
 	lock_sock(sk);
 	ax25 = ax25_sk(sk);
 
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED))
 		err = -EADDRNOTAVAIL;
 		goto out;
 	}
diff -Nru linux-2.6.11-rc4.orig/net/ax25/ax25_route.c linux-2.6.11-rc4/net/ax25/ax25_route.c
--- linux-2.6.11-rc4.orig/net/ax25/ax25_route.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ax25/ax25_route.c	2005-03-08 23:51:06.000000000 +0100
@@ -455,7 +455,7 @@
 
 	if (ax25->sk != NULL) {
 		bh_lock_sock(ax25->sk);
-		ax25->sk->sk_zapped = 0;
+		sock_reset_flag(ax25->sk, SOCK_ZAPPED);
 		bh_unlock_sock(ax25->sk);
 	}
 
diff -Nru linux-2.6.11-rc4.orig/net/bluetooth/af_bluetooth.c linux-2.6.11-rc4/net/bluetooth/af_bluetooth.c
--- linux-2.6.11-rc4.orig/net/bluetooth/af_bluetooth.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/bluetooth/af_bluetooth.c	2005-03-08 23:51:06.000000000 +0100
@@ -130,7 +130,7 @@
 	sock_init_data(sock, sk);
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 
-	sk->sk_zapped   = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	sk->sk_protocol = proto;
 	sk->sk_state    = BT_OPEN;
 
diff -Nru linux-2.6.11-rc4.orig/net/bluetooth/l2cap.c linux-2.6.11-rc4/net/bluetooth/l2cap.c
--- linux-2.6.11-rc4.orig/net/bluetooth/l2cap.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/bluetooth/l2cap.c	2005-03-08 23:51:06.000000000 +0100
@@ -280,7 +280,7 @@
 		l2cap_sock_close(sk);
 
 	parent->sk_state  = BT_CLOSED;
-	parent->sk_zapped = 1;
+	sock_set_flag(parent, SOCK_ZAPPED);
 }
 
 /* Kill socket (only if zapped and orphan)
@@ -288,7 +288,7 @@
  */
 static void l2cap_sock_kill(struct sock *sk)
 {
-	if (!sk->sk_zapped || sk->sk_socket)
+	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
 	BT_DBG("sk %p state %d", sk, sk->sk_state);
@@ -333,7 +333,7 @@
 		break;
 
 	default:
-		sk->sk_zapped = 1;
+		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
 	}
 }
@@ -1062,7 +1062,7 @@
 	}
 
 	sk->sk_state  = BT_CLOSED;
-	sk->sk_zapped = 1;
+	sock_set_flag(sk, SOCK_ZAPPED);
 
 	if (err)
 		sk->sk_err = err;
@@ -1424,7 +1424,7 @@
 	/* Check if we already have channel with that dcid */
 	if (__l2cap_get_chan_by_dcid(list, scid)) {
 		write_unlock(&list->lock);
-		sk->sk_zapped = 1;
+		sock_set_flag(sk, SOCK_ZAPPED);
 		l2cap_sock_kill(sk);
 		goto response;
 	}
diff -Nru linux-2.6.11-rc4.orig/net/bluetooth/rfcomm/sock.c linux-2.6.11-rc4/net/bluetooth/rfcomm/sock.c
--- linux-2.6.11-rc4.orig/net/bluetooth/rfcomm/sock.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/bluetooth/rfcomm/sock.c	2005-03-08 23:51:06.000000000 +0100
@@ -105,7 +105,7 @@
 	parent = bt_sk(sk)->parent;
 	if (parent) {
 		if (d->state == BT_CLOSED) {
-			sk->sk_zapped = 1;
+			sock_set_flag(sk, SOCK_ZAPPED);
 			bt_accept_unlink(sk);
 		}
 		parent->sk_data_ready(parent, 0);
@@ -117,7 +117,7 @@
 
 	bh_unlock_sock(sk);
 
-	if (parent && sk->sk_zapped) {
+	if (parent && sock_flag(sk, SOCK_ZAPPED)) {
 		/* We have to drop DLC lock here, otherwise
 		 * rfcomm_sock_destruct() will dead lock. */
 		rfcomm_dlc_unlock(d);
@@ -214,7 +214,7 @@
 	}
 
 	parent->sk_state  = BT_CLOSED;
-	parent->sk_zapped = 1;
+	sock_set_flag(parent, SOCK_ZAPPED);
 }
 
 /* Kill socket (only if zapped and orphan)
@@ -222,7 +222,7 @@
  */
 static void rfcomm_sock_kill(struct sock *sk)
 {
-	if (!sk->sk_zapped || sk->sk_socket)
+	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
 	BT_DBG("sk %p state %d refcnt %d", sk, sk->sk_state, atomic_read(&sk->sk_refcnt));
@@ -251,7 +251,7 @@
 		rfcomm_dlc_close(d, 0);
 
 	default:
-		sk->sk_zapped = 1;
+		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
 	}
 }
diff -Nru linux-2.6.11-rc4.orig/net/bluetooth/sco.c linux-2.6.11-rc4/net/bluetooth/sco.c
--- linux-2.6.11-rc4.orig/net/bluetooth/sco.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/bluetooth/sco.c	2005-03-08 23:51:06.000000000 +0100
@@ -352,7 +352,7 @@
 	}
 
 	parent->sk_state  = BT_CLOSED;
-	parent->sk_zapped = 1;
+	sock_set_flag(sk, SOCK_ZAPPED);
 }
 
 /* Kill socket (only if zapped and orphan)
@@ -360,7 +360,7 @@
  */
 static void sco_sock_kill(struct sock *sk)
 {
-	if (!sk->sk_zapped || sk->sk_socket)
+	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
 		return;
 
 	BT_DBG("sk %p state %d", sk, sk->sk_state);
@@ -399,7 +399,7 @@
 		break;
 
 	default:
-		sk->sk_zapped = 1;
+		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
 	};
 
@@ -778,7 +778,7 @@
 	sk->sk_err   = err;
 	sk->sk_state_change(sk);
 
-	sk->sk_zapped = 1;
+	sock_set_flag(sk, SOCK_ZAPPED);
 }
 
 static void sco_conn_ready(struct sco_conn *conn)
diff -Nru linux-2.6.11-rc4.orig/net/core/sock.c linux-2.6.11-rc4/net/core/sock.c
--- linux-2.6.11-rc4.orig/net/core/sock.c	2005-03-08 18:11:27.000000000 +0100
+++ linux-2.6.11-rc4/net/core/sock.c	2005-03-08 23:51:06.000000000 +0100
@@ -1186,9 +1186,10 @@
 	sk->sk_rcvbuf		=	sysctl_rmem_default;
 	sk->sk_sndbuf		=	sysctl_wmem_default;
 	sk->sk_state		=	TCP_CLOSE;
-	sk->sk_zapped		=	1;
 	sk->sk_socket		=	sock;
 
+	sock_set_flag(sk, SOCK_ZAPPED);
+
 	if(sock)
 	{
 		sk->sk_type	=	sock->type;
diff -Nru linux-2.6.11-rc4.orig/net/decnet/af_decnet.c linux-2.6.11-rc4/net/decnet/af_decnet.c
--- linux-2.6.11-rc4.orig/net/decnet/af_decnet.c	2005-03-08 18:11:29.000000000 +0100
+++ linux-2.6.11-rc4/net/decnet/af_decnet.c	2005-03-08 23:51:06.000000000 +0100
@@ -750,14 +750,13 @@
 
 	rv = -EINVAL;
 	lock_sock(sk);
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		memcpy(&scp->addr, saddr, addr_len);
-		sk->sk_zapped = 0;
+		sock_reset_flag(sk, SOCK_ZAPPED);
 
 		rv = dn_hash_sock(sk);
-		if (rv) {
-			sk->sk_zapped = 1;
-		}
+		if (rv)
+			sock_set_flag(sk, SOCK_ZAPPED);
 	}
 	release_sock(sk);
 
@@ -771,7 +770,7 @@
 	struct dn_scp *scp = DN_SK(sk);
 	int rv;
 
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 
 	scp->addr.sdn_flags  = 0;
 	scp->addr.sdn_objnum = 0;
@@ -795,9 +794,8 @@
 	rv = dn_dev_bind_default((dn_address *)scp->addr.sdn_add.a_addr);
 	if (rv == 0) {
 		rv = dn_hash_sock(sk);
-		if (rv) {
-			sk->sk_zapped = 1;
-		}
+		if (rv)
+			sock_set_flag(sk, SOCK_ZAPPED);
 	}
 
 	return rv;
@@ -922,7 +920,7 @@
 	if (addr->sdn_flags & SDF_WILD)
 		goto out;
 
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		err = dn_auto_bind(sk->sk_socket);
 		if (err)
 			goto out;
@@ -1141,7 +1139,7 @@
 	lock_sock(newsk);
 	err = dn_hash_sock(newsk);
 	if (err == 0) {
-		newsk->sk_zapped = 0;
+		sock_reset_flag(newsk, SOCK_ZAPPED);
 		dn_send_conn_ack(newsk);
 
 		/*
@@ -1259,7 +1257,7 @@
 
 	lock_sock(sk);
 
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 
 	if ((DN_SK(sk)->state != DN_O) || (sk->sk_state == TCP_LISTEN))
@@ -1671,7 +1669,7 @@
 
 	lock_sock(sk);
 
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		rv = -EADDRNOTAVAIL;
 		goto out;
 	}
diff -Nru linux-2.6.11-rc4.orig/net/econet/af_econet.c linux-2.6.11-rc4/net/econet/af_econet.c
--- linux-2.6.11-rc4.orig/net/econet/af_econet.c	2005-03-08 18:11:29.000000000 +0100
+++ linux-2.6.11-rc4/net/econet/af_econet.c	2005-03-08 23:51:06.000000000 +0100
@@ -583,7 +583,7 @@
 	sk_set_owner(sk, THIS_MODULE);
 
 	eo = ec_sk(sk);
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	sk->sk_family = PF_ECONET;
 	eo->num = protocol;
 
diff -Nru linux-2.6.11-rc4.orig/net/ipx/af_ipx.c linux-2.6.11-rc4/net/ipx/af_ipx.c
--- linux-2.6.11-rc4.orig/net/ipx/af_ipx.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipx/af_ipx.c	2005-03-08 23:51:06.000000000 +0100
@@ -310,7 +310,7 @@
 		s->sk_error_report(s);
 		ipxs->intrfc = NULL;
 		ipxs->port   = 0;
-		s->sk_zapped = 1;	/* Indicates it is no longer bound */
+		sock_set_flag(s, SOCK_ZAPPED); /* Indicates it is no longer bound */
 		sk_del_node_init(s);
 	}
 	INIT_HLIST_HEAD(&intrfc->if_sklist);
@@ -1427,7 +1427,7 @@
 	struct sockaddr_ipx *addr = (struct sockaddr_ipx *)uaddr;
 	int rc = -EINVAL;
 
-	if (!sk->sk_zapped || addr_len != sizeof(struct sockaddr_ipx))
+	if (!sock_flag(sk, SOCK_ZAPPED) || addr_len != sizeof(struct sockaddr_ipx))
 		goto out;
 
 	intrfc = ipxitf_find_using_net(addr->sipx_network);
@@ -1505,7 +1505,7 @@
 #endif	/* CONFIG_IPX_INTERN */
 
 	ipxitf_insert_socket(intrfc, sk);
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 
 	rc = 0;
 out_put:
@@ -1774,7 +1774,7 @@
 	}
 	
 	rc = -ENOTCONN;
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
diff -Nru linux-2.6.11-rc4.orig/net/llc/af_llc.c linux-2.6.11-rc4/net/llc/af_llc.c
--- linux-2.6.11-rc4.orig/net/llc/af_llc.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/llc/af_llc.c	2005-03-08 23:51:06.000000000 +0100
@@ -180,7 +180,7 @@
 		llc->laddr.lsap, llc->daddr.lsap);
 	if (!llc_send_disc(sk))
 		llc_ui_wait_for_disc(sk, sk->sk_rcvtimeo);
-	if (!sk->sk_zapped)
+	if (!sock_flag(sk, SOCK_ZAPPED))
 		llc_sap_remove_socket(llc->sap, sk);
 	release_sock(sk);
 	if (llc->sap && hlist_empty(&llc->sap->sk_list.list)) {
@@ -248,7 +248,7 @@
 	struct llc_sap *sap;
 	int rc = -EINVAL;
 
-	if (!sk->sk_zapped)
+	if (!sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 	rc = -ENODEV;
 	llc->dev = dev_getfirstbyhwtype(addr->sllc_arphrd);
@@ -266,7 +266,8 @@
 	memcpy(&llc->addr, addr, sizeof(llc->addr));
 	/* assign new connection to its SAP */
 	llc_sap_add_socket(sap, sk);
-	rc = sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
+	rc = 0;
 out:
 	return rc;
 }
@@ -298,7 +299,7 @@
 	int rc = -EINVAL;
 
 	dprintk("%s: binding %02X\n", __FUNCTION__, addr->sllc_sap);
-	if (!sk->sk_zapped || addrlen != sizeof(*addr))
+	if (!sock_flag(sk, SOCK_ZAPPED) || addrlen != sizeof(*addr))
 		goto out;
 	rc = -EAFNOSUPPORT;
 	if (addr->sllc_family != AF_LLC)
@@ -339,7 +340,8 @@
 	memcpy(&llc->addr, addr, sizeof(llc->addr));
 	/* assign new connection to its SAP */
 	llc_sap_add_socket(sap, sk);
-	rc = sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
+	rc = 0;
 out:
 	return rc;
 }
@@ -406,7 +408,7 @@
 	if (addr->sllc_family != AF_LLC)
 		goto out;
 	/* bind connection to sap if user hasn't done it. */
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		/* bind to sap with null dev, exclusive */
 		rc = llc_ui_autobind(sock, addr);
 		if (rc)
@@ -459,7 +461,7 @@
 	if (sk->sk_type != SOCK_STREAM)
 		goto out;
 	rc = -EAGAIN;
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 	rc = 0;
 	if (!(unsigned)backlog)	/* BSDism */
@@ -638,7 +640,7 @@
 	newsk = skb->sk;
 	/* attach connection to a new socket. */
 	llc_ui_sk_init(newsock, newsk);
-	newsk->sk_zapped	= 0;
+	sock_reset_flag(newsk, SOCK_ZAPPED);
 	newsk->sk_state		= TCP_ESTABLISHED;
 	newsock->state		= SS_CONNECTED;
 	llc			= llc_sk(sk);
@@ -749,7 +751,7 @@
 		addr = &llc->addr;
 	}
 	/* must bind connection to sap if user hasn't done it. */
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		/* bind to sap with null dev, exclusive. */
 		rc = llc_ui_autobind(sock, addr);
 		if (rc)
@@ -823,7 +825,7 @@
 	int rc = 0;
 
 	lock_sock(sk);
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 	*uaddrlen = sizeof(sllc);
 	memset(uaddr, 0, *uaddrlen);
diff -Nru linux-2.6.11-rc4.orig/net/netrom/af_netrom.c linux-2.6.11-rc4/net/netrom/af_netrom.c
--- linux-2.6.11-rc4.orig/net/netrom/af_netrom.c	2005-03-08 18:11:29.000000000 +0100
+++ linux-2.6.11-rc4/net/netrom/af_netrom.c	2005-03-08 23:51:06.000000000 +0100
@@ -479,7 +479,9 @@
 	sk->sk_debug    = osk->sk_debug;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
-	sk->sk_zapped   = osk->sk_zapped;
+
+	if (sock_flag(osk, SOCK_ZAPPED))
+		sock_set_flag(sk, SOCK_ZAPPED);
 
 	skb_queue_head_init(&nr->ack_queue);
 	skb_queue_head_init(&nr->reseq_queue);
@@ -559,7 +561,7 @@
 	ax25_address *user, *source;
 
 	lock_sock(sk);
-	if (!sk->sk_zapped) {
+	if (!sock_flag(sk, SOCK_ZAPPED)) {
 		release_sock(sk);
 		return -EINVAL;
 	}
@@ -611,7 +613,7 @@
 	nr->device = dev;
 	nr_insert_socket(sk);
 
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	dev_put(dev);
 	release_sock(sk);
 	SOCK_DEBUG(sk, "NET/ROM: socket is bound\n");
@@ -656,8 +658,8 @@
 		release_sock(sk);
 		return -EINVAL;
 	}
-	if (sk->sk_zapped) {	/* Must bind first - autobinding in this may or may not work */
-		sk->sk_zapped = 0;
+	if (sock_flag(sk, SOCK_ZAPPED)) {	/* Must bind first - autobinding in this may or may not work */
+		sock_reset_flag(sk, SOCK_ZAPPED);
 
 		if ((dev = nr_dev_first()) == NULL) {
 			release_sock(sk);
@@ -1024,7 +1026,7 @@
 		return -EINVAL;
 
 	lock_sock(sk);
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		err = -EADDRNOTAVAIL;
 		goto out;
 	}
diff -Nru linux-2.6.11-rc4.orig/net/rose/af_rose.c linux-2.6.11-rc4/net/rose/af_rose.c
--- linux-2.6.11-rc4.orig/net/rose/af_rose.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/rose/af_rose.c	2005-03-08 23:51:06.000000000 +0100
@@ -575,7 +575,9 @@
 	sk->sk_debug    = osk->sk_debug;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
-	sk->sk_zapped   = osk->sk_zapped;
+
+	if (sock_flag(osk, SOCK_ZAPPED))
+		sock_set_flag(sk, SOCK_ZAPPED);
 
 	init_timer(&rose->timer);
 	init_timer(&rose->idletimer);
@@ -648,7 +650,7 @@
 	ax25_address *user, *source;
 	int n;
 
-	if (!sk->sk_zapped)
+	if (!sock_flag(sk, SOCK_ZAPPED))
 		return -EINVAL;
 
 	if (addr_len != sizeof(struct sockaddr_rose) && addr_len != sizeof(struct full_sockaddr_rose))
@@ -693,7 +695,7 @@
 
 	rose_insert_socket(sk);
 
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	SOCK_DEBUG(sk, "ROSE: socket is bound\n");
 	return 0;
 }
@@ -749,8 +751,8 @@
 	if (!rose->lci)
 		return -ENETUNREACH;
 
-	if (sk->sk_zapped) {	/* Must bind first - autobinding in this may or may not work */
-		sk->sk_zapped = 0;
+	if (sock_flag(sk, SOCK_ZAPPED)) {	/* Must bind first - autobinding in this may or may not work */
+		sock_reset_flag(sk, SOCK_ZAPPED);
 
 		if ((dev = rose_dev_first()) == NULL)
 			return -ENETUNREACH;
@@ -1023,7 +1025,7 @@
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
 		return -EINVAL;
 
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		return -EADDRNOTAVAIL;
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
diff -Nru linux-2.6.11-rc4.orig/net/sctp/ipv6.c linux-2.6.11-rc4/net/sctp/ipv6.c
--- linux-2.6.11-rc4.orig/net/sctp/ipv6.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/sctp/ipv6.c	2005-03-08 23:51:06.000000000 +0100
@@ -609,11 +609,11 @@
 	newsk->sk_reuse = sk->sk_reuse;
 
 	newsk->sk_destruct = inet_sock_destruct;
-	newsk->sk_zapped = 0;
 	newsk->sk_family = PF_INET6;
 	newsk->sk_protocol = IPPROTO_SCTP;
 	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
 	newsk->sk_shutdown = sk->sk_shutdown;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 
 	newsctp6sk = (struct sctp6_sock *)newsk;
 	inet_sk(newsk)->pinet6 = &newsctp6sk->inet6;
diff -Nru linux-2.6.11-rc4.orig/net/sctp/protocol.c linux-2.6.11-rc4/net/sctp/protocol.c
--- linux-2.6.11-rc4.orig/net/sctp/protocol.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/sctp/protocol.c	2005-03-08 23:51:06.000000000 +0100
@@ -570,10 +570,10 @@
 	newsk->sk_shutdown = sk->sk_shutdown;
 
 	newsk->sk_destruct = inet_sock_destruct;
-	newsk->sk_zapped = 0;
 	newsk->sk_family = PF_INET;
 	newsk->sk_protocol = IPPROTO_SCTP;
 	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
+	sock_reset_flag(newsk, SOCK_ZAPPED);
 
 	newinet = inet_sk(newsk);
 
diff -Nru linux-2.6.11-rc4.orig/net/sunrpc/xprt.c linux-2.6.11-rc4/net/sunrpc/xprt.c
--- linux-2.6.11-rc4.orig/net/sunrpc/xprt.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/sunrpc/xprt.c	2005-03-08 23:51:06.000000000 +0100
@@ -1044,7 +1044,8 @@
 	dprintk("RPC:      tcp_state_change client %p...\n", xprt);
 	dprintk("RPC:      state %x conn %d dead %d zapped %d\n",
 				sk->sk_state, xprt_connected(xprt),
-				sock_flag(sk, SOCK_DEAD), sk->sk_zapped);
+				sock_flag(sk, SOCK_DEAD),
+				sock_flag(sk, SOCK_ZAPPED));
 
 	switch (sk->sk_state) {
 	case TCP_ESTABLISHED:
diff -Nru linux-2.6.11-rc4.orig/net/wanrouter/af_wanpipe.c linux-2.6.11-rc4/net/wanrouter/af_wanpipe.c
--- linux-2.6.11-rc4.orig/net/wanrouter/af_wanpipe.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/wanrouter/af_wanpipe.c	2005-03-08 23:51:06.000000000 +0100
@@ -394,7 +394,7 @@
 	chan->lcn = mbox_ptr->cmd.lcn;
 	card->u.x.svc_to_dev_map[(chan->lcn%MAX_X25_LCN)] = dev;
 
-	newsk->sk_zapped = 0;
+	sock_reset_flag(newsk, SOCK_ZAPPED);
 	newwp->num = htons(X25_PROT);
 
 	if (wanpipe_do_bind(newsk, dev, newwp->num)) {
@@ -546,7 +546,7 @@
 	int ifindex, err, reserve = 0;
 
 	
-	if (!sk->sk_zapped)
+	if (!sock_flag(sk, SOCK_ZAPPED))
 		return -ENETDOWN;
 
 	if (sk->sk_state != WANSOCK_CONNECTED)
@@ -672,7 +672,7 @@
 		return;
 	}
 	
-	if (sk->sk_state != WANSOCK_CONNECTED || !sk->sk_zapped) {
+	if (sk->sk_state != WANSOCK_CONNECTED || !sock_flag(sk, SOCK_ZAPPED)) {
 		clear_bit(0, &wp->timer);
 		DBG_PRINTK(KERN_INFO "wansock: Tx Timer, State not CONNECTED\n");
 		return;
@@ -865,7 +865,7 @@
 	struct net_device *dev;
 	wanpipe_common_t *chan=NULL;
 
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	sk->sk_state = WANSOCK_DISCONNECTED;
 	wp_sk(sk)->dev = NULL;
 
@@ -914,7 +914,7 @@
 	chan->mbox = wp->mbox;
 	chan->tx_timer = &wp->tx_timer;
 	wp->dev = dev;
-	sk->sk_zapped = 1;
+	sock_set_flag(sk, SOCK_ZAPPED);
 	clear_bit(0,&chan->common_critical);
 }
 
@@ -964,7 +964,7 @@
 	 */
 
 	if (wp->num == htons(X25_PROT) &&
-	    sk->sk_state != WANSOCK_DISCONNECTED && sk->sk_zapped) {
+	    sk->sk_state != WANSOCK_DISCONNECTED && sock_flag(sk, SOCK_ZAPPED)) {
 		struct net_device *dev = dev_get_by_index(sk->sk_bound_dev_if);
 		wanpipe_common_t *chan;
 		if (dev){
@@ -1075,15 +1075,15 @@
 			}
 			kfree_skb(skb);
 		}
-		if (sk->sk_zapped)
+		if (sock_flag(sk, SOCK_ZAPPED))
 			wanpipe_unlink_card(sk);
 	}else{
-		if (sk->sk_zapped)
+		if (sock_flag(sk, SOCK_ZAPPED))
 			wanpipe_unlink_driver(sk);
 	}
 	sk->sk_state	    = WANSOCK_DISCONNECTED;
 	sk->sk_bound_dev_if = 0;
-	sk->sk_zapped	    = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	wp = wp_sk(sk);
 
 	if (wp && wp->mbox) {
@@ -1261,7 +1261,7 @@
 	wanpipe_common_t *chan=NULL;
 	int err=0;
 
-	if (sk->sk_zapped) {
+	if (sock_flag(sk, SOCK_ZAPPED)) {
 		err = -EALREADY;
 		goto bind_unlock_exit;
 	}
@@ -1515,7 +1515,7 @@
 	sock->ops = &wanpipe_ops;
 	sock_init_data(sock,sk);
 
-	sk->sk_zapped	    = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	sk->sk_family	    = PF_WANPIPE;
 	wp_sk(sk)->num	    = protocol;
 	sk->sk_state	    = WANSOCK_DISCONNECTED;
@@ -1721,7 +1721,7 @@
 		case NETDEV_UNREGISTER:
 			if (dev->ifindex == sk->sk_bound_dev_if) {
 				printk(KERN_INFO "wansock: Device down %s\n",dev->name);
-				if (sk->sk_zapped) {
+				if (sock_flag(sk, SOCK_ZAPPED)) {
 					wanpipe_unlink_driver(sk);
 					sk->sk_err = ENETDOWN;
 					sk->sk_error_report(sk);
@@ -1737,7 +1737,7 @@
 			break;
 		case NETDEV_UP:
 			if (dev->ifindex == sk->sk_bound_dev_if &&
-			    po->num && !sk->sk_zapped) {
+			    po->num && !sock_flag(sk, SOCK_ZAPPED)) {
 				printk(KERN_INFO "wansock: Registering Device: %s\n",
 						dev->name);
 				wanpipe_link_driver(dev,sk);
@@ -2160,7 +2160,7 @@
 
 	card->sk=sk;
 	card->func=wanpipe_listen_rcv;
-	sk->sk_zapped = 1;
+	sock_set_flag(sk, SOCK_ZAPPED);
  
 	return 0;
 }
@@ -2504,7 +2504,7 @@
 
 	dev_put(dev);
 	
-	if (!sk->sk_zapped) /* Must bind first - autobinding does not work */
+	if (!sock_flag(sk, SOCK_ZAPPED)) /* Must bind first - autobinding does not work */
 		return -EINVAL;
 
 	sock->state   = SS_CONNECTING;
diff -Nru linux-2.6.11-rc4.orig/net/x25/af_x25.c linux-2.6.11-rc4/net/x25/af_x25.c
--- linux-2.6.11-rc4.orig/net/x25/af_x25.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/x25/af_x25.c	2005-03-08 23:51:06.000000000 +0100
@@ -528,9 +528,11 @@
 	sk->sk_debug       = osk->sk_debug;
 	sk->sk_state       = TCP_ESTABLISHED;
 	sk->sk_sleep       = osk->sk_sleep;
-	sk->sk_zapped      = osk->sk_zapped;
 	sk->sk_backlog_rcv = osk->sk_backlog_rcv;
 
+	if (sock_flag(osk, SOCK_ZAPPED))
+		sock_set_flag(sk, SOCK_ZAPPED);
+
 	ox25 = x25_sk(osk);
 	x25->t21        = ox25->t21;
 	x25->t22        = ox25->t22;
@@ -588,14 +590,14 @@
 	struct sock *sk = sock->sk;
 	struct sockaddr_x25 *addr = (struct sockaddr_x25 *)uaddr;
 
-	if (!sk->sk_zapped ||
+	if (!sock_flag(sk, SOCK_ZAPPED) ||
 	    addr_len != sizeof(struct sockaddr_x25) ||
 	    addr->sx25_family != AF_X25)
 		return -EINVAL;
 
 	x25_sk(sk)->source_addr = addr->sx25_addr;
 	x25_insert_socket(sk);
-	sk->sk_zapped = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	SOCK_DEBUG(sk, "x25_bind: socket is bound\n");
 
 	return 0;
@@ -679,7 +681,7 @@
 		goto out_put_neigh;
 
 	rc = -EINVAL;
-	if (sk->sk_zapped) /* Must bind first - autobinding does not work */
+	if (sock_flag(sk, SOCK_ZAPPED)) /* Must bind first - autobinding does not work */
 		goto out_put_neigh;
 
 	if (!strcmp(x25->source_addr.x25_addr, null_x25_address.x25_addr))
@@ -942,7 +944,7 @@
 		goto out;
 
 	rc = -EADDRNOTAVAIL;
-	if (sk->sk_zapped)
+	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 
 	rc = -EPIPE;
