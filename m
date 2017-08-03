From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: set rt6i_protocol properly in the route when it is installed
Date: Thu,  3 Aug 2017 14:13:46 +0800
Message-ID: <4b7ab03445cf34a630d5185b216de8ab103a20d8.1501740826.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, grawity@gmail.com,
        David Ahern <dsahern@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33889 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751062AbdHCGNz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 02:13:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id t86so614369pfe.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 23:13:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit c2ed1880fd61 ("net: ipv6: check route protocol when
deleting routes"), ipv6 route checks rt protocol when trying to
remove a rt entry.

It introduced a side effect causing 'ip -6 route flush cache' not
to work well. When flushing caches with iproute, all route caches
get dumped from kernel then removed one by one by sending DELROUTE
requests to kernel for each cache.

The thing is iproute sends the request with the cache whose proto
is set with RTPROT_REDIRECT by rt6_fill_node() when kernel dumps
it. But in kernel the rt_cache protocol is still 0, which causes
the cache not to be matched and removed.

So the real reason is rt6i_protocol in the route is not set when
it is allocated. As David Ahern's suggestion, this patch is to
set rt6i_protocol properly in the route when it is installed and
remove the codes setting rtm_protocol according to rt6i_flags in
rt6_fill_node.

This is also an improvement to keep rt6i_protocol consistent with
rtm_protocol.

Fixes: c2ed1880fd61 ("net: ipv6: check route protocol when deleting routes")
Reported-by: Jianlin Shi <jishi@redhat.com>
Suggested-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/route.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..a640fbc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2351,6 +2351,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	if (on_link)
 		nrt->rt6i_flags &= ~RTF_GATEWAY;
 
+	nrt->rt6i_protocol = RTPROT_REDIRECT;
 	nrt->rt6i_gateway = *(struct in6_addr *)neigh->primary_key;
 
 	if (ip6_ins_rt(nrt))
@@ -2461,6 +2462,7 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 		.fc_dst_len	= prefixlen,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_ROUTEINFO |
 				  RTF_UP | RTF_PREF(pref),
+		.fc_protocol = RTPROT_RA,
 		.fc_nlinfo.portid = 0,
 		.fc_nlinfo.nlh = NULL,
 		.fc_nlinfo.nl_net = net,
@@ -2513,6 +2515,7 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 		.fc_ifindex	= dev->ifindex,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
 				  RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
+		.fc_protocol = RTPROT_RA,
 		.fc_nlinfo.portid = 0,
 		.fc_nlinfo.nlh = NULL,
 		.fc_nlinfo.nl_net = dev_net(dev),
@@ -3424,14 +3427,6 @@ static int rt6_fill_node(struct net *net,
 	rtm->rtm_flags = 0;
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = rt->rt6i_protocol;
-	if (rt->rt6i_flags & RTF_DYNAMIC)
-		rtm->rtm_protocol = RTPROT_REDIRECT;
-	else if (rt->rt6i_flags & RTF_ADDRCONF) {
-		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
-			rtm->rtm_protocol = RTPROT_RA;
-		else
-			rtm->rtm_protocol = RTPROT_KERNEL;
-	}
 
 	if (rt->rt6i_flags & RTF_CACHE)
 		rtm->rtm_flags |= RTM_F_CLONED;
-- 
2.1.0
