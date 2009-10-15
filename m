From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inet: rename some inet_sock fields
Date: Thu, 15 Oct 2009 18:30:45 +0200
Message-ID: <4AD74E35.9080004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58036 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932908AbZJOQb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 12:31:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to have better cache layouts of struct sock (separate zones
for rx/tx paths), we need this preliminary patch.

Goal is to transfert fields used at lookup time in the first
read-mostly cache line (inside struct sock_common) and move sk_refcnt
to a separate cache line (only written by rx path)

This patch adds inet_ prefix to daddr, rcv_saddr, dport, num, saddr,
sport and id fields. This allows a future patch to define these
fields as macros, like sk_refcnt, without name clashes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/pppol2tp.c                         |   22 ++--
 fs/ocfs2/cluster/netdebug.c                    |    8 -
 include/linux/ipv6.h                           |    2 
 include/net/inet6_hashtables.h                 |    4 
 include/net/inet_hashtables.h                  |   12 +-
 include/net/inet_sock.h                        |   36 +++----
 include/net/inet_timewait_sock.h               |    2 
 include/net/ip.h                               |   12 +-
 net/dccp/ipv4.c                                |   40 ++++----
 net/dccp/ipv6.c                                |   27 +++--
 net/dccp/output.c                              |    4 
 net/dccp/probe.c                               |   13 +-
 net/dccp/proto.c                               |    4 
 net/ipv4/af_inet.c                             |   62 ++++++-------
 net/ipv4/datagram.c                            |   18 +--
 net/ipv4/inet_connection_sock.c                |   20 ++--
 net/ipv4/inet_diag.c                           |   26 ++---
 net/ipv4/inet_hashtables.c                     |   34 +++----
 net/ipv4/inet_timewait_sock.c                  |   12 +-
 net/ipv4/ip_input.c                            |    2 
 net/ipv4/ip_output.c                           |   15 +--
 net/ipv4/ip_sockglue.c                         |    8 -
 net/ipv4/ipmr.c                                |    2 
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    8 -
 net/ipv4/raw.c                                 |   30 +++---
 net/ipv4/tcp.c                                 |    4 
 net/ipv4/tcp_ipv4.c                            |   70 +++++++--------
 net/ipv4/tcp_output.c                          |    4 
 net/ipv4/tcp_probe.c                           |   11 +-
 net/ipv4/tcp_timer.c                           |    8 -
 net/ipv4/udp.c                                 |   51 +++++-----
 net/ipv6/af_inet6.c                            |   28 +++---
 net/ipv6/datagram.c                            |   15 +--
 net/ipv6/inet6_connection_sock.c               |    6 -
 net/ipv6/inet6_hashtables.c                    |   12 +-
 net/ipv6/ip6mr.c                               |    2 
 net/ipv6/ipv6_sockglue.c                       |    6 -
 net/ipv6/raw.c                                 |   30 +++---
 net/ipv6/syncookies.c                          |    2 
 net/ipv6/tcp_ipv6.c                            |   32 +++---
 net/ipv6/udp.c                                 |   24 ++---
 net/netfilter/xt_socket.c                      |    2 
 net/rds/tcp_listen.c                           |    8 -
 net/sctp/protocol.c                            |    8 -
 net/sctp/socket.c                              |   30 +++---
 net/sunrpc/svcsock.c                           |    8 -
 security/lsm_audit.c                           |   12 +-
 47 files changed, 408 insertions(+), 388 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 5910df6..849cc9c 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -516,7 +516,7 @@ static inline int pppol2tp_verify_udp_checksum(struct sock *sk,
 		return 0;
 
 	inet = inet_sk(sk);
-	psum = csum_tcpudp_nofold(inet->saddr, inet->daddr, ulen,
+	psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr, ulen,
 				  IPPROTO_UDP, 0);
 
 	if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
@@ -949,8 +949,8 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	inet = inet_sk(sk_tun);
 	udp_len = hdr_len + sizeof(ppph) + total_len;
 	uh = (struct udphdr *) skb->data;
-	uh->source = inet->sport;
-	uh->dest = inet->dport;
+	uh->source = inet->inet_sport;
+	uh->dest = inet->inet_dport;
 	uh->len = htons(udp_len);
 	uh->check = 0;
 	skb_put(skb, sizeof(struct udphdr));
@@ -978,7 +978,8 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	else if (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		csum = skb_checksum(skb, 0, udp_len, 0);
-		uh->check = csum_tcpudp_magic(inet->saddr, inet->daddr,
+		uh->check = csum_tcpudp_magic(inet->inet_saddr,
+					      inet->inet_daddr,
 					      udp_len, IPPROTO_UDP, csum);
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
@@ -986,7 +987,8 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
-		uh->check = ~csum_tcpudp_magic(inet->saddr, inet->daddr,
+		uh->check = ~csum_tcpudp_magic(inet->inet_saddr,
+					       inet->inet_daddr,
 					       udp_len, IPPROTO_UDP, 0);
 	}
 
@@ -1136,8 +1138,8 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	__skb_push(skb, sizeof(*uh));
 	skb_reset_transport_header(skb);
 	uh = udp_hdr(skb);
-	uh->source = inet->sport;
-	uh->dest = inet->dport;
+	uh->source = inet->inet_sport;
+	uh->dest = inet->inet_dport;
 	uh->len = htons(udp_len);
 	uh->check = 0;
 
@@ -1181,7 +1183,8 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	else if (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		csum = skb_checksum(skb, 0, udp_len, 0);
-		uh->check = csum_tcpudp_magic(inet->saddr, inet->daddr,
+		uh->check = csum_tcpudp_magic(inet->inet_saddr,
+					      inet->inet_daddr,
 					      udp_len, IPPROTO_UDP, csum);
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
@@ -1189,7 +1192,8 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
-		uh->check = ~csum_tcpudp_magic(inet->saddr, inet->daddr,
+		uh->check = ~csum_tcpudp_magic(inet->inet_saddr,
+					       inet->inet_daddr,
 					       udp_len, IPPROTO_UDP, 0);
 	}
 
diff --git a/fs/ocfs2/cluster/netdebug.c b/fs/ocfs2/cluster/netdebug.c
index da794bc..a3f150e 100644
--- a/fs/ocfs2/cluster/netdebug.c
+++ b/fs/ocfs2/cluster/netdebug.c
@@ -294,10 +294,10 @@ static int sc_seq_show(struct seq_file *seq, void *v)
 		if (sc->sc_sock) {
 			inet = inet_sk(sc->sc_sock->sk);
 			/* the stack's structs aren't sparse endian clean */
-			saddr = (__force __be32)inet->saddr;
-			daddr = (__force __be32)inet->daddr;
-			sport = (__force __be16)inet->sport;
-			dport = (__force __be16)inet->dport;
+			saddr = (__force __be32)inet->inet_saddr;
+			daddr = (__force __be32)inet->inet_daddr;
+			sport = (__force __be16)inet->inet_sport;
+			dport = (__force __be16)inet->inet_dport;
 		}
 
 		/* XXX sigh, inet-> doesn't have sparse annotation so any
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5640425..e0cc9a7 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -505,7 +505,7 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 
 #define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
 	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
-	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))  	&& \
+	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) && \
 	 ((__sk)->sk_family		== AF_INET6)		&& \
 	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&& \
 	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&& \
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 22c73a7..92838d3 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -46,8 +46,8 @@ static inline int inet6_sk_ehashfn(const struct sock *sk)
 	const struct ipv6_pinfo *np = inet6_sk(sk);
 	const struct in6_addr *laddr = &np->rcv_saddr;
 	const struct in6_addr *faddr = &np->daddr;
-	const __u16 lport = inet->num;
-	const __be16 fport = inet->dport;
+	const __u16 lport = inet->inet_num;
+	const __be16 fport = inet->inet_dport;
 	struct net *net = sock_net(sk);
 
 	return inet6_ehashfn(net, laddr, lport, faddr, fport);
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5f11c4a..5b698b3 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -241,7 +241,7 @@ static inline int inet_lhashfn(struct net *net, const unsigned short num)
 
 static inline int inet_sk_listen_hashfn(const struct sock *sk)
 {
-	return inet_lhashfn(sock_net(sk), inet_sk(sk)->num);
+	return inet_lhashfn(sock_net(sk), inet_sk(sk)->inet_num);
 }
 
 /* Caller must disable local BH processing. */
@@ -301,8 +301,8 @@ typedef __u64 __bitwise __addrpair;
 #endif /* __BIG_ENDIAN */
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
 	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
-	 ((*((__addrpair *)&(inet_sk(__sk)->daddr))) == (__cookie))	&&	\
-	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))	&&	\
+	 ((*((__addrpair *)&(inet_sk(__sk)->inet_daddr))) == (__cookie))  &&	\
+	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))   &&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #define INET_TW_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
 	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
@@ -313,9 +313,9 @@ typedef __u64 __bitwise __addrpair;
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr)
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)	\
 	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
-	 (inet_sk(__sk)->daddr		== (__saddr))		&&	\
-	 (inet_sk(__sk)->rcv_saddr	== (__daddr))		&&	\
-	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))	&&	\
+	 (inet_sk(__sk)->inet_daddr	== (__saddr))		&&	\
+	 (inet_sk(__sk)->inet_rcv_saddr	== (__daddr))		&&	\
+	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))	&&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #define INET_TW_MATCH(__sk, __net, __hash,__cookie, __saddr, __daddr, __ports, __dif)	\
 	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 47004f3..bd4c53f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -93,14 +93,14 @@ struct rtable;
  *
  * @sk - ancestor class
  * @pinet6 - pointer to IPv6 control block
- * @daddr - Foreign IPv4 addr
- * @rcv_saddr - Bound local IPv4 addr
- * @dport - Destination port
- * @num - Local port
- * @saddr - Sending source
+ * @inet_daddr - Foreign IPv4 addr
+ * @inet_rcv_saddr - Bound local IPv4 addr
+ * @inet_dport - Destination port
+ * @inet_num - Local port
+ * @inet_saddr - Sending source
  * @uc_ttl - Unicast TTL
- * @sport - Source port
- * @id - ID counter for DF pkts
+ * @inet_sport - Source port
+ * @inet_id - ID counter for DF pkts
  * @tos - TOS
  * @mc_ttl - Multicasting TTL
  * @is_icsk - is this an inet_connection_sock?
