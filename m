From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/8] ipv4: Make caller provide on-stack flow key to
 ip_route_output_ports().
Date: Wed, 04 May 2011 10:14:51 -0700 (PDT)
Message-ID: <20110504.101451.189696020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754695Ab1EDRPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id C26EC24C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:14:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/cxgb3/iwch_cm.c |    3 ++-
 drivers/infiniband/hw/cxgb4/cm.c      |    3 ++-
 drivers/net/pptp.c                    |    6 ++++--
 drivers/scsi/cxgbi/libcxgbi.c         |    3 ++-
 include/net/route.h                   |   11 +++++------
 net/ipv4/af_inet.c                    |    3 ++-
 net/ipv4/igmp.c                       |    6 ++++--
 net/ipv4/ip_output.c                  |    3 ++-
 net/ipv4/ipip.c                       |   19 +++++++++++--------
 net/ipv4/ipmr.c                       |    5 +++--
 net/ipv6/ip6_tunnel.c                 |    5 +++--
 net/ipv6/sit.c                        |    6 ++++--
 net/l2tp/l2tp_ip.c                    |    3 ++-
 net/rxrpc/ar-peer.c                   |    3 ++-
 14 files changed, 48 insertions(+), 31 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 3216bca..2391841 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -338,8 +338,9 @@ static struct rtable *find_route(struct t3cdev *dev, __be32 local_ip,
 				 __be16 peer_port, u8 tos)
 {
 	struct rtable *rt;
+	struct flowi4 fl4;
 
-	rt = ip_route_output_ports(&init_net, NULL, peer_ip, local_ip,
+	rt = ip_route_output_ports(&init_net, &fl4, NULL, peer_ip, local_ip,
 				   peer_port, local_port, IPPROTO_TCP,
 				   tos, 0);
 	if (IS_ERR(rt))
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 9d8dcfa..6aa53cd 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -315,8 +315,9 @@ static struct rtable *find_route(struct c4iw_dev *dev, __be32 local_ip,
 				 __be16 peer_port, u8 tos)
 {
 	struct rtable *rt;
+	struct flowi4 fl4;
 
-	rt = ip_route_output_ports(&init_net, NULL, peer_ip, local_ip,
+	rt = ip_route_output_ports(&init_net, &fl4, NULL, peer_ip, local_ip,
 				   peer_port, local_port, IPPROTO_TCP,
 				   tos, 0);
 	if (IS_ERR(rt))
diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index 51dfcf8..e771e8d 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -175,6 +175,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	struct pptp_opt *opt = &po->proto.pptp;
 	struct pptp_gre_header *hdr;
 	unsigned int header_len = sizeof(*hdr);
+	struct flowi4 fl4;
 	int islcp;
 	int len;
 	unsigned char *data;
@@ -189,7 +190,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (sk_pppox(po)->sk_state & PPPOX_DEAD)
 		goto tx_error;
 
-	rt = ip_route_output_ports(&init_net, NULL,
+	rt = ip_route_output_ports(&init_net, &fl4, NULL,
 				   opt->dst_addr.sin_addr.s_addr,
 				   opt->src_addr.sin_addr.s_addr,
 				   0, 0, IPPROTO_GRE,
@@ -434,6 +435,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	struct pppox_sock *po = pppox_sk(sk);
 	struct pptp_opt *opt = &po->proto.pptp;
 	struct rtable *rt;
+	struct flowi4 fl4;
 	int error = 0;
 
 	if (sp->sa_protocol != PX_PROTO_PPTP)
@@ -463,7 +465,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	po->chan.private = sk;
 	po->chan.ops = &pptp_chan_ops;
 
-	rt = ip_route_output_ports(&init_net, sk,
+	rt = ip_route_output_ports(&init_net, &fl4, sk,
 				   opt->dst_addr.sin_addr.s_addr,
 				   opt->src_addr.sin_addr.s_addr,
 				   0, 0,
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index de764ea..0c33d25 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -454,8 +454,9 @@ static struct rtable *find_route_ipv4(__be32 saddr, __be32 daddr,
 				      __be16 sport, __be16 dport, u8 tos)
 {
 	struct rtable *rt;
+	struct flowi4 fl4;
 
-	rt = ip_route_output_ports(&init_net, NULL, daddr, saddr,
+	rt = ip_route_output_ports(&init_net, &fl4, NULL, daddr, saddr,
 				   dport, sport, IPPROTO_TCP, tos, 0);
 	if (IS_ERR(rt))
 		return NULL;
diff --git a/include/net/route.h b/include/net/route.h
index f07609e..8c02c87 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -137,20 +137,19 @@ static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
 	return ip_route_output_key(net, &fl4);
 }
 
-static inline struct rtable *ip_route_output_ports(struct net *net, struct sock *sk,
+static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi4 *fl4,
+						   struct sock *sk,
 						   __be32 daddr, __be32 saddr,
 						   __be16 dport, __be16 sport,
 						   __u8 proto, __u8 tos, int oif)
 {
-	struct flowi4 fl4;
-
-	flowi4_init_output(&fl4, oif, sk ? sk->sk_mark : 0, tos,
+	flowi4_init_output(fl4, oif, sk ? sk->sk_mark : 0, tos,
 			   RT_SCOPE_UNIVERSE, proto,
 			   sk ? inet_sk_flowi_flags(sk) : 0,
 			   daddr, saddr, dport, sport);
 	if (sk)
-		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-	return ip_route_output_flow(net, &fl4, sk);
+		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
+	return ip_route_output_flow(net, fl4, sk);
 }
 
 static inline struct rtable *ip_route_output_gre(struct net *net,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4e73499..7b91fa8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1152,6 +1152,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	struct rtable *rt = (struct rtable *)__sk_dst_check(sk, 0);
 	__be32 daddr;
 	struct ip_options_rcu *inet_opt;
+	struct flowi4 fl4;
 	int err;
 
 	/* Route is OK, nothing to do. */
@@ -1165,7 +1166,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	if (inet_opt && inet_opt->opt.srr)
 		daddr = inet_opt->opt.faddr;
 	rcu_read_unlock();
-	rt = ip_route_output_ports(sock_net(sk), sk, daddr, inet->inet_saddr,
+	rt = ip_route_output_ports(sock_net(sk), &fl4, sk, daddr, inet->inet_saddr,
 				   inet->inet_dport, inet->inet_sport,
 				   sk->sk_protocol, RT_CONN_FLAGS(sk),
 				   sk->sk_bound_dev_if);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 8ae0a57..7c2ef59 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -309,6 +309,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	struct iphdr *pip;
 	struct igmpv3_report *pig;
 	struct net *net = dev_net(dev);
+	struct flowi4 fl4;
 
 	while (1) {
 		skb = alloc_skb(size + LL_ALLOCATED_SPACE(dev),
@@ -321,7 +322,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	}
 	igmp_skb_size(skb) = size;
 
-	rt = ip_route_output_ports(net, NULL, IGMPV3_ALL_MCR, 0,
+	rt = ip_route_output_ports(net, &fl4, NULL, IGMPV3_ALL_MCR, 0,
 				   0, 0,
 				   IPPROTO_IGMP, 0, dev->ifindex);
 	if (IS_ERR(rt)) {
@@ -650,6 +651,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	struct net_device *dev = in_dev->dev;
 	struct net *net = dev_net(dev);
 	__be32	group = pmc ? pmc->multiaddr : 0;
+	struct flowi4 fl4;
 	__be32	dst;
 
 	if (type == IGMPV3_HOST_MEMBERSHIP_REPORT)
@@ -659,7 +661,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	else
 		dst = group;
 
-	rt = ip_route_output_ports(net, NULL, dst, 0,
+	rt = ip_route_output_ports(net, &fl4, NULL, dst, 0,
 				   0, 0,
 				   IPPROTO_IGMP, 0, dev->ifindex);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 362e66f..3aa4c31 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -333,6 +333,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 	/* Make sure we can route this packet. */
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
 	if (rt == NULL) {
+		struct flowi4 fl4;
 		__be32 daddr;
 
 		/* Use correct destination address if we have options. */
@@ -344,7 +345,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 		 * keep trying until route appears or the connection times
 		 * itself out.
 		 */
-		rt = ip_route_output_ports(sock_net(sk), sk,
+		rt = ip_route_output_ports(sock_net(sk), &fl4, sk,
 					   daddr, inet->inet_saddr,
 					   inet->inet_dport,
 					   inet->inet_sport,
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index ef16377..88d96bd 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -442,6 +442,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	__be32 dst = tiph->daddr;
+	struct flowi4 fl4;
 	int    mtu;
 
 	if (skb->protocol != htons(ETH_P_IP))
@@ -460,7 +461,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error_icmp;
 	}
 
-	rt = ip_route_output_ports(dev_net(dev), NULL,
+	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
 				   dst, tiph->saddr,
 				   0, 0,
 				   IPPROTO_IPIP, RT_TOS(tos),
@@ -578,13 +579,15 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 	iph = &tunnel->parms.iph;
 
 	if (iph->daddr) {
-		struct rtable *rt = ip_route_output_ports(dev_net(dev), NULL,
-							  iph->daddr, iph->saddr,
-							  0, 0,
-							  IPPROTO_IPIP,
-							  RT_TOS(iph->tos),
-							  tunnel->parms.link);
-
+		struct rtable *rt;
+		struct flowi4 fl4;
+
+		rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
+					   iph->daddr, iph->saddr,
+					   0, 0,
+					   IPPROTO_IPIP,
+					   RT_TOS(iph->tos),
+					   tunnel->parms.link);
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 3ad38a4..86033b7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1595,6 +1595,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	struct vif_device *vif = &mrt->vif_table[vifi];
 	struct net_device *dev;
 	struct rtable *rt;
+	struct flowi4 fl4;
 	int    encap = 0;
 
 	if (vif->dev == NULL)
@@ -1612,7 +1613,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 #endif
 
 	if (vif->flags & VIFF_TUNNEL) {
-		rt = ip_route_output_ports(net, NULL,
+		rt = ip_route_output_ports(net, &fl4, NULL,
 					   vif->remote, vif->local,
 					   0, 0,
 					   IPPROTO_IPIP,
@@ -1621,7 +1622,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 			goto out_free;
 		encap = sizeof(struct iphdr);
 	} else {
-		rt = ip_route_output_ports(net, NULL, iph->daddr, 0,
+		rt = ip_route_output_ports(net, &fl4, NULL, iph->daddr, 0,
 					   0, 0,
 					   IPPROTO_IPIP,
 					   RT_TOS(iph->tos), vif->link);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9dd0e96..3dff27c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -537,6 +537,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct sk_buff *skb2;
 	const struct iphdr *eiph;
 	struct rtable *rt;
+	struct flowi4 fl4;
 
 	err = ip6_tnl_err(skb, IPPROTO_IPIP, opt, &rel_type, &rel_code,
 			  &rel_msg, &rel_info, offset);
@@ -577,7 +578,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	eiph = ip_hdr(skb2);
 
 	/* Try to guess incoming interface */
-	rt = ip_route_output_ports(dev_net(skb->dev), NULL,
+	rt = ip_route_output_ports(dev_net(skb->dev), &fl4, NULL,
 				   eiph->saddr, 0,
 				   0, 0,
 				   IPPROTO_IPIP, RT_TOS(eiph->tos), 0);
@@ -590,7 +591,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
 		rt = NULL;
-		rt = ip_route_output_ports(dev_net(skb->dev), NULL,
+		rt = ip_route_output_ports(dev_net(skb->dev), &fl4, NULL,
 					   eiph->daddr, eiph->saddr,
 					   0, 0,
 					   IPPROTO_IPIP,
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 34d8964..a24fb14 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -674,6 +674,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	__be32 dst = tiph->daddr;
+	struct flowi4 fl4;
 	int    mtu;
 	const struct in6_addr *addr6;
 	int addr_type;
@@ -733,7 +734,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		dst = addr6->s6_addr32[3];
 	}
 
-	rt = ip_route_output_ports(dev_net(dev), NULL,
+	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
 				   dst, tiph->saddr,
 				   0, 0,
 				   IPPROTO_IPV6, RT_TOS(tos),
@@ -851,12 +852,13 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph;
+	struct flowi4 fl4;
 
 	tunnel = netdev_priv(dev);
 	iph = &tunnel->parms.iph;
 
 	if (iph->daddr) {
-		struct rtable *rt = ip_route_output_ports(dev_net(dev), NULL,
+		struct rtable *rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
 							  iph->daddr, iph->saddr,
 							  0, 0,
 							  IPPROTO_IPV6,
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index a4d2dfa..8189960 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -471,6 +471,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 
 	if (rt == NULL) {
 		struct ip_options_rcu *inet_opt;
+		struct flowi4 fl4;
 
 		rcu_read_lock();
 		inet_opt = rcu_dereference(inet->inet_opt);
@@ -485,7 +486,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		 * keep trying until route appears or the connection times
 		 * itself out.
 		 */
-		rt = ip_route_output_ports(sock_net(sk), sk,
+		rt = ip_route_output_ports(sock_net(sk), &fl4, sk,
 					   daddr, inet->inet_saddr,
 					   inet->inet_dport, inet->inet_sport,
 					   sk->sk_protocol, RT_CONN_FLAGS(sk),
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index 55b93dc..b6ff063 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -36,10 +36,11 @@ static void rxrpc_destroy_peer(struct work_struct *work);
 static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 {
 	struct rtable *rt;
+	struct flowi4 fl4;
 
 	peer->if_mtu = 1500;
 
-	rt = ip_route_output_ports(&init_net, NULL,
+	rt = ip_route_output_ports(&init_net, &fl4, NULL,
 				   peer->srx.transport.sin.sin_addr.s_addr, 0,
 				   htons(7000), htons(7001),
 				   IPPROTO_UDP, 0, 0);
-- 
1.7.4.5

