From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Wed, 18 May 2011 16:19:01 +0300
Message-ID: <20110518131901.GA19695@redhat.com>
References: <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain>
 <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain>
 <20110518103819.GL7589@redhat.com>
 <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com>
 <20110518111734.GO7589@redhat.com>
 <BANLkTim9RQ94MT4L0QHx-yzZT5nXdbi0aQ@mail.gmail.com>
 <20110518115602.GT7589@redhat.com>
 <BANLkTikOsR9RUJboG1P=oG8ofr5BLbgQ4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTikOsR9RUJboG1P=oG8ofr5BLbgQ4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 02:48:24PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> W dniu 18 maja 2011 13:56 u=C5=BCytkownik Michael S. Tsirkin
> <mst@redhat.com> napisa=C5=82:
> > On Wed, May 18, 2011 at 01:47:33PM +0200, Micha=C5=82 Miros=C5=82aw=
 wrote:
> >> W dniu 18 maja 2011 13:17 u=C5=BCytkownik Michael S. Tsirkin
> >> <mst@redhat.com> napisa=C5=82:
> >> > On Wed, May 18, 2011 at 01:10:50PM +0200, Micha=C5=82 Miros=C5=82=
aw wrote:
> >> >> 2011/5/18 Michael S. Tsirkin <mst@redhat.com>:
> >> >> > On Tue, May 17, 2011 at 03:28:38PM -0700, Shirley Ma wrote:
> >> >> >> On Tue, 2011-05-17 at 23:48 +0200, Micha=C5=82 Miros=C5=82aw=
 wrote:
> >> >> >> > 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
> >> >> >> > > Hello Michael,
> >> >> >> > >
> >> >> >> > > Looks like to use a new flag requires more time/work. I =
am thinking
> >> >> >> > > whether we can just use HIGHDMA flag to enable zero-copy=
 in macvtap
> >> >> >> > to
> >> >> >> > > avoid the new flag for now since mavctap uses real NICs =
as lower
> >> >> >> > device?
> >> >> >> >
> >> >> >> > Is there any other restriction besides requiring driver to=
 not recycle
> >> >> >> > the skb? Are there any drivers that recycle TX skbs?
> >> >> > Not just recycling skbs, keeping reference to any of the page=
s in the
> >> >> > skb. Another requirement is to invoke the callback
> >> >> > in a timely fashion. =C2=A0For example virtio-net doesn't lim=
it the time until
> >> >> > that happens (skbs are only freed when some other packet is
> >> >> > transmitted), so we need to avoid zcopy for such (nested-virt=
)
> >> >> > scenarious, right?
> >> >> Hmm. But every hardware driver supporting SG will keep referenc=
e to
> >> >> the pages until the packet is sent (or DMA'd to the device). Th=
is can
> >> >> take a long time if hardware queue happens to stall for some re=
ason.
> >> > That's a fundamental property of zero copy transmit.
> >> > You can't let the application/guest reuse the memory until
> >> > no one looks at it anymore.
> >>
> >> One more question: is userspace (or whatever is sending those pack=
ets)
> >> denied from modifying passed pages? I assume it is, but just want =
to
> >> be sure.
> >>
> >> Best Regards,
> >> Micha=C5=82 Miros=C5=82aw
> >
> > Good point.
> >
> > It's not denied in the sense that it still can modify them if it's
> > buggy (the pages might not be read-only).
> > But well-behaved userspace won't modify them until the callback
> > is invoked.
> >
> > That would be a problem if the underlying device is
> > a bridge where we might try to e.g. filter these packets -
> > data can get modified after the filter. We'd have to copy
> > whatever the filter accesses and use the copy - it's rarely
> > the data itself.
> >
> > That's not normally a problem for macvtap connected to a physical N=
IC,
> > as that already bypasses any and all filtering.
> >
> > But that's another limitation we should note in the comment,
> > and another reason to limit to specific devices.
>=20
> It looks like this feature can be used only in very strict circumstan=
ces.

True. I think it's reasonable to try and start with something
restricted and then add features though - past attempts to solve the pr=
oblem
generally right away did not bear fruit.

> What about tcpdump listening on the device or lowerdev? This path
> might clone the skb for any device.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

Thanks for bringing this up: taps do need to be fixed as they can hang
on to a page for unlimited time. Further, as a malicious guest can
change the packet at any time, data that taps get wouldn't be correct.
We can either linearize the problematic skbs or disable
zero copy if there are any taps for the given device.

--=20
MST
