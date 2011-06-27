From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Mon, 27 Jun 2011 15:42:04 +0100
Message-ID: <1309185724.32717.241.camel@zakaz.uk.xensource.com>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
	 <4E04C961.9010302@goop.org>  <1308938183.2532.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	"Rusty Russell" <rusty@rustcorp.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:27069 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab1F0Ome (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 10:42:34 -0400
In-Reply-To: <1308938183.2532.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-24 at 18:56 +0100, Eric Dumazet wrote:
> Le vendredi 24 juin 2011 =C3=A0 10:29 -0700, Jeremy Fitzhardinge a =C3=
=A9crit :
> > On 06/24/2011 08:43 AM, Ian Campbell wrote:
> > > We've previously looked into solutions using the skb destructor c=
allback
> > > but that falls over if the skb is cloned since you also need to k=
now
> > > when the clone is destroyed. Jeremy Fitzhardinge and I subsequent=
ly
> > > looked at the possibility of a no-clone skb flag (i.e. always for=
cing a
> > > copy instead of a clone) but IIRC honouring it universally turned=
 into a
> > > very twisty maze with a number of nasty corner cases etc. It also=
 seemed
> > > that the proportion of SKBs which get cloned at least once appear=
ed as
> > > if it could be quite high which would presumably make the perform=
ance
> > > impact unacceptable when using the flag. Another issue with using=
 the
> > > skb destructor is that functions such as __pskb_pull_tail will ea=
t (and
> > > free) pages from the start of the frag array such that by the tim=
e the
> > > skb destructor is called they are no longer there.
> > >
> > > AIUI Rusty Russell had previously looked into a per-page destruct=
or in
> > > the shinfo but found that it couldn't be made to work (I don't re=
member
> > > why, or if I even knew at the time). Could that be an approach wo=
rth
> > > reinvestigating?
> > >
> > > I can't really think of any other solution which doesn't involve =
some
> > > sort of driver callback at the time a page is free()d.
> >=20
>=20
> This reminds me the packet mmap (tx path) games we play with pages.
>=20
> net/packet/af_packet.c : tpacket_destruct_skb(), poking
> TP_STATUS_AVAILABLE back to user to tell him he can reuse space...

This is OK because af_packet involves no kernel side protocol and hence
there can be no retransmits etc? Otherwise you would suffer from the
same sorts of issues as I described with NFS at [0]?

However it seems like this might still have a problem if your SKBs are
ever cloned. What happens in this case, e.g if a user of AF_PACKET send=
s
a broadcast via a device associated with a bridge[1] (where it would be
flooded)?

Wouldn't you get into the situation where the destructor of the initial
skb is called before one or more of the clones going to a different
destination were sent. So you would send TP_STATUS_AVAILABLE to
userspace before the stack was really finished with the page and run th=
e
risk of userspace reusing the buffer, leading to incorrect bytes going
to some destinations?

It looks to me that anything which does any zero-copy type thing to the
network stack will have problems with one or both of protocol retransmi=
t
or SKB clone. There's simply no mechanism to know when the stack is
really finished with a page.

Ian.

[0] http://marc.info/?l=3Dlinux-nfs&m=3D122424132729720&w=3D2
[1] Since dhcp clients typically use AF_PACKET and you typically put th=
e
IP address on the bridge itself in these configurations this won't be
that unusual.

Ian.

