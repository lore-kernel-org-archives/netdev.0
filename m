From: David Miller <davem@davemloft.net>
Subject: [PATCH 23/25] ipv6: Convert to use flowi6 where applicable.
Date: Sat, 12 Mar 2011 15:32:02 -0800 (PST)
Message-ID: <20110312.153202.233702120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756080Ab1CLXb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:31:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0892B24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:32:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c   |   18 +++---
 drivers/net/cnic.c               |   12 ++--
 include/linux/icmpv6.h           |    4 +-
 include/net/ip6_fib.h            |    4 +-
 include/net/ip6_route.h          |    2 +-
 include/net/ipv6.h               |   16 ++--
 include/net/transp_v6.h          |    4 +-
 net/dccp/ipv6.c                  |  132 +++++++++++++++++++-------------------
 net/ipv6/af_inet6.c              |   32 +++++-----
 net/ipv6/datagram.c              |   75 +++++++++++-----------
 net/ipv6/exthdrs.c               |   12 ++--
 net/ipv6/fib6_rules.c            |   19 +++--
 net/ipv6/icmp.c                  |  110 ++++++++++++++++----------------
 net/ipv6/inet6_connection_sock.c |   60 +++++++++---------
 net/ipv6/ip6_fib.c               |    4 +-
 net/ipv6/ip6_flowlabel.c         |    6 +-
 net/ipv6/ip6_output.c            |   90 +++++++++++++-------------
 net/ipv6/ip6_tunnel.c            |   50 +++++++-------
 net/ipv6/ip6mr.c                 |   53 ++++++++--------
 net/ipv6/ipv6_sockglue.c         |   10 ++--
 net/ipv6/mcast.c                 |   12 ++--
 net/ipv6/mip6.c                  |   13 ++--
 net/ipv6/ndisc.c                 |   14 ++--
 net/ipv6/netfilter.c             |   18 +++---
 net/ipv6/netfilter/ip6t_REJECT.c |   20 +++---
 net/ipv6/raw.c                   |   79 +++++++++++------------
 net/ipv6/route.c                 |   96 ++++++++++++++--------------
 net/ipv6/syncookies.c            |   26 ++++----
 net/ipv6/tcp_ipv6.c              |  114 ++++++++++++++++----------------
 net/ipv6/udp.c                   |   76 +++++++++++-----------
 net/ipv6/xfrm6_policy.c          |    3 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |   10 +--
 net/netfilter/ipvs/ip_vs_xmit.c  |   14 ++--
 net/netfilter/xt_TEE.c           |   12 ++--
 net/sctp/ipv6.c                  |   42 ++++++------
 35 files changed, 632 insertions(+), 630 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 3c2b309..e0ef5fd 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -231,28 +231,28 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 			 struct sockaddr_in6 *dst_in,
 			 struct rdma_dev_addr *addr)
 {
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct neighbour *neigh;
 	struct dst_entry *dst;
 	int ret;
 
-	memset(&fl, 0, sizeof fl);
-	ipv6_addr_copy(&fl.fl6_dst, &dst_in->sin6_addr);
-	ipv6_addr_copy(&fl.fl6_src, &src_in->sin6_addr);
-	fl.flowi_oif = addr->bound_dev_if;
+	memset(&fl6, 0, sizeof fl6);
+	ipv6_addr_copy(&fl6.daddr, &dst_in->sin6_addr);
+	ipv6_addr_copy(&fl6.saddr, &src_in->sin6_addr);
+	fl6.flowi6_oif = addr->bound_dev_if;
 
-	dst = ip6_route_output(&init_net, NULL, &fl);
+	dst = ip6_route_output(&init_net, NULL, &fl6);
 	if ((ret = dst->error))
 		goto put;
 
-	if (ipv6_addr_any(&fl.fl6_src)) {
+	if (ipv6_addr_any(&fl6.saddr)) {
 		ret = ipv6_dev_get_saddr(&init_net, ip6_dst_idev(dst)->dev,
-					 &fl.fl6_dst, 0, &fl.fl6_src);
+					 &fl6.daddr, 0, &fl6.saddr);
 		if (ret)
 			goto put;
 
 		src_in->sin6_family = AF_INET6;
-		ipv6_addr_copy(&src_in->sin6_addr, &fl.fl6_src);
+		ipv6_addr_copy(&src_in->sin6_addr, &fl6.saddr);
 	}
 
 	if (dst->dev->flags & IFF_LOOPBACK) {
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index c8922f6..8cca60e 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3424,14 +3424,14 @@ static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
 			     struct dst_entry **dst)
 {
 #if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
-	struct flowi fl;
+	struct flowi6 fl6;
 
-	memset(&fl, 0, sizeof(fl));
-	ipv6_addr_copy(&fl.fl6_dst, &dst_addr->sin6_addr);
-	if (ipv6_addr_type(&fl.fl6_dst) & IPV6_ADDR_LINKLOCAL)
-		fl.flowi_oif = dst_addr->sin6_scope_id;
+	memset(&fl6, 0, sizeof(fl6));
+	ipv6_addr_copy(&fl6.daddr, &dst_addr->sin6_addr);
+	if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
+		fl6.flowi6_oif = dst_addr->sin6_scope_id;
 
-	*dst = ip6_route_output(&init_net, NULL, &fl);
+	*dst = ip6_route_output(&init_net, NULL, &fl6);
 	if (*dst)
 		return 0;
 #endif
diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 4c4c74e..ba45e6b 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -183,10 +183,10 @@ extern void				icmpv6_cleanup(void);
 extern void				icmpv6_param_prob(struct sk_buff *skb,
 							  u8 code, int pos);
 
-struct flowi;
+struct flowi6;
 struct in6_addr;
 extern void				icmpv6_flow_init(struct sock *sk,
-							 struct flowi *fl,
+							 struct flowi6 *fl6,
 							 u8 type,
 							 const struct in6_addr *saddr,
 							 const struct in6_addr *daddr,
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 46a6e8a..bc3cde0 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -183,7 +183,7 @@ struct fib6_table {
 
 typedef struct rt6_info *(*pol_lookup_t)(struct net *,
 					 struct fib6_table *,
-					 struct flowi *, int);
+					 struct flowi6 *, int);
 
 /*
  *	exported functions
@@ -192,7 +192,7 @@ typedef struct rt6_info *(*pol_lookup_t)(struct net *,
 extern struct fib6_table        *fib6_get_table(struct net *net, u32 id);
 extern struct fib6_table        *fib6_new_table(struct net *net, u32 id);
 extern struct dst_entry         *fib6_rule_lookup(struct net *net,
-						  struct flowi *fl, int flags,
+						  struct flowi6 *fl6, int flags,
 						  pol_lookup_t lookup);
 
 extern struct fib6_node		*fib6_lookup(struct fib6_node *root,
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 8552f0a..642a80b 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -71,7 +71,7 @@ extern void			ip6_route_input(struct sk_buff *skb);
 
 extern struct dst_entry *	ip6_route_output(struct net *net,
 						 struct sock *sk,
-						 struct flowi *fl);
+						 struct flowi6 *fl6);
 
 extern int			ip6_route_init(void);
 extern void			ip6_route_cleanup(void);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4635a5c..34200f9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -492,7 +492,7 @@ extern int			ip6_rcv_finish(struct sk_buff *skb);
  */
 extern int			ip6_xmit(struct sock *sk,
 					 struct sk_buff *skb,
-					 struct flowi *fl,
+					 struct flowi6 *fl6,
 					 struct ipv6_txoptions *opt);
 
 extern int			ip6_nd_hdr(struct sock *sk,
@@ -512,7 +512,7 @@ extern int			ip6_append_data(struct sock *sk,
 		      				int hlimit,
 		      				int tclass,
 						struct ipv6_txoptions *opt,
-						struct flowi *fl,
+						struct flowi6 *fl6,
 						struct rt6_info *rt,
 						unsigned int flags,
 						int dontfrag);
@@ -523,13 +523,13 @@ extern void			ip6_flush_pending_frames(struct sock *sk);
 
 extern int			ip6_dst_lookup(struct sock *sk,
 					       struct dst_entry **dst,
-					       struct flowi *fl);
+					       struct flowi6 *fl6);
 extern struct dst_entry *	ip6_dst_lookup_flow(struct sock *sk,
-						    struct flowi *fl,
+						    struct flowi6 *fl6,
 						    const struct in6_addr *final_dst,
 						    bool can_sleep);
 extern struct dst_entry *	ip6_sk_dst_lookup_flow(struct sock *sk,
-						       struct flowi *fl,
+						       struct flowi6 *fl6,
 						       const struct in6_addr *final_dst,
 						       bool can_sleep);
 extern struct dst_entry *	ip6_blackhole_route(struct net *net,
@@ -566,7 +566,7 @@ extern int 			ipv6_ext_hdr(u8 nexthdr);
 
 extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
 
-extern struct in6_addr *fl6_update_dst(struct flowi *fl,
+extern struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 				       const struct ipv6_txoptions *opt,
 				       struct in6_addr *orig);
 
@@ -600,8 +600,8 @@ extern int 			ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len);
 extern int 			ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len);
 extern void			ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
 						u32 info, u8 *payload);
-extern void			ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info);
-extern void			ipv6_local_rxpmtu(struct sock *sk, struct flowi *fl, u32 mtu);
+extern void			ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info);
+extern void			ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu);
 
 extern int inet6_release(struct socket *sock);
 extern int inet6_bind(struct socket *sock, struct sockaddr *uaddr, 
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 42a0eb6..eeb077d 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -14,7 +14,7 @@ extern struct proto udpv6_prot;
 extern struct proto udplitev6_prot;
 extern struct proto tcpv6_prot;
 
-struct flowi;
+struct flowi6;
 
 /* extention headers */
 extern int				ipv6_exthdrs_init(void);
@@ -42,7 +42,7 @@ extern int			datagram_recv_ctl(struct sock *sk,
 
 extern int			datagram_send_ctl(struct net *net,
 						  struct msghdr *msg,
-						  struct flowi *fl,
+						  struct flowi6 *fl6,
 						  struct ipv6_txoptions *opt,
 						  int *hlimit, int *tclass,
 						  int *dontfrag);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 2b351c6..8d26c12 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -147,22 +147,22 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		dst = __sk_dst_check(sk, np->dst_cookie);
 		if (dst == NULL) {
 			struct inet_sock *inet = inet_sk(sk);
-			struct flowi fl;
+			struct flowi6 fl6;
 
 			/* BUGGG_FUTURE: Again, it is not clear how
 			   to handle rthdr case. Ignore this complexity
 			   for now.
 			 */
-			memset(&fl, 0, sizeof(fl));
-			fl.flowi_proto = IPPROTO_DCCP;
-			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-			fl.flowi_oif = sk->sk_bound_dev_if;
-			fl.fl6_dport = inet->inet_dport;
-			fl.fl6_sport = inet->inet_sport;
-			security_sk_classify_flow(sk, &fl);
-
-			dst = ip6_dst_lookup_flow(sk, &fl, NULL, false);
+			memset(&fl6, 0, sizeof(fl6));
+			fl6.flowi6_proto = IPPROTO_DCCP;
+			ipv6_addr_copy(&fl6.daddr, &np->daddr);
+			ipv6_addr_copy(&fl6.saddr, &np->saddr);
+			fl6.flowi6_oif = sk->sk_bound_dev_if;
+			fl6.uli.ports.dport = inet->inet_dport;
+			fl6.uli.ports.sport = inet->inet_sport;
+			security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
+
+			dst = ip6_dst_lookup_flow(sk, &fl6, NULL, false);
 			if (IS_ERR(dst)) {
 				sk->sk_err_soft = -PTR_ERR(dst);
 				goto out;
@@ -243,25 +243,25 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	struct sk_buff *skb;
 	struct ipv6_txoptions *opt = NULL;
 	struct in6_addr *final_p, final;
-	struct flowi fl;
+	struct flowi6 fl6;
 	int err = -1;
 	struct dst_entry *dst;
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = IPPROTO_DCCP;
-	ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-	ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
-	fl.fl6_flowlabel = 0;
-	fl.flowi_oif = ireq6->iif;
-	fl.fl6_dport = inet_rsk(req)->rmt_port;
-	fl.fl6_sport = inet_rsk(req)->loc_port;
-	security_req_classify_flow(req, &fl);
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_DCCP;
+	ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
+	ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
+	fl6.flowlabel = 0;
+	fl6.flowi6_oif = ireq6->iif;
+	fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
+	fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 	opt = np->opt;
 
-	final_p = fl6_update_dst(&fl, opt, &final);
+	final_p = fl6_update_dst(&fl6, opt, &final);
 
-	dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		dst = NULL;
@@ -275,8 +275,8 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 		dh->dccph_checksum = dccp_v6_csum_finish(skb,
 							 &ireq6->loc_addr,
 							 &ireq6->rmt_addr);
-		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		err = ip6_xmit(sk, skb, &fl, opt);
+		ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
+		err = ip6_xmit(sk, skb, &fl6, opt);
 		err = net_xmit_eval(err);
 	}
 
@@ -298,7 +298,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 {
 	struct ipv6hdr *rxip6h;
 	struct sk_buff *skb;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct net *net = dev_net(skb_dst(rxskb)->dev);
 	struct sock *ctl_sk = net->dccp.v6_ctl_sk;
 	struct dst_entry *dst;
@@ -317,21 +317,21 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	dccp_hdr(skb)->dccph_checksum = dccp_v6_csum_finish(skb, &rxip6h->saddr,
 							    &rxip6h->daddr);
 
-	memset(&fl, 0, sizeof(fl));
-	ipv6_addr_copy(&fl.fl6_dst, &rxip6h->saddr);
-	ipv6_addr_copy(&fl.fl6_src, &rxip6h->daddr);
+	memset(&fl6, 0, sizeof(fl6));
+	ipv6_addr_copy(&fl6.daddr, &rxip6h->saddr);
+	ipv6_addr_copy(&fl6.saddr, &rxip6h->daddr);
 
-	fl.flowi_proto = IPPROTO_DCCP;
-	fl.flowi_oif = inet6_iif(rxskb);
-	fl.fl6_dport = dccp_hdr(skb)->dccph_dport;
-	fl.fl6_sport = dccp_hdr(skb)->dccph_sport;
-	security_skb_classify_flow(rxskb, &fl);
+	fl6.flowi6_proto = IPPROTO_DCCP;
+	fl6.flowi6_oif = inet6_iif(rxskb);
+	fl6.uli.ports.dport = dccp_hdr(skb)->dccph_dport;
+	fl6.uli.ports.sport = dccp_hdr(skb)->dccph_sport;
+	security_skb_classify_flow(rxskb, flowi6_to_flowi(&fl6));
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
-	dst = ip6_dst_lookup_flow(ctl_sk, &fl, NULL, false);
+	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(skb, dst);
-		ip6_xmit(ctl_sk, skb, &fl, NULL);
+		ip6_xmit(ctl_sk, skb, &fl6, NULL);
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
 		return;
@@ -527,19 +527,19 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 	if (dst == NULL) {
 		struct in6_addr *final_p, final;
-		struct flowi fl;
-
-		memset(&fl, 0, sizeof(fl));
-		fl.flowi_proto = IPPROTO_DCCP;
-		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		final_p = fl6_update_dst(&fl, opt, &final);
-		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
-		fl.flowi_oif = sk->sk_bound_dev_if;
-		fl.fl6_dport = inet_rsk(req)->rmt_port;
-		fl.fl6_sport = inet_rsk(req)->loc_port;
-		security_sk_classify_flow(sk, &fl);
-
-		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+		struct flowi6 fl6;
+
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_proto = IPPROTO_DCCP;
+		ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
+		final_p = fl6_update_dst(&fl6, opt, &final);
+		ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
+		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
+		fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
+
+		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 		if (IS_ERR(dst))
 			goto out;
 	}
@@ -859,7 +859,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct in6_addr *saddr = NULL, *final_p, final;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int addr_type;
 	int err;
@@ -872,14 +872,14 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 
 	if (np->sndflow) {
-		fl.fl6_flowlabel = usin->sin6_flowinfo & IPV6_FLOWINFO_MASK;
-		IP6_ECN_flow_init(fl.fl6_flowlabel);
-		if (fl.fl6_flowlabel & IPV6_FLOWLABEL_MASK) {
+		fl6.flowlabel = usin->sin6_flowinfo & IPV6_FLOWINFO_MASK;
+		IP6_ECN_flow_init(fl6.flowlabel);
+		if (fl6.flowlabel & IPV6_FLOWLABEL_MASK) {
 			struct ip6_flowlabel *flowlabel;
-			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
@@ -916,7 +916,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	}
 
 	ipv6_addr_copy(&np->daddr, &usin->sin6_addr);
-	np->flow_label = fl.fl6_flowlabel;
+	np->flow_label = fl6.flowlabel;
 
 	/*
 	 * DCCP over IPv4
@@ -953,24 +953,24 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (!ipv6_addr_any(&np->rcv_saddr))
 		saddr = &np->rcv_saddr;
 
-	fl.flowi_proto = IPPROTO_DCCP;
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-	ipv6_addr_copy(&fl.fl6_src, saddr ? saddr : &np->saddr);
-	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.fl6_dport = usin->sin6_port;
-	fl.fl6_sport = inet->inet_sport;
-	security_sk_classify_flow(sk, &fl);
+	fl6.flowi6_proto = IPPROTO_DCCP;
+	ipv6_addr_copy(&fl6.daddr, &np->daddr);
+	ipv6_addr_copy(&fl6.saddr, saddr ? saddr : &np->saddr);
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.uli.ports.dport = usin->sin6_port;
+	fl6.uli.ports.sport = inet->inet_sport;
+	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	final_p = fl6_update_dst(&fl, np->opt, &final);
+	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
-	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto failure;
 	}
 
 	if (saddr == NULL) {
-		saddr = &fl.fl6_src;
+		saddr = &fl6.saddr;
 		ipv6_addr_copy(&np->rcv_saddr, saddr);
 	}
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 923febe..689eea6 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -652,22 +652,22 @@ int inet6_sk_rebuild_header(struct sock *sk)
 	if (dst == NULL) {
 		struct inet_sock *inet = inet_sk(sk);
 		struct in6_addr *final_p, final;
-		struct flowi fl;
-
-		memset(&fl, 0, sizeof(fl));
-		fl.flowi_proto = sk->sk_protocol;
-		ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-		fl.fl6_flowlabel = np->flow_label;
-		fl.flowi_oif = sk->sk_bound_dev_if;
-		fl.flowi_mark = sk->sk_mark;
-		fl.fl6_dport = inet->inet_dport;
-		fl.fl6_sport = inet->inet_sport;
-		security_sk_classify_flow(sk, &fl);
-
-		final_p = fl6_update_dst(&fl, np->opt, &final);
-
-		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+		struct flowi6 fl6;
+
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_proto = sk->sk_protocol;
+		ipv6_addr_copy(&fl6.daddr, &np->daddr);
+		ipv6_addr_copy(&fl6.saddr, &np->saddr);
+		fl6.flowlabel = np->flow_label;
+		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_mark = sk->sk_mark;
+		fl6.uli.ports.dport = inet->inet_dport;
+		fl6.uli.ports.sport = inet->inet_sport;
+		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
+
+		final_p = fl6_update_dst(&fl6, np->opt, &final);
+
+		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 		if (IS_ERR(dst)) {
 			sk->sk_route_caps = 0;
 			sk->sk_err_soft = -PTR_ERR(dst);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 07e03e6..04ae676 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -40,7 +40,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct ipv6_pinfo      	*np = inet6_sk(sk);
 	struct in6_addr		*daddr, *final_p, final;
 	struct dst_entry	*dst;
-	struct flowi		fl;
+	struct flowi6		fl6;
 	struct ip6_flowlabel	*flowlabel = NULL;
 	struct ipv6_txoptions   *opt;
 	int			addr_type;
@@ -59,11 +59,11 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 	if (np->sndflow) {
-		fl.fl6_flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-		if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
-			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+		fl6.flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
+		if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
+			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
@@ -137,7 +137,7 @@ ipv4_connected:
 	}
 
 	ipv6_addr_copy(&np->daddr, daddr);
-	np->flow_label = fl.fl6_flowlabel;
+	np->flow_label = fl6.flowlabel;
 
 	inet->inet_dport = usin->sin6_port;
 
@@ -146,23 +146,23 @@ ipv4_connected:
 	 *	destination cache for it.
 	 */
 
-	fl.flowi_proto = sk->sk_protocol;
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.flowi_mark = sk->sk_mark;
-	fl.fl6_dport = inet->inet_dport;
-	fl.fl6_sport = inet->inet_sport;
+	fl6.flowi6_proto = sk->sk_protocol;
+	ipv6_addr_copy(&fl6.daddr, &np->daddr);
+	ipv6_addr_copy(&fl6.saddr, &np->saddr);
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.flowi6_mark = sk->sk_mark;
+	fl6.uli.ports.dport = inet->inet_dport;
+	fl6.uli.ports.sport = inet->inet_sport;
 
-	if (!fl.flowi_oif && (addr_type&IPV6_ADDR_MULTICAST))
-		fl.flowi_oif = np->mcast_oif;
+	if (!fl6.flowi6_oif && (addr_type&IPV6_ADDR_MULTICAST))
+		fl6.flowi6_oif = np->mcast_oif;
 
-	security_sk_classify_flow(sk, &fl);
+	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 	opt = flowlabel ? flowlabel->opt : np->opt;
-	final_p = fl6_update_dst(&fl, opt, &final);
+	final_p = fl6_update_dst(&fl6, opt, &final);
 
-	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
 	err = 0;
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
@@ -172,20 +172,20 @@ ipv4_connected:
 	/* source address lookup done in ip6_dst_lookup */
 
 	if (ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&np->saddr, &fl.fl6_src);
+		ipv6_addr_copy(&np->saddr, &fl6.saddr);
 
 	if (ipv6_addr_any(&np->rcv_saddr)) {
-		ipv6_addr_copy(&np->rcv_saddr, &fl.fl6_src);
+		ipv6_addr_copy(&np->rcv_saddr, &fl6.saddr);
 		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 		if (sk->sk_prot->rehash)
 			sk->sk_prot->rehash(sk);
 	}
 
 	ip6_dst_store(sk, dst,
-		      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
+		      ipv6_addr_equal(&fl6.daddr, &np->daddr) ?
 		      &np->daddr : NULL,
 #ifdef CONFIG_IPV6_SUBTREES
-		      ipv6_addr_equal(&fl.fl6_src, &np->saddr) ?
+		      ipv6_addr_equal(&fl6.saddr, &np->saddr) ?
 		      &np->saddr :
 #endif
 		      NULL);
@@ -231,7 +231,7 @@ void ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 		kfree_skb(skb);
 }
 
-void ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info)
+void ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sock_exterr_skb *serr;
@@ -250,7 +250,7 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info)
 	skb_put(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	iph = ipv6_hdr(skb);
-	ipv6_addr_copy(&iph->daddr, &fl->fl6_dst);
+	ipv6_addr_copy(&iph->daddr, &fl6->daddr);
 
 	serr = SKB_EXT_ERR(skb);
 	serr->ee.ee_errno = err;
@@ -261,7 +261,7 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info)
 	serr->ee.ee_info = info;
 	serr->ee.ee_data = 0;
 	serr->addr_offset = (u8 *)&iph->daddr - skb_network_header(skb);
-	serr->port = fl->fl6_dport;
+	serr->port = fl6->uli.ports.dport;
 
 	__skb_pull(skb, skb_tail_pointer(skb) - skb->data);
 	skb_reset_transport_header(skb);
@@ -270,7 +270,7 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi *fl, u32 info)
 		kfree_skb(skb);
 }
 
-void ipv6_local_rxpmtu(struct sock *sk, struct flowi *fl, u32 mtu)
+void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *iph;
@@ -287,7 +287,7 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi *fl, u32 mtu)
 	skb_put(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	iph = ipv6_hdr(skb);
-	ipv6_addr_copy(&iph->daddr, &fl->fl6_dst);
+	ipv6_addr_copy(&iph->daddr, &fl6->daddr);
 
 	mtu_info = IP6CBMTU(skb);
 	if (!mtu_info) {
@@ -299,7 +299,7 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi *fl, u32 mtu)
 	mtu_info->ip6m_addr.sin6_family = AF_INET6;
 	mtu_info->ip6m_addr.sin6_port = 0;
 	mtu_info->ip6m_addr.sin6_flowinfo = 0;
-	mtu_info->ip6m_addr.sin6_scope_id = fl->flowi_oif;
+	mtu_info->ip6m_addr.sin6_scope_id = fl6->flowi6_oif;
 	ipv6_addr_copy(&mtu_info->ip6m_addr.sin6_addr, &ipv6_hdr(skb)->daddr);
 
 	__skb_pull(skb, skb_tail_pointer(skb) - skb->data);
@@ -593,7 +593,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 }
 
 int datagram_send_ctl(struct net *net,
-		      struct msghdr *msg, struct flowi *fl,
+		      struct msghdr *msg, struct flowi6 *fl6,
 		      struct ipv6_txoptions *opt,
 		      int *hlimit, int *tclass, int *dontfrag)
 {
@@ -629,16 +629,17 @@ int datagram_send_ctl(struct net *net,
 			src_info = (struct in6_pktinfo *)CMSG_DATA(cmsg);
 
 			if (src_info->ipi6_ifindex) {
-				if (fl->flowi_oif && src_info->ipi6_ifindex != fl->flowi_oif)
+				if (fl6->flowi6_oif &&
+				    src_info->ipi6_ifindex != fl6->flowi6_oif)
 					return -EINVAL;
-				fl->flowi_oif = src_info->ipi6_ifindex;
+				fl6->flowi6_oif = src_info->ipi6_ifindex;
 			}
 
 			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
 
 			rcu_read_lock();
-			if (fl->flowi_oif) {
-				dev = dev_get_by_index_rcu(net, fl->flowi_oif);
+			if (fl6->flowi6_oif) {
+				dev = dev_get_by_index_rcu(net, fl6->flowi6_oif);
 				if (!dev) {
 					rcu_read_unlock();
 					return -ENODEV;
@@ -654,7 +655,7 @@ int datagram_send_ctl(struct net *net,
 						   strict ? dev : NULL, 0))
 					err = -EINVAL;
 				else
-					ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
+					ipv6_addr_copy(&fl6->saddr, &src_info->ipi6_addr);
 			}
 
 			rcu_read_unlock();
@@ -671,13 +672,13 @@ int datagram_send_ctl(struct net *net,
 				goto exit_f;
 			}
 
-			if (fl->fl6_flowlabel&IPV6_FLOWINFO_MASK) {
-				if ((fl->fl6_flowlabel^*(__be32 *)CMSG_DATA(cmsg))&~IPV6_FLOWINFO_MASK) {
+			if (fl6->flowlabel&IPV6_FLOWINFO_MASK) {
+				if ((fl6->flowlabel^*(__be32 *)CMSG_DATA(cmsg))&~IPV6_FLOWINFO_MASK) {
 					err = -EINVAL;
 					goto exit_f;
 				}
 			}
-			fl->fl6_flowlabel = IPV6_FLOWINFO_MASK & *(__be32 *)CMSG_DATA(cmsg);
+			fl6->flowlabel = IPV6_FLOWINFO_MASK & *(__be32 *)CMSG_DATA(cmsg);
 			break;
 
 		case IPV6_2292HOPOPTS:
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 262f105..79a485e 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -876,22 +876,22 @@ struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
  * fl6_update_dst - update flowi destination address with info given
  *                  by srcrt option, if any.
  *
- * @fl: flowi for which fl6_dst is to be updated
+ * @fl6: flowi6 for which daddr is to be updated
  * @opt: struct ipv6_txoptions in which to look for srcrt opt
- * @orig: copy of original fl6_dst address if modified
+ * @orig: copy of original daddr address if modified
  *
  * Returns NULL if no txoptions or no srcrt, otherwise returns orig
- * and initial value of fl->fl6_dst set in orig
+ * and initial value of fl6->daddr set in orig
  */
-struct in6_addr *fl6_update_dst(struct flowi *fl,
+struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 				const struct ipv6_txoptions *opt,
 				struct in6_addr *orig)
 {
 	if (!opt || !opt->srcrt)
 		return NULL;
 
-	ipv6_addr_copy(orig, &fl->fl6_dst);
-	ipv6_addr_copy(&fl->fl6_dst, ((struct rt0_hdr *)opt->srcrt)->addr);
+	ipv6_addr_copy(orig, &fl6->daddr);
+	ipv6_addr_copy(&fl6->daddr, ((struct rt0_hdr *)opt->srcrt)->addr);
 	return orig;
 }
 
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index d829874..34d244d 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -29,7 +29,7 @@ struct fib6_rule
 	u8			tclass;
 };
 
-struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
+struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
 	struct fib_lookup_arg arg = {
@@ -37,7 +37,8 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 		.flags = FIB_LOOKUP_NOREF,
 	};
 
-	fib_rules_lookup(net->ipv6.fib6_rules_ops, fl, flags, &arg);
+	fib_rules_lookup(net->ipv6.fib6_rules_ops,
+			 flowi6_to_flowi(fl6), flags, &arg);
 
 	if (arg.result)
 		return arg.result;
@@ -49,6 +50,7 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			    int flags, struct fib_lookup_arg *arg)
 {
+	struct flowi6 *flp6 = &flp->u.ip6;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 	struct net *net = rule->fr_net;
@@ -71,7 +73,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 
 	table = fib6_get_table(net, rule->table);
 	if (table)
-		rt = lookup(net, table, flp, flags);
+		rt = lookup(net, table, flp6, flags);
 
 	if (rt != net->ipv6.ip6_null_entry) {
 		struct fib6_rule *r = (struct fib6_rule *)rule;
@@ -86,14 +88,14 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 
 			if (ipv6_dev_get_saddr(net,
 					       ip6_dst_idev(&rt->dst)->dev,
-					       &flp->fl6_dst,
+					       &flp6->daddr,
 					       rt6_flags2srcprefs(flags),
 					       &saddr))
 				goto again;
 			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
 					       r->src.plen))
 				goto again;
-			ipv6_addr_copy(&flp->fl6_src, &saddr);
+			ipv6_addr_copy(&flp6->saddr, &saddr);
 		}
 		goto out;
 	}
@@ -113,9 +115,10 @@ out:
 static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
 	struct fib6_rule *r = (struct fib6_rule *) rule;
+	struct flowi6 *fl6 = &fl->u.ip6;
 
 	if (r->dst.plen &&
-	    !ipv6_prefix_equal(&fl->fl6_dst, &r->dst.addr, r->dst.plen))
+	    !ipv6_prefix_equal(&fl6->daddr, &r->dst.addr, r->dst.plen))
 		return 0;
 
 	/*
@@ -125,14 +128,14 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 	 */
 	if (r->src.plen) {
 		if (flags & RT6_LOOKUP_F_HAS_SADDR) {
-			if (!ipv6_prefix_equal(&fl->fl6_src, &r->src.addr,
+			if (!ipv6_prefix_equal(&fl6->saddr, &r->src.addr,
 					       r->src.plen))
 				return 0;
 		} else if (!(r->common.flags & FIB_RULE_FIND_SADDR))
 			return 0;
 	}
 
-	if (r->tclass && r->tclass != ((ntohl(fl->fl6_flowlabel) >> 20) & 0xff))
+	if (r->tclass && r->tclass != ((ntohl(fl6->flowlabel) >> 20) & 0xff))
 		return 0;
 
 	return 1;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 52ff7aa..f7b9041 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -158,7 +158,7 @@ static int is_ineligible(struct sk_buff *skb)
  * Check the ICMP output rate limit
  */
 static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
-				      struct flowi *fl)
+				      struct flowi6 *fl6)
 {
 	struct dst_entry *dst;
 	struct net *net = sock_net(sk);
@@ -177,7 +177,7 @@ static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
 	 * XXX: perhaps the expire for routing entries cloned by
 	 * this lookup should be more aggressive (not longer than timeout).
 	 */
-	dst = ip6_route_output(net, sk, fl);
+	dst = ip6_route_output(net, sk, fl6);
 	if (dst->error) {
 		IP6_INC_STATS(net, ip6_dst_idev(dst),
 			      IPSTATS_MIB_OUTNOROUTES);
@@ -217,7 +217,7 @@ static __inline__ int opt_unrec(struct sk_buff *skb, __u32 offset)
 	return (*op & 0xC0) == 0x80;
 }
 
-static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct icmp6hdr *thdr, int len)
+static int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6, struct icmp6hdr *thdr, int len)
 {
 	struct sk_buff *skb;
 	struct icmp6hdr *icmp6h;
@@ -233,9 +233,9 @@ static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct
 	if (skb_queue_len(&sk->sk_write_queue) == 1) {
 		skb->csum = csum_partial(icmp6h,
 					sizeof(struct icmp6hdr), skb->csum);
-		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl->fl6_src,
-						      &fl->fl6_dst,
-						      len, fl->flowi_proto,
+		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl6->saddr,
+						      &fl6->daddr,
+						      len, fl6->flowi6_proto,
 						      skb->csum);
 	} else {
 		__wsum tmp_csum = 0;
@@ -246,9 +246,9 @@ static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct
 
 		tmp_csum = csum_partial(icmp6h,
 					sizeof(struct icmp6hdr), tmp_csum);
-		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl->fl6_src,
-						      &fl->fl6_dst,
-						      len, fl->flowi_proto,
+		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl6->saddr,
+						      &fl6->daddr,
+						      len, fl6->flowi6_proto,
 						      tmp_csum);
 	}
 	ip6_push_pending_frames(sk);
