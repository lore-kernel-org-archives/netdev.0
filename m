From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3.2 085/115] veth: don???t modify ip_summed; doing so
 treats packets with bad checksums as good.
Date: Fri, 13 May 2016 09:57:19 -0700
Message-ID: <5736076F.10003@candelatech.com>
References: <1462041181.17662.3.camel@decadent.org.uk>
 <57250A17.5090804@candelatech.com>
 <CALx6S36cqecPH+Zd8pGVdFHRi7bmWgAwm2UgFVprt5JOuO47UA@mail.gmail.com>
 <57251CB3.1040504@candelatech.com>
 <CAKUBDd-_5RouHduHvjOqgOpyAArEBd80BEy4KBDPLRQoTtWb2Q@mail.gmail.com>
 <572523C4.4080307@candelatech.com>
 <CAKUBDd8fksttZOW3T5zdKD4rzbcZzZer-DCMMsA2zKF4A_hXQw@mail.gmail.com>
 <57252918.7070302@candelatech.com>
 <CAKUBDd8S2=YcJ5wtM24D6-vw+bMud=Om9TBykMvSYcJ4X5tryw@mail.gmail.com>
 <57253527.7010009@candelatech.com> <20160501053059.GA26097@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, Vijay Pandurangan <vijayp@vijayp.ca>,
	Tom Herbert <tom@herbertland.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	akpm@linux-foundation.org, Cong Wang <cwang@twopensource.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20160501053059.GA26097@1wt.eu>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mr Miller:

How do you feel about a new socket-option to allow a socket to
request the old veth behaviour?

Thanks,
Ben

On 04/30/2016 10:30 PM, Willy Tarreau wrote:
> On Sat, Apr 30, 2016 at 03:43:51PM -0700, Ben Greear wrote:
>> On 04/30/2016 03:01 PM, Vijay Pandurangan wrote:
>>> Consider:
>>>
>>> - App A  sends out corrupt packets 50% of the time and discards inbound data.
> (...)
>> How can you make a generic app C know how to do this?  The path could be,
>> for instance:
>>
>> eth0 <-> user-space-A <-> vethA <-> vethB <-> { kernel routing logic } <-> vethC <-> vethD <-> appC
>>
>> There are no sockets on vethB, but it does need to have special behaviour to elide
>> csums.  Even if appC is hacked to know how to twiddle some thing on it's veth port,
>> mucking with vethD will have no effect on vethB.
>>
>> With regard to your example above, why would A corrupt packets?  My guess:
>>
>> 1)  It has bugs (so, fix the bugs, it could equally create incorrect data with proper checksums,
>>      so just enabling checksumming adds no useful protection.)
>
> I agree with Ben here, what he needs is the ability for userspace to be
> trusted when *forwarding* a packet. Ideally you'd only want to receive
> the csum status per packet on the packet socket and pass the same value
> on the vethA interface, with this status being kept when the packet
> reaches vethB.
>
> If A purposely corrupts packet, it's A's problem. It's similar to designing
> a NIC which intentionally corrupts packets and reports "checksum good".
>
> The real issue is that in order to do things right, the userspace bridge
> (here, "A") would really need to pass this status. In Ben's case as he
> says, bad checksum packets are dropped before reaching A, so that
> simplifies the process quite a bit and that might be what causes some
> confusion, but ideally we'd rather have recvmsg() and sendmsg() with
> these flags.
>
> I faced the exact same issue 3 years ago when playing with netmap, it was
> slow as hell because it would lose all checksum information when packets
> were passing through userland, resulting in GRO/GSO etc being disabled,
> and had to modify it to let userland preserve it. That's especially
> important when you have to deal with possibly corrupted packets not yet
> detected in the chain because the NIC did not validate their checksums.
>
> Willy
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
