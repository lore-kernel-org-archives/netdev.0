From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 6/8] bonding: move processing of recv
 handlers into handle_frame()
Date: Sun, 6 Mar 2011 17:32:55 +0100
Message-ID: <AANLkTi=Gt_ArqOVPJjnrAExO8Fihu8WzUhYSb_O6URQ_@mail.gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
	<1299320969-7951-7-git-send-email-jpirko@redhat.com>
	<4D7249BA.8030401@gmail.com>
	<20110305144314.GC8573@psychotron.redhat.com>
	<4D724DB4.9020207@gmail.com>
	<4D737D00.20406@gmail.com>
	<20110306133413.GB2795@psychotron.redhat.com>
	<4D739947.6040603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:40532 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab1CFQc4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 11:32:56 -0500
Received: by qyk7 with SMTP id 7so1407695qyk.19
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 08:32:55 -0800 (PST)
In-Reply-To: <4D739947.6040603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/6 Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>:
> Le 06/03/2011 14:34, Jiri Pirko a =E9crit :
>> Sun, Mar 06, 2011 at 01:24:32PM CET, nicolas.2p.debian@gmail.com wro=
te:
[...]
>>> That being said, the current vlan_on_bond_hook() hack already suffe=
r
>>> other troubles and for example won't support the following setup:
>>>
>>> eth0 -> =A0bond0 -> =A0br0 -> =A0br0.100.
>>
>> blah. Well correct me if my thinking is wrong but I cannot imagine
>> a scenario where there's not other way how to do arp monitoring than
>> over vlan.
>
> If you are connected to a switch smart enough to allow non tagged del=
ivery
> for one vlan and all you arp_ip_targets are reachable through that vl=
an,
> then, yes, this hack might been useless...
>
> But...
>
> In real life, you may be connected to any kind of switch, including t=
he most
> stupid one... or you may have trouble explaining to the network team =
the
> reason why you need all packets to be tagged expect for one vlan... o=
r
> simply, some of your arp_ip_targets will be reachable through a route=
r in
> another vlan.
>
>> So how about to just remove the vlan_on_bond_hook and forbid the
>> possibility. IMHO it should have never been introduced in the first
>> place.
>
> If it was never introduced, we would have been able to simply forbid =
it, but
> the feature exist since December 14th 2009, so I'm afraid we must kee=
p it...
> :-/
>
> And as a more general rule, I think we should support "all possible"
> interface stacking setups, because this would force us to think gener=
ic,
> instead of adding special hacks for special stacking setups.
>
>>> I think we need to fix this stacking issue in a more general way.
>>
>> Well this issue is more or less out of the concept and breaks layeri=
ng.
>> I cannot think of how to resolve this nicely atm.
>
> The only way I can imagine atm is something I described a few days ag=
o:
>
> 1/ Add a late_delivery property to packet_type:
>
> =A0 =A0 =A0 =A0struct packet_type {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__be16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0type; =A0 /* This is really
> htons(ether_type). */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct net_device =A0 =A0 =A0 *dev; =A0=
 /* NULL is wildcarded here
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (*func) (struct sk_buff *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct net_device *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct packet_type *);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff =A0 =A0 =A0 =A0 =A0*(*g=
so_segment)(struct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 features);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (*gso_send_check)(struct sk_buff
> *skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff =A0 =A0 =A0 =A0 =A0**(*=
gro_receive)(struct sk_buff
> **head,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (*gro_complete)(struct sk_buff *skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0*af_packet_priv;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0late_delivery;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0list;
> =A0 =A0 =A0 =A0};
>
> 2/ Use the late_delivery property inside the ptype_all and ptype_base=
 loops
> in __netif_receive_skb(), to skip the protocol handlers whose late_de=
livery
> property is false, while we walk the rx_handler path.
>
> 3/ At the end of __netif_receive_skb(), deliver the final skb to thos=
e
> ptype_all and ptype_base handlers whose late_delivery property is tru=
e.
>
> 4/ And revert back the bonding ARP monitoring to a normal protocol ha=
ndler,
> having late_delivery =3D=3D true.
>
> This would work with eth0 -> bond0 -> bond0.100 and eth0 -> bond0 -> =
br0 ->
> br0.100.
>
> This would also be reasonably generic, from my point of view. No refe=
rence
> to vlan, bonding, bridge or whatever...

Is there a particular reason why this ARP monitoring can't be done in
userspace (e.g. on AF_PACKET with suitable filter)? Marking slaves
up/down as their link goes in that direction is easy, but as more and
more link-state detecting methods/algorithms get added this is
becoming more of a mess.

Best Regards,
Micha=B3 Miros=B3aw
