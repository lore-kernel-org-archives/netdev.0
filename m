From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Wed, 9 Mar 2011 18:11:01 +0100
Message-ID: <20110309171100.GA2842@psychotron.redhat.com>
References: <20110306133413.GB2795@psychotron.redhat.com>
 <20110307125059.GA6053@psychotron.brq.redhat.com>
 <20110307224338.GU11864@gospo.rdu.redhat.com>
 <20110308071350.GA2826@psychotron.redhat.com>
 <20110308134247.GW11864@gospo.rdu.redhat.com>
 <4D76A345.9040200@gmail.com>
 <20110309074547.GA2808@psychotron.redhat.com>
 <4D77938D.3080408@gmail.com>
 <20110309150939.GA9013@psychotron.brq.redhat.com>
 <4D779CA2.1050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047Ab1CIRLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 12:11:44 -0500
Content-Disposition: inline
In-Reply-To: <4D779CA2.1050302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 09, 2011 at 04:28:34PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 09/03/2011 16:09, Jiri Pirko a =E9crit :
>>Wed, Mar 09, 2011 at 03:49:49PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>>>Le 09/03/2011 08:45, Jiri Pirko a =E9crit :
>>>>Tue, Mar 08, 2011 at 10:44:37PM CET, nicolas.2p.debian@gmail.com wr=
ote:
>>>>>Le 08/03/2011 14:42, Andy Gospodarek a =E9crit :
>>>>>>I'm pretty sure this patch will have the same catastrophic proble=
m your
>>>>>>last one did.  By cloning and setting skb2->dev =3D orig_dev you =
just
>>>>>>inserted a frame identical to the one we received right back into=
 the
>>>>>>stack.  It only took a few minutes for my box to melt as one fram=
e on
>>>>>>the wire will cause an infinite number of frames to be received b=
y the
>>>>>>stack.
>>>>>
>>>>>I agree with Andy. We still keep one reinject (netif_rx), which is
>>>>>probably better that two (__netif_receive_skb), but not enough.
>>>>>
>>>>>I really think we need a general framework for late delivery of fi=
nal
>>>>>packets to packet handler registered somewhere in the rx_handler
>>>>>path.
>>>>>
>>>>>Jiri, is this patch the one you announced as "I have some kind nic=
e
>>>>>solution in mind and I'm going to submit that as a patch later (to=
o
>>>>>many patches are in the wind atm)" ?
>>>>
>>>>
>>>>I did not had time to verify my thought yet but I think that the on=
ly
>>>>think needed against my original patch (bonding: move processing of=
 recv
>>>>handlers into handle_frame()) is ro remove vlan_on_bond_hook, perio=
d.
>>>>
>>>>Because all incoming arps are seen by bond_handle_frame =3D>
>>>>bond->recv_probe , even vlan ones - that would make eth0-bond0-bond=
0.5
>>>>work and eth0-bond0-br0-bond0.5 as well. But again, need to verify =
this.
>>>
>>>All incoming ARPs are seen by bond_handle_frame, even vlan ones, def=
initely true.
>>>
>>>But as some of them *are* vlan ones, you will have to untag those "b=
y hand" inside bond_handle_frame.
>>
>
>>Hmm. For hw vlan accel this would not be needed.
>
>Agreed.
>
>>But for non-hw-vlan-accel the frame is wrapped when going thru handle=
_frame. And yes, in that
>>case untagging would be necessary. Unless the vlan untagging happenin=
g now in ptype_base handler
>>is moved in rx path somewhere before __netif_receive_skb.
>
>Can't it me moved not before, but inside __netif_receive_skb, as a rx_=
handler?

I don't think so - rx_handler is not right place to untag. rx_handler i=
s
per device. untaging should happen idealy on realdev skb injection. Tha=
t
way the rx path for hw-vlan-accel and non-he-vlan-accel would be very
similar.

>
>At the time we setup eth0.100, we can arrange for a vlan_untag
>rx_handler to be registered on eth0. This is exactly the way it works
>now for macvlan. Should it be possible (and desirable) for vlan too?
>
>This might re-open the discussion about the need for several
>rx_handlers per interface, but that is another story.
>
>Also, moving it before __netif_receive_skb would cause every protocol
>handlers to receive the frame untagged. At least protocol sniffers
>registered at ptype_all may want to receive the tagged frame, for
>diagnostic purpose.

Thats how its done for hw-vlan-accel. No problem here.

>
>That would result in two things:
>>
>>1) Bond would be able to scope vlan packets
>>2) The rx path for hw-vlan-accel and non-hw-vlan-accel would be the s=
ame
>>    (should be desirable + one reinjection would be avoided for
>>     non-hw-vlan-accel)
>
>Agreed, but moving it inside __netif_receive_skb should have the same
>effects. If we move non-hw-accel-vlan to a rx_handler, the skb would
>be COW before being untagged only if shared. This sounds good to me.
>
>	Nicolas.
