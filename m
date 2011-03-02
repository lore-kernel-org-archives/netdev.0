From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Make output route lookup return rtable directly.
Date: Wed, 02 Mar 2011 14:47:24 -0800 (PST)
Message-ID: <20110302.144724.179916996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755904Ab1CBWqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 17:46:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 29E6D24C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 14:47:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of on the stack.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c        |    7 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c |    3 +-
 drivers/infiniband/hw/cxgb4/cm.c      |    3 +-
 drivers/infiniband/hw/nes/nes_cm.c    |    3 +-
 drivers/net/bonding/bond_main.c       |    6 +-
 drivers/net/cnic.c                    |    7 ++-
 drivers/net/pptp.c                    |    8 +-
 drivers/scsi/cxgbi/libcxgbi.c         |    3 +-
 include/net/route.h                   |   58 ++++++++++----------
 net/atm/clip.c                        |    6 +-
 net/bridge/br_netfilter.c             |    9 ++-
 net/dccp/ipv4.c                       |   27 +++++----
 net/ipv4/af_inet.c                    |   30 +++++-----
 net/ipv4/arp.c                        |   19 +++---
 net/ipv4/datagram.c                   |   11 ++--
 net/ipv4/icmp.c                       |   19 ++++--
 net/ipv4/igmp.c                       |   16 +++--
 net/ipv4/inet_connection_sock.c       |    3 +-
 net/ipv4/ip_gre.c                     |   11 ++--
 net/ipv4/ip_output.c                  |    6 +-
 net/ipv4/ipip.c                       |    7 +-
 net/ipv4/ipmr.c                       |    8 +-
 net/ipv4/netfilter.c                  |   12 +++-
 net/ipv4/raw.c                        |    8 ++-
 net/ipv4/route.c                      |  100 ++++++++++++++++-----------------
 net/ipv4/syncookies.c                 |    3 +-
 net/ipv4/tcp_ipv4.c                   |   28 +++++----
 net/ipv4/udp.c                        |    5 +-
 net/ipv4/xfrm4_policy.c               |   12 ++--
 net/ipv6/ip6_tunnel.c                 |   11 ++-
 net/ipv6/sit.c                        |    8 ++-
 net/l2tp/l2tp_ip.c                    |    8 ++-
 net/netfilter/ipvs/ip_vs_xmit.c       |    9 ++-
 net/netfilter/xt_TEE.c                |    3 +-
 net/rxrpc/ar-peer.c                   |    7 +-
 net/sctp/protocol.c                   |    7 +-
 36 files changed, 267 insertions(+), 224 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 8aba0ba..2d74993 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -193,10 +193,11 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	fl.nl_u.ip4_u.saddr = src_ip;
 	fl.oif = addr->bound_dev_if;
 
-	ret = ip_route_output_key(&init_net, &rt, &fl);
-	if (ret)
+	rt = ip_route_output_key(&init_net, &fl);
+	if (IS_ERR(rt)) {
+		ret = PTR_ERR(rt);
 		goto out;
-
+	}
 	src_in->sin_family = AF_INET;
 	src_in->sin_addr.s_addr = rt->rt_src;
 
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index e654285..e0ccbc5 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -354,7 +354,8 @@ static struct rtable *find_route(struct t3cdev *dev, __be32 local_ip,
 			  }
 	};
 
-	if (ip_route_output_flow(&init_net, &rt, &fl, NULL))
+	rt = ip_route_output_flow(&init_net, &fl, NULL);
+	if (IS_ERR(rt))
 		return NULL;
 	return rt;
 }
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 7e0484f..77b0eef 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -331,7 +331,8 @@ static struct rtable *find_route(struct c4iw_dev *dev, __be32 local_ip,
 			  }
 	};
 
-	if (ip_route_output_flow(&init_net, &rt, &fl, NULL))
+	rt = ip_route_output_flow(&init_net, &fl, NULL);
+	if (IS_ERR(rt))
 		return NULL;
 	return rt;
 }
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index ec3aa11..e81599c 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1112,7 +1112,8 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 
 	memset(&fl, 0, sizeof fl);
 	fl.nl_u.ip4_u.daddr = htonl(dst_ip);
-	if (ip_route_output_key(&init_net, &rt, &fl)) {
+	rt = ip_route_output_key(&init_net, &fl);
+	if (IS_ERR(rt)) {
 		printk(KERN_ERR "%s: ip_route_output_key failed for 0x%08X\n",
 				__func__, dst_ip);
 		return rc;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 584f97b..0592e6d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2681,7 +2681,7 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 
 static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
-	int i, vlan_id, rv;
+	int i, vlan_id;
 	__be32 *targets = bond->params.arp_targets;
 	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
@@ -2708,8 +2708,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		fl.fl4_dst = targets[i];
 		fl.fl4_tos = RTO_ONLINK;
 
-		rv = ip_route_output_key(dev_net(bond->dev), &rt, &fl);
-		if (rv) {
+		rt = ip_route_output_key(dev_net(bond->dev), &fl);
+		if (IS_ERR(rt)) {
 			if (net_ratelimit()) {
 				pr_warning("%s: no route to arp_ip_target %pI4\n",
 					   bond->dev->name, &fl.fl4_dst);
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 5274de3..25f0888 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3397,9 +3397,12 @@ static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
 	memset(&fl, 0, sizeof(fl));
 	fl.nl_u.ip4_u.daddr = dst_addr->sin_addr.s_addr;
 
-	err = ip_route_output_key(&init_net, &rt, &fl);
-	if (!err)
+	rt = ip_route_output_key(&init_net, &fl);
+	err = 0;
+	if (!IS_ERR(rt))
 		*dst = &rt->dst;
+	else
+		err = PTR_ERR(rt);
 	return err;
 #else
 	return -ENETUNREACH;
diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index 164cfad..1af549c 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -175,7 +175,6 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	struct pptp_opt *opt = &po->proto.pptp;
 	struct pptp_gre_header *hdr;
 	unsigned int header_len = sizeof(*hdr);
-	int err = 0;
 	int islcp;
 	int len;
 	unsigned char *data;
@@ -198,8 +197,8 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 					.saddr = opt->src_addr.sin_addr.s_addr,
 					.tos = RT_TOS(0) } },
 			.proto = IPPROTO_GRE };
-		err = ip_route_output_key(&init_net, &rt, &fl);
-		if (err)
+		rt = ip_route_output_key(&init_net, &fl);
+		if (IS_ERR(rt))
 			goto tx_error;
 	}
 	tdev = rt->dst.dev;
@@ -477,7 +476,8 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 					.tos = RT_CONN_FLAGS(sk) } },
 			.proto = IPPROTO_GRE };
 		security_sk_classify_flow(sk, &fl);
