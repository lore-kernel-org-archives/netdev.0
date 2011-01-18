From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Mon, 17 Jan 2011 19:16:29 -0800
Message-ID: <4D35060D.5080004@intel.com>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oleg V. Ukhno" <olegu@yandex-team.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14550 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459Ab1ARDQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 22:16:30 -0500
In-Reply-To: <26330.1295049912@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/2011 4:05 PM, Jay Vosburgh wrote:
> Oleg V. Ukhno <olegu@yandex-team.ru> wrote:
>> Jay Vosburgh wrote:
>>
>>> 	This is a violation of the 802.3ad (now 802.1ax) standard, 5.2.1
>>> (f), which requires that all frames of a given "conversation" are p=
assed
>>> to a single port.
>>>
>>> 	The existing layer3+4 hash has a similar problem (that it may
>>> send packets from a conversation to multiple ports), but for that c=
ase
>>> it's an unlikely exception (only in the case of IP fragmentation), =
but
>>> here it's the norm.  At a minimum, this must be clearly documented.
>>>
>>> 	Also, what does a round robin in 802.3ad provide that the
>>> existing round robin does not?  My presumption is that you're looki=
ng to
>>> get the aggregator autoconfiguration that 802.3ad provides, but you
>>> don't say.
>=20
> 	I'm still curious about this question.  Given the rather
> intricate setup of your particular network (described below), I'm not
> sure why 802.3ad is of benefit over traditional etherchannel
> (balance-rr / balance-xor).
>=20
>>> 	I don't necessarily think this is a bad cheat (round robining on
>>> 802.3ad as an explicit non-standard extension), since everybody wan=
ts to
>>> stripe their traffic across multiple slaves.  I've given some thoug=
ht to
>>> making round robin into just another hash mode, but this also does =
some
>>> magic to the MAC addresses of the outgoing frames (more on that bel=
ow).
>> Yes, I am resetting MAC addresses when transmitting packets to have =
switch
>> to put packets into different ports of the receiving etherchannel.
>=20
> 	By "etherchannel" do you really mean "Cisco switch with a
> port-channel group using LACP"?
>=20
>> I am using this patch to provide full-mesh ISCSI connectivity betwee=
n at
>> least 4 hosts (all hosts of course are in same ethernet segment) and=
 every
>> host is connected with aggregate link with 4 slaves(usually).
>> Using round-robin I provide near-equal load striping when transmitti=
ng,
>> using MAC address magic I force switch to stripe packets over all sl=
ave
>> links in destination port-channel(when number of rx-ing slaves is eq=
ual to
>> number ot tx-ing slaves and is even).
>=20
> 	By "MAC address magic" do you mean that you're assigning
> specifically chosen MAC addresses to the slaves so that the switch's
> hash is essentially "assigning" the bonding slaves to particular port=
s
> on the outgoing port-channel group?
>=20
> 	Assuming that this is the case, it's an interesting idea, but
> I'm unconvinced that it's better on 802.3ad vs. balance-rr.  Unless I=
'm
> missing something, you can get everything you need from an option to
> have balance-rr / balance-xor utilize the slave's permanent address a=
s
> the source address for outgoing traffic.
>=20
>> [...] So I am able to utilize all slaves
>> for tx and for rx up to maximum capacity; besides I am getting L2 li=
nk
>> failure detection (and load rebalancing), which is (in my opinion) m=
uch
>> faster and robust than L3 or than dm-multipath provides.
>> It's my idea with the patch
>=20
> 	Can somebody (John?) more knowledgable than I about dm-multipath
> comment on the above?

Here I'll give it a go.

I don't think detecting L2 link failure this way is very robust. If the=
re
is a failure farther away then your immediate link your going to break
completely? Your bonding hash will continue to round robin the iscsi
packets and half them will get dropped on the floor. dm-multipath handl=
es
this reasonably gracefully. Also in this bonding environment you seem t=
o
be very sensitive to RTT times on the network. Maybe not bad out right =
but
I wouldn't consider this robust either.

You could tweak your scsi timeout values and fail_fast values, set the =
io
retry to 0 to cause the fail over to occur faster. I suspect you alread=
y
did this and still it is too slow? Maybe adding a checker in multipathd=
 to
listen for link events would be fast enough. The checker could then fai=
l
the path immediately.

I'll try to address your comments from the other thread here. In genera=
l I
wonder if it would be better to solve the problems in dm-multipath rath=
er than
add another bonding mode?

OVU - it is slow(I am using ISCSI for Oracle , so I need to minimize la=
tency)

The dm-multipath layer is adding latency? How much? If this is really t=
rue
maybe its best to the address the real issue here and not avoid it by
using the bonding layer.

OVU - it handles any link failures bad, because of it's command queue=20
limitation(all queued commands above 32 are discarded in case of path=20
failure, as I remember)

Maybe true but only link failures with the immediate peer are handled
with a bonding strategy. By working at the block layer we can detect
failures throughout the path. I would need to look into this again I
know when we were looking at this sometime ago there was some talk abou=
t
improving this behavior. I need to take some time to go back through th=
e
error recovery stuff to remember how this works.

OVU - it performs very bad when there are many devices and ma=D1=82y pa=
ths(I was=20
unable to utilize more that 2Gbps of 4 even with 100 disks with 4 paths=
=20
per each disk)

Hmm well that seems like something is broken. I'll try this setup when
I get some time next few days. This really shouldn't be the case dm-mul=
tipath
should not add a bunch of extra latency or effect throughput significan=
tly.
By the way what are you seeing without mpio?

Thanks,
John
