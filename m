From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inet: add RCU protection to inet->opt
Date: Thu, 21 Apr 2011 21:45:37 +0200
Message-ID: <1303415137.2784.23.camel@edumazet-laptop>
References: <1302881994.3613.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41959 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab1DUTpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 15:45:44 -0400
Received: by wya21 with SMTP id 21so46486wya.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 12:45:42 -0700 (PDT)
In-Reply-To: <1302881994.3613.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 15 avril 2011 =C3=A0 17:39 +0200, Eric Dumazet a =C3=A9crit=
 :
> In commit 903ab86d19 (udp: Add lockless transmit path), we added a
> fastpath to avoid taking socket lock if we dont use corking.
>=20
> Prior work were commit 1c32c5ad6fac8c (inet: Add ip_make_skb and
> ip_finish_skb) and commit 1470ddf7f8cecf776921e5 (inet: Remove explic=
it
> write references to sk/inet in ip_append_data)
>=20
> Problem is ip_make_skb() calls ip_setup_cork() and
> ip_setup_cork() possibly makes a copy of ipc->opt (struct ip_options)=
,
> without any protection against another thread manipulating inet->opt.
>=20
> Another thread can change inet->opt pointer and free old one... kaboo=
m.
>=20
> This was discovered by code analysis (I am trying to remove the zeroi=
ng
> of cork variable in ip_make_skb(), since its a bit expensive and
> probably useless)
>=20
> Note : race was there before Herbert patches.
>=20
> My plan is to add RCU protection on inet->opt, unless someone has bet=
ter
> idea ?
>=20
>=20

OK, here is the patch I cooked to address this problem, on top of
net-next-2.6

[PATCH] inet: add RCU protection to inet->opt

We lack proper synchronization to manipulate inet->opt ip_options

Problem is ip_make_skb() calls ip_setup_cork() and
ip_setup_cork() possibly makes a copy of ipc->opt (struct ip_options),
without any protection against another thread manipulating inet->opt.

Another thread can change inet->opt pointer and free old one under us.

Use RCU to protect inet->opt (changed to inet->inet_opt).

Instead of handling atomic refcounts, just copy ip_options when
necessary, to avoid cache line dirtying.

We cant insert an rcu_head in struct ip_options since its included in
skb->cb[], so this patch is large because I had to introduce a new
ip_options_rcu structure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/net/inet_sock.h         |   14 ++-
 include/net/ip.h                |   11 +-
 net/dccp/ipv4.c                 |   16 ++--
 net/dccp/ipv6.c                 |    2=20
 net/ipv4/af_inet.c              |   17 +++-
 net/ipv4/cipso_ipv4.c           |  113 ++++++++++++++++--------------
 net/ipv4/icmp.c                 |   23 ++----
 net/ipv4/inet_connection_sock.c |    6 -
 net/ipv4/ip_options.c           |   38 ++++------
 net/ipv4/ip_output.c            |   44 +++++------
 net/ipv4/ip_sockglue.c          |   35 ++++++---
 net/ipv4/raw.c                  |   20 ++++-
 net/ipv4/syncookies.c           |    4 -
 net/ipv4/tcp_ipv4.c             |   34 +++++----
 net/ipv4/udp.c                  |   22 ++++-
 net/ipv6/tcp_ipv6.c             |    2=20
 16 files changed, 236 insertions(+), 165 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 7a37369..ed2ba6e 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -57,7 +57,15 @@ struct ip_options {
 	unsigned char	__data[0];
 };
=20
-#define optlength(opt) (sizeof(struct ip_options) + opt->optlen)
+struct ip_options_rcu {
+	struct rcu_head rcu;
+	struct ip_options opt;
+};
+
+struct ip_options_data {
+	struct ip_options_rcu	opt;
+	char			data[40];
+};
=20
 struct inet_request_sock {
 	struct request_sock	req;
@@ -78,7 +86,7 @@ struct inet_request_sock {
 				acked	   : 1,
 				no_srccheck: 1;
 	kmemcheck_bitfield_end(flags);
-	struct ip_options	*opt;
+	struct ip_options_rcu	*opt;
 };
=20
 static inline struct inet_request_sock *inet_rsk(const struct request_=
sock *sk)
@@ -140,7 +148,7 @@ struct inet_sock {
 	__be16			inet_sport;
 	__u16			inet_id;
=20
-	struct ip_options	*opt;
+	struct ip_options_rcu __rcu	*inet_opt;
 	__u8			tos;
 	__u8			min_ttl;
 	__u8			mc_ttl;
diff --git a/include/net/ip.h b/include/net/ip.h
index 7c41658..3a59bf9 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -52,7 +52,7 @@ static inline unsigned int ip_hdrlen(const struct sk_=
buff *skb)
 struct ipcm_cookie {
 	__be32			addr;
 	int			oif;
-	struct ip_options	*opt;
+	struct ip_options_rcu	*opt;
 	__u8			tx_flags;
 };
=20
@@ -92,7 +92,7 @@ extern int		igmp_mc_proc_init(void);
=20
 extern int		ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk=
,
 					      __be32 saddr, __be32 daddr,
-					      struct ip_options *opt);
+					      struct ip_options_rcu *opt);
 extern int		ip_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt, struct net_device *orig_dev);
 extern int		ip_local_deliver(struct sk_buff *skb);
@@ -416,14 +416,15 @@ extern int ip_forward(struct sk_buff *skb);
  *	Functions provided by ip_options.c
  */
 =20
-extern void ip_options_build(struct sk_buff *skb, struct ip_options *o=
pt, __be32 daddr, struct rtable *rt, int is_frag);
+extern void ip_options_build(struct sk_buff *skb, struct ip_options *o=
pt,
+			     __be32 daddr, struct rtable *rt, int is_frag);
 extern int ip_options_echo(struct ip_options *dopt, struct sk_buff *sk=
b);
 extern void ip_options_fragment(struct sk_buff *skb);
 extern int ip_options_compile(struct net *net,
 			      struct ip_options *opt, struct sk_buff *skb);