-		if (ip_route_output_key(&init_net, &rt, &fl)) {
+		rt = ip_route_output_key(&init_net, &fl);
+		if (IS_ERR(rt)) {
 			error = -EHOSTUNREACH;
 			goto end;
 		}
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 261aa81..889199a 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -470,7 +470,8 @@ static struct rtable *find_route_ipv4(__be32 saddr, __be32 daddr,
 			}
 	};
 
-	if (ip_route_output_flow(&init_net, &rt, &fl, NULL))
+	rt = ip_route_output_flow(&init_net, &fl, NULL);
+	if (IS_ERR(rt))
 		return NULL;
 
 	return rt;
diff --git a/include/net/route.h b/include/net/route.h
index 707cfc8..088a186 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -118,9 +118,10 @@ extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
 extern void		rt_cache_flush_batch(struct net *net);
-extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
-extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
-extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk);
+extern struct rtable *__ip_route_output_key(struct net *, const struct flowi *flp);
+extern struct rtable *ip_route_output_key(struct net *, struct flowi *flp);
+extern struct rtable *ip_route_output_flow(struct net *, struct flowi *flp,
+					   struct sock *sk);
 extern struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig);
 
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
@@ -166,10 +167,10 @@ static inline char rt_tos2priority(u8 tos)
 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
 }
 
-static inline int ip_route_connect(struct rtable **rp, __be32 dst,
-				   __be32 src, u32 tos, int oif, u8 protocol,
-				   __be16 sport, __be16 dport, struct sock *sk,
-				   bool can_sleep)
+static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
+					      int oif, u8 protocol,
+					      __be16 sport, __be16 dport,
+					      struct sock *sk, bool can_sleep)
 {
 	struct flowi fl = { .oif = oif,
 			    .mark = sk->sk_mark,
@@ -179,8 +180,8 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 			    .proto = protocol,
 			    .fl_ip_sport = sport,
 			    .fl_ip_dport = dport };
-	int err;
 	struct net *net = sock_net(sk);
+	struct rtable *rt;
 
 	if (inet_sk(sk)->transparent)
 		fl.flags |= FLOWI_FLAG_ANYSRC;
@@ -190,29 +191,29 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 		fl.flags |= FLOWI_FLAG_CAN_SLEEP;
 
 	if (!dst || !src) {
-		err = __ip_route_output_key(net, rp, &fl);
-		if (err)
-			return err;
-		fl.fl4_dst = (*rp)->rt_dst;
-		fl.fl4_src = (*rp)->rt_src;
-		ip_rt_put(*rp);
-		*rp = NULL;
+		rt = __ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
+			return rt;
+		fl.fl4_dst = rt->rt_dst;
+		fl.fl4_src = rt->rt_src;
+		ip_rt_put(rt);
 	}
 	security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(net, rp, &fl, sk);
+	return ip_route_output_flow(net, &fl, sk);
 }
 
-static inline int ip_route_newports(struct rtable **rp, u8 protocol,
-				    __be16 orig_sport, __be16 orig_dport,
-				    __be16 sport, __be16 dport, struct sock *sk)
+static inline struct rtable *ip_route_newports(struct rtable *rt,
+					       u8 protocol, __be16 orig_sport,
+					       __be16 orig_dport, __be16 sport,
+					       __be16 dport, struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi fl = { .oif = (*rp)->fl.oif,
-				    .mark = (*rp)->fl.mark,
-				    .fl4_dst = (*rp)->fl.fl4_dst,
-				    .fl4_src = (*rp)->fl.fl4_src,
-				    .fl4_tos = (*rp)->fl.fl4_tos,
-				    .proto = (*rp)->fl.proto,
+		struct flowi fl = { .oif = rt->fl.oif,
+				    .mark = rt->fl.mark,
+				    .fl4_dst = rt->fl.fl4_dst,
+				    .fl4_src = rt->fl.fl4_src,
+				    .fl4_tos = rt->fl.fl4_tos,
+				    .proto = rt->fl.proto,
 				    .fl_ip_sport = sport,
 				    .fl_ip_dport = dport };
 
@@ -220,12 +221,11 @@ static inline int ip_route_newports(struct rtable **rp, u8 protocol,
 			fl.flags |= FLOWI_FLAG_ANYSRC;
 		if (protocol == IPPROTO_TCP)
 			fl.flags |= FLOWI_FLAG_PRECOW_METRICS;
-		ip_rt_put(*rp);
-		*rp = NULL;
+		ip_rt_put(rt);
 		security_sk_classify_flow(sk, &fl);
-		return ip_route_output_flow(sock_net(sk), rp, &fl, sk);
+		return ip_route_output_flow(sock_net(sk), &fl, sk);
 	}
-	return 0;
+	return rt;
 }
 
 extern void rt_bind_peer(struct rtable *rt, int create);
diff --git a/net/atm/clip.c b/net/atm/clip.c
index d257da5..810a129 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -520,9 +520,9 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 		unlink_clip_vcc(clip_vcc);
 		return 0;
 	}
