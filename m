From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Multiqueue pktgen and ingress path (Was: [PATCH v5 2/2] pktgen:
 introduce xmit_mode '<start_xmit|netif_receive>')
Date: Fri, 08 May 2015 09:53:34 -0700
Message-ID: <554CEA0E.4050509@gmail.com>
References: <20150507143329.8534.49710.stgit@ivy>	<20150507143500.8534.4435.stgit@ivy>	<554B9293.2070702@plumgrid.com>	<554B9CDE.1050703@iogearbox.net>	<20150508173900.3fcf78de@redhat.com> <20150508174927.5b1ecdd1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36033 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbbEHQxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 12:53:55 -0400
Received: by pdea3 with SMTP id a3so92010689pde.3
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 09:53:55 -0700 (PDT)
In-Reply-To: <20150508174927.5b1ecdd1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2015 08:49 AM, Jesper Dangaard Brouer wrote:
> More interesting observations with the mentioned script (now attached).
>
> On my system the scaling stopped a 24Mpps, when I increased the number
> of threads the collective scaling was stuck at 24Mpps.
>
> Then I simply removed/compiled-out the:
>   atomic_long_inc(&skb->dev->rx_dropped);
>
> And after that change, the scaling is basically infinite/perfect.
>
> Single thread performance increased from 24.7Mpps to 31.1Mpps, which
> corresponds perfectly with the cost of an atomic operation on this HW
> (8.25ns).
>
> Diff to before:
>   * (1/24700988*10^9)-(1/31170819*10^9) = 8.40292328196 ns
>
> When increasing the threads now, they all basically run at 31Mpps.
> Tried it upto 12 threads.
>
>
> I'm quite puzzled why a single atomic op could "freeze" my system from
> scaling beyond 24Mpps.

The atomic access likely acts as a serializing event, and on top of that 
it would increase in time needed to be completed as you add more 
threads.  I am guessing the 8ns is probably the cost for a single 
threaded setup where the memory location is available in L2 or L1 
cache.  If it is in L3 cache that would make it more expensive.  If it 
is currently in use by another CPU then that would make it even more 
expensive.  If it is in use on another socket then we are probably 
looking at something in the high 10s if not 100s of nanoseconds.  Once 
you hit the point where the time for the atomic transaction multiplied 
by the number of threads is equal to the time it takes for any one 
thread to complete the operation you have hit the upper limit and 
everything after that is just wasted cycles spinning while waiting for 
cache line access.

So for example if you had 2 threads on the same socket you are looking 
at an L3 cache access which takes about 30 cycles.  That 30 cycles would 
likely be in addition to the 8ns you were already seeing for single 
thread performance, and I don't know if it includes the cache flush 
needed by the remote L1/L2 where the cache line currently resides.  I'd 
be interested in seeing what the 2 socket data looked like as I suspect 
you would take an even heavier hit for that.

- Alex
