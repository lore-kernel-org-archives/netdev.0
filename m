From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 01 Feb 2010 04:32:25 -0500
Message-ID: <1265016745.7499.144.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>  <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264834704.2919.3.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-01-30 at 07:58 +0100, Eric Dumazet wrote:
> Le vendredi 29 janvier 2010 =C3=A0 20:59 -0500, Jon Masters a =C3=A9c=
rit :
> > On Fri, 2010-01-29 at 20:57 -0500, Jon Masters wrote:
> >=20
> > > Ah so I should have realized before but I wasn't looking at valid=
 values
> > > for the range of the hashtable yet, nf_conntrack_htable_size is g=
etting
> > > wildly out of whack. It goes from:
> > >=20
> > > (gdb) print nf_conntrack_hash_rnd
> > > $1 =3D 2688505299
> > > (gdb) print nf_conntrack_htable_size
> > > $2 =3D 16384
> > >=20
> > > nf_conntrack_events: 1
> > > nf_conntrack_max: 65536
> > >=20
> > > Shortly after booting, before being NULLed shortly after starting=
 some
> > > virtual machines (the hash isn't reset, whereas it is recomputed =
if the
> > > hashtable is re-initialized after an intentional resizing operati=
on):
> >=20
> > I mean the *seed* isn't changed, so I don't think it was resized
> > intentionally. I wonder where else htable_size is fiddled with.

> This rings a bell here, since another crash analysis on another probl=
em
> suggested to me a potential problem with read_mostly and modules, but=
 I
> had no time to confirm the thing yet.

It gets more interesting, and this occurs with the code builtin anyway
(I build in to make it easier to kgdb the result conveniently), so I
don't think that's an issue...but...

I hacked up a per-namespace version of hashtables (this needs doing
anyway, since the global stuff is just waiting to break) but then
noticed that the built kernel always ends up linked roughly (the
nf_conntrack_default_htable_size is a direct rename of the existing
htable_size and is now simply the initial size for new hashtables - the=
y
can then have their own sizes independently of this global):

00000000000074c8 l     O .data.read_mostly      0000000000000008
nf_conntrack_cachep
00000000000074d0 g     O .data.read_mostly      0000000000000198
nf_conntrack_untracked
0000000000007668 g     O .data.read_mostly      0000000000000004
nf_conntrack_default_htable_size
000000000000766c g     O .data.read_mostly      0000000000000004
nf_conntrack_default_max

In some of my runs, I've been seeing nf_conntrack_default_htable_size
get corrupted with a value that just happens to be the address of
nf_conntrack_cachep. I looked over the RCU handling and the cache
allocation/de-allocation, but didn't see anything yet. And then I'm not
sure why this address would happen to get written there? It immediately
follows nf_conntrack_untracked so I looked over what happens to that
struct (including the memset, etc.) and didn't see anything either.

Like I said, I dumped the memory with kgdb in a number of runs both
"before" and "after" for the entire page surrounding the corruption and
the only real difference is this change to the value immediately
following nf_conntrack_untracked. There was also a decrement of the
reference count on untracked (I think that's normal? It's like a
catchall for when a connection isn't being tracking anywhere else) so
I'm still looking to weird freeing.

Anyway. It looks like we have a few issues:

1). The conntrack code needs to be looked at for namespaces. I have som=
e
work in progress patches for hashing I can send along later. But that's
just a start really for someone who knows that piece a little better.

2). Some other weird memory corruption of that specific address. Most o=
f
the other people who've had this problem don't have dumps or kgdb.

Jon.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