@@ -301,13 +301,13 @@ static inline void mip6_addr_swap(struct sk_buff *skb) {}
 #endif
 
 static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *skb,
-					     struct sock *sk, struct flowi *fl)
+					     struct sock *sk, struct flowi6 *fl6)
 {
 	struct dst_entry *dst, *dst2;
-	struct flowi fl2;
+	struct flowi6 fl2;
 	int err;
 
-	err = ip6_dst_lookup(sk, &dst, fl);
+	err = ip6_dst_lookup(sk, &dst, fl6);
 	if (err)
 		return ERR_PTR(err);
 
@@ -324,7 +324,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *sk
 	/* No need to clone since we're just using its address. */
 	dst2 = dst;
 
-	dst = xfrm_lookup(net, dst, fl, sk, 0);
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(fl6), sk, 0);
 	if (!IS_ERR(dst)) {
 		if (dst != dst2)
 			return dst;
@@ -335,7 +335,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *sk
 			return dst;
 	}
 
-	err = xfrm_decode_session_reverse(skb, &fl2, AF_INET6);
+	err = xfrm_decode_session_reverse(skb, flowi6_to_flowi(&fl2), AF_INET6);
 	if (err)
 		goto relookup_failed;
 
@@ -343,7 +343,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *sk
 	if (err)
 		goto relookup_failed;
 
