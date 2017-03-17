From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: apply correct delay when rate
 throttling
Date: Thu, 16 Mar 2017 20:15:54 -0700 (PDT)
Message-ID: <20170316.201554.1318233586227395731.davem@davemloft.net>
References: <20170313171658.18606-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, njunger@uwaterloo.ca
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdCQDQ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:16:29 -0400
In-Reply-To: <20170313171658.18606-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 13 Mar 2017 10:16:58 -0700

> From: Nik Unger <njunger@uwaterloo.ca>
> 
> I recently reported on the netem list that iperf network benchmarks
> show unexpected results when a bandwidth throttling rate has been
> configured for netem. Specifically:
> 
> 1) The measured link bandwidth *increases* when a higher delay is added
> 2) The measured link bandwidth appears higher than the specified limit
> 3) The measured link bandwidth for the same very slow settings varies significantly across
>   machines
> 
> The issue can be reproduced by using tc to configure netem with a
> 512kbit rate and various (none, 1us, 50ms, 100ms, 200ms) delays on a
> veth pair between network namespaces, and then using iperf (or any
> other network benchmarking tool) to test throughput. Complete detailed
> instructions are in the original email chain here:
> https://lists.linuxfoundation.org/pipermail/netem/2017-February/001672.html
> 
> There appear to be two underlying bugs causing these effects:
> 
> - The first issue causes long delays when the rate is slow and no
>   delay is configured (e.g., "rate 512kbit"). This is because SKBs are
>   not orphaned when no delay is configured, so orphaning does not
>   occur until *after* the rate-induced delay has been applied. For
>   this reason, adding a tiny delay (e.g., "rate 512kbit delay 1us")
>   dramatically increases the measured bandwidth.
> 
> - The second issue is that rate-induced delays are not correctly
>   applied, allowing SKB delays to occur in parallel. The indended
>   approach is to compute the delay for an SKB and to add this delay to
>   the end of the current queue. However, the code does not detect
>   existing SKBs in the queue due to improperly testing sch->q.qlen,
>   which is nonzero even when packets exist only in the
>   rbtree. Consequently, new SKBs do not wait for the current queue to
>   empty. When packet delays vary significantly (e.g., if packet sizes
>   are different), then this also causes unintended reordering.
> 
> I modified the code to expect a delay (and orphan the SKB) when a rate
> is configured. I also added some defensive tests that correctly find
> the latest scheduled delivery time, even if it is (unexpectedly) for a
> packet in sch->q. I have tested these changes on the latest kernel
> (4.11.0-rc1+) and the iperf / ping test results are as expected.
> 
> Signed-off-by: Nik Unger <njunger@uwaterloo.ca>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
