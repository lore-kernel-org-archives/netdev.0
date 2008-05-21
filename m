From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [RFC PATCH] TCP connection timesout if ICMP frag needed is delayed
Date: Wed, 21 May 2008 16:37:10 -0700
Message-ID: <1211413030.14663.42.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:55828 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756420AbYEUXhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 19:37:16 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4LNbC1N018976
	for <netdev@vger.kernel.org>; Wed, 21 May 2008 19:37:12 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4LNbC9n142496
	for <netdev@vger.kernel.org>; Wed, 21 May 2008 19:37:12 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4LNbBCX012124
	for <netdev@vger.kernel.org>; Wed, 21 May 2008 19:37:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing an issue with TCP in handling an ICMP frag needed
message that is received after net.ipv4.tcp_retries1 retransmits.
The default value of retries1 is 3. So if the path mtu changes
and ICMP frag needed is lost for the first 3 retransmits or if
it gets delayed until 3 retransmits are done, TCP doesn't update
MSS correctly and continues to retransmit the orginal message
until it timesout after tcp_retries2 retransmits.
I am seeing this issue even with the latest 2.6.25.4 kernel.

In tcp_retransmit_timer(), when retransmits counter exceeds 
tcp_retries1 value, the dst cache entry of the socket is reset.
At this time, if we receive an ICMP frag needed message, the 
dst entry gets updated with the new MTU, but the TCP sockets
dst_cache entry remains NULL.
So the next time when we try to retransmit after the ICMP frag
needed is received, tcp_retransmit_skb() gets called. Here the
cur_mss value is calculated at the start of the routine with
a NULL sk_dst_cache. Instead we should call tcp_current_mss after
the rebuild_header that caches the dst entry with the updated mtu.
Also the rebuild_header should be called before tcp_fragment
so that skb is fragmented if the mss goes down.

The following patch implements the above changes and fixes the
problem.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d29ef79..6c3d8a1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1836,7 +1836,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	unsigned int cur_mss = tcp_current_mss(sk, 0);
+	unsigned int cur_mss;
 	int err;
 
 	/* Inconslusive MTU probe */
@@ -1858,6 +1858,11 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 			return -ENOMEM;
 	}
 
+	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
+		return -EHOSTUNREACH; /* Routing failure or similar. */
+
+	cur_mss = tcp_current_mss(sk, 0);
+
 	/* If receiver has shrunk his window, and skb is out of
 	 * new window, do not retransmit it. The exception is the
 	 * case, when window is shrunk to zero. In this case
@@ -1884,9 +1889,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	    (sysctl_tcp_retrans_collapse != 0))
 		tcp_retrans_try_collapse(sk, skb, cur_mss);
 
-	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
-		return -EHOSTUNREACH; /* Routing failure or similar. */
-
 	/* Some Solaris stacks overoptimize and ignore the FIN on a
 	 * retransmit when old data is attached.  So strip it off
 	 * since it is cheap to do so and saves bytes on the network.




