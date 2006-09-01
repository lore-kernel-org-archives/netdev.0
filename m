From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/8] address: Add put_ifaddrmsg() and rt_scope()
Date: Fri, 01 Sep 2006 23:40:02 +0200
Message-ID: <20060901214014.779258207@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:4753 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750993AbWIAVle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:34 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_put_ifaddrmsg
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:15:21.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:22.000000000 +0200
@@ -3000,6 +3000,19 @@
 			      preferred_lft, valid_lft);
 }
 
+static void put_ifaddrmsg(struct nlmsghdr *nlh, u8 prefixlen, u8 flags,
+			  u8 scope, int ifindex)
+{
+	struct ifaddrmsg *ifm;
+
+	ifm = nlmsg_data(nlh);
+	ifm->ifa_family = AF_INET6;
+	ifm->ifa_prefixlen = prefixlen;
+	ifm->ifa_flags = flags;
+	ifm->ifa_scope = scope;
+	ifm->ifa_index = ifindex;
+}
+
 static int put_cacheinfo(struct sk_buff *skb, unsigned long cstamp,
 			 unsigned long tstamp, u32 preferred, u32 valid)
 {
@@ -3015,6 +3028,18 @@
 	return nla_put(skb, IFA_CACHEINFO, sizeof(ci), &ci);
 }
 
+static inline int rt_scope(int ifa_scope)
+{
+	if (ifa_scope & IFA_HOST)
+		return RT_SCOPE_HOST;
+	else if (ifa_scope & IFA_LINK)
+		return RT_SCOPE_LINK;
+	else if (ifa_scope & IFA_SITE)
+		return RT_SCOPE_SITE;
+	else
+		return RT_SCOPE_UNIVERSE;
+}
+
 /* Maximum length of ifa_cacheinfo attributes */
 #define INET6_IFADDR_RTA_SPACE \
 		RTA_SPACE(16) /* IFA_ADDRESS */ + \
@@ -3023,24 +3048,14 @@
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
-	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 	u32 preferred, valid;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
-	ifm = NLMSG_DATA(nlh);
-	ifm->ifa_family = AF_INET6;
-	ifm->ifa_prefixlen = ifa->prefix_len;
-	ifm->ifa_flags = ifa->flags;
-	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
-	if (ifa->scope&IFA_HOST)
-		ifm->ifa_scope = RT_SCOPE_HOST;
-	else if (ifa->scope&IFA_LINK)
-		ifm->ifa_scope = RT_SCOPE_LINK;
-	else if (ifa->scope&IFA_SITE)
-		ifm->ifa_scope = RT_SCOPE_SITE;
-	ifm->ifa_index = ifa->idev->dev->ifindex;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	put_ifaddrmsg(nlh, ifa->prefix_len, ifa->flags, rt_scope(ifa->scope),
+		      ifa->idev->dev->ifindex);
+
 	RTA_PUT(skb, IFA_ADDRESS, 16, &ifa->addr);
 	if (!(ifa->flags&IFA_F_PERMANENT)) {
 		preferred = ifa->prefered_lft;
@@ -3071,19 +3086,16 @@
 static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
 				u32 pid, u32 seq, int event, u16 flags)
 {
-	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
+	u8 scope = RT_SCOPE_UNIVERSE;
+	int ifindex = ifmca->idev->dev->ifindex;
+
+	if (ipv6_addr_scope(&ifmca->mca_addr) & IFA_SITE)
+		scope = RT_SCOPE_SITE;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
-	ifm = NLMSG_DATA(nlh);
-	ifm->ifa_family = AF_INET6;	
-	ifm->ifa_prefixlen = 128;
-	ifm->ifa_flags = IFA_F_PERMANENT;
-	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
-	if (ipv6_addr_scope(&ifmca->mca_addr)&IFA_SITE)
-		ifm->ifa_scope = RT_SCOPE_SITE;
-	ifm->ifa_index = ifmca->idev->dev->ifindex;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
 	RTA_PUT(skb, IFA_MULTICAST, 16, &ifmca->mca_addr);
 
 	if (put_cacheinfo(skb, ifmca->mca_cstamp, ifmca->mca_tstamp,
@@ -3102,19 +3114,16 @@
 static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
 				u32 pid, u32 seq, int event, unsigned int flags)
 {
-	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
+	u8 scope = RT_SCOPE_UNIVERSE;
+	int ifindex = ifaca->aca_idev->dev->ifindex;
+
+	if (ipv6_addr_scope(&ifaca->aca_addr) & IFA_SITE)
+		scope = RT_SCOPE_SITE;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
-	ifm = NLMSG_DATA(nlh);
-	ifm->ifa_family = AF_INET6;	
-	ifm->ifa_prefixlen = 128;
-	ifm->ifa_flags = IFA_F_PERMANENT;
-	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
-	if (ipv6_addr_scope(&ifaca->aca_addr)&IFA_SITE)
-		ifm->ifa_scope = RT_SCOPE_SITE;
-	ifm->ifa_index = ifaca->aca_idev->dev->ifindex;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
 	RTA_PUT(skb, IFA_ANYCAST, 16, &ifaca->aca_addr);
 
 	if (put_cacheinfo(skb, ifaca->aca_cstamp, ifaca->aca_tstamp,


-- 
VGER BF report: H 7.82266e-05