@@ -115,16 +115,16 @@ struct inet_sock {
 	struct ipv6_pinfo	*pinet6;
 #endif
 	/* Socket demultiplex comparisons on incoming packets. */
-	__be32			daddr;
-	__be32			rcv_saddr;
-	__be16			dport;
-	__u16			num;
-	__be32			saddr;
+	__be32			inet_daddr;
+	__be32			inet_rcv_saddr;
+	__be16			inet_dport;
+	__u16			inet_num;
+	__be32			inet_saddr;
 	__s16			uc_ttl;
 	__u16			cmsg_flags;
 	struct ip_options	*opt;
-	__be16			sport;
-	__u16			id;
+	__be16			inet_sport;
+	__u16			inet_id;
 	__u8			tos;
 	__u8			mc_ttl;
 	__u8			pmtudisc;
@@ -190,10 +190,10 @@ static inline unsigned int inet_ehashfn(struct net *net,
 static inline int inet_sk_ehashfn(const struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	const __be32 laddr = inet->rcv_saddr;
-	const __u16 lport = inet->num;
-	const __be32 faddr = inet->daddr;
-	const __be16 fport = inet->dport;
+	const __be32 laddr = inet->inet_rcv_saddr;
+	const __u16 lport = inet->inet_num;
+	const __be32 faddr = inet->inet_daddr;
+	const __be16 fport = inet->inet_dport;
 	struct net *net = sock_net(sk);
 
 	return inet_ehashfn(net, laddr, lport, faddr, fport);
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index b63b80f..37f3aea 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -194,7 +194,7 @@ static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 static inline __be32 inet_rcv_saddr(const struct sock *sk)
 {
 	return likely(sk->sk_state != TCP_TIME_WAIT) ?
-		inet_sk(sk)->rcv_saddr : inet_twsk(sk)->tw_rcv_saddr;
+		inet_sk(sk)->inet_rcv_saddr : inet_twsk(sk)->tw_rcv_saddr;
 }
 
 extern void inet_twsk_put(struct inet_timewait_sock *tw);
diff --git a/include/net/ip.h b/include/net/ip.h
index 2f47e54..376adf4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -240,8 +240,8 @@ static inline void ip_select_ident(struct iphdr *iph, struct dst_entry *dst, str
 		 * does not change, they drop every other packet in
 		 * a TCP stream using header compression.
 		 */
-		iph->id = (sk && inet_sk(sk)->daddr) ?
-					htons(inet_sk(sk)->id++) : 0;
+		iph->id = (sk && inet_sk(sk)->inet_daddr) ?
+					htons(inet_sk(sk)->inet_id++) : 0;
 	} else
 		__ip_select_ident(iph, dst, 0);
 }
@@ -249,9 +249,9 @@ static inline void ip_select_ident(struct iphdr *iph, struct dst_entry *dst, str
 static inline void ip_select_ident_more(struct iphdr *iph, struct dst_entry *dst, struct sock *sk, int more)
 {
 	if (iph->frag_off & htons(IP_DF)) {
-		if (sk && inet_sk(sk)->daddr) {
-			iph->id = htons(inet_sk(sk)->id);
-			inet_sk(sk)->id += 1 + more;
+		if (sk && inet_sk(sk)->inet_daddr) {
+			iph->id = htons(inet_sk(sk)->inet_id);
+			inet_sk(sk)->inet_id += 1 + more;
 		} else
 			iph->id = 0;
 	} else
@@ -317,7 +317,7 @@ static inline void ip_ib_mc_map(__be32 naddr, const unsigned char *broadcast, ch
 
 static __inline__ void inet_reset_saddr(struct sock *sk)
 {
-	inet_sk(sk)->rcv_saddr = inet_sk(sk)->saddr = 0;
+	inet_sk(sk)->inet_rcv_saddr = inet_sk(sk)->inet_saddr = 0;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	if (sk->sk_family == PF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7302e14..00028d4 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -62,10 +62,10 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		nexthop = inet->opt->faddr;
 	}
 
-	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
+	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_DCCP,
-			       inet->sport, usin->sin_port, sk, 1);
+			       inet->inet_sport, usin->sin_port, sk, 1);
 	if (tmp < 0)
 		return tmp;
 
@@ -77,12 +77,12 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (inet->opt == NULL || !inet->opt->srr)
 		daddr = rt->rt_dst;
 
-	if (inet->saddr == 0)
-		inet->saddr = rt->rt_src;
-	inet->rcv_saddr = inet->saddr;
+	if (inet->inet_saddr == 0)
+		inet->inet_saddr = rt->rt_src;
+	inet->inet_rcv_saddr = inet->inet_saddr;
 
-	inet->dport = usin->sin_port;
-	inet->daddr = daddr;
+	inet->inet_dport = usin->sin_port;
+	inet->inet_daddr = daddr;
 
 	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet->opt != NULL)
@@ -98,17 +98,19 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err != 0)
 		goto failure;
 
-	err = ip_route_newports(&rt, IPPROTO_DCCP, inet->sport, inet->dport,
-				sk);
+	err = ip_route_newports(&rt, IPPROTO_DCCP, inet->inet_sport,
+				inet->inet_dport, sk);
 	if (err != 0)
 		goto failure;
 
 	/* OK, now commit destination to socket.  */
 	sk_setup_caps(sk, &rt->u.dst);
 
-	dp->dccps_iss = secure_dccp_sequence_number(inet->saddr, inet->daddr,
-						    inet->sport, inet->dport);
-	inet->id = dp->dccps_iss ^ jiffies;
+	dp->dccps_iss = secure_dccp_sequence_number(inet->inet_saddr,
+						    inet->inet_daddr,
+						    inet->inet_sport,
+						    inet->inet_dport);
+	inet->inet_id = dp->dccps_iss ^ jiffies;
 
 	err = dccp_connect(sk);
 	rt = NULL;
@@ -123,7 +125,7 @@ failure:
 	dccp_set_state(sk, DCCP_CLOSED);
 	ip_rt_put(rt);
 	sk->sk_route_caps = 0;
-	inet->dport = 0;
+	inet->inet_dport = 0;
 	goto out;
 }
 
@@ -352,7 +354,9 @@ void dccp_v4_send_check(struct sock *sk, int unused, struct sk_buff *skb)
 	struct dccp_hdr *dh = dccp_hdr(skb);
 
 	dccp_csum_outgoing(skb);
-	dh->dccph_checksum = dccp_v4_csum_finish(skb, inet->saddr, inet->daddr);
+	dh->dccph_checksum = dccp_v4_csum_finish(skb,
+						 inet->inet_saddr,
+						 inet->inet_daddr);
 }
 
 EXPORT_SYMBOL_GPL(dccp_v4_send_check);
@@ -393,14 +397,14 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newinet		   = inet_sk(newsk);
 	ireq		   = inet_rsk(req);
-	newinet->daddr	   = ireq->rmt_addr;
-	newinet->rcv_saddr = ireq->loc_addr;
-	newinet->saddr	   = ireq->loc_addr;
+	newinet->inet_daddr	= ireq->rmt_addr;
+	newinet->inet_rcv_saddr = ireq->loc_addr;
+	newinet->inet_saddr	= ireq->loc_addr;
 	newinet->opt	   = ireq->opt;
 	ireq->opt	   = NULL;
 	newinet->mc_index  = inet_iif(skb);
 	newinet->mc_ttl	   = ip_hdr(skb)->ttl;
-	newinet->id	   = jiffies;
+	newinet->inet_id   = jiffies;
 
 	dccp_sync_mss(newsk, dst_mtu(dst));
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index a2afb55..6d89f9f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -158,8 +158,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 			fl.oif = sk->sk_bound_dev_if;
-			fl.fl_ip_dport = inet->dport;
-			fl.fl_ip_sport = inet->sport;
+			fl.fl_ip_dport = inet->inet_dport;
+			fl.fl_ip_sport = inet->inet_sport;
 			security_sk_classify_flow(sk, &fl);
 
 			err = ip6_dst_lookup(sk, &dst, &fl);
@@ -510,9 +510,9 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set_v4mapped(newinet->daddr, &newnp->daddr);
+		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newnp->daddr);
 
-		ipv6_addr_set_v4mapped(newinet->saddr, &newnp->saddr);
+		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
 
 		ipv6_addr_copy(&newnp->rcv_saddr, &newnp->saddr);
 
@@ -640,7 +640,8 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 	dccp_sync_mss(newsk, dst_mtu(dst));
 
-	newinet->daddr = newinet->saddr = newinet->rcv_saddr = LOOPBACK4_IPV6;
+	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
+	newinet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
 	__inet6_hash(newsk);
 	__inet_inherit_port(sk, newsk);
@@ -968,10 +969,9 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			icsk->icsk_af_ops = &dccp_ipv6_af_ops;
 			sk->sk_backlog_rcv = dccp_v6_do_rcv;
 			goto failure;
-		} else {
-			ipv6_addr_set_v4mapped(inet->saddr, &np->saddr);
-			ipv6_addr_set_v4mapped(inet->rcv_saddr, &np->rcv_saddr);
 		}
+		ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
+		ipv6_addr_set_v4mapped(inet->inet_rcv_saddr, &np->rcv_saddr);
 
 		return err;
 	}
@@ -984,7 +984,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	ipv6_addr_copy(&fl.fl6_src, saddr ? saddr : &np->saddr);
 	fl.oif = sk->sk_bound_dev_if;
 	fl.fl_ip_dport = usin->sin6_port;
-	fl.fl_ip_sport = inet->sport;
+	fl.fl_ip_sport = inet->inet_sport;
 	security_sk_classify_flow(sk, &fl);
 
 	if (np->opt != NULL && np->opt->srcrt != NULL) {
@@ -1017,7 +1017,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	/* set the source address */
 	ipv6_addr_copy(&np->saddr, saddr);
-	inet->rcv_saddr = LOOPBACK4_IPV6;
+	inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
 	__ip6_dst_store(sk, dst, NULL, NULL);
 
@@ -1026,7 +1026,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		icsk->icsk_ext_hdr_len = (np->opt->opt_flen +
 					  np->opt->opt_nflen);
 
-	inet->dport = usin->sin6_port;
+	inet->inet_dport = usin->sin6_port;
 
 	dccp_set_state(sk, DCCP_REQUESTING);
 	err = inet6_hash_connect(&dccp_death_row, sk);
@@ -1035,7 +1035,8 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	dp->dccps_iss = secure_dccpv6_sequence_number(np->saddr.s6_addr32,
 						      np->daddr.s6_addr32,
-						      inet->sport, inet->dport);
+						      inet->inet_sport,
+						      inet->inet_dport);
 	err = dccp_connect(sk);
 	if (err)
 		goto late_failure;
@@ -1046,7 +1047,7 @@ late_failure:
 	dccp_set_state(sk, DCCP_CLOSED);
 	__sk_dst_reset(sk);
 failure:
-	inet->dport = 0;
+	inet->inet_dport = 0;
 	sk->sk_route_caps = 0;
 	return err;
 }
diff --git a/net/dccp/output.c b/net/dccp/output.c
index c96119f..d6bb753 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -99,8 +99,8 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 		/* Build DCCP header and checksum it. */
 		dh = dccp_zeroed_hdr(skb, dccp_header_size);
 		dh->dccph_type	= dcb->dccpd_type;
-		dh->dccph_sport	= inet->sport;
-		dh->dccph_dport	= inet->dport;
+		dh->dccph_sport	= inet->inet_sport;
+		dh->dccph_dport	= inet->inet_dport;
 		dh->dccph_doff	= (dccp_header_size + dcb->dccpd_opt_len) / 4;
 		dh->dccph_ccval	= dcb->dccpd_ccval;
 		dh->dccph_cscov = dp->dccps_pcslen;
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 5e6ec8b..dc32842 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -80,19 +80,20 @@ static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (ccid_get_current_tx_ccid(dccp_sk(sk)) == DCCPC_CCID3)
 		hc = ccid3_hc_tx_sk(sk);
 
-	if (port == 0 || ntohs(inet->dport) == port ||
-	    ntohs(inet->sport) == port) {
+	if (port == 0 || ntohs(inet->inet_dport) == port ||
+	    ntohs(inet->inet_sport) == port) {
 		if (hc)
 			printl("%pI4:%u %pI4:%u %d %d %d %d %u %llu %llu %d\n",
-			       &inet->saddr, ntohs(inet->sport),
-			       &inet->daddr, ntohs(inet->dport), size,
+			       &inet->inet_saddr, ntohs(inet->inet_sport),
+			       &inet->inet_daddr, ntohs(inet->inet_dport), size,
 			       hc->tx_s, hc->tx_rtt, hc->tx_p,
 			       hc->tx_x_calc, hc->tx_x_recv >> 6,
 			       hc->tx_x >> 6, hc->tx_t_ipi);
 		else
 			printl("%pI4:%u %pI4:%u %d\n",
-			       &inet->saddr, ntohs(inet->sport),
-			       &inet->daddr, ntohs(inet->dport), size);
+			       &inet->inet_saddr, ntohs(inet->inet_sport),
+			       &inet->inet_daddr, ntohs(inet->inet_dport),
+			       size);
 	}
 
 	jprobe_return();
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index ecb203f..671cd14 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -278,7 +278,7 @@ int dccp_disconnect(struct sock *sk, int flags)
 		sk->sk_send_head = NULL;
 	}
 
-	inet->dport = 0;
+	inet->inet_dport = 0;
 
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
@@ -290,7 +290,7 @@ int dccp_disconnect(struct sock *sk, int flags)
 	inet_csk_delack_init(sk);
 	__sk_dst_reset(sk);
 
-	WARN_ON(inet->num && !icsk->icsk_bind_hash);
+	WARN_ON(inet->inet_num && !icsk->icsk_bind_hash);
 
 	sk->sk_error_report(sk);
 	return err;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1deff48..04a14b1 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -174,12 +174,12 @@ static int inet_autobind(struct sock *sk)
 	/* We may need to bind the socket. */
 	lock_sock(sk);
 	inet = inet_sk(sk);
