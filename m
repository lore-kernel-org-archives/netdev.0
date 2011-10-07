From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address from others
Date: Thu, 06 Oct 2011 17:59:53 -0700
Message-ID: <7122.1317949193@death>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com> <20111006110047.GA22462@hmsreliant.think-freely.org> <27199.1317927933@death> <CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com> <CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Yinglin Sun <Yinglin.Sun@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:33586 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758360Ab1JGBAB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 21:00:01 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 6 Oct 2011 19:00:00 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p970xvdk118872
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 18:59:57 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p970xt3q022233
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 18:59:57 -0600
In-reply-to: <CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yinglin Sun <Yinglin.Sun@emc.com> wrote:

>On Thu, Oct 6, 2011 at 3:17 PM, Yinglin Sun <Yinglin.Sun@emc.com> wrot=
e:
>>
>> On Thu, Oct 6, 2011 at 12:05 PM, Jay Vosburgh <fubar@us.ibm.com> wro=
te:
>> >
>> > Neil Horman <nhorman@tuxdriver.com> wrote:
>> >
>> > >On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote:
>> > >> Steps to reproduce this issue:
>> > >> 1. create bond0 over eth0 and eth1, set the mode to balance-xor
>> > >> 2. add an IPv6 address to bond0
>> > >> 3. DAD packet is sent out from one slave and then is looped bac=
k from
>> > >> the other slave. Therefore, it is treated as a duplicate addres=
s and
>> > >> stays tentative afterwards:
>> > >> =C2=A0 =C2=A0kern.info:
>> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0Oct =C2=A05 11:50:18 testvm1 kernel:=
 [ =C2=A0129.224353] bond0: IPv6 duplicate address 1234::1 detected!

[...]

>> > >Nack, This seems like it will just completely break DAD. =C2=A0Wh=
at if theres another
>> > >system out there with the same mac address. =C2=A0A response from=
 that system would
>> > >get dropped by this filter, instead of causing The local system t=
o stop using
>> > >the address. =C2=A0What you really want to do is modify
>> > >bond_should_deliver_exact_match to detect this frame on the inact=
ive slave or
>> > >some such, and drop the frame there.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Also NACK; and adding a bit of informat=
ion. =C2=A0The balance-xor
>> > mode is nominally expecting to interact with a switch whose ports =
are
>> > set for etherchannel ("static link aggregation"), in which case th=
e
>> > switch will not loop the packet back around.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0If your switch can do etherchannel, the=
n enable it and the
>> > problem should go away. =C2=A0If your switch cannot do this, then =
you may
>> > have other issues, because all of the multicast or broadcast packe=
ts
>> > going out any bonding slave will loop around to another slave. =C2=
=A0You
>> > could also use 802.3ad / LACP if you switch supports that.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0For balance-xor (or balance-rr, for tha=
t matter) mode to a
>> > non-etherchannel switch, it's going to be difficult, if not imposs=
ible,
>> > to modify bond_should_deliver_exact_match, because there are no in=
active
>> > slaves. =C2=A0In this mode, bonding is expecting the switch to bal=
ance
>> > incoming traffic across the ports, and not deliver looped back pac=
kets
>> > or duplicates. =C2=A0There are no restrictions on what type of tra=
ffic
>> > (mcast, bcast, ucast) may arrive on any given port.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0I can't think of a way to make the non-=
etherchannel case work
>> > for balance-xor (or balance-rr) without breaking the DAD functiona=
lity
>> > in the case of an actual duplicate. =C2=A0I'm not aware of a way t=
o
>> > distinguish a looped back DAD probe from an actual duplicate addre=
ss
>> > probe elsewhere on the network.
>> >
>>
>> Hi Neil & Jay,
>>
>> Thanks a lot for the comments.
>>
>> The use case is to add IPv6 address on the bonding interface first,
>> and then set up port channel on switch. We'll hit this issue and the
>> new address will stay tentative and unusable after port channel is s=
et
>> up on switch. This patch is for this valid use case.
>>
>> Except failover mode, all slaves are active on receiving packets, so
>> we are receiving such looped back DAD and the bonding driver cannot
>> ignore them. I cannot think of a way to distinguish if a DAD is loop=
ed
>> back or from someone else having the same mac address. They look the
>> same to the host. If there is another machine having the same mac
>> address, this code path gets executed if both are doing DAD at the
>> same time for the same IPv6 address. Maybe we should find out what t=
he
>> specification defines for this case?
>>
>
>RFC4862 has a discussion about this issue:
>http://tools.ietf.org/html/rfc4862#appendix-A
>The better solution could be to record the number of DAD sent out. If
>we received more DAD packets than we sent out, there is someone else
>on the network who has the same mac address and sent DAD for the same
>IPv6 address. However, this solution doesn't work with bonding
>interface, since all other active slaves but the one sending out DAD
>will receive packet looped back. It doesn't seem there is a simple
>solution for this issue.

	Why are you setting up the port channel after configuring the
bond?

	As a possible workaround, if you have control over the setup
process (perhaps it's some sort of manual process), adding one slave to
the bond, leaving the other soon-to-be slaves down, then setting up the
switch, and finally adding the remaining slaves should work around the
issue, since if the bond has only one slave it won't see any looped
packets.

	Or you could bring the bond up as active-backup, then change the
mode to balance-xor once the switch is configured.

	Ultimately, though, the problem stems from the settings mismatch
between the switch and the bonding system; balance-xor is meant to
interoperate with etherchannel, and when the switch is not configured
properly, correct behavior is difficult to guarantee.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
