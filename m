From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 5 Dec 2007 11:12:32 +1100
Message-ID: <20071205001230.GA11391@gondor.apana.org.au>
References: <4755A21F.2020407@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1346 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750813AbXLEAMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 19:12:43 -0500
Content-Disposition: inline
In-Reply-To: <4755A21F.2020407@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 06:53:19PM +0000, Simon Arlott wrote:
> If I have a IPsec rule like:
> 	spdadd 192.168.7.8 1.2.3.4 any -P out ipsec esp/transport//require;
> (i.e. a remote host 1.2.3.4 which will not respond)
> 
> Then any attempt to communicate with 1.2.3.4 will block, even when using non-blocking sockets:

This patch should help.

[INET]: Export non-blocking flags to proto connect call

Previously we made connect(2) block on IPsec SA resolution.  This is
good in general but not desirable for non-blocking sockets.

To fix this properly we'd need to implement the larval IPsec dst stuff
that we talked about.  For now let's just revert to the old behaviour
on non-blocking sockets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/ip.h b/include/net/ip.h
index 83fb9f1..9b4ed7e 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -121,7 +121,8 @@ extern void		ip_flush_pending_frames(struct sock *sk);
 
 /* datagram.c */
 extern int		ip4_datagram_connect(struct sock *sk, 
-					     struct sockaddr *uaddr, int addr_len);
+					     struct sockaddr *uaddr,
+					     int addr_len, int flags);
 
 /*
  *	Map a multicast IP onto multicast MAC for type Token Ring.
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e90f962..2686850 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -567,7 +567,8 @@ extern void			ipv6_packet_init(void);
 extern void			ipv6_packet_cleanup(void);
 
 extern int			ip6_datagram_connect(struct sock *sk, 
-						     struct sockaddr *addr, int addr_len);
+						     struct sockaddr *addr,
+						     int addr_len, int flags);
 
 extern int 			ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len);
 extern void			ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
diff --git a/include/net/sock.h b/include/net/sock.h
index 43e3cd9..d70b110 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -522,8 +522,8 @@ struct proto {
 	void			(*close)(struct sock *sk, 
 					long timeout);
 	int			(*connect)(struct sock *sk,
-				        struct sockaddr *uaddr, 
-					int addr_len);
+					   struct sockaddr *uaddr,
+					   int addr_len, int flags);
 	int			(*disconnect)(struct sock *sk, int flags);
 
 	struct sock *		(*accept) (struct sock *sk, int flags, int *err);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9dbed0b..d93eef6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -421,7 +421,7 @@ extern int			tcp_v4_do_rcv(struct sock *sk,
 
 extern int			tcp_v4_connect(struct sock *sk,
 					       struct sockaddr *uaddr,
-					       int addr_len);
+					       int addr_len, int flags);
 
 extern int			tcp_connect(struct sock *sk);
 
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index ee97950..4062068 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -292,7 +292,7 @@ extern int	   inet_dccp_listen(struct socket *sock, int backlog);
 extern unsigned int dccp_poll(struct file *file, struct socket *sock,
 			     poll_table *wait);
 extern int	   dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
-				   int addr_len);
+				   int addr_len, int flags);
 
 extern struct sk_buff *dccp_ctl_make_reset(struct socket *ctl,
 					   struct sk_buff *skb);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index db17b83..e2aba0f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -44,7 +44,8 @@ static int dccp_v4_get_port(struct sock *sk, const unsigned short snum)
 				 inet_csk_bind_conflict);
 }
 
-int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len,
+		    int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -72,7 +73,8 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_DCCP,
-			       inet->sport, usin->sin_port, sk, 1);
+			       inet->sport, usin->sin_port, sk,
+			       !(flags & O_NONBLOCK));
 	if (tmp < 0)
 		return tmp;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 87c98fb..7da5269 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -866,7 +866,7 @@ discard_and_relse:
 }
 
 static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
-			   int addr_len)
+			   int addr_len, int flags)
 {
 	struct sockaddr_in6 *usin = (struct sockaddr_in6 *)uaddr;
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -952,7 +952,8 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		icsk->icsk_af_ops = &dccp_ipv6_mapped;
 		sk->sk_backlog_rcv = dccp_v4_do_rcv;
 
-		err = dccp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
+		err = dccp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin),
+				      flags);
 		if (err) {
 			icsk->icsk_ext_hdr_len = exthdrlen;
 			icsk->icsk_af_ops = &dccp_ipv6_af_ops;
@@ -994,7 +995,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	err = __xfrm_lookup(&dst, &fl, sk, 1);
+	err = __xfrm_lookup(&dst, &fl, sk, !(flags & O_NONBLOCK));
 	if (err < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c75f20b..5fc5de0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -513,7 +513,8 @@ int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
 
 	if (!inet_sk(sk)->num && inet_autobind(sk))
 		return -EAGAIN;
-	return sk->sk_prot->connect(sk, (struct sockaddr *)uaddr, addr_len);
+	return sk->sk_prot->connect(sk, (struct sockaddr *)uaddr, addr_len,
+				    flags);
 }
 
 static long inet_wait_for_connect(struct sock *sk, long timeo)
@@ -574,7 +575,7 @@ int inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 		if (sk->sk_state != TCP_CLOSE)
 			goto out;
 
-		err = sk->sk_prot->connect(sk, uaddr, addr_len);
+		err = sk->sk_prot->connect(sk, uaddr, addr_len, flags);
 		if (err < 0)
 			goto out;
 
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 0301dd4..19ab5b1 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -20,7 +20,8 @@
 #include <net/route.h>
 #include <net/tcp_states.h>
 
-int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len,
+			 int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *) uaddr;
@@ -49,7 +50,8 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	err = ip_route_connect(&rt, usin->sin_addr.s_addr, saddr,
 			       RT_CONN_FLAGS(sk), oif,
 			       sk->sk_protocol,
-			       inet->sport, usin->sin_port, sk, 1);
+			       inet->sport, usin->sin_port, sk,
+			       !(flags & O_NONBLOCK));
 	if (err) {
 		if (err == -ENETUNREACH)
 			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a27e42..0a2ee0b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -166,7 +166,8 @@ int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
 EXPORT_SYMBOL_GPL(tcp_twsk_unique);
 
 /* This will initiate an outgoing connection. */
