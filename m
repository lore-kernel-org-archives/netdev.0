From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/8] address: Support NLM_F_EXCL when adding addresses
Date: Fri, 01 Sep 2006 23:40:05 +0200
Message-ID: <20060901214015.161907736@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:7569 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751003AbWIAVlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:49 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_fix_add
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

iproute2 doesn't provide the NLM_F_CREATE flag when adding addresses,
it is assumed to be implied. The existing code issues a check on
said flag when the modify operation fails (likely due to ENOENT)
before continueing to create it, this leads to a hard to predict
result, therefore the NLM_F_CREATE check is removed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:15:25.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:26.000000000 +0200
@@ -2908,24 +2908,14 @@
 	return inet6_addr_del(ifm->ifa_index, pfx, ifm->ifa_prefixlen);
 }
 
-static int
-inet6_addr_modify(int ifindex, struct in6_addr *pfx,
-		  __u32 prefered_lft, __u32 valid_lft)
+static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 prefered_lft,
+			     u32 valid_lft)
 {
-	struct inet6_ifaddr *ifp = NULL;
-	struct net_device *dev;
 	int ifa_flags = 0;
 
-	if ((dev = __dev_get_by_index(ifindex)) == NULL)
-		return -ENODEV;
-
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
 
-	ifp = ipv6_get_ifaddr(pfx, dev, 1);
-	if (ifp == NULL)
-		return -ENOENT;
-
 	if (valid_lft == INFINITY_LIFE_TIME)
 		ifa_flags = IFA_F_PERMANENT;
 	else if (valid_lft >= 0x7FFFFFFF/HZ)
@@ -2947,7 +2937,6 @@
 	spin_unlock_bh(&ifp->lock);
 	if (!(ifp->flags&IFA_F_TENTATIVE))
 		ipv6_ifa_notify(0, ifp);
-	in6_ifa_put(ifp);
 
 	addrconf_verify(0);
 
@@ -2960,6 +2949,8 @@
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *pfx;
+	struct inet6_ifaddr *ifa;
+	struct net_device *dev;
 	u32 valid_lft, preferred_lft;
 	int err;
 
@@ -2983,15 +2974,29 @@
 		valid_lft = INFINITY_LIFE_TIME;
 	}
 
-	if (nlh->nlmsg_flags & NLM_F_REPLACE) {
-		err = inet6_addr_modify(ifm->ifa_index, pfx,
-					preferred_lft, valid_lft);
-		if (err == 0 || !(nlh->nlmsg_flags & NLM_F_CREATE))
-			return err;
+	dev =  __dev_get_by_index(ifm->ifa_index);
+	if (dev == NULL)
+		return -ENODEV;
+
+	ifa = ipv6_get_ifaddr(pfx, dev, 1);
+	if (ifa == NULL) {
+		/*
+		 * It would be best to check for !NLM_F_CREATE here but
+		 * userspace alreay relies on not having to provide this.
+		 */
+		return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen,
+				      preferred_lft, valid_lft);
 	}
 
-	return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen,
-			      preferred_lft, valid_lft);
+	if (nlh->nlmsg_flags & NLM_F_EXCL ||
+	    !(nlh->nlmsg_flags & NLM_F_REPLACE))
+		err = -EEXIST;
+	else
+		err = inet6_addr_modify(ifa, preferred_lft, valid_lft);
+
+	in6_ifa_put(ifa);
+
+	return err;
 }
 
 static void put_ifaddrmsg(struct nlmsghdr *nlh, u8 prefixlen, u8 flags,


-- 
VGER BF report: H 0.192484
