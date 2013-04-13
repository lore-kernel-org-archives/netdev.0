From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: tcp_tso_segment() small optimization
Date: Sat, 13 Apr 2013 06:22:08 -0700
Message-ID: <1365859328.4459.97.camel@edumazet-glaptop>
References: <1365858859.4459.94.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:40525 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206Ab3DMNWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 09:22:11 -0400
Received: by mail-pd0-f172.google.com with SMTP id 5so1842290pdd.3
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 06:22:11 -0700 (PDT)
In-Reply-To: <1365858859.4459.94.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We can move th->check computation out of the loop, as compiler
doesn't know each skb initially share same tcp headers after
skb_segment()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: Typo in change log : more -> move

 net/ipv4/tcp.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 963bda1..dcb116d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2886,6 +2886,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 	unsigned int oldlen;
 	unsigned int mss;
 	struct sk_buff *gso_skb = skb;
+	__sum16 newcheck;
 
 	if (!pskb_may_pull(skb, sizeof(*th)))
 		goto out;
@@ -2936,11 +2937,13 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 	th = tcp_hdr(skb);
 	seq = ntohl(th->seq);
 
+	newcheck = ~csum_fold((__force __wsum)((__force u32)th->check +
+					       (__force u32)delta));
+
 	do {
 		th->fin = th->psh = 0;
+		th->check = newcheck;
 
-		th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
-				       (__force u32)delta));
 		if (skb->ip_summed != CHECKSUM_PARTIAL)
 			th->check =
 			     csum_fold(csum_partial(skb_transport_header(skb),