-int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len,
+		   int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -192,7 +193,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
-			       inet->sport, usin->sin_port, sk, 1);
+			       inet->sport, usin->sin_port, sk,
+			       !(flags & O_NONBLOCK));
 	if (tmp < 0) {
 		if (tmp == -ENETUNREACH)
 			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2ed689a..591634a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -34,7 +34,8 @@
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
 
-int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len,
+			 int flags)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_sock      	*inet = inet_sk(sk);
@@ -49,7 +50,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (usin->sin6_family == AF_INET) {
 		if (__ipv6_only_sock(sk))
 			return -EAFNOSUPPORT;
-		err = ip4_datagram_connect(sk, uaddr, addr_len);
+		err = ip4_datagram_connect(sk, uaddr, addr_len, flags);
 		goto ipv4_connected;
 	}
 
@@ -94,7 +95,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 		err = ip4_datagram_connect(sk,
 					   (struct sockaddr*) &sin,
-					   sizeof(sin));
+					   sizeof(sin), flags);
 
 ipv4_connected:
 		if (err)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f1294dc..9cb9068 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -122,7 +122,7 @@ static __u32 tcp_v6_init_sequence(struct sk_buff *skb)
 }
 
 static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
-			  int addr_len)
+			  int addr_len, int flags)
 {
 	struct sockaddr_in6 *usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_sock *inet = inet_sk(sk);
@@ -219,7 +219,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		tp->af_specific = &tcp_sock_ipv6_mapped_specific;
 #endif
 
-		err = tcp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin));
+		err = tcp_v4_connect(sk, (struct sockaddr *)&sin, sizeof(sin),
+				     flags);
 
 		if (err) {
 			icsk->icsk_ext_hdr_len = exthdrlen;
@@ -265,7 +266,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+	if ((err = __xfrm_lookup(&dst, &fl, sk, !(flags & O_NONBLOCK))) < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 248b9a5..1ca8913 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -960,7 +960,8 @@ out:
  */
 static int __sctp_connect(struct sock* sk,
 			  struct sockaddr *kaddrs,
-			  int addrs_size)
+			  int addrs_size,
+			  int f_flags)
 {
 	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
@@ -977,7 +978,6 @@ static int __sctp_connect(struct sock* sk,
 	union sctp_addr *sa_addr = NULL;
 	void *addr_buf;
 	unsigned short port;
-	unsigned int f_flags = 0;
 
 	sp = sctp_sk(sk);
 	ep = sp->ep;
@@ -1106,12 +1106,6 @@ static int __sctp_connect(struct sock* sk,
 	af->to_sk_daddr(sa_addr, sk);
 	sk->sk_err = 0;
 
-	/* in-kernel sockets don't generally have a file allocated to them
-	 * if all they do is call sock_create_kern().
-	 */
-	if (sk->sk_socket->file)
-		f_flags = sk->sk_socket->file->f_flags;
-
 	timeo = sock_sndtimeo(sk, f_flags & O_NONBLOCK);
 
 	err = sctp_wait_for_connect(asoc, &timeo);
@@ -1194,6 +1188,7 @@ SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
 {
 	int err = 0;
 	struct sockaddr *kaddrs;
+	int f_flags;
 
 	SCTP_DEBUG_PRINTK("%s - sk %p addrs %p addrs_size %d\n",
 			  __FUNCTION__, sk, addrs, addrs_size);
@@ -1210,10 +1205,15 @@ SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
 	if (unlikely(!kaddrs))
 		return -ENOMEM;
 
+	/* in-kernel sockets don't generally have a file allocated to them
+	 * if all they do is call sock_create_kern().
+	 */
+	f_flags = sk->sk_socket->file ? sk->sk_socket->file->f_flags : 0;
+
 	if (__copy_from_user(kaddrs, addrs, addrs_size)) {
 		err = -EFAULT;
 	} else {
-		err = __sctp_connect(sk, kaddrs, addrs_size);
+		err = __sctp_connect(sk, kaddrs, addrs_size, f_flags);
 	}
 
 	kfree(kaddrs);
@@ -3270,7 +3270,7 @@ out_nounlock:
  * len: the size of the address.
  */
 SCTP_STATIC int sctp_connect(struct sock *sk, struct sockaddr *addr,
-			     int addr_len)
+			     int addr_len, int flags)
 {
 	int err = 0;
 	struct sctp_af *af;
@@ -3288,7 +3288,7 @@ SCTP_STATIC int sctp_connect(struct sock *sk, struct sockaddr *addr,
 		/* Pass correct addr len to common routine (so it knows there
 		 * is only one address being passed.
 		 */
-		err = __sctp_connect(sk, addr, af->sockaddr_len);
+		err = __sctp_connect(sk, addr, af->sockaddr_len, flags);
 	}
 
 	sctp_release_sock(sk);
