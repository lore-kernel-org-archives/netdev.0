From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 08:00:49 +0200
Message-ID: <1317103249.2796.25.camel@edumazet-laptop>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <20110927.005905.1166544891922183065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com,
	ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41857 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab1I0GAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 02:00:55 -0400
Received: by wyg34 with SMTP id 34so6779487wyg.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 23:00:53 -0700 (PDT)
In-Reply-To: <20110927.005905.1166544891922183065.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct tcp_skb_cb contains a "flags" field containing either tcp flags
or IP dsfield depending on context (input or output path)

Introduce ip_dsfield to make the difference clear and ease maintenance.
If later we want to save space, we can union flags/ip_dsfield

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

If there is no objection, I plan to rename "flags" to "tcp_flags" in a
following patch.

 include/net/tcp.h    |    3 ++-
 net/ipv4/tcp_input.c |    2 +-
 net/ipv4/tcp_ipv4.c  |    2 +-
 net/ipv6/tcp_ipv6.c  |    2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 702aefc..28a9997 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -642,7 +642,8 @@ struct tcp_skb_cb {
 #define TCPCB_SACKED_RETRANS	0x02	/* SKB retransmitted		*/
 #define TCPCB_LOST		0x04	/* SKB is lost			*/
 #define TCPCB_TAGBITS		0x07	/* All tag bits			*/
-
+	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
+	/* 1 byte hole */
 #define TCPCB_EVER_RETRANS	0x80	/* Ever retransmitted frame	*/
 #define TCPCB_RETRANS		(TCPCB_SACKED_RETRANS|TCPCB_EVER_RETRANS)
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5a4408c..7008fcc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -222,7 +222,7 @@ static inline void TCP_ECN_check_ce(struct tcp_sock *tp, const struct sk_buff *s
 	if (!(tp->ecn_flags & TCP_ECN_OK))
 		return;
 
-	switch (TCP_SKB_CB(skb)->flags & INET_ECN_MASK) {
+	switch (TCP_SKB_CB(skb)->ip_dsfield & INET_ECN_MASK) {
 	case INET_ECN_NOT_ECT:
 		/* Funny extension: if ECT is not set on a segment,
 		 * and we already seen ECT on a previous segment,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c29912c..dd3fad9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1677,7 +1677,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 				    skb->len - th->doff * 4);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when	 = 0;
-	TCP_SKB_CB(skb)->flags	 = iph->tos;
+	TCP_SKB_CB(skb)->ip_dsfield = ipv4_get_dsfield(iph);
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
 	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 12bdb9a..00797d8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1717,7 +1717,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 				    skb->len - th->doff*4);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when = 0;
-	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(hdr);
+	TCP_SKB_CB(skb)->ip_dsfield = ipv6_get_dsfield(hdr);
 	TCP_SKB_CB(skb)->sacked = 0;
 
 	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