-	error = ip_route_output_key(&init_net, &rt, &fl);
-	if (error)
-		return error;
+	rt = ip_route_output_key(&init_net, &fl);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
 	neigh = __neigh_lookup(&clip_tbl, &ip, rt->dst.dev, 1);
 	ip_rt_put(rt);
 	if (!neigh)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4b5b66d..45b57b1 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -428,14 +428,15 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
+			rt = ip_route_output_key(dev_net(dev), &fl);
+			if (!IS_ERR(rt)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
 				 *   require ip_forwarding. */
-				if (((struct dst_entry *)rt)->dev == dev) {
-					skb_dst_set(skb, (struct dst_entry *)rt);
+				if (rt->dst.dev == dev) {
+					skb_dst_set(skb, &rt->dst);
 					goto bridged_dnat;
 				}
-				dst_release((struct dst_entry *)rt);
+				ip_rt_put(rt);
 			}
 free_skb:
 			kfree_skb(skb);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a8ff955..7882377 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -46,7 +46,6 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	__be16 orig_sport, orig_dport;
 	struct rtable *rt;
 	__be32 daddr, nexthop;
-	int tmp;
 	int err;
 
 	dp->dccps_role = DCCP_ROLE_CLIENT;
@@ -66,12 +65,12 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	orig_sport = inet->inet_sport;
 	orig_dport = usin->sin_port;
-	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
-			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
-			       IPPROTO_DCCP,
-			       orig_sport, orig_dport, sk, true);
-	if (tmp < 0)
-		return tmp;
+	rt = ip_route_connect(nexthop, inet->inet_saddr,
+			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
+			      IPPROTO_DCCP,
+			      orig_sport, orig_dport, sk, true);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
 
 	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
 		ip_rt_put(rt);
@@ -102,12 +101,13 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err != 0)
 		goto failure;
 
-	err = ip_route_newports(&rt, IPPROTO_DCCP,
-				orig_sport, orig_dport,
-				inet->inet_sport, inet->inet_dport, sk);
-	if (err != 0)
+	rt = ip_route_newports(rt, IPPROTO_DCCP,
+			       orig_sport, orig_dport,
+			       inet->inet_sport, inet->inet_dport, sk);
+	if (IS_ERR(rt)) {
+		rt = NULL;
 		goto failure;
-
+	}
 	/* OK, now commit destination to socket.  */
 	sk_setup_caps(sk, &rt->dst);
 
@@ -475,7 +475,8 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 			  };
 
 	security_skb_classify_flow(skb, &fl);
