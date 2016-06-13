From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 3/3] ipv4: kill RTO_ONLINK, RT_CONN_FLAGS and RT_CONN_FLAGS_TOS
Date: Mon, 13 Jun 2016 22:47:38 +0200
Message-ID: <1465850858-8559-4-git-send-email-hannes@stressinduktion.org>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
Cc: ja@ssi.bg, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53369 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423284AbcFMUrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:47:53 -0400
In-Reply-To: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately because of bisectability I cannot split this patch. :(

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/bonding/bond_main.c |  3 +--
 drivers/net/gtp.c               |  3 ++-
 drivers/net/ppp/pptp.c          |  2 +-
 drivers/net/vrf.c               |  7 -------
 include/net/ip.h                |  5 -----
 include/net/route.h             | 38 ++++++++++++++++++++++++++++----------
 net/dccp/ipv4.c                 |  5 +++--
 net/ipv4/af_inet.c              |  4 ++--
 net/ipv4/arp.c                  |  4 ++--
 net/ipv4/datagram.c             |  5 +++--
 net/ipv4/inet_connection_sock.c | 11 ++++++-----
 net/ipv4/ip_output.c            |  2 +-
 net/ipv4/ping.c                 |  6 +++---
 net/ipv4/raw.c                  | 13 ++++++++-----
 net/ipv4/route.c                | 18 +++++++-----------
 net/ipv4/syncookies.c           |  4 ++--
 net/ipv4/tcp_ipv4.c             |  2 +-
 net/ipv4/udp.c                  |  6 +++---
 net/l2tp/l2tp_ip.c              |  3 ++-
 net/sctp/protocol.c             |  6 ++++--
 20 files changed, 79 insertions(+), 68 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 90157e20357e62..0074563be80201 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2389,8 +2389,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		tags = NULL;
 
 		/* Find out through which dev should the packet go */
-		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
-				     RTO_ONLINK, 0);
+		rt = ip_route_output_link(dev_net(bond->dev), targets[i]);
 		if (IS_ERR(rt)) {
 			/* there's no route to target - try to send arp
 			 * probe to generate any traffic (arp_validate=0)
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 4e976a0d5a7644..a0437bac63f624 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -392,7 +392,8 @@ static struct rtable *ip4_route_output_gtp(struct net *net, struct flowi4 *fl4,
 	fl4->flowi4_oif		= sk->sk_bound_dev_if;
 	fl4->daddr		= daddr;
 	fl4->saddr		= inet_sk(sk)->inet_saddr;
-	fl4->flowi4_tos		= RT_CONN_FLAGS(sk);
+	fl4->flowi4_tos		= RT_TOS(inet_sk(sk)->tos);
+	fl4->flowi4_scope	= sk_rt_scope(sk);
 	fl4->flowi4_proto	= sk->sk_protocol;
 
 	return ip_route_output_key(net, fl4);
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index ae0905ed4a32b5..0696c5c24fda2f 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -491,7 +491,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 				   opt->dst_addr.sin_addr.s_addr,
 				   opt->src_addr.sin_addr.s_addr,
 				   0, 0,
-				   IPPROTO_GRE, RT_CONN_FLAGS(sk), 0);
+				   IPPROTO_GRE, RT_TOS(inet_sk(sk)->tos), 0);
 	if (IS_ERR(rt)) {
 		error = -EHOSTUNREACH;
 		goto end;
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b4d746943bc570..961d7905599150 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -37,9 +37,6 @@
 #include <net/l3mdev.h>
 #include <net/fib_rules.h>
 
-#define RT_FL_TOS(oldflp4) \
-	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
-
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
@@ -721,7 +718,6 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 	u32 orig_tos = fl4->flowi4_tos;
 	u8 flags = fl4->flowi4_flags;
 	u8 scope = fl4->flowi4_scope;
-	u8 tos = RT_FL_TOS(fl4);
 	int rc;
 
 	if (unlikely(!fl4->daddr))
@@ -731,9 +727,6 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	/* make sure oif is set to VRF device for lookup */
 	fl4->flowi4_oif = dev->ifindex;
-	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
-	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
-			     RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
 
 	rc = fib_lookup(net, fl4, &res, 0);
 	if (!rc) {
diff --git a/include/net/ip.h b/include/net/ip.h
index 37165fba3741ac..1b41763fb7900a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -153,11 +153,6 @@ static inline __u8 get_rttos(struct ipcm_cookie* ipc, struct inet_sock *inet)
 	return (ipc->tos != -1) ? RT_TOS(ipc->tos) : RT_TOS(inet->tos);
 }
 
-static inline __u8 get_rtconn_flags(struct ipcm_cookie* ipc, struct sock* sk)
-{
-	return (ipc->tos != -1) ? RT_CONN_FLAGS_TOS(sk, ipc->tos) : RT_CONN_FLAGS(sk);
-}
-
 /* datagram.c */
 int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
diff --git a/include/net/route.h b/include/net/route.h
index 8937e36fc9fd11..c374c217de7d7f 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -41,10 +41,13 @@
 /* IPv4 datagram length is stored into 16bit field (tot_len) */
 #define IP_MAX_MTU	0xFFFFU
 
-#define RTO_ONLINK	0x01
-
-#define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
-#define RT_CONN_FLAGS_TOS(sk,tos)   (RT_TOS(tos) | sock_flag(sk, SOCK_LOCALROUTE))
+static inline u8 sk_rt_scope(const struct sock *sk)
+{
+	if (sock_flag(sk, SOCK_LOCALROUTE))
+		return RT_SCOPE_LINK;
+	else
+		return RT_SCOPE_UNIVERSE;
+}
 
 struct fib_nh;
 struct fib_info;
@@ -133,8 +136,10 @@ static inline struct rtable *ip_route_output_key(struct net *net, struct flowi4
 	return ip_route_output_flow(net, flp, NULL);
 }
 
-static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
-					     __be32 saddr, u8 tos, int oif)
+static inline struct rtable *ip_route_output_scope(struct net *net,
+						   __be32 daddr,
+						   __be32 saddr, u8 tos,
+						   u8 scope, int oif)
 {
 	struct flowi4 fl4 = {
 		.flowi4_oif = oif,
@@ -145,6 +150,18 @@ static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
 	return ip_route_output_key(net, &fl4);
 }
 
+static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
+					     __be32 saddr, u8 tos, int oif)
+{
+	return ip_route_output_scope(net, daddr, saddr, tos, RT_SCOPE_UNIVERSE,
+				     oif);
+}
+
+static inline struct rtable *ip_route_output_link(struct net *net, __be32 daddr)
+{
+	return ip_route_output_scope(net, daddr, 0, 0, RT_SCOPE_LINK, 0);
+}
+
 static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi4 *fl4,
 						   struct sock *sk,
 						   __be32 daddr, __be32 saddr,
