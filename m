From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question] net/mlx4_en: Memory consumption issue with mlx4_en
 driver
Date: Wed, 11 Mar 2015 13:21:02 -0700
Message-ID: <1426105262.11398.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150311185146.GA1032293@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	kernel-team@fb.com
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33101 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbbCKUVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:21:04 -0400
Received: by iecvj10 with SMTP id vj10so4676228iec.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 13:21:03 -0700 (PDT)
In-Reply-To: <20150311185146.GA1032293@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 11:51 -0700, Martin Lau wrote:
> Hi,
> 
> We have seen a memory consumption issue related to the mlx4 driver.
> We suspect it is related to the page order used to do the alloc_pages().
> The order starts by 3 and then try the next lower value in case of failure.
> I have copy and paste the alloc_pages() call site at the end of the email.
> 
> Is it a must to get order 3 pages?  Based on the code and its comment,
> it seems it is a little bit of functional and/or performance reason.
> Can you share some perf test numbers on different page order allocation,
> like 3 vs 2 vs 1?
> 
> It can be reproduced by:
> 1. At netserver (receiver), sysctl net.ipv4.tcp_rmem ='4096 125000  67108864'
>    and net.core.rmem_max=67108864.
> 2. Start two netservers listening on 2 different ports:
>    - One for taking 1000 background netperf flows
>    - Another netserver for taking 200 netperf flows.  It will be
>      suspended (ctrl-z) in the middle of the test.
> 2. Start 1000 background netperf TCP_STREAM flows
> 3. Start another 200 netperf TCP_STREAM flows
> 4. Suspend the netserver taking the 200 flows.
> 5. Observe the socket memory usage of the suspended netserver by 'ss -t -m'.
>    200 of them will eventually reach 64MB rmem.
> 
> We observed the total socket rmem usage reported by 'ss -t -m'
> has a huge difference from /proc/meminfo. We have seen ~6x-10x difference.
> 
> Any of the fragment queued in the suspended socket will
> hold a refcount to page->_count and stop 8 pages from freeing.
> The net.ipv4.tcp_mem seems not saving us here since it only
> counts the skb->truesize which is 1536 in our setup.
> 
> Thanks,
> --Martin

You know, even the order-3 allocations done for regular skb allocations
will hurt you : a single copybreaked skb stored a long time in a tcp
receive queue will hold 32KB of memory.

Even 4KB can lead to disasters.

You could lower tcp_rmem so that collapsing happens sooner.
