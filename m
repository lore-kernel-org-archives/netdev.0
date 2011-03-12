From: David Miller <davem@davemloft.net>
Subject: [PATCH 24/25] net: Put fl6_* macros to struct flowi6 and use them
 again.
Date: Sat, 12 Mar 2011 15:32:19 -0800 (PST)
Message-ID: <20110312.153219.02272559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756080Ab1CLXbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:31:42 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DC77324C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:32:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h               |   17 +++++++----------
 net/dccp/ipv6.c                  |   20 ++++++++++----------
 net/ipv6/af_inet6.c              |    4 ++--
 net/ipv6/datagram.c              |    6 +++---
 net/ipv6/icmp.c                  |   10 +++++-----
 net/ipv6/inet6_connection_sock.c |    8 ++++----
 net/ipv6/mip6.c                  |    2 +-
 net/ipv6/netfilter/ip6t_REJECT.c |    4 ++--
 net/ipv6/raw.c                   |    6 +++---
 net/ipv6/syncookies.c            |    4 ++--
 net/ipv6/tcp_ipv6.c              |   16 ++++++++--------
 net/ipv6/udp.c                   |   10 +++++-----
 net/ipv6/xfrm6_policy.c          |   12 ++++++------
 13 files changed, 58 insertions(+), 61 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 44bd376..172d76d 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -84,6 +84,13 @@ struct flowi6 {
 	struct in6_addr		saddr;
 	__be32			flowlabel;
 	union flowi_uli		uli;
+#define fl6_sport		uli.ports.sport
+#define fl6_dport		uli.ports.dport
+#define fl6_icmp_type		uli.icmpt.type
+#define fl6_icmp_code		uli.icmpt.code
+#define fl6_ipsec_spi		uli.spi
+#define fl6_mh_type		uli.mht.type
+#define fl6_gre_key		uli.gre_key
 };
 
 struct flowidn {
@@ -112,16 +119,6 @@ struct flowi {
 
 #define fld_dst		u.dn.daddr
 #define fld_src		u.dn.saddr
-#define fl6_dst		u.ip6.daddr
-#define fl6_src		u.ip6.saddr
-#define fl6_flowlabel	u.ip6.flowlabel
-#define fl6_sport	u.ip6.uli.ports.sport
-#define fl6_dport	u.ip6.uli.ports.dport
-#define fl6_icmp_type	u.ip6.uli.icmpt.type
-#define fl6_icmp_code	u.ip6.uli.icmpt.code
-#define fl6_ipsec_spi	u.ip6.uli.spi
-#define fl6_mh_type	u.ip6.uli.mht.type
-#define fl6_gre_key	u.ip6.uli.gre_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 8d26c12..de1b7e3 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -158,8 +158,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl6.daddr, &np->daddr);
 			ipv6_addr_copy(&fl6.saddr, &np->saddr);
 			fl6.flowi6_oif = sk->sk_bound_dev_if;
-			fl6.uli.ports.dport = inet->inet_dport;
-			fl6.uli.ports.sport = inet->inet_sport;
+			fl6.fl6_dport = inet->inet_dport;
+			fl6.fl6_sport = inet->inet_sport;
 			security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 			dst = ip6_dst_lookup_flow(sk, &fl6, NULL, false);
@@ -253,8 +253,8 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
 	fl6.flowlabel = 0;
 	fl6.flowi6_oif = ireq6->iif;
-	fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
-	fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+	fl6.fl6_dport = inet_rsk(req)->rmt_port;
+	fl6.fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 	opt = np->opt;
@@ -323,8 +323,8 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 
 	fl6.flowi6_proto = IPPROTO_DCCP;
 	fl6.flowi6_oif = inet6_iif(rxskb);
-	fl6.uli.ports.dport = dccp_hdr(skb)->dccph_dport;
-	fl6.uli.ports.sport = dccp_hdr(skb)->dccph_sport;
+	fl6.fl6_dport = dccp_hdr(skb)->dccph_dport;
+	fl6.fl6_sport = dccp_hdr(skb)->dccph_sport;
 	security_skb_classify_flow(rxskb, flowi6_to_flowi(&fl6));
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
@@ -535,8 +535,8 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		final_p = fl6_update_dst(&fl6, opt, &final);
 		ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
-		fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
-		fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+		fl6.fl6_dport = inet_rsk(req)->rmt_port;
+		fl6.fl6_sport = inet_rsk(req)->loc_port;
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
@@ -957,8 +957,8 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	ipv6_addr_copy(&fl6.daddr, &np->daddr);
 	ipv6_addr_copy(&fl6.saddr, saddr ? saddr : &np->saddr);
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
-	fl6.uli.ports.dport = usin->sin6_port;
-	fl6.uli.ports.sport = inet->inet_sport;
+	fl6.fl6_dport = usin->sin6_port;
+	fl6.fl6_sport = inet->inet_sport;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 689eea6..4b13d5d 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -661,8 +661,8 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		fl6.flowlabel = np->flow_label;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.flowi6_mark = sk->sk_mark;
-		fl6.uli.ports.dport = inet->inet_dport;
-		fl6.uli.ports.sport = inet->inet_sport;
+		fl6.fl6_dport = inet->inet_dport;
+		fl6.fl6_sport = inet->inet_sport;
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 04ae676..1656033 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -151,8 +151,8 @@ ipv4_connected:
 	ipv6_addr_copy(&fl6.saddr, &np->saddr);
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
-	fl6.uli.ports.dport = inet->inet_dport;
-	fl6.uli.ports.sport = inet->inet_sport;
+	fl6.fl6_dport = inet->inet_dport;
+	fl6.fl6_sport = inet->inet_sport;
 
 	if (!fl6.flowi6_oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl6.flowi6_oif = np->mcast_oif;
@@ -261,7 +261,7 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info)
 	serr->ee.ee_info = info;
 	serr->ee.ee_data = 0;
 	serr->addr_offset = (u8 *)&iph->daddr - skb_network_header(skb);
-	serr->port = fl6->uli.ports.dport;
+	serr->port = fl6->fl6_dport;
 
 	__skb_pull(skb, skb_tail_pointer(skb) - skb->data);
 	skb_reset_transport_header(skb);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index f7b9041..83cb4f9 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -448,8 +448,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	if (saddr)
 		ipv6_addr_copy(&fl6.saddr, saddr);
 	fl6.flowi6_oif = iif;
-	fl6.uli.icmpt.type = type;
-	fl6.uli.icmpt.code = code;
+	fl6.fl6_icmp_type = type;
+	fl6.fl6_icmp_code = code;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
@@ -544,7 +544,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	if (saddr)
 		ipv6_addr_copy(&fl6.saddr, saddr);
 	fl6.flowi6_oif = skb->dev->ifindex;
-	fl6.uli.icmpt.type = ICMPV6_ECHO_REPLY;
+	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
@@ -794,8 +794,8 @@ void icmpv6_flow_init(struct sock *sk, struct flowi6 *fl6,
 	ipv6_addr_copy(&fl6->saddr, saddr);
 	ipv6_addr_copy(&fl6->daddr, daddr);
 	fl6->flowi6_proto 	= IPPROTO_ICMPV6;
-	fl6->uli.icmpt.type	= type;
-	fl6->uli.icmpt.code	= 0;
+	fl6->fl6_icmp_type	= type;
+	fl6->fl6_icmp_code	= 0;
 	fl6->flowi6_oif		= oif;
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 }
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 27d6691..1660546 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -70,8 +70,8 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	ipv6_addr_copy(&fl6.saddr, &treq->loc_addr);
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
-	fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
-	fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+	fl6.fl6_dport = inet_rsk(req)->rmt_port;
+	fl6.fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
@@ -220,8 +220,8 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
-	fl6.uli.ports.sport = inet->inet_sport;
-	fl6.uli.ports.dport = inet->inet_dport;
+	fl6.fl6_sport = inet->inet_sport;
+	fl6.fl6_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 6a13735..9b21048 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -216,7 +216,7 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	int err = 0;
 
 	if (unlikely(fl6->flowi6_proto == IPPROTO_MH &&
-		     fl6->uli.mht.type <= IP6_MH_TYPE_MAX))
+		     fl6->fl6_mh_type <= IP6_MH_TYPE_MAX))
 		goto out;
 
 	if (likely(opt->dsthao)) {
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index df05511..28e7448 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -93,8 +93,8 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	fl6.flowi6_proto = IPPROTO_TCP;
 	ipv6_addr_copy(&fl6.saddr, &oip6h->daddr);
 	ipv6_addr_copy(&fl6.daddr, &oip6h->saddr);
-	fl6.uli.ports.sport = otcph.dest;
-	fl6.uli.ports.dport = otcph.source;
+	fl6.fl6_sport = otcph.dest;
+	fl6.fl6_dport = otcph.source;
 	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst == NULL || dst->error) {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 259f1b2..4a1c3b4 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -693,8 +693,8 @@ static int rawv6_probe_proto_opt(struct flowi6 *fl6, struct msghdr *msg)
 				code = iov->iov_base;
 
 			if (type && code) {
-				if (get_user(fl6->uli.icmpt.type, type) ||
-				    get_user(fl6->uli.icmpt.code, code))
+				if (get_user(fl6->fl6_icmp_type, type) ||
+				    get_user(fl6->fl6_icmp_code, code))
 					return -EFAULT;
 				probed = 1;
 			}
@@ -705,7 +705,7 @@ static int rawv6_probe_proto_opt(struct flowi6 *fl6, struct msghdr *msg)
 			/* check if type field is readable or not. */
 			if (iov->iov_len > 2 - len) {
 				u8 __user *p = iov->iov_base;
-				if (get_user(fl6->uli.mht.type, &p[2 - len]))
+				if (get_user(fl6->fl6_mh_type, &p[2 - len]))
 					return -EFAULT;
 				probed = 1;
 			} else
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 97858d5..352c260 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -240,8 +240,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.flowi6_mark = sk->sk_mark;
-		fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
-		fl6.uli.ports.sport = inet_sk(sk)->inet_sport;
+		fl6.fl6_dport = inet_rsk(req)->rmt_port;
+		fl6.fl6_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7ed0ba1..2b0c186 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -248,8 +248,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		       (saddr ? saddr : &np->saddr));
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
-	fl6.uli.ports.dport = usin->sin6_port;
-	fl6.uli.ports.sport = inet->inet_sport;
+	fl6.fl6_dport = usin->sin6_port;
+	fl6.fl6_sport = inet->inet_sport;
 
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
@@ -401,8 +401,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl6.saddr, &np->saddr);
 			fl6.flowi6_oif = sk->sk_bound_dev_if;
 			fl6.flowi6_mark = sk->sk_mark;
