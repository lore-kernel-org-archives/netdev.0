From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 34/53] netns xfrm: lookup in netns
Date: Tue, 25 Nov 2008 20:27:06 +0300
Message-ID: <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:40948 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321AbYKYRZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:01 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23228eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:59 -0800 (PST)
In-Reply-To: <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass netns to xfrm_lookup()/__xfrm_lookup(). For that pass netns
to flow_cache_lookup() and resolver callback.

Take it from socket or netdevice. Stub DECnet to init_net.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/dst.h                |   16 ++++++++--------
 include/net/flow.h               |    9 +++++----
 net/core/flow.c                  |    4 ++--
 net/dccp/ipv6.c                  |   10 +++++-----
 net/decnet/dn_route.c            |    6 +++---
 net/ipv4/icmp.c                  |    4 ++--
 net/ipv4/netfilter.c             |    4 ++--
 net/ipv4/route.c                 |    2 +-
 net/ipv6/af_inet6.c              |    2 +-
 net/ipv6/datagram.c              |    3 ++-
 net/ipv6/icmp.c                  |    6 +++---
 net/ipv6/inet6_connection_sock.c |    2 +-
 net/ipv6/ip6_tunnel.c            |    5 +++--
 net/ipv6/mcast.c                 |    4 ++--
 net/ipv6/ndisc.c                 |    4 ++--
 net/ipv6/netfilter.c             |    2 +-
 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 net/ipv6/raw.c                   |    3 ++-
 net/ipv6/syncookies.c            |    2 +-
 net/ipv6/tcp_ipv6.c              |   11 ++++++-----
 net/ipv6/udp.c                   |    3 ++-
 net/xfrm/xfrm_policy.c           |   38 ++++++++++++++++++++------------------
 22 files changed, 75 insertions(+), 67 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 6c77879..6be3b08 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -291,21 +291,21 @@ enum {
 
 struct flowi;
 #ifndef CONFIG_XFRM
-static inline int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
-		       struct sock *sk, int flags)
+static inline int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
+			      struct flowi *fl, struct sock *sk, int flags)
 {
 	return 0;
 } 
-static inline int __xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
-				struct sock *sk, int flags)
+static inline int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
+				struct flowi *fl, struct sock *sk, int flags)
 {
 	return 0;
 }
 #else
-extern int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
-		       struct sock *sk, int flags);
-extern int __xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
-			 struct sock *sk, int flags);
+extern int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
+		       struct flowi *fl, struct sock *sk, int flags);
+extern int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
+			 struct flowi *fl, struct sock *sk, int flags);
 #endif
 #endif
 
diff --git a/include/net/flow.h b/include/net/flow.h
index b45a5e4..809970b 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -84,12 +84,13 @@ struct flowi {
 #define FLOW_DIR_OUT	1
 #define FLOW_DIR_FWD	2
 
+struct net;
 struct sock;
-typedef int (*flow_resolve_t)(struct flowi *key, u16 family, u8 dir,
-			       void **objp, atomic_t **obj_refp);
+typedef int (*flow_resolve_t)(struct net *net, struct flowi *key, u16 family,
+			      u8 dir, void **objp, atomic_t **obj_refp);
 
-extern void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
-	 		       flow_resolve_t resolver);
+extern void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family,
+			       u8 dir, flow_resolve_t resolver);
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
 
diff --git a/net/core/flow.c b/net/core/flow.c
index d323388..9601587 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -165,7 +165,7 @@ static int flow_key_compare(struct flowi *key1, struct flowi *key2)
 	return 0;
 }
 
