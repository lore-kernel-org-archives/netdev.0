From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] IPv6: Generic TTL Security Mechanism (unified version)
Date: Sat, 03 Apr 2010 16:21:06 -0700
Message-ID: <20100403232922.645244580@vyatta.com>
References: <20100403232103.923025940@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, Pekka Savola <pekkas@netcore.fi>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Nick Hilliard <nick@inex.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46448 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab0DCXb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Apr 2010 19:31:59 -0400
Content-Disposition: inline; filename=gtsm-ipv6.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is one alternative IPv6 support for RFC5082 Generalized TTL
Security Mechanism. 

This version takes a simplest (but least pure) approach.
It uses the same socket option for IPv6 as IPv4 because
the TCP code has to deal with mapped addresses already.

With this method, the server doesn't have to deal with both IPv4 and IPv6
socket options. But the client still does have to handle the different
options.

On client:
	int ttl = 255;
	getaddrinfo(argv[1], argv[2], &hint, &result);

	for (rp = result; rp != NULL; rp = rp->ai_next) {
		s = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
		if (s < 0) continue;

		if (rp->ai_family == AF_INET) {
			setsockopt(s, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));
		} else if (rp->ai_family == AF_INET6) {
			setsockopt(s, IPPROTO_IPV6,  IPV6_UNICAST_HOPS, 
					&ttl, sizeof(ttl)))
		}
			
		if (connect(s, rp->ai_addr, rp->ai_addrlen) == 0) {
		   ...

On server:
	unsigned char minttl = 255 - maxhops;
   
	getaddrinfo(NULL, port, &hints, &result);
	for (rp = result; rp != NULL; rp = rp->ai_next) {
		s = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
		if (s < 0) continue;

		setsockopt(s, IPPROTO_IP, IP_MINTTL, &minttl, sizeof(minttl));
			
		if (bind(s, rp->ai_addr, rp->ai_addrlen) == 0)
			break
..


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv4/tcp_ipv4.c |   15 +++++++++++----
 net/ipv6/tcp_ipv6.c |   10 ++++++++++
 2 files changed, 21 insertions(+), 4 deletions(-)

--- a/net/ipv6/tcp_ipv6.c	2010-04-02 21:19:39.692013672 -0700
+++ b/net/ipv6/tcp_ipv6.c	2010-04-03 15:55:43.778224848 -0700
@@ -349,6 +349,11 @@ static void tcp_v6_err(struct sk_buff *s
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
+	if (ipv6_hdr(skb)->hop_limit < inet_sk(sk)->min_ttl) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+		goto out;
+	}
+
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
@@ -1717,6 +1722,11 @@ process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	if (ipv6_hdr(skb)->hop_limit < inet_sk(sk)->min_ttl) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+		goto discard_and_relse;
+	}
+
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
--- a/net/ipv4/tcp_ipv4.c	2010-04-02 21:19:39.682014278 -0700
+++ b/net/ipv4/tcp_ipv4.c	2010-04-02 21:20:25.571077252 -0700
@@ -1660,10 +1660,14 @@ process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
-	if (unlikely(iph->ttl < inet_sk(sk)->min_ttl)) {
-		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
-		goto discard_and_relse;
-	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	if (skb->protocol == htons(ETH_P_IPV6)) {
+		if (ipv6_hdr(skb)->hop_limit < inet_sk(sk)->min_ttl)
+			goto min_ttl_discard;
+	} else
+#endif
+	if (iph->ttl < inet_sk(sk)->min_ttl)
+		goto min_ttl_discard;
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
@@ -1716,6 +1720,9 @@ discard_it:
 	kfree_skb(skb);
 	return 0;
 
+min_ttl_discard:
+	NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+
 discard_and_relse:
 	sock_put(sk);
 	goto discard_it;

-- 

