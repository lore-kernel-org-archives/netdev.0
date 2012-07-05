From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Thu, 05 Jul 2012 09:52:25 +0200
Message-ID: <1341474745.2583.3325.camel@edumazet-glaptop>
References: <alpine.LFD.2.00.1206282309340.1722@ja.ssi.bg>
	 <20120628.184500.114483408843364230.davem@davemloft.net>
	 <1341415267.2583.2120.camel@edumazet-glaptop>
	 <20120704.161335.1503971699878518173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54513 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab2GEHwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 03:52:30 -0400
Received: by eeit10 with SMTP id t10so3103056eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 00:52:29 -0700 (PDT)
In-Reply-To: <20120704.161335.1503971699878518173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-04 at 16:13 -0700, David Miller wrote:

> ====================
> ipv4: Fix crashes in ip_options_compile().
> 
> The spec_dst uses should be guarded by skb_rtable() being non-NULL
> not just the SKB being non-null.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Seems good to me thanks.

By the way, maybe we can defer fib_compute_spec_dst() call to the point
we really need it ?

[PATCH] ipv4: defer fib_compute_spec_dst() call

ip_options_compile() can avoid calling fib_compute_spec_dst()
by default, and perform the call if needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 1f02251..54ab83f 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -260,8 +260,6 @@ int ip_options_compile(struct net *net,
 
 	if (skb != NULL) {
 		rt = skb_rtable(skb);
-		if (rt)
-			spec_dst = fib_compute_spec_dst(skb);
 		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
 	} else
 		optptr = opt->__data;
@@ -334,6 +332,7 @@ int ip_options_compile(struct net *net,
 					goto error;
 				}
 				if (rt) {
+					spec_dst = fib_compute_spec_dst(skb);
 					memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 					opt->is_changed = 1;
 				}
@@ -376,6 +375,7 @@ int ip_options_compile(struct net *net,
 					}
 					opt->ts = optptr - iph;
 					if (rt)  {
+						spec_dst = fib_compute_spec_dst(skb);
 						memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 						timeptr = &optptr[optptr[2]+3];
 					}
