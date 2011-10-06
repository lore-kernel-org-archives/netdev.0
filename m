From: Yinglin Sun <Yinglin.Sun@emc.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Thu, 6 Oct 2011 15:17:00 -0700
Message-ID: <CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
	<20111006110047.GA22462@hmsreliant.think-freely.org>
	<27199.1317927933@death>
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
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54417 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab1JFWRY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 18:17:24 -0400
Received: by bkbzt4 with SMTP id zt4so4025201bkb.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 15:17:23 -0700 (PDT)
In-Reply-To: <27199.1317927933@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2011 at 12:05 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
>
> Neil Horman <nhorman@tuxdriver.com> wrote:
>
> >On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote:
> >> Steps to reproduce this issue:
> >> 1. create bond0 over eth0 and eth1, set the mode to balance-xor
> >> 2. add an IPv6 address to bond0
> >> 3. DAD packet is sent out from one slave and then is looped back f=
rom
> >> the other slave. Therefore, it is treated as a duplicate address a=
nd
> >> stays tentative afterwards:
> >> =C2=A0 =C2=A0kern.info:
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0Oct =C2=A05 11:50:18 testvm1 kernel: [ =
=C2=A0129.224353] bond0: IPv6 duplicate address 1234::1 detected!
> >>
> >> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
> >> ---
> >> =C2=A0net/ipv6/ndisc.c | =C2=A0 15 +++++++++++++--
> >> =C2=A01 files changed, 13 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> >> index 9da6e02..c82f4c7 100644
> >> --- a/net/ipv6/ndisc.c
> >> +++ b/net/ipv6/ndisc.c
> >> @@ -809,9 +809,10 @@ static void ndisc_recv_ns(struct sk_buff *skb=
)
> >>
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ifp->flags & (=
IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (dad) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const unsigned char *sadr;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sadr =3D skb_mac_header(skb);
> >> +
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (dev->type =3D=3D ARPHRD_IEEE8=
02_TR) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const unsign=
ed char *sadr;
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sadr =3D skb=
_mac_header(skb);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((=
(sadr[8] ^ dev->dev_addr[0]) & 0x7f) =3D=3D 0 &&
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0sadr[9] =3D=3D dev->dev_addr[1] &&
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0sadr[10] =3D=3D dev->dev_addr[2] &&
> >> @@ -821,6 +822,16 @@ static void ndisc_recv_ns(struct sk_buff *skb=
)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0/* looped-back to us */
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0goto out;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (dev->type =3D=3D ARPHRD_ETHER=
) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sadr[6] =
=3D=3D dev->dev_addr[0] &&
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sadr[7] =3D=3D dev->dev_addr[1] &&
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sadr[8] =3D=3D dev->dev_addr[2] &&
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sadr[9] =3D=3D dev->dev_addr[3] &&
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sadr[10] =3D=3D dev->dev_addr[4] &&
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sadr[11] =3D=3D dev->dev_addr[5]) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* looped-back to us */
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto out;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >>
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> >> --
> >> 1.7.4.1
> >>
> >Nack, This seems like it will just completely break DAD. =C2=A0What =
if theres another
> >system out there with the same mac address. =C2=A0A response from th=
at system would
> >get dropped by this filter, instead of causing The local system to s=
top using
> >the address. =C2=A0What you really want to do is modify
> >bond_should_deliver_exact_match to detect this frame on the inactive=
 slave or
> >some such, and drop the frame there.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Also NACK; and adding a bit of information=
=2E =C2=A0The balance-xor
> mode is nominally expecting to interact with a switch whose ports are
> set for etherchannel ("static link aggregation"), in which case the
> switch will not loop the packet back around.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0If your switch can do etherchannel, then e=
nable it and the
> problem should go away. =C2=A0If your switch cannot do this, then you=
 may
> have other issues, because all of the multicast or broadcast packets
> going out any bonding slave will loop around to another slave. =C2=A0=
You
> could also use 802.3ad / LACP if you switch supports that.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0For balance-xor (or balance-rr, for that m=
atter) mode to a
> non-etherchannel switch, it's going to be difficult, if not impossibl=
e,
> to modify bond_should_deliver_exact_match, because there are no inact=
ive
> slaves. =C2=A0In this mode, bonding is expecting the switch to balanc=
e
> incoming traffic across the ports, and not deliver looped back packet=
s
> or duplicates. =C2=A0There are no restrictions on what type of traffi=
c
> (mcast, bcast, ucast) may arrive on any given port.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0I can't think of a way to make the non-eth=
erchannel case work
> for balance-xor (or balance-rr) without breaking the DAD functionalit=
y
> in the case of an actual duplicate. =C2=A0I'm not aware of a way to
> distinguish a looped back DAD probe from an actual duplicate address
> probe elsewhere on the network.
>

Hi Neil & Jay,

Thanks a lot for the comments.

The use case is to add IPv6 address on the bonding interface first,
and then set up port channel on switch. We'll hit this issue and the
new address will stay tentative and unusable after port channel is set
up on switch. This patch is for this valid use case.

Except failover mode, all slaves are active on receiving packets, so
we are receiving such looped back DAD and the bonding driver cannot
ignore them. I cannot think of a way to distinguish if a DAD is looped
back or from someone else having the same mac address. They look the
same to the host. If there is another machine having the same mac
address, this code path gets executed if both are doing DAD at the
same time for the same IPv6 address. Maybe we should find out what the
specification defines for this case?

Thanks.

Yinglin
