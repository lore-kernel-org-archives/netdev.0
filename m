From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 02:00:46 -0700
Message-ID: <m1y61x94g1.fsf@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>
	<4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org>
	<4DD9F81D.6070806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33969 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab1EWJA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 05:00:58 -0400
In-Reply-To: <4DD9F81D.6070806@candelatech.com> (Ben Greear's message of "Sun,
	22 May 2011 23:01:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> On 05/22/2011 03:38 PM, Eric W. Biederman wrote:
>> Ben Greear<greearb@candelatech.com>  writes:
>>
>>> On 05/22/2011 12:39 PM, Eric W. Biederman wrote:
>>>>
>>>> Simplify the vlan handling code by not supporing clearing of
>>>> VLAN_FLAG_REORDER_HDR.  Which means we always make the vlan handling
>>>> code strip the vlan header from the packets, and always insert the vlan
>>>> header when transmitting packets.
>>>>
>>>> Not stripping the vlan header has alwasy been broken in combination with
>>>> vlan hardware accelleration.  Now that we are making everything look
>>>> like accelerated vlan handling not stripping the vlan header is always
>>>> broken.
>>>>
>>>> I don't think anyone actually cares so simply stop supporting the broken
>>>> case.
>>>
>>> I've lost track of the VLAN code a bit.  Is there any documentation
>>> somewhere about what happens in these various cases:
>>
>> Other than the code I don't know about documentation.
>
> These cases are tricky and probably have changed over
> the years.  It would be nice to have it written down
> somewhere, even if just in comments somewhere in the
> VLAN code.
>
>>
>>> *  Open a raw packet socket on eth0.
>> I assume you mean a pf_packet socket.
>
> Yes.
>
>>>    *  Do we get tagged VLAN packets?  (I'd expect yes.)
>> yes.
>>
>>>    *  If we sent a tagged VLAN packet, it's sent without modification?  (I'd expect yes.)
>>>    **  Without "yes" to the two above, one cannot do user-space bridging properly.
>>
>> This is sort of.  If you set the PACKET_AUXDATA option and use recv_cmsg
>> you get the priority and the vlan identifier in the auxdata.
>>
>> I think that is a pretty horrible answer myself but it has been that way
>> since sometime mid 2008.  So I'm not immediately prepared to call it
>> a regression, or a bug.
>
> I believe we have been getting tagged VLAN packets properly
> in our test cases.  We would not be creating any VLAN devices
> in this case, so perhaps the NIC isn't doing any stripping.
>
> To me, it seems like we should get the fully tagged packet
> without having to go muck with aux-data, though it would
> be fine if it were *also* in aux-data.

Given that pf_packet is a portable interface that works on multiple OS's
I tend to agree.  Certainly my users would be happier if they don't
have to change their code and not having to change tcpdump would
also be nice.

I'm not certain exactly where in the code it makes sense to put the
vlan header back on for pf_packet sockets.  The simplest thing would
be just before we run the socket filter.  If we don't do the simplest
thing this raises the question how do we avoid breaking socket filters
that look at the packet data and know there is going to be a vlan
header there.

Still the current situation is better than seeing vlan 0 tagged packets
twice.

My gut feel says if we can cheaply get the socket filters to act like it
sees the vlan tag (where the vlan tag belongs) we should not actually
put the vlan tag back on until we copy the packet to userspace.

Having the perspective of someone who cares whose hardware supports the
vlan tagging optimizations would be nice to have.

> I'll try to test this again this coming week to make sure
> it's working like I think it is.

Thanks.


Eric
