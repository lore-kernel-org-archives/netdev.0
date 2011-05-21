From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sat, 21 May 2011 15:15:26 -0700
Message-ID: <20110521151526.723a4f72@nehalam>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?UTF-8?B?UGVzbG/DvGFu?= <nicolas.2p.debian@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, ebiederm@xmission.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47039 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754820Ab1EUWP3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 18:15:29 -0400
In-Reply-To: <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 May 2011 10:54:39 -0700
Jesse Gross <jesse@nicira.com> wrote:

> On Sat, May 21, 2011 at 6:17 AM, Nicolas de Peslo=C3=BCan
> <nicolas.2p.debian@gmail.com> wrote:
> > Le 21/05/2011 12:43, Changli Gao a =C3=A9crit :
> >>
> >> On Sat, May 21, 2011 at 3:29 PM, Jiri Pirko<jpirko@redhat.com> =C2=
=A0wrote:
> >>>
> >>> I do not see a reason why to not emulate that. To make paths as m=
uch
> >>> similar as they can be, that is the point of this patch.
> >>>
> >>> I think it would be better to fix an issue you are pointing at
> >>> rather that revert this.
> >>>
> >>
> >> In my opinion, the hardware accelerated VLAN RX is just a special =
case
> >> of the non hardware accelerated VLAN RX with header reordering. Fo=
r
> >> promiscuous NICs and bridges, hw-accel-vlan-rx is just disabled.
> >
> > I strongly agree with that.
> >
> > The fact that a skb holds a VLAN tag is not a good enough reason to=
 always
> > remove this tag before giving the skb to protocol handlers.
> >
> > If the user ask for VLAN tag removal, we should remove the tag, pos=
sibly
> > using hw-accel untagging if available else software untagging. And =
if the
> > user doesn't ask for tag removal, we should not untag.
> >
> > In other words, if the user doesn't setup any vlan interface on top=
 of
> > another interface, there is no reason to untag the skb : both hw-ac=
cel
> > untagging and software untagging should be disabled.
>=20
> The problem is that for most hardware vlan stripping is actually the
> common case, not the exception.  When you try to disable it frequentl=
y
> there are hidden restrictions that cause problems.  A few examples:
> * Some NICs can't disable stripping at all.
> * Some NICs can only do tag insertion if stripping is configured on r=
eceive.
> * Some NICs can only do hardware offloads (checksum, TSO) if tag
> insertion is used on transmit.
>=20
> So if you are using vlans then acceleration is pretty much a fact of
> life and the best possible way we can deal with it is to make the
> accelerated and non-accelerated cases behave as similarly as possible=
=2E
>=20
> Before we were trying to dynamically enable/disable vlan acceleration
> based on whether a vlan group was configured and that worked fine for
> vlan devices because acceleration was enabled for it.  However, it
> caused an endless series of problems for other devices (such as
> bridging while trunking vlans) due to lost tags, driver bugs, and the
> restrictions above.  Some of these can be fixed with driver changes
> but the fact is that dynamically changing behavior just leads to
> problems for the less common cases that are supposedly being fixed.
> It's much better to do the same thing all the time.
>=20

The old code was also fundamentally broken if doing any kind of
Qos because the TC filter would have to know whether skb had extra
overhead of VLAN tag at the start. This meant the TC filter setup
had to be different depending on whether the hardware supported HW
acceleration or not.
--=20
