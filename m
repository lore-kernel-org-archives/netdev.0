From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/5] net: Add source address lookup op for VRF
Date: Thu,  1 Oct 2015 08:27:26 -0700
Message-ID: <1443713247-11230-5-git-send-email-dsa@cumulusnetworks.com>
References: <1443713247-11230-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33494 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756469AbbJAP1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 11:27:41 -0400
Received: by pacex6 with SMTP id ex6so77759471pac.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 08:27:41 -0700 (PDT)
In-Reply-To: <1443713247-11230-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add operation to l3mdev to lookup source address for a given flow.
Add support for the operation to VRF driver and convert existing
IPv4 hooks to use the new lookup.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 35 +++++++++++++++++++++++++++++++++++
 include/net/l3mdev.h | 27 +++++++++++++++++++++++++++
 include/net/route.h  |  7 ++++---
 net/ipv4/udp.c       | 22 +++-------------------
 4 files changed, 69 insertions(+), 22 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 277a8e0a6a4f..94881260fcfd 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -36,6 +36,9 @@
 #include <net/addrconf.h>
 #include <net/l3mdev.h>
 
+#define RT_FL_TOS(oldflp4) \
+	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
+
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
@@ -553,9 +556,41 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 	return rth;
 }
 
+/* called under rcu_read_lock */
+static void vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
+{
+	struct fib_result res = { .tclassid = 0 };
+	struct net *net = dev_net(dev);
+	u32 orig_tos = fl4->flowi4_tos;
+	u8 flags = fl4->flowi4_flags;
+	u8 scope = fl4->flowi4_scope;
+	u8 tos = RT_FL_TOS(fl4);
+
+	if (unlikely(!fl4->daddr))
+		return;
+
+	fl4->flowi4_flags |= FLOWI_FLAG_SKIP_NH_OIF;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
+	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
+			     RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
+
+	if (!fib_lookup(net, fl4, &res, 0)) {
+		if (res.type == RTN_LOCAL)
+			fl4->saddr = res.fi->fib_prefsrc ? : fl4->daddr;
+		else
+			fib_select_path(net, &res, fl4);
+	}
+
+	fl4->flowi4_flags = flags;
+	fl4->flowi4_tos = orig_tos;
+	fl4->flowi4_scope = scope;
+}
+
 static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
 	.l3mdev_get_rtable	= vrf_get_rtable,
+	.l3mdev_get_saddr	= vrf_get_saddr,
 };
 
 static void vrf_get_drvinfo(struct net_device *dev,
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 87cee05a0a17..44a19a171104 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -17,12 +17,16 @@
  * @l3mdev_fib_table: Get FIB table id to use for lookups
  *
  * @l3mdev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
+ *
+ * @l3mdev_get_saddr: Get source address for a flow
  */
 
 struct l3mdev_ops {
 	u32		(*l3mdev_fib_table)(const struct net_device *dev);
 	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
 					     const struct flowi4 *fl4);
+	void		(*l3mdev_get_saddr)(struct net_device *dev,
+					    struct flowi4 *fl4);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -100,6 +104,25 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return rc;
 }
 
+static inline void l3mdev_get_saddr(struct net *net, int ifindex,
+				    struct flowi4 *fl4)
+{
+	struct net_device *dev;
+
+	if (ifindex) {
+
+		rcu_read_lock();
+
+		dev = dev_get_by_index_rcu(net, ifindex);
+		if (dev && netif_is_l3_master(dev) &&
+		    dev->l3mdev_ops->l3mdev_get_saddr) {
+			dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
+		}
+
+		rcu_read_unlock();
+	}
+}
+
 #else
 
 static inline int l3mdev_master_ifindex_rcu(struct net_device *dev)
@@ -144,6 +167,10 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return false;
 }
 
+static inline void l3mdev_get_saddr(struct net *net, int ifindex,
+				    struct flowi4 *fl4)
+{
+}
 #endif
 
 #endif /* _NET_L3MDEV_H_ */
diff --git a/include/net/route.h b/include/net/route.h
index 7929c9c33587..a7cb5d02f0f9 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -257,9 +257,6 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
-	if (netif_index_is_l3_master(sock_net(sk), oif))
-		flow_flags |= FLOWI_FLAG_L3MDEV_SRC | FLOWI_FLAG_SKIP_NH_OIF;
-
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
 }
@@ -276,6 +273,10 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 	ip_route_connect_init(fl4, dst, src, tos, oif, protocol,
 			      sport, dport, sk);
 
+	if (!src && oif) {
+		l3mdev_get_saddr(net, oif, fl4);
+		src = fl4->saddr;
+	}
 	if (!dst || !src) {
 		rt = __ip_route_output_key(net, fl4);
 		if (IS_ERR(rt))
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b2882cfd3136..e1fc129099ea 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1017,30 +1017,14 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 		fl4 = &fl4_stack;
 
-		/* unconnected socket. If output device is enslaved to a VRF
-		 * device lookup source address from VRF table. This mimics
-		 * behavior of ip_route_connect{_init}.
-		 */
-		if (netif_index_is_l3_master(net, ipc.oif)) {
-			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
-					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-					   (flow_flags | FLOWI_FLAG_L3MDEV_SRC |
-					    FLOWI_FLAG_SKIP_NH_OIF),
-					   faddr, saddr, dport,
-					   inet->inet_sport);
-
-			rt = ip_route_output_flow(net, fl4, sk);
-			if (!IS_ERR(rt)) {
-				saddr = fl4->saddr;
-				ip_rt_put(rt);
-			}
-		}
-
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 				   flow_flags,
 				   faddr, saddr, dport, inet->inet_sport);
 
+		if (!saddr && ipc.oif)
+			l3mdev_get_saddr(net, ipc.oif, fl4);
+
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		rt = ip_route_output_flow(net, fl4, sk);
 		if (IS_ERR(rt)) {
-- 
1.9.1
