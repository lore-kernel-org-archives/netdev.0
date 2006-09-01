From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/8] address: Convert address addition to new netlink api
Date: Fri, 01 Sep 2006 23:39:58 +0200
Message-ID: <20060901214014.222216381@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:65424 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750963AbWIAVlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:13 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_newaddr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:14:47.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:14.000000000 +0200
@@ -2868,6 +2868,29 @@
 	spin_unlock_bh(&addrconf_verify_lock);
 }
 
+static struct in6_addr *extract_addr(struct nlattr *addr, struct nlattr *local)
+{
+	struct in6_addr *pfx = NULL;
+
+	if (addr)
+		pfx = nla_data(addr);
+
+	if (local) {
+		if (pfx && nla_memcmp(local, pfx, sizeof(*pfx)))
+			pfx = NULL;
+		else
+			pfx = nla_data(local);
+	}
+
+	return pfx;
+}
+
+static struct nla_policy ifa_ipv6_policy[IFA_MAX+1] __read_mostly = {
+	[IFA_ADDRESS]		= { .len = sizeof(struct in6_addr) },
+	[IFA_LOCAL]		= { .len = sizeof(struct in6_addr) },
+	[IFA_CACHEINFO]		= { .len = sizeof(struct ifa_cacheinfo) },
+};
+
 static int
 inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
@@ -2945,46 +2968,41 @@
 static int
 inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct rtattr  **rta = arg;
-	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
+	struct ifaddrmsg *ifm;
+	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *pfx;
-	__u32 valid_lft = INFINITY_LIFE_TIME, prefered_lft = INFINITY_LIFE_TIME;
+	u32 valid_lft, preferred_lft;
+	int err;
 
-	pfx = NULL;
-	if (rta[IFA_ADDRESS-1]) {
-		if (RTA_PAYLOAD(rta[IFA_ADDRESS-1]) < sizeof(*pfx))
-			return -EINVAL;
-		pfx = RTA_DATA(rta[IFA_ADDRESS-1]);
-	}
-	if (rta[IFA_LOCAL-1]) {
-		if (RTA_PAYLOAD(rta[IFA_LOCAL-1]) < sizeof(*pfx) ||
-		    (pfx && memcmp(pfx, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*pfx))))
-			return -EINVAL;
-		pfx = RTA_DATA(rta[IFA_LOCAL-1]);
-	}
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
+	if (err < 0)
+		return err;
+
+	ifm = nlmsg_data(nlh);
+	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL]);
 	if (pfx == NULL)
 		return -EINVAL;
 
-	if (rta[IFA_CACHEINFO-1]) {
+	if (tb[IFA_CACHEINFO]) {
 		struct ifa_cacheinfo *ci;
-		if (RTA_PAYLOAD(rta[IFA_CACHEINFO-1]) < sizeof(*ci))
-			return -EINVAL;
-		ci = RTA_DATA(rta[IFA_CACHEINFO-1]);
+
+		ci = nla_data(tb[IFA_CACHEINFO]);
 		valid_lft = ci->ifa_valid;
-		prefered_lft = ci->ifa_prefered;
+		preferred_lft = ci->ifa_prefered;
+	} else {
+		preferred_lft = INFINITY_LIFE_TIME;
+		valid_lft = INFINITY_LIFE_TIME;
 	}
 
 	if (nlh->nlmsg_flags & NLM_F_REPLACE) {
-		int ret;
-		ret = inet6_addr_modify(ifm->ifa_index, pfx,
-					prefered_lft, valid_lft);
-		if (ret == 0 || !(nlh->nlmsg_flags & NLM_F_CREATE))
-			return ret;
+		err = inet6_addr_modify(ifm->ifa_index, pfx,
+					preferred_lft, valid_lft);
+		if (err == 0 || !(nlh->nlmsg_flags & NLM_F_CREATE))
+			return err;
 	}
 
 	return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen,
-			      prefered_lft, valid_lft);
-
+			      preferred_lft, valid_lft);
 }
 
 /* Maximum length of ifa_cacheinfo attributes */


-- 
VGER BF report: H 0.0247949
