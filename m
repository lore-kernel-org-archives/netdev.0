From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] TCP: check min TTL on received ICMP packets
Date: Thu, 18 Mar 2010 14:27:32 -0700
Message-ID: <20100318142732.4de0f8d7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pekka Savola <pekkas@netcore.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47034 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451Ab0CRXve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 19:51:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds RFC5082 checks for TTL on received ICMP packets.
It adds some security against spoofed ICMP packets
disrupting GTSM protected sessions.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Please apply to 2.6.33 since it basically a "follow correct RFC"
fix to original GTSM patch.

--- a/net/ipv4/tcp_ipv4.c	2010-03-18 11:10:14.396384060 -0700
+++ b/net/ipv4/tcp_ipv4.c	2010-03-18 11:13:09.115759682 -0700
@@ -370,6 +370,11 @@ void tcp_v4_err(struct sk_buff *icmp_skb
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
+	if (unlikely(iph->ttl < inet_sk(sk)->min_ttl)) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+		goto out;
+	}
+
 	icsk = inet_csk(sk);
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
