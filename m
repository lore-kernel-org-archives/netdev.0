From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Fri, 06 Sep 2013 09:56:44 -0700
Message-ID: <1378486604.31445.34.camel@edumazet-glaptop>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	 <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:43426 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab3IFQ4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 12:56:46 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so3467691pbb.33
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 09:56:45 -0700 (PDT)
In-Reply-To: <522A049A.7000105@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 17:36 +0100, Zoltan Kiss wrote:
> On 06/09/13 13:57, Eric Dumazet wrote:
> > Well, I have no problem to get line rate on 20Gb with a single flow, so
> > other drivers have no problem.
> I've made some tests on bare metal:
> Dell PE R815, Intel 82599EB 10Gb, 3.11-rc4 32 bit kernel with 3.17.3 
> ixgbe (TSO, GSO on), iperf 2.0.5
> Transmitting packets toward the remote end (so running iperf -c on this 
> host) can make 8.3 Gbps with the default 128k tcp_limit_output_bytes. 
> When I increased this to 131.506 (128k + 434 bytes) suddenly it jumped 
> to 9.4 Gbps. Iperf CPU usage also jumped a few percent from ~36 to ~40% 
> (softint percentage in top also increased from ~3 to ~5%)

Typical tradeoff between latency and throughput

If you favor throughput, then you can increase tcp_limit_output_bytes

The default is quite reasonable IMHO.

> So I guess it would be good to revisit the default value of this 
> setting. What hw you used Eric for your 20Gb results?

Mellanox CX-3

Make sure your NIC doesn't hold TX packets in TX ring too long before
signaling an interrupt for TX completion.

For example I had to patch mellanox :

commit ecfd2ce1a9d5e6376ff5c00b366345160abdbbb7
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Nov 5 16:20:42 2012 +0000

    mlx4: change TX coalescing defaults
    
    mlx4 currently uses a too high tx coalescing setting, deferring
    TX completion interrupts by up to 128 us.
    
    With the recent skb_orphan() removal in commit 8112ec3b872,
    performance of a single TCP flow is capped to ~4 Gbps, unless
    we increase tcp_limit_output_bytes.
    
    I suggest using 16 us instead of 128 us, allowing a finer control.
    
    Performance of a single TCP flow is restored to previous levels,
    while keeping TCP small queues fully enabled with default sysctl.
    
    This patch is also a BQL prereq.
    
    Reported-by: Vimalkumar <j.vimal@gmail.com>
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
    Cc: Or Gerlitz <ogerlitz@mellanox.com>
    Acked-by: Amir Vadai <amirv@mellanox.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
