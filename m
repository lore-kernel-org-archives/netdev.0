From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 6/8] bonding: move processing of recv handlers
 into handle_frame()
Date: Sun, 06 Mar 2011 15:25:11 +0100
Message-ID: <4D739947.6040603@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64271 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab1CFOZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 09:25:15 -0500
Received: by wyg36 with SMTP id 36so3482236wyg.19
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 06:25:13 -0800 (PST)
In-Reply-To: <20110306133413.GB2795@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/03/2011 14:34, Jiri Pirko a =E9crit :
> Sun, Mar 06, 2011 at 01:24:32PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 05/03/2011 15:50, Nicolas de Peslo=FCan a =E9crit :
>>> Le 05/03/2011 15:43, Jiri Pirko a =E9crit :
>>>> Sat, Mar 05, 2011 at 03:33:30PM CET, nicolas.2p.debian@gmail.com w=
rote:
>>>>> Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
>>>>>> Since now when bonding uses rx_handler, all traffic going into b=
ond
>>>>>> device goes thru bond_handle_frame. So there's no need to go bac=
k into
>>>>>> bonding code later via ptype handlers. This patch converts
>>>>>> original ptype handlers into "bonding receive probes". These fun=
ctions
>>>>>> are called from bond_handle_frame and they are registered per-mo=
de.
>>>>>
>>>>> Does this still support having the arp_ip_target on a vlan?
>>>>>
>>>>> (eth0 ->  bond0 ->  bond0.100, with arp_ip_target only reachable
>>>>> through bond0.100).
>>>>
>>>> This case is still covered with vlan_on_bond_hook
>>>> eth0->
>>>> bond_handle_frame
>>>> bond0->
>>>> vlan_hwaccel_do_receive
>>>> bond0.5->
>>>> vlan_on_bond_hook ->  reinject into bond0
>>>> ->  bond_handle_frame (here it is processed)
>>>
>>> Sound good to me.
>>>
>>> Reviewed-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>>
>> After another review, I think it won't work.
>>
>> vlan_on_bond() will reinject into bond0, but bond_handle_frame() is
>> registered as the rx_handler for the slaves (eth0 in the above
>> setup), not as the rx_handler for the master (bond0 in the above
>> setup). So, bond_handlee_frame() will never see the untagged ARP
>> request/reply and bonding ARP monitoring will fail.
>
> Damn, you are right. I mislooked.

So do I :-D

>> That being said, the current vlan_on_bond_hook() hack already suffer
>> other troubles and for example won't support the following setup:
>>
>> eth0 ->  bond0 ->  br0 ->  br0.100.
>
> blah. Well correct me if my thinking is wrong but I cannot imagine
> a scenario where there's not other way how to do arp monitoring than
> over vlan.

If you are connected to a switch smart enough to allow non tagged deliv=
ery for one vlan and all you=20
arp_ip_targets are reachable through that vlan, then, yes, this hack mi=
ght been useless...

But...

In real life, you may be connected to any kind of switch, including the=
 most stupid one... or you=20
may have trouble explaining to the network team the reason why you need=
 all packets to be tagged=20
expect for one vlan... or simply, some of your arp_ip_targets will be r=
eachable through a router in=20
another vlan.

> So how about to just remove the vlan_on_bond_hook and forbid the
> possibility. IMHO it should have never been introduced in the first
> place.

If it was never introduced, we would have been able to simply forbid it=
, but the feature exist since=20
December 14th 2009, so I'm afraid we must keep it... :-/

And as a more general rule, I think we should support "all possible" in=
terface stacking setups,=20
because this would force us to think generic, instead of adding special=
 hacks for special stacking=20
setups.

>> I think we need to fix this stacking issue in a more general way.
>
> Well this issue is more or less out of the concept and breaks layerin=
g.
> I cannot think of how to resolve this nicely atm.

The only way I can imagine atm is something I described a few days ago:

1/ Add a late_delivery property to packet_type:

	struct packet_type {
	        __be16                  type;   /* This is really htons(ether_=
type). */
	        struct net_device       *dev;   /* NULL is wildcarded here    =
       */
	        int                     (*func) (struct sk_buff *,
	                                         struct net_device *,
	                                         struct packet_type *);
	        struct sk_buff          *(*gso_segment)(struct sk_buff *skb,
	                                                u32 features);
	        int                     (*gso_send_check)(struct sk_buff *skb)=
;
	        struct sk_buff          **(*gro_receive)(struct sk_buff **head=
,
	                                               struct sk_buff *skb);
	        int                     (*gro_complete)(struct sk_buff *skb);
	        void                    *af_packet_priv;
+		bool			late_delivery;
	        struct list_head        list;
	};

2/ Use the late_delivery property inside the ptype_all and ptype_base l=
oops in=20
__netif_receive_skb(), to skip the protocol handlers whose late_deliver=
y property is false, while we=20
walk the rx_handler path.

3/ At the end of __netif_receive_skb(), deliver the final skb to those =
ptype_all and ptype_base=20
handlers whose late_delivery property is true.

4/ And revert back the bonding ARP monitoring to a normal protocol hand=
ler, having late_delivery =3D=3D=20
true.

This would work with eth0 -> bond0 -> bond0.100 and eth0 -> bond0 -> br=
0 -> br0.100.

This would also be reasonably generic, from my point of view. No refere=
nce to vlan, bonding, bridge=20
or whatever...

	Nicolas.
