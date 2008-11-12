From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Wed, 12 Nov 2008 21:56:31 +0100
Message-ID: <491B42FF.3000407@cosmosbay.com>
References: <1226414697.17450.852.camel@ecld0pohly>	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly> <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com> <491B3B49.7070402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Patrick Ohly <patrick.ohly@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andi Kleen <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:52623 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbYKLU4p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 15:56:45 -0500
In-Reply-To: <491B3B49.7070402@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Eric Dumazet wrote:
>> Oliver Hartkopp a =E9crit :
>>> Patrick Ohly wrote:
>>>> On Wed, 2008-11-12 at 16:06 +0000, Andi Kleen wrote:
>>>> =20
>>>>> As a general comment on the patch series I'm still a little scept=
ical
>>>>> the time stamp offset method is a good idea. Since it tries to=20
>>>>> approximate
>>>>> several unsynchronized clocks the result will always be of a litt=
le=20
>>>>> poor
>>>>> quality, which will likely lead to problems sooner or later (or r=
ather
>>>>> require ugly workarounds in the user).
>>>>>
>>>>> I think it would be better to just bite the bullet and add new fi=
elds
>>>>> for this to the skbs. Hardware timestamps are useful enough to ju=
stify
>>>>> this.
>>>>>    =20
>>>>
>>>> I'm all for it, as long as it doesn't keep this feature out of the
>>>> mainline.
>>>>
>>>> At least one additional ktime_t field would be needed for the raw
>>>> hardware time stamp. Transformation to system time (as needed by P=
TP)
>>>> would have to be delayed until the packet is delivered via a socke=
t.=20
>>>> The
>>>> code would be easier (and a bit more accurate) if also another kti=
me_t
>>>> was added to store the transformed value directly after generating=
 it.
>>>>
>>>> An extra field would also solve one of the open problems (tstamp s=
et to
>>>> time stamp when dev_start_xmit_hard is called for IP_MULTICAST_LOO=
P).
>>>>
>>>>  =20
>>>
>>> I really wondered if you posted the series to get an impression why=
=20
>>> adding a new field is a good idea ;-)
>>> Ok, i'm not that experienced on timestamps but i really got confuse=
d=20
>>> reading the patches and it's documentation (even together with the=20
>>> discussion on the ML). I would also vote for having a new field in=20
>>> the skb instead of this current 'bit-compression' approach which=20
>>> smells quite expensive at runtime and in code size. Not talking abo=
ut=20
>>> the mentioned potential locking issues ...
>>
>> New fields in skb are probably the easy way to handle the problem, w=
e
>> all know that.
>>
>> But adding fields on such heavy duty structure for less than 0.001 %=
 of
>> handled frames is disgusting.
>=20
> You have a strange definition of "disgusting".
>=20
> But if that's true that applies to the existing timestamp in there th=
en too
> (and a couple of other fields in there too)
>=20
> Also I suspect that your percent numbers are wrong, depending on the=20
> workload.
>=20
> Personally I think hardware time stamps should replace the existing
> time stamp and I suspect more and more applications will move to that=
=20
> eventually.
>=20

tstamp is the time stamp at the time NIC driver got the frame. Not the =
time
the NIC got the frame from the wire.

In about five years, maybe libpcap is updated to use timespec instead o=
f timeval.

>=20
>> If an application needs skb hw timestamp, get it when reading messag=
e,=20
>> with appropriate
>> API, that calls NIC driver method, giving skb pointer as an argument=
=2E=20
>> NIC driver
>> search in its local table a match of skb pointer (giving the most=20
>> recent match of course),
>> and converts hwtimestamp into "generic application format". No need=20
>> for a fast search, just
>> a linear search in the table, so that feeding it is really easy (may=
be=20
>> lockless)
>=20
> This will probably be a disaster on e.g. high speed network sniffing
> (which is one of the primary use cases of the hardware
> As soon as there is any reordering in the queue (and that is inevitab=
le
> if you scale over multiple CPUs) your linear searches could get quite
> long and bounce cache lines like mad. Also I doubt it can be really
> done lockless.
>=20
> Also to be honest such a complicated and likely badly performing sche=
me=20
> just to save 4-8 bytes
> would match my own definition of "disgusting".
>=20

This scheme only is needed for special devices, used by PTP.

Only *selected* frames really need to gather hwtstamp.

TCP trafic wont use hwtstamp. Most UDP trafic wont use hwstamp.

I threw a "crazy idea", that can be changed if necessary, say with a co=
okie
that identifies the slot in NIC driver structure. O(1) lookup if really=
 needed.

Yes, I find year 2008 not appropriate to enlarge skb with a hwstamp,
but then YMMV