-	if (ip_route_output_flow(net, &rt, &fl, sk)) {
+	rt = ip_route_output_flow(net, &fl, sk);
+	if (IS_ERR(rt)) {
 		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 44513bb..35a5020 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1101,23 +1101,20 @@ int sysctl_ip_dynaddr __read_mostly;
 static int inet_sk_reselect_saddr(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	int err;
-	struct rtable *rt;
 	__be32 old_saddr = inet->inet_saddr;
-	__be32 new_saddr;
 	__be32 daddr = inet->inet_daddr;
+	struct rtable *rt;
+	__be32 new_saddr;
 
 	if (inet->opt && inet->opt->srr)
 		daddr = inet->opt->faddr;
 
 	/* Query new route. */
-	err = ip_route_connect(&rt, daddr, 0,
-			       RT_CONN_FLAGS(sk),
-			       sk->sk_bound_dev_if,
-			       sk->sk_protocol,
-			       inet->inet_sport, inet->inet_dport, sk, false);
-	if (err)
-		return err;
+	rt = ip_route_connect(daddr, 0, RT_CONN_FLAGS(sk),
+			      sk->sk_bound_dev_if, sk->sk_protocol,
+			      inet->inet_sport, inet->inet_dport, sk, false);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
 
 	sk_setup_caps(sk, &rt->dst);
 
@@ -1160,7 +1157,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	daddr = inet->inet_daddr;
 	if (inet->opt && inet->opt->srr)
 		daddr = inet->opt->faddr;
-{
+	{
 	struct flowi fl = {
 		.oif = sk->sk_bound_dev_if,
 		.mark = sk->sk_mark,
@@ -1174,11 +1171,14 @@ int inet_sk_rebuild_header(struct sock *sk)
 	};
 
 	security_sk_classify_flow(sk, &fl);
-	err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk);
-}
-	if (!err)
+	rt = ip_route_output_flow(sock_net(sk), &fl, sk);
+	}
+	if (!IS_ERR(rt)) {
+		err = 0;
 		sk_setup_caps(sk, &rt->dst);
-	else {
+	} else {
+		err = PTR_ERR(rt);
+
 		/* Routing failed... */
 		sk->sk_route_caps = 0;
 		/*
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7927589..fa9988d 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -440,7 +440,8 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 	/*unsigned long now; */
 	struct net *net = dev_net(dev);
 
-	if (ip_route_output_key(net, &rt, &fl) < 0)
+	rt = ip_route_output_key(net, &fl);
+	if (IS_ERR(rt))
 		return 1;
 	if (rt->dst.dev != dev) {
 		NET_INC_STATS_BH(net, LINUX_MIB_ARPFILTER);
@@ -1063,10 +1064,10 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	if (dev == NULL) {
 		struct flowi fl = { .fl4_dst = ip,
 				    .fl4_tos = RTO_ONLINK };
-		struct rtable *rt;
-		err = ip_route_output_key(net, &rt, &fl);
-		if (err != 0)
-			return err;
+		struct rtable *rt = ip_route_output_key(net, &fl);
+
+		if (IS_ERR(rt))
+			return PTR_ERR(rt);
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
 		if (!dev)
@@ -1177,7 +1178,6 @@ static int arp_req_delete_public(struct net *net, struct arpreq *r,
 static int arp_req_delete(struct net *net, struct arpreq *r,
 			  struct net_device *dev)
 {
-	int err;
 	__be32 ip;
 
 	if (r->arp_flags & ATF_PUBL)
@@ -1187,10 +1187,9 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 	if (dev == NULL) {
 		struct flowi fl = { .fl4_dst = ip,
 				    .fl4_tos = RTO_ONLINK };
-		struct rtable *rt;
-		err = ip_route_output_key(net, &rt, &fl);
-		if (err != 0)
-			return err;
+		struct rtable *rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
+			return PTR_ERR(rt);
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
 		if (!dev)
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index eaee1ed..85bd24c 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -46,11 +46,12 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		if (!saddr)
 			saddr = inet->mc_addr;
 	}
-	err = ip_route_connect(&rt, usin->sin_addr.s_addr, saddr,
-			       RT_CONN_FLAGS(sk), oif,
-			       sk->sk_protocol,
-			       inet->inet_sport, usin->sin_port, sk, true);
-	if (err) {
+	rt = ip_route_connect(usin->sin_addr.s_addr, saddr,
+			      RT_CONN_FLAGS(sk), oif,
+			      sk->sk_protocol,
+			      inet->inet_sport, usin->sin_port, sk, true);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 		return err;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c23bd8c..994a785 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -358,7 +358,8 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 				    .fl4_tos = RT_TOS(ip_hdr(skb)->tos),
 				    .proto = IPPROTO_ICMP };
 		security_skb_classify_flow(skb, &fl);
-		if (ip_route_output_key(net, &rt, &fl))
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
 			goto out_unlock;
 	}
 	if (icmpv4_xrlim_allow(net, rt, icmp_param->data.icmph.type,
@@ -388,9 +389,9 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 	int err;
 
 	security_skb_classify_flow(skb_in, &fl);
-	err = __ip_route_output_key(net, &rt, &fl);
-	if (err)
-		return ERR_PTR(err);
+	rt = __ip_route_output_key(net, &fl);
+	if (IS_ERR(rt))
+		return rt;
 
 	/* No need to clone since we're just using its address. */
 	rt2 = rt;
@@ -412,15 +413,19 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 		goto relookup_failed;
 
 	if (inet_addr_type(net, fl.fl4_src) == RTN_LOCAL) {
-		err = __ip_route_output_key(net, &rt2, &fl);
+		rt2 = __ip_route_output_key(net, &fl);
+		if (IS_ERR(rt2))
+			err = PTR_ERR(rt2);
 	} else {
 		struct flowi fl2 = {};
 		unsigned long orefdst;
 
 		fl2.fl4_dst = fl.fl4_src;
-		err = ip_route_output_key(net, &rt2, &fl2);
-		if (err)
+		rt2 = ip_route_output_key(net, &fl2);
+		if (IS_ERR(rt2)) {
+			err = PTR_ERR(rt2);
 			goto relookup_failed;
+		}
 		/* Ugh! */
 		orefdst = skb_in->_skb_refdst; /* save old refdst */
 		err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index e0e77e2..44ba906 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -325,7 +325,8 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 		struct flowi fl = { .oif = dev->ifindex,
 				    .fl4_dst = IGMPV3_ALL_MCR,
 				    .proto = IPPROTO_IGMP };
-		if (ip_route_output_key(net, &rt, &fl)) {
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt)) {
 			kfree_skb(skb);
 			return NULL;
 		}
@@ -670,7 +671,8 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 		struct flowi fl = { .oif = dev->ifindex,
 				    .fl4_dst = dst,
 				    .proto = IPPROTO_IGMP };
-		if (ip_route_output_key(net, &rt, &fl))
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
 			return -1;
 	}
 	if (rt->rt_src == 0) {
@@ -1440,7 +1442,6 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 {
 	struct flowi fl = { .fl4_dst = imr->imr_multiaddr.s_addr };
-	struct rtable *rt;
 	struct net_device *dev = NULL;
 	struct in_device *idev = NULL;
 
@@ -1454,9 +1455,12 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 			return NULL;
 	}
 
-	if (!dev && !ip_route_output_key(net, &rt, &fl)) {
-		dev = rt->dst.dev;
-		ip_rt_put(rt);
+	if (!dev) {
+		struct rtable *rt = ip_route_output_key(net, &fl);
+		if (!IS_ERR(rt)) {
+			dev = rt->dst.dev;
+			ip_rt_put(rt);
+		}
 	}
 	if (dev) {
 		imr->imr_ifindex = dev->ifindex;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7f85d4a..e4e301a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -369,7 +369,8 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct net *net = sock_net(sk);
 
 	security_req_classify_flow(req, &fl);
-	if (ip_route_output_flow(net, &rt, &fl, sk))
+	rt = ip_route_output_flow(net, &fl, sk);
+	if (IS_ERR(rt))
 		goto no_route;
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto route_err;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6613edf..f9af98d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -778,7 +778,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			.proto = IPPROTO_GRE,
 			.fl_gre_key = tunnel->parms.o_key
 		};
-		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
+		rt = ip_route_output_key(dev_net(dev), &fl);
+		if (IS_ERR(rt)) {
 			dev->stats.tx_carrier_errors++;
 			goto tx_error;
 		}
@@ -953,9 +954,9 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 			.proto = IPPROTO_GRE,
 			.fl_gre_key = tunnel->parms.o_key
 		};
-		struct rtable *rt;
+		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
 
-		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
+		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
 		}
@@ -1215,9 +1216,9 @@ static int ipgre_open(struct net_device *dev)
 			.proto = IPPROTO_GRE,
 			.fl_gre_key = t->parms.o_key
 		};
-		struct rtable *rt;
+		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
 
-		if (ip_route_output_key(dev_net(dev), &rt, &fl))
+		if (IS_ERR(rt))
 			return -EADDRNOTAVAIL;
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 33316b3..171f483 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -355,7 +355,8 @@ int ip_queue_xmit(struct sk_buff *skb)
 			 * itself out.
 			 */
 			security_sk_classify_flow(sk, &fl);
-			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk))
+			rt = ip_route_output_flow(sock_net(sk), &fl, sk);
+			if (IS_ERR(rt))
 				goto no_route;
 		}
 		sk_setup_caps(sk, &rt->dst);
@@ -1489,7 +1490,8 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 				    .proto = sk->sk_protocol,
 				    .flags = ip_reply_arg_flowi_flags(arg) };
 		security_skb_classify_flow(skb, &fl);
-		if (ip_route_output_key(sock_net(sk), &rt, &fl))
+		rt = ip_route_output_key(sock_net(sk), &fl);
+		if (IS_ERR(rt))
 			return;
 	}
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 988f52f..e1e1757 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -469,7 +469,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			.proto = IPPROTO_IPIP
 		};
 
-		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
+		rt = ip_route_output_key(dev_net(dev), &fl);
+		if (IS_ERR(rt)) {
 			dev->stats.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
@@ -590,9 +591,9 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 			.fl4_tos = RT_TOS(iph->tos),
 			.proto = IPPROTO_IPIP
 		};
-		struct rtable *rt;
+		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
 
-		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
+		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
 		}
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 8b65a12..26ca2f2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1618,8 +1618,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 			.fl4_tos = RT_TOS(iph->tos),
 			.proto = IPPROTO_IPIP
 		};
