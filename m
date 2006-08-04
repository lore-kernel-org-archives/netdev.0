From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/9] [IPV4]: Convert address addition to new netlink api
Date: Sat, 05 Aug 2006 00:00:03 +0200
Message-ID: <20060805003536.126713288@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5357 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422676AbWHEAnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:14 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv4_newaddr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds rtm_to_ifaddr() transforming a netlink message to a
struct in_ifaddr. Fixes various unvalidated netlink attributes
causing memory corruptions when left empty by userspace
applications.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.orig/net/ipv4/devinet.c
+++ net-2.6.19/net/ipv4/devinet.c
@@ -62,6 +62,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/ip_fib.h>
+#include <net/netlink.h>
 
 struct ipv4_devconf ipv4_devconf = {
 	.accept_redirects = 1,
@@ -78,6 +79,14 @@ static struct ipv4_devconf ipv4_devconf_
 	.accept_source_route = 1,
 };
 
+static struct nla_policy ifa_ipv4_policy[IFA_MAX+1] __read_mostly = {
+	[IFA_LOCAL]     	= { .type = NLA_U32 },
+	[IFA_ADDRESS]   	= { .type = NLA_U32 },
+	[IFA_BROADCAST] 	= { .type = NLA_U32 },
+	[IFA_ANYCAST]   	= { .type = NLA_U32 },
+	[IFA_LABEL]     	= { .type = NLA_STRING },
+};
+
 static void rtmsg_ifa(int event, struct in_ifaddr *);
 
 static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
@@ -451,57 +460,90 @@ out:
 	return -EADDRNOTAVAIL;
 }
 
-static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
 {
-	struct rtattr **rta = arg;
+	struct nlattr *tb[IFA_MAX+1];
+	struct in_ifaddr *ifa;
+	struct ifaddrmsg *ifm;
 	struct net_device *dev;
 	struct in_device *in_dev;
-	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
-	struct in_ifaddr *ifa;
-	int rc = -EINVAL;
+	int err = -EINVAL;
 
-	ASSERT_RTNL();
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
+	if (err < 0)
+		goto errout;
 
-	if (ifm->ifa_prefixlen > 32 || !rta[IFA_LOCAL - 1])
-		goto out;
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL)
+		goto errout;
 
-	rc = -ENODEV;
-	if ((dev = __dev_get_by_index(ifm->ifa_index)) == NULL)
-		goto out;
+	dev = __dev_get_by_index(ifm->ifa_index);
+	if (dev == NULL) {
+		err = -ENODEV;
+		goto errout;
+	}
 
-	rc = -ENOBUFS;
-	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL) {
+	in_dev = __in_dev_get_rtnl(dev);
+	if (in_dev == NULL) {
 		in_dev = inetdev_init(dev);
-		if (!in_dev)
-			goto out;
+		if (in_dev == NULL) {
+			err = -ENOBUFS;
+			goto errout;
+		}
 	}
 
-	if ((ifa = inet_alloc_ifa()) == NULL)
-		goto out;
+	ifa = inet_alloc_ifa();
+	if (ifa == NULL) {
+		/*
+		 * A potential indev allocation can be left alive, it stays
+		 * assigned to its device and is destroy with it.
+		 */
+		err = -ENOBUFS;
+		goto errout;
+	}
+
+	in_dev_hold(in_dev);
+
+	if (tb[IFA_ADDRESS] == NULL)
+		tb[IFA_ADDRESS] = tb[IFA_LOCAL];
 
-	if (!rta[IFA_ADDRESS - 1])
-		rta[IFA_ADDRESS - 1] = rta[IFA_LOCAL - 1];
-	memcpy(&ifa->ifa_local, RTA_DATA(rta[IFA_LOCAL - 1]), 4);
-	memcpy(&ifa->ifa_address, RTA_DATA(rta[IFA_ADDRESS - 1]), 4);
 	ifa->ifa_prefixlen = ifm->ifa_prefixlen;
 	ifa->ifa_mask = inet_make_mask(ifm->ifa_prefixlen);
-	if (rta[IFA_BROADCAST - 1])
-		memcpy(&ifa->ifa_broadcast,
-		       RTA_DATA(rta[IFA_BROADCAST - 1]), 4);
-	if (rta[IFA_ANYCAST - 1])
-		memcpy(&ifa->ifa_anycast, RTA_DATA(rta[IFA_ANYCAST - 1]), 4);
 	ifa->ifa_flags = ifm->ifa_flags;
 	ifa->ifa_scope = ifm->ifa_scope;
-	in_dev_hold(in_dev);
-	ifa->ifa_dev   = in_dev;
-	if (rta[IFA_LABEL - 1])
-		rtattr_strlcpy(ifa->ifa_label, rta[IFA_LABEL - 1], IFNAMSIZ);
+	ifa->ifa_dev = in_dev;
+
+	ifa->ifa_local = nla_get_u32(tb[IFA_LOCAL]);
+	ifa->ifa_address = nla_get_u32(tb[IFA_ADDRESS]);
+
+	if (tb[IFA_BROADCAST])
+		ifa->ifa_broadcast = nla_get_u32(tb[IFA_BROADCAST]);
+
+	if (tb[IFA_ANYCAST])
+		ifa->ifa_anycast = nla_get_u32(tb[IFA_ANYCAST]);
+
+	if (tb[IFA_LABEL])
+		nla_strlcpy(ifa->ifa_label, tb[IFA_LABEL], IFNAMSIZ);
 	else
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 
-	rc = inet_insert_ifa(ifa);
-out:
-	return rc;
+	return ifa;
+
+errout:
+	return ERR_PTR(err);
+}
+
+static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct in_ifaddr *ifa;
+
+	ASSERT_RTNL();
+
+	ifa = rtm_to_ifaddr(nlh);
+	if (IS_ERR(ifa))
+		return PTR_ERR(ifa);
+
+	return inet_insert_ifa(ifa);
 }
 
 /*

