From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?B?ZG9u4oCZdCBtb2RpZnkgaXBf?=
 =?UTF-8?B?c3VtbWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3M=?=
 =?UTF-8?B?dW1zIGFzIGdvb2Qu?=
Date: Sat, 30 Apr 2016 15:43:51 -0700
Message-ID: <57253527.7010009@candelatech.com>
References: <lsq.1461711744.699003961@decadent.org.uk> <5720E1F0.9010203@candelatech.com> <1461780469.5102.0.camel@decadent.org.uk> <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com> <572155F4.10405@candelatech.com> <20160428102953.GA7656@bistromath.localdomain> <1462041181.17662.3.camel@decadent.org.uk> <57250A17.5090804@candelatech.com> <CALx6S36cqecPH+Zd8pGVdFHRi7bmWgAwm2UgFVprt5JOuO47UA@mail.gmail.com> <57251CB3.1040504@candelatech.com> <CAKUBDd-_5RouHduHvjOqgOpyAArEBd80BEy4KBDPLRQoTtWb2Q@mail.gmail.com> <572523C4.4080307@candelatech.com> <CAKUBDd8fksttZOW3T5zdKD4rzbcZzZer-DCMMsA2zKF4A_hXQw@mail.gmail.com> <57252918.7070302@candelatech.com> <CAKUBDd8S2=YcJ5wtM24D6-vw+bMud=Om9TBykMvSYcJ4X5tryw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKUBDd8S2=YcJ5wtM24D6-vw+bMud=Om9TBykMvSYcJ4X5tryw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/30/2016 03:01 PM, Vijay Pandurangan wrote:
> On Sat, Apr 30, 2016 at 5:52 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>
>>> Good point, so if you had:
>>>
>>> eth0 <-> raw <-> user space-bridge <-> raw <-> vethA <-> veth B <->
>>> userspace-stub <->eth1
>>>
>>> and user-space hub enabled this elide flag, things would work, right?
>>> Then, it seems like what we need is a way to tell the kernel
>>> router/bridge logic to follow elide signals in packets coming from
>>> veth. I'm not sure what the best way to do this is because I'm less
>>> familiar with conventions in that part of the kernel, but assuming
>>> there's a way to do this, would it be acceptable?
>>
>>
>> You cannot receive on one veth without transmitting on the other, so
>> I think the elide csum logic can go on the raw-socket, and apply to packets
>> in the transmit-from-user-space direction.  Just allowing the socket to make
>> the veth behave like it used to before this patch in question should be good
>> enough, since that worked for us for years.  So, just an option to modify
>> the
>> ip_summed for pkts sent on a socket is probably sufficient.
>
> I don't think this is right. Consider:
>
> - App A  sends out corrupt packets 50% of the time and discards inbound data.
> - App B doesn't care about corrupt packets and is happy to receive
> them and has some way of dealing with them (special case)
> - App C is a regular app, say nc or something.
>
> In your world, where A decides what happens to data it transmits,
> then
> A<--veth-->B and A<---wire-->B will have the same behaviour
>
> but
>
> A<-- veth --> C and A<-- wire --> C will have _different_ behaviour: C
> will behave incorrectly if it's connected over veth but correctly if
> connected with a wire. That is a bug.
>
> Since A cannot know what the app it's talking to will desire, I argue
> that both sides of a message must be opted in to this optimization.

How can you make a generic app C know how to do this?  The path could be,
for instance:

eth0 <-> user-space-A <-> vethA <-> vethB <-> { kernel routing logic } <-> vethC <-> vethD <-> appC

There are no sockets on vethB, but it does need to have special behaviour to elide
csums.  Even if appC is hacked to know how to twiddle some thing on it's veth port,
mucking with vethD will have no effect on vethB.

With regard to your example above, why would A corrupt packets?  My guess:

1)  It has bugs (so, fix the bugs, it could equally create incorrect data with proper checksums,
     so just enabling checksumming adds no useful protection.)

2)  It means to corrupt frames.  In that case, someone must expect that C should receive incorrect
     frames, otherwise why bother making App-A corrupt them in the first place?

3)  You are explicitly trying to test the kernel checksum logic, so you want the kernel to
     detect the bad checksum and throw away the packet.  In this case, just don't set the socket
     option in appA to elide checksums and the packet will be thrown away.

Any other cases you can think of?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
