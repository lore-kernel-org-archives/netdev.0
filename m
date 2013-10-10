From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 2/2] net: Remove FLOWI_FLAG_CAN_SLEEP
Date: Thu, 10 Oct 2013 08:34:21 +0200
Message-ID: <20131010063421.GQ7660@secunet.com>
References: <20131010063301.GO7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38411 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab3JJGeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:34:24 -0400
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id A2B231A007E
	for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:34:23 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id GR2UiGBNZ1wC for <netdev@vger.kernel.org>;
	Thu, 10 Oct 2013 08:34:22 +0200 (CEST)
Received: from mail-srv1.secumail.de (unknown [10.53.40.200])
	by a.mx.secunet.com (Postfix) with ESMTP id D94E71A007B
	for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:34:21 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20131010063301.GO7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FLOWI_FLAG_CAN_SLEEP was used to notify xfrm about the posibility
to sleep until the needed states are resolved. This code is gone,
so FLOWI_FLAG_CAN_SLEEP is not needed anymore.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/flow.h               |    3 +--
 include/net/ipv6.h               |    6 ++----
 include/net/route.h              |    8 +++-----
 net/dccp/ipv4.c                  |    2 +-
 net/dccp/ipv6.c                  |    8 ++++----
 net/decnet/dn_route.c            |    2 --
 net/ipv4/af_inet.c               |    2 +-
 net/ipv4/datagram.c              |    2 +-
 net/ipv4/raw.c                   |    2 +-
 net/ipv4/tcp_ipv4.c              |    2 +-
 net/ipv4/udp.c                   |    2 +-
 net/ipv6/af_inet6.c              |    2 +-
 net/ipv6/datagram.c              |    2 +-
 net/ipv6/inet6_connection_sock.c |    4 ++--
 net/ipv6/ip6_output.c            |   12 ++----------
 net/ipv6/ping.c                  |    2 +-
 net/ipv6/raw.c                   |    2 +-
 net/ipv6/syncookies.c            |    2 +-
 net/ipv6/tcp_ipv6.c              |    4 ++--
 net/ipv6/udp.c                   |    2 +-
 net/l2tp/l2tp_ip6.c              |    2 +-
 net/sctp/ipv6.c                  |    4 ++--
 22 files changed, 31 insertions(+), 46 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 65ce471..d23e7fa 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -20,8 +20,7 @@ struct flowi_common {
 	__u8	flowic_proto;
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
-#define FLOWI_FLAG_CAN_SLEEP		0x02
-#define FLOWI_FLAG_KNOWN_NH		0x04
+#define FLOWI_FLAG_KNOWN_NH		0x02
 	__u32	flowic_secid;
 };
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index fe1c7f6..4f91706 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -710,11 +710,9 @@ void ip6_flush_pending_frames(struct sock *sk);
 
 int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi6 *fl6);
 struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
-				      const struct in6_addr *final_dst,
-				      bool can_sleep);
+				      const struct in6_addr *final_dst);
 struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
-					 const struct in6_addr *final_dst,
-					 bool can_sleep);
+					 const struct in6_addr *final_dst);
 struct dst_entry *ip6_blackhole_route(struct net *net,
 				      struct dst_entry *orig_dst);
 
diff --git a/include/net/route.h b/include/net/route.h
index 0ad8e01..a25fcca 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -247,14 +247,12 @@ static inline char rt_tos2priority(u8 tos)
 static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32 src,
 					 u32 tos, int oif, u8 protocol,
 					 __be16 sport, __be16 dport,
-					 struct sock *sk, bool can_sleep)
+					 struct sock *sk)
 {
 	__u8 flow_flags = 0;
 
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
-	if (can_sleep)
-		flow_flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
@@ -264,13 +262,13 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 					      __be32 dst, __be32 src, u32 tos,
 					      int oif, u8 protocol,
 					      __be16 sport, __be16 dport,
-					      struct sock *sk, bool can_sleep)
+					      struct sock *sk)
 {
 	struct net *net = sock_net(sk);
 	struct rtable *rt;
 
 	ip_route_connect_init(fl4, dst, src, tos, oif, protocol,
-			      sport, dport, sk, can_sleep);
+			      sport, dport, sk);
 
 	if (!dst || !src) {
 		rt = __ip_route_output_key(net, fl4);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ebc54fe..751637a 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -75,7 +75,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
 			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			      IPPROTO_DCCP,
-			      orig_sport, orig_dport, sk, true);
+			      orig_sport, orig_dport, sk);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6cf9f77..3d2574e 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -237,7 +237,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		dst = NULL;
@@ -302,7 +302,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	security_skb_classify_flow(rxskb, flowi6_to_flowi(&fl6));
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
-	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
+	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(skb, dst);
 		ip6_xmit(ctl_sk, skb, &fl6, NULL, 0);
@@ -513,7 +513,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		fl6.fl6_sport = inet_rsk(req)->loc_port;
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
+		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 		if (IS_ERR(dst))
 			goto out;
 	}
