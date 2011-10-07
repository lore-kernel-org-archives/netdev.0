From: Yinglin Sun <yinglin.s@gmail.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Fri, 7 Oct 2011 11:08:49 -0700
Message-ID: <CAN17JHUZLWmDQF8P6eCbLkTanYjwi0YmF5dXkfvH_QCRnbtaMA@mail.gmail.com>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
	<20111006110047.GA22462@hmsreliant.think-freely.org>
	<27199.1317927933@death>
	<CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com>
	<CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
	<7122.1317949193@death>
	<CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
	<20111007111028.GA11408@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41663 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab1JGSIv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 14:08:51 -0400
Received: by bkbzt4 with SMTP id zt4so5123966bkb.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 11:08:50 -0700 (PDT)
In-Reply-To: <20111007111028.GA11408@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 7, 2011 at 4:10 AM, Neil Horman <nhorman@tuxdriver.com> wro=
te:
> On Thu, Oct 06, 2011 at 06:24:36PM -0700, Yinglin Sun wrote:
>> On Thu, Oct 6, 2011 at 5:59 PM, Jay Vosburgh <fubar@us.ibm.com> wrot=
e:
>> > Yinglin Sun <Yinglin.Sun@emc.com> wrote:
>> >
>> >>On Thu, Oct 6, 2011 at 3:17 PM, Yinglin Sun <Yinglin.Sun@emc.com> =
wrote:
>> >>>
>> >>> On Thu, Oct 6, 2011 at 12:05 PM, Jay Vosburgh <fubar@us.ibm.com>=
 wrote:
>> >>> >
>> >>> > Neil Horman <nhorman@tuxdriver.com> wrote:
>> >>> >
>> >>> > >On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote:
>> >>> > >> Steps to reproduce this issue:
>> >>> > >> 1. create bond0 over eth0 and eth1, set the mode to balance=
-xor
>> >>> > >> 2. add an IPv6 address to bond0
>> >>> > >> 3. DAD packet is sent out from one slave and then is looped=
 back from
>> >>> > >> the other slave. Therefore, it is treated as a duplicate ad=
dress and
>> >>> > >> stays tentative afterwards:
>> >>> > >> =C2=A0 =C2=A0kern.info:
>> >>> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0Oct =C2=A05 11:50:18 testvm1 ker=
nel: [ =C2=A0129.224353] bond0: IPv6 duplicate address 1234::1 detected=
!
>> >
>> > [...]
>> >
>> >>> > >Nack, This seems like it will just completely break DAD. =C2=A0=
What if theres another
>> >>> > >system out there with the same mac address. =C2=A0A response =
from that system would
>> >>> > >get dropped by this filter, instead of causing The local syst=
em to stop using
>> >>> > >the address. =C2=A0What you really want to do is modify
>> >>> > >bond_should_deliver_exact_match to detect this frame on the i=
nactive slave or
>> >>> > >some such, and drop the frame there.
>> >>> >
>> >>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Also NACK; and adding a bit of info=
rmation. =C2=A0The balance-xor
>> >>> > mode is nominally expecting to interact with a switch whose po=
rts are
>> >>> > set for etherchannel ("static link aggregation"), in which cas=
e the
>> >>> > switch will not loop the packet back around.
>> >>> >
>> >>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0If your switch can do etherchannel,=
 then enable it and the
>> >>> > problem should go away. =C2=A0If your switch cannot do this, t=
hen you may
>> >>> > have other issues, because all of the multicast or broadcast p=
ackets
>> >>> > going out any bonding slave will loop around to another slave.=
 =C2=A0You
>> >>> > could also use 802.3ad / LACP if you switch supports that.
>> >>> >
>> >>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0For balance-xor (or balance-rr, for=
 that matter) mode to a
>> >>> > non-etherchannel switch, it's going to be difficult, if not im=
possible,
>> >>> > to modify bond_should_deliver_exact_match, because there are n=
o inactive
>> >>> > slaves. =C2=A0In this mode, bonding is expecting the switch to=
 balance
>> >>> > incoming traffic across the ports, and not deliver looped back=
 packets
