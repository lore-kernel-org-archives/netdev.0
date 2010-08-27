From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Thu, 26 Aug 2010 22:22:23 -0700
Message-ID: <4C774B8F.2030805@candelatech.com>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com>	<20100826.155915.200379485.davem@davemloft.net>	<4C773BAF.7010809@candelatech.com> <20100826.213419.189712657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37953 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609Ab0H0FWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 01:22:25 -0400
In-Reply-To: <20100826.213419.189712657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 09:34 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Thu, 26 Aug 2010 21:14:39 -0700
>
>> I'll look into the NET_XMIT_CN, but if that propagates backpressure up
>> through mac-vlan, then something must know how to re-start the tx
>> logic.
>
> It doesn't need to, as it drops and frees up the packet.

If there were 5 pkts in the socket buffer, and the attempt to
send the first one caused NET_XMIT_CN, then
based on your comment below about UDP being throttled, I assume
the other 4 are kept until later?

What logic wakes up the socket transmit logic for those other 4
packets?

For sch_generic, it never returns NET_XMIT_CN at all..it just returns
NET_XMIT_DROP and deletes the passed-in skb.  Others, such as sch_fifo
drop the oldest pkt, keep the one passed in, and returns NET_XMIT_CN,
so it could not benefit from my patch.

>> One thing that really bothers me about the current qdisc stuff is that
>> it just frees the packet when it cannot accept it.
>
> Without the drop, things like RED simply would not work.

Even if RED could never work, the sch_generic can.

>> This *should* allow us to better throttle UDP sockets without
>> dropping as many packets on the sending side, and would probably
>> help TCP as well.
>
> UDP is well throttled by the socket send buffer.
>
> The only problematic case is pktgen and it's an abberation and
> an obscure case.  It's in fact trying to bypass all of the
> queueing and accounting the stack normally makes use of.

 From looking at upstream code, it seems that pktgen does the
right thing when NET_XMIT_CN or NET_XMIT_DROP is returned,
as long as you don't mind busy-spinning and perhaps some
accounting errors (NET_XMIT_CN doesn't mean *your* pkt was
deleted, just that somebody's packet was).

For accounting purposes, it would still be nice to get
NET_TX_BUSY because then you can just retry the packet
and you know that your packet was not transmitted or dropped.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
