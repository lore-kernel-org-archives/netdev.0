From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/9] [IPV4]: Convert address dumping to new netlink api
Date: Sat, 05 Aug 2006 00:00:05 +0200
Message-ID: <20060805003536.773767001@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:8685 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422680AbWHEAnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:25 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv4_dumpaddr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.orig/net/ipv4/devinet.c
+++ net-2.6.19/net/ipv4/devinet.c
@@ -1112,32 +1112,37 @@ static int inet_fill_ifaddr(struct sk_bu
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
-	ifm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*ifm), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
+	ifm = nlmsg_data(nlh);
 	ifm->ifa_family = AF_INET;
 	ifm->ifa_prefixlen = ifa->ifa_prefixlen;
 	ifm->ifa_flags = ifa->ifa_flags|IFA_F_PERMANENT;
 	ifm->ifa_scope = ifa->ifa_scope;
 	ifm->ifa_index = ifa->ifa_dev->dev->ifindex;
+
 	if (ifa->ifa_address)
-		RTA_PUT(skb, IFA_ADDRESS, 4, &ifa->ifa_address);
+		NLA_PUT_U32(skb, IFA_ADDRESS, ifa->ifa_address);
+
 	if (ifa->ifa_local)
-		RTA_PUT(skb, IFA_LOCAL, 4, &ifa->ifa_local);
+		NLA_PUT_U32(skb, IFA_LOCAL, ifa->ifa_local);
+
 	if (ifa->ifa_broadcast)
-		RTA_PUT(skb, IFA_BROADCAST, 4, &ifa->ifa_broadcast);
+		NLA_PUT_U32(skb, IFA_BROADCAST, ifa->ifa_broadcast);
+
 	if (ifa->ifa_anycast)
-		RTA_PUT(skb, IFA_ANYCAST, 4, &ifa->ifa_anycast);
+		NLA_PUT_U32(skb, IFA_ANYCAST, ifa->ifa_anycast);
+
 	if (ifa->ifa_label[0])
-		RTA_PUT(skb, IFA_LABEL, IFNAMSIZ, &ifa->ifa_label);
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+		NLA_PUT_STRING(skb, IFA_LABEL, ifa->ifa_label);
+
+	return nlmsg_end(skb, nlh);
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1185,17 +1190,16 @@ done:
 
 static void rtmsg_ifa(int event, struct in_ifaddr* ifa)
 {
-	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg) + 128);
-	struct sk_buff *skb = alloc_skb(size, GFP_KERNEL);
+	struct sk_buff *skb;
 
-	if (!skb)
+	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb == NULL)
 		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_IFADDR, ENOBUFS);
 	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_IFADDR, EINVAL);
-	} else {
+	} else
 		netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_IFADDR, GFP_KERNEL);
-	}
 }
 
 static struct rtnetlink_link inet_rtnetlink_table[RTM_NR_MSGTYPES] = {

