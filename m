From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] xfrm: use xfrm_addr_cmp() instead of compare addresses directly
Date: Mon, 29 Jun 2009 12:42:53 +0800
Message-ID: <4A48464D.2010501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55926 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbZF2Enq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 00:43:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up to use xfrm_addr_cmp() instead of compare addresses directly.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/xfrm/xfrm_state.c |   57 +++++++------------------------------------------
 1 files changed, 8 insertions(+), 49 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5f1f865..f2f7c63 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -668,22 +668,10 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, xfrm_address_t *d
 	hlist_for_each_entry(x, entry, net->xfrm.state_byspi+h, byspi) {
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
-		    x->id.proto     != proto)
+		    x->id.proto     != proto ||
+		    xfrm_addr_cmp(&x->id.daddr, daddr, family))
 			continue;
 
-		switch (family) {
-		case AF_INET:
-			if (x->id.daddr.a4 != daddr->a4)
-				continue;
-			break;
-		case AF_INET6:
-			if (!ipv6_addr_equal((struct in6_addr *)daddr,
-					     (struct in6_addr *)
-					     x->id.daddr.a6))
-				continue;
-			break;
-		}
-
 		xfrm_state_hold(x);
 		return x;
 	}
@@ -699,26 +687,11 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, xfrm_addre
 
 	hlist_for_each_entry(x, entry, net->xfrm.state_bysrc+h, bysrc) {
 		if (x->props.family != family ||
-		    x->id.proto     != proto)
+		    x->id.proto     != proto ||
+		    xfrm_addr_cmp(&x->id.daddr, daddr, family) ||
+		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
 			continue;
 
-		switch (family) {
-		case AF_INET:
-			if (x->id.daddr.a4 != daddr->a4 ||
-			    x->props.saddr.a4 != saddr->a4)
-				continue;
-			break;
-		case AF_INET6:
-			if (!ipv6_addr_equal((struct in6_addr *)daddr,
-					     (struct in6_addr *)
-					     x->id.daddr.a6) ||
-			    !ipv6_addr_equal((struct in6_addr *)saddr,
-					     (struct in6_addr *)
-					     x->props.saddr.a6))
-				continue;
-			break;
-		}
-
 		xfrm_state_hold(x);
 		return x;
 	}
@@ -1001,25 +974,11 @@ static struct xfrm_state *__find_acq_core(struct net *net, unsigned short family
 		    x->props.family != family ||
 		    x->km.state     != XFRM_STATE_ACQ ||
 		    x->id.spi       != 0 ||
-		    x->id.proto	    != proto)
+		    x->id.proto	    != proto ||
+		    xfrm_addr_cmp(&x->id.daddr, daddr, family) ||
+		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
 			continue;
 
-		switch (family) {
-		case AF_INET:
-			if (x->id.daddr.a4    != daddr->a4 ||
-			    x->props.saddr.a4 != saddr->a4)
-				continue;
-			break;
-		case AF_INET6:
-			if (!ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
-					     (struct in6_addr *)daddr) ||
-			    !ipv6_addr_equal((struct in6_addr *)
-					     x->props.saddr.a6,
-					     (struct in6_addr *)saddr))
-				continue;
-			break;
-		}
-
 		xfrm_state_hold(x);
 		return x;
 	}
-- 
1.6.2.2




