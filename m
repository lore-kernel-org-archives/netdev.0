From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Wed, 18 May 2011 14:17:34 +0300
Message-ID: <20110518111734.GO7589@redhat.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop>
 <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop>
 <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain>
 <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain>
 <20110518103819.GL7589@redhat.com>
 <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com>
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
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 01:10:50PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> 2011/5/18 Michael S. Tsirkin <mst@redhat.com>:
> > On Tue, May 17, 2011 at 03:28:38PM -0700, Shirley Ma wrote:
> >> On Tue, 2011-05-17 at 23:48 +0200, Micha=C5=82 Miros=C5=82aw wrote=
:
> >> > 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
> >> > > Hello Michael,
> >> > >
> >> > > Looks like to use a new flag requires more time/work. I am thi=
nking
> >> > > whether we can just use HIGHDMA flag to enable zero-copy in ma=
cvtap
> >> > to
> >> > > avoid the new flag for now since mavctap uses real NICs as low=
er
> >> > device?
> >> >
> >> > Is there any other restriction besides requiring driver to not r=
ecycle
> >> > the skb? Are there any drivers that recycle TX skbs?
> >
> > Not just recycling skbs, keeping reference to any of the pages in t=
he
> > skb. Another requirement is to invoke the callback
> > in a timely fashion. =C2=A0For example virtio-net doesn't limit the=
 time until
> > that happens (skbs are only freed when some other packet is
> > transmitted), so we need to avoid zcopy for such (nested-virt)
> > scenarious, right?
>=20
> Hmm. But every hardware driver supporting SG will keep reference to
> the pages until the packet is sent (or DMA'd to the device). This can
> take a long time if hardware queue happens to stall for some reason.

That's a fundamental property of zero copy transmit.
You can't let the application/guest reuse the memory until
no one looks at it anymore.

> Is it that you mean keeping a reference after all skbs pointing to th=
e
> pages are released?

No one should reference the pages after the callback is invoked, yes.

> >> Not more other restrictions, skb clone is OK. pskb_expand_head() l=
ooks
> >> OK to me from code review.
> > Hmm. pskb_expand_head calls skb_release_data while keeping
> > references to pages. How is that ok? What do I miss?
>=20
> It's making copy of the skb_shinfo earlier, so the pages refcount
> stays the same.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

Exactly. But the callback is invoked so the guest thinks it's ok to
change this memory. If it does a corrupted packet will be sent out.

--=20
MST