-	if (!inet->num) {
+	if (!inet->inet_num) {
 		if (sk->sk_prot->get_port(sk, 0)) {
 			release_sock(sk);
 			return -EAGAIN;
 		}
-		inet->sport = htons(inet->num);
+		inet->inet_sport = htons(inet->inet_num);
 	}
 	release_sock(sk);
 	return 0;
@@ -354,7 +354,7 @@ lookup_protocol:
 	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;
 
 	if (SOCK_RAW == sock->type) {
-		inet->num = protocol;
+		inet->inet_num = protocol;
 		if (IPPROTO_RAW == protocol)
 			inet->hdrincl = 1;
 	}
@@ -364,7 +364,7 @@ lookup_protocol:
 	else
 		inet->pmtudisc = IP_PMTUDISC_WANT;
 
-	inet->id = 0;
+	inet->inet_id = 0;
 
 	sock_init_data(sock, sk);
 
@@ -381,13 +381,13 @@ lookup_protocol:
 
 	sk_refcnt_debug_inc(sk);
 
-	if (inet->num) {
+	if (inet->inet_num) {
 		/* It assumes that any protocol which allows
 		 * the user to assign a number at socket
 		 * creation time automatically
 		 * shares.
 		 */
-		inet->sport = htons(inet->num);
+		inet->inet_sport = htons(inet->inet_num);
 		/* Add to protocol hash chains. */
 		sk->sk_prot->hash(sk);
 	}
@@ -494,27 +494,27 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	/* Check these errors (active socket, double bind). */
 	err = -EINVAL;
-	if (sk->sk_state != TCP_CLOSE || inet->num)
+	if (sk->sk_state != TCP_CLOSE || inet->inet_num)
 		goto out_release_sock;
 
-	inet->rcv_saddr = inet->saddr = addr->sin_addr.s_addr;
+	inet->inet_rcv_saddr = inet->inet_saddr = addr->sin_addr.s_addr;
 	if (chk_addr_ret == RTN_MULTICAST || chk_addr_ret == RTN_BROADCAST)
-		inet->saddr = 0;  /* Use device */
+		inet->inet_saddr = 0;  /* Use device */
 
 	/* Make sure we are allowed to bind here. */
 	if (sk->sk_prot->get_port(sk, snum)) {
-		inet->saddr = inet->rcv_saddr = 0;
+		inet->inet_saddr = inet->inet_rcv_saddr = 0;
 		err = -EADDRINUSE;
 		goto out_release_sock;
 	}
 
-	if (inet->rcv_saddr)
+	if (inet->inet_rcv_saddr)
 		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
 	if (snum)
 		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
-	inet->sport = htons(inet->num);
-	inet->daddr = 0;
-	inet->dport = 0;
+	inet->inet_sport = htons(inet->inet_num);
+	inet->inet_daddr = 0;
+	inet->inet_dport = 0;
 	sk_dst_reset(sk);
 	err = 0;
 out_release_sock:
@@ -532,7 +532,7 @@ int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
 	if (uaddr->sa_family == AF_UNSPEC)
 		return sk->sk_prot->disconnect(sk, flags);
 
-	if (!inet_sk(sk)->num && inet_autobind(sk))
+	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
 		return -EAGAIN;
 	return sk->sk_prot->connect(sk, (struct sockaddr *)uaddr, addr_len);
 }
@@ -689,17 +689,17 @@ int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	sin->sin_family = AF_INET;
 	if (peer) {
-		if (!inet->dport ||
+		if (!inet->inet_dport ||
 		    (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
 		     peer == 1))
 			return -ENOTCONN;
-		sin->sin_port = inet->dport;
-		sin->sin_addr.s_addr = inet->daddr;
+		sin->sin_port = inet->inet_dport;
+		sin->sin_addr.s_addr = inet->inet_daddr;
 	} else {
-		__be32 addr = inet->rcv_saddr;
+		__be32 addr = inet->inet_rcv_saddr;
 		if (!addr)
-			addr = inet->saddr;
-		sin->sin_port = inet->sport;
+			addr = inet->inet_saddr;
+		sin->sin_port = inet->inet_sport;
 		sin->sin_addr.s_addr = addr;
 	}
 	memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
@@ -714,7 +714,7 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	struct sock *sk = sock->sk;
 
 	/* We may need to bind the socket. */
-	if (!inet_sk(sk)->num && inet_autobind(sk))
+	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
 		return -EAGAIN;
 
 	return sk->sk_prot->sendmsg(iocb, sk, msg, size);
@@ -728,7 +728,7 @@ static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 	struct sock *sk = sock->sk;
 
 	/* We may need to bind the socket. */
-	if (!inet_sk(sk)->num && inet_autobind(sk))
+	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
 		return -EAGAIN;
 
 	if (sk->sk_prot->sendpage)
@@ -1059,9 +1059,9 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	struct inet_sock *inet = inet_sk(sk);
 	int err;
 	struct rtable *rt;
-	__be32 old_saddr = inet->saddr;
+	__be32 old_saddr = inet->inet_saddr;
 	__be32 new_saddr;
-	__be32 daddr = inet->daddr;
+	__be32 daddr = inet->inet_daddr;
 
 	if (inet->opt && inet->opt->srr)
 		daddr = inet->opt->faddr;
@@ -1071,7 +1071,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 			       RT_CONN_FLAGS(sk),
 			       sk->sk_bound_dev_if,
 			       sk->sk_protocol,
-			       inet->sport, inet->dport, sk, 0);
+			       inet->inet_sport, inet->inet_dport, sk, 0);
 	if (err)
 		return err;
 
@@ -1087,7 +1087,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 		       __func__, &old_saddr, &new_saddr);
 	}
 
-	inet->saddr = inet->rcv_saddr = new_saddr;
+	inet->inet_saddr = inet->inet_rcv_saddr = new_saddr;
 
 	/*
 	 * XXX The only one ugly spot where we need to
@@ -1113,7 +1113,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 		return 0;
 
 	/* Reroute. */
-	daddr = inet->daddr;
+	daddr = inet->inet_daddr;
 	if (inet->opt && inet->opt->srr)
 		daddr = inet->opt->faddr;
 {
@@ -1123,7 +1123,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 		.nl_u = {
 			.ip4_u = {
 				.daddr	= daddr,
-				.saddr	= inet->saddr,
+				.saddr	= inet->inet_saddr,
 				.tos	= RT_CONN_FLAGS(sk),
 			},
 		},
@@ -1131,8 +1131,8 @@ int inet_sk_rebuild_header(struct sock *sk)
 		.flags = inet_sk_flowi_flags(sk),
 		.uli_u = {
 			.ports = {
-				.sport = inet->sport,
-				.dport = inet->dport,
+				.sport = inet->inet_sport,
+				.dport = inet->inet_dport,
 			},
 		},
 	};
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 5e6c5a0..fb24658 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -39,7 +39,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk_dst_reset(sk);
 
 	oif = sk->sk_bound_dev_if;
-	saddr = inet->saddr;
+	saddr = inet->inet_saddr;
 	if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
 		if (!oif)
 			oif = inet->mc_index;