-			fl6.uli.ports.dport = inet->inet_dport;
-			fl6.uli.ports.sport = inet->inet_sport;
+			fl6.fl6_dport = inet->inet_dport;
+			fl6.fl6_sport = inet->inet_sport;
 			security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 			dst = ip6_dst_lookup_flow(sk, &fl6, NULL, false);
@@ -493,8 +493,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	fl6.flowlabel = 0;
 	fl6.flowi6_oif = treq->iif;
 	fl6.flowi6_mark = sk->sk_mark;
-	fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
-	fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+	fl6.fl6_dport = inet_rsk(req)->rmt_port;
+	fl6.fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 	opt = np->opt;
@@ -1057,8 +1057,8 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 
 	fl6.flowi6_proto = IPPROTO_TCP;
 	fl6.flowi6_oif = inet6_iif(skb);
-	fl6.uli.ports.dport = t1->dest;
-	fl6.uli.ports.sport = t1->source;
+	fl6.fl6_dport = t1->dest;
+	fl6.fl6_sport = t1->source;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	/* Pass a socket to ip6_dst_lookup either it is for RST
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index ce4b16f..d7037c0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -899,8 +899,8 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	 * Create a UDP header
 	 */
 	uh = udp_hdr(skb);
-	uh->source = fl6->uli.ports.sport;
-	uh->dest = fl6->uli.ports.dport;
+	uh->source = fl6->fl6_sport;
+	uh->dest = fl6->fl6_dport;
 	uh->len = htons(up->len);
 	uh->check = 0;
 
