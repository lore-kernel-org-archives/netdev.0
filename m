From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH_3=2E2_085=2F115=5D_veth=3A_don=E2=80=99t_modify_ip=5Fsumm?=
	=?UTF-8?Q?ed=3B_doing_so_treats_packets_with_bad_checksums_as_good=2E?=
Date: Sat, 30 Apr 2016 18:01:29 -0400
Message-ID: <CAKUBDd8S2=YcJ5wtM24D6-vw+bMud=Om9TBykMvSYcJ4X5tryw@mail.gmail.com>
References: <lsq.1461711744.699003961@decadent.org.uk> <5720E1F0.9010203@candelatech.com>
 <1461780469.5102.0.camel@decadent.org.uk> <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>
 <572155F4.10405@candelatech.com> <20160428102953.GA7656@bistromath.localdomain>
 <1462041181.17662.3.camel@decadent.org.uk> <57250A17.5090804@candelatech.com>
 <CALx6S36cqecPH+Zd8pGVdFHRi7bmWgAwm2UgFVprt5JOuO47UA@mail.gmail.com>
 <57251CB3.1040504@candelatech.com> <CAKUBDd-_5RouHduHvjOqgOpyAArEBd80BEy4KBDPLRQoTtWb2Q@mail.gmail.com>
 <572523C4.4080307@candelatech.com> <CAKUBDd8fksttZOW3T5zdKD4rzbcZzZer-DCMMsA2zKF4A_hXQw@mail.gmail.com>
 <57252918.7070302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57252918.7070302@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 30, 2016 at 5:52 PM, Ben Greear <greearb@candelatech.com> wrote:
>>
>> Good point, so if you had:
>>
>> eth0 <-> raw <-> user space-bridge <-> raw <-> vethA <-> veth B <->
>> userspace-stub <->eth1
>>
>> and user-space hub enabled this elide flag, things would work, right?
>> Then, it seems like what we need is a way to tell the kernel
>> router/bridge logic to follow elide signals in packets coming from
>> veth. I'm not sure what the best way to do this is because I'm less
>> familiar with conventions in that part of the kernel, but assuming
>> there's a way to do this, would it be acceptable?
>
>
> You cannot receive on one veth without transmitting on the other, so
> I think the elide csum logic can go on the raw-socket, and apply to packets
> in the transmit-from-user-space direction.  Just allowing the socket to make
> the veth behave like it used to before this patch in question should be good
> enough, since that worked for us for years.  So, just an option to modify
> the
> ip_summed for pkts sent on a socket is probably sufficient.

I don't think this is right. Consider:

- App A  sends out corrupt packets 50% of the time and discards inbound data.
- App B doesn't care about corrupt packets and is happy to receive
them and has some way of dealing with them (special case)
- App C is a regular app, say nc or something.

In your world, where A decides what happens to data it transmits,
then
A<--veth-->B and A<---wire-->B will have the same behaviour

but

A<-- veth --> C and A<-- wire --> C will have _different_ behaviour: C
will behave incorrectly if it's connected over veth but correctly if
connected with a wire. That is a bug.

Since A cannot know what the app it's talking to will desire, I argue
that both sides of a message must be opted in to this optimization.






>
>>> There may be no sockets on the vethB port.  And reader/writer is not
>>> a good way to look at it since I am implementing a bi-directional bridge
>>> in
>>> user-space and each packet-socket is for both rx and tx.
>>
>>
>> Sure, but we could model a bidrectional connection as two
>> unidirectional sockets for our discussions here, right?
>
>
> Best not to I think, you want to make sure that one socket can
> correctly handle tx and rx.  As long as that works, then using
> uni-directional sockets should work too.
>
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