@@ -49,7 +49,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	err = ip_route_connect(&rt, usin->sin_addr.s_addr, saddr,
 			       RT_CONN_FLAGS(sk), oif,
 			       sk->sk_protocol,
-			       inet->sport, usin->sin_port, sk, 1);
+			       inet->inet_sport, usin->sin_port, sk, 1);
 	if (err) {
 		if (err == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
@@ -60,14 +60,14 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		ip_rt_put(rt);
 		return -EACCES;
 	}
-	if (!inet->saddr)
-		inet->saddr = rt->rt_src;	/* Update source address */
-	if (!inet->rcv_saddr)
-		inet->rcv_saddr = rt->rt_src;
-	inet->daddr = rt->rt_dst;
-	inet->dport = usin->sin_port;
+	if (!inet->inet_saddr)
+		inet->inet_saddr = rt->rt_src;	/* Update source address */
+	if (!inet->inet_rcv_saddr)
+		inet->inet_rcv_saddr = rt->rt_src;
+	inet->inet_daddr = rt->rt_dst;
+	inet->inet_dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
-	inet->id = jiffies;
+	inet->inet_id = jiffies;
 
 	sk_dst_set(sk, &rt->u.dst);
 	return(0);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 9139e8f..f6a0af7 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -368,7 +368,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 			    .proto = sk->sk_protocol,
 			    .flags = inet_sk_flowi_flags(sk),
 			    .uli_u = { .ports =
-				       { .sport = inet_sk(sk)->sport,
+				       { .sport = inet_sk(sk)->inet_sport,
 					 .dport = ireq->rmt_port } } };
 	struct net *net = sock_net(sk);
 
@@ -547,9 +547,9 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 		newsk->sk_state = TCP_SYN_RECV;
 		newicsk->icsk_bind_hash = NULL;
 
-		inet_sk(newsk)->dport = inet_rsk(req)->rmt_port;
-		inet_sk(newsk)->num = ntohs(inet_rsk(req)->loc_port);
-		inet_sk(newsk)->sport = inet_rsk(req)->loc_port;
+		inet_sk(newsk)->inet_dport = inet_rsk(req)->rmt_port;
+		inet_sk(newsk)->inet_num = ntohs(inet_rsk(req)->loc_port);
+		inet_sk(newsk)->inet_sport = inet_rsk(req)->loc_port;
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
@@ -580,8 +580,8 @@ void inet_csk_destroy_sock(struct sock *sk)
 	/* It cannot be in hash table! */
 	WARN_ON(!sk_unhashed(sk));
 
-	/* If it has not 0 inet_sk(sk)->num, it must be bound */
-	WARN_ON(inet_sk(sk)->num && !inet_csk(sk)->icsk_bind_hash);
+	/* If it has not 0 inet_sk(sk)->inet_num, it must be bound */
+	WARN_ON(inet_sk(sk)->inet_num && !inet_csk(sk)->icsk_bind_hash);
 
 	sk->sk_prot->destroy(sk);
 
@@ -616,8 +616,8 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 	 * after validation is complete.
 	 */
 	sk->sk_state = TCP_LISTEN;
-	if (!sk->sk_prot->get_port(sk, inet->num)) {
-		inet->sport = htons(inet->num);
+	if (!sk->sk_prot->get_port(sk, inet->inet_num)) {
+		inet->inet_sport = htons(inet->inet_num);
 
 		sk_dst_reset(sk);
 		sk->sk_prot->hash(sk);
@@ -693,8 +693,8 @@ void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 	const struct inet_sock *inet = inet_sk(sk);
 
 	sin->sin_family		= AF_INET;
-	sin->sin_addr.s_addr	= inet->daddr;
-	sin->sin_port		= inet->dport;
+	sin->sin_addr.s_addr	= inet->inet_daddr;
+	sin->sin_port		= inet->inet_dport;
 }
 
 EXPORT_SYMBOL_GPL(inet_csk_addr2sockaddr);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index cb73fde..bdb78dd 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -116,10 +116,10 @@ static int inet_csk_diag_fill(struct sock *sk,
 	r->id.idiag_cookie[0] = (u32)(unsigned long)sk;
 	r->id.idiag_cookie[1] = (u32)(((unsigned long)sk >> 31) >> 1);
 
-	r->id.idiag_sport = inet->sport;
-	r->id.idiag_dport = inet->dport;
-	r->id.idiag_src[0] = inet->rcv_saddr;
-	r->id.idiag_dst[0] = inet->daddr;
+	r->id.idiag_sport = inet->inet_sport;
+	r->id.idiag_dport = inet->inet_dport;
+	r->id.idiag_src[0] = inet->inet_rcv_saddr;
+	r->id.idiag_dst[0] = inet->inet_daddr;
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 	if (r->idiag_family == AF_INET6) {
@@ -504,11 +504,11 @@ static int inet_csk_diag_dump(struct sock *sk,
 		} else
 #endif
 		{
-			entry.saddr = &inet->rcv_saddr;
-			entry.daddr = &inet->daddr;
+			entry.saddr = &inet->inet_rcv_saddr;
+			entry.daddr = &inet->inet_daddr;
 		}
-		entry.sport = inet->num;
-		entry.dport = ntohs(inet->dport);
+		entry.sport = inet->inet_num;
+		entry.dport = ntohs(inet->inet_dport);
 		entry.userlocks = sk->sk_userlocks;
 
 		if (!inet_diag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), &entry))
@@ -584,7 +584,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	if (tmo < 0)
 		tmo = 0;
 
-	r->id.idiag_sport = inet->sport;
+	r->id.idiag_sport = inet->inet_sport;
 	r->id.idiag_dport = ireq->rmt_port;
 	r->id.idiag_src[0] = ireq->loc_addr;
 	r->id.idiag_dst[0] = ireq->rmt_addr;
@@ -639,7 +639,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
 	if (cb->nlh->nlmsg_len > 4 + NLMSG_SPACE(sizeof(*r))) {
 		bc = (struct rtattr *)(r + 1);
-		entry.sport = inet->num;
+		entry.sport = inet->inet_num;
 		entry.userlocks = sk->sk_userlocks;
 	}
 
@@ -732,7 +732,7 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 					continue;
 				}
 
-				if (r->id.idiag_sport != inet->sport &&
+				if (r->id.idiag_sport != inet->inet_sport &&
 				    r->id.idiag_sport)
 					goto next_listen;
 
@@ -797,10 +797,10 @@ skip_listen_ht:
 				goto next_normal;
 			if (!(r->idiag_states & (1 << sk->sk_state)))
 				goto next_normal;
-			if (r->id.idiag_sport != inet->sport &&
+			if (r->id.idiag_sport != inet->inet_sport &&
 			    r->id.idiag_sport)
 				goto next_normal;
-			if (r->id.idiag_dport != inet->dport &&
+			if (r->id.idiag_dport != inet->inet_dport &&
 			    r->id.idiag_dport)
 				goto next_normal;
 			if (inet_csk_diag_dump(sk, skb, cb) < 0) {
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index a45aaf3..47ad7aa 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -64,7 +64,7 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 
 	atomic_inc(&hashinfo->bsockets);
 
-	inet_sk(sk)->num = snum;
+	inet_sk(sk)->inet_num = snum;
 	sk_add_bind_node(sk, &tb->owners);
 	tb->num_owners++;
 	inet_csk(sk)->icsk_bind_hash = tb;
@@ -76,7 +76,7 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 static void __inet_put_port(struct sock *sk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
-	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(sk)->num,
+	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(sk)->inet_num,
 			hashinfo->bhash_size);
 	struct inet_bind_hashbucket *head = &hashinfo->bhash[bhash];
 	struct inet_bind_bucket *tb;
@@ -88,7 +88,7 @@ static void __inet_put_port(struct sock *sk)
 	__sk_del_bind_node(sk);
 	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
-	inet_sk(sk)->num = 0;
+	inet_sk(sk)->inet_num = 0;
 	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
 	spin_unlock(&head->lock);
 }
@@ -105,7 +105,7 @@ EXPORT_SYMBOL(inet_put_port);
 void __inet_inherit_port(struct sock *sk, struct sock *child)
 {
 	struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
-	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(child)->num,
+	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(child)->inet_num,
 			table->bhash_size);
 	struct inet_bind_hashbucket *head = &table->bhash[bhash];
 	struct inet_bind_bucket *tb;
@@ -126,9 +126,9 @@ static inline int compute_score(struct sock *sk, struct net *net,
 	int score = -1;
 	struct inet_sock *inet = inet_sk(sk);
 
-	if (net_eq(sock_net(sk), net) && inet->num == hnum &&
+	if (net_eq(sock_net(sk), net) && inet->inet_num == hnum &&
 			!ipv6_only_sock(sk)) {
-		__be32 rcv_saddr = inet->rcv_saddr;
+		__be32 rcv_saddr = inet->inet_rcv_saddr;
 		score = sk->sk_family == PF_INET ? 1 : 0;
 		if (rcv_saddr) {
 			if (rcv_saddr != daddr)
@@ -273,13 +273,14 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 {
 	struct inet_hashinfo *hinfo = death_row->hashinfo;
 	struct inet_sock *inet = inet_sk(sk);
-	__be32 daddr = inet->rcv_saddr;
-	__be32 saddr = inet->daddr;
+	__be32 daddr = inet->inet_rcv_saddr;
+	__be32 saddr = inet->inet_daddr;
 	int dif = sk->sk_bound_dev_if;
 	INET_ADDR_COOKIE(acookie, saddr, daddr)
-	const __portpair ports = INET_COMBINED_PORTS(inet->dport, lport);
+	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	struct net *net = sock_net(sk);
-	unsigned int hash = inet_ehashfn(net, daddr, lport, saddr, inet->dport);
+	unsigned int hash = inet_ehashfn(net, daddr, lport,
+					 saddr, inet->inet_dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
 	spinlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
@@ -312,8 +313,8 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 unique:
 	/* Must record num and sport now. Otherwise we will see
 	 * in hash table socket with a funny identity. */
-	inet->num = lport;
-	inet->sport = htons(lport);
+	inet->inet_num = lport;
+	inet->inet_sport = htons(lport);
 	sk->sk_hash = hash;
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
@@ -341,8 +342,9 @@ not_unique:
 static inline u32 inet_sk_port_offset(const struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	return secure_ipv4_port_ephemeral(inet->rcv_saddr, inet->daddr,
-					  inet->dport);
+	return secure_ipv4_port_ephemeral(inet->inet_rcv_saddr,
+					  inet->inet_daddr,
+					  inet->inet_dport);
 }
 
 void __inet_hash_nolisten(struct sock *sk)
@@ -424,7 +426,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		void (*hash)(struct sock *sk))
 {
 	struct inet_hashinfo *hinfo = death_row->hashinfo;
-	const unsigned short snum = inet_sk(sk)->num;
+	const unsigned short snum = inet_sk(sk)->inet_num;
 	struct inet_bind_hashbucket *head;
 	struct inet_bind_bucket *tb;
 	int ret;
@@ -485,7 +487,7 @@ ok:
 		/* Head lock still held and bh's disabled */
 		inet_bind_hash(sk, tb, port);
 		if (sk_unhashed(sk)) {
-			inet_sk(sk)->sport = htons(port);
+			inet_sk(sk)->inet_sport = htons(port);
 			hash(sk);
 		}
 		spin_unlock(&head->lock);
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 2fe5711..1f5d508 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -86,7 +86,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 	   Note, that any socket with inet->num != 0 MUST be bound in
 	   binding cache, even if it is closed.
 	 */
-	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), inet->num,
+	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), inet->inet_num,
 			hashinfo->bhash_size)];
 	spin_lock(&bhead->lock);
 	tw->tw_tb = icsk->icsk_bind_hash;
@@ -124,14 +124,14 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		kmemcheck_annotate_bitfield(tw, flags);
 
 		/* Give us an identity. */
-		tw->tw_daddr	    = inet->daddr;
-		tw->tw_rcv_saddr    = inet->rcv_saddr;
+		tw->tw_daddr	    = inet->inet_daddr;
+		tw->tw_rcv_saddr    = inet->inet_rcv_saddr;
 		tw->tw_bound_dev_if = sk->sk_bound_dev_if;
-		tw->tw_num	    = inet->num;
+		tw->tw_num	    = inet->inet_num;
 		tw->tw_state	    = TCP_TIME_WAIT;
 		tw->tw_substate	    = state;
-		tw->tw_sport	    = inet->sport;
-		tw->tw_dport	    = inet->dport;
+		tw->tw_sport	    = inet->inet_sport;
+		tw->tw_dport	    = inet->inet_dport;
 		tw->tw_family	    = sk->sk_family;
 		tw->tw_reuse	    = sk->sk_reuse;
 		tw->tw_hash	    = sk->sk_hash;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 6c98b43..fdf51ba 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -161,7 +161,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		/* If socket is bound to an interface, only report
 		 * the packet if it came  from that interface.
 		 */
-		if (sk && inet_sk(sk)->num == protocol &&
+		if (sk && inet_sk(sk)->inet_num == protocol &&
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == dev->ifindex) &&
 		    sock_net(sk) == dev_net(dev)) {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f989518..322b408 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -329,7 +329,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 		__be32 daddr;
 
 		/* Use correct destination address if we have options. */
-		daddr = inet->daddr;
+		daddr = inet->inet_daddr;
 		if(opt && opt->srr)
 			daddr = opt->faddr;
 
@@ -338,13 +338,13 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 					    .mark = sk->sk_mark,
 					    .nl_u = { .ip4_u =
 						      { .daddr = daddr,
-							.saddr = inet->saddr,
+							.saddr = inet->inet_saddr,
 							.tos = RT_CONN_FLAGS(sk) } },
 					    .proto = sk->sk_protocol,
 					    .flags = inet_sk_flowi_flags(sk),
 					    .uli_u = { .ports =
-						       { .sport = inet->sport,
-							 .dport = inet->dport } } };
+						       { .sport = inet->inet_sport,
+							 .dport = inet->inet_dport } } };
 
 			/* If this fails, retransmit mechanism of transport layer will
 			 * keep trying until route appears or the connection times
@@ -379,7 +379,7 @@ packet_routed:
 
 	if (opt && opt->optlen) {
 		iph->ihl += opt->optlen >> 2;
-		ip_options_build(skb, opt, inet->daddr, rt, 0);
+		ip_options_build(skb, opt, inet->inet_daddr, rt, 0);
 	}
 
 	ip_select_ident_more(iph, &rt->u.dst, sk,
@@ -846,7 +846,8 @@ int ip_append_data(struct sock *sk,
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
 	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport,
+			       mtu-exthdrlen);
 		return -EMSGSIZE;
 	}
 
@@ -1100,7 +1101,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
 	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport, mtu);
 		return -EMSGSIZE;
 	}
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 0c0b6e3..c602d98 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -245,7 +245,7 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 {
 	struct ip_ra_chain *ra, *new_ra, **rap;
 
-	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->num == IPPROTO_RAW)
+	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->inet_num == IPPROTO_RAW)
 		return -EINVAL;
 
 	new_ra = on ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
@@ -492,7 +492,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			if (sk->sk_family == PF_INET ||
 			    (!((1 << sk->sk_state) &
 			       (TCPF_LISTEN | TCPF_CLOSE)) &&
-			     inet->daddr != LOOPBACK4_IPV6)) {
+			     inet->inet_daddr != LOOPBACK4_IPV6)) {
 #endif
 				if (inet->opt)
 					icsk->icsk_ext_hdr_len -= inet->opt->optlen;
@@ -1181,8 +1181,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
 			struct in_pktinfo info;
 
-			info.ipi_addr.s_addr = inet->rcv_saddr;
-			info.ipi_spec_dst.s_addr = inet->rcv_saddr;
+			info.ipi_addr.s_addr = inet->inet_rcv_saddr;
+			info.ipi_spec_dst.s_addr = inet->inet_rcv_saddr;
 			info.ipi_ifindex = inet->mc_index;
 			put_cmsg(&msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);
 		}
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c757f0b..6949745 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -956,7 +956,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	switch (optname) {
 	case MRT_INIT:
 		if (sk->sk_type != SOCK_RAW ||
-		    inet_sk(sk)->num != IPPROTO_IGMP)
+		    inet_sk(sk)->inet_num != IPPROTO_IGMP)
 			return -EOPNOTSUPP;
 		if (optlen != sizeof(int))
 			return -ENOPROTOOPT;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index aa95bb8..9cd423f 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -255,10 +255,10 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 	struct nf_conntrack_tuple tuple;
 
 	memset(&tuple, 0, sizeof(tuple));
-	tuple.src.u3.ip = inet->rcv_saddr;
-	tuple.src.u.tcp.port = inet->sport;
-	tuple.dst.u3.ip = inet->daddr;
-	tuple.dst.u.tcp.port = inet->dport;
+	tuple.src.u3.ip = inet->inet_rcv_saddr;
+	tuple.src.u.tcp.port = inet->inet_sport;
+	tuple.dst.u3.ip = inet->inet_daddr;
+	tuple.dst.u.tcp.port = inet->inet_dport;
 	tuple.src.l3num = PF_INET;
 	tuple.dst.protonum = sk->sk_protocol;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 39e2a6b..9ef8c08 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -87,7 +87,7 @@ void raw_hash_sk(struct sock *sk)
 	struct raw_hashinfo *h = sk->sk_prot->h.raw_hash;
 	struct hlist_head *head;
 
-	head = &h->ht[inet_sk(sk)->num & (RAW_HTABLE_SIZE - 1)];
+	head = &h->ht[inet_sk(sk)->inet_num & (RAW_HTABLE_SIZE - 1)];
 
 	write_lock_bh(&h->lock);
 	sk_add_node(sk, head);
@@ -115,9 +115,9 @@ static struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 	sk_for_each_from(sk, node) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (net_eq(sock_net(sk), net) && inet->num == num	&&
-		    !(inet->daddr && inet->daddr != raddr) 		&&
-		    !(inet->rcv_saddr && inet->rcv_saddr != laddr)	&&
+		if (net_eq(sock_net(sk), net) && inet->inet_num == num	&&
+		    !(inet->inet_daddr && inet->inet_daddr != raddr) 	&&
+		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
 		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
 			goto found; /* gotcha */
 	}
@@ -326,7 +326,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	int err;
 
 	if (length > rt->u.dst.dev->mtu) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport,
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport,
 			       rt->u.dst.dev->mtu);
 		return -EMSGSIZE;
 	}
@@ -489,10 +489,10 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		err = -EDESTADDRREQ;
 		if (sk->sk_state != TCP_ESTABLISHED)
 			goto out;
-		daddr = inet->daddr;
+		daddr = inet->inet_daddr;
 	}
 
