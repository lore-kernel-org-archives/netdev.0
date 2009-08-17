From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce	primary_lazy
 option
Date: Mon, 17 Aug 2009 22:55:13 +0200
Message-ID: <4A89C3B1.3070509@free.fr>
References: <20090813150513.GB10449@psychotron.englab.brq.redhat.com> <4A846C4E.8030509@free.fr> <20090814105938.GE3457@psychotron.englab.brq.redhat.com> <4A859057.3020606@free.fr> <20090817114938.GA3416@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.services.sfr.fr ([93.17.128.13]:53223 "EHLO
	smtp22.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757982AbZHQVIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 17:08:40 -0400
Received: from smtp22.services.sfr.fr (msfrf2223 [10.18.26.37])
	by msfrf2215.sfr.fr (SMTP Server) with ESMTP id E2842700227B
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 22:58:53 +0200 (CEST)
In-Reply-To: <20090817114938.GA3416@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko a =E9crit :
> Fri, Aug 14, 2009 at 06:27:03PM CEST, nicolas.2p.debian@free.fr wrote=
:
>> Jiri Pirko wrote:
>>> Thu, Aug 13, 2009 at 09:41:02PM CEST, nicolas.2p.debian@free.fr wro=
te:
>>>> Jiri Pirko wrote:
>>>>> In some cases there is not desirable to switch back to primary in=
terface when
>>>>> it's link recovers and rather stay wiith currently active one. We=
 need to avoid
>>>>> packetloss as much as we can in some cases. This is solved by int=
roducing
>>>>> primary_lazy option. Note that enslaved primary slave is set as c=
urrent
>>>>> active no matter what.
>>>> May I suggest that instead of creating a new option to better defi=
ne how
>>>> the "primary" option is expected to behave for active-backup mode,=
 we=20
>>>>  try the "weight" slave  option I proposed in the thread "alternat=
ive=20
>>>> to  primary" earlier this year ?
>>>>
>>>> http://sourceforge.net/mailarchive/forum.php?thread_name=3D49D5357=
E.4020201%40free.fr&forum_name=3Dbonding-devel
>>> This link does not work for me :(
>> Nor for me... Sourceforge apparently decided to drop the bonding-dev=
el =20
>> list archive just now. 'hope the list archive will be back soon.
>>
>> Originally, the proposed "weight" option for slaves was designed jus=
t to =20
>> provide a way to better define which slave should become active when=
 the =20
>> active one just went down. As you know, the current "primary" option=
 =20
>> does not allow for a predictable selection of the new active slave w=
hen =20
>> the primary loose connectivity. The new active slave is chosen "at =20
>> random" between the remaining slaves.
>>
>> After a short thread, involving Jay Vosburg and Andy Gospodarek, we =
end =20
>> up with a general configuration interface, that provide a way to tun=
e =20
>> many things in slave management :
>>
>> - Active slave selection in active/backup mode, even in the presence=
 of =20
>> more than two slaves.
>> - Active aggregator selection in 802.3ad mode.
>> - Load balancing tuning for most load balancing modes.
>>
>> The sysfs interface would be /sys/class/net/eth0/bonding/weight. Wri=
ting =20
>> a number there would give a "user supplied weight" to a slave. The s=
peed =20
>> and link state of the slave would give a "natural weight" for the sl=
ave. =20
>> And the "effective weight" would be computed every time one of user =
=20
>> supplied or natural weight change (upon speed or link state changes)=
 and =20
>> would be used everywhere we need a slave weight.
>>
>> I suggest that :
>> - slave's natural weight =3D speed of the slave if link UP, else 0.
>> - slave's effective weight =3D slave's natural weight * slave's user=
 =20
>> supplied weight.
>> - aggregator's effective weight =3D sum of the effective weights of =
the =20
>> slaves inside the aggregator.
>>
>> For the active/backup mode, the exact behavior would be :
>>
>> - When the active slave disappear, the new active slave is the one w=
hose =20
>> effective weight is the highest.
>> - When a slave comes back, it only becomes active if its effective =20
>> weight is strictly higher than the one of the current active slave. =
=20
>> (This stop the flip-flop risk you stated).
>> - To keep the old "primary" option, we simply give a very high user =
=20
>> supplied weight to the primary slave. Jay suggested :
>> #define BOND_PRIMARY_PRIO 0x80000000
>> user_supplied_weight &=3D BOND_PRIMARY_PRIO /* to set the primary */
>> user_supplied_weight &=3D ~BOND_PRIMAY_PRIO  /* to clear the primary=
 */
>>
>> The same apply to aggregator : Every time a slave enter (link UP) or=
 =20
>> leave (link DOWN) an aggregator, the aggregator effective weight is =
=20
>> recomputed. Then, if an aggregator exist with an strictly higher =20
>> effective weight than the current active one, the new best aggregato=
r =20
>> becomes active.
>>
>> For others modes, the weight might be used later to tune the load =20
>> balancing logic in some way.
>>
>> A default value of 1 for slave weight would cause slave speed to be =
used =20
>> alone, hence the "natural weight".
>>
>=20
> I read your text and also the original list thread and I must say I s=
ee no
> solution in this "weight" parameter for this issue. Because it's desi=
red for one
> link to stay active even if second come up, these 2 must have the sam=
e weight.
> But imagine 3 links of the same weight. In that case you cannot insur=
e that the
> "primary one" will be chosen as active (see my picture in the reply t=
o Jay's
> post). Correct me if I'm wrong but for that what I want to fix by pri=
mary_lazy
> option, your proposed weight option has no effect.
>=20
> Therefor I still think the primary_lazy is the only solution now.
>=20
> Jirka

Hi Jirka,

 From your previous posts (first one and reply to Jay), I understand=20
that your want to achieve  the following behavior :

eth0 is primary and active.
eth1 is allowed to be active is eth0 is down.
Also, eth1 should stay active, even if eth0 comes back up.
Switch active to eth0 if eth1 eventually fall down.
Switch active to eth2 only if both eth0 and eth1 are down.

eth0		eth1		eth2
UP(curr)	UP		UP
DOWN		UP(curr)	UP
UP		UP(curr)	UP
UP(curr)	DOWN		UP
DOWN		DOWN		UP(curr)

Using weight, the following setup should give this result :

echo 1000 > /sys/class/net/eth0/bonding/weight
echo 1000 > /sys/class/net/eth1/bonding/weight
echo 1 > /sys/class/net/eth2/bonding/weight
echo eth0 > /sys/class/net/bond0/bonding/active_slave

I hope this is clear now.

	Nicolas.

>=20
>>>> Giving the same "weight" to two different slaves means "chose at r=
andom
>>>> on startup and keep the active one until it fails". And if the "at
>>>> random" behavior is not appropriate, one can force the active slav=
e
>>>> using what Jay suggested  (/sys/class/net/bond0/bonding/active).
>>>>
>>>> The proposed "weight" slave's option is able to prevent the slaves=
 from
>>>> flip-flopping, by stating the fact that two slaves share the same =
 =20
>>>> "primary" level, and may provide several other enhancements as=20
>>>> described  in the thread.
>>>>
>>> Although I cannot reach the thread, this looks interesting. But I'm=
 not sure it
>>> has real benefits over primary_lazy option (and it doesn't solve in=
itial curr
>>> active slave setup)
>> You are right, it doesn't solve the initial active slave selection. =
But =20
>> why would it be so important to properly select the initial active =20
>> slave, if you feel comfortable with staying with a new active slave,=
 =20
>> after a failure and return of the original active slave ? This kind =
of =20
>> failures may last for only a few seconds (just unplugging and pluggi=
ng =20
>> back the wire), and you configuration may then stay with the new act=
ive =20
>> slave "forever". If "forever" is acceptable, may be "at startup" is =
=20
>> acceptable too. :-)
>>
>> From my point of view (and Andy Gospodarek apparently agreed), the r=
eal =20
>> benefits of the weight slave option is that is it more generic and a=
llow =20
>> for later usage in other modes, that we don't anticipate for now.
>>
>> Quoted from a mail from Andy Gospodarek in the original thread :
>>
>> "I really have no objection to that.  Adding this as a base part of
>> bonding for a few modes with known features would be a nice start.
>> I'm sure others will be kind enough to send suggestions or patches f=
or
>> ways this could benefit other modes."
>>
>> 	Nicolas.
>=20


