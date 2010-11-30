From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Tue, 30 Nov 2010 09:56:02 -0800
Message-ID: <4CF53AB2.60209@hp.com>
References: <20101130135549.GA22688@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:13239 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab0K3R4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 12:56:06 -0500
In-Reply-To: <20101130135549.GA22688@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
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

Why 1472 bytes per send?  If you wanted a 1-1 between the send size and the MSS, 
I would guess that 1448 would have been in order.  1472 would be the maximum 
data payload for a UDP/IPv4 datagram.  TCP will have more header than UDP.

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

If you are changing things on the receiver, you should probably enable remote 
CPU utilization measurement with the -C option.

> Which is much better than any result I get tweaking tcp_reordering when
> GRO is disabled on the receiver.
> 
> Tweaking tcp_reordering when GRO is enabled on the receiver seems to have
> negligible effect.  Which is interesting, because my brief reading on the
> subject indicated that tcp_reordering was the key tuning parameter for
> bonding with balance-rr.

You are in a maze of twisty heuristics and algorithms, all interacting :)  If 
there are only three links in the bond, I suspect the chances for spurrious fast 
retransmission are somewhat smaller than if you had say four, based on just 
hand-waving on three duplicate ACKs requires receipt of perhaps four out of 
order segments.

> The only other parameter that seemed to have significant effect was to
> increase the mtu.  In the case of MTU=9000, GRO seemed to have a negative
> impact on throughput, though a significant positive effect on CPU
> utilisation.
> 
> MTU=9000, sender,receiver:tcp_reordering=3(default), receiver:GRO=off
> netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 9872

9872?

> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
> 
>  87380  16384   9872    10.01      2957.52   14.89    -1.00    0.825   -1.000
> 
> MTU=9000, sender,receiver:tcp_reordering=3(default), receiver:GRO=on
> netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 9872
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
> 
>  87380  16384   9872    10.01      2847.64   10.84    -1.00    0.624   -1.000

Short of packet traces, taking snapshots of netstat statistics before and after 
each netperf run might be goodness - you can look at things like ratio of ACKs 
to data segments/bytes and such.  LRO/GRO can have a non-trivial effect on the 
number of ACKs, and ACKs are what matter for fast retransmit.

netstat -s > before
netperf ...
netstat -s > after
beforeafter before after > delta

where beforeafter comes (for now, the site will have to go away before long as 
the campus on which it is located has been sold) 
ftp://ftp.cup.hp.com/dist/networking/tools/  and will subtract before from after.

happy benchmarking,

rick jones
