From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 5/6][NETNS][IPV6] tcp6 - handle several network namespace
Date: Fri, 07 Mar 2008 16:26:43 +0100
Message-ID: <20080307152942.640704390@mai.toulouse-stg.fr.ibm.com>
References: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:64094 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764145AbYCGPaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:30:14 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m27FUDOV147134
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:13 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27FUCDr1990840
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:12 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27FUCMV019246
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:12 +0100
Content-Disposition: inline; filename=make-tcp6-handle-multiple-network-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have the right network namespace at the right place now.
So make use of this information to make tcp6 per network namespace

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/tcp_ipv6.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

Index: net-2.6.26/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6.26/net/ipv6/tcp_ipv6.c
@@ -988,6 +988,8 @@ static void tcp_v6_send_reset(struct soc
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
+	struct net *net = skb->dst->dev->nd_net;
+	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(*th);
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
@@ -1072,11 +1074,10 @@ static void tcp_v6_send_reset(struct soc
 	 * Underlying function will use this to retrieve the network
 	 * namespace
 	 */
-	if (!ip6_dst_lookup(init_net.ipv6.tcp_sk, &buff->dst, &fl)) {
+	if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
 
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
-			ip6_xmit(init_net.ipv6.tcp_sk,
-				 buff, &fl, NULL, 0);
+			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 			TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
 			return;
@@ -1092,6 +1093,8 @@ static void tcp_v6_send_ack(struct tcp_t
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
+	struct net *net = skb->dev->nd_net;
+	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(struct tcphdr);
 	__be32 *topt;
 #ifdef CONFIG_TCP_MD5SIG
@@ -1173,10 +1176,9 @@ static void tcp_v6_send_ack(struct tcp_t
 	fl.fl_ip_sport = t1->source;
 	security_skb_classify_flow(skb, &fl);
 
-	if (!ip6_dst_lookup(init_net.ipv6.tcp_sk, &buff->dst, &fl)) {
+	if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
-			ip6_xmit(init_net.ipv6.tcp_sk,
-				 buff, &fl, NULL, 0);
+			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 			return;
 		}

-- 
