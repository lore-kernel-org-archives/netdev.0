From: Simon Horman <horms@verge.net.au>
Subject: Bonding, GRO and tcp_reordering
Date: Tue, 30 Nov 2010 22:55:52 +0900
Message-ID: <20101130135549.GA22688@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41763 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761Ab0K3Nz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 08:55:58 -0500
Received: from ayumi.akashicho.tokyo.vergenet.net (219-109-213-121.bitcat.net [219.109.213.121])
	by kirsty.vergenet.net (Postfix) with ESMTP id 262B124062
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 00:55:56 +1100 (EST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just wanted to share what is a rather pleasing,
though to me somewhat surprising result.

I am testing bonding using balance-rr mode with three physical links to try
to get > gigabit speed for a single stream. Why?  Because I'd like to run
various tests at > gigabit speed and I don't have any 10G hardware at my
disposal.

The result I have is that with a 1500 byte MTU, tcp_reordering=3 and both
LSO and GSO disabled on both the sender and receiver I see:

# netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 1472
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216
(172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

  87380  16384   1472    10.01      1646.13   40.01    -1.00    3.982  -1.000

But with GRO enabled on the receiver I see.

# netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 1472
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216
(172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384   1472    10.01      2613.83   19.32    -1.00    1.211   -1.000

Which is much better than any result I get tweaking tcp_reordering when
GRO is disabled on the receiver.

Tweaking tcp_reordering when GRO is enabled on the receiver seems to have
negligible effect.  Which is interesting, because my brief reading on the
subject indicated that tcp_reordering was the key tuning parameter for
bonding with balance-rr.

The only other parameter that seemed to have significant effect was to
increase the mtu.  In the case of MTU=9000, GRO seemed to have a negative
impact on throughput, though a significant positive effect on CPU
utilisation.

MTU=9000, sender,receiver:tcp_reordering=3(default), receiver:GRO=off
netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 9872
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384   9872    10.01      2957.52   14.89    -1.00    0.825   -1.000

MTU=9000, sender,receiver:tcp_reordering=3(default), receiver:GRO=on
netperf -c -4 -t TCP_STREAM -H 172.17.60.216 -- -m 9872
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384   9872    10.01      2847.64   10.84    -1.00    0.624   -1.000


Test run using 2.6.37-rc1