-
-		if (ip_route_output_key(net, &rt, &fl))
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
 			goto out_free;
 		encap = sizeof(struct iphdr);
 	} else {
@@ -1629,8 +1629,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 			.fl4_tos = RT_TOS(iph->tos),
 			.proto = IPPROTO_IPIP
 		};
-
-		if (ip_route_output_key(net, &rt, &fl))
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
 			goto out_free;
 	}
 
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 9770bb4..67bf709 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -38,7 +38,8 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 		fl.mark = skb->mark;
 		fl.flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
-		if (ip_route_output_key(net, &rt, &fl) != 0)
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
 			return -1;
 
 		/* Drop old route. */
@@ -48,7 +49,8 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
 		fl.fl4_dst = iph->saddr;
-		if (ip_route_output_key(net, &rt, &fl) != 0)
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
 			return -1;
 
 		orefdst = skb->_skb_refdst;
@@ -221,7 +223,11 @@ static __sum16 nf_ip_checksum_partial(struct sk_buff *skb, unsigned int hook,
 
 static int nf_ip_route(struct dst_entry **dst, struct flowi *fl)
 {
-	return ip_route_output_key(&init_net, (struct rtable **)dst, fl);
+	struct rtable *rt = ip_route_output_key(&init_net, fl);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
+	*dst = &rt->dst;
+	return 0;
 }
 
 static const struct nf_afinfo nf_ip_afinfo = {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index d7a2d1e..467d570 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -564,10 +564,12 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk);
+		rt = ip_route_output_flow(sock_net(sk), &fl, sk);
+		if (IS_ERR(rt)) {
+			err = PTR_ERR(rt);
+			goto done;
+		}
 	}
-	if (err)
-		goto done;
 
 	err = -EACCES;
 	if (rt->rt_flags & RTCF_BROADCAST && !sock_flag(sk, SOCK_BROADCAST))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 63d3700..5090e95 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1014,8 +1014,8 @@ static int slow_chain_length(const struct rtable *head)
 	return length >> FRACT_BITS;
 }
 
-static int rt_intern_hash(unsigned hash, struct rtable *rt,
-			  struct rtable **rp, struct sk_buff *skb, int ifindex)
+static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
+				     struct sk_buff *skb, int ifindex)
 {
 	struct rtable	*rth, *cand;
 	struct rtable __rcu **rthp, **candp;
@@ -1056,7 +1056,7 @@ restart:
 					printk(KERN_WARNING
 					    "Neighbour table failure & not caching routes.\n");
 				ip_rt_put(rt);
-				return err;
+				return ERR_PTR(err);
 			}
 		}
 
@@ -1093,11 +1093,9 @@ restart:
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
 			rt_drop(rt);
