From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's source
 MAC
Date: Wed, 02 Mar 2011 00:08:22 +0100
Message-ID: <4D6D7C66.6050205@gmail.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com> <9882.1298958366@death> <20110301181624.GM11864@gospo.rdu.redhat.com> <4D6D658C.90300@gmail.com> <20893.1299018331@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jiri Pirko <jpirko@redhat.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39299 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab1CAXIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:08:25 -0500
Received: by wyg36 with SMTP id 36so5224535wyg.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 15:08:24 -0800 (PST)
In-Reply-To: <20893.1299018331@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/03/2011 23:25, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 01/03/2011 19:16, Andy Gospodarek a =C3=A9crit :
>>
>> [snip]
>>
>>> Knowing that I'm using an unmanaged switch with balance-rr probably
>>> helps understand how this is happening.  I'll clarify this however,=
 so
>>> we are all on the same page.
>>>
>>> In my situation, eth2 and eth3 are in bond0.  When bond0 transmits =
the
>>> NS, let's say it goes out eth3.  Since it is a multicast frame my s=
witch
>>> will broadcast this to all ports and eth2 will receive the frame wi=
th
>>> the source MAC address being the same as bond0's MAC address.  This
>>> frame is passed up the stack to the ipv6 layer and appears to be a
>>> response to the NS from another host and is dropped.
>>
>> 'sounds perfectly normal.
>>
>> This problem is described in detail in chapter 5.4.3 and appendix A =
of
>> RFC4862 "IPv6 Stateless Address Autoconfiguration".
>>
>> As this is clearly IPv6 related, it sounds normal from my point of v=
iew to
>> fix it at the ndisc_recv_ns() level.
>
> 	Andy's immediate problem is IPv6 related, but the issue itself
> is generic: how to deal with broadcast / multicasts arriving at a -rr=
 or
> -xor bond, because we do not and cannot know if the switch is going t=
o
> flood to the slaves or not.  There may be other instances wherein tha=
t
> bonus copy of some packet confuses things.

Agreed, even if the only known instances that currently expose the prob=
lem is IPv6.

Anyway, let's try and fix it at the bonding level...

> 	My view is that -rr and -xor are intended to interoperate with
> Etherchannel.  Yes, they will often work tolerably well when connecte=
d
> to a non-Etherchannel switch.  But, if the host and the switch are no=
t
> in agreement on the link aggregation status of the ports, some level =
of
> misbehavior is expected.  If that misbehavior can be corrected withou=
t
> adversely affecting a properly configured host and switch, then I don=
't
> see much problem with fixing it.
>
> 	For the IPv6 case here, I think there's a problem with any fix,
> and that is that there's no way for bonding to know if the switch por=
ts
> are configured properly or not.  I'm using "properly" to mean that th=
e
> switch ports corresponding to the bonding slaves are configured into =
an
> Etherchannel-type channel group.
>
> 	If the switch ports are grouped, then if IPv6 sees one of these
> messages coming in, it's actually a duplicate detection.  This becaus=
e
> the switch won't loop the broadcast / multicast back around to a memb=
er
> of the channel group.
>
> 	If the switch ports are not grouped, then the switch will
> happily send broadcasts and multicasts to all ports of the bond, beca=
use
> it doesn't know about the aggregation.  In this case, I suspect there=
's
> no way to reliably determine if the incoming packet is a switch artif=
act
> or an actual duplicate detection.  Anybody know for sure if this is t=
he
> case?
>
> 	For the generic case, I'm not seeing a way to distinguish actual
> repeated packets from switch artifact duplicate packets without addin=
g
> another knob to bonding to tell it if the switch does etherchannel or
> not (which I'm not in favor of doing).

I originally thought about such knob and agree with you that we should =
avoid adding one more...

>> Quoting the RFC:
>>
>>   "In those cases where the hardware cannot suppress loopbacks, howe=
ver,
>>    one possible software heuristic to filter out unwanted loopbacks =
is
>>    to discard any received packet whose link-layer source address is=
 the
>>    same as the receiving interface's.  There is even a link-layer
>>    specification that requires that any such packets be discarded
>>    [IEEE802.11].  Unfortunately, use of that criteria also results i=
n
>>    the discarding of all packets sent by another node using the same
>>    link-layer address.  Duplicate Address Detection will fail on
>>    interfaces that filter received packets in this manner:
>>
>>    [snip]
>>
>>    Thus, to perform Duplicate Address Detection correctly in the cas=
e
>>    where two interfaces are using the same link-layer address, an
>>    implementation must have a good understanding of the interface's
>>    multicast loopback semantics, and the interface cannot discard
>>    received packets simply because the source link-layer address is =
the
>>    same as the interface's."
>>
>> So, simply dropping frames whose source MAC =3D=3D local MAC is appa=
rently not the right solution.
>
> 	I tend to agree here, because this would break DAD for properly
> configured (meaning etherchannel on the switch ports) installations.
>
> 	Is there a way to fix bonding and/or ndisc_recv_ns to work
> correctly for both cases (have/don't have etherchannel on the switch)=
?

Can we imagine that, at the time we change the bonding mode to -rr or -=
xor, we simply brodcast or=20
multicast one or two frames with some random data and wait to see wheth=
er we receive the frame back?=20
If we receive at least one frame with the same random data, in one of t=
he slaves interface for this=20
bonding, we know for sure the switch configuration is not "multicast lo=
op safe". Bonding already=20
send ARP requests/replies in many situations. Adding one broadcast/mult=
icast frame at bond setup=20
time is probably acceptable.

And to ensure consistent results, we need to send such broadcast/multic=
ast every time the link goes=20
up for an already enslaved slave. This is not perfect, as the switch to=
pology may change in a way=20
that won't be detected by bonding, but still cause a new multicast loop=
, but...

Knowing the switch configuration is not "multicast loop safe", we can, =
at a minimum, issue a=20
warning, telling the user she should expect strange behaviors, like fal=
se duplicate address detection.

And we can probably use this information into the should-drop logic, fo=
r mode that lack "inactive"=20
slaves.

	Nicolas.