-	dst2 = xfrm_lookup(net, dst2, &fl2, sk, XFRM_LOOKUP_ICMP);
+	dst2 = xfrm_lookup(net, dst2, flowi6_to_flowi(&fl2), sk, XFRM_LOOKUP_ICMP);
 	if (!IS_ERR(dst2)) {
 		dst_release(dst);
 		dst = dst2;
@@ -375,7 +375,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	struct in6_addr *saddr = NULL;
 	struct dst_entry *dst;
 	struct icmp6hdr tmp_hdr;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct icmpv6_msg msg;
 	int iif = 0;
 	int addr_type = 0;
@@ -442,22 +442,22 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 
 	mip6_addr_swap(skb);
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = IPPROTO_ICMPV6;
-	ipv6_addr_copy(&fl.fl6_dst, &hdr->saddr);
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_ICMPV6;
+	ipv6_addr_copy(&fl6.daddr, &hdr->saddr);
 	if (saddr)
-		ipv6_addr_copy(&fl.fl6_src, saddr);
-	fl.flowi_oif = iif;
-	fl.fl6_icmp_type = type;
-	fl.fl6_icmp_code = code;
-	security_skb_classify_flow(skb, &fl);
+		ipv6_addr_copy(&fl6.saddr, saddr);
+	fl6.flowi6_oif = iif;
+	fl6.uli.icmpt.type = type;
+	fl6.uli.icmpt.code = code;
+	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
 	if (sk == NULL)
 		return;
 	np = inet6_sk(sk);
 
-	if (!icmpv6_xrlim_allow(sk, type, &fl))
+	if (!icmpv6_xrlim_allow(sk, type, &fl6))
 		goto out;
 
 	tmp_hdr.icmp6_type = type;
@@ -465,14 +465,14 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	tmp_hdr.icmp6_cksum = 0;
 	tmp_hdr.icmp6_pointer = htonl(info);
 
-	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-		fl.flowi_oif = np->mcast_oif;
+	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
+		fl6.flowi6_oif = np->mcast_oif;
 
-	dst = icmpv6_route_lookup(net, skb, sk, &fl);
+	dst = icmpv6_route_lookup(net, skb, sk, &fl6);
 	if (IS_ERR(dst))
 		goto out;
 
-	if (ipv6_addr_is_multicast(&fl.fl6_dst))
+	if (ipv6_addr_is_multicast(&fl6.daddr))
 		hlimit = np->mcast_hops;
 	else
 		hlimit = np->hop_limit;
@@ -495,14 +495,14 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
 			      len + sizeof(struct icmp6hdr),
 			      sizeof(struct icmp6hdr), hlimit,
-			      np->tclass, NULL, &fl, (struct rt6_info*)dst,
+			      np->tclass, NULL, &fl6, (struct rt6_info*)dst,
 			      MSG_DONTWAIT, np->dontfrag);
 	if (err) {
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
-	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + sizeof(struct icmp6hdr));
+	err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr, len + sizeof(struct icmp6hdr));
 
 out_put:
 	if (likely(idev != NULL))
@@ -524,7 +524,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	struct in6_addr *saddr = NULL;
 	struct icmp6hdr *icmph = icmp6_hdr(skb);
 	struct icmp6hdr tmp_hdr;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct icmpv6_msg msg;
 	struct dst_entry *dst;
 	int err = 0;
@@ -538,31 +538,31 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
 	tmp_hdr.icmp6_type = ICMPV6_ECHO_REPLY;
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = IPPROTO_ICMPV6;
-	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_ICMPV6;
+	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->saddr);
 	if (saddr)
-		ipv6_addr_copy(&fl.fl6_src, saddr);
-	fl.flowi_oif = skb->dev->ifindex;
-	fl.fl6_icmp_type = ICMPV6_ECHO_REPLY;
-	security_skb_classify_flow(skb, &fl);
+		ipv6_addr_copy(&fl6.saddr, saddr);
+	fl6.flowi6_oif = skb->dev->ifindex;
+	fl6.uli.icmpt.type = ICMPV6_ECHO_REPLY;
+	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
 	if (sk == NULL)
 		return;
 	np = inet6_sk(sk);
 
-	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-		fl.flowi_oif = np->mcast_oif;
+	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
+		fl6.flowi6_oif = np->mcast_oif;
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
+	err = ip6_dst_lookup(sk, &dst, &fl6);
 	if (err)
 		goto out;
-	dst = xfrm_lookup(net, dst, &fl, sk, 0);
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), sk, 0);
 	if (IS_ERR(dst))
 		goto out;
 
-	if (ipv6_addr_is_multicast(&fl.fl6_dst))
+	if (ipv6_addr_is_multicast(&fl6.daddr))
 		hlimit = np->mcast_hops;
 	else
 		hlimit = np->hop_limit;
@@ -576,7 +576,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	msg.type = ICMPV6_ECHO_REPLY;
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
-				sizeof(struct icmp6hdr), hlimit, np->tclass, NULL, &fl,
+				sizeof(struct icmp6hdr), hlimit, np->tclass, NULL, &fl6,
 				(struct rt6_info*)dst, MSG_DONTWAIT,
 				np->dontfrag);
 
