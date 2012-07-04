From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Wed, 04 Jul 2012 16:13:35 -0700 (PDT)
Message-ID: <20120704.161335.1503971699878518173.davem@davemloft.net>
References: <alpine.LFD.2.00.1206282309340.1722@ja.ssi.bg>
	<20120628.184500.114483408843364230.davem@davemloft.net>
	<1341415267.2583.2120.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978Ab2GDXNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 19:13:35 -0400
In-Reply-To: <1341415267.2583.2120.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Jul 2012 17:21:07 +0200

> David I tried to setup a bridge to investigate problems reported on
> another thread and got immediate crash because of this patch.
> 
> Crash in fib_compute_spec_dst() if skb_rtable(skb) is NULL

I mixed up the tests in ip_options_compile(), I've pushed the following.

Thanks.

====================
ipv4: Fix crashes in ip_options_compile().

The spec_dst uses should be guarded by skb_rtable() being non-NULL
not just the SKB being non-null.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_options.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 766dfe56..1f02251 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -253,12 +253,15 @@ int ip_options_compile(struct net *net,
 {
 	__be32 spec_dst = (__force __be32) 0;
 	unsigned char *pp_ptr = NULL;
+	struct rtable *rt = NULL;
 	unsigned char *optptr;
 	unsigned char *iph;
 	int optlen, l;
 
 	if (skb != NULL) {
-		spec_dst = fib_compute_spec_dst(skb);
+		rt = skb_rtable(skb);
+		if (rt)
+			spec_dst = fib_compute_spec_dst(skb);
 		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
 	} else
 		optptr = opt->__data;
@@ -330,7 +333,7 @@ int ip_options_compile(struct net *net,
 					pp_ptr = optptr + 2;
 					goto error;
 				}
-				if (skb) {
+				if (rt) {
 					memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 					opt->is_changed = 1;
 				}
@@ -372,7 +375,7 @@ int ip_options_compile(struct net *net,
 						goto error;
 					}
 					opt->ts = optptr - iph;
-					if (skb)  {
+					if (rt)  {
 						memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 						timeptr = &optptr[optptr[2]+3];
 					}
-- 
1.7.10.4