@@ -155,7 +172,7 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_mark = sk ? sk->sk_mark : 0;
 	fl4->flowi4_tos = tos;
-	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_scope = sk ? sk_rt_scope(sk) : RT_SCOPE_UNIVERSE;
 	fl4->flowi4_proto = proto;
 	fl4->flowi4_flags = sk ? inet_sk_flowi_flags(sk) : 0;
 	fl4->flowi4_secid = 0;
@@ -282,8 +299,8 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	fl4->flowi4_oif = oif;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_mark = sk->sk_mark;
-	fl4->flowi4_tos = tos;
-	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_tos = RT_TOS(tos);
+	fl4->flowi4_scope = sk_rt_scope(sk);
 	fl4->flowi4_proto = protocol;
 	fl4->flowi4_flags = flow_flags;
 	fl4->flowi4_secid = 0;
@@ -337,7 +354,8 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 		fl4->fl4_sport = sport;
 		ip_rt_put(rt);
 		fl4->flowi4_oif = sk->sk_bound_dev_if;
-		fl4->flowi4_tos = RT_CONN_FLAGS(sk);
+		fl4->flowi4_tos = RT_TOS(inet_sk(sk)->tos);
+		fl4->flowi4_scope = sk_rt_scope(sk);
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		return ip_route_output_flow(sock_net(sk), fl4, sk);
 	}
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5c7e413a3ae407..59df4a807d2991 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -73,7 +73,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	orig_dport = usin->sin_port;
 	fl4 = &inet->cork.fl.u.ip4;
 	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
-			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
+			      RT_TOS(inet_sk(sk)->tos), sk->sk_bound_dev_if,
 			      IPPROTO_DCCP,
 			      orig_sport, orig_dport, sk);
 	if (IS_ERR(rt))
@@ -453,7 +453,8 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 		.flowi4_oif = inet_iif(skb),
 		.daddr = iph->saddr,
 		.saddr = iph->daddr,