@@ -585,7 +585,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
-	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, skb->len + sizeof(struct icmp6hdr));
+	err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr, skb->len + sizeof(struct icmp6hdr));
 
 out_put:
 	if (likely(idev != NULL))
@@ -784,20 +784,20 @@ drop_no_count:
 	return 0;
 }
 
-void icmpv6_flow_init(struct sock *sk, struct flowi *fl,
+void icmpv6_flow_init(struct sock *sk, struct flowi6 *fl6,
 		      u8 type,
 		      const struct in6_addr *saddr,
 		      const struct in6_addr *daddr,
 		      int oif)
 {
-	memset(fl, 0, sizeof(*fl));
-	ipv6_addr_copy(&fl->fl6_src, saddr);
-	ipv6_addr_copy(&fl->fl6_dst, daddr);
-	fl->flowi_proto	 	= IPPROTO_ICMPV6;
-	fl->fl6_icmp_type	= type;
-	fl->fl6_icmp_code	= 0;
-	fl->flowi_oif		= oif;
-	security_sk_classify_flow(sk, fl);
+	memset(fl6, 0, sizeof(*fl6));
+	ipv6_addr_copy(&fl6->saddr, saddr);
+	ipv6_addr_copy(&fl6->daddr, daddr);
+	fl6->flowi6_proto 	= IPPROTO_ICMPV6;
+	fl6->uli.icmpt.type	= type;
+	fl6->uli.icmpt.code	= 0;
+	fl6->flowi6_oif		= oif;
+	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 }
 
 /*
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 1b06a24..27d6691 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -61,20 +61,20 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *final_p, final;
 	struct dst_entry *dst;
-	struct flowi fl;
-
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
-	final_p = fl6_update_dst(&fl, np->opt, &final);
-	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
-	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.flowi_mark = sk->sk_mark;
-	fl.fl6_dport = inet_rsk(req)->rmt_port;
-	fl.fl6_sport = inet_rsk(req)->loc_port;
-	security_req_classify_flow(req, &fl);
-
-	dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+	struct flowi6 fl6;
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_TCP;
+	ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
+	final_p = fl6_update_dst(&fl6, np->opt, &final);
+	ipv6_addr_copy(&fl6.saddr, &treq->loc_addr);
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.flowi6_mark = sk->sk_mark;
+	fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
+	fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
+
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 	if (IS_ERR(dst))
 		return NULL;
 
@@ -208,28 +208,28 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 	struct in6_addr *final_p, final;
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = sk->sk_protocol;
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.fl6_flowlabel = np->flow_label;
-	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
-	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.flowi_mark = sk->sk_mark;
-	fl.fl6_sport = inet->inet_sport;
-	fl.fl6_dport = inet->inet_dport;
-	security_sk_classify_flow(sk, &fl);
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = sk->sk_protocol;
+	ipv6_addr_copy(&fl6.daddr, &np->daddr);
+	ipv6_addr_copy(&fl6.saddr, &np->saddr);
+	fl6.flowlabel = np->flow_label;
+	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.flowi6_mark = sk->sk_mark;
+	fl6.uli.ports.sport = inet->inet_sport;
+	fl6.uli.ports.dport = inet->inet_dport;
+	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	final_p = fl6_update_dst(&fl, np->opt, &final);
+	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
 	dst = __inet6_csk_dst_check(sk, np->dst_cookie);
 
 	if (dst == NULL) {
-		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 
 		if (IS_ERR(dst)) {
 			sk->sk_err_soft = -PTR_ERR(dst);
@@ -244,9 +244,9 @@ int inet6_csk_xmit(struct sk_buff *skb)
 	skb_dst_set(skb, dst_clone(dst));
 
 	/* Restore final destination back after routing done */
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+	ipv6_addr_copy(&fl6.daddr, &np->daddr);
 
-	return ip6_xmit(sk, skb, &fl, np->opt);
+	return ip6_xmit(sk, skb, &fl6, np->opt);
 }
 
 EXPORT_SYMBOL_GPL(inet6_csk_xmit);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index de38211..7548905 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -260,10 +260,10 @@ struct fib6_table *fib6_get_table(struct net *net, u32 id)
 	  return net->ipv6.fib6_main_tbl;
 }
 
-struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
+struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
-	return (struct dst_entry *) lookup(net, net->ipv6.fib6_main_tbl, fl, flags);
+	return (struct dst_entry *) lookup(net, net->ipv6.fib6_main_tbl, fl6, flags);
 }
 
 static void __net_init fib6_tables_init(struct net *net)
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index c8fa470..f3caf1b 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -342,7 +342,7 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 
 	if (olen > 0) {
 		struct msghdr msg;
-		struct flowi flowi;
+		struct flowi6 flowi6;
 		int junk;
 
 		err = -ENOMEM;
@@ -358,9 +358,9 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 
 		msg.msg_controllen = olen;
 		msg.msg_control = (void*)(fl->opt+1);
-		flowi.flowi_oif = 0;
+		memset(&flowi6, 0, sizeof(flowi6));
 
-		err = datagram_send_ctl(net, &msg, &flowi, fl->opt, &junk,
+		err = datagram_send_ctl(net, &msg, &flowi6, fl->opt, &junk,
 					&junk, &junk);
 		if (err)
 			goto done;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3d0f2ac..1820887 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -174,15 +174,15 @@ int ip6_output(struct sk_buff *skb)
  *	xmit an sk_buff (used by TCP, SCTP and DCCP)
  */
 
-int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
+int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	     struct ipv6_txoptions *opt)
 {
 	struct net *net = sock_net(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct in6_addr *first_hop = &fl->fl6_dst;
+	struct in6_addr *first_hop = &fl6->daddr;
 	struct dst_entry *dst = skb_dst(skb);
 	struct ipv6hdr *hdr;
-	u8  proto = fl->flowi_proto;
+	u8  proto = fl6->flowi6_proto;
 	int seg_len = skb->len;
 	int hlimit = -1;
 	int tclass = 0;
@@ -230,13 +230,13 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	*(__be32 *)hdr = htonl(0x60000000 | (tclass << 20)) | fl->fl6_flowlabel;
+	*(__be32 *)hdr = htonl(0x60000000 | (tclass << 20)) | fl6->flowlabel;
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
 	hdr->hop_limit = hlimit;
 
-	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
+	ipv6_addr_copy(&hdr->saddr, &fl6->saddr);
 	ipv6_addr_copy(&hdr->daddr, first_hop);
 
 	skb->priority = sk->sk_priority;
@@ -879,7 +879,7 @@ static inline int ip6_rt_check(struct rt6key *rt_key,
 
 static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 					  struct dst_entry *dst,
-					  struct flowi *fl)
+					  struct flowi6 *fl6)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct rt6_info *rt = (struct rt6_info *)dst;
@@ -904,11 +904,11 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 	 *    sockets.
 	 * 2. oif also should be the same.
 	 */
-	if (ip6_rt_check(&rt->rt6i_dst, &fl->fl6_dst, np->daddr_cache) ||
+	if (ip6_rt_check(&rt->rt6i_dst, &fl6->daddr, np->daddr_cache) ||
 #ifdef CONFIG_IPV6_SUBTREES
-	    ip6_rt_check(&rt->rt6i_src, &fl->fl6_src, np->saddr_cache) ||
+	    ip6_rt_check(&rt->rt6i_src, &fl6->saddr, np->saddr_cache) ||
 #endif
-	    (fl->flowi_oif && fl->flowi_oif != dst->dev->ifindex)) {
+	    (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex)) {
 		dst_release(dst);
 		dst = NULL;
 	}
@@ -918,22 +918,22 @@ out:
 }
 
 static int ip6_dst_lookup_tail(struct sock *sk,
-			       struct dst_entry **dst, struct flowi *fl)
+			       struct dst_entry **dst, struct flowi6 *fl6)
 {
 	int err;
 	struct net *net = sock_net(sk);
 
 	if (*dst == NULL)
-		*dst = ip6_route_output(net, sk, fl);
+		*dst = ip6_route_output(net, sk, fl6);
 
 	if ((err = (*dst)->error))
 		goto out_err_release;
 
-	if (ipv6_addr_any(&fl->fl6_src)) {
+	if (ipv6_addr_any(&fl6->saddr)) {
 		err = ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
-					 &fl->fl6_dst,
+					 &fl6->daddr,
 					 sk ? inet6_sk(sk)->srcprefs : 0,
-					 &fl->fl6_src);
+					 &fl6->saddr);
 		if (err)
 			goto out_err_release;
 	}
@@ -949,10 +949,10 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 */
 	if ((*dst)->neighbour && !((*dst)->neighbour->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
-		struct flowi fl_gw;
+		struct flowi6 fl_gw6;
 		int redirect;
 
-		ifp = ipv6_get_ifaddr(net, &fl->fl6_src,
+		ifp = ipv6_get_ifaddr(net, &fl6->saddr,
 				      (*dst)->dev, 1);
 
 		redirect = (ifp && ifp->flags & IFA_F_OPTIMISTIC);
@@ -965,9 +965,9 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			 * default router instead
 			 */
 			dst_release(*dst);
-			memcpy(&fl_gw, fl, sizeof(struct flowi));
-			memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
-			*dst = ip6_route_output(net, sk, &fl_gw);
+			memcpy(&fl_gw6, fl6, sizeof(struct flowi6));
+			memset(&fl_gw6.daddr, 0, sizeof(struct in6_addr));
+			*dst = ip6_route_output(net, sk, &fl_gw6);
 			if ((err = (*dst)->error))
 				goto out_err_release;
 		}
@@ -988,23 +988,23 @@ out_err_release:
  *	ip6_dst_lookup - perform route lookup on flow
  *	@sk: socket which provides route info
  *	@dst: pointer to dst_entry * for result
- *	@fl: flow to lookup
+ *	@fl6: flow to lookup
  *
  *	This function performs a route lookup on the given flow.
  *
  *	It returns zero on success, or a standard errno code on error.
  */
-int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi *fl)
+int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi6 *fl6)
 {
 	*dst = NULL;
-	return ip6_dst_lookup_tail(sk, dst, fl);
+	return ip6_dst_lookup_tail(sk, dst, fl6);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup);
 
 /**
  *	ip6_dst_lookup_flow - perform route lookup on flow with ipsec
  *	@sk: socket which provides route info
- *	@fl: flow to lookup
+ *	@fl6: flow to lookup
  *	@final_dst: final destination address for ipsec lookup
  *	@can_sleep: we are in a sleepable context
  *
@@ -1013,29 +1013,29 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup);
  *	It returns a valid dst pointer on success, or a pointer encoded
  *	error code.
  */
-struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
+struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 				      const struct in6_addr *final_dst,
 				      bool can_sleep)
 {
 	struct dst_entry *dst = NULL;
 	int err;
 
-	err = ip6_dst_lookup_tail(sk, &dst, fl);
+	err = ip6_dst_lookup_tail(sk, &dst, fl6);
 	if (err)
 		return ERR_PTR(err);
 	if (final_dst)
-		ipv6_addr_copy(&fl->fl6_dst, final_dst);
+		ipv6_addr_copy(&fl6->daddr, final_dst);
 	if (can_sleep)
-		fl->flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
+		fl6->flowi6_flags |= FLOWI_FLAG_CAN_SLEEP;
 
-	return xfrm_lookup(sock_net(sk), dst, fl, sk, 0);
+	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
 
 /**
  *	ip6_sk_dst_lookup_flow - perform socket cached route lookup on flow
  *	@sk: socket which provides the dst cache and route info
- *	@fl: flow to lookup
+ *	@fl6: flow to lookup
  *	@final_dst: final destination address for ipsec lookup
  *	@can_sleep: we are in a sleepable context
  *
@@ -1047,24 +1047,24 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
  *	It returns a valid dst pointer on success, or a pointer encoded
  *	error code.
  */
-struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
+struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 					 const struct in6_addr *final_dst,
 					 bool can_sleep)
 {
 	struct dst_entry *dst = sk_dst_check(sk, inet6_sk(sk)->dst_cookie);
 	int err;
 
-	dst = ip6_sk_dst_check(sk, dst, fl);
+	dst = ip6_sk_dst_check(sk, dst, fl6);
 
-	err = ip6_dst_lookup_tail(sk, &dst, fl);
+	err = ip6_dst_lookup_tail(sk, &dst, fl6);
 	if (err)
 		return ERR_PTR(err);
 	if (final_dst)
-		ipv6_addr_copy(&fl->fl6_dst, final_dst);
+		ipv6_addr_copy(&fl6->daddr, final_dst);
 	if (can_sleep)
-		fl->flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
+		fl6->flowi6_flags |= FLOWI_FLAG_CAN_SLEEP;
 
-	return xfrm_lookup(sock_net(sk), dst, fl, sk, 0);
+	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
@@ -1145,7 +1145,7 @@ static inline struct ipv6_rt_hdr *ip6_rthdr_dup(struct ipv6_rt_hdr *src,
 int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int offset, int len, int odd, struct sk_buff *skb),
 	void *from, int length, int transhdrlen,
-	int hlimit, int tclass, struct ipv6_txoptions *opt, struct flowi *fl,
+	int hlimit, int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
 	struct rt6_info *rt, unsigned int flags, int dontfrag)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1203,7 +1203,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		}
 		dst_hold(&rt->dst);
 		inet->cork.dst = &rt->dst;
-		inet->cork.fl = *fl;
+		inet->cork.fl.u.ip6 = *fl6;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
 		mtu = np->pmtudisc == IPV6_PMTUDISC_PROBE ?