@@ -1036,7 +1036,7 @@ do_udp_sendmsg:
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
-		fl6.uli.ports.dport = sin6->sin6_port;
+		fl6.fl6_dport = sin6->sin6_port;
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
@@ -1065,7 +1065,7 @@ do_udp_sendmsg:
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		fl6.uli.ports.dport = inet->inet_dport;
+		fl6.fl6_dport = inet->inet_dport;
 		daddr = &np->daddr;
 		fl6.flowlabel = np->flow_label;
 		connected = 1;
@@ -1112,7 +1112,7 @@ do_udp_sendmsg:
 		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
 	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl6.saddr, &np->saddr);
-	fl6.uli.ports.sport = inet->inet_sport;
+	fl6.fl6_sport = inet->inet_sport;
 
 	final_p = fl6_update_dst(&fl6, opt, &final);
 	if (final_p)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index bef6200..05e34c8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -160,8 +160,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			     pskb_may_pull(skb, nh + offset + 4 - skb->data))) {
 				__be16 *ports = (__be16 *)exthdr;
 
-				fl6->uli.ports.sport = ports[!!reverse];
-				fl6->uli.ports.dport = ports[!reverse];
+				fl6->fl6_sport = ports[!!reverse];
+				fl6->fl6_dport = ports[!reverse];
 			}
 			fl6->flowi6_proto = nexthdr;
 			return;
@@ -170,8 +170,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
 				u8 *icmp = (u8 *)exthdr;
 
-				fl6->uli.icmpt.type = icmp[0];
-				fl6->uli.icmpt.code = icmp[1];
+				fl6->fl6_icmp_type = icmp[0];
+				fl6->fl6_icmp_code = icmp[1];
 			}
 			fl6->flowi6_proto = nexthdr;
 			return;
@@ -182,7 +182,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 				struct ip6_mh *mh;
 				mh = (struct ip6_mh *)exthdr;
 
-				fl6->uli.mht.type = mh->ip6mh_type;
+				fl6->fl6_mh_type = mh->ip6mh_type;
 			}
 			fl6->flowi6_proto = nexthdr;
 			return;
@@ -193,7 +193,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_ESP:
 		case IPPROTO_COMP:
 		default:
-			fl6->uli.spi = 0;
+			fl6->fl6_ipsec_spi = 0;
 			fl6->flowi6_proto = nexthdr;
 			return;
 		}
-- 
1.7.4.1

