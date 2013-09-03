From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: ipv6: tcp: fix potential use after free in tcp_v6_do_rcv
Date: Tue,  3 Sep 2013 19:29:12 +0200
Message-ID: <1378229352-9779-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757058Ab3ICR3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 13:29:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcp_v6_do_rcv() code, when processing pkt options, we soley work
on our skb clone opt_skb that we've created earlier before entering
tcp_rcv_established() on our way. However, only in condition ...

  if (np->rxopt.bits.rxtclass)
    np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));

... we work on skb itself. As we extract every other information out
of opt_skb in ipv6_pktoptions path, this seems wrong, since skb can
already be released by tcp_rcv_established() earlier on. When we try
to access it in ipv6_hdr(), we will dereference freed skb.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/tcp_ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6e1649d..eeb4cb0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1427,7 +1427,7 @@ ipv6_pktoptions:
 		if (np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim)
 			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
 		if (np->rxopt.bits.rxtclass)
-			np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
+			np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(opt_skb));
 		if (ipv6_opt_accepted(sk, opt_skb)) {
 			skb_set_owner_r(opt_skb, sk);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
-- 
1.7.11.7
