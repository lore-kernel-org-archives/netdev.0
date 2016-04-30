From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH_3=2E2_085=2F115=5D_veth=3A_don=E2=80=99t_modify_ip=5Fsumm?=
	=?UTF-8?Q?ed=3B_doing_so_treats_packets_with_bad_checksums_as_good=2E?=
Date: Sat, 30 Apr 2016 16:15:35 -0400
Message-ID: <CAKUBDd-WaKfdpBYumGuZG0MHmK6BZX9WxCOX7G3aiaPwQu7MuQ@mail.gmail.com>
References: <lsq.1461711744.699003961@decadent.org.uk> <5720E1F0.9010203@candelatech.com>
 <1461780469.5102.0.camel@decadent.org.uk> <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>
 <572155F4.10405@candelatech.com> <20160428102953.GA7656@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20160428102953.GA7656@bistromath.localdomain>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[oops =E2=80=93 resending this because I was using gmail in HTML mode b=
efore
by accident]

There was a discussion on a separate thread about this. I agree with
Sabrina fully. I believe veth should provide an abstraction layer that
correctly emulates a physical network in all ways.

Consider an environment where we have multiple physical computers.
Each computer runs one or more containers, each of which has a
publicly routable ip address.  When adding a new app to the cluster, a
scheduler might decide to run this container on any physical machine
of its choice, assuming that apps have a way of routing traffic to
their backends (we did something similar Google >10 years ago). This
is something we might imagine happening with docker and ipv6 for
instance.

If you have an app, A, which sends raw ethernet frames (the simplest
case I could imagine) with TCP data that has invalid checksums to app
B, which is receiving it, the behaviour of the system _will be
different_ depending upon whether app B is scheduled to run on the
same machine as app A or not. This seems like a clear bug and a broken
abstraction (especially as the default case), and something we should
endeavour to avoid.

I do see Ben's point about enabling sw checksum verification as
potentially incurring a huge performance penalty (I haven't had a
chance to measure it) that is completely wasteful in the vast majority
of cases.

Unfortunately I just don't see how we can solve this problem in a way
that preserves a correct abstraction layer while also avoiding excess
work. I guess the first piece of data that would be helpful is to
determine just how big of a performance penalty this is. If it's
small, then maybe it doesn't matter.




On Thu, Apr 28, 2016 at 6:29 AM, Sabrina Dubroca <sd@queasysnail.net> w=
rote:
> Hello,
>
> 2016-04-27, 17:14:44 -0700, Ben Greear wrote:
>> On 04/27/2016 05:00 PM, Hannes Frederic Sowa wrote:
>> > Hi Ben,
>> >
>> > On Wed, Apr 27, 2016, at 20:07, Ben Hutchings wrote:
>> > > On Wed, 2016-04-27 at 08:59 -0700, Ben Greear wrote:
>> > > > On 04/26/2016 04:02 PM, Ben Hutchings wrote:
>> > > > >
>> > > > > 3.2.80-rc1 review patch.  If anyone has any objections, plea=
se let me know.
>> > > > I would be careful about this.  It causes regressions when sen=
ding
>> > > > PACKET_SOCKET buffers from user-space to veth devices.
>> > > >
>> > > > There was a proposed upstream fix for the regression, but it h=
as not gone
>> > > > into the tree as far as I know.
>> > > >
>> > > > http://www.spinics.net/lists/netdev/msg370436.html
>> > > [...]
>> > >
>> > > OK, I'll drop this for now.
>> >
>> > The fall out from not having this patch is in my opinion a bigger
>> > fallout than not having this patch. This patch fixes silent data
>> > corruption vs. the problem Ben Greear is talking about, which migh=
t not
>> > be that a common usage.
>> >
>> > What do others think?
>> >
>> > Bye,
>> > Hannes
>> >
>>
>> This patch from Cong Wang seems to fix the regression for me, I thin=
k it should be added and
>> tested in the main tree, and then apply them to stable as a pair.
>>
>> http://dmz2.candelatech.com/?p=3Dlinux-4.4.dev.y/.git;a=3Dcommitdiff=
;h=3D8153e983c0e5eba1aafe1fc296248ed2a553f1ac;hp=3D454b07405d694dad52e7=
f41af5816eed0190da8a
>
> Actually, no, this is not really a regression.
>
> If you capture packets on a device with checksum offloading enabled,
> the TCP/UDP checksum isn't filled.  veth also behaves that way.  What
> the "veth: don't modify ip_summed" patch does is enable proper
> checksum validation on veth.  This really was a bug in veth.
>
> Cong's patch would also break cases where we choose to inject packets
> with invalid checksums, and they would now be accepted as correct.
>
> Your use case is invalid, it just happened to work because of a
> bug.  If you want the stack to fill checksums so that you want captur=
e
> and reinject packets, you have to disable checksum offloading (or
> compute the checksum yourself in userspace).
>
> Thanks.
>
> --
> Sabrina
