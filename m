From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] fib_trie: flush improvement
Date: Wed, 2 Apr 2008 11:03:35 -0700
Message-ID: <20080402110335.66b04181@extreme>
References: <20080401172702.094c0700@extreme>
	<47F33D42.9080302@cosmosbay.com>
	<47F39998.8040605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33116 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708AbYDBSDl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 14:03:41 -0400
In-Reply-To: <47F39998.8040605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Apr 2008 16:35:04 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Eric Dumazet a =C3=A9crit :
> > Stephen Hemminger a =C3=A9crit :
> >> This is an attempt to fix the problem described in:
> >>      http://bugzilla.kernel.org/show_bug.cgi?id=3D6648
> >> I can reproduce this by loading lots and lots of routes and the ta=
king
> >> the interface down. This causes all entries in trie to be flushed,=
 but
> >> each leaf removal causes a rebalance of the trie. And since the re=
moval
> >> is depth first, it creates lots of needless work.
> >>
> >> Instead on flush, just walk the trie and prune as we go.
> >> The implementation is for description only, it probably doesn't wo=
rk=20
> >> yet.
> >>
> >>  =20
> >
> > I dont get it, since the bug reporter mentions with recent kernels =
:
> >
> > Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> >
> > Is it what you get with your tests ?
> >
> > Pawel reports :
> >
> > cat /proc/net/fib_triestat
> > Main: Aver depth: 2.26 Max depth: 6 Leaves: 235924
> > Internal nodes: 57854 1: 31632 2: 11422 3: 8475 4: 3755 5: 1676 6: =
893=20
> > 18: 1
> >
> > Pointers: 609760 Null ptrs: 315983 Total size: 16240 kB
> >
> > warning messages comes from rootnode that cannot be expanded, since=
 it=20
> > hits MAX_ORDER (on a 32bit x86)
> >
> >
> >
> > (sizeof(struct tnode) + (sizeof(struct node *) << bits);) is rounde=
d=20
> > to 4 << (bit + 1), ie 2 << 20
> >
> > For larger allocations Pawel has two choices :
> >
> > change MAX_ORDER from 11 to 13 or 14
> > If this machine is a pure router, this change wont have performance=
=20
> > impact.
> >
> > Or (more difficult, but more appropriate for mainline) change=20
> > fib_trie.c to use vmalloc() for very big allocaions (for the root=20
> > only), and vfree()
> >
> > Since vfree() cannot be called from rcu callback, one has to setup =
a=20
> > struct work_struct helper.
> >
> Here is a patch (untested unfortunatly) to implement this.
>=20
> [IPV4] fib_trie: root_tnode can benefit of vmalloc()
>=20
> FIB_TRIE root node can be very large and currently hits MAX_ORDER lim=
it.
> It also wastes about 50% of allocated size, because of power of two=20
> rounding of tnode.
>=20
> A switch to vmalloc() can improve FIB_TRIE performance by allowing ro=
ot=20
> node to grow
> past the alloc_pages() limit, while preserving memory.
>=20
> Special care must be taken to free such zone, as rcu handler is not=20
> allowed to call vfree(),
> we use a worker instead.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
>=20

Rather than switching between three allocation strategies, I would rath=
er
just have kmalloc and vmalloc.
