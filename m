From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 07/11] ipv6/addrconf: add an helper for inet6 address lookup
Date: Fri, 22 Sep 2017 23:06:31 +0200
Message-ID: <7c11317cb4794fcd016caeff8d23da3bd2911d7d.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42882 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752730AbdIVVHK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:07:10 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reduce code duplication and will simplify follow-up patch

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/addrconf.c | 65 +++++++++++++++++++++++++----------------------------
 1 file changed, 31 insertions(+), 34 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c2e2a78787ec..5940062cac8d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1796,35 +1796,46 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 }
 EXPORT_SYMBOL(ipv6_chk_addr);
 
+/* called under RCU lock with bh disabled */
+static struct inet6_ifaddr *ipv6_lookup_ifaddr_rcu_bh(struct net *net,
+						    const struct in6_addr *addr)
+{
+	unsigned int hash = inet6_addr_hash(addr);
+	struct inet6_ifaddr *ifp;
+
+	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst)
+		if (net_eq(dev_net(ifp->idev->dev), net) &&
+		    ipv6_addr_equal(&ifp->addr, addr))
+			return ifp;
+
+	return NULL;
+}
+
 int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
 			    const struct net_device *dev, int strict,
 			    u32 banned_flags)
 {
 	struct inet6_ifaddr *ifp;
-	unsigned int hash = inet6_addr_hash(addr);
 	u32 ifp_flags;
+	int ret = 0;
 
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(ifp, &inet6_addr_lst[hash], addr_lst) {
-		if (!net_eq(dev_net(ifp->idev->dev), net))
-			continue;
+	ifp = ipv6_lookup_ifaddr_rcu_bh(net, addr);
+	if (ifp) {
 		/* Decouple optimistic from tentative for evaluation here.
 		 * Ban optimistic addresses explicitly, when required.
 		 */
 		ifp_flags = (ifp->flags&IFA_F_OPTIMISTIC)
 			    ? (ifp->flags&~IFA_F_TENTATIVE)
 			    : ifp->flags;
-		if (ipv6_addr_equal(&ifp->addr, addr) &&
-		    !(ifp_flags&banned_flags) &&
+		if (!(ifp_flags&banned_flags) &&
 		    (!dev || ifp->idev->dev == dev ||
-		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
-			rcu_read_unlock_bh();
-			return 1;
-		}
+		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict)))
+			ret = 1;
 	}
 
 	rcu_read_unlock_bh();
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL(ipv6_chk_addr_and_flags);
 
@@ -1900,20 +1911,13 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 				     struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr *ifp, *result = NULL;
-	unsigned int hash = inet6_addr_hash(addr);
 
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
-		if (!net_eq(dev_net(ifp->idev->dev), net))
-			continue;
-		if (ipv6_addr_equal(&ifp->addr, addr)) {
-			if (!dev || ifp->idev->dev == dev ||
-			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict)) {
-				result = ifp;
-				in6_ifa_hold(ifp);
-				break;
-			}
-		}
+	ifp = ipv6_lookup_ifaddr_rcu_bh(net, addr);
+	if (ifp && (!dev || ifp->idev->dev == dev ||
+		    !(ifp->scope & (IFA_LINK|IFA_HOST) || strict))) {
+		result = ifp;
+		in6_ifa_hold(ifp);
 	}
 	rcu_read_unlock_bh();
 
@@ -4226,20 +4230,13 @@ void if6_proc_exit(void)
 /* Check if address is a home address configured on any interface. */
 int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
 {
-	int ret = 0;
 	struct inet6_ifaddr *ifp = NULL;
-	unsigned int hash = inet6_addr_hash(addr);
+	int ret = 0;
 
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
-		if (!net_eq(dev_net(ifp->idev->dev), net))
-			continue;
-		if (ipv6_addr_equal(&ifp->addr, addr) &&
-		    (ifp->flags & IFA_F_HOMEADDRESS)) {
-			ret = 1;
-			break;
-		}
-	}
+	ifp = ipv6_lookup_ifaddr_rcu_bh(net, addr);
+	if (ifp && ifp->flags & IFA_F_HOMEADDRESS)
+		ret = 1;
 	rcu_read_unlock_bh();
 	return ret;
 }
-- 
2.13.5
