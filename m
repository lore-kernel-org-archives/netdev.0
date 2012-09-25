From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: mip6: fix mip6_mh_filter()
Date: Tue, 25 Sep 2012 22:01:28 +0200
Message-ID: <1348603288.26828.3398.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52654 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab2IYUBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 16:01:33 -0400
Received: by bkcjk13 with SMTP id jk13so1487293bkc.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 13:01:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mip6_mh_filter() should not modify its input, or else its caller
would need to recompute ipv6_hdr() if skb->head is reallocated.

Use skb_header_pointer() instead of pskb_may_pull()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/mip6.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 5b087c3..0f9bdc5 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -86,28 +86,30 @@ static int mip6_mh_len(int type)
 
 static int mip6_mh_filter(struct sock *sk, struct sk_buff *skb)
 {
-	struct ip6_mh *mh;
+	struct ip6_mh _hdr;
+	const struct ip6_mh *mh;
 
-	if (!pskb_may_pull(skb, (skb_transport_offset(skb)) + 8) ||
-	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
-				 ((skb_transport_header(skb)[1] + 1) << 3))))
+	mh = skb_header_pointer(skb, skb_transport_offset(skb),
+				sizeof(_hdr), &_hdr);
+	if (!mh)
 		return -1;
 
-	mh = (struct ip6_mh *)skb_transport_header(skb);
+	if (((mh->ip6mh_hdrlen + 1) << 3) > skb->len)
+		return -1;
 
 	if (mh->ip6mh_hdrlen < mip6_mh_len(mh->ip6mh_type)) {
 		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH message too short: %d vs >=%d\n",
 			       mh->ip6mh_hdrlen, mip6_mh_len(mh->ip6mh_type));
-		mip6_param_prob(skb, 0, ((&mh->ip6mh_hdrlen) -
-					 skb_network_header(skb)));
+		mip6_param_prob(skb, 0, offsetof(struct ip6_mh, ip6mh_hdrlen) +
+				skb_network_header_len(skb));
 		return -1;
 	}
 
 	if (mh->ip6mh_proto != IPPROTO_NONE) {
 		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH invalid payload proto = %d\n",
 			       mh->ip6mh_proto);
-		mip6_param_prob(skb, 0, ((&mh->ip6mh_proto) -
-					 skb_network_header(skb)));
+		mip6_param_prob(skb, 0, offsetof(struct ip6_mh, ip6mh_proto) +
+				skb_network_header_len(skb));
 		return -1;
 	}
 
