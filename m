From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2 net-next 1/2] net: gro: add a per device gro flush
 timer
Date: Fri, 07 Nov 2014 17:00:44 -0500 (EST)
Message-ID: <20141107.170044.1376374292241401593.davem@redhat.com>
References: <1415311880.13896.85.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141106.223603.678182467467024928.davem@davemloft.net>
	<1415336984.13896.102.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, willemb@google.com,
	amirv@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752256AbaKGWAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 17:00:53 -0500
In-Reply-To: <1415336984.13896.102.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Nov 2014 21:09:44 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Tuning coalescing parameters on NIC can be really hard.
> 
> Servers can handle both bulk and RPC like traffic, with conflicting
> goals : bulk flows want as big GRO packets as possible, RPC want minimal
> latencies.
> 
> To reach big GRO packets on 10Gbe NIC, one can use :
> 
> ethtool -C eth0 rx-usecs 4 rx-frames 44
> 
> But this penalizes rpc sessions, with an increase of latencies, up to
> 50% in some cases, as NICs generally do not force an interrupt when
> a packet with TCP Push flag is received.
> 
> Some NICs do not have an absolute timer, only a timer rearmed for every
> incoming packet.
> 
> This patch uses a different strategy : Let GRO stack decides what do do,
> based on traffic pattern.
> 
> Packets with Push flag wont be delayed.
> Packets without Push flag might be held in GRO engine, if we keep
> receiving data.
> 
> This new mechanism is off by default, and shall be enabled by setting
> /sys/class/net/ethX/gro_flush_timeout to a value in nanosecond.
> 
> To fully enable this mechanism, drivers should use napi_complete_done()
> instead of napi_complete().
> 
> Tested:
>  Ran 200 netperf TCP_STREAM from A to B (10Gbe mlx4 link, 8 RX queues)
> 
> Without this feature, we send back about 305,000 ACK per second.
> 
> GRO aggregation ratio is low (811/305 = 2.65 segments per GRO packet)
> 
> Setting a timer of 2000 nsec is enough to increase GRO packet sizes
> and reduce number of ACK packets. (811/19.2 = 42)
> 
> Receiver performs less calls to upper stacks, less wakes up.
> This also reduces cpu usage on the sender, as it receives less ACK
> packets.
> 
> Note that reducing number of wakes up increases cpu efficiency, but can
> decrease QPS, as applications wont have the chance to warmup cpu caches
> doing a partial read of RPC requests/answers if they fit in one skb.
> 
> B:~# sar -n DEV 1 10 | grep eth0 | tail -1
> Average:         eth0 811269.80 305732.30 1199462.57  19705.72      0.00
> 0.00      0.50
> 
> B:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
> 
> B:~# sar -n DEV 1 10 | grep eth0 | tail -1
> Average:         eth0 811577.30  19230.80 1199916.51   1239.80      0.00
> 0.00      0.50
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: As requested by David, drivers should use napi_complete_done()
>     instead of napi_complete() so that we do not have to track if
>     a packet was received during last NAPI poll.

Applied, thanks.

I do think this looks a lot nicer.
