From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/6][NETNS][IPV6] fix some missing namespace
Date: Fri, 07 Mar 2008 16:26:39 +0100
Message-ID: <20080307152937.190883701@mai.toulouse-stg.fr.ibm.com>
References: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:28368 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763915AbYCGPaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:30:12 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m27FU77H326252
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:07 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27FU7LA2031770
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:07 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27FU7VT023897
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:07 GMT
Content-Disposition: inline; filename=fix-missing-net-parameter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds some missing namespace

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/ip6_output.c    |   10 ++++++----
 net/ipv6/ipv6_sockglue.c |    3 ++-
 net/ipv6/route.c         |    2 +-
 3 files changed, 9 insertions(+), 6 deletions(-)

Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -2261,7 +2261,7 @@ static int inet6_rtm_getroute(struct sk_
 	skb_reset_mac_header(skb);
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
-	rt = (struct rt6_info*) ip6_route_output(&init_net, NULL, &fl);
+	rt = (struct rt6_info*) ip6_route_output(net, NULL, &fl);
 	skb->dst = &rt->u.dst;
 
 	err = rt6_fill_node(skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
Index: net-2.6.26/net/ipv6/ip6_output.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_output.c
+++ net-2.6.26/net/ipv6/ip6_output.c
@@ -404,6 +404,7 @@ int ip6_forward(struct sk_buff *skb)
 	struct dst_entry *dst = skb->dst;
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct net *net = dst->dev->nd_net;
 
 	if (ipv6_devconf.forwarding == 0)
 		goto error;
@@ -450,7 +451,7 @@ int ip6_forward(struct sk_buff *skb)
 
 	/* XXX: idev->cnf.proxy_ndp? */
 	if (ipv6_devconf.proxy_ndp &&
-	    pneigh_lookup(&nd_tbl, &init_net, &hdr->daddr, skb->dev, 0)) {
+	    pneigh_lookup(&nd_tbl, net, &hdr->daddr, skb->dev, 0)) {
 		int proxied = ip6_forward_proxy_check(skb);
 		if (proxied > 0)
 			return ip6_input(skb);
@@ -911,9 +912,10 @@ static int ip6_dst_lookup_tail(struct so
 			       struct dst_entry **dst, struct flowi *fl)
 {
 	int err;
+	struct net *net = sk->sk_net;
 
 	if (*dst == NULL)
-		*dst = ip6_route_output(sk->sk_net, sk, fl);
+		*dst = ip6_route_output(net, sk, fl);
 
 	if ((err = (*dst)->error))
 		goto out_err_release;
@@ -939,7 +941,7 @@ static int ip6_dst_lookup_tail(struct so
 			struct flowi fl_gw;
 			int redirect;
 
-			ifp = ipv6_get_ifaddr(&init_net, &fl->fl6_src,
+			ifp = ipv6_get_ifaddr(net, &fl->fl6_src,
 					      (*dst)->dev, 1);
 
 			redirect = (ifp && ifp->flags & IFA_F_OPTIMISTIC);
@@ -954,7 +956,7 @@ static int ip6_dst_lookup_tail(struct so
 				dst_release(*dst);
 				memcpy(&fl_gw, fl, sizeof(struct flowi));
 				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
-				*dst = ip6_route_output(sk->sk_net, sk, &fl_gw);
+				*dst = ip6_route_output(net, sk, &fl_gw);
 				if ((err = (*dst)->error))
 					goto out_err_release;
 			}
Index: net-2.6.26/net/ipv6/ipv6_sockglue.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ipv6_sockglue.c
+++ net-2.6.26/net/ipv6/ipv6_sockglue.c
@@ -107,6 +107,7 @@ static int do_ipv6_setsockopt(struct soc
 		    char __user *optval, int optlen)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct net *net = sk->sk_net;
 	int val, valbool;
 	int retv = -ENOPROTOOPT;
 
@@ -432,7 +433,7 @@ done:
 			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
 				goto e_inval;
 
-			if (__dev_get_by_index(&init_net, val) == NULL) {
+			if (__dev_get_by_index(net, val) == NULL) {
 				retv = -ENODEV;
 				break;
 			}

-- 
