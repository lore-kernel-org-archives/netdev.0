From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm, for adaptive dcache hash table sizing (resend)
Date: Tue, 7 Oct 2008 10:06:56 +0200
Message-ID: <20081007080656.GB16143@wotan.suse.de>
References: <20081007064834.GA5959@wotan.suse.de> <20081007070225.GB5959@wotan.suse.de> <48EB11BB.2060704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	netdev@vger.kernel.org, Paul McKenney <paulmck@us.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:56719 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbYJGIG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 04:06:59 -0400
Content-Disposition: inline
In-Reply-To: <48EB11BB.2060704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 09:37:31AM +0200, Eric Dumazet wrote:
> Nick Piggin a =E9crit :
> >(resending with correct netdev address)
> >
> >With this algorithm, I can fit a whole kernel source and git tree in=
 my=20
> >dcache
> >hash table that is still 1/8th the size it would be before the patch=
=2E
> >
> >I'm cc'ing netdev because Dave did express some interest in using th=
is for
> >some networking hashes, and network guys in general are pretty cluey=
 when=20
> >it
> >comes to hashes and such ;)
> >
>=20
> Thanks for reminding us this interesting stuff. And yes, IP route cac=
he=20
> could use
> same algo. That is particularly interesting because it has a=20
> /proc/net/rt_cache
> accessor that needs to sequentially scan this hash table (potentialy =
with
> many empty slots), while dcache doesnt have such killer.

Hmm, that is interesting. What are the exact semantics of this rt_cache
file? It might be difficult to retain them over a hash table resize
operation, but it would be worth trying. Big hammer to block access to
the file if a resize is in progress might work (but do we need to hold =
off
access over multiple calls from userspace? then may need to also avoid
resizing the hash table if the rt_cache file is open).


> >+static struct dcache_hash *alloc_dhash(int size)
> >+{
> >+	struct dcache_hash *dh;
> >+	unsigned long bytes;
> >+	unsigned int shift;
> >+	int i;
> >+
> >+	shift =3D ilog2(size);
> >+	BUG_ON(size !=3D 1UL << shift);
> >+	bytes =3D size * sizeof(struct hlist_head *);
> >+
> >+	dh =3D kmalloc(sizeof(struct dcache_hash), GFP_KERNEL);
> >+	if (!dh)
> >+		return NULL;
> >+
> >+	if (bytes <=3D PAGE_SIZE) {
> >+		dh->table =3D kmalloc(bytes, GFP_KERNEL);
> >+	} else {
> >+		dh->table =3D vmalloc(bytes);
> >+	}
>=20
> Here we probably want to use a hashdist/NUMA enabled vmalloc().
>=20
> That is, regardless of current numa policy of *this* thread,
> we want to spread hash table on all nodes.

Yeah, it definitely should do. Thanks.

=20
> Also, struct dcache_hash being very small, you want to force it to
> use an exclusive cache line, to be sure it wont share it with some=20
> higly modified data...
>=20
> struct dcache_hash {
> 	struct hlist_head *table;
> 	unsigned int shift;
> 	unsigned int mask;
> } __cacheline_aligned_in_smp;

Yes, good point.
