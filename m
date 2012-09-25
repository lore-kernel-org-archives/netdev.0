From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: raw: fix icmpv6_filter()
Date: Tue, 25 Sep 2012 19:03:40 +0200
Message-ID: <1348592620.26828.3215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46501 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101Ab2IYRDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 13:03:45 -0400
Received: by eaac11 with SMTP id c11so2376210eaa.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 10:03:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

icmpv6_filter() should not modify its input, or else its caller
would need to recompute ipv6_hdr() if skb->head is reallocated.

Use skb_header_pointer() instead of pskb_may_pull() and
change the prototype to make clear both sk and skb are const.

Also, if icmpv6 header cannot be found, do not deliver the packet,
as we do in IPv4.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note: another patch is needed in mip6_mh_filter()

 net/ipv6/raw.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ef0579d..4a5f78b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -107,21 +107,20 @@ found:
  *	0 - deliver
  *	1 - block
  */
-static __inline__ int icmpv6_filter(struct sock *sk, struct sk_buff *skb)
+static int icmpv6_filter(const struct sock *sk, const struct sk_buff *skb)
 {
-	struct icmp6hdr *icmph;
-	struct raw6_sock *rp = raw6_sk(sk);
-
-	if (pskb_may_pull(skb, sizeof(struct icmp6hdr))) {
-		__u32 *data = &rp->filter.data[0];
-		int bit_nr;
+	struct icmp6hdr *_hdr;
+	const struct icmp6hdr *hdr;
 
-		icmph = (struct icmp6hdr *) skb->data;
-		bit_nr = icmph->icmp6_type;
+	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
+				 sizeof(_hdr), &_hdr);
+	if (hdr) {
+		const __u32 *data = &raw6_sk(sk)->filter.data[0];
+		unsigned int type = hdr->icmp6_type;
 
-		return (data[bit_nr >> 5] & (1 << (bit_nr & 31))) != 0;
+		return (data[type >> 5] & (1U << (type & 31))) != 0;
 	}
-	return 0;
+	return 1;
 }
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
