From: Erik Kline <ek@google.com>
Subject: [PATCH net] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 21 Jan 2015 16:02:39 +0900
Message-ID: <1421823759-15098-1-git-send-email-ek@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net,
	Erik Kline <ek@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:56326 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbbAUHCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 02:02:50 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so6699843pab.12
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 23:02:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4429 ("Optimistic DAD") states that optimistic addresses
should be treated as deprecated addresses.  From section 2.1:

   Unless noted otherwise, components of the IPv6 protocol stack
   should treat addresses in the Optimistic state equivalently to
   those in the Deprecated state, indicating that the address is
   available for use but should not be used if another suitable
   address is available.

Optimistic addresses are indeed avoided when other addresses are
available (i.e. at source address selection time), but they have
not heretofore been available for things like explicit bind() and
sendmsg() with struct in6_pktinfo, etc.

This change makes optimistic addresses treated more like
deprecated addresses than tentative ones.

Signed-off-by: Erik Kline <ek@google.com>
---
 include/net/addrconf.h |  3 +++
 net/ipv6/addrconf.c    | 14 ++++++++++++--
 net/ipv6/ndisc.c       |  3 ++-
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index d13573b..80456f7 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -62,6 +62,9 @@ int addrconf_set_dstaddr(struct net *net, void __user *arg);
 
 int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 		  const struct net_device *dev, int strict);
+int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
+			    const struct net_device *dev, int strict,
+			    u32 banned_flags);
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f7c8bbe..422976b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1519,6 +1519,14 @@ static int ipv6_count_addresses(struct inet6_dev *idev)
 int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 		  const struct net_device *dev, int strict)
 {
+	return ipv6_chk_addr_and_flags(net, addr, dev, strict, 0);
+}
+EXPORT_SYMBOL(ipv6_chk_addr);
+
+int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
+			    const struct net_device *dev, int strict,
+			    u32 banned_flags)
+{
 	struct inet6_ifaddr *ifp;
 	unsigned int hash = inet6_addr_hash(addr);
 
@@ -1527,7 +1535,9 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
-		    !(ifp->flags&IFA_F_TENTATIVE) &&
+		    (!(ifp->flags&IFA_F_TENTATIVE) ||
+		     ifp->flags&IFA_F_OPTIMISTIC) &&
+		    !(ifp->flags&banned_flags) &&
 		    (dev == NULL || ifp->idev->dev == dev ||
 		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
 			rcu_read_unlock_bh();
@@ -1538,7 +1548,7 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 	rcu_read_unlock_bh();
 	return 0;
 }
-EXPORT_SYMBOL(ipv6_chk_addr);
+EXPORT_SYMBOL(ipv6_chk_addr_and_flags);
 
 static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 			       struct net_device *dev)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 6828667..a726c7a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -655,7 +655,8 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	struct in6_addr *target = (struct in6_addr *)&neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 
-	if (skb && ipv6_chk_addr(dev_net(dev), &ipv6_hdr(skb)->saddr, dev, 1))
+	if (skb && ipv6_chk_addr_and_flags(dev_net(dev), &ipv6_hdr(skb)->saddr,
+					   dev, 1, IFA_F_OPTIMISTIC))
 		saddr = &ipv6_hdr(skb)->saddr;
 	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
 	if (probes < 0) {
-- 
2.2.0.rc0.207.ga3a616c