-		.flowi4_tos = RT_CONN_FLAGS(sk),
+		.flowi4_tos = RT_TOS(inet_sk(sk)->tos),
+		.flowi4_scope = sk_rt_scope(sk),
 		.flowi4_proto = sk->sk_protocol,
 		.fl4_sport = dccp_hdr(skb)->dccph_dport,
 		.fl4_dport = dccp_hdr(skb)->dccph_sport,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d39e9e47a26e55..7a62bb5f14e7d5 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1113,7 +1113,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 
 	/* Query new route. */
 	fl4 = &inet->cork.fl.u.ip4;
-	rt = ip_route_connect(fl4, daddr, 0, RT_CONN_FLAGS(sk),
+	rt = ip_route_connect(fl4, daddr, 0, RT_TOS(inet_sk(sk)->tos),
 			      sk->sk_bound_dev_if, sk->sk_protocol,
 			      inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt))
@@ -1167,7 +1167,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	fl4 = &inet->cork.fl.u.ip4;
 	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr, inet->inet_saddr,
 				   inet->inet_dport, inet->inet_sport,
-				   sk->sk_protocol, RT_CONN_FLAGS(sk),
+				   sk->sk_protocol, RT_TOS(inet_sk(sk)->tos),
 				   sk->sk_bound_dev_if);
 	if (!IS_ERR(rt)) {
 		err = 0;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 89a8cac4726a5e..d7e3a707bbd9ee 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -994,7 +994,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
 	if (!dev) {
-		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
+		struct rtable *rt = ip_route_output_link(net, ip);
 
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
@@ -1116,7 +1116,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (!dev) {
-		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
+		struct rtable *rt = ip_route_output_link(net, ip);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 		dev = rt->dst.dev;
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index f915abff1350a8..3c4d0b25222c8e 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -49,7 +49,7 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	}
 	fl4 = &inet->cork.fl.u.ip4;
 	rt = ip_route_connect(fl4, usin->sin_addr.s_addr, saddr,
-			      RT_CONN_FLAGS(sk), oif,
+			      RT_TOS(inet_sk(sk)->tos), oif,
 			      sk->sk_protocol,
 			      inet->inet_sport, usin->sin_port, sk);
 	if (IS_ERR(rt)) {
@@ -121,7 +121,8 @@ void ip4_datagram_release_cb(struct sock *sk)
 	rt = ip_route_output_ports(sock_net(sk), &fl4, sk, daddr,
 				   inet->inet_saddr, inet->inet_dport,
 				   inet->inet_sport, sk->sk_protocol,
-				   RT_CONN_FLAGS(sk), sk->sk_bound_dev_if);
+				   RT_TOS(inet_sk(sk)->tos),
+				   sk->sk_bound_dev_if);
 
 	dst = !IS_ERR(rt) ? &rt->dst : NULL;
 	sk_dst_set(sk, dst);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f84b851e050534..9289aca0c98cfd 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -413,8 +413,8 @@ struct dst_entry *inet_csk_route_req(const struct sock *sk,
 	fl4->flowi4_oif = ireq->ir_iif;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_mark = ireq->ir_mark;
-	fl4->flowi4_tos = RT_CONN_FLAGS(sk);
-	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_tos = RT_TOS(inet_sk(sk)->tos);
+	fl4->flowi4_scope = sk_rt_scope(sk);
 	fl4->flowi4_proto = sk->sk_protocol;
 	fl4->flowi4_flags = inet_sk_flowi_flags(sk);
 	fl4->flowi4_secid = 0;
@@ -459,8 +459,8 @@ struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
 	fl4->flowi4_oif = ireq->ir_iif;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_mark = ireq->ir_mark;
-	fl4->flowi4_tos = RT_CONN_FLAGS(sk);
-	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_tos = RT_TOS(inet_sk(sk)->tos);
+	fl4->flowi4_scope = sk_rt_scope(sk);
 	fl4->flowi4_proto = sk->sk_protocol;
 	fl4->flowi4_flags = inet_sk_flowi_flags(sk);
 	fl4->flowi4_secid = 0;
@@ -950,7 +950,8 @@ static struct dst_entry *inet_csk_rebuild_route(struct sock *sk, struct flowi *f
 	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr,
 				   inet->inet_saddr, inet->inet_dport,
 				   inet->inet_sport, sk->sk_protocol,
-				   RT_CONN_FLAGS(sk), sk->sk_bound_dev_if);
+				   RT_TOS(inet_sk(sk)->tos),
+				   sk->sk_bound_dev_if);
 	if (IS_ERR(rt))
 		rt = NULL;
 	if (rt)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 90076310888d7f..b016679c988e3a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -412,7 +412,7 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 					   inet->inet_dport,
 					   inet->inet_sport,
 					   sk->sk_protocol,
-					   RT_CONN_FLAGS(sk),
+					   RT_TOS(inet_sk(sk)->tos),
 					   sk->sk_bound_dev_if);
 		if (IS_ERR(rt))
 			goto no_route;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index dc6a42d1136752..87a901ce43c62b 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -708,7 +708,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	struct ip_options_data opt_copy;
 	int free = 0;
 	__be32 saddr, daddr, faddr;
-	u8  tos;
+	u8  tos, scope = RT_SCOPE_UNIVERSE;
 	int err;
 
 	pr_debug("ping_v4_sendmsg(sk=%p,sk->num=%u)\n", inet, inet->inet_num);
@@ -781,7 +781,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (sock_flag(sk, SOCK_LOCALROUTE) ||
 	    (msg->msg_flags & MSG_DONTROUTE) ||
 	    (ipc.opt && ipc.opt->opt.is_strictroute)) {
-		tos |= RTO_ONLINK;
+		scope = RT_SCOPE_LINK;
 	}
 
 	if (ipv4_is_multicast(daddr)) {
@@ -796,7 +796,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	fl4.flowi4_iif = LOOPBACK_IFINDEX;
 	fl4.flowi4_mark = sk->sk_mark;
 	fl4.flowi4_tos = tos;
-	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_scope = scope;
 	fl4.flowi4_proto = sk->sk_protocol;
 	fl4.flowi4_flags = inet_sk_flowi_flags(sk);
 	fl4.flowi4_secid = 0;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 50057df31fc9da..d4b4dedb44a1eb 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -495,7 +495,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	int free = 0;
 	__be32 daddr;
 	__be32 saddr;
-	u8  tos;
+	u8  tos, scope = RT_SCOPE_UNIVERSE;
 	int err;
 	struct ip_options_data opt_copy;
 	struct raw_frag_vec rfv;
@@ -587,9 +587,12 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			daddr = ipc.opt->opt.faddr;
 		}
 	}