-extern int ip_options_get(struct net *net, struct ip_options **optp,
+extern int ip_options_get(struct net *net, struct ip_options_rcu **opt=
p,
 			  unsigned char *data, int optlen);
-extern int ip_options_get_from_user(struct net *net, struct ip_options=
 **optp,
+extern int ip_options_get_from_user(struct net *net, struct ip_options=
_rcu **optp,
 				    unsigned char __user *data, int optlen);
 extern void ip_options_undo(struct ip_options * opt);
 extern void ip_forward_options(struct sk_buff *skb);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ae451c6..1f54ee2 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -47,6 +47,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr =
*uaddr, int addr_len)
 	struct rtable *rt;
 	__be32 daddr, nexthop;
 	int err;
+	struct ip_options_rcu *inet_opt;
=20
 	dp->dccps_role =3D DCCP_ROLE_CLIENT;
=20
@@ -57,10 +58,13 @@ int dccp_v4_connect(struct sock *sk, struct sockadd=
r *uaddr, int addr_len)
 		return -EAFNOSUPPORT;
=20
 	nexthop =3D daddr =3D usin->sin_addr.s_addr;
-	if (inet->opt !=3D NULL && inet->opt->srr) {
+
+	inet_opt =3D rcu_dereference_protected(inet->inet_opt,
+					     sock_owned_by_user(sk));
+	if (inet_opt !=3D NULL && inet_opt->opt.srr) {
 		if (daddr =3D=3D 0)
 			return -EINVAL;
-		nexthop =3D inet->opt->faddr;
+		nexthop =3D inet_opt->opt.faddr;
 	}
=20
 	orig_sport =3D inet->inet_sport;
@@ -77,7 +81,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr =
*uaddr, int addr_len)
 		return -ENETUNREACH;
 	}
=20
-	if (inet->opt =3D=3D NULL || !inet->opt->srr)
+	if (inet_opt =3D=3D NULL || !inet_opt->opt.srr)
 		daddr =3D rt->rt_dst;
=20
 	if (inet->inet_saddr =3D=3D 0)
@@ -88,8 +92,8 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr =
*uaddr, int addr_len)
 	inet->inet_daddr =3D daddr;
=20
 	inet_csk(sk)->icsk_ext_hdr_len =3D 0;
-	if (inet->opt !=3D NULL)
-		inet_csk(sk)->icsk_ext_hdr_len =3D inet->opt->optlen;
+	if (inet_opt)
+		inet_csk(sk)->icsk_ext_hdr_len =3D inet_opt->opt.optlen;
 	/*
 	 * Socket identity is still unknown (sport may be zero).
 	 * However we set state to DCCP_REQUESTING and not releasing socket
@@ -405,7 +409,7 @@ struct sock *dccp_v4_request_recv_sock(struct sock =
*sk, struct sk_buff *skb,
 	newinet->inet_daddr	=3D ireq->rmt_addr;
 	newinet->inet_rcv_saddr =3D ireq->loc_addr;
 	newinet->inet_saddr	=3D ireq->loc_addr;
-	newinet->opt	   =3D ireq->opt;
+	newinet->inet_opt	=3D ireq->opt;
 	ireq->opt	   =3D NULL;
 	newinet->mc_index  =3D inet_iif(skb);
 	newinet->mc_ttl	   =3D ip_hdr(skb)->ttl;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index de1b7e3..43eba99 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -573,7 +573,7 @@ static struct sock *dccp_v6_request_recv_sock(struc=
t sock *sk,
=20
 	   First: no IPv4 options.
 	 */
-	newinet->opt =3D NULL;
+	newinet->inet_opt =3D NULL;
=20
 	/* Clone RX bits */
 	newnp->rxopt.all =3D np->rxopt.all;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 807d83c..01ae9b5 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -153,7 +153,7 @@ void inet_sock_destruct(struct sock *sk)
 	WARN_ON(sk->sk_wmem_queued);
 	WARN_ON(sk->sk_forward_alloc);
=20
-	kfree(inet->opt);
+	kfree(rcu_dereference_protected(inet->inet_opt, 1));
 	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
 	sk_refcnt_debug_dec(sk);
 }
@@ -1105,9 +1105,12 @@ static int inet_sk_reselect_saddr(struct sock *s=
k)
 	__be32 daddr =3D inet->inet_daddr;
 	struct rtable *rt;
 	__be32 new_saddr;
