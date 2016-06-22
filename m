From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 18:22:50 +0000
Message-ID: <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>,<CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	"Hannes Frederic Sowa" <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0130.outbound.protection.outlook.com ([157.56.110.130]:59712
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752542AbcFVSXE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 14:23:04 -0400
In-Reply-To: <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>> This series adds driver support for the processing of tunnel
>>>> [specifically vxlan/geneve/gre tunnels] packets which are
>>>> aggregated [GROed] by the hardware before driver passes
>>>> such packets upto the stack.
>>> First off I am pretty sure this isn't GRO.=A0 This is LRO.
>> Nopes. This is GRO - each MSS-sized frame will arrive on its
>> own frag, whereas the headers [both=A0 internal & external]
>> would arrive on the linear part of the SKB.

> No it is LRO, it just very closely mimics GRO.=A0 If it is in hardwar=
e
> it is LRO.=A0 GRO is extensible in software and bugs can be fixed in
> kernel, LRO is not extensible and any bugs in it are found in hardwar=
e
> or the driver and would have to be fixed there.=A0 It all comes down =
to
> bug isolation.=A0 If we find that disabling LRO makes the bug go away=
 we
> know the hardware aggregation has an issue.=A0 Both features should n=
ot
> operate on the same bit.=A0 Otherwise when some bug is found in your
> implementation it will be blamed on GRO when the bug is actually in
> LRO.
I'm not aware of a definition stating GRO *has* to be extensible in SW;
AFAIK the LRO/GRO distinction revolves around multiple areas [criteria
for aggregation, method of aggregation, etc.].

> I realize this causes some pain when routing or bridging as LRO is
> disabled but that is kind of the point.=A0 We don't want the hardware=
 to
> be mangling frames when we are attempting to route packets between an=
y
> two given devices.
Actually, while I might disagree on whether this is LRO/GRO, I don't th=
ink
there's any problem for us to base this on the LRO feature - I.e., when=
 we
started working on qede we didn't bother implementing LRO as we underst=
ood
it was deprecated, but this encapsulated aggregation is configurable; I=
f it
makes life easier for everyone if we make the configuration based on th=
e LRO
configuration, so that when LRO is disabled we won't have this turned o=
n
it can be easily done.

>>> Also I don't know if you have been paying attention to recent
>>> discussions on the mailing list but the fact is GRO over UDP tunnel=
s
>>> is still a subject for debate.=A0 This patch takes things in the
>>> opposite direction of where we are currently talking about going wi=
th
>>> GRO.=A0 I've added Hannes and Tom to this discussion just to make s=
ure I
>>> have the proper understanding of all this as my protocol knowledge =
is
>>> somewhat lacking.
>> I guess we're on the exact opposite side of the discussion - I.e., w=
e're
>> the vendor that tries pushing offload capabilities to the device.
>> Do notice however that we're not planning on pushing anything new
>> feature-wise, just like we haven't done anything for regular TCP GRO=
 -
>> All we do is allow our HW/FW to aggregate packets instead of stack.

> If you have been following the list then arguably you didn't fully
> understand what has been going on.=A0 I just went through and cleaned=
 up
> all the VXLAN, GENEVE, and VXLAN-GPE mess that we have been creating
> and tried to get this consolidated so that we could start to have
> conversations about this without things being outright rejected.=A0 I
> feel like you guys have just prooven the argument for the other side
> that said as soon as we start support any of it, the vendors were
> going to go nuts and try to stuff everything and the kitchen sink int=
o
> the NICs.=A0 The fact is I am starting to think they were right.
You hurt my feeling; I started going nuts ages ago ;-)
But seriously, this isn't really anything new but rather a step forward=
 in
the direction we've already taken - bnx2x/qede are already performing
the same for non-encapsulated TCP.
And while I understand why you're being suspicious of such an addition,
I don't entirely see how it affects any of that discussion - I already =
yielded
that we can make this configurable, so if any routing decision would be
added that result in packets NOT supposed to be aggregated, the feature
can be turned off [at worst, at the expanse of it not having its benefi=
t
on other connections].

>>> Ideally we need to be able to identify that a given packet terminat=
es
>>> on a local socket in our namespace before we could begin to perform
>>> any sort of mangling on the local packets.=A0 It is always possible=
 that
>>> we could be looking at a frame that uses the same UDP port but is n=
ot
>>> the tunnel protocol if we are performing bridging or routing.=A0 Th=
e
>>> current GRO implementation fails in that regard and there are
>>> discussions between several of us on how to deal with that.=A0 It i=
s
>>> likely that we would be forcing GRO for tunnels to move a bit furth=
er
>>>> up the stack if bridging or routing so that we could verify that t=
he
>>> frame is not being routed back out before we could aggregate it.

>> I'm aware of the on-going discussion, but I'm not sure this should
>> bother us greatly - the aggregation is done based on the
>> inner TCP connection; I.e., it's guaranteed all the frames belong to
>> the same TCP connection. While HW requires the UDP port for the
>> initial classification effort, it doesn't take decision solely on th=
at.

> I realize that UDP port is only one piece of this.=A0 Exactly what
> fields are being taken into account.=A0 That information would be use=
ful
> as we could then go though and determine what the probability is of u=
s
> having a false match between any two packets in a given UDP flow.
While we can surely do that, I think that's really beside the point;
I.e., I don't expect any of you to debug issues arising from a bad HW/F=
W
implementation. But if you REALLY want, I can go and ask for exact
details.

> Also I would still argue this is LRO.=A0 If we are doing routing it
> should be disabled for us to later re-enable if we feel it is safe.
> Having a feature like this enabled by default with GRO is a really ba=
d
> idea.
Which is exactly what happens in qede/bnx2x for regular TCP.
[I understand this area is a much hotter potato at the moment then
simple GRO when we've submitted that content for both drivers;
But I won't mention it again - the sins of the fathers are not excuses
for any wrong-doings today].

>>> Also I would be interested in knowing how your hardware handles
>>> tunnels with outer checksums.=A0 Is it just ignoring the frames in =
such
>>> a case, ignoring the checksum, or is it actually validating the fra=
mes
>>> and then merging the resulting checksum?

>> HW is validating both inner and outer csum; if it wouldn't be able t=
o
>> due to some limitation, it would not try to pass the packet as a GRO
>> aggregation but rather as regular seperated packets.
>> But I don't believe it merges the checksum, only validate each
>> independently [CSUM_UNNECESSARY].

>So it is mangling the packets then.=A0
Obviously - you can't aggregate things without touching them.

> If this were flagged as LRO at
> least if bridging or routing is enabled you won't be mangling the
> frames without the user having to specifically go back through and
> re-enable LRO.

- Alex
  =20=20
