From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Sat, 06 Sep 2014 11:21:52 -0700
Message-ID: <1410027712.11872.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ED4354.9090904@intel.com>
	 <20140814.162024.2218312002979492106.davem@davemloft.net>
	 <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
	 <20140821.162406.2076033247433267586.davem@davemloft.net>
	 <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410018384.11872.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410021507.11872.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:61876 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbaIFSVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 14:21:55 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so1291539pad.2
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 11:21:54 -0700 (PDT)
In-Reply-To: <1410021507.11872.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-06 at 09:38 -0700, Eric Dumazet wrote:
> On Sat, 2014-09-06 at 08:46 -0700, Eric Dumazet wrote:
> 
> > Works fine on IPv4, not on IPv6, I will submit a v2 (with a proper title
> > btw)
> 
> Oh well, we first need to fix IPv6 early demux.
> 
> Current net-next kernel profile
> 
> +  20.95%      netserver  [kernel.kallsyms]    [k] dst_release     
> +  19.33%      netserver  [kernel.kallsyms]    [k] ip6_pol_route.isra.46
> +  11.75%      netserver  [kernel.kallsyms]    [k] inet6_sk_rx_dst_set
> +   3.72%      netserver  [kernel.kallsyms]    [k] ip6_input_finish
> 
> So we repeat over and over calls to inet6_sk_rx_dst_set(),
> something is surely wrong.
> 

Nicolas, it seems that after your commit
(6f3118b571b8a4c06c7985dc3172c3526cb86253 "ipv6: use net->rt_genid to
check dst validity")  IP early demux is broken.


Basically, we now hit the following condition in ip6_dst_check()

if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev))) 

In my traces, rt->rt6i_genid stays at 2, and the rt_genid_ipv6()
increments every time a route is added/deleted.

So we keep calling dst_release(), and inet6_sk_rx_dst_set(),
but the route we keep installing is already wrong, as its genid is too
old.

Does following fix make any sense ?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f74b0417bd60..a139a16298e3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -947,9 +947,10 @@ restart:
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
-	else
+	else {
+		rt->rt6i_genid = rt_genid_ipv6(net);
 		goto out2;
-
+	}
 	ip6_rt_put(rt);
 	rt = nrt ? : net->ipv6.ip6_null_entry;
 
