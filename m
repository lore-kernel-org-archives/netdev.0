From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] ipv6: move peer_addr init into ipv6_add_addr()
Date: Thu,  1 Aug 2013 10:41:27 +0200
Message-ID: <1375346488-1001-2-git-send-email-jiri@resnulli.us>
References: <1375346488-1001-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jbenc@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:64318 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab3HAIli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 04:41:38 -0400
Received: by mail-wi0-f180.google.com with SMTP id f14so1548815wiw.1
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 01:41:34 -0700 (PDT)
In-Reply-To: <1375346488-1001-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/addrconf.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cfdcf7b..a0ce957 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -813,7 +813,8 @@ static u32 inet6_addr_hash(const struct in6_addr *addr)
 /* On success it returns ifp with increased reference count */
 
 static struct inet6_ifaddr *
-ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
+ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
+	      const struct in6_addr *peer_addr, int pfxlen,
 	      int scope, u32 flags)
 {
 	struct inet6_ifaddr *ifa = NULL;
@@ -863,6 +864,8 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	}
 
 	ifa->addr = *addr;
+	if (peer_addr)
+		ifa->peer_addr = *peer_addr;
 
 	spin_lock_init(&ifa->lock);
 	spin_lock_init(&ifa->state_lock);
@@ -1123,8 +1126,8 @@ retry:
 
 	ift = !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ?
-		ipv6_add_addr(idev, &addr, tmp_plen, ipv6_addr_scope(&addr),
-			      addr_flags) : NULL;
+		ipv6_add_addr(idev, &addr, NULL, tmp_plen,
+			      ipv6_addr_scope(&addr), addr_flags) : NULL;
 	if (IS_ERR_OR_NULL(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -2179,7 +2182,8 @@ ok:
 			 */
 			if (!max_addresses ||
 			    ipv6_count_addresses(in6_dev) < max_addresses)
-				ifp = ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
+				ifp = ipv6_add_addr(in6_dev, &addr, NULL,
+						    pinfo->prefix_len,
 						    addr_type&IPV6_ADDR_SCOPE_MASK,
 						    addr_flags);
 
@@ -2455,15 +2459,13 @@ static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *p
 		prefered_lft = timeout;
 	}
 
-	ifp = ipv6_add_addr(idev, pfx, plen, scope, ifa_flags);
+	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags);
 
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->valid_lft = valid_lft;
 		ifp->prefered_lft = prefered_lft;
 		ifp->tstamp = jiffies;
-		if (peer_pfx)
-			ifp->peer_addr = *peer_pfx;
 		spin_unlock_bh(&ifp->lock);
 
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
@@ -2557,7 +2559,7 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 {
 	struct inet6_ifaddr *ifp;
 
-	ifp = ipv6_add_addr(idev, addr, plen, scope, IFA_F_PERMANENT);
+	ifp = ipv6_add_addr(idev, addr, NULL, plen, scope, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &= ~IFA_F_TENTATIVE;
@@ -2683,7 +2685,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 #endif
 
 
-	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, addr_flags);
+	ifp = ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp);
-- 
1.7.11.7
