From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce
	primary_lazy option
Date: Tue, 18 Aug 2009 14:45:51 +0200
Message-ID: <20090818124550.GB3539@psychotron.englab.brq.redhat.com>
References: <20090813150513.GB10449@psychotron.englab.brq.redhat.com> <4A846C4E.8030509@free.fr> <20090814105938.GE3457@psychotron.englab.brq.redhat.com> <4A859057.3020606@free.fr> <20090817114938.GA3416@psychotron.englab.brq.redhat.com> <4A89C3B1.3070509@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56510 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756526AbZHRMqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 08:46:07 -0400
Content-Disposition: inline
In-Reply-To: <4A89C3B1.3070509@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 17, 2009 at 10:55:13PM CEST, nicolas.2p.debian@free.fr wrote:
> Jiri Pirko a =E9crit :
>> Fri, Aug 14, 2009 at 06:27:03PM CEST, nicolas.2p.debian@free.fr wrot=
e:
>>> Jiri Pirko wrote:
>>>> Thu, Aug 13, 2009 at 09:41:02PM CEST, nicolas.2p.debian@free.fr wr=
ote:
>>>>> Jiri Pirko wrote:
>>>>>> In some cases there is not desirable to switch back to primary i=
nterface when
>>>>>> it's link recovers and rather stay wiith currently active one. W=
e need to avoid
>>>>>> packetloss as much as we can in some cases. This is solved by in=
troducing
>>>>>> primary_lazy option. Note that enslaved primary slave is set as =
current
>>>>>> active no matter what.
>>>>> May I suggest that instead of creating a new option to better def=
ine how
>>>>> the "primary" option is expected to behave for active-backup=20
>>>>> mode, we  try the "weight" slave  option I proposed in the thread=
=20
>>>>> "alternative to  primary" earlier this year ?
>>>>>
>>>>> http://sourceforge.net/mailarchive/forum.php?thread_name=3D49D535=
7E.4020201%40free.fr&forum_name=3Dbonding-devel
>>>> This link does not work for me :(
>>> Nor for me... Sourceforge apparently decided to drop the=20
>>> bonding-devel  list archive just now. 'hope the list archive will b=
e=20
>>> back soon.
>>>
>>> Originally, the proposed "weight" option for slaves was designed ju=
st=20
>>> to  provide a way to better define which slave should become active=
=20
>>> when the  active one just went down. As you know, the current=20
>>> "primary" option  does not allow for a predictable selection of the=
=20
>>> new active slave when  the primary loose connectivity. The new acti=
ve=20
>>> slave is chosen "at  random" between the remaining slaves.
>>>
>>> After a short thread, involving Jay Vosburg and Andy Gospodarek, we=
=20
>>> end  up with a general configuration interface, that provide a way =
to=20
>>> tune  many things in slave management :
>>>
>>> - Active slave selection in active/backup mode, even in the presenc=
e=20
>>> of  more than two slaves.
>>> - Active aggregator selection in 802.3ad mode.
>>> - Load balancing tuning for most load balancing modes.
>>>
>>> The sysfs interface would be /sys/class/net/eth0/bonding/weight.=20
>>> Writing  a number there would give a "user supplied weight" to a=20
>>> slave. The speed  and link state of the slave would give a "natural=
=20
>>> weight" for the slave.  And the "effective weight" would be compute=
d=20
>>> every time one of user  supplied or natural weight change (upon spe=
ed=20
>>> or link state changes) and  would be used everywhere we need a slav=
e=20
>>> weight.
>>>
>>> I suggest that :
>>> - slave's natural weight =3D speed of the slave if link UP, else 0.
>>> - slave's effective weight =3D slave's natural weight * slave's use=
r  =20
>>> supplied weight.
>>> - aggregator's effective weight =3D sum of the effective weights of=
 the=20
>>>  slaves inside the aggregator.
>>>
>>> For the active/backup mode, the exact behavior would be :
>>>
>>> - When the active slave disappear, the new active slave is the one=20
>>> whose  effective weight is the highest.
>>> - When a slave comes back, it only becomes active if its effective =
 =20
>>> weight is strictly higher than the one of the current active slave.=
  =20
>>> (This stop the flip-flop risk you stated).
>>> - To keep the old "primary" option, we simply give a very high user=
  =20
>>> supplied weight to the primary slave. Jay suggested :
>>> #define BOND_PRIMARY_PRIO 0x80000000
>>> user_supplied_weight &=3D BOND_PRIMARY_PRIO /* to set the primary *=
/
>>> user_supplied_weight &=3D ~BOND_PRIMAY_PRIO  /* to clear the primar=
y */
>>>
>>> The same apply to aggregator : Every time a slave enter (link UP) o=
r =20
>>> leave (link DOWN) an aggregator, the aggregator effective weight is=
  =20
>>> recomputed. Then, if an aggregator exist with an strictly higher  =20
>>> effective weight than the current active one, the new best aggregat=
or=20
>>>  becomes active.
>>>
>>> For others modes, the weight might be used later to tune the load  =
=20
>>> balancing logic in some way.
>>>
>>> A default value of 1 for slave weight would cause slave speed to be=
=20
>>> used  alone, hence the "natural weight".
>>>
>>
>> I read your text and also the original list thread and I must say I =
see no
>> solution in this "weight" parameter for this issue. Because it's des=
ired for one
>> link to stay active even if second come up, these 2 must have the sa=
me weight.
>> But imagine 3 links of the same weight. In that case you cannot insu=
re that the
>> "primary one" will be chosen as active (see my picture in the reply =
to Jay's
>> post). Correct me if I'm wrong but for that what I want to fix by pr=
imary_lazy
>> option, your proposed weight option has no effect.
>>
>> Therefor I still think the primary_lazy is the only solution now.
>>
>> Jirka
>
> Hi Jirka,
>
> From your previous posts (first one and reply to Jay), I understand t=
hat=20
> your want to achieve  the following behavior :
>
> eth0 is primary and active.
> eth1 is allowed to be active is eth0 is down.
> Also, eth1 should stay active, even if eth0 comes back up.
> Switch active to eth0 if eth1 eventually fall down.
> Switch active to eth2 only if both eth0 and eth1 are down.
>
> eth0		eth1		eth2
> UP(curr)	UP		UP
> DOWN		UP(curr)	UP
> UP		UP(curr)	UP
> UP(curr)	DOWN		UP
> DOWN		DOWN		UP(curr)
>
> Using weight, the following setup should give this result :
>
> echo 1000 > /sys/class/net/eth0/bonding/weight
> echo 1000 > /sys/class/net/eth1/bonding/weight
> echo 1 > /sys/class/net/eth2/bonding/weight
> echo eth0 > /sys/class/net/bond0/bonding/active_slave
>
> I hope this is clear now.

Hmm... I ment the eth1 and eth2 to be the equivalent...
If eth1 is down (let's say for good) and eth0 comes down, eth2 is
selected as current active. But when eth0 comes up then eth0 is selecte=
d. That
is not desired.


>
> 	Nicolas.
>
>>
>>>>> Giving the same "weight" to two different slaves means "chose at =
random
>>>>> on startup and keep the active one until it fails". And if the "a=
t
>>>>> random" behavior is not appropriate, one can force the active sla=
ve
>>>>> using what Jay suggested  (/sys/class/net/bond0/bonding/active).
>>>>>
>>>>> The proposed "weight" slave's option is able to prevent the slave=
s from
>>>>> flip-flopping, by stating the fact that two slaves share the same=
=20
>>>>>   "primary" level, and may provide several other enhancements as =
=20
>>>>> described  in the thread.
>>>>>
>>>> Although I cannot reach the thread, this looks interesting. But I'=
m not sure it
>>>> has real benefits over primary_lazy option (and it doesn't solve i=
nitial curr
>>>> active slave setup)
>>> You are right, it doesn't solve the initial active slave selection.=
=20
>>> But  why would it be so important to properly select the initial=20
>>> active  slave, if you feel comfortable with staying with a new acti=
ve=20
>>> slave,  after a failure and return of the original active slave ?=20
>>> This kind of  failures may last for only a few seconds (just=20
>>> unplugging and plugging  back the wire), and you configuration may=20
>>> then stay with the new active  slave "forever". If "forever" is=20
>>> acceptable, may be "at startup" is  acceptable too. :-)
>>>
>>> From my point of view (and Andy Gospodarek apparently agreed), the=20
>>> real  benefits of the weight slave option is that is it more generi=
c=20
>>> and allow  for later usage in other modes, that we don't anticipate=
=20
>>> for now.
>>>
>>> Quoted from a mail from Andy Gospodarek in the original thread :
>>>
>>> "I really have no objection to that.  Adding this as a base part of
>>> bonding for a few modes with known features would be a nice start.
>>> I'm sure others will be kind enough to send suggestions or patches =
for
>>> ways this could benefit other modes."
>>>
>>> 	Nicolas.
>>
>
>
