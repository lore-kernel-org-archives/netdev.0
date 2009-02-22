From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 4/8] l2tp: add L2TPv3 PPP pseudowire support
Date: Sun, 22 Feb 2009 17:52:20 GMT
Message-ID: <200902221752.n1MHqKoi006543@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48314 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799AbZBVRqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 12:46:45 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id BDDA9A620A2
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:40 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id K0MfpgjbXQoM for <netdev@vger.kernel.org>;
	Sun, 22 Feb 2009 17:52:34 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id A2441A620A9
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: (from james@localhost)
	by bert.katalix.com (8.14.2/8.14.2/Submit) id n1MHqKoi006543
	for netdev@vger.kernel.org; Sun, 22 Feb 2009 17:52:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes changes to the L2TP PPP code for L2TPv3.

The existing code has some assumptions about the L2TP header which are
broken by L2TPv3. Also the sockaddr_pppol2tp structure of the original
code is too small to support the increased size of the L2TPv3 tunnel
and session id, so a new sockaddr_pppol2tpv3 structure is needed. In
the socket calls, the size of this structure is used to tell if the
operation is for L2TPv2 or L2TPv3.

Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_ppp.c
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/l2tp_ppp.c
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_ppp.c
@@ -297,17 +297,6 @@ static void pppol2tp_session_sock_put(st
  * Transmit handling
  ***********************************************************************/
 
-/* Tell how big L2TP headers are for a particular session. This
- * depends on whether sequence numbers are being used.
- */
-static inline int pppol2tp_l2tp_header_len(struct l2tp_session *session)
-{
-	if (session->send_seq)
-		return PPPOL2TP_L2TP_HDR_SIZE_SEQ;
-
-	return PPPOL2TP_L2TP_HDR_SIZE_NOSEQ;
-}
-
 /* This is the sendmsg for the PPPoL2TP pppol2tp_session socket.  We come here
  * when a user application does a sendmsg() on the session socket. L2TP and
  * PPP headers must be inserted into the user's data.
@@ -321,7 +310,6 @@ static int pppol2tp_sendmsg(struct kiocb
 	__wsum csum = 0;
 	struct sk_buff *skb;
 	int error;
-	int hdr_len;
 	struct l2tp_session *session;
 	struct l2tp_tunnel *tunnel;
 	struct udphdr *uh;
@@ -342,13 +330,10 @@ static int pppol2tp_sendmsg(struct kiocb
 	if (tunnel == NULL)
 		goto error_put_sess;
 
-	/* What header length is configured for this session? */
-	hdr_len = pppol2tp_l2tp_header_len(session);
-
 	/* Allocate a socket buffer */
 	error = -ENOMEM;
 	skb = sock_wmalloc(sk, NET_SKB_PAD + sizeof(struct iphdr) +
-			   sizeof(struct udphdr) + hdr_len +
+			   sizeof(struct udphdr) + session->header_len +
 			   sizeof(ppph) + total_len,
 			   0, GFP_KERNEL);
 	if (!skb)
@@ -365,13 +350,13 @@ static int pppol2tp_sendmsg(struct kiocb
 	uh = (struct udphdr *) skb->data;
 	uh->source = inet->sport;
 	uh->dest = inet->dport;
-	uh->len = htons(hdr_len + sizeof(ppph) + total_len);
+	uh->len = htons(session->header_len + sizeof(ppph) + total_len);
 	uh->check = 0;
 	skb_put(skb, sizeof(struct udphdr));
 
 	/* Build L2TP header */
 	session->build_header(session, skb->data);
-	skb_put(skb, hdr_len);
+	skb_put(skb, session->header_len);
 
 	/* Add PPP header */
 	skb->data[0] = ppph[0];
@@ -421,7 +406,6 @@ static int pppol2tp_xmit(struct ppp_chan
 	static const u8 ppph[2] = { 0xff, 0x03 };
 	struct sock *sk = (struct sock *) chan->private;
 	struct sock *sk_tun;
-	int hdr_len;
 	struct l2tp_session *session;
 	struct l2tp_tunnel *tunnel;
 	struct pppol2tp_session *ps;
@@ -442,9 +426,6 @@ static int pppol2tp_xmit(struct ppp_chan
 	if (tunnel == NULL)
 		goto abort_put_sess;
 
-	/* What header length is configured for this session? */
-	hdr_len = pppol2tp_l2tp_header_len(session);
-
  	if (skb_cow_head(skb, sizeof(ppph)))
 		goto abort_put_sess_tun;
 
@@ -453,7 +434,7 @@ static int pppol2tp_xmit(struct ppp_chan
 	skb->data[0] = ppph[0];
 	skb->data[1] = ppph[1];
 
- 	l2tp_xmit_skb(session, skb, hdr_len);
+ 	l2tp_xmit_skb(session, skb, session->header_len);
 
 	sock_put(sk_tun);
 	sock_put(sk);
@@ -646,6 +627,7 @@ static int pppol2tp_connect(struct socke
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_pppol2tp *sp = (struct sockaddr_pppol2tp *) uservaddr;
+	struct sockaddr_pppol2tpv3 *sp3 = (struct sockaddr_pppol2tpv3 *) uservaddr;
 	struct pppox_sock *po = pppox_sk(sk);
 	struct l2tp_session *session = NULL;
 	struct l2tp_tunnel *tunnel;
@@ -653,6 +635,10 @@ static int pppol2tp_connect(struct socke
 	struct dst_entry *dst;
 	struct l2tp_session_cfg cfg = { 0, };
 	int error = 0;
+	u32 tunnel_id, peer_tunnel_id;
+	u32 session_id, peer_session_id;
+	int ver = 2;
+	int fd;
 
 	lock_sock(sk);
 
@@ -670,22 +656,41 @@ static int pppol2tp_connect(struct socke
 	if (sk->sk_user_data)
 		goto end; /* socket is already attached */
 
-	/* Don't bind if s_tunnel is 0 */
+	/* Get params from socket address. Handle L2TPv2 and L2TPv3 */
+	if (sockaddr_len == sizeof(struct sockaddr_pppol2tp)) {
+		fd = sp->pppol2tp.fd;
+		tunnel_id = sp->pppol2tp.s_tunnel;
+		peer_tunnel_id = sp->pppol2tp.d_tunnel;
+		session_id = sp->pppol2tp.s_session;
+		peer_session_id = sp->pppol2tp.d_session;
+	} else if (sockaddr_len == sizeof(struct sockaddr_pppol2tpv3)) {
+		ver = 3;
+		fd = sp3->pppol2tp.fd;
+		tunnel_id = sp3->pppol2tp.s_tunnel;
+		peer_tunnel_id = sp3->pppol2tp.d_tunnel;
+		session_id = sp3->pppol2tp.s_session;
+		peer_session_id = sp3->pppol2tp.d_session;
+	} else {
+		error = -EINVAL;
+		goto end; /* bad socket address */
+	}
+
+	/* Don't bind if tunnel_id is 0 */
 	error = -EINVAL;
-	if (sp->pppol2tp.s_tunnel == 0)
+	if (tunnel_id == 0)
 		goto end;
 
-	/* Special case: create tunnel context if s_session and
-	 * d_session is 0. Otherwise look up tunnel using supplied
+	/* Special case: create tunnel context if session_id and
+	 * peer_session_id is 0. Otherwise look up tunnel using supplied
 	 * tunnel id.
 	 */
-	if ((sp->pppol2tp.s_session == 0) && (sp->pppol2tp.d_session == 0)) {
+	if ((session_id == 0) && (peer_session_id == 0)) {
 		struct l2tp_tunnel_cfg tcfg = { 0, };
-		error = l2tp_tunnel_create(sp->pppol2tp.fd, 2, sp->pppol2tp.s_tunnel, sp->pppol2tp.d_tunnel, &tcfg, &tunnel);
+		error = l2tp_tunnel_create(fd, ver, tunnel_id, peer_tunnel_id, &tcfg, &tunnel);
 		if (error < 0)
 			goto end;
 	} else {
-		tunnel = l2tp_tunnel_find(sp->pppol2tp.s_tunnel);
+		tunnel = l2tp_tunnel_find(tunnel_id);
 
 		/* Error if we can't find the tunnel */
 		error = -ENOENT;
@@ -702,19 +707,20 @@ static int pppol2tp_connect(struct socke
 
 	/* Check that this session doesn't already exist */
 	error = -EEXIST;
-	session = l2tp_session_find(tunnel, sp->pppol2tp.s_session);
+	session = l2tp_session_find(tunnel, session_id);
 	if (session != NULL)
 		goto end;
 
-	/* Default MTU must allow space for UDP/L2TP/PPP
-	 * headers.
-	 */
-	cfg.mtu = cfg.mru = 1500 - PPPOL2TP_HEADER_OVERHEAD;
+	/* Default MTU values. */
+	if (cfg.mtu == 0)
+		cfg.mtu = 1500 - PPPOL2TP_HEADER_OVERHEAD;
+	if (cfg.mru == 0)
+		cfg.mru = cfg.mtu;
 
 	/* Allocate and initialize a new session context. */
 	session = l2tp_session_create(sizeof(struct pppol2tp_session),
-				      tunnel, sp->pppol2tp.s_session,
-				      sp->pppol2tp.d_session, &cfg);
+				      tunnel, session_id,
+				      peer_session_id, &cfg);
 	if (session == NULL) {
 		error = -ENOMEM;
 		goto end;
@@ -779,8 +785,6 @@ static int pppol2tp_connect(struct socke
 out_no_ppp:
 	/* This is how we get the session context from the socket. */
 	sk->sk_user_data = session;
-
-	l2tp_tunnel_inc_refcount(tunnel);
 	sk->sk_state = PPPOX_CONNECTED;
 	PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
 	       "%s: created\n", session->name);
@@ -790,10 +794,6 @@ end_put_tun:
 end:
 	release_sock(sk);
 
-	if (error != 0)
-		printk(KERN_WARNING "sess %hu/%hu: connect failed: %d\n",
-		       sp->pppol2tp.d_tunnel, sp->pppol2tp.d_session, error);
-
 	return error;
 }
 
@@ -802,8 +802,7 @@ end:
 static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 			    int *usockaddr_len, int peer)
 {
-	int len = sizeof(struct sockaddr_pppol2tp);
-	struct sockaddr_pppol2tp sp;
+	int len = 0;
 	int error = 0;
 	struct l2tp_session *session;
 	struct l2tp_tunnel *tunnel;
@@ -826,28 +825,50 @@ static int pppol2tp_getname(struct socke
 	tunnel = l2tp_sock_to_tunnel(pls->tunnel_sock);
 	if (tunnel == NULL) {
 		error = -EBADF;
-		goto end;
+		goto end_put_sess;
 	}
 
-	memset(&sp, 0, len);
-	sp.sa_family	= AF_PPPOX;
-	sp.sa_protocol	= PX_PROTO_OL2TP;
-	sp.pppol2tp.fd  = tunnel->fd;
-	sp.pppol2tp.pid = pls->owner;
-	sp.pppol2tp.s_tunnel = tunnel->tunnel_id;
-	sp.pppol2tp.d_tunnel = tunnel->peer_tunnel_id;
-	sp.pppol2tp.s_session = session->session_id;
-	sp.pppol2tp.d_session = session->peer_session_id;
 	inet = inet_sk(sk);
-	sp.pppol2tp.addr.sin_family = AF_INET;
-	sp.pppol2tp.addr.sin_port = inet->dport;
-	sp.pppol2tp.addr.sin_addr.s_addr = inet->daddr;
 
-	memcpy(uaddr, &sp, len);
+	if (tunnel->version == 2) {
+		struct sockaddr_pppol2tp sp;
+		len = sizeof(sp);
+		memset(&sp, 0, len);
+		sp.sa_family	= AF_PPPOX;
+		sp.sa_protocol	= PX_PROTO_OL2TP;
+		sp.pppol2tp.fd  = tunnel->fd;
+		sp.pppol2tp.pid = pls->owner;
+		sp.pppol2tp.s_tunnel = tunnel->tunnel_id;
+		sp.pppol2tp.d_tunnel = tunnel->peer_tunnel_id;
+		sp.pppol2tp.s_session = session->session_id;
+		sp.pppol2tp.d_session = session->peer_session_id;
+		sp.pppol2tp.addr.sin_family = AF_INET;
+		sp.pppol2tp.addr.sin_port = inet->dport;
+		sp.pppol2tp.addr.sin_addr.s_addr = inet->daddr;
+		memcpy(uaddr, &sp, len);
+	} else if (tunnel->version == 3) {
+		struct sockaddr_pppol2tpv3 sp;
+		len = sizeof(sp);
+		memset(&sp, 0, len);
+		sp.sa_family	= AF_PPPOX;
+		sp.sa_protocol	= PX_PROTO_OL2TP;
+		sp.pppol2tp.fd  = tunnel->fd;
+		sp.pppol2tp.pid = pls->owner;
+		sp.pppol2tp.s_tunnel = tunnel->tunnel_id;
+		sp.pppol2tp.d_tunnel = tunnel->peer_tunnel_id;
+		sp.pppol2tp.s_session = session->session_id;
+		sp.pppol2tp.d_session = session->peer_session_id;
+		sp.pppol2tp.addr.sin_family = AF_INET;
+		sp.pppol2tp.addr.sin_port = inet->dport;
+		sp.pppol2tp.addr.sin_addr.s_addr = inet->daddr;
+		memcpy(uaddr, &sp, len);
+	}
 
 	*usockaddr_len = len;
 
-	sock_put(sock->sk);
+	sock_put(pls->tunnel_sock);
+end_put_sess:
+	sock_put(sk);
 	error = 0;
 
 end:
Index: net-next-2.6-l2tpv3-2/include/linux/if_pppol2tp.h
===================================================================
--- net-next-2.6-l2tpv3-2.orig/include/linux/if_pppol2tp.h
+++ net-next-2.6-l2tpv3-2/include/linux/if_pppol2tp.h
@@ -2,7 +2,7 @@
  * Linux PPP over L2TP (PPPoL2TP) Socket Implementation (RFC 2661)
  *
  * This file supplies definitions required by the PPP over L2TP driver
- * (pppol2tp.c).  All version information wrt this file is located in pppol2tp.c
+ * (l2tp_eth.c).  All version information wrt this file is located in l2tp_eth.c
  *
  * License:
  *		This program is free software; you can redistribute it and/or
@@ -36,6 +36,20 @@ struct pppol2tp_addr
 	__u16 d_tunnel, d_session;	/* For sending outgoing packets */
 };
 
+/* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
+ * bits. So we need a different sockaddr structure.
+ */
+struct pppol2tpv3_addr {
+	pid_t	pid;			/* pid that owns the fd.
+					 * 0 => current */
+	int	fd;			/* FD of UDP or IP socket to use */
+
+	struct sockaddr_in addr;	/* IP address and port to send to */
+
+	__u32 s_tunnel, s_session;	/* For matching incoming packets */
+	__u32 d_tunnel, d_session;	/* For sending outgoing packets */
+};
+
 /* Socket options:
  * DEBUG	- bitmask of debug message categories
  * SENDSEQ	- 0 => don't send packets with sequence numbers
Index: net-next-2.6-l2tpv3-2/include/linux/if_pppox.h
===================================================================
--- net-next-2.6-l2tpv3-2.orig/include/linux/if_pppox.h
+++ net-next-2.6-l2tpv3-2/include/linux/if_pppox.h
@@ -72,6 +72,15 @@ struct sockaddr_pppol2tp {
 	struct pppol2tp_addr pppol2tp;
 }__attribute__ ((packed));
 
+/* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
+ * bits. So we need a different sockaddr structure.
+ */
+struct sockaddr_pppol2tpv3 {
+	sa_family_t     sa_family;      /* address family, AF_PPPOX */
+	unsigned int    sa_protocol;    /* protocol identifier */
+	struct pppol2tpv3_addr pppol2tp;
+} __attribute__ ((packed));
+
 /*********************************************************************
  *
  * ioctl interface for defining forwarding of connections
