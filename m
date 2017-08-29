From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/2] addrlabel: add/delete/get can run without rtnl
Date: Tue, 29 Aug 2017 13:29:42 +0200
Message-ID: <20170829112942.4791-3-fw@strlen.de>
References: <20170829112942.4791-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56350 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752881AbdH2L3j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 07:29:39 -0400
In-Reply-To: <20170829112942.4791-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There appears to be no need to use rtnl, addrlabel entries are refcounted
and add/delete is serialized by the addrlabel table spinlock.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/addrlabel.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index cea5eb488013..b055bc79f56d 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -405,6 +405,18 @@ static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
 	[IFAL_LABEL]		= { .len = sizeof(u32), },
 };
 
+static bool addrlbl_ifindex_exists(struct net *net, int ifindex)
+{
+
+	struct net_device *dev;
+
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, ifindex);
+	rcu_read_unlock();
+
+	return dev != NULL;
+}
+
 static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 			     struct netlink_ext_ack *extack)
 {
@@ -439,7 +451,7 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 	switch (nlh->nlmsg_type) {
 	case RTM_NEWADDRLABEL:
 		if (ifal->ifal_index &&
-		    !__dev_get_by_index(net, ifal->ifal_index))
+		    !addrlbl_ifindex_exists(net, ifal->ifal_index))
 			return -EINVAL;
 
 		err = ip6addrlbl_add(net, pfx, ifal->ifal_prefixlen,
@@ -548,7 +560,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	if (ifal->ifal_index &&
-	    !__dev_get_by_index(net, ifal->ifal_index))
+	    !addrlbl_ifindex_exists(net, ifal->ifal_index))
 		return -EINVAL;
 
 	if (!tb[IFAL_ADDRESS])
@@ -593,10 +605,10 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 void __init ipv6_addr_label_rtnl_register(void)
 {
 	__rtnl_register(PF_INET6, RTM_NEWADDRLABEL, ip6addrlbl_newdel,
-			NULL, 0);
+			NULL, RTNL_FLAG_DOIT_UNLOCKED);
 	__rtnl_register(PF_INET6, RTM_DELADDRLABEL, ip6addrlbl_newdel,
-			NULL, 0);
+			NULL, RTNL_FLAG_DOIT_UNLOCKED);
 	__rtnl_register(PF_INET6, RTM_GETADDRLABEL, ip6addrlbl_get,
-			ip6addrlbl_dump, 0);
+			ip6addrlbl_dump, RTNL_FLAG_DOIT_UNLOCKED);
 }
 
-- 
2.13.0
