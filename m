From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] ndisc: Ensure to reserve header space for encapsulation.
Date: Tue, 25 Dec 2012 23:39:32 +0900
Message-ID: <50D9BAA4.7000207@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38821 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751669Ab2LYOje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2012 09:39:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We allocate sk_buff of MAX_HEADER + LL_RESERVED_SPACE(dev) + packet
length + dev->needed_tailroom, but reserved LL_RESERVED_SPACE(dev)
only.  This means that space for encapsulation was placed at the end
of buffer.  This does not make sense.

Reserve the space correctly, like this:

head                       data                   tail       end
+--------------------------------------------------------------+
+                |           |                      |          |
+--------------------------------------------------------------+
|<--MAX_HEADER-->|<-hlen---->|<---ipv6 packet------>|<--tlen-->|
                   =LL_
                    RESERVED_
                    SPACE(dev)

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 6574175..5f78ac2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -404,7 +404,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 		return NULL;
 	}
 
-	skb_reserve(skb, hlen);
+	skb_reserve(skb, MAX_HEADER + hlen);
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
 	skb->transport_header = skb->tail;
@@ -1449,7 +1449,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 		goto release;
 	}
 
-	skb_reserve(buff, hlen);
+	skb_reserve(buff, MAX_HEADER + hlen);
 	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
 		   IPPROTO_ICMPV6, len);
 
-- 
1.7.9.5
