From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 15:29:26 -0700
Message-ID: <468041C6.4060309@hp.com>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com> <5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: OBATA Noboru <noboru.obata.ar@hitachi.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:42488 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754544AbXFYW3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 18:29:34 -0400
In-Reply-To: <5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald wrote:
> On 6/26/07, OBATA Noboru <noboru.obata.ar@hitachi.com> wrote:
> 
>> From: OBATA Noboru <noboru.obata.ar@hitachi.com>
>>
>> Make TCP_RTO_MAX a variable, and allow a user to change it via a
>> new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
>> then guarantee TCP retransmission to be more controllable, say,
>> at least once per 10 seconds, by setting it to 10.  This is
>> quite helpful on failover-capable network devices, such as an
>> active-backup bonding device.  On such devices, it is desirable
>> that TCP retransmits a packet shortly after the failover, which
>> is what I would like to do with this patch.  Please see
>> Background and Problem below for rationale in detail.
>>
> RFC2988 says this:
>   (2.4) Whenever RTO is computed, if it is less than 1 second then the
>         RTO SHOULD be rounded up to 1 second.
> 
>         Traditionally, TCP implementations use coarse grain clocks to
>         measure the RTT and trigger the RTO, which imposes a large
>         minimum value on the RTO.  Research suggests that a large
>         minimum RTO is needed to keep TCP conservative and avoid
>         spurious retransmissions [AP99].  Therefore, this
>         specification requires a large minimum RTO as a conservative
>         approach, while at the same time acknowledging that at some
>         future point, research may show that a smaller minimum RTO is
>         acceptable or superior.
> 
>   (2.5) A maximum value MAY be placed on RTO provided it is at least 60
>         seconds.
> 
> Your code doesn't seem to meet requirements of section 2.5 as your
> minimum is 1 second.

(At the risk of having another Emily Litella moment entering a 
discussion late...)

I thought that those sorts of things were generally referring to the 
_default_ setting?

> I think if you're trying to solve the bonding issue then you should
> solve that issue, not hack the TCP implementation as that opens it up
> to abuse in other ways.

FWIW, other stacks have a "tcp_rexmit_interval_max" without too much 
trouble:

$ ndd -h tcp_rexmit_interval_max

tcp_rexmit_interval_max:

     Upper limit for computed round trip time-out. [1,7200000]
     Default: 60000 (1 minute)

[Interesting to me that the default happens to be the aforementioned 60 
seconds :) ]

In the abstract, if we wanted a quick recovery in TCP from a link 
failover, I suppose it could be possible for a machine-local link 
failover if the link-failover code could then call back up into TCP to 
say "Yo, TCP, any connections you had going over this link/path/route 
should probably go ahead and try retransmitting now rather than later."

Of course, that does seem rather more complicated than having the 
administrator set an upper bound on the RTO, and wouldn't deal with 
non-machine-local link failover.

rick jones
