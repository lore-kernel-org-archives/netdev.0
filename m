From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH v2 1/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Tue,  7 Jan 2014 15:39:12 +0100
Message-ID: <1389105553-21230-2-git-send-email-thaller@redhat.com>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com>
 <1389105553-21230-1-git-send-email-thaller@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com,
	Thomas Haller <thaller@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbaAGOjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 09:39:39 -0500
In-Reply-To: <1389105553-21230-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding/modifying an IPv6 address, the userspace application needs
a way to suppress adding a prefix route. This is for example relevant
together with IFA_F_MANAGERTEMPADDR, where userspace creates autoconf
generated addresses, but depending on on-link, no route for the
prefix should be added.

Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 include/uapi/linux/if_addr.h |  1 +
 net/ipv6/addrconf.c          | 18 ++++++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index cfed10b..dea10a8 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -49,6 +49,7 @@ enum {
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
 #define IFA_F_MANAGETEMPADDR	0x100
+#define IFA_F_NOPREFIXROUTE	0x200
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 31f75ea..1bc575f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2433,8 +2433,11 @@ static int inet6_addr_add(struct net *net, int ifindex,
 			    valid_lft, prefered_lft);
 
 	if (!IS_ERR(ifp)) {
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
-				      expires, flags);
+		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
+			addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
+					      expires, flags);
+		}
+
 		/*
 		 * Note that section 3.1 of RFC 4429 indicates
 		 * that the Optimistic flag should not be set for
@@ -3658,7 +3661,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	spin_lock_bh(&ifp->lock);
 	was_managetempaddr = ifp->flags & IFA_F_MANAGETEMPADDR;
 	ifp->flags &= ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD |
-			IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR);
+			IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR | IFA_F_NOPREFIXROUTE);
 	ifp->flags |= ifa_flags;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
@@ -3668,8 +3671,10 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	if (!(ifp->flags&IFA_F_TENTATIVE))
 		ipv6_ifa_notify(0, ifp);
 
-	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
-			      expires, flags);
+	if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
+				      expires, flags);
+	}
 
 	if (was_managetempaddr || ifp->flags & IFA_F_MANAGETEMPADDR) {
 		if (was_managetempaddr && !(ifp->flags & IFA_F_MANAGETEMPADDR))
@@ -3723,7 +3728,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
 
 	/* We ignore other flags so far. */
-	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR;
+	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
+		     IFA_F_NOPREFIXROUTE;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
-- 
1.8.4.2
