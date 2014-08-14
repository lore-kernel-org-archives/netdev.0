From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 11:46:02 -0700
Message-ID: <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ECFDAB.5010701@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:51520 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbaHNSqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 14:46:04 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so2031351pde.38
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 11:46:03 -0700 (PDT)
In-Reply-To: <53ECFDAB.5010701@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 11:19 -0700, Alexander Duyck wrote:
> Yesterday I tripped over a bit of an issue and it seems like we are
> seeing significant cache thrash on kernels 3.10 and newer when running
> multiple streams of small packet stress on multiple NUMA nodes for a
> single NIC.
> 
> I did some bisection and found that I was able to trace it back to
> upstream commit 093162553c33e9479283e107b4431378271c735d (tcp: force a
> dst refcount when prequeue packet).
> 
> Recreating this issue is pretty strait forward.  All I did was setup 2
> dual socket Xeon systems connected back to back with ixgbe and ran the
> following script after disabling tcp_autocork on the transmitting system:
>   for i in `seq 0 19`
>   do
>     for j in `seq 0 2`
>     do
>       netperf -H 192.168.10.1 -t TCP_STREAM \
>               -l 10 -c -C -T $i,$i -P 0 -- \
>               -m 64 -s 64K -D
>     done
>   done
> 
> The current net tree as-is will give me about 2Gb/s of data w/ 100% CPU
> utilization on the receiving system, and with the patch above reverted
> on that system it gives me about 4Gb/s with only 21% CPU utilization.
> If I set tcp_low_latency=1 I can get the CPU utilization down to about
> 12% on the same test with about 4Gb/s of throughput.
> 
> I'm still working on determining the exact root cause but it looks to me
> like there is some significant cache thrash going on in regards to the
> dst entries.
> 
> Below is a quick breakdown of the top CPU users for tcp_low_latency
> on/off using perf top:
> 
> tcp_low_latency = 0

> 
> tcp_low_latency = 1
> Any input/advice on where I should look or patches to possibly test
> would be appreciated.


I believe you answered your own question : prequeue mode does not work
very well when one host has hundred of active TCP flows to one other.

In real life, applications do not use prequeue, because nobody wants one
thread per flow.

Each socket has its own dst now route cache was removed, but if your
netperf migrates cpu (and NUMA node), we do not detect the dst should be
re-created onto a different NUMA node.

But really, I am not sure we want to care about prequeue, as modern
applications uses epoll()/poll()/select() instead of blocking on
recvmsg()
