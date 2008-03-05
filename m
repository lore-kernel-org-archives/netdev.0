From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 7/9][NETNS][IPV6] route6 - pass always a valid socket to ip6_dst_lookup
Date: Wed, 05 Mar 2008 18:56:56 +0100
Message-ID: <20080305180203.366538434@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:12648 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbYCESCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:09 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m25I27Z4374832
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:07 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I27da2015280
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:02:07 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I26Kx004309
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:06 GMT
Content-Disposition: inline; filename=ip6_dst_lookup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6_dst_lookup receive a socket as parameter. In some part of the code
it is called with a NULL socket parameter. We want to rely on the socket
to retrieve the network namespace, so we always pass a valid socket in all
cases.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6_output.c |    4 ++--
 net/ipv6/tcp_ipv6.c   |    9 ++++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

Index: net-2.6.26/net/ipv6/ip6_output.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_output.c
+++ net-2.6.26/net/ipv6/ip6_output.c
@@ -913,7 +913,7 @@ static int ip6_dst_lookup_tail(struct so
 	int err;
 
 	if (*dst == NULL)
-		*dst = ip6_route_output(&init_net, sk, fl);
+		*dst = ip6_route_output(sk->sk_net, sk, fl);
 
 	if ((err = (*dst)->error))
 		goto out_err_release;
@@ -954,7 +954,7 @@ static int ip6_dst_lookup_tail(struct so
 				dst_release(*dst);
 				memcpy(&fl_gw, fl, sizeof(struct flowi));
 				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
-				*dst = ip6_route_output(&init_net, sk, &fl_gw);
+				*dst = ip6_route_output(sk->sk_net, sk, &fl_gw);
 				if ((err = (*dst)->error))
 					goto out_err_release;
 			}
Index: net-2.6.26/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6.26/net/ipv6/tcp_ipv6.c
@@ -1071,8 +1071,11 @@ static void tcp_v6_send_reset(struct soc
 	fl.fl_ip_sport = t1->source;
 	security_skb_classify_flow(skb, &fl);
 
-	/* sk = NULL, but it is safe for now. RST socket required. */
-	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
+	/* Pass a socket to ip6_dst_lookup either it is for RST
+	 * Underlying function will use this to retrieve the network
+	 * namespace
+	 */
+	if (!ip6_dst_lookup(tcp6_socket->sk, &buff->dst, &fl)) {
 
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
 			ip6_xmit(tcp6_socket->sk, buff, &fl, NULL, 0);
@@ -1172,7 +1175,7 @@ static void tcp_v6_send_ack(struct tcp_t
 	fl.fl_ip_sport = t1->source;
 	security_skb_classify_flow(skb, &fl);
 
-	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
+	if (!ip6_dst_lookup(tcp6_socket->sk, &buff->dst, &fl)) {
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
 			ip6_xmit(tcp6_socket->sk, buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);

-- 
