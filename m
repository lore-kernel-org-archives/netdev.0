From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Wed, 12 Nov 2008 21:23:37 +0100
Message-ID: <491B3B49.7070402@linux.intel.com>
References: <1226414697.17450.852.camel@ecld0pohly>	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly> <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com>
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
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31160 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbYKLUX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 15:23:26 -0500
In-Reply-To: <491B2D03.1090700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Oliver Hartkopp a =E9crit :
>> Patrick Ohly wrote:
>>> On Wed, 2008-11-12 at 16:06 +0000, Andi Kleen wrote:
>>> =20
>>>> As a general comment on the patch series I'm still a little scepti=
cal
>>>> the time stamp offset method is a good idea. Since it tries to=20
>>>> approximate
>>>> several unsynchronized clocks the result will always be of a littl=
e=20
>>>> poor
>>>> quality, which will likely lead to problems sooner or later (or ra=
ther
>>>> require ugly workarounds in the user).
>>>>
>>>> I think it would be better to just bite the bullet and add new fie=
lds
>>>> for this to the skbs. Hardware timestamps are useful enough to jus=
tify
>>>> this.
>>>>    =20
>>>
>>> I'm all for it, as long as it doesn't keep this feature out of the
>>> mainline.
>>>
>>> At least one additional ktime_t field would be needed for the raw
>>> hardware time stamp. Transformation to system time (as needed by PT=
P)
>>> would have to be delayed until the packet is delivered via a socket=
=2E The
>>> code would be easier (and a bit more accurate) if also another ktim=
e_t
>>> was added to store the transformed value directly after generating =
it.
>>>
>>> An extra field would also solve one of the open problems (tstamp se=
t to
>>> time stamp when dev_start_xmit_hard is called for IP_MULTICAST_LOOP=
).
>>>
>>>  =20
>>
>> I really wondered if you posted the series to get an impression why=20
>> adding a new field is a good idea ;-)
>> Ok, i'm not that experienced on timestamps but i really got confused=
=20
>> reading the patches and it's documentation (even together with the=20
>> discussion on the ML). I would also vote for having a new field in t=
he=20
>> skb instead of this current 'bit-compression' approach which smells=20
>> quite expensive at runtime and in code size. Not talking about the=20
>> mentioned potential locking issues ...
>=20
> New fields in skb are probably the easy way to handle the problem, we
> all know that.
>=20
> But adding fields on such heavy duty structure for less than 0.001 % =
of
> handled frames is disgusting.

You have a strange definition of "disgusting".

But if that's true that applies to the existing timestamp in there then=
 too
(and a couple of other fields in there too)

Also I suspect that your percent numbers are wrong, depending on the wo=
rkload.

Personally I think hardware time stamps should replace the existing
time stamp and I suspect more and more applications will move to that e=
ventually.


> If an application needs skb hw timestamp, get it when reading message=
,=20
> with appropriate
> API, that calls NIC driver method, giving skb pointer as an argument.=
=20
> NIC driver
> search in its local table a match of skb pointer (giving the most rec=
ent=20
> match of course),
> and converts hwtimestamp into "generic application format". No need f=
or=20
> a fast search, just
> a linear search in the table, so that feeding it is really easy (mayb=
e=20
> lockless)

This will probably be a disaster on e.g. high speed network sniffing
(which is one of the primary use cases of the hardware
As soon as there is any reordering in the queue (and that is inevitable
if you scale over multiple CPUs) your linear searches could get quite
long and bounce cache lines like mad. Also I doubt it can be really
done lockless.

Also to be honest such a complicated and likely badly performing scheme=
 just to save 4-8 bytes
would match my own definition of "disgusting".

-Andi
