From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/9] [IPV4]: Convert address deletion to new netlink api
Date: Sat, 05 Aug 2006 00:00:04 +0200
Message-ID: <20060805003536.455996896@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:6125 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422678AbWHEAnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:19 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv4_deladdr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes various unvalidated netlink attributes causing
memory corruptions when left empty by userspace.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.orig/net/ipv4/devinet.c
+++ net-2.6.19/net/ipv4/devinet.c
@@ -430,34 +430,48 @@ struct in_ifaddr *inet_ifa_byprefix(stru
 
 static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct rtattr **rta = arg;
+	struct nlattr *tb[IFA_MAX+1];
 	struct in_device *in_dev;
-	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
+	struct ifaddrmsg *ifm;
 	struct in_ifaddr *ifa, **ifap;
+	int err = -EINVAL;
 
 	ASSERT_RTNL();
 
-	if ((in_dev = inetdev_by_index(ifm->ifa_index)) == NULL)
-		goto out;
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
+	if (err < 0)
+		goto errout;
+
+	ifm = nlmsg_data(nlh);
+	in_dev = inetdev_by_index(ifm->ifa_index);
+	if (in_dev == NULL) {
+		err = -ENODEV;
+		goto errout;
+	}
+
 	__in_dev_put(in_dev);
 
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
-		if ((rta[IFA_LOCAL - 1] &&
-		     memcmp(RTA_DATA(rta[IFA_LOCAL - 1]),
-			    &ifa->ifa_local, 4)) ||
-		    (rta[IFA_LABEL - 1] &&
-		     rtattr_strcmp(rta[IFA_LABEL - 1], ifa->ifa_label)) ||
-		    (rta[IFA_ADDRESS - 1] &&
-		     (ifm->ifa_prefixlen != ifa->ifa_prefixlen ||
-		      !inet_ifa_match(*(u32*)RTA_DATA(rta[IFA_ADDRESS - 1]),
-			      	      ifa))))
+		if (tb[IFA_LOCAL] &&
+		    ifa->ifa_local != nla_get_u32(tb[IFA_LOCAL]))
 			continue;
+
+		if (tb[IFA_LABEL] && nla_strcmp(tb[IFA_LABEL], ifa->ifa_label))
+			continue;
+
+		if (tb[IFA_ADDRESS] &&
+		    (ifm->ifa_prefixlen != ifa->ifa_prefixlen ||
+		    !inet_ifa_match(nla_get_u32(tb[IFA_ADDRESS]), ifa)))
+			continue;
+
 		inet_del_ifa(in_dev, ifap, 1);
 		return 0;
 	}
-out:
-	return -EADDRNOTAVAIL;
+
+	err = -EADDRNOTAVAIL;
+errout:
+	return err;
 }
 
 static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)