-void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
+void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 			flow_resolve_t resolver)
 {
 	struct flow_cache_entry *fle, **head;
@@ -225,7 +225,7 @@ nocache:
 		void *obj;
 		atomic_t *obj_ref;
 
-		err = resolver(key, family, dir, &obj, &obj_ref);
+		err = resolver(net, key, family, dir, &obj, &obj_ref);
 
 		if (fle && !err) {
 			fle->genid = atomic_read(&flow_cache_genid);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index f033e84..b963f35 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -168,7 +168,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 				goto out;
 			}
 
-			err = xfrm_lookup(&dst, &fl, sk, 0);
+			err = xfrm_lookup(net, &dst, &fl, sk, 0);
 			if (err < 0) {
 				sk->sk_err_soft = -err;
 				goto out;
@@ -279,7 +279,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	err = xfrm_lookup(&dst, &fl, sk, 0);
+	err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0);
 	if (err < 0)
 		goto done;
 
@@ -343,7 +343,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(ctl_sk, &skb->dst, &fl)) {
-		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >= 0) {
+		if (xfrm_lookup(net, &skb->dst, &fl, NULL, 0) >= 0) {
 			ip6_xmit(ctl_sk, skb, &fl, NULL, 0);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
@@ -569,7 +569,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		if (final_p)
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+		if ((xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
 			goto out;
 	}
 
@@ -1004,7 +1004,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT);
+	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
 	if (err < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 768df00..eeaa3d8 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1184,7 +1184,7 @@ static int dn_route_output_key(struct dst_entry **pprt, struct flowi *flp, int f
 
 	err = __dn_route_output_key(pprt, flp, flags);
 	if (err == 0 && flp->proto) {
-		err = xfrm_lookup(pprt, flp, NULL, 0);
+		err = xfrm_lookup(&init_net, pprt, flp, NULL, 0);
 	}
 	return err;
 }
@@ -1195,8 +1195,8 @@ int dn_route_output_sock(struct dst_entry **pprt, struct flowi *fl, struct sock
 
 	err = __dn_route_output_key(pprt, fl, flags & MSG_TRYHARD);
 	if (err == 0 && fl->proto) {
-		err = xfrm_lookup(pprt, fl, sk, (flags & MSG_DONTWAIT) ?
-						0 : XFRM_LOOKUP_WAIT);
+		err = xfrm_lookup(&init_net, pprt, fl, sk,
+				 (flags & MSG_DONTWAIT) ? 0 : XFRM_LOOKUP_WAIT);
 	}
 	return err;
 }
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 21e497e..893e070 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -562,7 +562,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		/* No need to clone since we're just using its address. */
 		rt2 = rt;
 
-		err = xfrm_lookup((struct dst_entry **)&rt, &fl, NULL, 0);
+		err = xfrm_lookup(net, (struct dst_entry **)&rt, &fl, NULL, 0);
 		switch (err) {
 		case 0:
 			if (rt != rt2)
@@ -601,7 +601,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		if (err)
 			goto relookup_failed;
 
-		err = xfrm_lookup((struct dst_entry **)&rt2, &fl, NULL,
+		err = xfrm_lookup(net, (struct dst_entry **)&rt2, &fl, NULL,
 				  XFRM_LOOKUP_ICMP);
 		switch (err) {
 		case 0:
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 6efdb70..c99eecf 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -66,7 +66,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 #ifdef CONFIG_XFRM
 	if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
 	    xfrm_decode_session(skb, &fl, AF_INET) == 0)
-		if (xfrm_lookup(&skb->dst, &fl, skb->sk, 0))
+		if (xfrm_lookup(net, &skb->dst, &fl, skb->sk, 0))
 			return -1;
 #endif
 
@@ -97,7 +97,7 @@ int ip_xfrm_me_harder(struct sk_buff *skb)
 		dst = ((struct xfrm_dst *)dst)->route;
 	dst_hold(dst);
 
-	if (xfrm_lookup(&dst, &fl, skb->sk, 0) < 0)
+	if (xfrm_lookup(dev_net(dst->dev), &dst, &fl, skb->sk, 0) < 0)
 		return -1;
 
 	dst_release(skb->dst);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4e6959c..77bfba9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2761,7 +2761,7 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 			flp->fl4_src = (*rp)->rt_src;
 		if (!flp->fl4_dst)
 			flp->fl4_dst = (*rp)->rt_dst;
-		err = __xfrm_lookup((struct dst_entry **)rp, flp, sk,
+		err = __xfrm_lookup(net, (struct dst_entry **)rp, flp, sk,
 				    flags ? XFRM_LOOKUP_WAIT : 0);
 		if (err == -EREMOTE)
 			err = ipv4_dst_blackhole(net, rp, flp);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 01edac8..437b750 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -637,7 +637,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 		if (final_p)
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		if ((err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0) {
 			sk->sk_err_soft = -err;
 			return err;
 		}
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e44deb8..e2bdc6d 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -175,7 +175,8 @@ ipv4_connected:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
+	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
+	if (err < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a77b8d1..4f43384 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -427,7 +427,7 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
 	/* No need to clone since we're just using its address. */
 	dst2 = dst;
 
-	err = xfrm_lookup(&dst, &fl, sk, 0);
+	err = xfrm_lookup(net, &dst, &fl, sk, 0);
 	switch (err) {
 	case 0:
 		if (dst != dst2)
@@ -446,7 +446,7 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
 	if (ip6_dst_lookup(sk, &dst2, &fl))
 		goto relookup_failed;
 
-	err = xfrm_lookup(&dst2, &fl, sk, XFRM_LOOKUP_ICMP);
+	err = xfrm_lookup(net, &dst2, &fl, sk, XFRM_LOOKUP_ICMP);
 	switch (err) {
 	case 0:
 		dst_release(dst);
@@ -552,7 +552,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	if ((err = xfrm_lookup(net, &dst, &fl, sk, 0)) < 0)
 		goto out;
 
 	if (ipv6_addr_is_multicast(&fl.fl6_dst))
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 16d43f2..3c3732d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -219,7 +219,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 		if (final_p)
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+		if ((err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0) {
 			sk->sk_route_caps = 0;
 			kfree_skb(skb);
 			return err;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ef249ab..58e2b0d 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -846,6 +846,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 			 int encap_limit,
 			 __u32 *pmtu)
 {
+	struct net *net = dev_net(dev);
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->dev->stats;
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
@@ -861,9 +862,9 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	if ((dst = ip6_tnl_dst_check(t)) != NULL)
 		dst_hold(dst);
 	else {
-		dst = ip6_route_output(dev_net(dev), NULL, fl);
+		dst = ip6_route_output(net, NULL, fl);
 
-		if (dst->error || xfrm_lookup(&dst, fl, NULL, 0) < 0)
+		if (dst->error || xfrm_lookup(net, &dst, fl, NULL, 0) < 0)
 			goto tx_err_link_failure;
 	}
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 870a1d6..0f38960 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1466,7 +1466,7 @@ static void mld_sendpack(struct sk_buff *skb)
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	err = xfrm_lookup(&skb->dst, &fl, NULL, 0);
+	err = xfrm_lookup(net, &skb->dst, &fl, NULL, 0);
 	if (err)
 		goto err_out;
 
@@ -1831,7 +1831,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	err = xfrm_lookup(&skb->dst, &fl, NULL, 0);
+	err = xfrm_lookup(net, &skb->dst, &fl, NULL, 0);
 	if (err)
 		goto err_out;
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index af6705f..e4acc21 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -524,7 +524,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 		return;
 	}
 
-	err = xfrm_lookup(&dst, &fl, NULL, 0);
+	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		return;
@@ -1524,7 +1524,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	if (dst == NULL)
 		return;
 
-	err = xfrm_lookup(&dst, &fl, NULL, 0);
+	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
 	if (err)
 		return;
 
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index fd5b3a4..627e21d 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -29,7 +29,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
 	    xfrm_decode_session(skb, &fl, AF_INET6) == 0)
-		if (xfrm_lookup(&skb->dst, &fl, skb->sk, 0))
+		if (xfrm_lookup(net, &skb->dst, &fl, skb->sk, 0))
 			return -1;
 #endif
 
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 0981b4c..5a2d0a4 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -97,7 +97,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	dst = ip6_route_output(net, NULL, &fl);
 	if (dst == NULL)
 		return;
-	if (dst->error || xfrm_lookup(&dst, &fl, NULL, 0))
+	if (dst->error || xfrm_lookup(net, &dst, &fl, NULL, 0))
 		return;
 
 	hh_len = (dst->dev->hard_header_len + 15)&~15;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 2ba04d4..61f6827 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -860,7 +860,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
+	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
+	if (err < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 676c80b..711175e 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -259,7 +259,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 		if (final_p)
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
-		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+		if ((xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
 			goto out_free;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a5d750a..f259c96 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -260,7 +260,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
+	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
+	if (err < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
@@ -390,7 +391,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 				goto out;
 			}
 
-			if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			if ((err = xfrm_lookup(net, &dst, &fl, sk, 0)) < 0) {
 				sk->sk_err_soft = -err;
 				goto out;
 			}
@@ -492,7 +493,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 		goto done;
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
-	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+	if ((err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
 		goto done;
 
 	skb = tcp_make_synack(sk, dst, req);
@@ -1018,7 +1019,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	 * namespace
 	 */
 	if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
-		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
+		if (xfrm_lookup(net, &buff->dst, &fl, NULL, 0) >= 0) {
 			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 			if (rst)
@@ -1316,7 +1317,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		if (final_p)
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+		if ((xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
 			goto out;
 	}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fd2d9ad..38390dd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -849,7 +849,8 @@ do_udp_sendmsg:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = __xfrm_lookup(&dst, &fl, sk, XFRM_LOOKUP_WAIT)) < 0) {
+	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
+	if (err < 0) {
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, &fl);
 		if (err < 0)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6165218..7c88a25 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -940,7 +940,8 @@ static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
 	return ret;
 }
 
-static struct xfrm_policy *xfrm_policy_lookup_bytype(u8 type, struct flowi *fl,
+static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
+						     struct flowi *fl,
 						     u16 family, u8 dir)
 {
 	int err;
@@ -956,7 +957,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(u8 type, struct flowi *fl,
 		return NULL;
 
 	read_lock_bh(&xfrm_policy_lock);
-	chain = policy_hash_direct(&init_net, daddr, saddr, family, dir);
+	chain = policy_hash_direct(net, daddr, saddr, family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		err = xfrm_policy_match(pol, fl, type, family, dir);
@@ -973,7 +974,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(u8 type, struct flowi *fl,
 			break;
 		}
 	}
-	chain = &init_net.xfrm.policy_inexact[dir];
+	chain = &net->xfrm.policy_inexact[dir];
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		err = xfrm_policy_match(pol, fl, type, family, dir);
 		if (err) {
@@ -996,14 +997,14 @@ fail:
 	return ret;
 }
 
-static int xfrm_policy_lookup(struct flowi *fl, u16 family, u8 dir,
-			       void **objp, atomic_t **obj_refp)
+static int xfrm_policy_lookup(struct net *net, struct flowi *fl, u16 family,
+			      u8 dir, void **objp, atomic_t **obj_refp)
 {
 	struct xfrm_policy *pol;
 	int err = 0;
 
 #ifdef CONFIG_XFRM_SUB_POLICY
-	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_SUB, fl, family, dir);
+	pol = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_SUB, fl, family, dir);
 	if (IS_ERR(pol)) {
 		err = PTR_ERR(pol);
 		pol = NULL;
@@ -1011,7 +1012,7 @@ static int xfrm_policy_lookup(struct flowi *fl, u16 family, u8 dir,
 	if (pol || err)
 		goto end;
 #endif
-	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_MAIN, fl, family, dir);
+	pol = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN, fl, family, dir);
 	if (IS_ERR(pol)) {
 		err = PTR_ERR(pol);
 		pol = NULL;
@@ -1537,7 +1538,7 @@ static int stale_bundle(struct dst_entry *dst);
  * At the moment we eat a raw IP route. Mostly to speed up lookups
  * on interfaces with disabled IPsec.
  */
-int __xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
+int __xfrm_lookup(struct net *net, struct dst_entry **dst_p, struct flowi *fl,
 		  struct sock *sk, int flags)
 {
 	struct xfrm_policy *policy;
@@ -1575,10 +1576,10 @@ restart:
 	if (!policy) {
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) ||
-		    !init_net.xfrm.policy_count[XFRM_POLICY_OUT])
+		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		policy = flow_cache_lookup(fl, dst_orig->ops->family,
+		policy = flow_cache_lookup(net, fl, dst_orig->ops->family,
 					   dir, xfrm_policy_lookup);
 		err = PTR_ERR(policy);
 		if (IS_ERR(policy)) {
@@ -1635,7 +1636,8 @@ restart:
 
 #ifdef CONFIG_XFRM_SUB_POLICY
 		if (pols[0]->type != XFRM_POLICY_TYPE_MAIN) {
-			pols[1] = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_MAIN,
+			pols[1] = xfrm_policy_lookup_bytype(net,
+							    XFRM_POLICY_TYPE_MAIN,
 							    fl, family,
 							    XFRM_POLICY_OUT);
 			if (pols[1]) {
@@ -1683,11 +1685,11 @@ restart:
 			if (err == -EAGAIN && (flags & XFRM_LOOKUP_WAIT)) {
 				DECLARE_WAITQUEUE(wait, current);
 
-				add_wait_queue(&init_net.xfrm.km_waitq, &wait);
+				add_wait_queue(&net->xfrm.km_waitq, &wait);
 				set_current_state(TASK_INTERRUPTIBLE);
 				schedule();
 				set_current_state(TASK_RUNNING);
-				remove_wait_queue(&init_net.xfrm.km_waitq, &wait);
+				remove_wait_queue(&net->xfrm.km_waitq, &wait);
 
 				nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
@@ -1781,10 +1783,10 @@ nopol:
 }
 EXPORT_SYMBOL(__xfrm_lookup);
 
-int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
+int xfrm_lookup(struct net *net, struct dst_entry **dst_p, struct flowi *fl,
 		struct sock *sk, int flags)
 {
-	int err = __xfrm_lookup(dst_p, fl, sk, flags);
+	int err = __xfrm_lookup(net, dst_p, fl, sk, flags);
 
 	if (err == -EREMOTE) {
 		dst_release(*dst_p);
@@ -1936,7 +1938,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	}
 
 	if (!pol)
-		pol = flow_cache_lookup(&fl, family, fl_dir,
+		pol = flow_cache_lookup(&init_net, &fl, family, fl_dir,
 					xfrm_policy_lookup);
 
 	if (IS_ERR(pol)) {
@@ -1959,7 +1961,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	npols ++;
 #ifdef CONFIG_XFRM_SUB_POLICY
 	if (pols[0]->type != XFRM_POLICY_TYPE_MAIN) {
-		pols[1] = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_MAIN,
+		pols[1] = xfrm_policy_lookup_bytype(&init_net, XFRM_POLICY_TYPE_MAIN,
 						    &fl, family,
 						    XFRM_POLICY_IN);
 		if (pols[1]) {
@@ -2049,7 +2051,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 		return 0;
 	}
 
-	return xfrm_lookup(&skb->dst, &fl, NULL, 0) == 0;
+	return xfrm_lookup(&init_net, &skb->dst, &fl, NULL, 0) == 0;
 }
 EXPORT_SYMBOL(__xfrm_route_forward);
 
-- 
1.5.6.5

