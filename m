From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory
 accounting for dgram sockets
Date: Mon, 10 Mar 2014 16:27:56 -0400 (EDT)
Message-ID: <20140310.162756.2102404684106170700.davem@davemloft.net>
References: <20140304201336.GB26307@order.stressinduktion.org>
	<20140304.153732.1314382655798460205.davem@davemloft.net>
	<20140310010754.GE5493@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbaCJU17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:27:59 -0400
In-Reply-To: <20140310010754.GE5493@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 10 Mar 2014 02:07:54 +0100

> On Tue, Mar 04, 2014 at 03:37:32PM -0500, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Tue, 4 Mar 2014 21:13:36 +0100
>> 
>> > Just a small followup:
>> > 
>> > Because of the additional sock_wfree during skb handover in unix_dgram_sendmsg
>> > the spinlock in __wake_up_sync_key is hit more often thus more cacheline
>> > bouncing.
>> > 
>> > Deferring the POLLOUT notification after the sock_rfree in unix_dgram_recvmsg
>> > already halfed the number of context switches with the new patch.
>> > 
>> > I try to play with some other ideas this week and will submit new patch with
>> > performance numbers.
>> > 
>> > Haven't noticed any problems with the additional atomic operations
>> > performance-wise so far.
>> 
>> Ok, thanks for the update.
> 
> I need to have some feedback regarding backwards compatibility, so still no
> final patch:
> 
> First the unconnected send/reply benchmark, which look good.
> 
> /home/hannes/netperf-2.6.0/src/netperf -t  DG_RR -- -r 1,1
> 
> === Unpatched net-next: ===
> DG REQUEST/RESPONSE TEST
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
> 
> 212992 212992 1        1       10.00    23587.28
> 4608   2304
> 
> === Patched net-next: ===
> DG REQUEST/RESPONSE TEST
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
> 
> 212992 212992 1        1       10.00    21607.50
> 4608   2304

If I read those transaction rate numbers correctly, it's slowing
down by more then %8.  I'm not so sure that looks "good" to me.

> I couldn't do the parameterless netperf DG_STREAM benchmarks, because
> netserver unconditionally sets SO_RCVBUF to 0 and such the clamps this value
> to SOCK_MIN_RCVBUF. The sender cannot send netperf's normal packet size
> through the socket. In case there are other applications out there,
> are we allowed to break them?
 ...
> The important question for me is if we can assume applications already
> setting SO_RCVBUF to some minimal value and because of this not receiving
> packets being buggy and ignore them or do we need to introduce some way
> around this?

I think if it works currently, the risk of breaking a lot of things is simply
too high to change this.