-	tos = get_rtconn_flags(&ipc, sk);
-	if (msg->msg_flags & MSG_DONTROUTE)
-		tos |= RTO_ONLINK;
+
+	tos = get_rttos(&ipc, inet_sk(sk));
+
+	if (msg->msg_flags & MSG_DONTROUTE ||
+	    sock_flag(sk, SOCK_LOCALROUTE))
+		scope = RT_SCOPE_LINK;
 
 	if (ipv4_is_multicast(daddr)) {
 		if (!ipc.oif)
@@ -603,7 +606,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	fl4.flowi4_iif = LOOPBACK_IFINDEX;
 	fl4.flowi4_mark = sk->sk_mark;
 	fl4.flowi4_tos = tos;
-	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_scope = scope;
 	fl4.flowi4_proto = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
 	fl4.flowi4_flags = inet_sk_flowi_flags(sk) |
 			    inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e8f499d224ec2a..2446727ca6f980 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -114,9 +114,6 @@
 #include <net/ip_tunnels.h>
 #include <net/l3mdev.h>
 
-#define RT_FL_TOS(oldflp4) \
-	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
-
 #define RT_GC_TIMEOUT (300*HZ)
 
 static int ip_rt_max_size;
@@ -506,20 +503,23 @@ static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 			     int oif, u8 tos,
 			     u8 prot, u32 mark, int flow_flags)
 {
+	u8 scope = RT_SCOPE_UNIVERSE;
+
 	if (sk) {
 		const struct inet_sock *inet = inet_sk(sk);
 
 		oif = sk->sk_bound_dev_if;
 		mark = sk->sk_mark;
-		tos = RT_CONN_FLAGS(sk);
+		tos = RT_TOS(inet_sk(sk)->tos);
 		prot = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
+		scope = sk_rt_scope(sk);
 	}
 
 	fl4->flowi4_oif = oif;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_mark = mark;
 	fl4->flowi4_tos = tos;
-	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_scope = scope;
 	fl4->flowi4_proto = prot;
 	fl4->flowi4_flags = flow_flags;
 	fl4->flowi4_secid = 0;
@@ -556,8 +556,8 @@ static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
 	fl4->flowi4_oif = sk->sk_bound_dev_if;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_mark = sk->sk_mark;
-	fl4->flowi4_tos = RT_CONN_FLAGS(sk);
-	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4->flowi4_tos = RT_TOS(inet_sk(sk)->tos);
+	fl4->flowi4_scope = sk_rt_scope(sk);
 	fl4->flowi4_proto = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
 	fl4->flowi4_flags = inet_sk_flowi_flags(sk);
 	fl4->flowi4_secid = 0;
@@ -2162,7 +2162,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 					  int mp_hash)
 {
 	struct net_device *dev_out = NULL;
-	__u8 tos = RT_FL_TOS(fl4);
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
@@ -2180,9 +2179,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	if (master_idx)
 		fl4->flowi4_oif = master_idx;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
-	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
-	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
-			 RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
 
 	rcu_read_lock();
 	if (fl4->saddr) {
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index d5eedcae69f188..bdc23e4fafd64f 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -371,8 +371,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	fl4.flowi4_oif = ireq->ir_iif;
 	fl4.flowi4_iif = LOOPBACK_IFINDEX;
 	fl4.flowi4_mark = ireq->ir_mark;
-	fl4.flowi4_tos = RT_CONN_FLAGS(sk);
-	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_tos = RT_TOS(inet_sk(sk)->tos);
+	fl4.flowi4_scope = sk_rt_scope(sk);
 	fl4.flowi4_proto = IPPROTO_TCP;
 	fl4.flowi4_flags = inet_sk_flowi_flags(sk);
 	fl4.flowi4_secid = 0;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3708de2a66833c..a0d0f08090a39e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -168,7 +168,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	orig_dport = usin->sin_port;
 	fl4 = &inet->cork.fl.u.ip4;
 	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
-			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
+			      RT_TOS(inet_sk(sk)->tos), sk->sk_bound_dev_if,
 			      IPPROTO_TCP,
 			      orig_sport, orig_dport, sk);
 	if (IS_ERR(rt)) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2d3de2565e13bf..5203c1f89f6bb3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -923,7 +923,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	int connected = 0;
 	__be32 daddr, faddr, saddr;
 	__be16 dport;
-	u8  tos;
+	u8  tos, scope = RT_SCOPE_UNIVERSE;
 	int err, is_udplite = IS_UDPLITE(sk);
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
@@ -1034,7 +1034,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (sock_flag(sk, SOCK_LOCALROUTE) ||
 	    (msg->msg_flags & MSG_DONTROUTE) ||
 	    (ipc.opt && ipc.opt->opt.is_strictroute)) {
-		tos |= RTO_ONLINK;
+		scope = RT_SCOPE_LINK;
 		connected = 0;
 	}
 
@@ -1060,7 +1060,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		fl4->flowi4_iif = LOOPBACK_IFINDEX;
 		fl4->flowi4_mark = sk->sk_mark;
 		fl4->flowi4_tos = tos;
-		fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
+		fl4->flowi4_scope = scope;
 		fl4->flowi4_proto = sk->sk_protocol;
 		fl4->flowi4_flags = flow_flags;
 		fl4->flowi4_secid = 0;
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 42de4ccd159f6f..66b33bd8153d8b 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -470,7 +470,8 @@ static int l2tp_ip_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		rt = ip_route_output_ports(sock_net(sk), fl4, sk,
 					   daddr, inet->inet_saddr,
 					   inet->inet_dport, inet->inet_sport,
-					   sk->sk_protocol, RT_CONN_FLAGS(sk),
+					   sk->sk_protocol,
+					   RT_TOS(inet_sk(sk)->tos),
 					   sk->sk_bound_dev_if);
 		if (IS_ERR(rt))
 			goto no_route;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index f85b37a73ee633..5e8eee6182bbec 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -438,7 +438,8 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	fl4->fl4_dport = daddr->v4.sin_port;
 	fl4->flowi4_proto = IPPROTO_SCTP;
 	if (asoc) {
-		fl4->flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
+		fl4->flowi4_tos = RT_TOS(inet_sk(asoc->base.sk)->tos);
+		fl4->flowi4_scope = sk_rt_scope(asoc->base.sk);
 		fl4->flowi4_oif = asoc->base.sk->sk_bound_dev_if;
 		fl4->fl4_sport = htons(asoc->base.bind_addr.port);
 	}
@@ -500,7 +501,8 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 
 		fl4->fl4_sport = laddr->a.v4.sin_port;
 		fl4->flowi4_oif = asoc->base.sk->sk_bound_dev_if;
-		fl4->flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
+		fl4->flowi4_tos = RT_TOS(inet_sk(asoc->base.sk)->tos);
+		fl4->flowi4_scope = sk_rt_scope(asoc->base.sk);
 		fl4->daddr = daddr->v4.sin_addr.s_addr;
 		fl4->saddr = laddr->a.v4.sin_addr.s_addr;
 		rt = ip_route_output_key(sock_net(sk), fl4);
-- 
2.5.5