+	struct ip_options_rcu *inet_opt;
=20
-	if (inet->opt && inet->opt->srr)
-		daddr =3D inet->opt->faddr;
+	inet_opt =3D rcu_dereference_protected(inet->inet_opt,
+					     sock_owned_by_user(sk));
+	if (inet_opt && inet_opt->opt.srr)
+		daddr =3D inet_opt->opt.faddr;
=20
 	/* Query new route. */
 	rt =3D ip_route_connect(daddr, 0, RT_CONN_FLAGS(sk),
@@ -1147,6 +1150,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	struct inet_sock *inet =3D inet_sk(sk);
 	struct rtable *rt =3D (struct rtable *)__sk_dst_check(sk, 0);
 	__be32 daddr;
+	struct ip_options_rcu *inet_opt;
 	int err;
=20
 	/* Route is OK, nothing to do. */
@@ -1154,9 +1158,12 @@ int inet_sk_rebuild_header(struct sock *sk)
 		return 0;
=20
 	/* Reroute. */
+	rcu_read_lock();
+	inet_opt =3D rcu_dereference(inet->inet_opt);
 	daddr =3D inet->inet_daddr;
-	if (inet->opt && inet->opt->srr)
-		daddr =3D inet->opt->faddr;
+	if (inet_opt && inet_opt->opt.srr)
+		daddr =3D inet_opt->opt.faddr;
+	rcu_read_unlock();
 	rt =3D ip_route_output_ports(sock_net(sk), sk, daddr, inet->inet_sadd=
r,
 				   inet->inet_dport, inet->inet_sport,
 				   sk->sk_protocol, RT_CONN_FLAGS(sk),
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index a0af7ea..2b3c23c 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1857,6 +1857,11 @@ static int cipso_v4_genopt(unsigned char *buf, u=
32 buf_len,
 	return CIPSO_V4_HDR_LEN + ret_val;
 }
=20
+static void opt_kfree_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ip_options_rcu, rcu));
+}
+
 /**
  * cipso_v4_sock_setattr - Add a CIPSO option to a socket
  * @sk: the socket
@@ -1879,7 +1884,7 @@ int cipso_v4_sock_setattr(struct sock *sk,
 	unsigned char *buf =3D NULL;
 	u32 buf_len;
 	u32 opt_len;
-	struct ip_options *opt =3D NULL;
+	struct ip_options_rcu *old, *opt =3D NULL;
 	struct inet_sock *sk_inet;
 	struct inet_connection_sock *sk_conn;
=20
@@ -1915,22 +1920,25 @@ int cipso_v4_sock_setattr(struct sock *sk,
 		ret_val =3D -ENOMEM;
 		goto socket_setattr_failure;
 	}
-	memcpy(opt->__data, buf, buf_len);
-	opt->optlen =3D opt_len;
-	opt->cipso =3D sizeof(struct iphdr);
+	memcpy(opt->opt.__data, buf, buf_len);
+	opt->opt.optlen =3D opt_len;
+	opt->opt.cipso =3D sizeof(struct iphdr);
 	kfree(buf);
 	buf =3D NULL;
=20
 	sk_inet =3D inet_sk(sk);
+
+	old =3D rcu_dereference_protected(sk_inet->inet_opt, sock_owned_by_us=
er(sk));
 	if (sk_inet->is_icsk) {
 		sk_conn =3D inet_csk(sk);
-		if (sk_inet->opt)
-			sk_conn->icsk_ext_hdr_len -=3D sk_inet->opt->optlen;
-		sk_conn->icsk_ext_hdr_len +=3D opt->optlen;
+		if (old)
+			sk_conn->icsk_ext_hdr_len -=3D old->opt.optlen;
+		sk_conn->icsk_ext_hdr_len +=3D opt->opt.optlen;
 		sk_conn->icsk_sync_mss(sk, sk_conn->icsk_pmtu_cookie);
 	}
-	opt =3D xchg(&sk_inet->opt, opt);
-	kfree(opt);
+	rcu_assign_pointer(sk_inet->inet_opt, opt);
+	if (old)
+		call_rcu(&old->rcu, opt_kfree_rcu);
=20
 	return 0;
=20
@@ -1960,7 +1968,7 @@ int cipso_v4_req_setattr(struct request_sock *req=
,
 	unsigned char *buf =3D NULL;
 	u32 buf_len;
 	u32 opt_len;
-	struct ip_options *opt =3D NULL;
+	struct ip_options_rcu *opt =3D NULL;
 	struct inet_request_sock *req_inet;
=20
 	/* We allocate the maximum CIPSO option size here so we are probably
@@ -1988,15 +1996,16 @@ int cipso_v4_req_setattr(struct request_sock *r=
eq,
 		ret_val =3D -ENOMEM;
 		goto req_setattr_failure;
 	}
-	memcpy(opt->__data, buf, buf_len);
-	opt->optlen =3D opt_len;
-	opt->cipso =3D sizeof(struct iphdr);
+	memcpy(opt->opt.__data, buf, buf_len);
+	opt->opt.optlen =3D opt_len;
+	opt->opt.cipso =3D sizeof(struct iphdr);
 	kfree(buf);
 	buf =3D NULL;
=20
 	req_inet =3D inet_rsk(req);
 	opt =3D xchg(&req_inet->opt, opt);
-	kfree(opt);
+	if (opt)
+		call_rcu(&opt->rcu, opt_kfree_rcu);
=20
 	return 0;
=20
@@ -2016,34 +2025,34 @@ req_setattr_failure:
  * values on failure.
  *
  */
