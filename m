From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH v2] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Thu, 26 Mar 2015 11:28:04 +0300
Message-ID: <1427358484-16402-1-git-send-email-alexey.kodanev@oracle.com>
Cc: vasily.isaenko@oracle.com,
	Alexey Kodanev <alexey.kodanev@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24299 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbbCZI0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 04:26:00 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t2Q8Px63004189
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 08:25:59 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t2Q8PxkK022656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 08:25:59 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.13.8/8.13.8) with ESMTP id t2Q8Pwhr007994
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 08:25:58 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regression from the following commit: 2dc49d1680.

tcp_v6_fill_cb() will be called twice if socket's state changes from
TCP_TIME_WAIT to TCP_LISTEN. That can result in control buffer data
corruption because in the second tcp_v6_fill_cb() call it's not copying
IP6CB(skb) anymore, but 'seq', 'end_seq', etc., so we can get weird and
unpredictable results. Performance loss of up to 1200% has been observed
in LTP/vxlan03 test.

This can be fixed by copying inet6_skb_parm to the beginning of 'cb'
only if xfrm6_policy_check() and tcp_v6_fill_cb() are going to be
called again.

Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 net/ipv6/tcp_ipv6.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5d46832..7d21a78 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1411,6 +1411,15 @@ static void tcp_v6_fill_cb(struct sk_buff *skb, const struct ipv6hdr *hdr,
 	TCP_SKB_CB(skb)->sacked = 0;
 }
 
+static void tcp_v6_restore_cb(struct sk_buff *skb)
+{
+	/* We need to move header back to the beginning if xfrm6_policy_check()
+	 * and tcp_v6_fill_cb() are going to be called again.
+	 */
+	memmove(IP6CB(skb), &TCP_SKB_CB(skb)->header.h6,
+		sizeof(struct inet6_skb_parm));
+}
+
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
 	const struct tcphdr *th;
@@ -1543,6 +1552,7 @@ do_time_wait:
 			inet_twsk_deschedule(tw, &tcp_death_row);
 			inet_twsk_put(tw);
 			sk = sk2;
+			tcp_v6_restore_cb(skb);
 			goto process;
 		}
 		/* Fall through to ACK */
@@ -1551,6 +1561,7 @@ do_time_wait:
 		tcp_v6_timewait_ack(sk, skb);
 		break;
 	case TCP_TW_RST:
+		tcp_v6_restore_cb(skb);
 		goto no_tcp_socket;
 	case TCP_TW_SUCCESS:
 		;
-- 
1.7.1