-	ipc.addr = inet->saddr;
+	ipc.addr = inet->inet_saddr;
 	ipc.opt = NULL;
 	ipc.shtx.flags = 0;
 	ipc.oif = sk->sk_bound_dev_if;
@@ -634,9 +634,9 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (addr->sin_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
 		goto out;
-	inet->rcv_saddr = inet->saddr = addr->sin_addr.s_addr;
+	inet->inet_rcv_saddr = inet->inet_saddr = addr->sin_addr.s_addr;
 	if (chk_addr_ret == RTN_MULTICAST || chk_addr_ret == RTN_BROADCAST)
-		inet->saddr = 0;  /* Use device */
+		inet->inet_saddr = 0;  /* Use device */
 	sk_dst_reset(sk);
 	ret = 0;
 out:	return ret;
@@ -706,7 +706,7 @@ static int raw_init(struct sock *sk)
 {
 	struct raw_sock *rp = raw_sk(sk);
 
-	if (inet_sk(sk)->num == IPPROTO_ICMP)
+	if (inet_sk(sk)->inet_num == IPPROTO_ICMP)
 		memset(&rp->filter, 0, sizeof(rp->filter));
 	return 0;
 }
@@ -743,7 +743,7 @@ static int do_raw_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, unsigned int optlen)
 {
 	if (optname == ICMP_FILTER) {
-		if (inet_sk(sk)->num != IPPROTO_ICMP)
+		if (inet_sk(sk)->inet_num != IPPROTO_ICMP)
 			return -EOPNOTSUPP;
 		else
 			return raw_seticmpfilter(sk, optval, optlen);
@@ -773,7 +773,7 @@ static int do_raw_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
 	if (optname == ICMP_FILTER) {
-		if (inet_sk(sk)->num != IPPROTO_ICMP)
+		if (inet_sk(sk)->inet_num != IPPROTO_ICMP)
 			return -EOPNOTSUPP;
 		else
 			return raw_geticmpfilter(sk, optval, optlen);
@@ -932,10 +932,10 @@ EXPORT_SYMBOL_GPL(raw_seq_stop);
 static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 {
 	struct inet_sock *inet = inet_sk(sp);
-	__be32 dest = inet->daddr,
-	       src = inet->rcv_saddr;
+	__be32 dest = inet->inet_daddr,
+	       src = inet->inet_rcv_saddr;
 	__u16 destp = 0,
-	      srcp  = inet->num;
+	      srcp  = inet->inet_num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf13726..206a291 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1998,7 +1998,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	__skb_queue_purge(&sk->sk_async_wait_queue);
 #endif
 
-	inet->dport = 0;
+	inet->inet_dport = 0;
 
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
@@ -2022,7 +2022,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
 
-	WARN_ON(inet->num && !icsk->icsk_bind_hash);
+	WARN_ON(inet->inet_num && !icsk->icsk_bind_hash);
 
 	sk->sk_error_report(sk);
 	return err;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9971870..a4a3390 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -165,10 +165,10 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		nexthop = inet->opt->faddr;
 	}
 
-	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
+	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
-			       inet->sport, usin->sin_port, sk, 1);
+			       inet->inet_sport, usin->sin_port, sk, 1);
 	if (tmp < 0) {
 		if (tmp == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
@@ -183,11 +183,11 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (!inet->opt || !inet->opt->srr)
 		daddr = rt->rt_dst;
 
-	if (!inet->saddr)
-		inet->saddr = rt->rt_src;
-	inet->rcv_saddr = inet->saddr;
+	if (!inet->inet_saddr)
+		inet->inet_saddr = rt->rt_src;
+	inet->inet_rcv_saddr = inet->inet_saddr;
 
-	if (tp->rx_opt.ts_recent_stamp && inet->daddr != daddr) {
+	if (tp->rx_opt.ts_recent_stamp && inet->inet_daddr != daddr) {
 		/* Reset inherited state */
 		tp->rx_opt.ts_recent	   = 0;
 		tp->rx_opt.ts_recent_stamp = 0;
@@ -210,8 +210,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		}
 	}
 
-	inet->dport = usin->sin_port;
-	inet->daddr = daddr;
+	inet->inet_dport = usin->sin_port;
+	inet->inet_daddr = daddr;
 
 	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet->opt)
@@ -230,7 +230,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		goto failure;
 
 	err = ip_route_newports(&rt, IPPROTO_TCP,
-				inet->sport, inet->dport, sk);
+				inet->inet_sport, inet->inet_dport, sk);
 	if (err)
 		goto failure;
 
@@ -239,12 +239,12 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk_setup_caps(sk, &rt->u.dst);
 
 	if (!tp->write_seq)
-		tp->write_seq = secure_tcp_sequence_number(inet->saddr,
-							   inet->daddr,
-							   inet->sport,
+		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
+							   inet->inet_daddr,
+							   inet->inet_sport,
 							   usin->sin_port);
 
-	inet->id = tp->write_seq ^ jiffies;
+	inet->inet_id = tp->write_seq ^ jiffies;
 
 	err = tcp_connect(sk);
 	rt = NULL;
@@ -261,7 +261,7 @@ failure:
 	tcp_set_state(sk, TCP_CLOSE);
 	ip_rt_put(rt);
 	sk->sk_route_caps = 0;
-	inet->dport = 0;
+	inet->inet_dport = 0;
 	return err;
 }
 
