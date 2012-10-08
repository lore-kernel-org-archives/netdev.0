From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net v2 6/6] ipvs: fix ARP resolving for direct routing mode
Date: Tue,  9 Oct 2012 00:41:20 +0300
Message-ID: <1349732480-19978-7-git-send-email-ja@ssi.bg>
References: <1349732480-19978-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44342 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698Ab2JHVgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 17:36:03 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q98LfZ7h020034
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2012 00:41:35 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q98LfZm2020033
	for netdev@vger.kernel.org; Tue, 9 Oct 2012 00:41:35 +0300
In-Reply-To: <1349732480-19978-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	After the change "Make neigh lookups directly in output packet path"
(commit a263b30936) IPVS can not reach the real server for DR mode
because we resolve the destination address from IP header, not from
route neighbour. Use the new FLOWI_FLAG_KNOWN_NH flag to request
output routes with known nexthop, so that it has preference
on resolving.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 56f6d5d..cc4c809 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -50,6 +50,7 @@ enum {
 				      * local
 				      */
 	IP_VS_RT_MODE_CONNECT	= 8, /* Always bind route to saddr */
+	IP_VS_RT_MODE_KNOWN_NH	= 16,/* Route via remote addr */
 };
 
 /*
@@ -113,6 +114,8 @@ static struct rtable *do_output_route4(struct net *net, __be32 daddr,
 	fl4.daddr = daddr;
 	fl4.saddr = (rt_mode & IP_VS_RT_MODE_CONNECT) ? *saddr : 0;
 	fl4.flowi4_tos = rtos;
+	fl4.flowi4_flags = (rt_mode & IP_VS_RT_MODE_KNOWN_NH) ?
+			   FLOWI_FLAG_KNOWN_NH : 0;
 
 retry:
 	rt = ip_route_output_key(net, &fl4);
@@ -1061,7 +1064,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (!(rt = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
 				      RT_TOS(iph->tos),
 				      IP_VS_RT_MODE_LOCAL |
-					IP_VS_RT_MODE_NON_LOCAL, NULL)))
+				      IP_VS_RT_MODE_NON_LOCAL |
+				      IP_VS_RT_MODE_KNOWN_NH, NULL)))
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
-- 
1.7.3.4
