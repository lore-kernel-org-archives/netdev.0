From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/25] ipv4: Create and use route lookup helpers.
Date: Sat, 12 Mar 2011 15:24:09 -0800 (PST)
Message-ID: <20110312.152409.112587737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756179Ab1CLXXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:23:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 48D4424C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:24:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The idea here is this minimizes the number of places one has to edit
in order to make changes to how flows are defined and used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c        |    8 +-----
 drivers/infiniband/hw/cxgb3/iwch_cm.c |   21 +++-----------
 drivers/infiniband/hw/cxgb4/cm.c      |   21 +++-----------
 drivers/infiniband/hw/nes/nes_cm.c    |    5 +---
 drivers/net/bonding/bond_main.c       |   12 +++-----
 drivers/net/cnic.c                    |   16 +++-------
 drivers/net/pptp.c                    |   45 ++++++++++++------------------
 drivers/scsi/cxgbi/libcxgbi.c         |   20 ++-----------
 include/net/route.h                   |   48 ++++++++++++++++++++++++++++++++
 net/atm/clip.c                        |    4 +--
 net/bridge/br_netfilter.c             |    7 +---
 net/ipv4/af_inet.c                    |   20 +++-----------
 net/ipv4/arp.c                        |   12 ++------
 net/ipv4/igmp.c                       |   34 ++++++++++-------------
 net/ipv4/ip_gre.c                     |   49 +++++++++++---------------------
 net/ipv4/ip_output.c                  |   33 +++++++++-------------
 net/ipv4/ipip.c                       |   36 +++++++++---------------
 net/ipv4/ipmr.c                       |   24 ++++++----------
 net/ipv6/ip6_tunnel.c                 |   19 ++++++-------
 net/ipv6/sit.c                        |   31 +++++++++-----------
 net/l2tp/l2tp_ip.c                    |   30 +++++++-------------
 net/netfilter/ipvs/ip_vs_xmit.c       |   14 +--------
 net/rxrpc/ar-peer.c                   |   23 +++-------------
 23 files changed, 206 insertions(+), 326 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 2d74993..1742f72 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -183,17 +183,11 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 {
 	__be32 src_ip = src_in->sin_addr.s_addr;
 	__be32 dst_ip = dst_in->sin_addr.s_addr;
-	struct flowi fl;
 	struct rtable *rt;
 	struct neighbour *neigh;
 	int ret;
 
-	memset(&fl, 0, sizeof fl);
-	fl.nl_u.ip4_u.daddr = dst_ip;
-	fl.nl_u.ip4_u.saddr = src_ip;
-	fl.oif = addr->bound_dev_if;
-
-	rt = ip_route_output_key(&init_net, &fl);
+	rt = ip_route_output(&init_net, dst_ip, src_ip, 0, addr->bound_dev_if);
 	if (IS_ERR(rt)) {
 		ret = PTR_ERR(rt);
 		goto out;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index e0ccbc5..3216bca 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -338,23 +338,10 @@ static struct rtable *find_route(struct t3cdev *dev, __be32 local_ip,
 				 __be16 peer_port, u8 tos)
 {
 	struct rtable *rt;
-	struct flowi fl = {
-		.oif = 0,
-		.nl_u = {
-			 .ip4_u = {
-				   .daddr = peer_ip,
-				   .saddr = local_ip,
-				   .tos = tos}
-			 },
-		.proto = IPPROTO_TCP,
-		.uli_u = {
-			  .ports = {
-				    .sport = local_port,
-				    .dport = peer_port}
-			  }
-	};
-
-	rt = ip_route_output_flow(&init_net, &fl, NULL);
+
+	rt = ip_route_output_ports(&init_net, NULL, peer_ip, local_ip,
+				   peer_port, local_port, IPPROTO_TCP,
+				   tos, 0);
 	if (IS_ERR(rt))
 		return NULL;
 	return rt;
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 77b0eef..97a876a 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -315,23 +315,10 @@ static struct rtable *find_route(struct c4iw_dev *dev, __be32 local_ip,
 				 __be16 peer_port, u8 tos)
 {
 	struct rtable *rt;
-	struct flowi fl = {
-		.oif = 0,
-		.nl_u = {
-			 .ip4_u = {
-				   .daddr = peer_ip,
-				   .saddr = local_ip,
-				   .tos = tos}
-			 },
-		.proto = IPPROTO_TCP,
-		.uli_u = {
-			  .ports = {
-				    .sport = local_port,
-				    .dport = peer_port}
-			  }
-	};
-
-	rt = ip_route_output_flow(&init_net, &fl, NULL);
+
+	rt = ip_route_output_ports(&init_net, NULL, peer_ip, local_ip,
+				   peer_port, local_port, IPPROTO_TCP,
+				   tos, 0);
 	if (IS_ERR(rt))
 		return NULL;
 	return rt;
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index e81599c..ef32915 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1104,15 +1104,12 @@ static inline int mini_cm_accelerated(struct nes_cm_core *cm_core,
 static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpindex)
 {
 	struct rtable *rt;
-	struct flowi fl;
 	struct neighbour *neigh;
 	int rc = arpindex;
 	struct net_device *netdev;
 	struct nes_adapter *nesadapter = nesvnic->nesdev->nesadapter;
 
-	memset(&fl, 0, sizeof fl);
-	fl.nl_u.ip4_u.daddr = htonl(dst_ip);
-	rt = ip_route_output_key(&init_net, &fl);
+	rt = ip_route_output(&init_net, htonl(dst_ip), 0, 0, 0);
 	if (IS_ERR(rt)) {
 		printk(KERN_ERR "%s: ip_route_output_key failed for 0x%08X\n",
 				__func__, dst_ip);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 68a5ce0..3ad4f50 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2676,7 +2676,6 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 	__be32 *targets = bond->params.arp_targets;
 	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
-	struct flowi fl;
 	struct rtable *rt;
 
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
@@ -2695,15 +2694,12 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		 * determine which VLAN interface would be used, so we
 		 * can tag the ARP with the proper VLAN tag.
 		 */
-		memset(&fl, 0, sizeof(fl));
-		fl.fl4_dst = targets[i];
-		fl.fl4_tos = RTO_ONLINK;
-
-		rt = ip_route_output_key(dev_net(bond->dev), &fl);
+		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
+				     RTO_ONLINK, 0);
 		if (IS_ERR(rt)) {
 			if (net_ratelimit()) {
 				pr_warning("%s: no route to arp_ip_target %pI4\n",
-					   bond->dev->name, &fl.fl4_dst);
+					   bond->dev->name, &targets[i]);
 			}
 			continue;
 		}
@@ -2739,7 +2735,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 
 		if (net_ratelimit()) {
 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
-				   bond->dev->name, &fl.fl4_dst,
+				   bond->dev->name, &targets[i],
 				   rt->dst.dev ? rt->dst.dev->name : "NULL");
 		}
 		ip_rt_put(rt);
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 271a1f0..6583295 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3407,20 +3407,14 @@ static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
 			     struct dst_entry **dst)
 {
 #if defined(CONFIG_INET)
-	struct flowi fl;
-	int err;
 	struct rtable *rt;
 
-	memset(&fl, 0, sizeof(fl));
-	fl.nl_u.ip4_u.daddr = dst_addr->sin_addr.s_addr;
-
-	rt = ip_route_output_key(&init_net, &fl);
-	err = 0;
-	if (!IS_ERR(rt))
+	rt = ip_route_output(&init_net, dst_addr->sin_addr.s_addr, 0, 0, 0);
+	if (!IS_ERR(rt)) {
 		*dst = &rt->dst;
-	else
-		err = PTR_ERR(rt);
-	return err;
+		return 0;
+	}
+	return PTR_ERR(rt);
 #else
 	return -ENETUNREACH;
 #endif
diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index 1af549c..51dfcf8 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -189,18 +189,14 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (sk_pppox(po)->sk_state & PPPOX_DEAD)
 		goto tx_error;
 
-	{
-		struct flowi fl = { .oif = 0,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = opt->dst_addr.sin_addr.s_addr,
-					.saddr = opt->src_addr.sin_addr.s_addr,
-					.tos = RT_TOS(0) } },
-			.proto = IPPROTO_GRE };
-		rt = ip_route_output_key(&init_net, &fl);
-		if (IS_ERR(rt))
-			goto tx_error;
-	}
+	rt = ip_route_output_ports(&init_net, NULL,
+				   opt->dst_addr.sin_addr.s_addr,
+				   opt->src_addr.sin_addr.s_addr,
+				   0, 0, IPPROTO_GRE,
+				   RT_TOS(0), 0);
+	if (IS_ERR(rt))
+		goto tx_error;
+
 	tdev = rt->dst.dev;
 
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(*iph) + sizeof(*hdr) + 2;
@@ -467,22 +463,17 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	po->chan.private = sk;
 	po->chan.ops = &pptp_chan_ops;
 
-	{
-		struct flowi fl = {
-			.nl_u = {
-				.ip4_u = {
-					.daddr = opt->dst_addr.sin_addr.s_addr,
-					.saddr = opt->src_addr.sin_addr.s_addr,
-					.tos = RT_CONN_FLAGS(sk) } },
-			.proto = IPPROTO_GRE };
-		security_sk_classify_flow(sk, &fl);
-		rt = ip_route_output_key(&init_net, &fl);
-		if (IS_ERR(rt)) {
-			error = -EHOSTUNREACH;
-			goto end;
-		}
-		sk_setup_caps(sk, &rt->dst);
+	rt = ip_route_output_ports(&init_net, sk,
+				   opt->dst_addr.sin_addr.s_addr,
+				   opt->src_addr.sin_addr.s_addr,
+				   0, 0,
+				   IPPROTO_GRE, RT_CONN_FLAGS(sk), 0);
+	if (IS_ERR(rt)) {
+		error = -EHOSTUNREACH;
+		goto end;
 	}
+	sk_setup_caps(sk, &rt->dst);
+
 	po->chan.mtu = dst_mtu(&rt->dst);
 	if (!po->chan.mtu)
 		po->chan.mtu = PPP_MTU;
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 889199a..a24dff9 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -451,26 +451,12 @@ static struct cxgbi_sock *cxgbi_sock_create(struct cxgbi_device *cdev)
 }
 
 static struct rtable *find_route_ipv4(__be32 saddr, __be32 daddr,
-					__be16 sport, __be16 dport, u8 tos)
+				      __be16 sport, __be16 dport, u8 tos)
 {
 	struct rtable *rt;
-	struct flowi fl = {
-		.oif = 0,
-		.nl_u = {
-			.ip4_u = {
-				.daddr = daddr,
-				.saddr = saddr,
-				.tos = tos }
-			},
-		.proto = IPPROTO_TCP,
-		.uli_u = {
-			.ports = {
-				.sport = sport,
-				.dport = dport }
-			}
-	};
 
-	rt = ip_route_output_flow(&init_net, &fl, NULL);
+	rt = ip_route_output_ports(&init_net, NULL, daddr, saddr,
+				   dport, sport, IPPROTO_TCP, tos, 0);
 	if (IS_ERR(rt))
 		return NULL;
 
diff --git a/include/net/route.h b/include/net/route.h
index 9257f5f..f140f41 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -132,6 +132,54 @@ static inline struct rtable *ip_route_output_key(struct net *net, struct flowi *
 	return ip_route_output_flow(net, flp, NULL);
 }
 
+static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
+					     __be32 saddr, u8 tos, int oif)
+{
+	struct flowi fl = {
+		.oif = oif,
+		.fl4_dst = daddr,
+		.fl4_src = saddr,
+		.fl4_tos = tos,
+	};
+	return ip_route_output_key(net, &fl);
+}
+
+static inline struct rtable *ip_route_output_ports(struct net *net, struct sock *sk,
+						   __be32 daddr, __be32 saddr,
+						   __be16 dport, __be16 sport,
+						   __u8 proto, __u8 tos, int oif)
+{
+	struct flowi fl = {
+		.oif = oif,
+		.flags = sk ? inet_sk_flowi_flags(sk) : 0,
+		.mark = sk ? sk->sk_mark : 0,
+		.fl4_dst = daddr,
+		.fl4_src = saddr,
+		.fl4_tos = tos,
+		.proto = proto,
+		.fl_ip_dport = dport,
+		.fl_ip_sport = sport,
+	};
+	if (sk)
+		security_sk_classify_flow(sk, &fl);
+	return ip_route_output_flow(net, &fl, sk);
+}
+
+static inline struct rtable *ip_route_output_gre(struct net *net,
+						 __be32 daddr, __be32 saddr,
+						 __be32 gre_key, __u8 tos, int oif)
+{
+	struct flowi fl = {
+		.oif = oif,
+		.fl4_dst = daddr,
+		.fl4_src = saddr,
+		.fl4_tos = tos,
+		.proto = IPPROTO_GRE,
+		.fl_gre_key = gre_key,
+	};
+	return ip_route_output_key(net, &fl);
+}
+
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
 				 u8 tos, struct net_device *devin, bool noref);
 
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 810a129..1d4be60 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -502,8 +502,6 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	struct atmarp_entry *entry;
 	int error;
 	struct clip_vcc *clip_vcc;
