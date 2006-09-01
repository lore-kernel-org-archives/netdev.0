From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/8] address: Convert address dumping to new netlink api
Date: Fri, 01 Sep 2006 23:40:03 +0200
Message-ID: <20060901214014.912617720@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5521 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750998AbWIAVlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:39 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_fill_ifaddr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaces INET6_IFADDR_RTA_SPACE with a new function calculating
the total required message size for all address messages.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:15:22.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:24.000000000 +0200
@@ -3040,23 +3040,27 @@
 		return RT_SCOPE_UNIVERSE;
 }
 
-/* Maximum length of ifa_cacheinfo attributes */
-#define INET6_IFADDR_RTA_SPACE \
-		RTA_SPACE(16) /* IFA_ADDRESS */ + \
-		RTA_SPACE(sizeof(struct ifa_cacheinfo)) /* CACHEINFO */
+static inline int inet6_ifaddr_msgsize(void)
+{
+	return nlmsg_total_size(sizeof(struct ifaddrmsg) +
+				nla_total_size(16) +
+				nla_total_size(sizeof(struct ifa_cacheinfo)) +
+				128);
+}
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
 	u32 preferred, valid;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
 	put_ifaddrmsg(nlh, ifa->prefix_len, ifa->flags, rt_scope(ifa->scope),
 		      ifa->idev->dev->ifindex);
 
-	RTA_PUT(skb, IFA_ADDRESS, 16, &ifa->addr);
 	if (!(ifa->flags&IFA_F_PERMANENT)) {
 		preferred = ifa->prefered_lft;
 		valid = ifa->valid_lft;
@@ -3071,72 +3075,57 @@
 		valid = INFINITY_LIFE_TIME;
 	}
 
-	if (put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
-		goto rtattr_failure;
-
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+	if (nla_put(skb, IFA_ADDRESS, 16, &ifa->addr) < 0 ||
+	    put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
+		return nlmsg_cancel(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+	return nlmsg_end(skb, nlh);
 }
 
 static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
 				u32 pid, u32 seq, int event, u16 flags)
 {
 	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
 	u8 scope = RT_SCOPE_UNIVERSE;
 	int ifindex = ifmca->idev->dev->ifindex;
 
 	if (ipv6_addr_scope(&ifmca->mca_addr) & IFA_SITE)
 		scope = RT_SCOPE_SITE;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
-	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
-	RTA_PUT(skb, IFA_MULTICAST, 16, &ifmca->mca_addr);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
 
-	if (put_cacheinfo(skb, ifmca->mca_cstamp, ifmca->mca_tstamp,
+	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
+	if (nla_put(skb, IFA_MULTICAST, 16, &ifmca->mca_addr) < 0 ||
+	    put_cacheinfo(skb, ifmca->mca_cstamp, ifmca->mca_tstamp,
 			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0)
-		goto rtattr_failure;
-
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+		return nlmsg_cancel(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+	return nlmsg_end(skb, nlh);
 }
 
 static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
 				u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
 	u8 scope = RT_SCOPE_UNIVERSE;
 	int ifindex = ifaca->aca_idev->dev->ifindex;
 
 	if (ipv6_addr_scope(&ifaca->aca_addr) & IFA_SITE)
 		scope = RT_SCOPE_SITE;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
-	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
-	RTA_PUT(skb, IFA_ANYCAST, 16, &ifaca->aca_addr);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
 
-	if (put_cacheinfo(skb, ifaca->aca_cstamp, ifaca->aca_tstamp,
+	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
+	if (nla_put(skb, IFA_ANYCAST, 16, &ifaca->aca_addr) < 0 ||
+	    put_cacheinfo(skb, ifaca->aca_cstamp, ifaca->aca_tstamp,
 			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0)
-		goto rtattr_failure;
+		return nlmsg_cancel(skb, nlh);
 
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
-
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+	return nlmsg_end(skb, nlh);
 }
 
 enum addr_type_t
@@ -3256,7 +3245,6 @@
 	struct net_device *dev = NULL;
 	struct inet6_ifaddr *ifa;
 	struct sk_buff *skb;
-	int payload = sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
@@ -3278,7 +3266,7 @@
 		goto errout;
 	}
 
-	if ((skb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL)) == NULL) {
+	if ((skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_KERNEL)) == NULL) {
 		err = -ENOBUFS;
 		goto errout_ifa;
 	}
@@ -3300,10 +3288,9 @@
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
-	int payload = sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(nlmsg_total_size(payload), GFP_ATOMIC);
+	skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 


-- 
VGER BF report: H 0.00178487