-			if (rp)
-				*rp = rth;
-			else
+			if (skb)
 				skb_dst_set(skb, &rth->dst);
-			return 0;
+			return rth;
 		}
 
 		if (!atomic_read(&rth->dst.__refcnt)) {
@@ -1154,7 +1152,7 @@ restart:
 
 			if (err != -ENOBUFS) {
 				rt_drop(rt);
-				return err;
+				return ERR_PTR(err);
 			}
 
 			/* Neighbour tables are full and nothing
@@ -1175,7 +1173,7 @@ restart:
 			if (net_ratelimit())
 				printk(KERN_WARNING "ipv4: Neighbour table overflow.\n");
 			rt_drop(rt);
-			return -ENOBUFS;
+			return ERR_PTR(-ENOBUFS);
 		}
 	}
 
@@ -1201,11 +1199,9 @@ restart:
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 
 skip_hashing:
-	if (rp)
-		*rp = rt;
-	else
+	if (skb)
 		skb_dst_set(skb, &rt->dst);
-	return 0;
+	return rt;
 }
 
 static atomic_t __rt_peer_genid = ATOMIC_INIT(0);
@@ -1896,7 +1892,10 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	RT_CACHE_STAT_INC(in_slow_mc);
 
 	hash = rt_hash(daddr, saddr, dev->ifindex, rt_genid(dev_net(dev)));
-	return rt_intern_hash(hash, rth, NULL, skb, dev->ifindex);
+	rth = rt_intern_hash(hash, rth, skb, dev->ifindex);
+	err = 0;
+	if (IS_ERR(rth))
+		err = PTR_ERR(rth);
 
 e_nobufs:
 	return -ENOBUFS;
@@ -2051,7 +2050,10 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	/* put it into the cache */
 	hash = rt_hash(daddr, saddr, fl->iif,
 		       rt_genid(dev_net(rth->dst.dev)));
-	return rt_intern_hash(hash, rth, NULL, skb, fl->iif);
+	rth = rt_intern_hash(hash, rth, skb, fl->iif);
+	if (IS_ERR(rth))
+		return PTR_ERR(rth);
+	return 0;
 }
 
 /*
@@ -2194,7 +2196,10 @@ local_input:
 	}
 	rth->rt_type	= res.type;
 	hash = rt_hash(daddr, saddr, fl.iif, rt_genid(net));
-	err = rt_intern_hash(hash, rth, NULL, skb, fl.iif);
+	rth = rt_intern_hash(hash, rth, skb, fl.iif);
+	err = 0;
+	if (IS_ERR(rth))
+		err = PTR_ERR(rth);
 	goto out;
 
 no_route:
@@ -2422,8 +2427,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  * called with rcu_read_lock();
  */
 
-static int ip_route_output_slow(struct net *net, struct rtable **rp,
-				const struct flowi *oldflp)
+static struct rtable *ip_route_output_slow(struct net *net,
+					   const struct flowi *oldflp)
 {
 	u32 tos	= RT_FL_TOS(oldflp);
 	struct flowi fl = { .fl4_dst = oldflp->fl4_dst,
@@ -2438,8 +2443,6 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	unsigned int flags = 0;
 	struct net_device *dev_out = NULL;
 	struct rtable *rth;
-	int err;
-
 
 	res.fi		= NULL;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
@@ -2448,7 +2451,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 
 	rcu_read_lock();
 	if (oldflp->fl4_src) {
-		err = -EINVAL;
+		rth = ERR_PTR(-EINVAL);
 		if (ipv4_is_multicast(oldflp->fl4_src) ||
 		    ipv4_is_lbcast(oldflp->fl4_src) ||
 		    ipv4_is_zeronet(oldflp->fl4_src))
@@ -2499,13 +2502,13 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 
 	if (oldflp->oif) {
 		dev_out = dev_get_by_index_rcu(net, oldflp->oif);
-		err = -ENODEV;
+		rth = ERR_PTR(-ENODEV);
 		if (dev_out == NULL)
 			goto out;
 
 		/* RACE: Check return value of inet_select_addr instead. */
 		if (!(dev_out->flags & IFF_UP) || !__in_dev_get_rcu(dev_out)) {
-			err = -ENETUNREACH;
+			rth = ERR_PTR(-ENETUNREACH);
 			goto out;
 		}
 		if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
@@ -2563,7 +2566,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 			res.type = RTN_UNICAST;
 			goto make_route;
 		}
-		err = -ENETUNREACH;
+		rth = ERR_PTR(-ENETUNREACH);
 		goto out;
 	}
 
@@ -2598,23 +2601,20 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 
 make_route:
 	rth = __mkroute_output(&res, &fl, oldflp, dev_out, flags);
-	if (IS_ERR(rth))
-		err = PTR_ERR(rth);
-	else {
+	if (!IS_ERR(rth)) {
 		unsigned int hash;
 
 		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif,
 			       rt_genid(dev_net(dev_out)));
-		err = rt_intern_hash(hash, rth, rp, NULL, oldflp->oif);
+		rth = rt_intern_hash(hash, rth, NULL, oldflp->oif);
 	}
 
 out:
 	rcu_read_unlock();
-	return err;
+	return rth;
 }
 
-int __ip_route_output_key(struct net *net, struct rtable **rp,
-			  const struct flowi *flp)
+struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
 {
 	struct rtable *rth;
 	unsigned int hash;
@@ -2639,15 +2639,14 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
-			*rp = rth;
-			return 0;
+			return rth;
 		}
 		RT_CACHE_STAT_INC(out_hlist_search);
 	}
 	rcu_read_unlock_bh();
 
 slow_output:
