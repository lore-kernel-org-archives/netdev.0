From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 9/9][NETNS][IPV6] icmp6 - make icmpv6_socket per namespace
Date: Wed, 05 Mar 2008 18:56:58 +0100
Message-ID: <20080305180206.043262980@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:50854 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbYCESCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:11 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m25I29OV090624
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:09 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I29GV1962188
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:09 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I29UO018737
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:09 GMT
Content-Disposition: inline; filename=icmp6-allocate-icmpv6_socket-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch make the changes necessary to support network namespaces in ICMPv6.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/icmp.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: net-2.6.26/net/ipv6/icmp.c
===================================================================
--- net-2.6.26.orig/net/ipv6/icmp.c
+++ net-2.6.26/net/ipv6/icmp.c
@@ -163,6 +163,7 @@ static inline int icmpv6_xrlim_allow(str
 				     struct flowi *fl)
 {
 	struct dst_entry *dst;
+	struct net *net = sk->sk_net;
 	int res = 0;
 
 	/* Informational messages are not limited. */
@@ -178,7 +179,7 @@ static inline int icmpv6_xrlim_allow(str
 	 * XXX: perhaps the expire for routing entries cloned by
 	 * this lookup should be more aggressive (not longer than timeout).
 	 */
-	dst = ip6_route_output(&init_net, sk, fl);
+	dst = ip6_route_output(net, sk, fl);
 	if (dst->error) {
 		IP6_INC_STATS(ip6_dst_idev(dst),
 			      IPSTATS_MIB_OUTNOROUTES);
@@ -186,7 +187,7 @@ static inline int icmpv6_xrlim_allow(str
 		res = 1;
 	} else {
 		struct rt6_info *rt = (struct rt6_info *)dst;
-		int tmo = init_net.ipv6.sysctl.icmpv6_time;
+		int tmo = net->ipv6.sysctl.icmpv6_time;
 
 		/* Give more bandwidth to wider prefixes. */
 		if (rt->rt6i_dst.plen < 128)
@@ -305,6 +306,7 @@ static inline void mip6_addr_swap(struct
 void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
 		 struct net_device *dev)
 {
+	struct net *net = skb->dev->nd_net;
 	struct inet6_dev *idev = NULL;
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct sock *sk;
@@ -334,7 +336,7 @@ void icmpv6_send(struct sk_buff *skb, in
 	 */
 	addr_type = ipv6_addr_type(&hdr->daddr);
 
-	if (ipv6_chk_addr(&init_net, &hdr->daddr, skb->dev, 0))
+	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0))
 		saddr = &hdr->daddr;
 
 	/*
@@ -391,7 +393,7 @@ void icmpv6_send(struct sk_buff *skb, in
 	fl.fl_icmp_code = code;
 	security_skb_classify_flow(skb, &fl);
 
-	sk = icmpv6_sk(&init_net);
+	sk = icmpv6_sk(net);
 	np = inet6_sk(sk);
 
 	if (icmpv6_xmit_lock(sk))
@@ -507,6 +509,7 @@ EXPORT_SYMBOL(icmpv6_send);
 
 static void icmpv6_echo_reply(struct sk_buff *skb)
 {
+	struct net *net = skb->dev->nd_net;
 	struct sock *sk;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *np;
@@ -537,7 +540,7 @@ static void icmpv6_echo_reply(struct sk_
 	fl.fl_icmp_type = ICMPV6_ECHO_REPLY;
 	security_skb_classify_flow(skb, &fl);
 
-	sk = icmpv6_sk(&init_net);
+	sk = icmpv6_sk(net);
 	np = inet6_sk(sk);
 
 	if (icmpv6_xmit_lock(sk))

-- 
