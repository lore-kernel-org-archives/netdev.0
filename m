From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: raw: fix icmp_filter()
Date: Sat, 22 Sep 2012 12:08:29 +0200
Message-ID: <1348308509.2669.1105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47384 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754714Ab2IVKId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 06:08:33 -0400
Received: by eaac11 with SMTP id c11so1321297eaa.19
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 03:08:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

icmp_filter() should not modify its input, or else its caller
would need to recompute ip_hdr() if skb->head is reallocated.

Use skb_header_pointer() instead of pskb_may_pull() and
change the prototype to make clear both sk and skb are const.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
This is a minimal fix, to meet stable expectations.

 net/ipv4/raw.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ff0f071..d23c657 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -131,18 +131,20 @@ found:
  *	0 - deliver
  *	1 - block
  */
-static __inline__ int icmp_filter(struct sock *sk, struct sk_buff *skb)
+static int icmp_filter(const struct sock *sk, const struct sk_buff *skb)
 {
-	int type;
+	struct icmphdr _hdr;
+	const struct icmphdr *hdr;
 
-	if (!pskb_may_pull(skb, sizeof(struct icmphdr)))
+	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
+				 sizeof(_hdr), &_hdr);
+	if (!hdr)
 		return 1;
 
-	type = icmp_hdr(skb)->type;
-	if (type < 32) {
+	if (hdr->type < 32) {
 		__u32 data = raw_sk(sk)->filter.data;
 
-		return ((1 << type) & data) != 0;
+		return ((1U << hdr->type) & data) != 0;
 	}
 
 	/* Do not block unknown ICMP types */
