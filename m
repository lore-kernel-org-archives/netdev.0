From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Wed, 18 May 2011 19:23:12 +0300
Message-ID: <20110518162311.GA22001@redhat.com>
References: <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain>
 <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain>
 <20110518103819.GL7589@redhat.com>
 <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com>
 <20110518111734.GO7589@redhat.com>
 <BANLkTi=g_PFfS5653K8ZoQ2Jhp8DhCV1hg@mail.gmail.com>
 <1305729507.32080.6.camel@localhost.localdomain>
 <1305734543.32080.50.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305734543.32080.50.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 09:02:23AM -0700, Shirley Ma wrote:
> On Wed, 2011-05-18 at 07:38 -0700, Shirley Ma wrote:
> > On Wed, 2011-05-18 at 13:40 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > > >> >> Not more other restrictions, skb clone is OK.
> > pskb_expand_head()
> > > looks
> > > >> >> OK to me from code review.
> > > >> > Hmm. pskb_expand_head calls skb_release_data while keeping
> > > >> > references to pages. How is that ok? What do I miss?
> > > >> It's making copy of the skb_shinfo earlier, so the pages refco=
unt
> > > >> stays the same.
> > > > Exactly. But the callback is invoked so the guest thinks it's o=
k
> > to
> > > > change this memory. If it does a corrupted packet will be sent
> > out.
> > >=20
> > > Hmm. I tool a quick look at skb_clone(), and it looks like this
> > > sequence will break this scheme:
> > >=20
> > > skb2 =3D skb_clone(skb...);
> > > kfree_skb(skb) or pskb_expand_head(skb);  /* callback called */
> > > [use skb2, pages still referenced]
> > > kfree_skb(skb); /* callback called again */
> > >=20
> > > This sequence is common in bridge, might be in other places.
> > >=20
> > > Maybe this ubuf thing should just track clones? This will make it
> > work
> > > on all devices then.
> >=20
> > The callback was only invoked when last reference of skb was gone.
> > skb_clone does increase skb refcnt. I tested tcpdump on lower devic=
e,
> > it
> > worked.
> >=20
> > For the sequence of:
> >=20
> > skb_clone  -> last refcnt + 1
> > kfree_skb() or pskb_expand_head -> callback not called
> > kfree_skb() -> callback called
> >=20
> > I will check page refcount to see whether it's balanced.=20
>=20
> The page refcounts are balanced too.=20
>=20
> In macvtap/vhost Real NIC zerocopy case, it always goes to fastpath i=
n
> pskb_expand_head, so I didn't hit any issue.
>=20
> But rethinking about pskb_expand_head(), it calls skb_release_data() =
to
> free old skb head when it's not in the fastpath (pskb_expand_head is =
not
> the last reference of this skb); And it's impossible to track which s=
kb
> head (old one or new one) will be the last one to free. So better to
> return error for zero-copy skbs when not using fastpath. Does it make
> sense?=20

I'm not sure it does. Look e.g. at tg3 - if expand_head fails
packet gets dropped. No crash but unlikely to perform well :).

> Besides this, any other issue?
>=20
>=20
> Thanks
> Shirley
