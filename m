From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Thu, 12 May 2011 23:04:05 -0400 (EDT)
Message-ID: <20110512.230405.532264333967231887.davem@davemloft.net>
References: <20110513114139.b1ed88ae.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110513114139.b1ed88ae.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 13 May 2011 11:41:39 +1000

> After merging the net tree, today's linux-next build (powerpc
> ppc64_defconfig) produced this warning:
> 
> net/ipv4/ip_forward.c: In function 'ip_forward':
> net/ipv4/ip_forward.c:87: warning: 'iph' may be used uninitialized in this function
> 
> Introduced by commit def57687e957 ("ipv4: Elide use of rt->rt_dst in
> ip_forward()").  It may be a false positive, but it is not obvious how
> iph is assigned before being used.

My compiler didn't warn, (and I just double checked this) which is
weird.  Sigh.

Thanks, here is the fix I'll push:

--------------------
ipv4: Fix 'iph' use before set.

I swear none of my compilers warned about this, yet it is so
obvious.

> net/ipv4/ip_forward.c: In function 'ip_forward':
> net/ipv4/ip_forward.c:87: warning: 'iph' may be used uninitialized in this function

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_forward.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index fcbc0c8..3b34d1c 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -84,7 +84,7 @@ int ip_forward(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 
-	if (opt->is_strictroute && iph->daddr != rt->rt_gateway)
+	if (opt->is_strictroute && ip_hdr(skb)->daddr != rt->rt_gateway)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
-- 
1.7.4.4
