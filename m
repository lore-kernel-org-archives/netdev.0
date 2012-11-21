From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH]ipv6:  fix the bug when we do not have a socket context
Date: Wed, 21 Nov 2012 19:12:28 +0800
Message-ID: <50ACB71C.4080101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40830 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729Ab2KULMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 06:12:37 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so5004770pbc.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 03:12:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


call the ip6_update_pmtu/ip6_redirect function to deal with
ICMPV6 Error Messages and Redirect Message, when we do not
have a socket context.

Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
---
 net/ipv6/raw.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d8e95c7..b10f478 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -354,7 +354,9 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 	const struct in6_addr *saddr, *daddr;
 	struct net *net;
 
+
 	hash = nexthdr & (RAW_HTABLE_SIZE - 1);
+	net = dev_net(skb->dev);
 
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
@@ -363,7 +365,6 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 		const struct ipv6hdr *ip6h = (const struct ipv6hdr *)skb->data;
 		saddr = &ip6h->saddr;
 		daddr = &ip6h->daddr;
-		net = dev_net(skb->dev);
 
 		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,
 						IP6CB(skb)->iif))) {
@@ -371,6 +372,19 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 					inner_offset, info);
 			sk = sk_next(sk);
 		}
+	} else {
+		switch (type) {
+			case ICMPV6_PKT_TOOBIG:
+				ip6_update_pmtu(skb, net, info, 0, 0);
+				break;
+			
+			case NDISC_REDIRECT:
+				ip6_redirect(skb, net, 0, 0);
+				break;
+
+			default:
+				break;
+		}		
 	}
 	read_unlock(&raw_v6_hashinfo.lock);
 }
-- 
1.7.1
