From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Tue, 30 Nov 2010 15:42:56 +0000
Message-ID: <1291131776.21077.27.camel@bwh-desktop>
References: <20101130135549.GA22688@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54942 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab0K3Pm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 10:42:59 -0500
In-Reply-To: <20101130135549.GA22688@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-30 at 22:55 +0900, Simon Horman wrote:
> Hi,
> 
> I just wanted to share what is a rather pleasing,
> though to me somewhat surprising result.
>
> I am testing bonding using balance-rr mode with three physical links to try
> to get > gigabit speed for a single stream. Why?  Because I'd like to run
> various tests at > gigabit speed and I don't have any 10G hardware at my
> disposal.
> 
> The result I have is that with a 1500 byte MTU, tcp_reordering=3 and both
> LSO and GSO disabled on both the sender and receiver I see:
> 
> # netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 1472
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216
> (172.17.60.216) port 0 AF_INET
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
> 
>   87380  16384   1472    10.01      1646.13   40.01    -1.00    3.982  -1.000
> 
> But with GRO enabled on the receiver I see.
> 
> # netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 1472
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216
> (172.17.60.216) port 0 AF_INET
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
> 
>  87380  16384   1472    10.01      2613.83   19.32    -1.00    1.211   -1.000
> 
> Which is much better than any result I get tweaking tcp_reordering when
> GRO is disabled on the receiver.

Did you also enable TSO/GSO on the sender?

What TSO/GSO will do is to change the round-robin scheduling from one
packet per interface to one super-packet per interface.  GRO then
coalesces the physical packets back into a super-packet.  The intervals
between receiving super-packets then tend to exceed the difference in
delay between interfaces, hiding the reordering.

If you only enabled GRO then I don't understand this.

> Tweaking tcp_reordering when GRO is enabled on the receiver seems to have
> negligible effect.  Which is interesting, because my brief reading on the
> subject indicated that tcp_reordering was the key tuning parameter for
> bonding with balance-rr.
> 
> The only other parameter that seemed to have significant effect was to
> increase the mtu.  In the case of MTU=9000, GRO seemed to have a negative
> impact on throughput, though a significant positive effect on CPU
> utilisation.
[...]

Increasing MTU also increases the interval between packets on a TCP flow
using maximum segment size so that it is more likely to exceed the
difference in delay.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

