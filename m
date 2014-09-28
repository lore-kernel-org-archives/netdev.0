From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dql: dql_queued() should write first to
 reduce bus transactions
Date: Sun, 28 Sep 2014 17:43:41 -0400 (EDT)
Message-ID: <20140928.174341.2056306997547610435.davem@davemloft.net>
References: <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, brouer@redhat.com, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com, toke@toke.dk, fw@strlen.de,
	jhs@mojatatu.com, dave.taht@gmail.com, john.r.fastabend@intel.com,
	dborkman@redhat.com, hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaI1Vno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:43:44 -0400
In-Reply-To: <1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 25 Sep 2014 23:04:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While doing high throughput test on a BQL enabled NIC,
> I found a very high cost in ndo_start_xmit() when accessing BQL data.
> 
> It turned out the problem was caused by compiler trying to be
> smart, but involving a bad MESI transaction :
> 
>   0.05 │  mov    0xc0(%rax),%edi    // LOAD dql->num_queued
>   0.48 │  mov    %edx,0xc8(%rax)    // STORE dql->last_obj_cnt = count
>  58.23 │  add    %edx,%edi
>   0.58 │  cmp    %edi,0xc4(%rax)
>   0.76 │  mov    %edi,0xc0(%rax)    // STORE dql->num_queued += count
>   0.72 │  js     bd8
> 
> 
> I got an incredible 10 % gain [1] by making sure cpu do not attempt
> to get the cache line in Shared mode, but directly requests for
> ownership.
> 
> New code :
> 	mov    %edx,0xc8(%rax)  // STORE dql->last_obj_cnt = count
> 	add    %edx,0xc0(%rax)  // RMW   dql->num_queued += count
> 	mov    0xc4(%rax),%ecx  // LOAD dql->adj_limit
> 	mov    0xc0(%rax),%edx  // LOAD dql->num_queued
> 	cmp    %edx,%ecx
> 
> The TX completion was running from another cpu, with high interrupts
> rate.
> 
> Note that I am using barrier() as a soft hint, as mb() here could be
> too heavy cost.
> 
> [1] This was a netperf TCP_STREAM with TSO disabled, but GSO enabled.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Ok now you're just showing off :-)  Applied, thanks!
