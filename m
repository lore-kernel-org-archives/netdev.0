From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH v3] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Fri, 27 Mar 2015 12:24:22 +0300
Message-ID: <1427448262-7231-1-git-send-email-alexey.kodanev@oracle.com>
Cc: vasily.isaenko@oracle.com,
	Alexey Kodanev <alexey.kodanev@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37062 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769AbbC0JVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 05:21:51 -0400
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t2R9LoXA009476
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 09:21:50 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t2R9LoxR014938
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 09:21:50 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t2R9LoWT023516
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 09:21:50 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_v6_fill_cb() will be called twice if socket's state changes from
TCP_TIME_WAIT to TCP_LISTEN. That can result in control buffer data
corruption because in the second tcp_v6_fill_cb() call it's not copying
IP6CB(skb) anymore, but 'seq', 'end_seq', etc., so we can get weird and
unpredictable results. Performance loss of up to 1200% has been observed
in LTP/vxlan03 test.

This can be fixed by copying inet6_skb_parm to the beginning of 'cb'
only if xfrm6_policy_check() and tcp_v6_fill_cb() are going to be
called again.

Fixes: 2dc49d1680b53 ("tcp6: don't move IP6CB before xfrm6_policy_check()")

Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
v3: remove redundant 'Regression from...' line from commit message

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