-static int cipso_v4_delopt(struct ip_options **opt_ptr)
+static int cipso_v4_delopt(struct ip_options_rcu **opt_ptr)
 {
 	int hdr_delta =3D 0;
-	struct ip_options *opt =3D *opt_ptr;
+	struct ip_options_rcu *opt =3D *opt_ptr;
=20
-	if (opt->srr || opt->rr || opt->ts || opt->router_alert) {
+	if (opt->opt.srr || opt->opt.rr || opt->opt.ts || opt->opt.router_ale=
rt) {
 		u8 cipso_len;
 		u8 cipso_off;
 		unsigned char *cipso_ptr;
 		int iter;
 		int optlen_new;
=20
-		cipso_off =3D opt->cipso - sizeof(struct iphdr);
-		cipso_ptr =3D &opt->__data[cipso_off];
+		cipso_off =3D opt->opt.cipso - sizeof(struct iphdr);
+		cipso_ptr =3D &opt->opt.__data[cipso_off];
 		cipso_len =3D cipso_ptr[1];
=20
-		if (opt->srr > opt->cipso)
-			opt->srr -=3D cipso_len;
-		if (opt->rr > opt->cipso)
-			opt->rr -=3D cipso_len;
-		if (opt->ts > opt->cipso)
-			opt->ts -=3D cipso_len;
-		if (opt->router_alert > opt->cipso)
-			opt->router_alert -=3D cipso_len;
-		opt->cipso =3D 0;
+		if (opt->opt.srr > opt->opt.cipso)
+			opt->opt.srr -=3D cipso_len;
+		if (opt->opt.rr > opt->opt.cipso)
+			opt->opt.rr -=3D cipso_len;
+		if (opt->opt.ts > opt->opt.cipso)
+			opt->opt.ts -=3D cipso_len;
+		if (opt->opt.router_alert > opt->opt.cipso)
+			opt->opt.router_alert -=3D cipso_len;
+		opt->opt.cipso =3D 0;
=20
 		memmove(cipso_ptr, cipso_ptr + cipso_len,
-			opt->optlen - cipso_off - cipso_len);
+			opt->opt.optlen - cipso_off - cipso_len);
=20
 		/* determining the new total option length is tricky because of
 		 * the padding necessary, the only thing i can think to do at
@@ -2052,21 +2061,21 @@ static int cipso_v4_delopt(struct ip_options **=
opt_ptr)
 		 * from there we can determine the new total option length */
 		iter =3D 0;
 		optlen_new =3D 0;
-		while (iter < opt->optlen)
-			if (opt->__data[iter] !=3D IPOPT_NOP) {
-				iter +=3D opt->__data[iter + 1];
+		while (iter < opt->opt.optlen)
+			if (opt->opt.__data[iter] !=3D IPOPT_NOP) {
+				iter +=3D opt->opt.__data[iter + 1];
 				optlen_new =3D iter;
 			} else
 				iter++;
-		hdr_delta =3D opt->optlen;
-		opt->optlen =3D (optlen_new + 3) & ~3;
-		hdr_delta -=3D opt->optlen;
+		hdr_delta =3D opt->opt.optlen;
+		opt->opt.optlen =3D (optlen_new + 3) & ~3;
+		hdr_delta -=3D opt->opt.optlen;
 	} else {
 		/* only the cipso option was present on the socket so we can
 		 * remove the entire option struct */
 		*opt_ptr =3D NULL;
-		hdr_delta =3D opt->optlen;
-		kfree(opt);
+		hdr_delta =3D opt->opt.optlen;
+		call_rcu(&opt->rcu, opt_kfree_rcu);
 	}
=20
 	return hdr_delta;
@@ -2083,15 +2092,15 @@ static int cipso_v4_delopt(struct ip_options **=
opt_ptr)
 void cipso_v4_sock_delattr(struct sock *sk)
 {
 	int hdr_delta;
-	struct ip_options *opt;
+	struct ip_options_rcu *opt;
 	struct inet_sock *sk_inet;
=20
 	sk_inet =3D inet_sk(sk);
-	opt =3D sk_inet->opt;
-	if (opt =3D=3D NULL || opt->cipso =3D=3D 0)
+	opt =3D rcu_dereference_protected(sk_inet->inet_opt, 1);
+	if (opt =3D=3D NULL || opt->opt.cipso =3D=3D 0)
 		return;
=20
-	hdr_delta =3D cipso_v4_delopt(&sk_inet->opt);
+	hdr_delta =3D cipso_v4_delopt(&sk_inet->inet_opt);
 	if (sk_inet->is_icsk && hdr_delta > 0) {
 		struct inet_connection_sock *sk_conn =3D inet_csk(sk);
 		sk_conn->icsk_ext_hdr_len -=3D hdr_delta;
@@ -2109,12 +2118,12 @@ void cipso_v4_sock_delattr(struct sock *sk)
  */
 void cipso_v4_req_delattr(struct request_sock *req)
 {
-	struct ip_options *opt;
+	struct ip_options_rcu *opt;
 	struct inet_request_sock *req_inet;
=20
 	req_inet =3D inet_rsk(req);
 	opt =3D req_inet->opt;
-	if (opt =3D=3D NULL || opt->cipso =3D=3D 0)
+	if (opt =3D=3D NULL || opt->opt.cipso =3D=3D 0)
 		return;
=20
 	cipso_v4_delopt(&req_inet->opt);
@@ -2184,14 +2193,18 @@ getattr_return:
  */
 int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *=
secattr)
 {
-	struct ip_options *opt;
+	struct ip_options_rcu *opt;
+	int res =3D -ENOMSG;
=20
-	opt =3D inet_sk(sk)->opt;
-	if (opt =3D=3D NULL || opt->cipso =3D=3D 0)
-		return -ENOMSG;
-
-	return cipso_v4_getattr(opt->__data + opt->cipso - sizeof(struct iphd=
r),
-				secattr);
+	rcu_read_lock();
+	opt =3D rcu_dereference(inet_sk(sk)->inet_opt);
+	if (opt && opt->opt.cipso)
+		res =3D cipso_v4_getattr(opt->opt.__data +
+						opt->opt.cipso -
+						sizeof(struct iphdr),
+				       secattr);
+	rcu_read_unlock();
+	return res;
 }
=20
 /**
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e5f8a71..831e7dc 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -108,8 +108,7 @@ struct icmp_bxm {
 		__be32	       times[3];
 	} data;
 	int head_len;
-	struct ip_options replyopts;
-	unsigned char  optbuf[40];
+	struct ip_options_data replyopts;
 };
=20
 /* An array of errno for error messages from dest unreach. */
@@ -333,7 +332,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param,=
 struct sk_buff *skb)
 	struct inet_sock *inet;
 	__be32 daddr;
=20
-	if (ip_options_echo(&icmp_param->replyopts, skb))
+	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb))
 		return;
=20
 	sk =3D icmp_xmit_lock(net);
@@ -347,10 +346,10 @@ static void icmp_reply(struct icmp_bxm *icmp_para=
m, struct sk_buff *skb)
 	daddr =3D ipc.addr =3D rt->rt_src;
 	ipc.opt =3D NULL;
 	ipc.tx_flags =3D 0;
-	if (icmp_param->replyopts.optlen) {
-		ipc.opt =3D &icmp_param->replyopts;
-		if (ipc.opt->srr)
-			daddr =3D icmp_param->replyopts.faddr;
+	if (icmp_param->replyopts.opt.opt.optlen) {
+		ipc.opt =3D &icmp_param->replyopts.opt;
+		if (ipc.opt->opt.srr)
+			daddr =3D icmp_param->replyopts.opt.opt.faddr;
 	}
 	{
 		struct flowi4 fl4 =3D {
@@ -379,8 +378,8 @@ static struct rtable *icmp_route_lookup(struct net =
*net, struct sk_buff *skb_in,
 					struct icmp_bxm *param)
 {
 	struct flowi4 fl4 =3D {
-		.daddr =3D (param->replyopts.srr ?
-			  param->replyopts.faddr : iph->saddr),
+		.daddr =3D (param->replyopts.opt.opt.srr ?
+			  param->replyopts.opt.opt.faddr : iph->saddr),
 		.saddr =3D saddr,
 		.flowi4_tos =3D RT_TOS(tos),
 		.flowi4_proto =3D IPPROTO_ICMP,
@@ -581,7 +580,7 @@ void icmp_send(struct sk_buff *skb_in, int type, in=
t code, __be32 info)
 					   IPTOS_PREC_INTERNETCONTROL) :
 					  iph->tos;
=20
-	if (ip_options_echo(&icmp_param.replyopts, skb_in))
+	if (ip_options_echo(&icmp_param.replyopts.opt.opt, skb_in))
 		goto out_unlock;
=20
=20
@@ -597,7 +596,7 @@ void icmp_send(struct sk_buff *skb_in, int type, in=
t code, __be32 info)
 	icmp_param.offset =3D skb_network_offset(skb_in);
 	inet_sk(sk)->tos =3D tos;
 	ipc.addr =3D iph->saddr;
-	ipc.opt =3D &icmp_param.replyopts;
+	ipc.opt =3D &icmp_param.replyopts.opt;
 	ipc.tx_flags =3D 0;
=20
 	rt =3D icmp_route_lookup(net, skb_in, iph, saddr, tos,
@@ -613,7 +612,7 @@ void icmp_send(struct sk_buff *skb_in, int type, in=
t code, __be32 info)
 	room =3D dst_mtu(&rt->dst);
 	if (room > 576)
 		room =3D 576;
-	room -=3D sizeof(struct iphdr) + icmp_param.replyopts.optlen;
+	room -=3D sizeof(struct iphdr) + icmp_param.replyopts.opt.opt.optlen;
 	room -=3D sizeof(struct icmphdr);
=20
 	icmp_param.data_len =3D skb_in->len - icmp_param.offset;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 8514db5..3282cb2 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -354,20 +354,20 @@ struct dst_entry *inet_csk_route_req(struct sock =
*sk,
 {
 	struct rtable *rt;
 	const struct inet_request_sock *ireq =3D inet_rsk(req);
-	struct ip_options *opt =3D inet_rsk(req)->opt;
+	struct ip_options_rcu *opt =3D inet_rsk(req)->opt;
 	struct net *net =3D sock_net(sk);
 	struct flowi4 fl4;
=20
 	flowi4_init_output(&fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
-			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
+			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->rmt_addr,
 			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt =3D ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
-	if (opt && opt->is_strictroute && rt->rt_dst !=3D rt->rt_gateway)
+	if (opt && opt->opt.is_strictroute && rt->rt_dst !=3D rt->rt_gateway)
 		goto route_err;
 	return &rt->dst;
=20
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 2391b24..01fc409 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -36,7 +36,7 @@
  * saddr is address of outgoing interface.
  */
=20
-void ip_options_build(struct sk_buff * skb, struct ip_options * opt,
+void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
 			    __be32 daddr, struct rtable *rt, int is_frag)
 {
 	unsigned char *iph =3D skb_network_header(skb);
@@ -83,9 +83,9 @@ void ip_options_build(struct sk_buff * skb, struct ip=
_options * opt,
  * NOTE: dopt cannot point to skb.
  */
=20
-int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
+int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
 {
-	struct ip_options *sopt;
+	const struct ip_options *sopt;
 	unsigned char *sptr, *dptr;
 	int soffset, doffset;
 	int	optlen;
@@ -95,10 +95,8 @@ int ip_options_echo(struct ip_options * dopt, struct=
 sk_buff * skb)
=20
 	sopt =3D &(IPCB(skb)->opt);
=20
-	if (sopt->optlen =3D=3D 0) {
-		dopt->optlen =3D 0;
+	if (sopt->optlen =3D=3D 0)
 		return 0;
-	}
=20
 	sptr =3D skb_network_header(skb);
 	dptr =3D dopt->__data;
@@ -157,7 +155,7 @@ int ip_options_echo(struct ip_options * dopt, struc=
t sk_buff * skb)
 		dopt->optlen +=3D optlen;
 	}
 	if (sopt->srr) {
-		unsigned char * start =3D sptr+sopt->srr;
+		unsigned char *start =3D sptr+sopt->srr;
 		__be32 faddr;
=20
 		optlen  =3D start[1];
@@ -499,19 +497,19 @@ void ip_options_undo(struct ip_options * opt)
 	}
 }
=20
-static struct ip_options *ip_options_get_alloc(const int optlen)
+static struct ip_options_rcu *ip_options_get_alloc(const int optlen)
 {
-	return kzalloc(sizeof(struct ip_options) + ((optlen + 3) & ~3),
+	return kzalloc(sizeof(struct ip_options_rcu) + ((optlen + 3) & ~3),
 		       GFP_KERNEL);
 }
=20
-static int ip_options_get_finish(struct net *net, struct ip_options **=
optp,
-				 struct ip_options *opt, int optlen)
+static int ip_options_get_finish(struct net *net, struct ip_options_rc=
u **optp,
+				 struct ip_options_rcu *opt, int optlen)
 {
 	while (optlen & 3)
-		opt->__data[optlen++] =3D IPOPT_END;
-	opt->optlen =3D optlen;
-	if (optlen && ip_options_compile(net, opt, NULL)) {
+		opt->opt.__data[optlen++] =3D IPOPT_END;
+	opt->opt.optlen =3D optlen;
+	if (optlen && ip_options_compile(net, &opt->opt, NULL)) {
 		kfree(opt);
 		return -EINVAL;
 	}
@@ -520,29 +518,29 @@ static int ip_options_get_finish(struct net *net,=
 struct ip_options **optp,
 	return 0;
 }
=20
-int ip_options_get_from_user(struct net *net, struct ip_options **optp=
,
+int ip_options_get_from_user(struct net *net, struct ip_options_rcu **=
optp,
 			     unsigned char __user *data, int optlen)
 {
-	struct ip_options *opt =3D ip_options_get_alloc(optlen);
+	struct ip_options_rcu *opt =3D ip_options_get_alloc(optlen);
=20
 	if (!opt)
 		return -ENOMEM;
-	if (optlen && copy_from_user(opt->__data, data, optlen)) {
+	if (optlen && copy_from_user(opt->opt.__data, data, optlen)) {
 		kfree(opt);
 		return -EFAULT;
 	}
 	return ip_options_get_finish(net, optp, opt, optlen);
 }
=20
-int ip_options_get(struct net *net, struct ip_options **optp,
+int ip_options_get(struct net *net, struct ip_options_rcu **optp,
 		   unsigned char *data, int optlen)
 {
-	struct ip_options *opt =3D ip_options_get_alloc(optlen);
+	struct ip_options_rcu *opt =3D ip_options_get_alloc(optlen);
=20
 	if (!opt)
 		return -ENOMEM;
 	if (optlen)
-		memcpy(opt->__data, data, optlen);
+		memcpy(opt->opt.__data, data, optlen);
 	return ip_options_get_finish(net, optp, opt, optlen);
 }
=20
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index bdad3d6..362e66f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -140,14 +140,14 @@ static inline int ip_select_ttl(struct inet_sock =
*inet, struct dst_entry *dst)
  *
  */
 int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
-			  __be32 saddr, __be32 daddr, struct ip_options *opt)
+			  __be32 saddr, __be32 daddr, struct ip_options_rcu *opt)
 {
 	struct inet_sock *inet =3D inet_sk(sk);
 	struct rtable *rt =3D skb_rtable(skb);
 	struct iphdr *iph;
=20
 	/* Build the IP header. */
-	skb_push(skb, sizeof(struct iphdr) + (opt ? opt->optlen : 0));
+	skb_push(skb, sizeof(struct iphdr) + (opt ? opt->opt.optlen : 0));
 	skb_reset_network_header(skb);
 	iph =3D ip_hdr(skb);
 	iph->version  =3D 4;
@@ -163,9 +163,9 @@ int ip_build_and_send_pkt(struct sk_buff *skb, stru=
ct sock *sk,
 	iph->protocol =3D sk->sk_protocol;
 	ip_select_ident(iph, &rt->dst, sk);
=20
-	if (opt && opt->optlen) {
-		iph->ihl +=3D opt->optlen>>2;
-		ip_options_build(skb, opt, daddr, rt, 0);
+	if (opt && opt->opt.optlen) {
+		iph->ihl +=3D opt->opt.optlen>>2;
+		ip_options_build(skb, &opt->opt, daddr, rt, 0);
 	}
=20
 	skb->priority =3D sk->sk_priority;
@@ -316,7 +316,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 {
 	struct sock *sk =3D skb->sk;
 	struct inet_sock *inet =3D inet_sk(sk);
-	struct ip_options *opt =3D inet->opt;
+	struct ip_options_rcu *inet_opt;
 	struct rtable *rt;
 	struct iphdr *iph;
 	int res;
@@ -325,6 +325,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 	 * f.e. by something like SCTP.
 	 */
 	rcu_read_lock();
+	inet_opt =3D rcu_dereference(inet->inet_opt);
 	rt =3D skb_rtable(skb);
 	if (rt !=3D NULL)
 		goto packet_routed;
@@ -336,8 +337,8 @@ int ip_queue_xmit(struct sk_buff *skb)
=20
 		/* Use correct destination address if we have options. */
 		daddr =3D inet->inet_daddr;
-		if(opt && opt->srr)
-			daddr =3D opt->faddr;
+		if (inet_opt && inet_opt->opt.srr)
+			daddr =3D inet_opt->opt.faddr;
=20
 		/* If this fails, retransmit mechanism of transport layer will
 		 * keep trying until route appears or the connection times
@@ -357,11 +358,11 @@ int ip_queue_xmit(struct sk_buff *skb)
 	skb_dst_set_noref(skb, &rt->dst);
=20
 packet_routed:
-	if (opt && opt->is_strictroute && rt->rt_dst !=3D rt->rt_gateway)
+	if (inet_opt && inet_opt->opt.is_strictroute && rt->rt_dst !=3D rt->r=
t_gateway)
 		goto no_route;
=20
 	/* OK, we know where to send it, allocate and build IP header. */
-	skb_push(skb, sizeof(struct iphdr) + (opt ? opt->optlen : 0));
+	skb_push(skb, sizeof(struct iphdr) + (inet_opt ? inet_opt->opt.optlen=
 : 0));
 	skb_reset_network_header(skb);
 	iph =3D ip_hdr(skb);
 	*((__be16 *)iph) =3D htons((4 << 12) | (5 << 8) | (inet->tos & 0xff))=
;
@@ -375,9 +376,9 @@ packet_routed:
 	iph->daddr    =3D rt->rt_dst;
 	/* Transport layer set skb->h.foo itself. */
=20
-	if (opt && opt->optlen) {
-		iph->ihl +=3D opt->optlen >> 2;
-		ip_options_build(skb, opt, inet->inet_daddr, rt, 0);
+	if (inet_opt && inet_opt->opt.optlen) {
+		iph->ihl +=3D inet_opt->opt.optlen >> 2;
+		ip_options_build(skb, &inet_opt->opt, inet->inet_daddr, rt, 0);
 	}
=20
 	ip_select_ident_more(iph, &rt->dst, sk,
@@ -1033,7 +1034,7 @@ static int ip_setup_cork(struct sock *sk, struct =
inet_cork *cork,
 			 struct ipcm_cookie *ipc, struct rtable **rtp)
 {
 	struct inet_sock *inet =3D inet_sk(sk);
-	struct ip_options *opt;
+	struct ip_options_rcu *opt;
 	struct rtable *rt;
=20
 	/*
@@ -1047,7 +1048,7 @@ static int ip_setup_cork(struct sock *sk, struct =
inet_cork *cork,
 			if (unlikely(cork->opt =3D=3D NULL))
 				return -ENOBUFS;
 		}
-		memcpy(cork->opt, opt, sizeof(struct ip_options) + opt->optlen);
+		memcpy(cork->opt, &opt->opt, sizeof(struct ip_options) + opt->opt.op=
tlen);
 		cork->flags |=3D IPCORK_OPT;
 		cork->addr =3D ipc->addr;
 	}
@@ -1451,26 +1452,23 @@ void ip_send_reply(struct sock *sk, struct sk_b=
uff *skb, struct ip_reply_arg *ar
 		   unsigned int len)
 {
 	struct inet_sock *inet =3D inet_sk(sk);
-	struct {
-		struct ip_options	opt;
-		char			data[40];
-	} replyopts;
+	struct ip_options_data replyopts;
 	struct ipcm_cookie ipc;
 	__be32 daddr;
 	struct rtable *rt =3D skb_rtable(skb);
=20
-	if (ip_options_echo(&replyopts.opt, skb))
+	if (ip_options_echo(&replyopts.opt.opt, skb))
 		return;
=20
 	daddr =3D ipc.addr =3D rt->rt_src;
 	ipc.opt =3D NULL;
 	ipc.tx_flags =3D 0;
=20
-	if (replyopts.opt.optlen) {
+	if (replyopts.opt.opt.optlen) {
 		ipc.opt =3D &replyopts.opt;
=20
-		if (ipc.opt->srr)
-			daddr =3D replyopts.opt.faddr;
+		if (replyopts.opt.opt.srr)
+			daddr =3D replyopts.opt.opt.faddr;
 	}
=20
 	{
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 3948c86..68cdf2b 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -451,6 +451,11 @@ out:
 }
=20
=20
+static void opt_kfree_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ip_options_rcu, rcu));
+}
+
 /*
  *	Socket option code for IP. This is the end of the line after any
  *	TCP,UDP etc options on an IP socket.
@@ -497,13 +502,16 @@ static int do_ip_setsockopt(struct sock *sk, int =
level,
 	switch (optname) {
 	case IP_OPTIONS:
 	{
-		struct ip_options *opt =3D NULL;
+		struct ip_options_rcu *old, *opt =3D NULL;
+
 		if (optlen > 40)
 			goto e_inval;
 		err =3D ip_options_get_from_user(sock_net(sk), &opt,
 					       optval, optlen);
 		if (err)
 			break;
+		old =3D rcu_dereference_protected(inet->inet_opt,
+						sock_owned_by_user(sk));
 		if (inet->is_icsk) {
 			struct inet_connection_sock *icsk =3D inet_csk(sk);
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -512,17 +520,18 @@ static int do_ip_setsockopt(struct sock *sk, int =
level,
 			       (TCPF_LISTEN | TCPF_CLOSE)) &&
 			     inet->inet_daddr !=3D LOOPBACK4_IPV6)) {
 #endif
-				if (inet->opt)
-					icsk->icsk_ext_hdr_len -=3D inet->opt->optlen;
+				if (old)
+					icsk->icsk_ext_hdr_len -=3D old->opt.optlen;
 				if (opt)
-					icsk->icsk_ext_hdr_len +=3D opt->optlen;
+					icsk->icsk_ext_hdr_len +=3D opt->opt.optlen;
 				icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 			}
 #endif
 		}
-		opt =3D xchg(&inet->opt, opt);
-		kfree(opt);
+		rcu_assign_pointer(inet->inet_opt, opt);
+		if (old)
+			call_rcu(&old->rcu, opt_kfree_rcu);
 		break;
 	}
 	case IP_PKTINFO:
@@ -1081,12 +1090,16 @@ static int do_ip_getsockopt(struct sock *sk, in=
t level, int optname,
 	case IP_OPTIONS:
 	{
 		unsigned char optbuf[sizeof(struct ip_options)+40];
-		struct ip_options * opt =3D (struct ip_options *)optbuf;
+		struct ip_options *opt =3D (struct ip_options *)optbuf;
+		struct ip_options_rcu *inet_opt;
+
+		inet_opt =3D rcu_dereference_protected(inet->inet_opt,
+						     sock_owned_by_user(sk));
 		opt->optlen =3D 0;
-		if (inet->opt)
-			memcpy(optbuf, inet->opt,
-			       sizeof(struct ip_options)+
-			       inet->opt->optlen);
+		if (inet_opt)
+			memcpy(optbuf, &inet_opt->opt,
+			       sizeof(struct ip_options) +
+			       inet_opt->opt.optlen);
 		release_sock(sk);
=20
 		if (opt->optlen =3D=3D 0)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2b50cc2..c577d25 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -460,6 +460,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct s=
ock *sk, struct msghdr *msg,
 	__be32 saddr;
 	u8  tos;
 	int err;
+	struct ip_options_data opt_copy;
=20
 	err =3D -EMSGSIZE;
 	if (len > 0xFFFF)
@@ -520,8 +521,18 @@ static int raw_sendmsg(struct kiocb *iocb, struct =
sock *sk, struct msghdr *msg,
 	saddr =3D ipc.addr;
 	ipc.addr =3D daddr;
=20
-	if (!ipc.opt)
-		ipc.opt =3D inet->opt;
+	if (!ipc.opt) {
+		struct ip_options_rcu *inet_opt;
+
+		rcu_read_lock();
+		inet_opt =3D rcu_dereference(inet->inet_opt);
+		if (inet_opt) {
+			memcpy(&opt_copy, inet_opt,
+			       sizeof(*inet_opt) + inet_opt->opt.optlen);
+			ipc.opt =3D &opt_copy.opt;
+		}
+		rcu_read_unlock();
+	}
=20
 	if (ipc.opt) {
 		err =3D -EINVAL;
@@ -530,10 +541,10 @@ static int raw_sendmsg(struct kiocb *iocb, struct=
 sock *sk, struct msghdr *msg,
 		 */
 		if (inet->hdrincl)
 			goto done;
-		if (ipc.opt->srr) {
+		if (ipc.opt->opt.srr) {
 			if (!daddr)
 				goto done;
-			daddr =3D ipc.opt->faddr;
+			daddr =3D ipc.opt->opt.faddr;
 		}
 	}
 	tos =3D RT_CONN_FLAGS(sk);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 71e0296..2646149 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -321,10 +321,10 @@ struct sock *cookie_v4_check(struct sock *sk, str=
uct sk_buff *skb,
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
 	 */
 	if (opt && opt->optlen) {
-		int opt_size =3D sizeof(struct ip_options) + opt->optlen;
+		int opt_size =3D sizeof(struct ip_options_rcu) + opt->optlen;
=20
 		ireq->opt =3D kmalloc(opt_size, GFP_ATOMIC);
-		if (ireq->opt !=3D NULL && ip_options_echo(ireq->opt, skb)) {
+		if (ireq->opt !=3D NULL && ip_options_echo(&ireq->opt->opt, skb)) {
 			kfree(ireq->opt);
 			ireq->opt =3D NULL;
 		}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f7e6c2c..d120f6f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -153,6 +153,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr=
 *uaddr, int addr_len)
 	struct rtable *rt;
 	__be32 daddr, nexthop;
 	int err;
+	struct ip_options_rcu *inet_opt;
=20
 	if (addr_len < sizeof(struct sockaddr_in))
 		return -EINVAL;
@@ -161,10 +162,12 @@ int tcp_v4_connect(struct sock *sk, struct sockad=
dr *uaddr, int addr_len)
 		return -EAFNOSUPPORT;
=20
 	nexthop =3D daddr =3D usin->sin_addr.s_addr;
-	if (inet->opt && inet->opt->srr) {
+	inet_opt =3D rcu_dereference_protected(inet->inet_opt,
+					     sock_owned_by_user(sk));
+	if (inet_opt && inet_opt->opt.srr) {
 		if (!daddr)
 			return -EINVAL;
-		nexthop =3D inet->opt->faddr;
+		nexthop =3D inet_opt->opt.faddr;
 	}
=20
 	orig_sport =3D inet->inet_sport;
@@ -185,7 +188,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr=
 *uaddr, int addr_len)
 		return -ENETUNREACH;
 	}
=20
-	if (!inet->opt || !inet->opt->srr)
+	if (!inet_opt || !inet_opt->opt.srr)
 		daddr =3D rt->rt_dst;
=20
 	if (!inet->inet_saddr)
@@ -221,8 +224,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr=
 *uaddr, int addr_len)
 	inet->inet_daddr =3D daddr;
=20
 	inet_csk(sk)->icsk_ext_hdr_len =3D 0;
-	if (inet->opt)
-		inet_csk(sk)->icsk_ext_hdr_len =3D inet->opt->optlen;
+	if (inet_opt)
+		inet_csk(sk)->icsk_ext_hdr_len =3D inet_opt->opt.optlen;
=20
 	tp->rx_opt.mss_clamp =3D TCP_MSS_DEFAULT;
=20
@@ -820,17 +823,18 @@ static void syn_flood_warning(const struct sk_buf=
f *skb)
 /*
  * Save and compile IPv4 options into the request_sock if needed.
  */
-static struct ip_options *tcp_v4_save_options(struct sock *sk,
-					      struct sk_buff *skb)
+static struct ip_options_rcu *tcp_v4_save_options(struct sock *sk,
+						  struct sk_buff *skb)
 {
-	struct ip_options *opt =3D &(IPCB(skb)->opt);
-	struct ip_options *dopt =3D NULL;
+	const struct ip_options *opt =3D &(IPCB(skb)->opt);
+	struct ip_options_rcu *dopt =3D NULL;
=20
 	if (opt && opt->optlen) {
-		int opt_size =3D optlength(opt);
+		int opt_size =3D sizeof(*dopt) + opt->optlen;
+
 		dopt =3D kmalloc(opt_size, GFP_ATOMIC);
 		if (dopt) {
-			if (ip_options_echo(dopt, skb)) {
+			if (ip_options_echo(&dopt->opt, skb)) {
 				kfree(dopt);
 				dopt =3D NULL;
 			}
@@ -1411,6 +1415,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk=
, struct sk_buff *skb,
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
+	struct ip_options_rcu *inet_opt;
=20
 	if (sk_acceptq_is_full(sk))
 		goto exit_overflow;
@@ -1431,13 +1436,14 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *=
sk, struct sk_buff *skb,
 	newinet->inet_daddr   =3D ireq->rmt_addr;
 	newinet->inet_rcv_saddr =3D ireq->loc_addr;
 	newinet->inet_saddr	      =3D ireq->loc_addr;
-	newinet->opt	      =3D ireq->opt;
+	inet_opt	      =3D ireq->opt;
+	rcu_assign_pointer(newinet->inet_opt, inet_opt);
 	ireq->opt	      =3D NULL;
 	newinet->mc_index     =3D inet_iif(skb);
 	newinet->mc_ttl	      =3D ip_hdr(skb)->ttl;
 	inet_csk(newsk)->icsk_ext_hdr_len =3D 0;
-	if (newinet->opt)
-		inet_csk(newsk)->icsk_ext_hdr_len =3D newinet->opt->optlen;
+	if (inet_opt)
+		inet_csk(newsk)->icsk_ext_hdr_len =3D inet_opt->opt.optlen;
 	newinet->inet_id =3D newtp->write_seq ^ jiffies;
=20
 	tcp_mtup_init(newsk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index a15c8fb..75d24ce 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -804,6 +804,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk=
, struct msghdr *msg,
 	int corkreq =3D up->corkflag || msg->msg_flags&MSG_MORE;
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 	struct sk_buff *skb;
+	struct ip_options_data opt_copy;
=20
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
@@ -877,22 +878,32 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
 			free =3D 1;
 		connected =3D 0;
 	}
-	if (!ipc.opt)
-		ipc.opt =3D inet->opt;
+	if (!ipc.opt) {
+		struct ip_options_rcu *inet_opt;
+
+		rcu_read_lock();
+		inet_opt =3D rcu_dereference(inet->inet_opt);
+		if (inet_opt) {
+			memcpy(&opt_copy, inet_opt,
+			       sizeof(*inet_opt) + inet_opt->opt.optlen);
+			ipc.opt =3D &opt_copy.opt;
+		}
+		rcu_read_unlock();
+	}
=20
 	saddr =3D ipc.addr;
 	ipc.addr =3D faddr =3D daddr;
=20
-	if (ipc.opt && ipc.opt->srr) {
+	if (ipc.opt && ipc.opt->opt.srr) {
 		if (!daddr)
 			return -EINVAL;
-		faddr =3D ipc.opt->faddr;
+		faddr =3D ipc.opt->opt.faddr;
 		connected =3D 0;
 	}
 	tos =3D RT_TOS(inet->tos);
 	if (sock_flag(sk, SOCK_LOCALROUTE) ||
 	    (msg->msg_flags & MSG_DONTROUTE) ||
-	    (ipc.opt && ipc.opt->is_strictroute)) {
+	    (ipc.opt && ipc.opt->opt.is_strictroute)) {
 		tos |=3D RTO_ONLINK;
 		connected =3D 0;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4f49e5d..2c6e606 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1469,7 +1469,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct =
sock *sk, struct sk_buff *skb,
=20
 	   First: no IPv4 options.
 	 */
-	newinet->opt =3D NULL;
+	newinet->inet_opt =3D NULL;
 	newnp->ipv6_fl_list =3D NULL;
=20
 	/* Clone RX bits */


