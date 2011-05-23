From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 13:24:12 -0700
Message-ID: <4DDAC26C.2070601@candelatech.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>	<20110412.141645.112604563.davem@davemloft.net>	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>	<20110521072925.GA2588@jirka.orion>	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>	<4DD7BB61.9050200@gmail.com>	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>	<m17h9jp7js.fsf@fess.ebiederm.org>	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>	<4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org>	<4DD9F81D.6070806@candelatech.com> <m1y61x94g1.fsf@fess.ebiederm.org> <4DDA8C42.3090009@candelatech.com> <4DDAB72B.9050101@gmail.com>
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
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34009 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab1EWUYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 16:24:55 -0400
In-Reply-To: <4DDAB72B.9050101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2011 12:36 PM, Nicolas de Peslo=FCan wrote:
> Le 23/05/2011 18:33, Ben Greear a =E9crit :
>> On 05/23/2011 02:00 AM, Eric W. Biederman wrote:
>>> Ben Greear<greearb@candelatech.com> writes:
>>>
>>>> I believe we have been getting tagged VLAN packets properly
>>>> in our test cases. We would not be creating any VLAN devices
>>>> in this case, so perhaps the NIC isn't doing any stripping.
>>>>
>>>> To me, it seems like we should get the fully tagged packet
>>>> without having to go muck with aux-data, though it would
>>>> be fine if it were *also* in aux-data.
>>>
>>> Given that pf_packet is a portable interface that works on multiple=
 OS's
>>> I tend to agree. Certainly my users would be happier if they don't
>>> have to change their code and not having to change tcpdump would
>>> also be nice.
>>>
>>> I'm not certain exactly where in the code it makes sense to put the
>>> vlan header back on for pf_packet sockets. The simplest thing would
>>> be just before we run the socket filter. If we don't do the simples=
t
>>> thing this raises the question how do we avoid breaking socket filt=
ers
>>> that look at the packet data and know there is going to be a vlan
>>> header there.
>>
>> That is going to be tricky, since the VLAN header would adjust
>> offsets and users could be using some filter that uses offsets
>> with no actual mention of VLANs (but expecting it to take
>> the VLAN header into account).
>>
>>> Still the current situation is better than seeing vlan 0 tagged pac=
kets
>>> twice.
>>>
>>> My gut feel says if we can cheaply get the socket filters to act li=
ke it
>>> sees the vlan tag (where the vlan tag belongs) we should not actual=
ly
>>> put the vlan tag back on until we copy the packet to userspace.
>>
>> Maybe keep a count of how many sockets with filters and/or pf_packet
>> sockets are open, and how many things are registered in
>> the 'ptype_all' chain, and only re-add (or never remove) the header =
if
>> that is > 0?
>>
>> (And, let the bridging and other kernel logic deal with vlans
>> via auxillary methods as well as checking in-line headers.)
>
> Well, this doesn't sound very different from my previous proposal: if=
 a
> protocol handler is registered at parent interface level, can't we
> simply assume this protocol handler expect the raw packet?

Well, yes..unless perhaps when the REORDER_HDR flag is enabled.

As for when the tag is added/removed, as long as we don't end up doing
a remove and then an add (in software), and as long as the pkt is corre=
ct
going to user-space, it doesn't matter to me.

It would be lame to remove it in software and then re-add it,
unless absolutely required for some reason.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

