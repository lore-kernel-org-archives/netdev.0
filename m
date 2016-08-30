From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 07/12] net: ipv4: Remove l3mdev_get_saddr
Date: Tue, 30 Aug 2016 10:34:12 -0700
Message-ID: <1472578457-26722-8-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36180 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932930AbcH3Reb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:31 -0400
Received: by mail-pa0-f46.google.com with SMTP id fu3so1753908pad.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:30 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer needed

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 38 --------------------------------------
 include/net/l3mdev.h | 12 ------------
 include/net/route.h  | 10 ----------
 net/ipv4/raw.c       |  6 ------
 net/ipv4/udp.c       |  6 ------
 net/l3mdev/l3mdev.c  | 31 -------------------------------
 6 files changed, 103 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index df58bc791cfd..ec65bf2afcb2 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -668,43 +668,6 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 	return rth;
 }
 
-/* called under rcu_read_lock */
-static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
-{
-	struct fib_result res = { .tclassid = 0 };
-	struct net *net = dev_net(dev);
-	u32 orig_tos = fl4->flowi4_tos;
-	u8 flags = fl4->flowi4_flags;
-	u8 scope = fl4->flowi4_scope;
-	u8 tos = RT_FL_TOS(fl4);
-	int rc;
-
-	if (unlikely(!fl4->daddr))
-		return 0;
-
-	fl4->flowi4_flags |= FLOWI_FLAG_SKIP_NH_OIF;
-	fl4->flowi4_iif = LOOPBACK_IFINDEX;
-	/* make sure oif is set to VRF device for lookup */
-	fl4->flowi4_oif = dev->ifindex;
-	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
-	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
-			     RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
-
-	rc = fib_lookup(net, fl4, &res, 0);
-	if (!rc) {
-		if (res.type == RTN_LOCAL)
-			fl4->saddr = res.fi->fib_prefsrc ? : fl4->daddr;
-		else
-			fib_select_path(net, &res, fl4, -1);
-	}
-
-	fl4->flowi4_flags = flags;
-	fl4->flowi4_tos = orig_tos;
-	fl4->flowi4_scope = scope;
-
-	return rc;
-}
-
 static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return 0;
@@ -991,7 +954,6 @@ static int vrf_get_saddr6(struct net_device *dev, const struct sock *sk,
 static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
 	.l3mdev_get_rtable	= vrf_get_rtable,
-	.l3mdev_get_saddr	= vrf_get_saddr,
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
 	.l3mdev_l3_out		= vrf_l3_out,
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 5f03a89bb075..8085be19a767 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -25,8 +25,6 @@
  *
  * @l3mdev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
  *
- * @l3mdev_get_saddr: Get source address for a flow
- *
  * @l3mdev_get_rt6_dst: Get cached IPv6 rt6_info (dst_entry) for device
  */
 
@@ -41,8 +39,6 @@ struct l3mdev_ops {
 	/* IPv4 ops */
 	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
 					     const struct flowi4 *fl4);
-	int		(*l3mdev_get_saddr)(struct net_device *dev,
-					    struct flowi4 *fl4);
 
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
@@ -175,8 +171,6 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return rc;
 }
 
-int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
-
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6);
 int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
 		      struct flowi6 *fl6);
@@ -291,12 +285,6 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return false;
 }
 
-static inline int l3mdev_get_saddr(struct net *net, int ifindex,
-				   struct flowi4 *fl4)
-{
-	return 0;
-}
-
 static inline
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6)
 {
diff --git a/include/net/route.h b/include/net/route.h
index ad777d79af94..0429d47cad25 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -29,7 +29,6 @@
 #include <net/flow.h>
 #include <net/inet_sock.h>
 #include <net/ip_fib.h>
-#include <net/l3mdev.h>
 #include <linux/in_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/rcupdate.h>
@@ -285,15 +284,6 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 	ip_route_connect_init(fl4, dst, src, tos, oif, protocol,
 			      sport, dport, sk);
 
-	if (!src && oif) {
-		int rc;
-
-		rc = l3mdev_get_saddr(net, oif, fl4);
-		if (rc < 0)
-			return ERR_PTR(rc);
-
-		src = fl4->saddr;
-	}
 	if (!dst || !src) {
 		rt = __ip_route_output_key(net, fl4);
 		if (IS_ERR(rt))
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 438f50c1a676..90a85c955872 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -606,12 +606,6 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
 			   daddr, saddr, 0, 0);
 
-	if (!saddr && ipc.oif) {
-		err = l3mdev_get_saddr(net, ipc.oif, &fl4);
-		if (err < 0)
-			goto done;
-	}
-
 	if (!inet->hdrincl) {
 		rfv.msg = msg;
 		rfv.hlen = 0;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 058c31286ce1..7d96dc2d3d08 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1021,12 +1021,6 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 				   flow_flags,
 				   faddr, saddr, dport, inet->inet_sport);
 
-		if (!saddr && ipc.oif) {
-			err = l3mdev_get_saddr(net, ipc.oif, fl4);
-			if (err < 0)
-				goto out;
-		}
-
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		rt = ip_route_output_flow(net, fl4, sk);
 		if (IS_ERR(rt)) {
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 43610e5acc4e..b30034efccff 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -131,37 +131,6 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
 }
 EXPORT_SYMBOL_GPL(l3mdev_get_rt6_dst);
 
-/**
- *	l3mdev_get_saddr - get source address for a flow based on an interface
- *			   enslaved to an L3 master device
- *	@net: network namespace for device index lookup
- *	@ifindex: Interface index
- *	@fl4: IPv4 flow struct
- */
-
-int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4)
-{
-	struct net_device *dev;
-	int rc = 0;
-
-	if (ifindex) {
-		rcu_read_lock();
-
-		dev = dev_get_by_index_rcu(net, ifindex);
-		if (dev && netif_is_l3_slave(dev))
-			dev = netdev_master_upper_dev_get_rcu(dev);
-
-		if (dev && netif_is_l3_master(dev) &&
-		    dev->l3mdev_ops->l3mdev_get_saddr)
-			rc = dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
-
-		rcu_read_unlock();
-	}
-
-	return rc;
-}
-EXPORT_SYMBOL_GPL(l3mdev_get_saddr);
-
 int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
 		      struct flowi6 *fl6)
 {
-- 
2.1.4
