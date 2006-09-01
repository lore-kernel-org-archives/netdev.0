From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/8] address: Convert address lookup to new netlink api
Date: Fri, 01 Sep 2006 23:40:00 +0200
Message-ID: <20060901214014.486154960@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2705 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750980AbWIAVlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:23 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_getaddr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:15:18.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:19.000000000 +0200
@@ -3234,58 +3234,54 @@
 	return inet6_dump_addr(skb, cb, type);
 }
 
-static int inet6_rtm_getaddr(struct sk_buff *in_skb,
-		struct nlmsghdr* nlh, void *arg)
+static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr* nlh,
+			     void *arg)
 {
-	struct rtattr **rta = arg;
-	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
+	struct ifaddrmsg *ifm;
+	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *addr = NULL;
 	struct net_device *dev = NULL;
 	struct inet6_ifaddr *ifa;
 	struct sk_buff *skb;
-	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE);
+	int payload = sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE;
 	int err;
 
-	if (rta[IFA_ADDRESS-1]) {
-		if (RTA_PAYLOAD(rta[IFA_ADDRESS-1]) < sizeof(*addr))
-			return -EINVAL;
-		addr = RTA_DATA(rta[IFA_ADDRESS-1]);
-	}
-	if (rta[IFA_LOCAL-1]) {
-		if (RTA_PAYLOAD(rta[IFA_LOCAL-1]) < sizeof(*addr) ||
-		    (addr && memcmp(addr, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*addr))))
-			return -EINVAL;
-		addr = RTA_DATA(rta[IFA_LOCAL-1]);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
+	if (err < 0)
+		goto errout;
+
+	addr = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL]);
+	if (addr == NULL) {
+		err = -EINVAL;
+		goto errout;
 	}
-	if (addr == NULL)
-		return -EINVAL;
 
+	ifm = nlmsg_data(nlh);
 	if (ifm->ifa_index)
 		dev = __dev_get_by_index(ifm->ifa_index);
 
-	if ((ifa = ipv6_get_ifaddr(addr, dev, 1)) == NULL)
-		return -EADDRNOTAVAIL;
+	if ((ifa = ipv6_get_ifaddr(addr, dev, 1)) == NULL) {
+		err = -EADDRNOTAVAIL;
+		goto errout;
+	}
 
-	if ((skb = alloc_skb(size, GFP_KERNEL)) == NULL) {
+	if ((skb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL)) == NULL) {
 		err = -ENOBUFS;
-		goto out;
+		goto errout_ifa;
 	}
 
-	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 	err = inet6_fill_ifaddr(skb, ifa, NETLINK_CB(in_skb).pid,
 				nlh->nlmsg_seq, RTM_NEWADDR, 0);
 	if (err < 0) {
-		err = -EMSGSIZE;
-		goto out_free;
+		kfree_skb(skb);
+		goto errout_ifa;
 	}
 
 	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
-out:
+errout_ifa:
 	in6_ifa_put(ifa);
+errout:
 	return err;
-out_free:
-	kfree_skb(skb);
-	goto out;
 }
 
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)


-- 
VGER BF report: H 0.00657627