@@ -933,7 +933,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto failure;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index fe32388..ad2efa5 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1288,8 +1288,6 @@ int dn_route_output_sock(struct dst_entry __rcu **pprt, struct flowidn *fl, stru
 
 	err = __dn_route_output_key(pprt, fl, flags & MSG_TRYHARD);
 	if (err == 0 && fl->flowidn_proto) {
-		if (!(flags & MSG_DONTWAIT))
-			fl->flowidn_flags |= FLOWI_FLAG_CAN_SLEEP;
 		*pprt = xfrm_lookup(&init_net, *pprt,
 				    flowidn_to_flowi(fl), sk, 0);
 		if (IS_ERR(*pprt)) {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7a1874b..c3bf51e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1162,7 +1162,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	fl4 = &inet->cork.fl.u.ip4;
 	rt = ip_route_connect(fl4, daddr, 0, RT_CONN_FLAGS(sk),
 			      sk->sk_bound_dev_if, sk->sk_protocol,
-			      inet->inet_sport, inet->inet_dport, sk, false);
+			      inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index b28e863..dcd4148 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -53,7 +53,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rt = ip_route_connect(fl4, usin->sin_addr.s_addr, saddr,
 			      RT_CONN_FLAGS(sk), oif,
 			      sk->sk_protocol,
-			      inet->inet_sport, usin->sin_port, sk, true);
+			      inet->inet_sport, usin->sin_port, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a3fe534..6fd4d0c 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -573,7 +573,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-			   inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP |
+			   inet_sk_flowi_flags(sk) |
 			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
 			   daddr, saddr, 0, 0);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b14266b..6959be9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -173,7 +173,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
 			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			      IPPROTO_TCP,
-			      orig_sport, orig_dport, sk, true);
+			      orig_sport, orig_dport, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 22462d94..70a9e28 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -966,7 +966,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		fl4 = &fl4_stack;
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-				   inet_sk_flowi_flags(sk)|FLOWI_FLAG_CAN_SLEEP,
+				   inet_sk_flowi_flags(sk),
 				   faddr, saddr, dport, inet->inet_sport);
 
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 4966b12..cd3c181 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -666,7 +666,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
 
-		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
+		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 		if (IS_ERR(dst)) {
 			sk->sk_route_caps = 0;
 			sk->sk_err_soft = -PTR_ERR(dst);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 48b6bd2..0bc3297 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -171,7 +171,7 @@ ipv4_connected:
 	opt = flowlabel ? flowlabel->opt : np->opt;
 	final_p = fl6_update_dst(&fl6, opt, &final);
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	err = 0;
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index e4311cb..b65ca8c 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -86,7 +86,7 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	fl6->fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, flowi6_to_flowi(fl6));
 
-	dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
+	dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 	if (IS_ERR(dst))
 		return NULL;
 
@@ -217,7 +217,7 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 
 	dst = __inet6_csk_dst_check(sk, np->dst_cookie);
 	if (!dst) {
-		dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
+		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 
 		if (!IS_ERR(dst))
 			__inet6_csk_dst_store(sk, dst, NULL, NULL);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3a692d5..7a0d3c4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -937,7 +937,6 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup);
  *	@sk: socket which provides route info
  *	@fl6: flow to lookup
  *	@final_dst: final destination address for ipsec lookup
- *	@can_sleep: we are in a sleepable context
  *
  *	This function performs a route lookup on the given flow.
  *
@@ -945,8 +944,7 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup);
  *	error code.
  */
 struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
-				      const struct in6_addr *final_dst,
-				      bool can_sleep)
+				      const struct in6_addr *final_dst)
 {
 	struct dst_entry *dst = NULL;
 	int err;
@@ -956,8 +954,6 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 		return ERR_PTR(err);
 	if (final_dst)
 		fl6->daddr = *final_dst;
-	if (can_sleep)
-		fl6->flowi6_flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
@@ -968,7 +964,6 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
  *	@sk: socket which provides the dst cache and route info
  *	@fl6: flow to lookup
  *	@final_dst: final destination address for ipsec lookup
- *	@can_sleep: we are in a sleepable context
  *
  *	This function performs a route lookup on the given flow with the
  *	possibility of using the cached route in the socket if it is valid.
@@ -979,8 +974,7 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
  *	error code.
  */
 struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
-					 const struct in6_addr *final_dst,
-					 bool can_sleep)
+					 const struct in6_addr *final_dst)
 {
 	struct dst_entry *dst = sk_dst_check(sk, inet6_sk(sk)->dst_cookie);
 	int err;
@@ -992,8 +986,6 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 		return ERR_PTR(err);
 	if (final_dst)
 		fl6->daddr = *final_dst;
-	if (can_sleep)
-		fl6->flowi6_flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 18f19df..4ec91bb 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -144,7 +144,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	else if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->ucast_oif;
 
-	dst = ip6_sk_dst_lookup_flow(sk, &fl6,  daddr, 1);
+	dst = ip6_sk_dst_lookup_flow(sk, &fl6,  daddr);
 	if (IS_ERR(dst))
 		return PTR_ERR(dst);
 	rt = (struct rt6_info *) dst;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 58916bb..c74425d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -866,7 +866,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		fl6.flowi6_oif = np->ucast_oif;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto out;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d703218..b0fbbfc 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -243,7 +243,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		fl6.fl6_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
-		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
+		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 		if (IS_ERR(dst))
 			goto out_free;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5c71501..b762603 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -258,7 +258,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto failure;
@@ -800,7 +800,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	 * Underlying function will use this to retrieve the network
 	 * namespace
 	 */
-	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
+	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
 		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f405815..a20b562 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1204,7 +1204,7 @@ do_udp_sendmsg:
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	dst = ip6_sk_dst_lookup_flow(sk, &fl6, final_p, true);
+	dst = ip6_sk_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		dst = NULL;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index b8a6039..d1149aa 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -598,7 +598,7 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto out;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e7b2d4f..2b3d523 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -263,7 +263,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	}
 
 	final_p = fl6_update_dst(fl6, np->opt, &final);
-	dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
+	dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 	if (!asoc || saddr)
 		goto out;
 
@@ -320,7 +320,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		fl6->saddr = baddr->v6.sin6_addr;
 		fl6->fl6_sport = baddr->v6.sin6_port;
 		final_p = fl6_update_dst(fl6, np->opt, &final);
-		dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
+		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 	}
 
 out:
-- 
1.7.9.5
