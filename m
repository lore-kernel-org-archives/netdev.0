From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 14/27] afnetns: check for afnetns in inet6_bind
Date: Mon, 13 Mar 2017 00:01:38 +0100
Message-ID: <20170312230151.5185-15-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48457 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935669AbdCLXCU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:20 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 586CE20749
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:05 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id B4314240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:04 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/addrconf.h |  3 ++-
 net/ipv6/addrconf.c    | 12 ++++++++++--
 net/ipv6/af_inet6.c    |  7 +++++--
 net/ipv6/ndisc.c       |  4 ++--
 net/ipv6/route.c       |  2 +-
 5 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 17c6fd84e28780..e3f1920ca57968 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -63,7 +63,8 @@ int addrconf_set_dstaddr(struct net *net, void __user *arg);
 
 int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 		  const struct net_device *dev, int strict);
-int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
+int ipv6_chk_addr_and_flags(struct net *net, struct afnetns *afnetns,
+			    const struct in6_addr *addr,
 			    const struct net_device *dev, int strict,
 			    u32 banned_flags);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c67f6d3c5b9a7a..2e546584695118 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1776,11 +1776,13 @@ static int ipv6_count_addresses(struct inet6_dev *idev)
 int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 		  const struct net_device *dev, int strict)
 {
-	return ipv6_chk_addr_and_flags(net, addr, dev, strict, IFA_F_TENTATIVE);
+	return ipv6_chk_addr_and_flags(net, NULL, addr, dev, strict,
+				       IFA_F_TENTATIVE);
 }
 EXPORT_SYMBOL(ipv6_chk_addr);
 
-int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
+int ipv6_chk_addr_and_flags(struct net *net, struct afnetns *afnetns,
+			    const struct in6_addr *addr,
 			    const struct net_device *dev, int strict,
 			    u32 banned_flags)
 {
@@ -1792,6 +1794,12 @@ int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
 	hlist_for_each_entry_rcu(ifp, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
+
+#if IS_ENABLED(CONFIG_AFNETNS)
+		if (afnetns && ifp->afnetns != afnetns)
+			continue;
+#endif
+
 		/* Decouple optimistic from tentative for evaluation here.
 		 * Ban optimistic addresses explicitly, when required.
 		 */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f9367c507573bc..ffb116297c0950 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -362,8 +362,11 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
 				if (!net->ipv6.sysctl.ip_nonlocal_bind &&
 				    !(inet->freebind || inet->transparent) &&
-				    !ipv6_chk_addr(net, &addr->sin6_addr,
-						   dev, 0)) {
+				    !ipv6_chk_addr_and_flags(net,
+							     sock_afnetns(sk),
+							     &addr->sin6_addr,
+							     dev, 0,
+							     IFA_F_TENTATIVE)) {
 					err = -EADDRNOTAVAIL;
 					goto out_unlock;
 				}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7ebac630d3c603..4415659f8cfb0d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -693,8 +693,8 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	struct in6_addr *target = (struct in6_addr *)&neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 
-	if (skb && ipv6_chk_addr_and_flags(dev_net(dev), &ipv6_hdr(skb)->saddr,
-					   dev, 1,
+	if (skb && ipv6_chk_addr_and_flags(dev_net(dev), NULL,
+					   &ipv6_hdr(skb)->saddr, dev, 1,
 					   IFA_F_TENTATIVE|IFA_F_OPTIMISTIC))
 		saddr = &ipv6_hdr(skb)->saddr;
 	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 229bfcc451ef50..87d87c5413d71e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2007,7 +2007,7 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 		 * prefix route was assigned to, which might be non-loopback.
 		 */
 		err = -EINVAL;
-		if (ipv6_chk_addr_and_flags(net, gw_addr,
+		if (ipv6_chk_addr_and_flags(net, NULL, gw_addr,
 					    gwa_type & IPV6_ADDR_LINKLOCAL ?
 					    dev : NULL, 0, 0))
 			goto out;
-- 
2.9.3
