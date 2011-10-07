From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Fri, 7 Oct 2011 15:09:49 -0400
Message-ID: <20111007190949.GE11408@hmsreliant.think-freely.org>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
 <20111006110047.GA22462@hmsreliant.think-freely.org>
 <27199.1317927933@death>
 <CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com>
 <CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
 <7122.1317949193@death>
 <CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
 <20111007111028.GA11408@hmsreliant.think-freely.org>
 <CAN17JHUZLWmDQF8P6eCbLkTanYjwi0YmF5dXkfvH_QCRnbtaMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Yinglin Sun <yinglin.s@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58779 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947Ab1JGTKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 15:10:16 -0400
Content-Disposition: inline
In-Reply-To: <CAN17JHUZLWmDQF8P6eCbLkTanYjwi0YmF5dXkfvH_QCRnbtaMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 11:08:49AM -0700, Yinglin Sun wrote:
> On Fri, Oct 7, 2011 at 4:10 AM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> > On Thu, Oct 06, 2011 at 06:24:36PM -0700, Yinglin Sun wrote:
> >> On Thu, Oct 6, 2011 at 5:59 PM, Jay Vosburgh <fubar@us.ibm.com> wr=
ote:
> >> > Yinglin Sun <Yinglin.Sun@emc.com> wrote:
> >> >
> >> >>On Thu, Oct 6, 2011 at 3:17 PM, Yinglin Sun <Yinglin.Sun@emc.com=
> wrote:
> >> >>>
> >> >>> On Thu, Oct 6, 2011 at 12:05 PM, Jay Vosburgh <fubar@us.ibm.co=
m> wrote:
> >> >>> >
> >> >>> > Neil Horman <nhorman@tuxdriver.com> wrote:
> >> >>> >
> >> >>> > >On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote=
:
> >> >>> > >> Steps to reproduce this issue:
> >> >>> > >> 1. create bond0 over eth0 and eth1, set the mode to balan=
ce-xor
> >> >>> > >> 2. add an IPv6 address to bond0
> >> >>> > >> 3. DAD packet is sent out from one slave and then is loop=
ed back from
> >> >>> > >> the other slave. Therefore, it is treated as a duplicate =
address and
> >> >>> > >> stays tentative afterwards:
> >> >>> > >> =A0 =A0kern.info:
> >> >>> > >> =A0 =A0 =A0 =A0Oct =A05 11:50:18 testvm1 kernel: [ =A0129=
=2E224353] bond0: IPv6 duplicate address 1234::1 detected!
> >> >
> >> > [...]
> >> >
> >> >>> > >Nack, This seems like it will just completely break DAD. =A0=
What if theres another
> >> >>> > >system out there with the same mac address. =A0A response f=
rom that system would
> >> >>> > >get dropped by this filter, instead of causing The local sy=
stem to stop using
> >> >>> > >the address. =A0What you really want to do is modify
> >> >>> > >bond_should_deliver_exact_match to detect this frame on the=
 inactive slave or
> >> >>> > >some such, and drop the frame there.
> >> >>> >
> >> >>> > =A0 =A0 =A0 =A0Also NACK; and adding a bit of information. =A0=
The balance-xor
> >> >>> > mode is nominally expecting to interact with a switch whose =
ports are
> >> >>> > set for etherchannel ("static link aggregation"), in which c=
ase the
> >> >>> > switch will not loop the packet back around.
> >> >>> >
> >> >>> > =A0 =A0 =A0 =A0If your switch can do etherchannel, then enab=
le it and the
> >> >>> > problem should go away. =A0If your switch cannot do this, th=
en you may
> >> >>> > have other issues, because all of the multicast or broadcast=
 packets
> >> >>> > going out any bonding slave will loop around to another slav=
e. =A0You
> >> >>> > could also use 802.3ad / LACP if you switch supports that.
> >> >>> >
> >> >>> > =A0 =A0 =A0 =A0For balance-xor (or balance-rr, for that matt=
er) mode to a
> >> >>> > non-etherchannel switch, it's going to be difficult, if not =
impossible,
> >> >>> > to modify bond_should_deliver_exact_match, because there are=
 no inactive
> >> >>> > slaves. =A0In this mode, bonding is expecting the switch to =
balance
> >> >>> > incoming traffic across the ports, and not deliver looped ba=
ck packets
> >> >>> > or duplicates. =A0There are no restrictions on what type of =
traffic
> >> >>> > (mcast, bcast, ucast) may arrive on any given port.
> >> >>> >
> >> >>> > =A0 =A0 =A0 =A0I can't think of a way to make the non-etherc=
hannel case work
> >> >>> > for balance-xor (or balance-rr) without breaking the DAD fun=
ctionality
> >> >>> > in the case of an actual duplicate. =A0I'm not aware of a wa=
y to
> >> >>> > distinguish a looped back DAD probe from an actual duplicate=
 address