@@ -520,12 +520,13 @@ void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
 	struct tcphdr *th = tcp_hdr(skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		th->check = ~tcp_v4_check(len, inet->saddr,
-					  inet->daddr, 0);
+		th->check = ~tcp_v4_check(len, inet->inet_saddr,
+					  inet->inet_daddr, 0);
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
-		th->check = tcp_v4_check(len, inet->saddr, inet->daddr,
+		th->check = tcp_v4_check(len, inet->inet_saddr,
+					 inet->inet_daddr,
 					 csum_partial(th,
 						      th->doff << 2,
 						      skb->csum));
@@ -848,7 +849,7 @@ static struct tcp_md5sig_key *
 struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
 					 struct sock *addr_sk)
 {
-	return tcp_v4_md5_do_lookup(sk, inet_sk(addr_sk)->daddr);
+	return tcp_v4_md5_do_lookup(sk, inet_sk(addr_sk)->inet_daddr);
 }
 
 EXPORT_SYMBOL(tcp_v4_md5_lookup);
@@ -923,7 +924,7 @@ EXPORT_SYMBOL(tcp_v4_md5_do_add);
 static int tcp_v4_md5_add_func(struct sock *sk, struct sock *addr_sk,
 			       u8 *newkey, u8 newkeylen)
 {
-	return tcp_v4_md5_do_add(sk, inet_sk(addr_sk)->daddr,
+	return tcp_v4_md5_do_add(sk, inet_sk(addr_sk)->inet_daddr,
 				 newkey, newkeylen);
 }
 
@@ -1089,8 +1090,8 @@ int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 	__be32 saddr, daddr;
 
 	if (sk) {
-		saddr = inet_sk(sk)->saddr;
-		daddr = inet_sk(sk)->daddr;
+		saddr = inet_sk(sk)->inet_saddr;
+		daddr = inet_sk(sk)->inet_daddr;
 	} else if (req) {
 		saddr = inet_rsk(req)->loc_addr;
 		daddr = inet_rsk(req)->rmt_addr;
@@ -1380,9 +1381,9 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newtp		      = tcp_sk(newsk);
 	newinet		      = inet_sk(newsk);
 	ireq		      = inet_rsk(req);
-	newinet->daddr	      = ireq->rmt_addr;
-	newinet->rcv_saddr    = ireq->loc_addr;
-	newinet->saddr	      = ireq->loc_addr;
+	newinet->inet_daddr   = ireq->rmt_addr;
+	newinet->inet_rcv_saddr = ireq->loc_addr;
+	newinet->inet_saddr	      = ireq->loc_addr;
 	newinet->opt	      = ireq->opt;
 	ireq->opt	      = NULL;
 	newinet->mc_index     = inet_iif(skb);
@@ -1390,7 +1391,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (newinet->opt)
 		inet_csk(newsk)->icsk_ext_hdr_len = newinet->opt->optlen;
-	newinet->id = newtp->write_seq ^ jiffies;
+	newinet->inet_id = newtp->write_seq ^ jiffies;
 
 	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
@@ -1403,7 +1404,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	if ((key = tcp_v4_md5_do_lookup(sk, newinet->daddr)) != NULL) {
+	key = tcp_v4_md5_do_lookup(sk, newinet->inet_daddr);
+	if (key != NULL) {
 		/*
 		 * We're using one, so create a matching key
 		 * on the newsk structure. If we fail to get
@@ -1412,7 +1414,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 */
 		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
 		if (newkey != NULL)
-			tcp_v4_md5_do_add(newsk, newinet->daddr,
+			tcp_v4_md5_do_add(newsk, newinet->inet_daddr,
 					  newkey, key->keylen);
 		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
@@ -1711,8 +1713,8 @@ int tcp_v4_remember_stamp(struct sock *sk)
 	struct inet_peer *peer = NULL;
 	int release_it = 0;
 
-	if (!rt || rt->rt_dst != inet->daddr) {
-		peer = inet_getpeer(inet->daddr, 1);
+	if (!rt || rt->rt_dst != inet->inet_daddr) {
+		peer = inet_getpeer(inet->inet_daddr, 1);
 		release_it = 1;
 	} else {
 		if (!rt->peer)
@@ -2225,7 +2227,7 @@ static void get_openreq4(struct sock *sk, struct request_sock *req,
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p%n",
 		i,
 		ireq->loc_addr,
-		ntohs(inet_sk(sk)->sport),
+		ntohs(inet_sk(sk)->inet_sport),
 		ireq->rmt_addr,
 		ntohs(ireq->rmt_port),
 		TCP_SYN_RECV,
@@ -2248,10 +2250,10 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
-	__be32 dest = inet->daddr;
-	__be32 src = inet->rcv_saddr;
-	__u16 destp = ntohs(inet->dport);
-	__u16 srcp = ntohs(inet->sport);
+	__be32 dest = inet->inet_daddr;
+	__be32 src = inet->inet_rcv_saddr;
+	__u16 destp = ntohs(inet->inet_dport);
+	__u16 srcp = ntohs(inet->inet_sport);
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
 		timer_active	= 1;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fcd278a..2e2eb74 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -661,8 +661,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	/* Build TCP header and checksum it. */
 	th = tcp_hdr(skb);
-	th->source		= inet->sport;
-	th->dest		= inet->dport;
+	th->source		= inet->inet_sport;
+	th->dest		= inet->inet_dport;
 	th->seq			= htonl(tcb->seq);
 	th->ack_seq		= htonl(tp->rcv_nxt);
 	*(((__be16 *)th) + 6)	= htons(((tcp_header_size >> 2) << 12) |
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 59f5b5e..7a3cc2f 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -94,7 +94,8 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	const struct inet_sock *inet = inet_sk(sk);
 
 	/* Only update if port matches */
-	if ((port == 0 || ntohs(inet->dport) == port || ntohs(inet->sport) == port)
+	if ((port == 0 || ntohs(inet->inet_dport) == port ||
+	     ntohs(inet->inet_sport) == port)
 	    && (full || tp->snd_cwnd != tcp_probe.lastcwnd)) {
 
 		spin_lock(&tcp_probe.lock);
@@ -103,10 +104,10 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			struct tcp_log *p = tcp_probe.log + tcp_probe.head;
 
 			p->tstamp = ktime_get();
-			p->saddr = inet->saddr;
-			p->sport = inet->sport;
-			p->daddr = inet->daddr;
-			p->dport = inet->dport;
+			p->saddr = inet->inet_saddr;
+			p->sport = inet->inet_sport;
+			p->daddr = inet->inet_daddr;
+			p->dport = inet->inet_dport;
 			p->length = skb->len;
 			p->snd_nxt = tp->snd_nxt;
 			p->snd_una = tp->snd_una;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index cdb2ca7..6e8996c 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -303,15 +303,15 @@ void tcp_retransmit_timer(struct sock *sk)
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
-			       &inet->daddr, ntohs(inet->dport),
-			       inet->num, tp->snd_una, tp->snd_nxt);
+			       &inet->inet_daddr, ntohs(inet->inet_dport),
+			       inet->inet_num, tp->snd_una, tp->snd_nxt);
 		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
-			       &np->daddr, ntohs(inet->dport),
-			       inet->num, tp->snd_una, tp->snd_nxt);
+			       &np->daddr, ntohs(inet->inet_dport),
+			       inet->inet_num, tp->snd_una, tp->snd_nxt);
 		}
 #endif
 #endif
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 45a8a7e..ec5c7a7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -214,7 +214,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			goto fail_unlock;
 	}
 found:
-	inet_sk(sk)->num = snum;
+	inet_sk(sk)->inet_num = snum;
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
 		sk_nulls_add_node_rcu(sk, &hslot->head);
@@ -233,8 +233,8 @@ static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
 	return 	(!ipv6_only_sock(sk2)  &&
-		 (!inet1->rcv_saddr || !inet2->rcv_saddr ||
-		   inet1->rcv_saddr == inet2->rcv_saddr));
+		 (!inet1->inet_rcv_saddr || !inet2->inet_rcv_saddr ||
+		   inet1->inet_rcv_saddr == inet2->inet_rcv_saddr));
 }
 
 int udp_v4_get_port(struct sock *sk, unsigned short snum)
@@ -253,18 +253,18 @@ static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
 		struct inet_sock *inet = inet_sk(sk);
 
 		score = (sk->sk_family == PF_INET ? 1 : 0);
-		if (inet->rcv_saddr) {
-			if (inet->rcv_saddr != daddr)
+		if (inet->inet_rcv_saddr) {
+			if (inet->inet_rcv_saddr != daddr)
 				return -1;
 			score += 2;
 		}
-		if (inet->daddr) {
-			if (inet->daddr != saddr)
+		if (inet->inet_daddr) {
+			if (inet->inet_daddr != saddr)
 				return -1;
 			score += 2;
 		}
-		if (inet->dport) {
-			if (inet->dport != sport)
+		if (inet->inet_dport) {
+			if (inet->inet_dport != sport)
 				return -1;
 			score += 2;
 		}
@@ -360,9 +360,10 @@ static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
 
 		if (!net_eq(sock_net(s), net)				||
 		    s->sk_hash != hnum					||
-		    (inet->daddr && inet->daddr != rmt_addr)		||
-		    (inet->dport != rmt_port && inet->dport)		||
-		    (inet->rcv_saddr && inet->rcv_saddr != loc_addr)	||
+		    (inet->inet_daddr && inet->inet_daddr != rmt_addr)	||
+		    (inet->inet_dport != rmt_port && inet->inet_dport)	||
+		    (inet->inet_rcv_saddr	&&
+		     inet->inet_rcv_saddr != loc_addr)			||
 		    ipv6_only_sock(s)					||
 		    (s->sk_bound_dev_if && s->sk_bound_dev_if != dif))
 			continue;
@@ -646,14 +647,14 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
-		daddr = inet->daddr;
-		dport = inet->dport;
+		daddr = inet->inet_daddr;
+		dport = inet->inet_dport;
 		/* Open fast path for connected socket.
 		   Route will not be used, if at least one option is set.
 		 */
 		connected = 1;
 	}
-	ipc.addr = inet->saddr;
+	ipc.addr = inet->inet_saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
 	err = sock_tx_timestamp(msg, sk, &ipc.shtx);
@@ -708,7 +709,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				    .proto = sk->sk_protocol,
 				    .flags = inet_sk_flowi_flags(sk),
 				    .uli_u = { .ports =
-					       { .sport = inet->sport,
+					       { .sport = inet->inet_sport,
 						 .dport = dport } } };
 		struct net *net = sock_net(sk);
 
@@ -752,7 +753,7 @@ back_from_confirm:
 	inet->cork.fl.fl4_dst = daddr;
 	inet->cork.fl.fl_ip_dport = dport;
 	inet->cork.fl.fl4_src = saddr;
-	inet->cork.fl.fl_ip_sport = inet->sport;
+	inet->cork.fl.fl_ip_sport = inet->inet_sport;
 	up->pending = AF_INET;
 
 do_append_data:
@@ -1029,15 +1030,15 @@ int udp_disconnect(struct sock *sk, int flags)
 	 */
 
 	sk->sk_state = TCP_CLOSE;
-	inet->daddr = 0;
-	inet->dport = 0;
+	inet->inet_daddr = 0;
+	inet->inet_dport = 0;
 	sk->sk_bound_dev_if = 0;
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
 
 	if (!(sk->sk_userlocks & SOCK_BINDPORT_LOCK)) {
 		sk->sk_prot->unhash(sk);
-		inet->sport = 0;
+		inet->inet_sport = 0;
 	}
 	sk_dst_reset(sk);
 	return 0;
@@ -1053,7 +1054,7 @@ void udp_lib_unhash(struct sock *sk)
 
 		spin_lock_bh(&hslot->lock);
 		if (sk_nulls_del_node_init_rcu(sk)) {
-			inet_sk(sk)->num = 0;
+			inet_sk(sk)->inet_num = 0;
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 		}
 		spin_unlock_bh(&hslot->lock);
@@ -1752,10 +1753,10 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 		int bucket, int *len)
 {
 	struct inet_sock *inet = inet_sk(sp);
-	__be32 dest = inet->daddr;
-	__be32 src  = inet->rcv_saddr;
-	__u16 destp	  = ntohs(inet->dport);
-	__u16 srcp	  = ntohs(inet->sport);
+	__be32 dest = inet->inet_daddr;
+	__be32 src  = inet->inet_rcv_saddr;
+	__u16 destp	  = ntohs(inet->inet_dport);
+	__u16 srcp	  = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 9421651..b6d0588 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -185,7 +185,7 @@ lookup_protocol:
 	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;
 
 	if (SOCK_RAW == sock->type) {
-		inet->num = protocol;
+		inet->inet_num = protocol;
 		if (IPPROTO_RAW == protocol)
 			inet->hdrincl = 1;
 	}
@@ -228,12 +228,12 @@ lookup_protocol:
 	 */
 	sk_refcnt_debug_inc(sk);
 
-	if (inet->num) {
+	if (inet->inet_num) {
 		/* It assumes that any protocol which allows
 		 * the user to assign a number at socket
 		 * creation time automatically shares.
 		 */
-		inet->sport = htons(inet->num);
+		inet->inet_sport = htons(inet->inet_num);
 		sk->sk_prot->hash(sk);
 	}
 	if (sk->sk_prot->init) {
@@ -281,7 +281,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	lock_sock(sk);
 
 	/* Check these errors (active socket, double bind). */
-	if (sk->sk_state != TCP_CLOSE || inet->num) {
+	if (sk->sk_state != TCP_CLOSE || inet->inet_num) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -353,8 +353,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		}
 	}
 
-	inet->rcv_saddr = v4addr;
-	inet->saddr = v4addr;
+	inet->inet_rcv_saddr = v4addr;
+	inet->inet_saddr = v4addr;
 
 	ipv6_addr_copy(&np->rcv_saddr, &addr->sin6_addr);
 
@@ -375,9 +375,9 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	}
 	if (snum)
 		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
-	inet->sport = htons(inet->num);
-	inet->dport = 0;
-	inet->daddr = 0;
+	inet->inet_sport = htons(inet->inet_num);
+	inet->inet_dport = 0;
+	inet->inet_daddr = 0;
 out:
 	release_sock(sk);
 	return err;
@@ -441,12 +441,12 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 	sin->sin6_flowinfo = 0;
 	sin->sin6_scope_id = 0;
 	if (peer) {
-		if (!inet->dport)
+		if (!inet->inet_dport)
 			return -ENOTCONN;
 		if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
 		    peer == 1)
 			return -ENOTCONN;
-		sin->sin6_port = inet->dport;
+		sin->sin6_port = inet->inet_dport;
 		ipv6_addr_copy(&sin->sin6_addr, &np->daddr);
 		if (np->sndflow)
 			sin->sin6_flowinfo = np->flow_label;
@@ -456,7 +456,7 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 		else
 			ipv6_addr_copy(&sin->sin6_addr, &np->rcv_saddr);
 
-		sin->sin6_port = inet->sport;
+		sin->sin6_port = inet->inet_sport;
 	}
 	if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 		sin->sin6_scope_id = sk->sk_bound_dev_if;
@@ -655,8 +655,8 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		fl.fl6_flowlabel = np->flow_label;
 		fl.oif = sk->sk_bound_dev_if;
 		fl.mark = sk->sk_mark;
-		fl.fl_ip_dport = inet->dport;
-		fl.fl_ip_sport = inet->sport;
+		fl.fl_ip_dport = inet->inet_dport;
+		fl.fl_ip_sport = inet->inet_sport;
 		security_sk_classify_flow(sk, &fl);
 
 		if (np->opt && np->opt->srcrt) {
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index dbfec71..9f70452 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -98,13 +98,14 @@ ipv4_connected:
 		if (err)
 			goto out;
 
-		ipv6_addr_set_v4mapped(inet->daddr, &np->daddr);
+		ipv6_addr_set_v4mapped(inet->inet_daddr, &np->daddr);
 
 		if (ipv6_addr_any(&np->saddr))
-			ipv6_addr_set_v4mapped(inet->saddr, &np->saddr);
+			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
 
 		if (ipv6_addr_any(&np->rcv_saddr))
-			ipv6_addr_set_v4mapped(inet->rcv_saddr, &np->rcv_saddr);
+			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
+					       &np->rcv_saddr);
 
 		goto out;
 	}
@@ -133,7 +134,7 @@ ipv4_connected:
 	ipv6_addr_copy(&np->daddr, daddr);
 	np->flow_label = fl.fl6_flowlabel;
 
-	inet->dport = usin->sin6_port;
+	inet->inet_dport = usin->sin6_port;
 
 	/*
 	 *	Check for a route to destination an obtain the
@@ -145,8 +146,8 @@ ipv4_connected:
 	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.oif = sk->sk_bound_dev_if;
 	fl.mark = sk->sk_mark;
-	fl.fl_ip_dport = inet->dport;
-	fl.fl_ip_sport = inet->sport;
+	fl.fl_ip_dport = inet->inet_dport;
+	fl.fl_ip_sport = inet->inet_sport;
 
 	if (!fl.oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl.oif = np->mcast_oif;
@@ -188,7 +189,7 @@ ipv4_connected:
 
 	if (ipv6_addr_any(&np->rcv_saddr)) {
 		ipv6_addr_copy(&np->rcv_saddr, &fl.fl6_src);
-		inet->rcv_saddr = LOOPBACK4_IPV6;
+		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 	}
 
 	ip6_dst_store(sk, dst,
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index a9f4a21..19dceef 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -132,7 +132,7 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
 
 	sin6->sin6_family = AF_INET6;
 	ipv6_addr_copy(&sin6->sin6_addr, &np->daddr);
-	sin6->sin6_port	= inet_sk(sk)->dport;
+	sin6->sin6_port	= inet_sk(sk)->inet_dport;
 	/* We do not store received flowlabel for TCP */
 	sin6->sin6_flowinfo = 0;
 	sin6->sin6_scope_id = 0;
@@ -195,8 +195,8 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
 	fl.oif = sk->sk_bound_dev_if;
 	fl.mark = sk->sk_mark;
-	fl.fl_ip_sport = inet->sport;
-	fl.fl_ip_dport = inet->dport;
+	fl.fl_ip_sport = inet->inet_sport;
+	fl.fl_ip_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, &fl);
 
 	if (np->opt && np->opt->srcrt) {
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 874aed8..00c6a3e 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -125,7 +125,7 @@ static int inline compute_score(struct sock *sk, struct net *net,
 {
 	int score = -1;
 
-	if (net_eq(sock_net(sk), net) && inet_sk(sk)->num == hnum &&
+	if (net_eq(sock_net(sk), net) && inet_sk(sk)->inet_num == hnum &&
 	    sk->sk_family == PF_INET6) {
 		const struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -214,10 +214,10 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	const struct in6_addr *daddr = &np->rcv_saddr;
 	const struct in6_addr *saddr = &np->daddr;
 	const int dif = sk->sk_bound_dev_if;
-	const __portpair ports = INET_COMBINED_PORTS(inet->dport, lport);
+	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	struct net *net = sock_net(sk);
 	const unsigned int hash = inet6_ehashfn(net, daddr, lport, saddr,
-						inet->dport);
+						inet->inet_dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
 	spinlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
@@ -248,8 +248,8 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 unique:
 	/* Must record num and sport now. Otherwise we will see
 	 * in hash table socket with a funny identity. */
-	inet->num = lport;
-	inet->sport = htons(lport);
+	inet->inet_num = lport;
+	inet->inet_sport = htons(lport);
 	WARN_ON(!sk_unhashed(sk));
 	__sk_nulls_add_node_rcu(sk, &head->chain);
 	sk->sk_hash = hash;
@@ -279,7 +279,7 @@ static inline u32 inet6_sk_port_offset(const struct sock *sk)
 	const struct ipv6_pinfo *np = inet6_sk(sk);
 	return secure_ipv6_port_ephemeral(np->rcv_saddr.s6_addr32,
 					  np->daddr.s6_addr32,
-					  inet->dport);
+					  inet->inet_dport);
 }
 
 int inet6_hash_connect(struct inet_timewait_death_row *death_row,
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7161539..85849b4 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1297,7 +1297,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	switch (optname) {
 	case MRT6_INIT:
 		if (sk->sk_type != SOCK_RAW ||
-		    inet_sk(sk)->num != IPPROTO_ICMPV6)
+		    inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
 			return -EOPNOTSUPP;
 		if (optlen < sizeof(int))
 			return -EINVAL;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index dc0f736..39e10ac 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -64,7 +64,7 @@ int ip6_ra_control(struct sock *sk, int sel)
 	struct ip6_ra_chain *ra, *new_ra, **rap;
 
 	/* RA packet may be delivered ONLY to IPPROTO_RAW socket */
-	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->num != IPPROTO_RAW)
+	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->inet_num != IPPROTO_RAW)
 		return -ENOPROTOOPT;
 
 	new_ra = (sel>=0) ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
@@ -106,7 +106,7 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 	if (inet_sk(sk)->is_icsk) {
 		if (opt &&
 		    !((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
-		    inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
+		    inet_sk(sk)->inet_daddr != LOOPBACK4_IPV6) {
 			struct inet_connection_sock *icsk = inet_csk(sk);
 			icsk->icsk_ext_hdr_len = opt->opt_flen + opt->opt_nflen;
 			icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
@@ -234,7 +234,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 	case IPV6_V6ONLY:
 		if (optlen < sizeof(int) ||
-		    inet_sk(sk)->num)
+		    inet_sk(sk)->inet_num)
 			goto e_inval;
 		np->ipv6only = valbool;
 		retv = 0;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fd737ef..52ed7d7 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -72,7 +72,7 @@ static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 	int is_multicast = ipv6_addr_is_multicast(loc_addr);
 
 	sk_for_each_from(sk, node)
-		if (inet_sk(sk)->num == num) {
+		if (inet_sk(sk)->inet_num == num) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 
 			if (!net_eq(sock_net(sk), net))
@@ -298,7 +298,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			dev_put(dev);
 	}
 
-	inet->rcv_saddr = inet->saddr = v4addr;
+	inet->inet_rcv_saddr = inet->inet_saddr = v4addr;
 	ipv6_addr_copy(&np->rcv_saddr, &addr->sin6_addr);
 	if (!(addr_type & IPV6_ADDR_MULTICAST))
 		ipv6_addr_copy(&np->saddr, &addr->sin6_addr);
@@ -415,14 +415,14 @@ int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
 				   skb_network_header_len(skb));
 		if (!csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 				     &ipv6_hdr(skb)->daddr,
-				     skb->len, inet->num, skb->csum))
+				     skb->len, inet->inet_num, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	if (!skb_csum_unnecessary(skb))
 		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 							 &ipv6_hdr(skb)->daddr,
 							 skb->len,
-							 inet->num, 0));
+							 inet->inet_num, 0));
 
 	if (inet->hdrincl) {
 		if (skb_checksum_complete(skb)) {
@@ -765,8 +765,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		proto = ntohs(sin6->sin6_port);
 
 		if (!proto)
-			proto = inet->num;
-		else if (proto != inet->num)
+			proto = inet->inet_num;
+		else if (proto != inet->inet_num)
 			return(-EINVAL);
 
 		if (proto > 255)
@@ -799,7 +799,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		proto = inet->num;
+		proto = inet->inet_num;
 		daddr = &np->daddr;
 		fl.fl6_flowlabel = np->flow_label;
 	}
@@ -966,7 +966,7 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 
 	switch (optname) {
 		case IPV6_CHECKSUM:
-			if (inet_sk(sk)->num == IPPROTO_ICMPV6 &&
+			if (inet_sk(sk)->inet_num == IPPROTO_ICMPV6 &&
 			    level == IPPROTO_IPV6) {
 				/*
 				 * RFC3542 tells that IPV6_CHECKSUM socket
@@ -1006,7 +1006,7 @@ static int rawv6_setsockopt(struct sock *sk, int level, int optname,
 			break;
 
 		case SOL_ICMPV6:
-			if (inet_sk(sk)->num != IPPROTO_ICMPV6)
+			if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
 				return -EOPNOTSUPP;
 			return rawv6_seticmpfilter(sk, level, optname, optval,
 						   optlen);
@@ -1029,7 +1029,7 @@ static int compat_rawv6_setsockopt(struct sock *sk, int level, int optname,
 	case SOL_RAW:
 		break;
 	case SOL_ICMPV6:
-		if (inet_sk(sk)->num != IPPROTO_ICMPV6)
+		if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
 			return -EOPNOTSUPP;
 		return rawv6_seticmpfilter(sk, level, optname, optval, optlen);
 	case SOL_IPV6:
@@ -1086,7 +1086,7 @@ static int rawv6_getsockopt(struct sock *sk, int level, int optname,
 			break;
 
 		case SOL_ICMPV6:
-			if (inet_sk(sk)->num != IPPROTO_ICMPV6)
+			if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
 				return -EOPNOTSUPP;
 			return rawv6_geticmpfilter(sk, level, optname, optval,
 						   optlen);
@@ -1109,7 +1109,7 @@ static int compat_rawv6_getsockopt(struct sock *sk, int level, int optname,
 	case SOL_RAW:
 		break;
 	case SOL_ICMPV6:
-		if (inet_sk(sk)->num != IPPROTO_ICMPV6)
+		if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
 			return -EOPNOTSUPP;
 		return rawv6_geticmpfilter(sk, level, optname, optval, optlen);
 	case SOL_IPV6:
@@ -1156,7 +1156,7 @@ static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 
 static void rawv6_close(struct sock *sk, long timeout)
 {
-	if (inet_sk(sk)->num == IPPROTO_RAW)
+	if (inet_sk(sk)->inet_num == IPPROTO_RAW)
 		ip6_ra_control(sk, -1);
 	ip6mr_sk_done(sk);
 	sk_common_release(sk);
@@ -1175,7 +1175,7 @@ static int rawv6_init_sk(struct sock *sk)
 {
 	struct raw6_sock *rp = raw6_sk(sk);
 
-	switch (inet_sk(sk)->num) {
+	switch (inet_sk(sk)->inet_num) {
 	case IPPROTO_ICMPV6:
 		rp->checksum = 1;
 		rp->offset   = 2;
@@ -1225,7 +1225,7 @@ static void raw6_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	dest  = &np->daddr;
 	src   = &np->rcv_saddr;
 	destp = 0;
-	srcp  = inet_sk(sp)->num;
+	srcp  = inet_sk(sp)->inet_num;
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index cbe55e5..c46da53 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -254,7 +254,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		fl.oif = sk->sk_bound_dev_if;
 		fl.mark = sk->sk_mark;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-		fl.fl_ip_sport = inet_sk(sk)->sport;
+		fl.fl_ip_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, &fl);
 		if (ip6_dst_lookup(sk, &dst, &fl))
 			goto out_free;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4517630..c54ec36 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -226,8 +226,9 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 #endif
 			goto failure;
 		} else {
-			ipv6_addr_set_v4mapped(inet->saddr, &np->saddr);
-			ipv6_addr_set_v4mapped(inet->rcv_saddr, &np->rcv_saddr);
+			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
+			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
+					       &np->rcv_saddr);
 		}
 
 		return err;
@@ -243,7 +244,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	fl.oif = sk->sk_bound_dev_if;
 	fl.mark = sk->sk_mark;
 	fl.fl_ip_dport = usin->sin6_port;
-	fl.fl_ip_sport = inet->sport;
+	fl.fl_ip_sport = inet->inet_sport;
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
@@ -275,7 +276,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	/* set the source address */
 	ipv6_addr_copy(&np->saddr, saddr);
-	inet->rcv_saddr = LOOPBACK4_IPV6;
+	inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
 	sk->sk_gso_type = SKB_GSO_TCPV6;
 	__ip6_dst_store(sk, dst, NULL, NULL);
@@ -287,7 +288,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	tp->rx_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 
-	inet->dport = usin->sin6_port;
+	inet->inet_dport = usin->sin6_port;
 
 	tcp_set_state(sk, TCP_SYN_SENT);
 	err = inet6_hash_connect(&tcp_death_row, sk);
@@ -297,8 +298,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (!tp->write_seq)
 		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
 							     np->daddr.s6_addr32,
-							     inet->sport,
-							     inet->dport);
+							     inet->inet_sport,
+							     inet->inet_dport);
 
 	err = tcp_connect(sk);
 	if (err)
@@ -310,7 +311,7 @@ late_failure:
 	tcp_set_state(sk, TCP_CLOSE);
 	__sk_dst_reset(sk);
 failure:
-	inet->dport = 0;
+	inet->inet_dport = 0;
 	sk->sk_route_caps = 0;
 	return err;
 }
@@ -383,8 +384,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 			fl.oif = sk->sk_bound_dev_if;
 			fl.mark = sk->sk_mark;
-			fl.fl_ip_dport = inet->dport;
-			fl.fl_ip_sport = inet->sport;
+			fl.fl_ip_dport = inet->inet_dport;
+			fl.fl_ip_sport = inet->inet_sport;
 			security_skb_classify_flow(skb, &fl);
 
 			if ((err = ip6_dst_lookup(sk, &dst, &fl))) {
@@ -1291,9 +1292,9 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set_v4mapped(newinet->daddr, &newnp->daddr);
+		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newnp->daddr);
 
-		ipv6_addr_set_v4mapped(newinet->saddr, &newnp->saddr);
+		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
 
 		ipv6_addr_copy(&newnp->rcv_saddr, &newnp->saddr);
 
@@ -1431,7 +1432,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(newsk);
 
-	newinet->daddr = newinet->saddr = newinet->rcv_saddr = LOOPBACK4_IPV6;
+	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
+	newinet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
@@ -1931,8 +1933,8 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 
 	dest  = &np->daddr;
 	src   = &np->rcv_saddr;
-	destp = ntohs(inet->dport);
-	srcp  = ntohs(inet->sport);
+	destp = ntohs(inet->inet_dport);
+	srcp  = ntohs(inet->inet_sport);
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
 		timer_active	= 1;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b86425b..829d300 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -53,7 +53,7 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
 	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
-	__be32 sk_rcv_saddr = inet_sk(sk)->rcv_saddr;
+	__be32 sk1_rcv_saddr = inet_sk(sk)->inet_rcv_saddr;
 	__be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
 	int sk_ipv6only = ipv6_only_sock(sk);
 	int sk2_ipv6only = inet_v6_ipv6only(sk2);
@@ -63,8 +63,8 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 	/* if both are mapped, treat as IPv4 */
 	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED)
 		return (!sk2_ipv6only &&
-			(!sk_rcv_saddr || !sk2_rcv_saddr ||
-			  sk_rcv_saddr == sk2_rcv_saddr));
+			(!sk1_rcv_saddr || !sk2_rcv_saddr ||
+			  sk1_rcv_saddr == sk2_rcv_saddr));
 
 	if (addr_type2 == IPV6_ADDR_ANY &&
 	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
@@ -100,8 +100,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 		struct inet_sock *inet = inet_sk(sk);
 
 		score = 0;
-		if (inet->dport) {
-			if (inet->dport != sport)
+		if (inet->inet_dport) {
+			if (inet->inet_dport != sport)
 				return -1;
 			score++;
 		}
@@ -417,8 +417,8 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 
 		if (s->sk_hash == num && s->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(s);
-			if (inet->dport) {
-				if (inet->dport != rmt_port)
+			if (inet->inet_dport) {
+				if (inet->inet_dport != rmt_port)
 					continue;
 			}
 			if (!ipv6_addr_any(&np->daddr) &&
@@ -792,7 +792,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		if (ipv6_addr_v4mapped(daddr)) {
 			struct sockaddr_in sin;
 			sin.sin_family = AF_INET;
-			sin.sin_port = sin6 ? sin6->sin6_port : inet->dport;
+			sin.sin_port = sin6 ? sin6->sin6_port : inet->inet_dport;
 			sin.sin_addr.s_addr = daddr->s6_addr32[3];
 			msg->msg_name = &sin;
 			msg->msg_namelen = sizeof(sin);
@@ -865,7 +865,7 @@ do_udp_sendmsg:
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		fl.fl_ip_dport = inet->dport;
+		fl.fl_ip_dport = inet->inet_dport;
 		daddr = &np->daddr;
 		fl.fl6_flowlabel = np->flow_label;
 		connected = 1;
@@ -911,7 +911,7 @@ do_udp_sendmsg:
 		fl.fl6_dst.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.fl_ip_sport = inet->sport;
+	fl.fl_ip_sport = inet->inet_sport;
 
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
@@ -1192,8 +1192,8 @@ static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket
 
 	dest  = &np->daddr;
 	src   = &np->rcv_saddr;
-	destp = ntohs(inet->dport);
-	srcp  = ntohs(inet->sport);
+	destp = ntohs(inet->inet_dport);
+	srcp  = ntohs(inet->inet_sport);
 	seq_printf(seq,
 		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index ebf00ad..362afbd 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -149,7 +149,7 @@ socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
 
 		/* Ignore sockets listening on INADDR_ANY */
 		wildcard = (sk->sk_state != TCP_TIME_WAIT &&
-			    inet_sk(sk)->rcv_saddr == 0);
+			    inet_sk(sk)->inet_rcv_saddr == 0);
 
 		/* Ignore non-transparent sockets,
 		   if XT_SOCKET_TRANSPARENT is used */
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 24b743e..45474a4 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -67,11 +67,11 @@ static int rds_tcp_accept_one(struct socket *sock)
 	inet = inet_sk(new_sock->sk);
 
 	rdsdebug("accepted tcp %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u\n",
-		  NIPQUAD(inet->saddr), ntohs(inet->sport),
-		  NIPQUAD(inet->daddr), ntohs(inet->dport));
+		  NIPQUAD(inet->inet_saddr), ntohs(inet->inet_sport),
+		  NIPQUAD(inet->inet_daddr), ntohs(inet->inet_dport));
 
-	conn = rds_conn_create(inet->saddr, inet->daddr, &rds_tcp_transport,
-			       GFP_KERNEL);
+	conn = rds_conn_create(inet->inet_saddr, inet->inet_daddr,
+			       &rds_tcp_transport, GFP_KERNEL);
 	if (IS_ERR(conn)) {
 		ret = PTR_ERR(conn);
 		goto out;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 612dc87..d9f4cc2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -296,19 +296,19 @@ static void sctp_v4_from_sk(union sctp_addr *addr, struct sock *sk)
 {
 	addr->v4.sin_family = AF_INET;
 	addr->v4.sin_port = 0;
-	addr->v4.sin_addr.s_addr = inet_sk(sk)->rcv_saddr;
+	addr->v4.sin_addr.s_addr = inet_sk(sk)->inet_rcv_saddr;
 }
 
 /* Initialize sk->sk_rcv_saddr from sctp_addr. */
 static void sctp_v4_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
 {
-	inet_sk(sk)->rcv_saddr = addr->v4.sin_addr.s_addr;
+	inet_sk(sk)->inet_rcv_saddr = addr->v4.sin_addr.s_addr;
 }
 
 /* Initialize sk->sk_daddr from sctp_addr. */
 static void sctp_v4_to_sk_daddr(union sctp_addr *addr, struct sock *sk)
 {
-	inet_sk(sk)->daddr = addr->v4.sin_addr.s_addr;
+	inet_sk(sk)->inet_daddr = addr->v4.sin_addr.s_addr;
 }
 
 /* Initialize a sctp_addr from an address parameter. */
@@ -598,7 +598,7 @@ static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
 
 	newinet = inet_sk(newsk);
 
-	newinet->daddr = asoc->peer.primary_addr.v4.sin_addr.s_addr;
+	newinet->inet_daddr = asoc->peer.primary_addr.v4.sin_addr.s_addr;
 
 	sk_refcnt_debug_inc(newsk);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0970e92..4085db9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -394,7 +394,7 @@ SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 
 	/* Refresh ephemeral port.  */
 	if (!bp->port)
-		bp->port = inet_sk(sk)->num;
+		bp->port = inet_sk(sk)->inet_num;
 
 	/* Add the address to the bind address list.
 	 * Use GFP_ATOMIC since BHs will be disabled.
@@ -403,7 +403,7 @@ SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 
 	/* Copy back into socket for getsockname() use. */
 	if (!ret) {
-		inet_sk(sk)->sport = htons(inet_sk(sk)->num);
+		inet_sk(sk)->inet_sport = htons(inet_sk(sk)->inet_num);
 		af->to_sk_saddr(addr, sk);
 	}
 
@@ -1115,7 +1115,7 @@ static int __sctp_connect(struct sock* sk,
 	}
 
 	/* Initialize sk's dport and daddr for getpeername() */
-	inet_sk(sk)->dport = htons(asoc->peer.port);
+	inet_sk(sk)->inet_dport = htons(asoc->peer.port);
 	af = sctp_get_af_specific(sa_addr->sa.sa_family);
 	af->to_sk_daddr(sa_addr, sk);
 	sk->sk_err = 0;
@@ -5851,7 +5851,7 @@ pp_not_found:
 	 */
 success:
 	if (!sctp_sk(sk)->bind_hash) {
-		inet_sk(sk)->num = snum;
+		inet_sk(sk)->inet_num = snum;
 		sk_add_bind_node(sk, &pp->owner);
 		sctp_sk(sk)->bind_hash = pp;
 	}
@@ -5923,7 +5923,7 @@ SCTP_STATIC int sctp_listen_start(struct sock *sk, int backlog)
 		if (sctp_autobind(sk))
 			return -EAGAIN;
 	} else {
-		if (sctp_get_port(sk, inet_sk(sk)->num)) {
+		if (sctp_get_port(sk, inet_sk(sk)->inet_num)) {
 			sk->sk_state = SCTP_SS_CLOSED;
 			return -EADDRINUSE;
 		}
@@ -6094,14 +6094,14 @@ static void sctp_bucket_destroy(struct sctp_bind_bucket *pp)
 static inline void __sctp_put_port(struct sock *sk)
 {
 	struct sctp_bind_hashbucket *head =
-		&sctp_port_hashtable[sctp_phashfn(inet_sk(sk)->num)];
+		&sctp_port_hashtable[sctp_phashfn(inet_sk(sk)->inet_num)];
 	struct sctp_bind_bucket *pp;
 
 	sctp_spin_lock(&head->lock);
 	pp = sctp_sk(sk)->bind_hash;
 	__sk_del_bind_node(sk);
 	sctp_sk(sk)->bind_hash = NULL;
-	inet_sk(sk)->num = 0;
+	inet_sk(sk)->inet_num = 0;
 	sctp_bucket_destroy(pp);
 	sctp_spin_unlock(&head->lock);
 }
@@ -6128,7 +6128,7 @@ static int sctp_autobind(struct sock *sk)
 	/* Initialize a local sockaddr structure to INADDR_ANY. */
 	af = sctp_sk(sk)->pf->af;
 
-	port = htons(inet_sk(sk)->num);
+	port = htons(inet_sk(sk)->inet_num);
 	af->inaddr_any(&autoaddr, port);
 
 	return sctp_do_bind(sk, &autoaddr, af->sockaddr_len);
@@ -6697,12 +6697,12 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 	/* Initialize sk's sport, dport, rcv_saddr and daddr for
 	 * getsockname() and getpeername()
 	 */
-	newinet->sport = inet->sport;
-	newinet->saddr = inet->saddr;
-	newinet->rcv_saddr = inet->rcv_saddr;
-	newinet->dport = htons(asoc->peer.port);
+	newinet->inet_sport = inet->inet_sport;
+	newinet->inet_saddr = inet->inet_saddr;
+	newinet->inet_rcv_saddr = inet->inet_rcv_saddr;
+	newinet->inet_dport = htons(asoc->peer.port);
 	newinet->pmtudisc = inet->pmtudisc;
-	newinet->id = asoc->next_tsn ^ jiffies;
+	newinet->inet_id = asoc->next_tsn ^ jiffies;
 
 	newinet->uc_ttl = inet->uc_ttl;
 	newinet->mc_loop = 1;
@@ -6741,13 +6741,13 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	newsp->hmac = NULL;
 
 	/* Hook this new socket in to the bind_hash list. */
-	head = &sctp_port_hashtable[sctp_phashfn(inet_sk(oldsk)->num)];
+	head = &sctp_port_hashtable[sctp_phashfn(inet_sk(oldsk)->inet_num)];
 	sctp_local_bh_disable();
 	sctp_spin_lock(&head->lock);
 	pp = sctp_sk(oldsk)->bind_hash;
 	sk_add_bind_node(newsk, &pp->owner);
 	sctp_sk(newsk)->bind_hash = pp;
-	inet_sk(newsk)->num = inet_sk(oldsk)->num;
+	inet_sk(newsk)->inet_num = inet_sk(oldsk)->inet_num;
 	sctp_spin_unlock(&head->lock);
 	sctp_local_bh_enable();
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ccc5e83..c2a1787 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -272,14 +272,14 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 	case PF_INET:
 		len = snprintf(buf, remaining, "ipv4 %s %pI4 %d\n",
 				proto_name,
-				&inet_sk(sk)->rcv_saddr,
-				inet_sk(sk)->num);
+				&inet_sk(sk)->inet_rcv_saddr,
+				inet_sk(sk)->inet_num);
 		break;
 	case PF_INET6:
 		len = snprintf(buf, remaining, "ipv6 %s %pI6 %d\n",
 				proto_name,
 				&inet6_sk(sk)->rcv_saddr,
-				inet_sk(sk)->num);
+				inet_sk(sk)->inet_num);
 		break;
 	default:
 		len = snprintf(buf, remaining, "*unknown-%d*\n",
@@ -1311,7 +1311,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	/* Register socket with portmapper */
 	if (*errp >= 0 && pmap_register)
 		*errp = svc_register(serv, inet->sk_family, inet->sk_protocol,
-				     ntohs(inet_sk(inet)->sport));
+				     ntohs(inet_sk(inet)->inet_sport));
 
 	if (*errp < 0) {
 		kfree(svsk);
diff --git a/security/lsm_audit.c b/security/lsm_audit.c
index 3bb90b6..e04566a 100644
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -273,11 +273,11 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 			case AF_INET: {
 				struct inet_sock *inet = inet_sk(sk);
 
-				print_ipv4_addr(ab, inet->rcv_saddr,
-						inet->sport,
+				print_ipv4_addr(ab, inet->inet_rcv_saddr,
+						inet->inet_sport,
 						"laddr", "lport");
-				print_ipv4_addr(ab, inet->daddr,
-						inet->dport,
+				print_ipv4_addr(ab, inet->inet_daddr,
+						inet->inet_dport,
 						"faddr", "fport");
 				break;
 			}
@@ -286,10 +286,10 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 				struct ipv6_pinfo *inet6 = inet6_sk(sk);
 
 				print_ipv6_addr(ab, &inet6->rcv_saddr,
-						inet->sport,
+						inet->inet_sport,
 						"laddr", "lport");
 				print_ipv6_addr(ab, &inet6->daddr,
-						inet->dport,
+						inet->inet_dport,
 						"faddr", "fport");
 				break;
 			}
