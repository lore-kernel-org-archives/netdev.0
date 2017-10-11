From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/2] ipv6: addrconf: don't use rtnl mutex in RTM_GETADDR
Date: Wed, 11 Oct 2017 10:28:01 +0200
Message-ID: <20171011082801.12715-3-fw@strlen.de>
References: <20171011082801.12715-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38994 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757239AbdJKI1u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 04:27:50 -0400
In-Reply-To: <20171011082801.12715-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to the previous patch, use the device lookup functions
that bump device refcount and flag this as DOIT_UNLOCKED to avoid
rtnl mutex.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/addrconf.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5207f567ef28..4603aa488f4f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4890,17 +4890,15 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy,
 			  extack);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	addr = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL], &peer);
-	if (!addr) {
-		err = -EINVAL;
-		goto errout;
-	}
+	if (!addr)
+		return -EINVAL;
 
 	ifm = nlmsg_data(nlh);
 	if (ifm->ifa_index)
-		dev = __dev_get_by_index(net, ifm->ifa_index);
+		dev = dev_get_by_index(net, ifm->ifa_index);
 
 	ifa = ipv6_get_ifaddr(net, addr, dev, 1);
 	if (!ifa) {
@@ -4926,6 +4924,8 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 errout_ifa:
 	in6_ifa_put(ifa);
 errout:
+	if (dev)
+		dev_put(dev);
 	return err;
 }
 
@@ -6568,7 +6568,7 @@ int __init addrconf_init(void)
 	__rtnl_register(PF_INET6, RTM_NEWADDR, inet6_rtm_newaddr, NULL, 0);
 	__rtnl_register(PF_INET6, RTM_DELADDR, inet6_rtm_deladdr, NULL, 0);
 	__rtnl_register(PF_INET6, RTM_GETADDR, inet6_rtm_getaddr,
-			inet6_dump_ifaddr, 0);
+			inet6_dump_ifaddr, RTNL_FLAG_DOIT_UNLOCKED);
 	__rtnl_register(PF_INET6, RTM_GETMULTICAST, NULL,
 			inet6_dump_ifmcaddr, 0);
 	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL,
-- 
2.13.6
