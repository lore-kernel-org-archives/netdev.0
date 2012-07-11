From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 08:16:58 -0700
Message-ID: <4FFD98EA.1040301@candelatech.com>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>  <1340945457.29822.7.camel@edumazet-glaptop>  <1341396687.2583.1757.camel@edumazet-glaptop>  <20120709.000834.1182150057463599677.davem@davemloft.net>  <1341845722.3265.3065.camel@edumazet-glaptop>  <1341933215.3265.5476.camel@edumazet-glaptop> <1342019518.3265.8116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ycheng@google.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, therbert@google.com,
	mattmathis@google.com, nanditad@google.com, ncardwell@google.com,
	andrewmcgr@gmail.com, Rick Jones <rick.jones2@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:32922 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab2GKPRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 11:17:14 -0400
In-Reply-To: <1342019518.3265.8116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 08:11 AM, Eric Dumazet wrote:
> On Tue, 2012-07-10 at 17:13 +0200, Eric Dumazet wrote:
>> This introduce TSQ (TCP Small Queues)
>>
>> TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &
>> device queues), to reduce RTT and cwnd bias, part of the bufferbloat
>> problem.
>>
>> sk->sk_wmem_alloc not allowed to grow above a given limit,
>> allowing no more than ~128KB [1] per tcp socket in qdisc/dev layers at a
>> given time.
>>
>> TSO packets are sized/capped to half the limit, so that we have two
>> TSO packets in flight, allowing better bandwidth use.
>>
>> As a side effect, setting the limit to 40000 automatically reduces the
>> standard gso max limit (65536) to 40000/2 : It can help to reduce
>> latencies of high prio packets, having smaller TSO packets.
>>
>> This means we divert sock_wfree() to a tcp_wfree() handler, to
>> queue/send following frames when skb_orphan() [2] is called for the
>> already queued skbs.
>>
>> Results on my dev machine (tg3 nic) are really impressive, using
>> standard pfifo_fast, and with or without TSO/GSO. Without reduction of
>> nominal bandwidth.
>>
>> I no longer have 3MBytes backlogged in qdisc by a single netperf
>> session, and both side socket autotuning no longer use 4 Mbytes.
>>
>> As skb destructor cannot restart xmit itself ( as qdisc lock might be
>> taken at this point ), we delegate the work to a tasklet. We use one
>> tasklest per cpu for performance reasons.
>>
>>
>>
>> [1] New /proc/sys/net/ipv4/tcp_limit_output_bytes tunable
>> [2] skb_orphan() is usually called at TX completion time,
>>    but some drivers call it in their start_xmit() handler.
>>    These drivers should at least use BQL, or else a single TCP
>>    session can still fill the whole NIC TX ring, since TSQ will
>>    have no effect.
>
> I am going to send an official patch (I'll put a v3 tag in it)
>
> I believe I did a full implementation, including the xmit() done
> by the user at release_sock() time, if the tasklet found socket owned by
> the user.
>
> Some bench results about the choice of 128KB being the default value:
>
> 64KB seems the 'good' value on 10Gb links to reach max throughput on my
> lab machines (ixgbe adapters).
>
> Using 128KB is a very conservative value to allow link rate on 20Gbps.
>
> Still, it allows less than 1ms of buffering on a Gbit link, and less
> than 8ms on 100Mbit link (instead of 130ms without Small Queues)

I haven't read your patch in detail, but I was wondering if this feature
would cause trouble for applications that are servicing many sockets at once
and so might take several ms between handling each individual socket.

Or, applications that for other reasons cannot service sockets quite
as fast.  Without this feature, they could poke more data into the
xmit queues to be handled by the kernel while the app goes about it's
other user-space work?

Maybe this feature could be enabled/tuned on a per-socket basis?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
