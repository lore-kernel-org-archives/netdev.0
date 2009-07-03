From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 13:31:30 -0400
Message-ID: <20090703173130.GA16089@Krystal>
References: <20090703152951.GA28837@gondor.apana.org.au> <4A4E25BB.8060408@gmail.com> <20090703154700.GD10256@Krystal> <20090703170621.GS8943@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, mingo@elte.hu,
	jolsa@redhat.com, a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	oleg@redhat.com, davidel@xmailserver.org, Paul.McKenney@us.ibm.com
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758487AbZGCRbm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090703170621.GS8943@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> On Fri, Jul 03, 2009 at 11:47:00AM -0400, Mathieu Desnoyers wrote:
> > * Eric Dumazet (eric.dumazet@gmail.com) wrote:
> > > Herbert Xu a =E9crit :
> > > > Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> > > >> Why don't we create a read_lock without acquire semantic inste=
ad (e.g.
> > > >> read_lock_nomb(), or something with a better name like __read_=
lock()) ?
> > > >> On architectures where memory barriers are needed to provide t=
he acquire
> > > >> semantic, it would be faster to do :
> > > >>
> > > >> __read_lock();
> > > >> smp_mb();
> > > >>
> > > >> than :
> > > >>
> > > >> read_lock(); <- e.g. lwsync + isync or something like that
> > > >> smp_mb(); <- full sync.
> > > >=20
> > > > Hmm, why do we even care when read_lock should just die?
> > > >=20
> > > > Cheers,
> > >=20
> > > +1 :)
> > >=20
> > > Do you mean using a spinlock instead or what ?
> > >=20
> >=20
> > I think he meant RCU.
> >=20
> > > Also, how many arches are able to have a true __read_lock()
> > > (or __spin_lock() if that matters), without acquire semantic ?
> >=20
> > At least PowerPC, MIPS, recent ARM, alpha.
>=20
> Are you guys sure you are in agreement about what you all mean by
> "acquire semantics"?
>=20

I use acquire/release semantic with the following meaning :

=2E..
read A
read_unlock()

read B

read_lock();
read C

read_unlock would provide release semantic by disallowing read A to mov=
e
after the read_unlock.

read_lock would provide acquire semantic by disallowing read C to move
before read_lock.

read B is free to move.


> Clearly, any correct __read_lock() implementation must enforce orderi=
ng
> with respect to the most recent __write_unlock(), but this does not
> necesarily imply all possible definitions of "acquire semantics".
>=20

Yes, you are right. We could never remove _all_ memory barriers from
__read_lock()/__read_unlock implementations even if we require somethin=
g
such as :

__read_lock()
smp_mb()

critical section.

smp_mb()
__read_unlock()

Because we also need to guarantee that consecutive unlock/lock won't be
reordered, which implies a barrier _outside_ of the read lock/unlock
atomic operations.

But anyway I'm not sure it's worth trying to optimize rwlocks, given
that for critical sections where the performance hit of a memory barrie=
r
would be perceivable, we should really think about using RCU rather tha=
n
beating this dead horse. :)

Thanks,

Mathieu.


> 							Thanx, Paul

--=20
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE =
9A68
