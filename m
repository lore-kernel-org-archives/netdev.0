From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: refresh rt6i_genid in ip6_pol_route()
Date: Sun, 07 Sep 2014 12:05:03 -0700
Message-ID: <1410116703.11872.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ED4354.9090904@intel.com>
	 <20140814.162024.2218312002979492106.davem@davemloft.net>
	 <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
	 <20140821.162406.2076033247433267586.davem@davemloft.net>
	 <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410018384.11872.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410021507.11872.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410027712.11872.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, therbert@google.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42663 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaIGTFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 15:05:06 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so25812447pac.19
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 12:05:05 -0700 (PDT)
In-Reply-To: <1410027712.11872.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While tracking IPv6 poor performance, I found that IPv6 early demux
was broken in recent kernels. perf profiles show inet6_sk_rx_dst_set()
being called for every incoming TCP segment :

  20.95%      netserver  [kernel.kallsyms]    [k] dst_release     
  19.33%      netserver  [kernel.kallsyms]    [k] ip6_pol_route
  11.75%      netserver  [kernel.kallsyms]    [k] inet6_sk_rx_dst_set
   3.72%      netserver  [kernel.kallsyms]    [k] ip6_input_finish

Regression came in linux-3.6 with commit 6f3118b571b8 ("ipv6: use
net->rt_genid to check dst validity")

When a route found in ip6_pol_route() is cloned (either using
rt6_alloc_cow() or rt6_alloc_clone()), copy gets an updated rt6i_genid.

But when original route is selected, we need to refresh its rt6i_genid
that could be obsolete. If we do not refresh rt6i_genid, ip6_dst_check()
will fail.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 6f3118b571b8 ("ipv6: use net->rt_genid to check dst validity")
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f23fbd28a501..1e76c3c5b87b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -944,13 +944,20 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
+	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY))) {
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST))
+	} else if (!(rt->dst.flags & DST_HOST)) {
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
-	else
-		goto out2;
+	} else {
+		u32 genid = rt_genid_ipv6(net);
 
+		/* We must refresh rt6i_genid, but only if needed
+		 * to avoid false sharing.
+		 */
+		if (rt->rt6i_genid != genid)
+			rt->rt6i_genid = genid;
+		goto out2;
+	}
 	ip6_rt_put(rt);
 	rt = nrt ? : net->ipv6.ip6_null_entry;
 