@@ -1224,7 +1224,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		transhdrlen += exthdrlen;
 	} else {
 		rt = (struct rt6_info *)inet->cork.dst;
-		fl = &inet->cork.fl;
+		fl6 = &inet->cork.fl.u.ip6;
 		opt = np->cork.opt;
 		transhdrlen = 0;
 		exthdrlen = 0;
@@ -1239,7 +1239,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
 		if (inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
-			ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
+			ipv6_local_error(sk, EMSGSIZE, fl6, mtu-exthdrlen);
 			return -EMSGSIZE;
 		}
 	}
@@ -1271,7 +1271,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	if (length > mtu) {
 		int proto = sk->sk_protocol;
 		if (dontfrag && (proto == IPPROTO_UDP || proto == IPPROTO_RAW)){
-			ipv6_local_rxpmtu(sk, fl, mtu-exthdrlen);
+			ipv6_local_rxpmtu(sk, fl6, mtu-exthdrlen);
 			return -EMSGSIZE;
 		}
 
@@ -1516,8 +1516,8 @@ int ip6_push_pending_frames(struct sock *sk)
 	struct ipv6hdr *hdr;
 	struct ipv6_txoptions *opt = np->cork.opt;
 	struct rt6_info *rt = (struct rt6_info *)inet->cork.dst;
-	struct flowi *fl = &inet->cork.fl;
-	unsigned char proto = fl->flowi_proto;
+	struct flowi6 *fl6 = &inet->cork.fl.u.ip6;
+	unsigned char proto = fl6->flowi6_proto;
 	int err = 0;
 
 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
@@ -1542,7 +1542,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	if (np->pmtudisc < IPV6_PMTUDISC_DO)
 		skb->local_df = 1;
 
-	ipv6_addr_copy(final_dst, &fl->fl6_dst);
+	ipv6_addr_copy(final_dst, &fl6->daddr);
 	__skb_pull(skb, skb_network_header_len(skb));
 	if (opt && opt->opt_flen)
 		ipv6_push_frag_opts(skb, opt, &proto);
@@ -1553,12 +1553,12 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
-	*(__be32*)hdr = fl->fl6_flowlabel |
+	*(__be32*)hdr = fl6->flowlabel |
 		     htonl(0x60000000 | ((int)np->cork.tclass << 20));
 
 	hdr->hop_limit = np->cork.hop_limit;
 	hdr->nexthdr = proto;
-	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
+	ipv6_addr_copy(&hdr->saddr, &fl6->saddr);
 	ipv6_addr_copy(&hdr->daddr, final_dst);
 
 	skb->priority = sk->sk_priority;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index c3fc824..c1b1bd3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -884,7 +884,7 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 static int ip6_tnl_xmit2(struct sk_buff *skb,
 			 struct net_device *dev,
 			 __u8 dsfield,
-			 struct flowi *fl,
+			 struct flowi6 *fl6,
 			 int encap_limit,
 			 __u32 *pmtu)
 {
@@ -904,11 +904,11 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	if ((dst = ip6_tnl_dst_check(t)) != NULL)
 		dst_hold(dst);
 	else {
-		dst = ip6_route_output(net, NULL, fl);
+		dst = ip6_route_output(net, NULL, fl6);
 
 		if (dst->error)
 			goto tx_err_link_failure;
-		dst = xfrm_lookup(net, dst, fl, NULL, 0);
+		dst = xfrm_lookup(net, dst, flowi6_to_flowi(fl6), NULL, 0);
 		if (IS_ERR(dst)) {
 			err = PTR_ERR(dst);
 			dst = NULL;
@@ -963,7 +963,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 
 	skb->transport_header = skb->network_header;
 
-	proto = fl->flowi_proto;
+	proto = fl6->flowi6_proto;
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
 		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
@@ -971,13 +971,13 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-	*(__be32*)ipv6h = fl->fl6_flowlabel | htonl(0x60000000);
+	*(__be32*)ipv6h = fl6->flowlabel | htonl(0x60000000);
 	dsfield = INET_ECN_encapsulate(0, dsfield);
 	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
-	ipv6_addr_copy(&ipv6h->saddr, &fl->fl6_src);
-	ipv6_addr_copy(&ipv6h->daddr, &fl->fl6_dst);
+	ipv6_addr_copy(&ipv6h->saddr, &fl6->saddr);
+	ipv6_addr_copy(&ipv6h->daddr, &fl6->daddr);
 	nf_reset(skb);
 	pkt_len = skb->len;
 	err = ip6_local_out(skb);
@@ -1007,7 +1007,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct iphdr  *iph = ip_hdr(skb);
 	int encap_limit = -1;
-	struct flowi fl;
+	struct flowi6 fl6;
 	__u8 dsfield;
 	__u32 mtu;
 	int err;
@@ -1019,16 +1019,16 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
 
-	memcpy(&fl, &t->fl, sizeof (fl));
-	fl.flowi_proto = IPPROTO_IPIP;
+	memcpy(&fl6, &t->fl.u.ip6, sizeof (fl6));
+	fl6.flowi6_proto = IPPROTO_IPIP;
 
 	dsfield = ipv4_get_dsfield(iph);
 
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
-		fl.fl6_flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
+		fl6.flowlabel |= htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
 					  & IPV6_TCLASS_MASK;
 
-	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
+	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
 	if (err != 0) {
 		/* XXX: send ICMP error even if DF is not set. */
 		if (err == -EMSGSIZE)
@@ -1047,7 +1047,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	int encap_limit = -1;
 	__u16 offset;
-	struct flowi fl;
+	struct flowi6 fl6;
 	__u8 dsfield;
 	__u32 mtu;
 	int err;
@@ -1069,16 +1069,16 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
 
-	memcpy(&fl, &t->fl, sizeof (fl));
-	fl.flowi_proto = IPPROTO_IPV6;
+	memcpy(&fl6, &t->fl.u.ip6, sizeof (fl6));
+	fl6.flowi6_proto = IPPROTO_IPV6;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
-		fl.fl6_flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
+		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
-		fl.fl6_flowlabel |= (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
+		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
 
-	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
+	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
 	if (err != 0) {
 		if (err == -EMSGSIZE)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
@@ -1141,21 +1141,21 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 {
 	struct net_device *dev = t->dev;
 	struct ip6_tnl_parm *p = &t->parms;
-	struct flowi *fl = &t->fl;
+	struct flowi6 *fl6 = &t->fl.u.ip6;
 
 	memcpy(dev->dev_addr, &p->laddr, sizeof(struct in6_addr));
 	memcpy(dev->broadcast, &p->raddr, sizeof(struct in6_addr));
 
 	/* Set up flowi template */
-	ipv6_addr_copy(&fl->fl6_src, &p->laddr);
-	ipv6_addr_copy(&fl->fl6_dst, &p->raddr);
-	fl->flowi_oif = p->link;
-	fl->fl6_flowlabel = 0;
+	ipv6_addr_copy(&fl6->saddr, &p->laddr);
+	ipv6_addr_copy(&fl6->daddr, &p->raddr);
+	fl6->flowi6_oif = p->link;
+	fl6->flowlabel = 0;
 
 	if (!(p->flags&IP6_TNL_F_USE_ORIG_TCLASS))
-		fl->fl6_flowlabel |= IPV6_TCLASS_MASK & p->flowinfo;
+		fl6->flowlabel |= IPV6_TCLASS_MASK & p->flowinfo;
 	if (!(p->flags&IP6_TNL_F_USE_ORIG_FLOWLABEL))
-		fl->fl6_flowlabel |= IPV6_FLOWLABEL_MASK & p->flowinfo;
+		fl6->flowlabel |= IPV6_FLOWLABEL_MASK & p->flowinfo;
 
 	ip6_tnl_set_cap(t);
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 61a8be3..7ff0343 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -135,14 +135,15 @@ static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
 	return NULL;
 }
 
-static int ip6mr_fib_lookup(struct net *net, struct flowi *flp,
+static int ip6mr_fib_lookup(struct net *net, struct flowi6 *flp6,
 			    struct mr6_table **mrt)
 {
 	struct ip6mr_result res;
 	struct fib_lookup_arg arg = { .result = &res, };
 	int err;
 
-	err = fib_rules_lookup(net->ipv6.mr6_rules_ops, flp, 0, &arg);
+	err = fib_rules_lookup(net->ipv6.mr6_rules_ops,
+			       flowi6_to_flowi(flp6), 0, &arg);
 	if (err < 0)
 		return err;
 	*mrt = res.mrt;
@@ -270,7 +271,7 @@ static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
 	return net->ipv6.mrt6;
 }
 
-static int ip6mr_fib_lookup(struct net *net, struct flowi *flp,
+static int ip6mr_fib_lookup(struct net *net, struct flowi6 *flp6,
 			    struct mr6_table **mrt)
 {
 	*mrt = net->ipv6.mrt6;
@@ -617,9 +618,9 @@ static int pim6_rcv(struct sk_buff *skb)
 	struct net_device  *reg_dev = NULL;
 	struct net *net = dev_net(skb->dev);
 	struct mr6_table *mrt;
-	struct flowi fl = {
-		.flowi_iif	= skb->dev->ifindex,
-		.flowi_mark = skb->mark,
+	struct flowi6 fl6 = {
+		.flowi6_iif	= skb->dev->ifindex,
+		.flowi6_mark	= skb->mark,
 	};
 	int reg_vif_num;
 
@@ -644,7 +645,7 @@ static int pim6_rcv(struct sk_buff *skb)
 	    ntohs(encap->payload_len) + sizeof(*pim) > skb->len)
 		goto drop;
 
-	if (ip6mr_fib_lookup(net, &fl, &mrt) < 0)
+	if (ip6mr_fib_lookup(net, &fl6, &mrt) < 0)
 		goto drop;
 	reg_vif_num = mrt->mroute_reg_vif_num;
 
@@ -687,14 +688,14 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 {
 	struct net *net = dev_net(dev);
 	struct mr6_table *mrt;
-	struct flowi fl = {
-		.flowi_oif		= dev->ifindex,
-		.flowi_iif		= skb->skb_iif,
-		.flowi_mark	= skb->mark,
+	struct flowi6 fl6 = {
+		.flowi6_oif	= dev->ifindex,
+		.flowi6_iif	= skb->skb_iif,
+		.flowi6_mark	= skb->mark,
 	};
 	int err;
 
-	err = ip6mr_fib_lookup(net, &fl, &mrt);
+	err = ip6mr_fib_lookup(net, &fl6, &mrt);
 	if (err < 0)
 		return err;
 
@@ -1547,13 +1548,13 @@ int ip6mr_sk_done(struct sock *sk)
 struct sock *mroute6_socket(struct net *net, struct sk_buff *skb)
 {
 	struct mr6_table *mrt;
-	struct flowi fl = {
-		.flowi_iif	= skb->skb_iif,
-		.flowi_oif	= skb->dev->ifindex,
-		.flowi_mark= skb->mark,
+	struct flowi6 fl6 = {
+		.flowi6_iif	= skb->skb_iif,
+		.flowi6_oif	= skb->dev->ifindex,
+		.flowi6_mark	= skb->mark,
 	};
 
-	if (ip6mr_fib_lookup(net, &fl, &mrt) < 0)
+	if (ip6mr_fib_lookup(net, &fl6, &mrt) < 0)
 		return NULL;
 
 	return mrt->mroute6_sk;
@@ -1897,7 +1898,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 	struct mif_device *vif = &mrt->vif6_table[vifi];
 	struct net_device *dev;
 	struct dst_entry *dst;
-	struct flowi fl;
+	struct flowi6 fl6;
 
 	if (vif->dev == NULL)
 		goto out_free;
@@ -1915,12 +1916,12 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 
 	ipv6h = ipv6_hdr(skb);
 
-	fl = (struct flowi) {
-		.flowi_oif = vif->link,
-		.fl6_dst = ipv6h->daddr,
+	fl6 = (struct flowi6) {
+		.flowi6_oif = vif->link,
+		.daddr = ipv6h->daddr,
 	};
 
-	dst = ip6_route_output(net, NULL, &fl);
+	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst)
 		goto out_free;
 
@@ -2043,13 +2044,13 @@ int ip6_mr_input(struct sk_buff *skb)
 	struct mfc6_cache *cache;
 	struct net *net = dev_net(skb->dev);
 	struct mr6_table *mrt;
-	struct flowi fl = {
-		.flowi_iif	= skb->dev->ifindex,
-		.flowi_mark= skb->mark,
+	struct flowi6 fl6 = {
+		.flowi6_iif	= skb->dev->ifindex,
+		.flowi6_mark	= skb->mark,
 	};
 	int err;
 
-	err = ip6mr_fib_lookup(net, &fl, &mrt);
+	err = ip6mr_fib_lookup(net, &fl6, &mrt);
 	if (err < 0)
 		return err;
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 1448c50..9cb191e 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -444,12 +444,12 @@ sticky_done:
 	{
 		struct ipv6_txoptions *opt = NULL;
 		struct msghdr msg;
-		struct flowi fl;
+		struct flowi6 fl6;
 		int junk;
 
-		fl.fl6_flowlabel = 0;
-		fl.flowi_oif = sk->sk_bound_dev_if;
-		fl.flowi_mark = sk->sk_mark;
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_mark = sk->sk_mark;
 
 		if (optlen == 0)
 			goto update;
@@ -475,7 +475,7 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(net, &msg, &fl, opt, &junk, &junk,
+		retv = datagram_send_ctl(net, &msg, &fl6, opt, &junk, &junk,
 					 &junk);
 		if (retv)
 			goto done;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index f2c9b69..76b8937 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1396,7 +1396,7 @@ static void mld_sendpack(struct sk_buff *skb)
 	struct inet6_dev *idev;
 	struct net *net = dev_net(skb->dev);
 	int err;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 
 	rcu_read_lock();
@@ -1419,11 +1419,11 @@ static void mld_sendpack(struct sk_buff *skb)
 		goto err_out;
 	}
 
-	icmpv6_flow_init(net->ipv6.igmp_sk, &fl, ICMPV6_MLD2_REPORT,
+	icmpv6_flow_init(net->ipv6.igmp_sk, &fl6, ICMPV6_MLD2_REPORT,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 	err = 0;
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
@@ -1731,7 +1731,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	u8 ra[8] = { IPPROTO_ICMPV6, 0,
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 
 	if (type == ICMPV6_MGM_REDUCTION)
@@ -1791,11 +1791,11 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		goto err_out;
 	}
 
-	icmpv6_flow_init(sk, &fl, type,
+	icmpv6_flow_init(sk, &fl6, type,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto err_out;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index e1767ae..6a13735 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -208,14 +208,15 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 {
 	struct net *net = xs_net(x);
 	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
+	const struct flowi6 *fl6 = &fl->u.ip6;
 	struct ipv6_destopt_hao *hao = NULL;
 	struct xfrm_selector sel;
 	int offset;
 	struct timeval stamp;
 	int err = 0;
 
-	if (unlikely(fl->flowi_proto == IPPROTO_MH &&
-		     fl->fl6_mh_type <= IP6_MH_TYPE_MAX))
+	if (unlikely(fl6->flowi6_proto == IPPROTO_MH &&
+		     fl6->uli.mht.type <= IP6_MH_TYPE_MAX))
 		goto out;
 
 	if (likely(opt->dsthao)) {
@@ -240,14 +241,14 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	       sizeof(sel.saddr));
 	sel.prefixlen_s = 128;
 	sel.family = AF_INET6;
-	sel.proto = fl->flowi_proto;
-	sel.dport = xfrm_flowi_dport(fl, &fl->u.ip6.uli);
+	sel.proto = fl6->flowi6_proto;
+	sel.dport = xfrm_flowi_dport(fl, &fl6->uli);
 	if (sel.dport)
 		sel.dport_mask = htons(~0);
-	sel.sport = xfrm_flowi_sport(fl, &fl->u.ip6.uli);
+	sel.sport = xfrm_flowi_sport(fl, &fl6->uli);
 	if (sel.sport)
 		sel.sport_mask = htons(~0);
-	sel.ifindex = fl->flowi_oif;
+	sel.ifindex = fl6->flowi6_oif;
 
 	err = km_report(net, IPPROTO_DSTOPTS, &sel,
 			(hao ? (xfrm_address_t *)&hao->addr : NULL));
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9360d3b..0e49c9d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -511,7 +511,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 		    const struct in6_addr *saddr,
 		    struct icmp6hdr *icmp6h)
 {
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
@@ -521,7 +521,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 
 	type = icmp6h->icmp6_type;
 
-	icmpv6_flow_init(sk, &fl, type, saddr, daddr, dev->ifindex);
+	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
 
 	dst = icmp6_dst_alloc(dev, neigh, daddr);
 	if (!dst) {
@@ -529,7 +529,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 		return;
 	}
 
-	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 	if (IS_ERR(dst)) {
 		kfree_skb(skb);
 		return;
@@ -1515,7 +1515,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	struct rt6_info *rt;
 	struct dst_entry *dst;
 	struct inet6_dev *idev;
-	struct flowi fl;
+	struct flowi6 fl6;
 	u8 *opt;
 	int rd_len;
 	int err;
@@ -1535,14 +1535,14 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 		return;
 	}
 
-	icmpv6_flow_init(sk, &fl, NDISC_REDIRECT,
+	icmpv6_flow_init(sk, &fl6, NDISC_REDIRECT,
 			 &saddr_buf, &ipv6_hdr(skb)->saddr, dev->ifindex);
 
-	dst = ip6_route_output(net, NULL, &fl);
+	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst == NULL)
 		return;
 
-	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 	if (IS_ERR(dst))
 		return;
 
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index d282c62..39aaca2 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -15,14 +15,14 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct dst_entry *dst;
-	struct flowi fl = {
-		.flowi_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
-		.flowi_mark = skb->mark,
-		.fl6_dst = iph->daddr,
-		.fl6_src = iph->saddr,
+	struct flowi6 fl6 = {
+		.flowi6_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
+		.flowi6_mark = skb->mark,
+		.daddr = iph->daddr,
+		.saddr = iph->saddr,
 	};
 
-	dst = ip6_route_output(net, skb->sk, &fl);
+	dst = ip6_route_output(net, skb->sk, &fl6);
 	if (dst->error) {
 		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
@@ -37,9 +37,9 @@ int ip6_route_me_harder(struct sk_buff *skb)
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
-	    xfrm_decode_session(skb, &fl, AF_INET6) == 0) {
+	    xfrm_decode_session(skb, flowi6_to_flowi(&fl6), AF_INET6) == 0) {
 		skb_dst_set(skb, NULL);
-		dst = xfrm_lookup(net, dst, &fl, skb->sk, 0);
+		dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), skb->sk, 0);
 		if (IS_ERR(dst))
 			return -1;
 		skb_dst_set(skb, dst);
@@ -92,7 +92,7 @@ static int nf_ip6_reroute(struct sk_buff *skb,
 
 static int nf_ip6_route(struct dst_entry **dst, struct flowi *fl)
 {
-	*dst = ip6_route_output(&init_net, NULL, fl);
+	*dst = ip6_route_output(&init_net, NULL, &fl->u.ip6);
 	return (*dst)->error;
 }
 
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index d1e905b..df05511 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -47,7 +47,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	struct ipv6hdr *ip6h;
 	struct dst_entry *dst = NULL;
 	u8 proto;
-	struct flowi fl;
+	struct flowi6 fl6;
 
 	if ((!(ipv6_addr_type(&oip6h->saddr) & IPV6_ADDR_UNICAST)) ||
 	    (!(ipv6_addr_type(&oip6h->daddr) & IPV6_ADDR_UNICAST))) {
@@ -89,19 +89,19 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 		return;
 	}
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl.fl6_src, &oip6h->daddr);
-	ipv6_addr_copy(&fl.fl6_dst, &oip6h->saddr);
-	fl.fl6_sport = otcph.dest;
-	fl.fl6_dport = otcph.source;
-	security_skb_classify_flow(oldskb, &fl);
-	dst = ip6_route_output(net, NULL, &fl);
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_TCP;
+	ipv6_addr_copy(&fl6.saddr, &oip6h->daddr);
+	ipv6_addr_copy(&fl6.daddr, &oip6h->saddr);
+	fl6.uli.ports.sport = otcph.dest;
+	fl6.uli.ports.dport = otcph.source;
+	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
+	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst == NULL || dst->error) {
 		dst_release(dst);
 		return;
 	}
-	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 	if (IS_ERR(dst))
 		return;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d061465..259f1b2 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -524,7 +524,7 @@ csum_copy_err:
 	goto out;
 }
 
-static int rawv6_push_pending_frames(struct sock *sk, struct flowi *fl,
+static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 				     struct raw6_sock *rp)
 {
 	struct sk_buff *skb;
@@ -586,11 +586,10 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi *fl,
 	if (unlikely(csum))
 		tmp_csum = csum_sub(tmp_csum, csum_unfold(csum));
 
-	csum = csum_ipv6_magic(&fl->fl6_src,
-				   &fl->fl6_dst,
-				   total_len, fl->flowi_proto, tmp_csum);
+	csum = csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
+			       total_len, fl6->flowi6_proto, tmp_csum);
 
-	if (csum == 0 && fl->flowi_proto == IPPROTO_UDP)
+	if (csum == 0 && fl6->flowi6_proto == IPPROTO_UDP)
 		csum = CSUM_MANGLED_0;
 
 	if (skb_store_bits(skb, offset, &csum, 2))
@@ -603,7 +602,7 @@ out:
 }
 
 static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
-			struct flowi *fl, struct dst_entry **dstp,
+			struct flowi6 *fl6, struct dst_entry **dstp,
 			unsigned int flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -613,7 +612,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	struct rt6_info *rt = (struct rt6_info *)*dstp;
 
 	if (length > rt->dst.dev->mtu) {
-		ipv6_local_error(sk, EMSGSIZE, fl, rt->dst.dev->mtu);
+		ipv6_local_error(sk, EMSGSIZE, fl6, rt->dst.dev->mtu);
 		return -EMSGSIZE;
 	}
 	if (flags&MSG_PROBE)
@@ -662,7 +661,7 @@ error:
 	return err;
 }
 
-static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
+static int rawv6_probe_proto_opt(struct flowi6 *fl6, struct msghdr *msg)
 {
 	struct iovec *iov;
 	u8 __user *type = NULL;
@@ -679,7 +678,7 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 		if (!iov)
 			continue;
 
-		switch (fl->flowi_proto) {
+		switch (fl6->flowi6_proto) {
 		case IPPROTO_ICMPV6:
 			/* check if one-byte field is readable or not. */
 			if (iov->iov_base && iov->iov_len < 1)
@@ -694,8 +693,8 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 				code = iov->iov_base;
 
 			if (type && code) {
-				if (get_user(fl->fl6_icmp_type, type) ||
-				    get_user(fl->fl6_icmp_code, code))
+				if (get_user(fl6->uli.icmpt.type, type) ||
+				    get_user(fl6->uli.icmpt.code, code))
 					return -EFAULT;
 				probed = 1;
 			}
@@ -706,7 +705,7 @@ static int rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
 			/* check if type field is readable or not. */
 			if (iov->iov_len > 2 - len) {
 				u8 __user *p = iov->iov_base;
-				if (get_user(fl->fl6_mh_type, &p[2 - len]))
+				if (get_user(fl6->uli.mht.type, &p[2 - len]))
 					return -EFAULT;
 				probed = 1;
 			} else
@@ -735,7 +734,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct dst_entry *dst = NULL;
-	struct flowi fl;
+	struct flowi6 fl6;
 	int addr_len = msg->msg_namelen;
 	int hlimit = -1;
 	int tclass = -1;
@@ -756,9 +755,9 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	/*
 	 *	Get and verify the address.
 	 */
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 
-	fl.flowi_mark = sk->sk_mark;
+	fl6.flowi6_mark = sk->sk_mark;
 
 	if (sin6) {
 		if (addr_len < SIN6_LEN_RFC2133)
@@ -780,9 +779,9 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 		daddr = &sin6->sin6_addr;
 		if (np->sndflow) {
-			fl.fl6_flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-			if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+			fl6.flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
+			if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
+				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
 				daddr = &flowlabel->dst;
@@ -800,32 +799,32 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
 		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
-			fl.flowi_oif = sin6->sin6_scope_id;
+			fl6.flowi6_oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
 		proto = inet->inet_num;
 		daddr = &np->daddr;
-		fl.fl6_flowlabel = np->flow_label;
+		fl6.flowlabel = np->flow_label;
 	}
 
-	if (fl.flowi_oif == 0)
-		fl.flowi_oif = sk->sk_bound_dev_if;
+	if (fl6.flowi6_oif == 0)
+		fl6.flowi6_oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit,
+		err = datagram_send_ctl(sock_net(sk), msg, &fl6, opt, &hlimit,
 					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
 		}
-		if ((fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+		if ((fl6.flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
+			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 		}
@@ -838,31 +837,31 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
 
-	fl.flowi_proto = proto;
-	err = rawv6_probe_proto_opt(&fl, msg);
+	fl6.flowi6_proto = proto;
+	err = rawv6_probe_proto_opt(&fl6, msg);
 	if (err)
 		goto out;
 
 	if (!ipv6_addr_any(daddr))
-		ipv6_addr_copy(&fl.fl6_dst, daddr);
+		ipv6_addr_copy(&fl6.daddr, daddr);
 	else
-		fl.fl6_dst.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
-	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
+		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
+	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
+		ipv6_addr_copy(&fl6.saddr, &np->saddr);
 
-	final_p = fl6_update_dst(&fl, opt, &final);
+	final_p = fl6_update_dst(&fl6, opt, &final);
 
-	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-		fl.flowi_oif = np->mcast_oif;
-	security_sk_classify_flow(sk, &fl);
+	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
+		fl6.flowi6_oif = np->mcast_oif;
+	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto out;
 	}
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl.fl6_dst))
+		if (ipv6_addr_is_multicast(&fl6.daddr))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -881,17 +880,17 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 back_from_confirm:
 	if (inet->hdrincl)
-		err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl, &dst, msg->msg_flags);
+		err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl6, &dst, msg->msg_flags);
 	else {
 		lock_sock(sk);
 		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
-			len, 0, hlimit, tclass, opt, &fl, (struct rt6_info*)dst,
+			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info*)dst,
 			msg->msg_flags, dontfrag);
 
 		if (err)
 			ip6_flush_pending_frames(sk);
 		else if (!(msg->msg_flags & MSG_MORE))
-			err = rawv6_push_pending_frames(sk, &fl, rp);
+			err = rawv6_push_pending_frames(sk, &fl6, rp);
 		release_sock(sk);
 	}
 done:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c3b20d6..6814c87 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -599,17 +599,17 @@ do { \
 
 static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 					     struct fib6_table *table,
-					     struct flowi *fl, int flags)
+					     struct flowi6 *fl6, int flags)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt;
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
+	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(net, rt, &fl->fl6_src, fl->flowi_oif, flags);
-	BACKTRACK(net, &fl->fl6_src);
+	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
+	BACKTRACK(net, &fl6->saddr);
 out:
 	dst_use(&rt->dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
@@ -620,19 +620,19 @@ out:
 struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int strict)
 {
-	struct flowi fl = {
-		.flowi_oif = oif,
-		.fl6_dst = *daddr,
+	struct flowi6 fl6 = {
+		.flowi6_oif = oif,
+		.daddr = *daddr,
 	};
 	struct dst_entry *dst;
 	int flags = strict ? RT6_LOOKUP_F_IFACE : 0;
 
 	if (saddr) {
-		memcpy(&fl.fl6_src, saddr, sizeof(*saddr));
+		memcpy(&fl6.saddr, saddr, sizeof(*saddr));
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 	}
 
-	dst = fib6_rule_lookup(net, &fl, flags, ip6_pol_route_lookup);
+	dst = fib6_rule_lookup(net, &fl6, flags, ip6_pol_route_lookup);
 	if (dst->error == 0)
 		return (struct rt6_info *) dst;
 
@@ -753,7 +753,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, struct in6_addr *d
 }
 
 static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
-				      struct flowi *fl, int flags)
+				      struct flowi6 *fl6, int flags)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
@@ -768,12 +768,12 @@ relookup:
 	read_lock_bh(&table->tb6_lock);
 
 restart_2:
-	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
+	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
 
-	BACKTRACK(net, &fl->fl6_src);
+	BACKTRACK(net, &fl6->saddr);
 	if (rt == net->ipv6.ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
@@ -782,9 +782,9 @@ restart:
 	read_unlock_bh(&table->tb6_lock);
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
-		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
+		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
-		nrt = rt6_alloc_clone(rt, &fl->fl6_dst);
+		nrt = rt6_alloc_clone(rt, &fl6->daddr);
 	else
 		goto out2;
 
@@ -823,9 +823,9 @@ out2:
 }
 
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
-					    struct flowi *fl, int flags)
+					    struct flowi6 *fl6, int flags)
 {
-	return ip6_pol_route(net, table, fl->flowi_iif, fl, flags);
+	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags);
 }
 
 void ip6_route_input(struct sk_buff *skb)
@@ -833,41 +833,41 @@ void ip6_route_input(struct sk_buff *skb)
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct net *net = dev_net(skb->dev);
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
-	struct flowi fl = {
-		.flowi_iif = skb->dev->ifindex,
-		.fl6_dst = iph->daddr,
-		.fl6_src = iph->saddr,
-		.fl6_flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
-		.flowi_mark = skb->mark,
-		.flowi_proto = iph->nexthdr,
+	struct flowi6 fl6 = {
+		.flowi6_iif = skb->dev->ifindex,
+		.daddr = iph->daddr,
+		.saddr = iph->saddr,
+		.flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
+		.flowi6_mark = skb->mark,
+		.flowi6_proto = iph->nexthdr,
 	};
 
 	if (rt6_need_strict(&iph->daddr) && skb->dev->type != ARPHRD_PIMREG)
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	skb_dst_set(skb, fib6_rule_lookup(net, &fl, flags, ip6_pol_route_input));
+	skb_dst_set(skb, fib6_rule_lookup(net, &fl6, flags, ip6_pol_route_input));
 }
 
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
-					     struct flowi *fl, int flags)
+					     struct flowi6 *fl6, int flags)
 {
-	return ip6_pol_route(net, table, fl->flowi_oif, fl, flags);
+	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
 }
 
 struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
-				    struct flowi *fl)
+				    struct flowi6 *fl6)
 {
 	int flags = 0;
 
-	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl->fl6_dst))
+	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	if (!ipv6_addr_any(&fl->fl6_src))
+	if (!ipv6_addr_any(&fl6->saddr))
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 	else if (sk)
 		flags |= rt6_srcprefs2flags(inet6_sk(sk)->srcprefs);
 
-	return fib6_rule_lookup(net, fl, flags, ip6_pol_route_output);
+	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_output);
 }
 
 EXPORT_SYMBOL(ip6_route_output);
@@ -1444,16 +1444,16 @@ static int ip6_route_del(struct fib6_config *cfg)
  *	Handle redirects
  */
 struct ip6rd_flowi {
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct in6_addr gateway;
 };
 
 static struct rt6_info *__ip6_route_redirect(struct net *net,
 					     struct fib6_table *table,
-					     struct flowi *fl,
+					     struct flowi6 *fl6,
 					     int flags)
 {
-	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl;
+	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl6;
 	struct rt6_info *rt;
 	struct fib6_node *fn;
 
@@ -1469,7 +1469,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 	 */
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
+	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 restart:
 	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 		/*
@@ -1484,7 +1484,7 @@ restart:
 			continue;
 		if (!(rt->rt6i_flags & RTF_GATEWAY))
 			continue;
-		if (fl->flowi_oif != rt->rt6i_dev->ifindex)
+		if (fl6->flowi6_oif != rt->rt6i_dev->ifindex)
 			continue;
 		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
 			continue;
@@ -1493,7 +1493,7 @@ restart:
 
 	if (!rt)
 		rt = net->ipv6.ip6_null_entry;
-	BACKTRACK(net, &fl->fl6_src);
+	BACKTRACK(net, &fl6->saddr);
 out:
 	dst_hold(&rt->dst);
 
@@ -1510,10 +1510,10 @@ static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct net *net = dev_net(dev);
 	struct ip6rd_flowi rdfl = {
-		.fl = {
-			.flowi_oif = dev->ifindex,
-			.fl6_dst = *dest,
-			.fl6_src = *src,
+		.fl6 = {
+			.flowi6_oif = dev->ifindex,
+			.daddr = *dest,
+			.saddr = *src,
 		},
 	};
 
@@ -1522,7 +1522,7 @@ static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
 	if (rt6_need_strict(dest))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	return (struct rt6_info *)fib6_rule_lookup(net, (struct flowi *)&rdfl,
+	return (struct rt6_info *)fib6_rule_lookup(net, &rdfl.fl6,
 						   flags, __ip6_route_redirect);
 }
 
@@ -2385,7 +2385,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	struct rt6_info *rt;
 	struct sk_buff *skb;
 	struct rtmsg *rtm;
-	struct flowi fl;
+	struct flowi6 fl6;
 	int err, iif = 0;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
@@ -2393,27 +2393,27 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		goto errout;
 
 	err = -EINVAL;
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 
 	if (tb[RTA_SRC]) {
 		if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
 			goto errout;
 
-		ipv6_addr_copy(&fl.fl6_src, nla_data(tb[RTA_SRC]));
+		ipv6_addr_copy(&fl6.saddr, nla_data(tb[RTA_SRC]));
 	}
 
 	if (tb[RTA_DST]) {
 		if (nla_len(tb[RTA_DST]) < sizeof(struct in6_addr))
 			goto errout;
 
-		ipv6_addr_copy(&fl.fl6_dst, nla_data(tb[RTA_DST]));
+		ipv6_addr_copy(&fl6.daddr, nla_data(tb[RTA_DST]));
 	}
 
 	if (tb[RTA_IIF])
 		iif = nla_get_u32(tb[RTA_IIF]);
 
 	if (tb[RTA_OIF])
-		fl.flowi_oif = nla_get_u32(tb[RTA_OIF]);
+		fl6.flowi6_oif = nla_get_u32(tb[RTA_OIF]);
 
 	if (iif) {
 		struct net_device *dev;
@@ -2436,10 +2436,10 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	skb_reset_mac_header(skb);
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
-	rt = (struct rt6_info*) ip6_route_output(net, NULL, &fl);
+	rt = (struct rt6_info*) ip6_route_output(net, NULL, &fl6);
 	skb_dst_set(skb, &rt->dst);
 
-	err = rt6_fill_node(net, skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
+	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
 			    nlh->nlmsg_seq, 0, 0, 0);
 	if (err < 0) {
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 5b9eded..97858d5 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -232,19 +232,19 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	 */
 	{
 		struct in6_addr *final_p, final;
-		struct flowi fl;
-		memset(&fl, 0, sizeof(fl));
-		fl.flowi_proto = IPPROTO_TCP;
-		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
-		final_p = fl6_update_dst(&fl, np->opt, &final);
-		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
-		fl.flowi_oif = sk->sk_bound_dev_if;
-		fl.flowi_mark = sk->sk_mark;
-		fl.fl6_dport = inet_rsk(req)->rmt_port;
-		fl.fl6_sport = inet_sk(sk)->inet_sport;
-		security_req_classify_flow(req, &fl);
-
-		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+		struct flowi6 fl6;
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_proto = IPPROTO_TCP;
+		ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
+		final_p = fl6_update_dst(&fl6, np->opt, &final);
+		ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
+		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_mark = sk->sk_mark;
+		fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
+		fl6.uli.ports.sport = inet_sk(sk)->inet_sport;
+		security_req_classify_flow(req, flowi6_to_flowi(&fl6));
+
+		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 		if (IS_ERR(dst))
 			goto out_free;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c531ad5..7ed0ba1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -131,7 +131,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct in6_addr *saddr = NULL, *final_p, final;
 	struct rt6_info *rt;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int addr_type;
 	int err;
@@ -142,14 +142,14 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 
 	if (np->sndflow) {
-		fl.fl6_flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-		IP6_ECN_flow_init(fl.fl6_flowlabel);
-		if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
+		fl6.flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
+		IP6_ECN_flow_init(fl6.flowlabel);
+		if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
 			struct ip6_flowlabel *flowlabel;
-			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
@@ -195,7 +195,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	}
 
 	ipv6_addr_copy(&np->daddr, &usin->sin6_addr);
-	np->flow_label = fl.fl6_flowlabel;
+	np->flow_label = fl6.flowlabel;
 
 	/*
 	 *	TCP over IPv4
@@ -242,27 +242,27 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (!ipv6_addr_any(&np->rcv_saddr))
 		saddr = &np->rcv_saddr;
 
-	fl.flowi_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-	ipv6_addr_copy(&fl.fl6_src,
+	fl6.flowi6_proto = IPPROTO_TCP;
+	ipv6_addr_copy(&fl6.daddr, &np->daddr);
+	ipv6_addr_copy(&fl6.saddr,
 		       (saddr ? saddr : &np->saddr));
-	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.flowi_mark = sk->sk_mark;
-	fl.fl6_dport = usin->sin6_port;
-	fl.fl6_sport = inet->inet_sport;
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.flowi6_mark = sk->sk_mark;
+	fl6.uli.ports.dport = usin->sin6_port;
+	fl6.uli.ports.sport = inet->inet_sport;
 
-	final_p = fl6_update_dst(&fl, np->opt, &final);
+	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
-	security_sk_classify_flow(sk, &fl);
+	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto failure;
 	}
 
 	if (saddr == NULL) {
-		saddr = &fl.fl6_src;
+		saddr = &fl6.saddr;
 		ipv6_addr_copy(&np->rcv_saddr, saddr);
 	}
 
@@ -389,23 +389,23 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		if (dst == NULL) {
 			struct inet_sock *inet = inet_sk(sk);
-			struct flowi fl;
+			struct flowi6 fl6;
 
 			/* BUGGG_FUTURE: Again, it is not clear how
 			   to handle rthdr case. Ignore this complexity
 			   for now.
 			 */
-			memset(&fl, 0, sizeof(fl));
-			fl.flowi_proto = IPPROTO_TCP;
-			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-			fl.flowi_oif = sk->sk_bound_dev_if;
-			fl.flowi_mark = sk->sk_mark;
-			fl.fl6_dport = inet->inet_dport;
-			fl.fl6_sport = inet->inet_sport;
-			security_skb_classify_flow(skb, &fl);
-
-			dst = ip6_dst_lookup_flow(sk, &fl, NULL, false);
+			memset(&fl6, 0, sizeof(fl6));
+			fl6.flowi6_proto = IPPROTO_TCP;
+			ipv6_addr_copy(&fl6.daddr, &np->daddr);
+			ipv6_addr_copy(&fl6.saddr, &np->saddr);
+			fl6.flowi6_oif = sk->sk_bound_dev_if;
+			fl6.flowi6_mark = sk->sk_mark;
+			fl6.uli.ports.dport = inet->inet_dport;
+			fl6.uli.ports.sport = inet->inet_sport;
+			security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
+
+			dst = ip6_dst_lookup_flow(sk, &fl6, NULL, false);
 			if (IS_ERR(dst)) {
 				sk->sk_err_soft = -PTR_ERR(dst);
 				goto out;
@@ -482,25 +482,25 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	struct sk_buff * skb;
 	struct ipv6_txoptions *opt = NULL;
 	struct in6_addr * final_p, final;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int err;
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
-	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
-	fl.fl6_flowlabel = 0;
-	fl.flowi_oif = treq->iif;
-	fl.flowi_mark = sk->sk_mark;
-	fl.fl6_dport = inet_rsk(req)->rmt_port;
-	fl.fl6_sport = inet_rsk(req)->loc_port;
-	security_req_classify_flow(req, &fl);
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_TCP;
+	ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
+	ipv6_addr_copy(&fl6.saddr, &treq->loc_addr);
+	fl6.flowlabel = 0;
+	fl6.flowi6_oif = treq->iif;
+	fl6.flowi6_mark = sk->sk_mark;
+	fl6.uli.ports.dport = inet_rsk(req)->rmt_port;
+	fl6.uli.ports.sport = inet_rsk(req)->loc_port;
+	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 	opt = np->opt;
-	final_p = fl6_update_dst(&fl, opt, &final);
+	final_p = fl6_update_dst(&fl6, opt, &final);
 
-	dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto done;
@@ -510,8 +510,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
-		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
-		err = ip6_xmit(sk, skb, &fl, opt);
+		ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
+		err = ip6_xmit(sk, skb, &fl6, opt);
 		err = net_xmit_eval(err);
 	}
 
@@ -992,7 +992,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 {
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(struct tcphdr);
@@ -1046,29 +1046,29 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	}
 #endif
 
-	memset(&fl, 0, sizeof(fl));
-	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
-	ipv6_addr_copy(&fl.fl6_src, &ipv6_hdr(skb)->daddr);
+	memset(&fl6, 0, sizeof(fl6));
+	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->saddr);
+	ipv6_addr_copy(&fl6.saddr, &ipv6_hdr(skb)->daddr);
 
 	buff->ip_summed = CHECKSUM_PARTIAL;
 	buff->csum = 0;
 
-	__tcp_v6_send_check(buff, &fl.fl6_src, &fl.fl6_dst);
+	__tcp_v6_send_check(buff, &fl6.saddr, &fl6.daddr);
 
-	fl.flowi_proto = IPPROTO_TCP;
-	fl.flowi_oif = inet6_iif(skb);
-	fl.fl6_dport = t1->dest;
-	fl.fl6_sport = t1->source;
-	security_skb_classify_flow(skb, &fl);
+	fl6.flowi6_proto = IPPROTO_TCP;
+	fl6.flowi6_oif = inet6_iif(skb);
+	fl6.uli.ports.dport = t1->dest;
+	fl6.uli.ports.sport = t1->source;
+	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	/* Pass a socket to ip6_dst_lookup either it is for RST
 	 * Underlying function will use this to retrieve the network
 	 * namespace
 	 */
-	dst = ip6_dst_lookup_flow(ctl_sk, &fl, NULL, false);
+	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
-		ip6_xmit(ctl_sk, buff, &fl, NULL);
+		ip6_xmit(ctl_sk, buff, &fl6, NULL);
 		TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 		if (rst)
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index dad035f..ce4b16f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -886,7 +886,7 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	struct udphdr *uh;
 	struct udp_sock  *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
-	struct flowi *fl = &inet->cork.fl;
+	struct flowi6 *fl6 = &inet->cork.fl.u.ip6;
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
 	__wsum csum = 0;
@@ -899,23 +899,23 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	 * Create a UDP header
 	 */
 	uh = udp_hdr(skb);
-	uh->source = fl->fl6_sport;
-	uh->dest = fl->fl6_dport;
+	uh->source = fl6->uli.ports.sport;
+	uh->dest = fl6->uli.ports.dport;
 	uh->len = htons(up->len);
 	uh->check = 0;
 
 	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
 	else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
-		udp6_hwcsum_outgoing(sk, skb, &fl->fl6_src, &fl->fl6_dst,
+		udp6_hwcsum_outgoing(sk, skb, &fl6->saddr, &fl6->daddr,
 				     up->len);
 		goto send;
 	} else
 		csum = udp_csum_outgoing(sk, skb);
 
 	/* add protocol-dependent pseudo-header */
-	uh->check = csum_ipv6_magic(&fl->fl6_src, &fl->fl6_dst,
-				    up->len, fl->flowi_proto, csum);
+	uh->check = csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
+				    up->len, fl6->flowi6_proto, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
@@ -947,7 +947,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct in6_addr *daddr, *final_p, final;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
-	struct flowi fl;
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
@@ -1030,19 +1030,19 @@ do_udp_sendmsg:
 	}
 	ulen += sizeof(struct udphdr);
 
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 
 	if (sin6) {
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
-		fl.fl6_dport = sin6->sin6_port;
+		fl6.uli.ports.dport = sin6->sin6_port;
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
-			fl.fl6_flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-			if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+			fl6.flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
+			if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
+				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
 				daddr = &flowlabel->dst;
@@ -1060,38 +1060,38 @@ do_udp_sendmsg:
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
 		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
-			fl.flowi_oif = sin6->sin6_scope_id;
+			fl6.flowi6_oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		fl.fl6_dport = inet->inet_dport;
+		fl6.uli.ports.dport = inet->inet_dport;
 		daddr = &np->daddr;
-		fl.fl6_flowlabel = np->flow_label;
+		fl6.flowlabel = np->flow_label;
 		connected = 1;
 	}
 
-	if (!fl.flowi_oif)
-		fl.flowi_oif = sk->sk_bound_dev_if;
+	if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = sk->sk_bound_dev_if;
 
-	if (!fl.flowi_oif)
-		fl.flowi_oif = np->sticky_pktinfo.ipi6_ifindex;
+	if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
 
-	fl.flowi_mark = sk->sk_mark;
+	fl6.flowi6_mark = sk->sk_mark;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit,
+		err = datagram_send_ctl(sock_net(sk), msg, &fl6, opt, &hlimit,
 					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
 		}
-		if ((fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+		if ((fl6.flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
+			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 		}
@@ -1105,27 +1105,27 @@ do_udp_sendmsg:
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
 
-	fl.flowi_proto = sk->sk_protocol;
+	fl6.flowi6_proto = sk->sk_protocol;
 	if (!ipv6_addr_any(daddr))
-		ipv6_addr_copy(&fl.fl6_dst, daddr);
+		ipv6_addr_copy(&fl6.daddr, daddr);
 	else
-		fl.fl6_dst.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
-	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.fl6_sport = inet->inet_sport;
+		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
+	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
+		ipv6_addr_copy(&fl6.saddr, &np->saddr);
+	fl6.uli.ports.sport = inet->inet_sport;
 
-	final_p = fl6_update_dst(&fl, opt, &final);
+	final_p = fl6_update_dst(&fl6, opt, &final);
 	if (final_p)
 		connected = 0;
 
-	if (!fl.flowi_oif && ipv6_addr_is_multicast(&fl.fl6_dst)) {
-		fl.flowi_oif = np->mcast_oif;
+	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr)) {
+		fl6.flowi6_oif = np->mcast_oif;
 		connected = 0;
 	}
 
-	security_sk_classify_flow(sk, &fl);
+	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	dst = ip6_sk_dst_lookup_flow(sk, &fl, final_p, true);
+	dst = ip6_sk_dst_lookup_flow(sk, &fl6, final_p, true);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		dst = NULL;
@@ -1133,7 +1133,7 @@ do_udp_sendmsg:
 	}
 
 	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl.fl6_dst))
+		if (ipv6_addr_is_multicast(&fl6.daddr))
 			hlimit = np->mcast_hops;
 		else
 			hlimit = np->hop_limit;
@@ -1168,7 +1168,7 @@ do_append_data:
 	up->len += ulen;
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
-		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
+		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
 		(struct rt6_info*)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
 	if (err)
@@ -1181,10 +1181,10 @@ do_append_data:
 	if (dst) {
 		if (connected) {
 			ip6_dst_store(sk, dst,
-				      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
+				      ipv6_addr_equal(&fl6.daddr, &np->daddr) ?
 				      &np->daddr : NULL,
 #ifdef CONFIG_IPV6_SUBTREES
-				      ipv6_addr_equal(&fl.fl6_src, &np->saddr) ?
+				      ipv6_addr_equal(&fl6.saddr, &np->saddr) ?
 				      &np->saddr :
 #endif
 				      NULL);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 254aa6d..bef6200 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -39,8 +39,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
 	if (saddr)
 		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
 
-	dst = ip6_route_output(net, NULL,
-			       flowi6_to_flowi(&fl6));
+	dst = ip6_route_output(net, NULL, &fl6);
 
 	err = dst->error;
 	if (dst->error) {
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d07a32a..a60b20f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -75,15 +75,13 @@ static int __ip_vs_addr_is_local_v6(struct net *net,
 				    const struct in6_addr *addr)
 {
 	struct rt6_info *rt;
-	struct flowi fl = {
-		.flowi_oif = 0,
-		.fl6_dst = *addr,
-		.fl6_src = { .s6_addr32 = {0, 0, 0, 0} },
+	struct flowi6 fl6 = {
+		.daddr = *addr,
 	};
 
-	rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl);
+	rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
 	if (rt && rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
-			return 1;
+		return 1;
 
 	return 0;
 }
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 7dc00e3..6132b21 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -198,27 +198,27 @@ __ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
 			struct in6_addr *ret_saddr, int do_xfrm)
 {
 	struct dst_entry *dst;
-	struct flowi fl = {
-		.fl6_dst = *daddr,
+	struct flowi6 fl6 = {
+		.daddr = *daddr,
 	};
 
-	dst = ip6_route_output(net, NULL, &fl);
+	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error)
 		goto out_err;
 	if (!ret_saddr)
 		return dst;
-	if (ipv6_addr_any(&fl.fl6_src) &&
+	if (ipv6_addr_any(&fl6.saddr) &&
 	    ipv6_dev_get_saddr(net, ip6_dst_idev(dst)->dev,
-			       &fl.fl6_dst, 0, &fl.fl6_src) < 0)
+			       &fl6.daddr, 0, &fl6.saddr) < 0)
 		goto out_err;
 	if (do_xfrm) {
-		dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+		dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 		if (IS_ERR(dst)) {
 			dst = NULL;
 			goto out_err;
 		}
 	}
-	ipv6_addr_copy(ret_saddr, &fl.fl6_src);
+	ipv6_addr_copy(ret_saddr, &fl6.saddr);
 	return dst;
 
 out_err:
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index d8c00f9..5f054a0 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -143,18 +143,18 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct net *net = pick_net(skb);
 	struct dst_entry *dst;
-	struct flowi fl;
+	struct flowi6 fl6;
 
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 	if (info->priv) {
 		if (info->priv->oif == -1)
 			return false;
-		fl.flowi_oif = info->priv->oif;
+		fl6.flowi6_oif = info->priv->oif;
 	}
-	fl.fl6_dst = info->gw.in6;
-	fl.fl6_flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
+	fl6.daddr = info->gw.in6;
+	fl6.flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
 			   (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
-	dst = ip6_route_output(net, NULL, &fl);
+	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst == NULL)
 		return false;
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 8316271..865ce7b 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -201,40 +201,40 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 {
 	struct sock *sk = skb->sk;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flowi fl;
+	struct flowi6 fl6;
 
-	memset(&fl, 0, sizeof(fl));
+	memset(&fl6, 0, sizeof(fl6));
 
-	fl.flowi_proto = sk->sk_protocol;
+	fl6.flowi6_proto = sk->sk_protocol;
 
 	/* Fill in the dest address from the route entry passed with the skb
 	 * and the source address from the transport.
 	 */
-	ipv6_addr_copy(&fl.fl6_dst, &transport->ipaddr.v6.sin6_addr);
-	ipv6_addr_copy(&fl.fl6_src, &transport->saddr.v6.sin6_addr);
+	ipv6_addr_copy(&fl6.daddr, &transport->ipaddr.v6.sin6_addr);
+	ipv6_addr_copy(&fl6.saddr, &transport->saddr.v6.sin6_addr);
 
-	fl.fl6_flowlabel = np->flow_label;
-	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
-	if (ipv6_addr_type(&fl.fl6_src) & IPV6_ADDR_LINKLOCAL)
-		fl.flowi_oif = transport->saddr.v6.sin6_scope_id;
+	fl6.flowlabel = np->flow_label;
+	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
+	if (ipv6_addr_type(&fl6.saddr) & IPV6_ADDR_LINKLOCAL)
+		fl6.flowi6_oif = transport->saddr.v6.sin6_scope_id;
 	else
-		fl.flowi_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_oif = sk->sk_bound_dev_if;
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		ipv6_addr_copy(&fl6.daddr, rt0->addr);
 	}
 
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%pI6 dst:%pI6\n",
 			  __func__, skb, skb->len,
-			  &fl.fl6_src, &fl.fl6_dst);
+			  &fl6.saddr, &fl6.daddr);
 
 	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
 
 	if (!(transport->param_flags & SPP_PMTUD_ENABLE))
 		skb->local_df = 1;
 
-	return ip6_xmit(sk, skb, &fl, np->opt);
+	return ip6_xmit(sk, skb, &fl6, np->opt);
 }
 
 /* Returns the dst cache entry for the given source and destination ip
@@ -245,22 +245,22 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 					 union sctp_addr *saddr)
 {
 	struct dst_entry *dst;
-	struct flowi fl;
+	struct flowi6 fl6;
 
-	memset(&fl, 0, sizeof(fl));
-	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
+	memset(&fl6, 0, sizeof(fl6));
+	ipv6_addr_copy(&fl6.daddr, &daddr->v6.sin6_addr);
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		fl.flowi_oif = daddr->v6.sin6_scope_id;
+		fl6.flowi6_oif = daddr->v6.sin6_scope_id;
 
 
-	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl.fl6_dst);
+	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl6.daddr);
 
 	if (saddr) {
-		ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl.fl6_src);
+		ipv6_addr_copy(&fl6.saddr, &saddr->v6.sin6_addr);
+		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl6.saddr);
 	}
 
-	dst = ip6_route_output(&init_net, NULL, &fl);
+	dst = ip6_route_output(&init_net, NULL, &fl6);
 	if (!dst->error) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
-- 
1.7.4.1

