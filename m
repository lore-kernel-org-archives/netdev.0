From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 21:36:11 +0200
Message-ID: <4DDAB72B.9050101@gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>	<20110412.141645.112604563.davem@davemloft.net>	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>	<20110521072925.GA2588@jirka.orion>	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>	<4DD7BB61.9050200@gmail.com>	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>	<m17h9jp7js.fsf@fess.ebiederm.org>	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>	<4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org>	<4DD9F81D.6070806@candelatech.com> <m1y61x94g1.fsf@fess.ebiederm.org> <4DDA8C42.3090009@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47099 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756494Ab1EWTgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 15:36:14 -0400
Received: by wya21 with SMTP id 21so4464452wya.19
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 12:36:13 -0700 (PDT)
In-Reply-To: <4DDA8C42.3090009@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/05/2011 18:33, Ben Greear a =E9crit :
> On 05/23/2011 02:00 AM, Eric W. Biederman wrote:
>> Ben Greear<greearb@candelatech.com> writes:
>>
>>> I believe we have been getting tagged VLAN packets properly
>>> in our test cases. We would not be creating any VLAN devices
>>> in this case, so perhaps the NIC isn't doing any stripping.
>>>
>>> To me, it seems like we should get the fully tagged packet
>>> without having to go muck with aux-data, though it would
>>> be fine if it were *also* in aux-data.
>>
>> Given that pf_packet is a portable interface that works on multiple =
OS's
>> I tend to agree. Certainly my users would be happier if they don't
>> have to change their code and not having to change tcpdump would
>> also be nice.
>>
>> I'm not certain exactly where in the code it makes sense to put the
>> vlan header back on for pf_packet sockets. The simplest thing would
>> be just before we run the socket filter. If we don't do the simplest
>> thing this raises the question how do we avoid breaking socket filte=
rs
>> that look at the packet data and know there is going to be a vlan
>> header there.
>
> That is going to be tricky, since the VLAN header would adjust
> offsets and users could be using some filter that uses offsets
> with no actual mention of VLANs (but expecting it to take
> the VLAN header into account).
>
>> Still the current situation is better than seeing vlan 0 tagged pack=
ets
>> twice.
>>
>> My gut feel says if we can cheaply get the socket filters to act lik=
e it
>> sees the vlan tag (where the vlan tag belongs) we should not actuall=
y
>> put the vlan tag back on until we copy the packet to userspace.
>
> Maybe keep a count of how many sockets with filters and/or pf_packet
> sockets are open, and how many things are registered in
> the 'ptype_all' chain, and only re-add (or never remove) the header i=
f that is > 0?
>
> (And, let the bridging and other kernel logic deal with vlans
> via auxillary methods as well as checking in-line headers.)

Well, this doesn't sound very different from my previous proposal: if a=
 protocol handler is=20
registered at parent interface level, can't we simply assume this proto=
col handler expect the raw=20
packet?

Also, I think the main problem is that ptype_all and ptype_base deliver=
ies are different in=20
__netif_receive_skb, for no good reason (at least, to my knowledge).

In http://patchwork.ozlabs.org/patch/85578/, I proposed to process prot=
ocol handlers that are=20
registered on a particular interface inside the loop, then process prot=
ocol handlers registered to=20
NULL upon exit from the loop.

That way, we would have the opportunity to deliver different skb (tagge=
d/untagged) to different=20
level of interface, while we cross the interface stack.

I know there is a possible performance penalty in this implementation, =
but this can be fixed by=20
properly ordering the ptype_all/ptype_base list.

	Nicolas.