>> >>> > or duplicates. =C2=A0There are no restrictions on what type of=
 traffic
>> >>> > (mcast, bcast, ucast) may arrive on any given port.
>> >>> >
>> >>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0I can't think of a way to make the =
non-etherchannel case work
>> >>> > for balance-xor (or balance-rr) without breaking the DAD funct=
ionality
>> >>> > in the case of an actual duplicate. =C2=A0I'm not aware of a w=
ay to
>> >>> > distinguish a looped back DAD probe from an actual duplicate a=
ddress
>> >>> > probe elsewhere on the network.
>> >>> >
>> >>>
>> >>> Hi Neil & Jay,
>> >>>
>> >>> Thanks a lot for the comments.
>> >>>
>> >>> The use case is to add IPv6 address on the bonding interface fir=
st,
>> >>> and then set up port channel on switch. We'll hit this issue and=
 the
>> >>> new address will stay tentative and unusable after port channel =
is set
>> >>> up on switch. This patch is for this valid use case.
>> >>>
>> >>> Except failover mode, all slaves are active on receiving packets=
, so
>> >>> we are receiving such looped back DAD and the bonding driver can=
not
>> >>> ignore them. I cannot think of a way to distinguish if a DAD is =
looped
>> >>> back or from someone else having the same mac address. They look=
 the
>> >>> same to the host. If there is another machine having the same ma=
c
>> >>> address, this code path gets executed if both are doing DAD at t=
he
>> >>> same time for the same IPv6 address. Maybe we should find out wh=
at the
>> >>> specification defines for this case?
>> >>>
>> >>
>> >>RFC4862 has a discussion about this issue:
>> >>http://tools.ietf.org/html/rfc4862#appendix-A
>> >>The better solution could be to record the number of DAD sent out.=
 If
>> >>we received more DAD packets than we sent out, there is someone el=
se
>> >>on the network who has the same mac address and sent DAD for the s=
ame
>> >>IPv6 address. However, this solution doesn't work with bonding
>> >>interface, since all other active slaves but the one sending out D=
AD
>> >>will receive packet looped back. It doesn't seem there is a simple
>> >>solution for this issue.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Why are you setting up the port channel=
 after configuring the
>> > bond?
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0As a possible workaround, if you have c=
ontrol over the setup
>> > process (perhaps it's some sort of manual process), adding one sla=
ve to
>> > the bond, leaving the other soon-to-be slaves down, then setting u=
p the
>> > switch, and finally adding the remaining slaves should work around=
 the
>> > issue, since if the bond has only one slave it won't see any loope=
d
>> > packets.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Or you could bring the bond up as activ=
e-backup, then change the
>> > mode to balance-xor once the switch is configured.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Ultimately, though, the problem stems f=
rom the settings mismatch
>> > between the switch and the bonding system; balance-xor is meant to
>> > interoperate with etherchannel, and when the switch is not configu=
red
>> > properly, correct behavior is difficult to guarantee.
>> >
>>
>> Jay,
>>
>> Thanks a lot for the suggestion.
>>
>> It's mainly about usability. We would like to provide customers with
>> consistent IPv6 configuration procedures as IPv4. =C2=A0Such workaro=
unds
>> could be confusing and generate customer calls.
>>
> Its not a workaround, its the way it has to be done. =C2=A0You can't =
just drop dad
> packets because you can't tell the difference between those that are =
looped back
> and those that are legitimaely from other hosts, so you need to do so=
mething
> like what Jay is suggesting.
>

Yes, you are right. For this case, we cannot tell the difference
between those DADs  looped back and DADs for the same IPv6 addresses,
which are from other machines having the same mac address on the
network.

If this happens, the network is already broken due to duplicate mac
addresses, right? I know this is not the excuse to drop DAD from
others having the same mac address, since those DADs are legitimate
and indicate duplicate IPv6 address in the network. Just out of
curiosity, is there any case that such network can still function well
with multiple machines having the same mac address besides link
aggregation? Maybe we could drop those DADs since the network is
already in trouble?

Thanks.

Yinglin