-	return ip_route_output_slow(net, rp, flp);
+	return ip_route_output_slow(net, flp);
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
@@ -2717,34 +2716,29 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 	return rt ? &rt->dst : ERR_PTR(-ENOMEM);
 }
 
-int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
-			 struct sock *sk)
+struct rtable *ip_route_output_flow(struct net *net, struct flowi *flp,
+				    struct sock *sk)
 {
-	int err;
+	struct rtable *rt = __ip_route_output_key(net, flp);
 
-	if ((err = __ip_route_output_key(net, rp, flp)) != 0)
-		return err;
+	if (IS_ERR(rt))
+		return rt;
 
 	if (flp->proto) {
 		if (!flp->fl4_src)
-			flp->fl4_src = (*rp)->rt_src;
+			flp->fl4_src = rt->rt_src;
 		if (!flp->fl4_dst)
-			flp->fl4_dst = (*rp)->rt_dst;
-		*rp = (struct rtable *) xfrm_lookup(net, &(*rp)->dst, flp, sk, 0);
-		if (IS_ERR(*rp)) {
-			err = PTR_ERR(*rp);
-			*rp = NULL;
-			return err;
-		}
+			flp->fl4_dst = rt->rt_dst;
+		rt = (struct rtable *) xfrm_lookup(net, &rt->dst, flp, sk, 0);
 	}
 
-	return 0;
+	return rt;
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-int ip_route_output_key(struct net *net, struct rtable **rp, struct flowi *flp)
+struct rtable *ip_route_output_key(struct net *net, struct flowi *flp)
 {
-	return ip_route_output_flow(net, rp, flp, NULL);
+	return ip_route_output_flow(net, flp, NULL);
 }
 EXPORT_SYMBOL(ip_route_output_key);
 
@@ -2915,7 +2909,11 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 			.oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
 			.mark = mark,
 		};
-		err = ip_route_output_key(net, &rt, &fl);
+		rt = ip_route_output_key(net, &fl);
+
+		err = 0;
+		if (IS_ERR(rt))
+			err = PTR_ERR(rt);
 	}
 
 	if (err)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4751920..0ad6ddf 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -355,7 +355,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 				    .fl_ip_sport = th->dest,
 				    .fl_ip_dport = th->source };
 		security_req_classify_flow(req, &fl);
-		if (ip_route_output_key(sock_net(sk), &rt, &fl)) {
+		rt = ip_route_output_key(sock_net(sk), &fl);
+		if (IS_ERR(rt)) {
 			reqsk_free(req);
 			goto out;
 		}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 05bc6d9..f7e6c2c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -152,7 +152,6 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	__be16 orig_sport, orig_dport;
 	struct rtable *rt;
 	__be32 daddr, nexthop;
-	int tmp;
 	int err;
 
 	if (addr_len < sizeof(struct sockaddr_in))
@@ -170,14 +169,15 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	orig_sport = inet->inet_sport;
 	orig_dport = usin->sin_port;
-	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
-			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
-			       IPPROTO_TCP,
-			       orig_sport, orig_dport, sk, true);
-	if (tmp < 0) {
-		if (tmp == -ENETUNREACH)
+	rt = ip_route_connect(nexthop, inet->inet_saddr,
+			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
+			      IPPROTO_TCP,
+			      orig_sport, orig_dport, sk, true);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		if (err == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
-		return tmp;
+		return err;
 	}
 
 	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
@@ -236,12 +236,14 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err)
 		goto failure;
 
-	err = ip_route_newports(&rt, IPPROTO_TCP,
-				orig_sport, orig_dport,
-				inet->inet_sport, inet->inet_dport, sk);
-	if (err)
+	rt = ip_route_newports(rt, IPPROTO_TCP,
+			       orig_sport, orig_dport,
+			       inet->inet_sport, inet->inet_dport, sk);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		rt = NULL;
 		goto failure;
