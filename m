From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: give prequeue mode some care
Date: Thu, 28 Apr 2016 17:15:14 -0400 (EDT)
Message-ID: <20160428.171514.1303373912379094235.davem@davemloft.net>
References: <1461777145.5535.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbcD1VPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:15:16 -0400
In-Reply-To: <1461777145.5535.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Apr 2016 10:12:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP prequeue goal is to defer processing of incoming packets
> to user space thread currently blocked in a recvmsg() system call.
> 
> Intent is to spend less time processing these packets on behalf
> of softirq handler, as softirq handler is unfair to normal process
> scheduler decisions, as it might interrupt threads that do not
> even use networking.
> 
> Current prequeue implementation has following issues :
> 
> 1) It only checks size of the prequeue against sk_rcvbuf
> 
>    It was fine 15 years ago when sk_rcvbuf was in the 64KB vicinity.
>    But we now have ~8MB values to cope with modern networking needs.
>    We have to add sk_rmem_alloc in the equation, since out of order
>    packets can definitely use up to sk_rcvbuf memory themselves.
> 
> 2) Even with a fixed memory truesize check, prequeue can be filled
>    by thousands of packets. When prequeue needs to be flushed, either
>    from sofirq context (in tcp_prequeue() or timer code), or process
>    context (in tcp_prequeue_process()), this adds a latency spike
>    which is often not desirable.
>    I added a fixed limit of 32 packets, as this translated to a max
>    flush time of 60 us on my test hosts.
> 
>    Also note that all packets in prequeue are not accounted for tcp_mem,
>    since they are not charged against sk_forward_alloc at this point.
>    This is probably not a big deal.
> 
> Note that this might increase LINUX_MIB_TCPPREQUEUEDROPPED counts,
> which is misnamed, as packets are not dropped at all, but rather pushed
> to the stack (where they can be either consumed or dropped)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

There was a conflict due to the stats macro renaming, but that was trivial
to resolve so I did it.

Applied, thanks Eric.
