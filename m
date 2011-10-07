From: Yinglin Sun <yinglin.s@gmail.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Thu, 6 Oct 2011 18:24:36 -0700
Message-ID: <CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
	<20111006110047.GA22462@hmsreliant.think-freely.org>
	<27199.1317927933@death>
	<CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com>
	<CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
	<7122.1317949193@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43924 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908Ab1JGBYi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 21:24:38 -0400
Received: by bkbzt4 with SMTP id zt4so4199103bkb.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 18:24:37 -0700 (PDT)
In-Reply-To: <7122.1317949193@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2011 at 5:59 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Yinglin Sun <Yinglin.Sun@emc.com> wrote:
>
>>On Thu, Oct 6, 2011 at 3:17 PM, Yinglin Sun <Yinglin.Sun@emc.com> wro=
te:
>>>
>>> On Thu, Oct 6, 2011 at 12:05 PM, Jay Vosburgh <fubar@us.ibm.com> wr=
ote:
>>> >
>>> > Neil Horman <nhorman@tuxdriver.com> wrote:
>>> >
>>> > >On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote:
>>> > >> Steps to reproduce this issue:
>>> > >> 1. create bond0 over eth0 and eth1, set the mode to balance-xo=
r
>>> > >> 2. add an IPv6 address to bond0
>>> > >> 3. DAD packet is sent out from one slave and then is looped ba=
ck from
>>> > >> the other slave. Therefore, it is treated as a duplicate addre=
ss and
>>> > >> stays tentative afterwards:
>>> > >> =C2=A0 =C2=A0kern.info:
>>> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0Oct =C2=A05 11:50:18 testvm1 kernel=
: [ =C2=A0129.224353] bond0: IPv6 duplicate address 1234::1 detected!
>
> [...]
>
>>> > >Nack, This seems like it will just completely break DAD. =C2=A0W=
hat if theres another
>>> > >system out there with the same mac address. =C2=A0A response fro=
m that system would
>>> > >get dropped by this filter, instead of causing The local system =
to stop using
>>> > >the address. =C2=A0What you really want to do is modify
>>> > >bond_should_deliver_exact_match to detect this frame on the inac=
tive slave or
>>> > >some such, and drop the frame there.
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Also NACK; and adding a bit of informa=
tion. =C2=A0The balance-xor
>>> > mode is nominally expecting to interact with a switch whose ports=
 are
>>> > set for etherchannel ("static link aggregation"), in which case t=
he
>>> > switch will not loop the packet back around.
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0If your switch can do etherchannel, th=
en enable it and the
>>> > problem should go away. =C2=A0If your switch cannot do this, then=
 you may
>>> > have other issues, because all of the multicast or broadcast pack=
ets
>>> > going out any bonding slave will loop around to another slave. =C2=
=A0You
>>> > could also use 802.3ad / LACP if you switch supports that.
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0For balance-xor (or balance-rr, for th=
at matter) mode to a
>>> > non-etherchannel switch, it's going to be difficult, if not impos=
sible,
>>> > to modify bond_should_deliver_exact_match, because there are no i=
nactive
>>> > slaves. =C2=A0In this mode, bonding is expecting the switch to ba=
lance
>>> > incoming traffic across the ports, and not deliver looped back pa=
ckets
>>> > or duplicates. =C2=A0There are no restrictions on what type of tr=
affic
>>> > (mcast, bcast, ucast) may arrive on any given port.
>>> >
>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0I can't think of a way to make the non=
-etherchannel case work
>>> > for balance-xor (or balance-rr) without breaking the DAD function=
ality
>>> > in the case of an actual duplicate. =C2=A0I'm not aware of a way =
to
>>> > distinguish a looped back DAD probe from an actual duplicate addr=
ess
>>> > probe elsewhere on the network.
>>> >
>>>
>>> Hi Neil & Jay,
>>>
>>> Thanks a lot for the comments.
>>>
>>> The use case is to add IPv6 address on the bonding interface first,
>>> and then set up port channel on switch. We'll hit this issue and th=
e
>>> new address will stay tentative and unusable after port channel is =
set
>>> up on switch. This patch is for this valid use case.
>>>
>>> Except failover mode, all slaves are active on receiving packets, s=
o
>>> we are receiving such looped back DAD and the bonding driver cannot
>>> ignore them. I cannot think of a way to distinguish if a DAD is loo=
ped
>>> back or from someone else having the same mac address. They look th=
e
>>> same to the host. If there is another machine having the same mac
>>> address, this code path gets executed if both are doing DAD at the
>>> same time for the same IPv6 address. Maybe we should find out what =
the
>>> specification defines for this case?
>>>
>>
>>RFC4862 has a discussion about this issue:
>>http://tools.ietf.org/html/rfc4862#appendix-A
>>The better solution could be to record the number of DAD sent out. If
>>we received more DAD packets than we sent out, there is someone else
>>on the network who has the same mac address and sent DAD for the same
>>IPv6 address. However, this solution doesn't work with bonding
>>interface, since all other active slaves but the one sending out DAD
>>will receive packet looped back. It doesn't seem there is a simple
>>solution for this issue.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Why are you setting up the port channel af=
ter configuring the
> bond?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0As a possible workaround, if you have cont=
rol over the setup
> process (perhaps it's some sort of manual process), adding one slave =
to
> the bond, leaving the other soon-to-be slaves down, then setting up t=
he
> switch, and finally adding the remaining slaves should work around th=
e
> issue, since if the bond has only one slave it won't see any looped
> packets.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Or you could bring the bond up as active-b=
ackup, then change the
> mode to balance-xor once the switch is configured.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Ultimately, though, the problem stems from=
 the settings mismatch
> between the switch and the bonding system; balance-xor is meant to
> interoperate with etherchannel, and when the switch is not configured
> properly, correct behavior is difficult to guarantee.
>

Jay,

Thanks a lot for the suggestion.

It's mainly about usability. We would like to provide customers with
consistent IPv6 configuration procedures as IPv4.  Such workarounds
could be confusing and generate customer calls.

Yinglin
