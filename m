From: Koichiro Den <den@klaipeden.com>
Subject: [net-next 1/3] tcp: avoid useless copying and collapsing of just one skb
Date: Sat, 14 Oct 2017 16:27:43 +0900
Message-ID: <20171014072745.23462-2-den@klaipeden.com>
References: <20171014072745.23462-1-den@klaipeden.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21412 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdJNH2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 03:28:02 -0400
In-Reply-To: <20171014072745.23462-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the starting point chosen, it could be possible that just one skb
remains in between the range provided, leading to copying and re-insertion
of rb node, which is useless with respect to the rcv buf measurement.
This is rather probable in ooo queue case, in which non-contiguous bloated
packets have been queued up.

Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 net/ipv4/tcp_input.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d0682ce2a5d6..1d785b5bf62d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4807,7 +4807,8 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
 		start = TCP_SKB_CB(skb)->end_seq;
 	}
 	if (end_of_skbs ||
-	    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)))
+	    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)) ||
+	    (TCP_SKB_CB(skb)->seq == start && TCP_SKB_CB(skb)->end_seq == end))
 		return;
 
 	__skb_queue_head_init(&tmp);
-- 
2.9.4
