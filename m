From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] net: vrf: Implement get_saddr for IPv6
Date: Thu, 16 Jun 2016 16:24:25 -0700
Message-ID: <1466119466-3144-3-git-send-email-dsa@cumulusnetworks.com>
References: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34456 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbcFPXYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:24:36 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so22338986pad.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 16:24:36 -0700 (PDT)
In-Reply-To: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 source address selection needs to consider the real egress route.
Similar to IPv4 implement a get_saddr6 method which is called if
source address has not been set.  The get_saddr6 method does a full
lookup which means pulling a route from the VRF FIB table and properly
considering linklocal/multicast destination addresses. Lookup failures
(eg., unreachable) then cause the source address selection to fail
which gets propagated back to the caller.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c     | 41 +++++++++++++++++++++++++++++++++++++++++
 include/net/l3mdev.h  | 11 +++++++++++
 net/ipv6/ip6_output.c | 12 ++++++++++--
 net/l3mdev/l3mdev.c   | 24 ++++++++++++++++++++++++
 4 files changed, 86 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 32173aa9208e..b3762822b653 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -999,6 +999,46 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 
 	return dst;
 }
+
+/* called under rcu_read_lock */
+static int vrf_get_saddr6(struct net_device *dev, const struct sock *sk,
+			  struct flowi6 *fl6)
+{
+	struct net *net = dev_net(dev);
+	struct dst_entry *dst;
+	struct rt6_info *rt;
+	int err;
+
+	if (rt6_need_strict(&fl6->daddr)) {
+		rt = vrf_ip6_route_lookup(net, dev, fl6, fl6->flowi6_oif,
+					  RT6_LOOKUP_F_IFACE);
+		if (unlikely(!rt))
+			return 0;
+
+		dst = &rt->dst;
+	} else {
+		__u8 flags = fl6->flowi6_flags;
+
+		fl6->flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
+		fl6->flowi6_flags |= FLOWI_FLAG_SKIP_NH_OIF;
+
+		dst = ip6_route_output(net, sk, fl6);
+		rt = (struct rt6_info *)dst;
+
+		fl6->flowi6_flags = flags;
+	}
+
+	err = dst->error;
+	if (!err) {
+		err = ip6_route_get_saddr(net, rt, &fl6->daddr,
+					  sk ? inet6_sk(sk)->srcprefs : 0,
+					  &fl6->saddr);
+	}
+
+	dst_release(dst);
+
+	return err;
+}
 #endif
 
 static const struct l3mdev_ops vrf_l3mdev_ops = {
@@ -1008,6 +1048,7 @@ static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
 #if IS_ENABLED(CONFIG_IPV6)
 	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
+	.l3mdev_get_saddr6	= vrf_get_saddr6,
 #endif
 };
 
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index f8a416ec674c..818fd4f100fc 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -39,6 +39,9 @@ struct l3mdev_ops {
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
 						 struct flowi6 *fl6);
+	int		   (*l3mdev_get_saddr6)(struct net_device *dev,
+						const struct sock *sk,
+						struct flowi6 *fl6);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -140,6 +143,8 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6);
+int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
+		      struct flowi6 *fl6);
 
 static inline
 struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
@@ -230,6 +235,12 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6)
 	return NULL;
 }
 
+static inline int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
+				    struct flowi6 *fl6)
+{
+	return 0;
+}
+
 static inline
 struct sk_buff *l3mdev_ip_rcv(struct sk_buff *skb)
 {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index fd3217579b65..1dfc402d9ad1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -910,6 +910,13 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	int err;
 	int flags = 0;
 
+	if (ipv6_addr_any(&fl6->saddr) && fl6->flowi6_oif &&
+	    (!*dst || !(*dst)->error)) {
+		err = l3mdev_get_saddr6(net, sk, fl6);
+		if (err)
+			goto out_err;
+	}
+
 	/* The correct way to handle this would be to do
 	 * ip6_route_get_saddr, and then ip6_route_output; however,
 	 * the route-specific preferred source forces the
@@ -999,10 +1006,11 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	return 0;
 
 out_err_release:
-	if (err == -ENETUNREACH)
-		IP6_INC_STATS(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	dst_release(*dst);
 	*dst = NULL;
+out_err:
+	if (err == -ENETUNREACH)
+		IP6_INC_STATS(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	return err;
 }
 
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index d90e4ef09e85..c4a1c3e84e12 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -162,6 +162,30 @@ int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4)
 }
 EXPORT_SYMBOL_GPL(l3mdev_get_saddr);
 
+int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
+		      struct flowi6 *fl6)
+{
+	struct net_device *dev;
+	int rc = 0;
+
+	if (fl6->flowi6_oif) {
+		rcu_read_lock();
+
+		dev = dev_get_by_index_rcu(net, fl6->flowi6_oif);
+		if (dev && netif_is_l3_slave(dev))
+			dev = netdev_master_upper_dev_get_rcu(dev);
+
+		if (dev && netif_is_l3_master(dev) &&
+		    dev->l3mdev_ops->l3mdev_get_saddr6)
+			rc = dev->l3mdev_ops->l3mdev_get_saddr6(dev, sk, fl6);
+
+		rcu_read_unlock();
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(l3mdev_get_saddr6);
+
 /**
  *	l3mdev_fib_rule_match - Determine if flowi references an
  *				L3 master device
-- 
2.1.4