-
+	}
 	/* OK, now commit destination to socket.  */
 	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ed9a5b7..95e0c2c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -922,8 +922,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		struct net *net = sock_net(sk);
 
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(net, &rt, &fl, sk);
-		if (err) {
+		rt = ip_route_output_flow(net, &fl, sk);
+		if (IS_ERR(rt)) {
+			err = PTR_ERR(rt);
 			if (err == -ENETUNREACH)
 				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 			goto out;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 5f0f058..45b8214 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -26,18 +26,16 @@ static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
 		.fl4_dst = daddr->a4,
 		.fl4_tos = tos,
 	};
-	struct dst_entry *dst;
 	struct rtable *rt;
-	int err;
 
 	if (saddr)
 		fl.fl4_src = saddr->a4;
 
-	err = __ip_route_output_key(net, &rt, &fl);
-	dst = &rt->dst;
-	if (err)
-		dst = ERR_PTR(err);
-	return dst;
+	rt = __ip_route_output_key(net, &fl);
+	if (!IS_ERR(rt))
+		return &rt->dst;
+
+	return ERR_CAST(rt);
 }
 
 static int xfrm4_get_saddr(struct net *net,
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index da43038..02730ef 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -581,7 +581,8 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	fl.fl4_dst = eiph->saddr;
 	fl.fl4_tos = RT_TOS(eiph->tos);
 	fl.proto = IPPROTO_IPIP;
-	if (ip_route_output_key(dev_net(skb->dev), &rt, &fl))
+	rt = ip_route_output_key(dev_net(skb->dev), &fl);
+	if (IS_ERR(rt))
 		goto out;
 
 	skb2->dev = rt->dst.dev;
@@ -593,12 +594,14 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		fl.fl4_dst = eiph->daddr;
 		fl.fl4_src = eiph->saddr;
 		fl.fl4_tos = eiph->tos;
-		if (ip_route_output_key(dev_net(skb->dev), &rt, &fl) ||
+		rt = ip_route_output_key(dev_net(skb->dev), &fl);
+		if (IS_ERR(rt) ||
 		    rt->dst.dev->type != ARPHRD_TUNNEL) {
-			ip_rt_put(rt);
+			if (!IS_ERR(rt))
+				ip_rt_put(rt);
 			goto out;
 		}
-		skb_dst_set(skb2, (struct dst_entry *)rt);
+		skb_dst_set(skb2, &rt->dst);
 	} else {
 		ip_rt_put(rt);
 		if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos,
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b1599a3..b8c8adb 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -738,7 +738,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 				    .fl4_tos = RT_TOS(tos),
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
-		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
+		rt = ip_route_output_key(dev_net(dev), &fl);
+		if (IS_ERR(rt)) {
 			dev->stats.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
@@ -862,8 +863,9 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 				    .fl4_tos = RT_TOS(iph->tos),
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
-		struct rtable *rt;
-		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
+		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
+
+		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
 		}
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 5381ceb..2a698ff 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -320,11 +320,12 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	if (ipv4_is_multicast(lsa->l2tp_addr.s_addr))
 		goto out;
 
-	rc = ip_route_connect(&rt, lsa->l2tp_addr.s_addr, saddr,
+	rt = ip_route_connect(lsa->l2tp_addr.s_addr, saddr,
 			      RT_CONN_FLAGS(sk), oif,
 			      IPPROTO_L2TP,
 			      0, 0, sk, true);
-	if (rc) {
+	if (IS_ERR(rt)) {
+		rc = PTR_ERR(rt);
 		if (rc == -ENETUNREACH)
 			IP_INC_STATS_BH(&init_net, IPSTATS_MIB_OUTNOROUTES);
 		goto out;
@@ -489,7 +490,8 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 			 * itself out.
 			 */
 			security_sk_classify_flow(sk, &fl);
-			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk))
+			rt = ip_route_output_flow(sock_net(sk), &fl, sk);
+			if (IS_ERR(rt))
 				goto no_route;
 		}
 		sk_setup_caps(sk, &rt->dst);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6264219..878f6dd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -103,7 +103,8 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 				.fl4_tos = rtos,
 			};
 
-			if (ip_route_output_key(net, &rt, &fl)) {
+			rt = ip_route_output_key(net, &fl);
+			if (IS_ERR(rt)) {
 				spin_unlock(&dest->dst_lock);
 				IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
 					     &dest->addr.ip);
@@ -121,7 +122,8 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 			.fl4_tos = rtos,
 		};
 
-		if (ip_route_output_key(net, &rt, &fl)) {
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt)) {
 			IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
 				     &daddr);
 			return NULL;
@@ -180,7 +182,8 @@ __ip_vs_reroute_locally(struct sk_buff *skb)
 			.mark = skb->mark,
 		};
 
-		if (ip_route_output_key(net, &rt, &fl))
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt))
 			return 0;
 		if (!(rt->rt_flags & RTCF_LOCAL)) {
 			ip_rt_put(rt);
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 5128a6c..624725b 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -73,7 +73,8 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	fl.fl4_dst = info->gw.ip;
 	fl.fl4_tos = RT_TOS(iph->tos);
 	fl.fl4_scope = RT_SCOPE_UNIVERSE;
-	if (ip_route_output_key(net, &rt, &fl) != 0)
+	rt = ip_route_output_key(net, &fl);
+	if (IS_ERR(rt))
 		return false;
 
 	skb_dst_drop(skb);
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index a53fb25..3620c56 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -37,7 +37,6 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 {
 	struct rtable *rt;
 	struct flowi fl;
-	int ret;
 
 	peer->if_mtu = 1500;
 
@@ -58,9 +57,9 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 		BUG();
 	}
 
-	ret = ip_route_output_key(&init_net, &rt, &fl);
-	if (ret < 0) {
-		_leave(" [route err %d]", ret);
+	rt = ip_route_output_key(&init_net, &fl);
+	if (IS_ERR(rt)) {
+		_leave(" [route err %ld]", PTR_ERR(rt));
 		return;
 	}
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index e58f947..4e55e6c 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -491,9 +491,9 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 	SCTP_DEBUG_PRINTK("%s: DST:%pI4, SRC:%pI4 - ",
 			  __func__, &fl.fl4_dst, &fl.fl4_src);
 
-	if (!ip_route_output_key(&init_net, &rt, &fl)) {
+	rt = ip_route_output_key(&init_net, &fl);
+	if (!IS_ERR(rt))
 		dst = &rt->dst;
-	}
 
 	/* If there is no association or if a source address is passed, no
 	 * more validation is required.
@@ -535,7 +535,8 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 		    (AF_INET == laddr->a.sa.sa_family)) {
 			fl.fl4_src = laddr->a.v4.sin_addr.s_addr;
 			fl.fl_ip_sport = laddr->a.v4.sin_port;
-			if (!ip_route_output_key(&init_net, &rt, &fl)) {
+			rt = ip_route_output_key(&init_net, &fl);
+			if (!IS_ERR(rt)) {
 				dst = &rt->dst;
 				goto out_unlock;
 			}
-- 
1.7.4.1

