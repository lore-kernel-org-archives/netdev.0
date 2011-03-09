From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Wed, 09 Mar 2011 23:18:41 +0100
Message-ID: <4D77FCC1.5050904@gmail.com>
References: <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307224338.GU11864@gospo.rdu.redhat.com> <20110308071350.GA2826@psychotron.redhat.com> <20110308134247.GW11864@gospo.rdu.redhat.com> <4D76A345.9040200@gmail.com> <20110309074547.GA2808@psychotron.redhat.com> <4D77938D.3080408@gmail.com> <20110309150939.GA9013@psychotron.brq.redhat.com> <4D779CA2.1050302@gmail.com> <20110309171100.GA2842@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51883 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295Ab1CIWSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 17:18:46 -0500
Received: by wya21 with SMTP id 21so923386wya.19
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 14:18:44 -0800 (PST)
In-Reply-To: <20110309171100.GA2842@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/03/2011 18:11, Jiri Pirko a =E9crit :
> Wed, Mar 09, 2011 at 04:28:34PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 09/03/2011 16:09, Jiri Pirko a =E9crit :
>>> Wed, Mar 09, 2011 at 03:49:49PM CET, nicolas.2p.debian@gmail.com wr=
ote:
>>>> Le 09/03/2011 08:45, Jiri Pirko a =E9crit :
>>>>> Tue, Mar 08, 2011 at 10:44:37PM CET, nicolas.2p.debian@gmail.com =
wrote:
>>>>>> Le 08/03/2011 14:42, Andy Gospodarek a =E9crit :
>>>>>>> I'm pretty sure this patch will have the same catastrophic prob=
lem your
>>>>>>> last one did.  By cloning and setting skb2->dev =3D orig_dev yo=
u just
>>>>>>> inserted a frame identical to the one we received right back in=
to the
>>>>>>> stack.  It only took a few minutes for my box to melt as one fr=
ame on
>>>>>>> the wire will cause an infinite number of frames to be received=
 by the
>>>>>>> stack.
>>>>>>
>>>>>> I agree with Andy. We still keep one reinject (netif_rx), which =
is
>>>>>> probably better that two (__netif_receive_skb), but not enough.
>>>>>>
>>>>>> I really think we need a general framework for late delivery of =
final
>>>>>> packets to packet handler registered somewhere in the rx_handler
>>>>>> path.
>>>>>>
>>>>>> Jiri, is this patch the one you announced as "I have some kind n=
ice
>>>>>> solution in mind and I'm going to submit that as a patch later (=
too
>>>>>> many patches are in the wind atm)" ?
>>>>>
>>>>>
>>>>> I did not had time to verify my thought yet but I think that the =
only
>>>>> think needed against my original patch (bonding: move processing =
of recv
>>>>> handlers into handle_frame()) is ro remove vlan_on_bond_hook, per=
iod.
>>>>>
>>>>> Because all incoming arps are seen by bond_handle_frame =3D>
>>>>> bond->recv_probe , even vlan ones - that would make eth0-bond0-bo=
nd0.5
>>>>> work and eth0-bond0-br0-bond0.5 as well. But again, need to verif=
y this.
>>>>
>>>> All incoming ARPs are seen by bond_handle_frame, even vlan ones, d=
efinitely true.
>>>>
>>>> But as some of them *are* vlan ones, you will have to untag those =
"by hand" inside bond_handle_frame.
>>>
>>
>>> Hmm. For hw vlan accel this would not be needed.
>>
>> Agreed.
>>
>>> But for non-hw-vlan-accel the frame is wrapped when going thru hand=
le_frame. And yes, in that
>>> case untagging would be necessary. Unless the vlan untagging happen=
ing now in ptype_base handler
>>> is moved in rx path somewhere before __netif_receive_skb.
>>
>> Can't it me moved not before, but inside __netif_receive_skb, as a r=
x_handler?
>
> I don't think so - rx_handler is not right place to untag. rx_handler=
 is
> per device. untaging should happen idealy on realdev skb injection. T=
hat
> way the rx path for hw-vlan-accel and non-he-vlan-accel would be very
> similar.

I don't understand your argument about "rx_handler is per device". A vl=
an interface is by design=20
built on top a parent (physical or logical) interface. Why can't we use=
 the rx_handler of the parent=20
device to untag?

Untagging the frame very early (before __netif_receive_skb() would work=
 if the value of skb->dev, at=20
the time the frame enter __netif_receive_skb, is the parent interface f=
or the vlan interface: eth0=20
-> eth0.100. This is exactly what happens for hw-accel vlan frame and i=
t sounds logical at first to=20
do it the same way for non-hw-accel device.

But for all others setups, where there exist some net_devices before th=
e "untagging" one, you would=20
face some troubles. For example, with eth0+eth1 -> br0 -> br0.100, you =
cannot untag before entering=20
__netif_receive_skb. If you do so, the bridge would receive untagged fr=
ame and if the frame is not=20
for the local host, the bridge would forward an untagged frame while it=
 is expected to forward a=20
tagged one. Even if the bridge is in a position to know the frame *was*=
 tagged, we cannot expect the=20
bridge to do special processing to handle this situation. Doing so woul=
d break layering.

On another setup, eth0 -> eth0.100 -> br0 -> eth1.200 -> eth1, on the o=
pposite, we expect the bridge=20
to receive and to forward an untagged frame, that has been untagged whi=
le crossing eth0.100 and will=20
be tagged while crossing eth1.200.

If we want to avoid reinjection as much as possible (and I advocate for=
 that, you know :-)), then=20
the only place to untag is in the rx_header for the parent device of th=
e vlan device. I still don't=20
understand the problem you see with this proposal.

And the only remaining discrepancy would be in hw-accel vs non-hw-accel=
=2E A protocol handler=20
registered on eth0 -> eth0.100 would receive:
- a tagged frame for non-hw-accel.
- an untagged frame for hw-accel.

I think it is already true today, so I don't consider this a problem. W=
e might arrange to fix this=20
discrepancy later, if someone consider this a problem.

	Nicolas.

>> At the time we setup eth0.100, we can arrange for a vlan_untag
>> rx_handler to be registered on eth0. This is exactly the way it work=
s
>> now for macvlan. Should it be possible (and desirable) for vlan too?
>>
>> This might re-open the discussion about the need for several
>> rx_handlers per interface, but that is another story.
>>
>> Also, moving it before __netif_receive_skb would cause every protoco=
l
>> handlers to receive the frame untagged. At least protocol sniffers
>> registered at ptype_all may want to receive the tagged frame, for
>> diagnostic purpose.
>
> Thats how its done for hw-vlan-accel. No problem here.
>
>>
>> That would result in two things:
>>>
>>> 1) Bond would be able to scope vlan packets
>>> 2) The rx path for hw-vlan-accel and non-hw-vlan-accel would be the=
 same
>>>     (should be desirable + one reinjection would be avoided for
>>>      non-hw-vlan-accel)
>>
>> Agreed, but moving it inside __netif_receive_skb should have the sam=
e
>> effects. If we move non-hw-accel-vlan to a rx_handler, the skb would
>> be COW before being untagged only if shared. This sounds good to me.
>>
>> 	Nicolas.
>