-	struct flowi fl = { .fl4_dst = ip,
-			    .fl4_tos = 1 };
 	struct rtable *rt;
 
 	if (vcc->push != clip_push) {
@@ -520,7 +518,7 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 		unlink_clip_vcc(clip_vcc);
 		return 0;
 	}
-	rt = ip_route_output_key(&init_net, &fl);
+	rt = ip_route_output(&init_net, ip, 0, 1, 0);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 	neigh = __neigh_lookup(&clip_tbl, &ip, rt->dst.dev, 1);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 45b57b1..f97af559 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -412,10 +412,6 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 	if (dnat_took_place(skb)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
-			struct flowi fl = {
-				.fl4_dst = iph->daddr,
-				.fl4_tos = RT_TOS(iph->tos),
-			};
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 			/* If err equals -EHOSTUNREACH the error is due to a
@@ -428,7 +424,8 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			rt = ip_route_output_key(dev_net(dev), &fl);
+			rt = ip_route_output(dev_net(dev), iph->daddr, 0,
+					     RT_TOS(iph->tos), 0);
 			if (!IS_ERR(rt)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
 				 *   require ip_forwarding. */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 35a5020..807d83c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1157,22 +1157,10 @@ int inet_sk_rebuild_header(struct sock *sk)
 	daddr = inet->inet_daddr;
 	if (inet->opt && inet->opt->srr)
 		daddr = inet->opt->faddr;
-	{
-	struct flowi fl = {
-		.oif = sk->sk_bound_dev_if,
-		.mark = sk->sk_mark,
-		.fl4_dst = daddr,
-		.fl4_src = inet->inet_saddr,
-		.fl4_tos = RT_CONN_FLAGS(sk),
-		.proto = sk->sk_protocol,
-		.flags = inet_sk_flowi_flags(sk),
-		.fl_ip_sport = inet->inet_sport,
-		.fl_ip_dport = inet->inet_dport,
-	};
-
-	security_sk_classify_flow(sk, &fl);
-	rt = ip_route_output_flow(sock_net(sk), &fl, sk);
-	}
+	rt = ip_route_output_ports(sock_net(sk), sk, daddr, inet->inet_saddr,
+				   inet->inet_dport, inet->inet_sport,
+				   sk->sk_protocol, RT_CONN_FLAGS(sk),
+				   sk->sk_bound_dev_if);
 	if (!IS_ERR(rt)) {
 		err = 0;
 		sk_setup_caps(sk, &rt->dst);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index fa9988d..090d273 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -433,14 +433,12 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 
 static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 {
-	struct flowi fl = { .fl4_dst = sip,
-			    .fl4_src = tip };
 	struct rtable *rt;
 	int flag = 0;
 	/*unsigned long now; */
 	struct net *net = dev_net(dev);
 
-	rt = ip_route_output_key(net, &fl);
+	rt = ip_route_output(net, sip, tip, 0, 0);
 	if (IS_ERR(rt))
 		return 1;
 	if (rt->dst.dev != dev) {
@@ -1062,9 +1060,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
 	if (dev == NULL) {
-		struct flowi fl = { .fl4_dst = ip,
-				    .fl4_tos = RTO_ONLINK };
-		struct rtable *rt = ip_route_output_key(net, &fl);
+		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
 
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
@@ -1185,9 +1181,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (dev == NULL) {
-		struct flowi fl = { .fl4_dst = ip,
-				    .fl4_tos = RTO_ONLINK };
-		struct rtable *rt = ip_route_output_key(net, &fl);
+		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 		dev = rt->dst.dev;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 12b65cc..1fd3d9c 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -321,15 +321,12 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	}
 	igmp_skb_size(skb) = size;
 
-	{
-		struct flowi fl = { .oif = dev->ifindex,
-				    .fl4_dst = IGMPV3_ALL_MCR,
-				    .proto = IPPROTO_IGMP };
-		rt = ip_route_output_key(net, &fl);
-		if (IS_ERR(rt)) {
-			kfree_skb(skb);
-			return NULL;
-		}
+	rt = ip_route_output_ports(net, NULL, IGMPV3_ALL_MCR, 0,
+				   0, 0,
+				   IPPROTO_IGMP, 0, dev->ifindex);
+	if (IS_ERR(rt)) {
+		kfree_skb(skb);
+		return NULL;
 	}
 	if (rt->rt_src == 0) {
 		kfree_skb(skb);
@@ -667,14 +664,12 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	else
 		dst = group;
 
-	{
-		struct flowi fl = { .oif = dev->ifindex,
-				    .fl4_dst = dst,
-				    .proto = IPPROTO_IGMP };
-		rt = ip_route_output_key(net, &fl);
-		if (IS_ERR(rt))
-			return -1;
-	}
+	rt = ip_route_output_ports(net, NULL, dst, 0,
+				   0, 0,
+				   IPPROTO_IGMP, 0, dev->ifindex);
+	if (IS_ERR(rt))
+		return -1;
+
 	if (rt->rt_src == 0) {
 		ip_rt_put(rt);
 		return -1;
@@ -1441,7 +1436,6 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 /* RTNL is locked */
 static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 {
-	struct flowi fl = { .fl4_dst = imr->imr_multiaddr.s_addr };
 	struct net_device *dev = NULL;
 	struct in_device *idev = NULL;
 
@@ -1456,7 +1450,9 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 	}
 
 	if (!dev) {
-		struct rtable *rt = ip_route_output_key(net, &fl);
+		struct rtable *rt = ip_route_output(net,
+						    imr->imr_multiaddr.s_addr,
+						    0, 0, 0);
 		if (!IS_ERR(rt)) {
 			dev = rt->dst.dev;
 			ip_rt_put(rt);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7146595..da5941f 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -769,20 +769,12 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			tos = ipv6_get_dsfield((struct ipv6hdr *)old_iph);
 	}
 
-	{
-		struct flowi fl = {
-			.oif = tunnel->parms.link,
-			.fl4_dst = dst,
-			.fl4_src = tiph->saddr,
-			.fl4_tos = RT_TOS(tos),
-			.proto = IPPROTO_GRE,
-			.fl_gre_key = tunnel->parms.o_key
-		};
-		rt = ip_route_output_key(dev_net(dev), &fl);
-		if (IS_ERR(rt)) {
-			dev->stats.tx_carrier_errors++;
-			goto tx_error;
-		}
+	rt = ip_route_output_gre(dev_net(dev), dst, tiph->saddr,
+				 tunnel->parms.o_key, RT_TOS(tos),
+				 tunnel->parms.link);
+	if (IS_ERR(rt)) {
+		dev->stats.tx_carrier_errors++;
+		goto tx_error;
 	}
 	tdev = rt->dst.dev;
 
@@ -946,15 +938,11 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 	/* Guess output device to choose reasonable mtu and needed_headroom */
 
 	if (iph->daddr) {
-		struct flowi fl = {
-			.oif = tunnel->parms.link,
-			.fl4_dst = iph->daddr,
-			.fl4_src = iph->saddr,
-			.fl4_tos = RT_TOS(iph->tos),
-			.proto = IPPROTO_GRE,
-			.fl_gre_key = tunnel->parms.o_key
-		};
-		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
+		struct rtable *rt = ip_route_output_gre(dev_net(dev),
+							iph->daddr, iph->saddr,
+							tunnel->parms.o_key,
+							RT_TOS(iph->tos),
+							tunnel->parms.link);
 
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
@@ -1208,15 +1196,12 @@ static int ipgre_open(struct net_device *dev)
 	struct ip_tunnel *t = netdev_priv(dev);
 
 	if (ipv4_is_multicast(t->parms.iph.daddr)) {
-		struct flowi fl = {
-			.oif = t->parms.link,
-			.fl4_dst = t->parms.iph.daddr,
-			.fl4_src = t->parms.iph.saddr,
-			.fl4_tos = RT_TOS(t->parms.iph.tos),
-			.proto = IPPROTO_GRE,
-			.fl_gre_key = t->parms.o_key
-		};
-		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
+		struct rtable *rt = ip_route_output_gre(dev_net(dev),
+							t->parms.iph.daddr,
+							t->parms.iph.saddr,
+							t->parms.o_key,
+							RT_TOS(t->parms.iph.tos),
+							t->parms.link);
 
 		if (IS_ERR(rt))
 			return -EADDRNOTAVAIL;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 171f483..916152d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -339,26 +339,19 @@ int ip_queue_xmit(struct sk_buff *skb)
 		if(opt && opt->srr)
 			daddr = opt->faddr;
 
-		{
-			struct flowi fl = { .oif = sk->sk_bound_dev_if,
-					    .mark = sk->sk_mark,
-					    .fl4_dst = daddr,
-					    .fl4_src = inet->inet_saddr,
-					    .fl4_tos = RT_CONN_FLAGS(sk),
-					    .proto = sk->sk_protocol,
-					    .flags = inet_sk_flowi_flags(sk),
-					    .fl_ip_sport = inet->inet_sport,
-					    .fl_ip_dport = inet->inet_dport };
-
-			/* If this fails, retransmit mechanism of transport layer will
-			 * keep trying until route appears or the connection times
-			 * itself out.
-			 */
-			security_sk_classify_flow(sk, &fl);
-			rt = ip_route_output_flow(sock_net(sk), &fl, sk);
-			if (IS_ERR(rt))
-				goto no_route;
-		}
+		/* If this fails, retransmit mechanism of transport layer will
+		 * keep trying until route appears or the connection times
+		 * itself out.
+		 */
+		rt = ip_route_output_ports(sock_net(sk), sk,
+					   daddr, inet->inet_saddr,
+					   inet->inet_dport,
+					   inet->inet_sport,
+					   sk->sk_protocol,
+					   RT_CONN_FLAGS(sk),
+					   sk->sk_bound_dev_if);
+		if (IS_ERR(rt))
+			goto no_route;
 		sk_setup_caps(sk, &rt->dst);
 	}
 	skb_dst_set_noref(skb, &rt->dst);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 65008f4..bfc17c5 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -460,20 +460,14 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error_icmp;
 	}
 
-	{
-		struct flowi fl = {
-			.oif = tunnel->parms.link,
-			.fl4_dst = dst,
-			.fl4_src= tiph->saddr,
-			.fl4_tos = RT_TOS(tos),
-			.proto = IPPROTO_IPIP
-		};
-
-		rt = ip_route_output_key(dev_net(dev), &fl);
-		if (IS_ERR(rt)) {
-			dev->stats.tx_carrier_errors++;
-			goto tx_error_icmp;
-		}
+	rt = ip_route_output_ports(dev_net(dev), NULL,
+				   dst, tiph->saddr,
+				   0, 0,
+				   IPPROTO_IPIP, RT_TOS(tos),
+				   tunnel->parms.link);
+	if (IS_ERR(rt)) {
+		dev->stats.tx_carrier_errors++;
+		goto tx_error_icmp;
 	}
 	tdev = rt->dst.dev;
 
@@ -584,14 +578,12 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 	iph = &tunnel->parms.iph;
 
 	if (iph->daddr) {
-		struct flowi fl = {
-			.oif = tunnel->parms.link,
-			.fl4_dst = iph->daddr,
-			.fl4_src = iph->saddr,
-			.fl4_tos = RT_TOS(iph->tos),
-			.proto = IPPROTO_IPIP
-		};
-		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
+		struct rtable *rt = ip_route_output_ports(dev_net(dev), NULL,
+							  iph->daddr, iph->saddr,
+							  0, 0,
+							  IPPROTO_IPIP,
+							  RT_TOS(iph->tos),
+							  tunnel->parms.link);
 
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 74909ba..594a300 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1611,25 +1611,19 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 #endif
 
 	if (vif->flags & VIFF_TUNNEL) {
-		struct flowi fl = {
-			.oif = vif->link,
-			.fl4_dst = vif->remote,
-			.fl4_src = vif->local,
-			.fl4_tos = RT_TOS(iph->tos),
-			.proto = IPPROTO_IPIP
-		};
-		rt = ip_route_output_key(net, &fl);
+		rt = ip_route_output_ports(net, NULL,
+					   vif->remote, vif->local,
+					   0, 0,
+					   IPPROTO_IPIP,
+					   RT_TOS(iph->tos), vif->link);
 		if (IS_ERR(rt))
 			goto out_free;
 		encap = sizeof(struct iphdr);
 	} else {
-		struct flowi fl = {
-			.oif = vif->link,
-			.fl4_dst = iph->daddr,
-			.fl4_tos = RT_TOS(iph->tos),
-			.proto = IPPROTO_IPIP
-		};
-		rt = ip_route_output_key(net, &fl);
+		rt = ip_route_output_ports(net, NULL, iph->daddr, 0,
+					   0, 0,
+					   IPPROTO_IPIP,
+					   RT_TOS(iph->tos), vif->link);
 		if (IS_ERR(rt))
 			goto out_free;
 	}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ea8d5e8..f199b84 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -536,7 +536,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	int err;
 	struct sk_buff *skb2;
 	struct iphdr *eiph;
-	struct flowi fl;
 	struct rtable *rt;
 
 	err = ip6_tnl_err(skb, IPPROTO_IPIP, opt, &rel_type, &rel_code,
@@ -578,11 +577,10 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	eiph = ip_hdr(skb2);
 
 	/* Try to guess incoming interface */
-	memset(&fl, 0, sizeof(fl));
-	fl.fl4_dst = eiph->saddr;
-	fl.fl4_tos = RT_TOS(eiph->tos);
-	fl.proto = IPPROTO_IPIP;
-	rt = ip_route_output_key(dev_net(skb->dev), &fl);
+	rt = ip_route_output_ports(dev_net(skb->dev), NULL,
+				   eiph->saddr, 0,
+				   0, 0,
+				   IPPROTO_IPIP, RT_TOS(eiph->tos), 0);
 	if (IS_ERR(rt))
 		goto out;
 
@@ -592,10 +590,11 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
 		rt = NULL;
-		fl.fl4_dst = eiph->daddr;
-		fl.fl4_src = eiph->saddr;
-		fl.fl4_tos = eiph->tos;
-		rt = ip_route_output_key(dev_net(skb->dev), &fl);
+		rt = ip_route_output_ports(dev_net(skb->dev), NULL,
+					   eiph->daddr, eiph->saddr,
+					   0, 0,
+					   IPPROTO_IPIP,
+					   RT_TOS(eiph->tos), 0);
 		if (IS_ERR(rt) ||
 		    rt->dst.dev->type != ARPHRD_TUNNEL) {
 			if (!IS_ERR(rt))
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3534cea..43b3337 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -732,17 +732,14 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		dst = addr6->s6_addr32[3];
 	}
 
-	{
-		struct flowi fl = { .fl4_dst = dst,
-				    .fl4_src = tiph->saddr,
-				    .fl4_tos = RT_TOS(tos),
-				    .oif = tunnel->parms.link,
-				    .proto = IPPROTO_IPV6 };
-		rt = ip_route_output_key(dev_net(dev), &fl);
-		if (IS_ERR(rt)) {
-			dev->stats.tx_carrier_errors++;
-			goto tx_error_icmp;
-		}
+	rt = ip_route_output_ports(dev_net(dev), NULL,
+				   dst, tiph->saddr,
+				   0, 0,
+				   IPPROTO_IPV6, RT_TOS(tos),
+				   tunnel->parms.link);
+	if (IS_ERR(rt)) {
+		dev->stats.tx_carrier_errors++;
+		goto tx_error_icmp;
 	}
 	if (rt->rt_type != RTN_UNICAST) {
 		ip_rt_put(rt);
@@ -858,12 +855,12 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	iph = &tunnel->parms.iph;
 
 	if (iph->daddr) {
-		struct flowi fl = { .fl4_dst = iph->daddr,
-				    .fl4_src = iph->saddr,
-				    .fl4_tos = RT_TOS(iph->tos),
-				    .oif = tunnel->parms.link,
-				    .proto = IPPROTO_IPV6 };
-		struct rtable *rt = ip_route_output_key(dev_net(dev), &fl);
+		struct rtable *rt = ip_route_output_ports(dev_net(dev), NULL,
+							  iph->daddr, iph->saddr,
+							  0, 0,
+							  IPPROTO_IPV6,
+							  RT_TOS(iph->tos),
+							  tunnel->parms.link);
 
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 2a698ff..fce9bd3 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -475,25 +475,17 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		if (opt && opt->srr)
 			daddr = opt->faddr;
 
-		{
-			struct flowi fl = { .oif = sk->sk_bound_dev_if,
-					    .fl4_dst = daddr,
-					    .fl4_src = inet->inet_saddr,
-					    .fl4_tos = RT_CONN_FLAGS(sk),
-					    .proto = sk->sk_protocol,
-					    .flags = inet_sk_flowi_flags(sk),
-					    .fl_ip_sport = inet->inet_sport,
-					    .fl_ip_dport = inet->inet_dport };
-
-			/* If this fails, retransmit mechanism of transport layer will
-			 * keep trying until route appears or the connection times
-			 * itself out.
-			 */
-			security_sk_classify_flow(sk, &fl);
-			rt = ip_route_output_flow(sock_net(sk), &fl, sk);
-			if (IS_ERR(rt))
-				goto no_route;
-		}
+		/* If this fails, retransmit mechanism of transport layer will
+		 * keep trying until route appears or the connection times
+		 * itself out.
+		 */
+		rt = ip_route_output_ports(sock_net(sk), sk,
+					   daddr, inet->inet_saddr,
+					   inet->inet_dport, inet->inet_sport,
+					   sk->sk_protocol, RT_CONN_FLAGS(sk),
+					   sk->sk_bound_dev_if);
+		if (IS_ERR(rt))
+			goto no_route;
 		sk_setup_caps(sk, &rt->dst);
 	}
 	skb_dst_set(skb, dst_clone(&rt->dst));
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 878f6dd..faf381d 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -98,12 +98,7 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		spin_lock(&dest->dst_lock);
 		if (!(rt = (struct rtable *)
 		      __ip_vs_dst_check(dest, rtos))) {
-			struct flowi fl = {
-				.fl4_dst = dest->addr.ip,
-				.fl4_tos = rtos,
-			};
-
-			rt = ip_route_output_key(net, &fl);
+			rt = ip_route_output(net, dest->addr.ip, 0, rtos, 0);
 			if (IS_ERR(rt)) {
 				spin_unlock(&dest->dst_lock);
 				IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
@@ -117,12 +112,7 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		}
 		spin_unlock(&dest->dst_lock);
 	} else {
-		struct flowi fl = {
-			.fl4_dst = daddr,
-			.fl4_tos = rtos,
-		};
-
-		rt = ip_route_output_key(net, &fl);
+		rt = ip_route_output(net, daddr, 0, rtos, 0);
 		if (IS_ERR(rt)) {
 			IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
 				     &daddr);
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index 3620c56..55b93dc 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -36,28 +36,13 @@ static void rxrpc_destroy_peer(struct work_struct *work);
 static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 {
 	struct rtable *rt;
-	struct flowi fl;
 
 	peer->if_mtu = 1500;
 
-	memset(&fl, 0, sizeof(fl));
-
-	switch (peer->srx.transport.family) {
-	case AF_INET:
-		fl.oif = 0;
-		fl.proto = IPPROTO_UDP,
-		fl.fl4_dst = peer->srx.transport.sin.sin_addr.s_addr;
-		fl.fl4_src = 0;
-		fl.fl4_tos = 0;
-		/* assume AFS.CM talking to AFS.FS */
-		fl.fl_ip_sport = htons(7001);
-		fl.fl_ip_dport = htons(7000);
-		break;
-	default:
-		BUG();
-	}
-
-	rt = ip_route_output_key(&init_net, &fl);
+	rt = ip_route_output_ports(&init_net, NULL,
+				   peer->srx.transport.sin.sin_addr.s_addr, 0,
+				   htons(7000), htons(7001),
+				   IPPROTO_UDP, 0, 0);
 	if (IS_ERR(rt)) {
 		_leave(" [route err %ld]", PTR_ERR(rt));
 		return;
-- 
1.7.4.1

