From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory accounting for dgram sockets
Date: Mon, 10 Mar 2014 02:07:54 +0100
Message-ID: <20140310010754.GE5493@order.stressinduktion.org>
References: <20140226202154.GA9626@order.stressinduktion.org> <20140226.154232.1642777813885536970.davem@davemloft.net> <20140304201336.GB26307@order.stressinduktion.org> <20140304.153732.1314382655798460205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52491 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbaCJBH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 21:07:56 -0400
Content-Disposition: inline
In-Reply-To: <20140304.153732.1314382655798460205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 04, 2014 at 03:37:32PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 4 Mar 2014 21:13:36 +0100
> 
> > Just a small followup:
> > 
> > Because of the additional sock_wfree during skb handover in unix_dgram_sendmsg
> > the spinlock in __wake_up_sync_key is hit more often thus more cacheline
> > bouncing.
> > 
> > Deferring the POLLOUT notification after the sock_rfree in unix_dgram_recvmsg
> > already halfed the number of context switches with the new patch.
> > 
> > I try to play with some other ideas this week and will submit new patch with
> > performance numbers.
> > 
> > Haven't noticed any problems with the additional atomic operations
> > performance-wise so far.
> 
> Ok, thanks for the update.

I need to have some feedback regarding backwards compatibility, so still no
final patch:

First the unconnected send/reply benchmark, which look good.

/home/hannes/netperf-2.6.0/src/netperf -t  DG_RR -- -r 1,1

=== Unpatched net-next: ===
DG REQUEST/RESPONSE TEST
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

212992 212992 1        1       10.00    23587.28
4608   2304

=== Patched net-next: ===
DG REQUEST/RESPONSE TEST
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

212992 212992 1        1       10.00    21607.50
4608   2304

I guess it doesn't matter much. As soon as I start profiling the
difference vanishes even more. perf diff shows now difference in
unix_dgram_sendmsg.

I couldn't do the parameterless netperf DG_STREAM benchmarks, because
netserver unconditionally sets SO_RCVBUF to 0 and such the clamps this value
to SOCK_MIN_RCVBUF. The sender cannot send netperf's normal packet size
through the socket. In case there are other applications out there,
are we allowed to break them?

Otherwise benchmark results for stream tests don't look that good because
of rescheduling from sock_wfree and I didn't find an easy way to reduce
them besides playing dirty tricks with SOCK_USE_WRITE_QUEUE for which
I could not come up with a proper and race-free idea.

/home/hannes/netperf-2.6.0/src/netperf -t  DG_STREAM -- -m 1024

=== Unpatched net-next: ===
DG UNIDIRECTIONAL SEND TEST
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992    1024    10.02      963846      0     787.68
 2304            10.02      963846            787.68

=== Patched net-next: ===
DG UNIDIRECTIONAL SEND TEST
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992    1024    10.00      347507      0     284.68
 2304            10.00      347507            284.68

The important question for me is if we can assume applications already
setting SO_RCVBUF to some minimal value and because of this not receiving
packets being buggy and ignore them or do we need to introduce some way
around this?

Greetings,

  Hannes
