From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/8] address: Add put_cacheinfo() to dump struct cacheinfo
Date: Fri, 01 Sep 2006 23:40:01 +0200
Message-ID: <20060901214014.615928855@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:3473 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750992AbWIAVl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:28 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_put_cacheinfo
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:15:19.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:21.000000000 +0200
@@ -3000,6 +3000,21 @@
 			      preferred_lft, valid_lft);
 }
 
+static int put_cacheinfo(struct sk_buff *skb, unsigned long cstamp,
+			 unsigned long tstamp, u32 preferred, u32 valid)
+{
+	struct ifa_cacheinfo ci;
+
+	ci.cstamp = (u32)(TIME_DELTA(cstamp, INITIAL_JIFFIES) / HZ * 100
+			+ TIME_DELTA(cstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
+	ci.tstamp = (u32)(TIME_DELTA(tstamp, INITIAL_JIFFIES) / HZ * 100
+			+ TIME_DELTA(tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
+	ci.ifa_prefered = preferred;
+	ci.ifa_valid = valid;
+
+	return nla_put(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+}
+
 /* Maximum length of ifa_cacheinfo attributes */
 #define INET6_IFADDR_RTA_SPACE \
 		RTA_SPACE(16) /* IFA_ADDRESS */ + \
@@ -3010,8 +3025,8 @@
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
-	struct ifa_cacheinfo ci;
 	unsigned char	 *b = skb->tail;
+	u32 preferred, valid;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
 	ifm = NLMSG_DATA(nlh);
@@ -3028,23 +3043,22 @@
 	ifm->ifa_index = ifa->idev->dev->ifindex;
 	RTA_PUT(skb, IFA_ADDRESS, 16, &ifa->addr);
 	if (!(ifa->flags&IFA_F_PERMANENT)) {
-		ci.ifa_prefered = ifa->prefered_lft;
-		ci.ifa_valid = ifa->valid_lft;
-		if (ci.ifa_prefered != INFINITY_LIFE_TIME) {
+		preferred = ifa->prefered_lft;
+		valid = ifa->valid_lft;
+		if (preferred != INFINITY_LIFE_TIME) {
 			long tval = (jiffies - ifa->tstamp)/HZ;
-			ci.ifa_prefered -= tval;
-			if (ci.ifa_valid != INFINITY_LIFE_TIME)
-				ci.ifa_valid -= tval;
+			preferred -= tval;
+			if (valid != INFINITY_LIFE_TIME)
+				valid -= tval;
 		}
 	} else {
-		ci.ifa_prefered = INFINITY_LIFE_TIME;
-		ci.ifa_valid = INFINITY_LIFE_TIME;
+		preferred = INFINITY_LIFE_TIME;
+		valid = INFINITY_LIFE_TIME;
 	}
-	ci.cstamp = (__u32)(TIME_DELTA(ifa->cstamp, INITIAL_JIFFIES) / HZ * 100
-		    + TIME_DELTA(ifa->cstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
-	ci.tstamp = (__u32)(TIME_DELTA(ifa->tstamp, INITIAL_JIFFIES) / HZ * 100
-		    + TIME_DELTA(ifa->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
-	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+
+	if (put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
+		goto rtattr_failure;
+
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
@@ -3059,7 +3073,6 @@
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
-	struct ifa_cacheinfo ci;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
@@ -3072,15 +3085,11 @@
 		ifm->ifa_scope = RT_SCOPE_SITE;
 	ifm->ifa_index = ifmca->idev->dev->ifindex;
 	RTA_PUT(skb, IFA_MULTICAST, 16, &ifmca->mca_addr);
-	ci.cstamp = (__u32)(TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.tstamp = (__u32)(TIME_DELTA(ifmca->mca_tstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifmca->mca_tstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.ifa_prefered = INFINITY_LIFE_TIME;
-	ci.ifa_valid = INFINITY_LIFE_TIME;
-	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+
+	if (put_cacheinfo(skb, ifmca->mca_cstamp, ifmca->mca_tstamp,
+			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0)
+		goto rtattr_failure;
+
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
@@ -3095,7 +3104,6 @@
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
-	struct ifa_cacheinfo ci;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
@@ -3108,15 +3116,11 @@
 		ifm->ifa_scope = RT_SCOPE_SITE;
 	ifm->ifa_index = ifaca->aca_idev->dev->ifindex;
 	RTA_PUT(skb, IFA_ANYCAST, 16, &ifaca->aca_addr);
-	ci.cstamp = (__u32)(TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.tstamp = (__u32)(TIME_DELTA(ifaca->aca_tstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifaca->aca_tstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.ifa_prefered = INFINITY_LIFE_TIME;
-	ci.ifa_valid = INFINITY_LIFE_TIME;
-	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+
+	if (put_cacheinfo(skb, ifaca->aca_cstamp, ifaca->aca_tstamp,
+			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0)
+		goto rtattr_failure;
+
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 


-- 
VGER BF report: H 0.000143698
