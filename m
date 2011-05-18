From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Wed, 18 May 2011 09:45:40 -0700
Message-ID: <1305737140.32080.59.camel@localhost.localdomain>
References: <1305588738.3456.65.camel@localhost.localdomain>
	 <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
	 <1305671318.10756.49.camel@localhost.localdomain>
	 <20110518103819.GL7589@redhat.com>
	 <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com>
	 <20110518111734.GO7589@redhat.com>
	 <BANLkTi=g_PFfS5653K8ZoQ2Jhp8DhCV1hg@mail.gmail.com>
	 <1305729507.32080.6.camel@localhost.localdomain>
	 <20110518154746.GA21378@redhat.com>
	 <1305734857.32080.53.camel@localhost.localdomain>
	 <20110518163633.GB22001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518163633.GB22001@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-05-18 at 19:36 +0300, Michael S. Tsirkin wrote:
> On Wed, May 18, 2011 at 09:07:37AM -0700, Shirley Ma wrote:
> > On Wed, 2011-05-18 at 18:47 +0300, Michael S. Tsirkin wrote:
> > > On Wed, May 18, 2011 at 07:38:27AM -0700, Shirley Ma wrote:
> > > > On Wed, 2011-05-18 at 13:40 +0200, Micha=C5=82 Miros=C5=82aw wr=
ote:
> > > > > >> >> Not more other restrictions, skb clone is OK.
> > > pskb_expand_head()
> > > > > looks
> > > > > >> >> OK to me from code review.
> > > > > >> > Hmm. pskb_expand_head calls skb_release_data while
> keeping
> > > > > >> > references to pages. How is that ok? What do I miss?
> > > > > >> It's making copy of the skb_shinfo earlier, so the pages
> > > refcount
> > > > > >> stays the same.
> > > > > > Exactly. But the callback is invoked so the guest thinks
> it's ok
> > > to
> > > > > > change this memory. If it does a corrupted packet will be
> sent
> > > out.
> > > > >=20
> > > > > Hmm. I tool a quick look at skb_clone(), and it looks like
> this
> > > > > sequence will break this scheme:
> > > > >=20
> > > > > skb2 =3D skb_clone(skb...);
> > > > > kfree_skb(skb) or pskb_expand_head(skb);  /* callback called
> */
> > > > > [use skb2, pages still referenced]
> > > > > kfree_skb(skb); /* callback called again */
> > > > >=20
> > > > > This sequence is common in bridge, might be in other places.
> > > > >=20
> > > > > Maybe this ubuf thing should just track clones? This will mak=
e
> it
> > > work
> > > > > on all devices then.
> > > >=20
> > > > The callback was only invoked when last reference of skb was
> gone.
> > > > skb_clone does increase skb refcnt. I tested tcpdump on lower
> > > device, it
> > > > worked.
> > >=20
> > > Right, it will normally work, but two issues I think you miss:
> > > 1. malicious guest can change the memory between when it is sent
> out
> > > by
> > >    device and consumed by tcpdump, so you will see different
> things
> > >    (not sure how important this is).
> > > 2. if tcpdump stops consuming stuff from the packet socket (it's
> > >    userspace, can't be trusted) then we won't get a callback for
> > >    page potentially forever, guest networking will get blocked
> etc.
> > > > For the sequence of:
> > > >=20
> > > > skb_clone  -> last refcnt + 1
> > > > kfree_skb() or pskb_expand_head -> callback not called
> > > > kfree_skb() -> callback called
> > > >=20
> > > > I will check page refcount to see whether it's balanced.
> > > >=20
> > > > Thanks
> > > > shirley
> > >=20
> > >=20
> > > pskb_expand_head is a problem anyway I think as it
> > > can hang on to pages after it calls release_data.
> > > Then guest will modify these pages and you get trash there.=20
> >=20
> > This can be avoid by allowing pskb_expand_head in fastpath only, I
> > think. But not sure whether tcpdump can still work with this.
> >=20
> > Thanks
> > Shirley
>=20
> Yes, I agree.  I think for tcpdump, we really need to copy the data
> anyway, to avoid guest changing it in between.  So we do that and the=
n
> use the copy everywhere, release the old one. Hmm?=20

Yes. Old one use zerocopy, new one use copy data.

Thanks
Shirley