> >> >>> > probe elsewhere on the network.
> >> >>> >
> >> >>>
> >> >>> Hi Neil & Jay,
> >> >>>
> >> >>> Thanks a lot for the comments.
> >> >>>
> >> >>> The use case is to add IPv6 address on the bonding interface f=
irst,
> >> >>> and then set up port channel on switch. We'll hit this issue a=
nd the
> >> >>> new address will stay tentative and unusable after port channe=
l is set
> >> >>> up on switch. This patch is for this valid use case.
> >> >>>
> >> >>> Except failover mode, all slaves are active on receiving packe=
ts, so
> >> >>> we are receiving such looped back DAD and the bonding driver c=
annot
> >> >>> ignore them. I cannot think of a way to distinguish if a DAD i=
s looped
> >> >>> back or from someone else having the same mac address. They lo=
ok the
> >> >>> same to the host. If there is another machine having the same =
mac
> >> >>> address, this code path gets executed if both are doing DAD at=
 the
> >> >>> same time for the same IPv6 address. Maybe we should find out =
what the
> >> >>> specification defines for this case?
> >> >>>
> >> >>
> >> >>RFC4862 has a discussion about this issue:
> >> >>http://tools.ietf.org/html/rfc4862#appendix-A
> >> >>The better solution could be to record the number of DAD sent ou=
t. If
> >> >>we received more DAD packets than we sent out, there is someone =
else
> >> >>on the network who has the same mac address and sent DAD for the=
 same
> >> >>IPv6 address. However, this solution doesn't work with bonding
> >> >>interface, since all other active slaves but the one sending out=
 DAD
> >> >>will receive packet looped back. It doesn't seem there is a simp=
le
> >> >>solution for this issue.
> >> >
> >> > =A0 =A0 =A0 =A0Why are you setting up the port channel after con=
figuring the
> >> > bond?
> >> >
> >> > =A0 =A0 =A0 =A0As a possible workaround, if you have control ove=
r the setup
> >> > process (perhaps it's some sort of manual process), adding one s=
lave to
> >> > the bond, leaving the other soon-to-be slaves down, then setting=
 up the
> >> > switch, and finally adding the remaining slaves should work arou=
nd the
> >> > issue, since if the bond has only one slave it won't see any loo=
ped
> >> > packets.
> >> >
> >> > =A0 =A0 =A0 =A0Or you could bring the bond up as active-backup, =
then change the
> >> > mode to balance-xor once the switch is configured.
> >> >
> >> > =A0 =A0 =A0 =A0Ultimately, though, the problem stems from the se=
ttings mismatch
> >> > between the switch and the bonding system; balance-xor is meant =
to
> >> > interoperate with etherchannel, and when the switch is not confi=
gured
> >> > properly, correct behavior is difficult to guarantee.
> >> >
> >>
> >> Jay,
> >>
> >> Thanks a lot for the suggestion.
> >>
> >> It's mainly about usability. We would like to provide customers wi=
th
> >> consistent IPv6 configuration procedures as IPv4. =A0Such workarou=
nds
> >> could be confusing and generate customer calls.
> >>
> > Its not a workaround, its the way it has to be done. =A0You can't j=
ust drop dad
> > packets because you can't tell the difference between those that ar=
e looped back
> > and those that are legitimaely from other hosts, so you need to do =
something
> > like what Jay is suggesting.
> >
>=20
> Yes, you are right. For this case, we cannot tell the difference
> between those DADs  looped back and DADs for the same IPv6 addresses,
> which are from other machines having the same mac address on the
> network.
>=20
> If this happens, the network is already broken due to duplicate mac
> addresses, right? I know this is not the excuse to drop DAD from
Wrong, if you assume that the other systems on the network all implemen=
t DAD
correctly, then the network is working properly until such time as your=
 system
joined it.  At that moment, your system is the one with the duplicate m=
ac and
ipv6 system, and DAD is there to bring the network back into a working =
state.

> others having the same mac address, since those DADs are legitimate
> and indicate duplicate IPv6 address in the network. Just out of
> curiosity, is there any case that such network can still function wel=
l
> with multiple machines having the same mac address besides link
> aggregation? Maybe we could drop those DADs since the network is
> already in trouble?
>=20
Well, if you're just considering end systems (i.e. not routers), then h=
aving two
systems with duplicate macs and/or ipv6 addresses isnt' catastrophic to=
 the
network as a whole,  Those two systems will just fight for ownership of=
 the ipv6
address in the switch arp tables and will both only be intermittently r=
eachable.
The purpose of DAD is to ensure that both parties become aware of this
condition.  The other systems on the network will function as they norm=
ally do.

Neil

> Thanks.
>=20
> Yinglin
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
