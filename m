From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] ipv6: prevent race between address creation and removal
Date: Thu,  1 Aug 2013 10:41:28 +0200
Message-ID: <1375346488-1001-3-git-send-email-jiri@resnulli.us>
References: <1375346488-1001-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jbenc@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:65361 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab3HAIli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 04:41:38 -0400
Received: by mail-wg0-f49.google.com with SMTP id y10so1397313wgg.28
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 01:41:37 -0700 (PDT)
In-Reply-To: <1375346488-1001-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>

There's a race in IPv6 automatic addess assingment. The address is created
with zero lifetime when it's added to various address lists. Before it gets
assigned the correct lifetime, there's a window where a new address may be
configured. This causes the semi-initiated address to be deleted in
addrconf_verify.

This was discovered as a reference leak caused by concurrent run of
__ipv6_ifa_notify for both RTM_NEWADDR and RTM_DELADDR with the same
address.

Fix this by setting the lifetime before the address is added to
inet6_addr_lst.

A few notes:

1. In addrconf_prefix_rcv, by setting update_lft to zero, the
   if (update_lft) { ... } condition is no longer executed for newly
   created addresses. This is okay, as the ifp fields are set in
   ipv6_add_addr now and ipv6_ifa_notify is called (and has been called)
   through addrconf_dad_start.

2. The removal of the whole block under ifp->lock in inet6_addr_add is okay,
   too, as tstamp is initialized to jiffies in ipv6_add_addr.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/addrconf.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a0ce957..da4241c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -815,7 +815,7 @@ static u32 inet6_addr_hash(const struct in6_addr *addr)
 static struct inet6_ifaddr *
 ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	      const struct in6_addr *peer_addr, int pfxlen,
-	      int scope, u32 flags)
+	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft)
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
@@ -875,6 +875,8 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa->scope = scope;
 	ifa->prefix_len = pfxlen;
 	ifa->flags = flags | IFA_F_TENTATIVE;
+	ifa->valid_lft = valid_lft;
+	ifa->prefered_lft = prefered_lft;
 	ifa->cstamp = ifa->tstamp = jiffies;
 	ifa->tokenized = false;
 
@@ -1127,7 +1129,8 @@ retry:
 	ift = !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ?
 		ipv6_add_addr(idev, &addr, NULL, tmp_plen,
-			      ipv6_addr_scope(&addr), addr_flags) : NULL;
+			      ipv6_addr_scope(&addr), addr_flags,
+			      tmp_valid_lft, tmp_prefered_lft) : NULL;
 	if (IS_ERR_OR_NULL(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -1139,8 +1142,6 @@ retry:
 
 	spin_lock_bh(&ift->lock);
 	ift->ifpub = ifp;
-	ift->valid_lft = tmp_valid_lft;
-	ift->prefered_lft = tmp_prefered_lft;
 	ift->cstamp = now;
 	ift->tstamp = tmp_tstamp;
 	spin_unlock_bh(&ift->lock);
@@ -2185,14 +2186,16 @@ ok:
 				ifp = ipv6_add_addr(in6_dev, &addr, NULL,
 						    pinfo->prefix_len,
 						    addr_type&IPV6_ADDR_SCOPE_MASK,
-						    addr_flags);
+						    addr_flags, valid_lft,
+						    prefered_lft);
 
 			if (IS_ERR_OR_NULL(ifp)) {
 				in6_dev_put(in6_dev);
 				return;
 			}
 
-			update_lft = create = 1;
+			update_lft = 0;
+			create = 1;
 			ifp->cstamp = jiffies;
 			ifp->tokenized = tokenized;
 			addrconf_dad_start(ifp);
@@ -2213,7 +2216,7 @@ ok:
 				stored_lft = ifp->valid_lft - (now - ifp->tstamp) / HZ;
 			else
 				stored_lft = 0;
-			if (!update_lft && stored_lft) {
+			if (!update_lft && !create && stored_lft) {
 				if (valid_lft > MIN_VALID_LIFETIME ||
 				    valid_lft > stored_lft)
 					update_lft = 1;
@@ -2459,15 +2462,10 @@ static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *p
 		prefered_lft = timeout;
 	}
 
-	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags);
+	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags,
+			    valid_lft, prefered_lft);
 
 	if (!IS_ERR(ifp)) {
-		spin_lock_bh(&ifp->lock);
-		ifp->valid_lft = valid_lft;
-		ifp->prefered_lft = prefered_lft;
-		ifp->tstamp = jiffies;
-		spin_unlock_bh(&ifp->lock);
-
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
 				      expires, flags);
 		/*
@@ -2559,7 +2557,8 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 {
 	struct inet6_ifaddr *ifp;
 
-	ifp = ipv6_add_addr(idev, addr, NULL, plen, scope, IFA_F_PERMANENT);
+	ifp = ipv6_add_addr(idev, addr, NULL, plen,
+			    scope, IFA_F_PERMANENT, 0, 0);
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &= ~IFA_F_TENTATIVE;
@@ -2685,7 +2684,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 #endif
 
 
-	ifp = ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags);
+	ifp = ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags, 0, 0);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp);
-- 
1.7.11.7
