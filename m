From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 7 Jul 2009 10:01:35 -0400
Message-ID: <20090707140135.GA5506@Krystal>
References: <20090703081219.GE2902@jolsa.lab.eng.brq.redhat.com> <20090703081445.GG2902@jolsa.lab.eng.brq.redhat.com> <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts43.bellnexxia.net ([209.226.175.110]:41921 "EHLO
	tomts43-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755203AbZGGOCj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 10:02:39 -0400
Content-Disposition: inline
In-Reply-To: <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jiri Olsa (jolsa@redhat.com) wrote:
> On Tue, Jul 07, 2009 at 12:18:16PM +0200, Jiri Olsa wrote:
> > On Fri, Jul 03, 2009 at 01:18:48PM +0200, Jiri Olsa wrote:
> > > On Fri, Jul 03, 2009 at 12:25:30PM +0200, Ingo Molnar wrote:
> > > >=20
> > > > * Jiri Olsa <jolsa@redhat.com> wrote:
> > > >=20
> > > > > On Fri, Jul 03, 2009 at 11:24:38AM +0200, Ingo Molnar wrote:
> > > > > >=20
> > > > > > * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > > > >=20
> > > > > > > Ingo Molnar a =E9crit :
> > > > > > > > * Jiri Olsa <jolsa@redhat.com> wrote:
> > > > > > > >=20
> > > > > > > >> +++ b/arch/x86/include/asm/spinlock.h
> > > > > > > >> @@ -302,4 +302,7 @@ static inline void __raw_write_unl=
ock(raw_rwlock_t *rw)
> > > > > > > >>  #define _raw_read_relax(lock)	cpu_relax()
> > > > > > > >>  #define _raw_write_relax(lock)	cpu_relax()
> > > > > > > >> =20
> > > > > > > >> +/* The {read|write|spin}_lock() on x86 are full memor=
y barriers. */
> > > > > > > >> +#define smp_mb__after_lock() do { } while (0)
> > > > > > > >=20
> > > > > > > > Two small stylistic comments, please make this an inlin=
e function:
> > > > > > > >=20
> > > > > > > > static inline void smp_mb__after_lock(void) { }
> > > > > > > > #define smp_mb__after_lock
> > > > > > > >=20
> > > > > > > > (untested)
> > > > > > > >=20
> > > > > > > >> +/* The lock does not imply full memory barrier. */
> > > > > > > >> +#ifndef smp_mb__after_lock
> > > > > > > >> +#define smp_mb__after_lock() smp_mb()
> > > > > > > >> +#endif
> > > > > > > >=20
> > > > > > > > ditto.
> > > > > > > >=20
> > > > > > > > 	Ingo
> > > > > > >=20
> > > > > > > This was following existing implementations of various sm=
p_mb__??? helpers :
> > > > > > >=20
> > > > > > > # grep -4 smp_mb__before_clear_bit include/asm-generic/bi=
tops.h
> > > > > > >=20
> > > > > > > /*
> > > > > > >  * clear_bit may not imply a memory barrier
> > > > > > >  */
> > > > > > > #ifndef smp_mb__before_clear_bit
> > > > > > > #define smp_mb__before_clear_bit()      smp_mb()
> > > > > > > #define smp_mb__after_clear_bit()       smp_mb()
> > > > > > > #endif
> > > > > >=20
> > > > > > Did i mention that those should be fixed too? :-)
> > > > > >=20
> > > > > > 	Ingo
> > > > >=20
> > > > > ok, could I include it in the 2/2 or you prefer separate patc=
h?
> > > >=20
> > > > depends on whether it will regress ;-)
> > > >=20
> > > > If it regresses, it's better to have it separate. If it wont, i=
t can=20
> > > > be included. If unsure, default to the more conservative option=
=2E
> > > >=20
> > > > 	Ingo
> > >=20
> > >=20
> > > how about this..=20
> > > and similar change for smp_mb__before_clear_bit in a separate pat=
ch
> > >=20
> > >=20
> > > diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/a=
sm/spinlock.h
> > > index b7e5db8..4e77853 100644
> > > --- a/arch/x86/include/asm/spinlock.h
> > > +++ b/arch/x86/include/asm/spinlock.h
> > > @@ -302,4 +302,8 @@ static inline void __raw_write_unlock(raw_rwl=
ock_t *rw)
> > >  #define _raw_read_relax(lock)	cpu_relax()
> > >  #define _raw_write_relax(lock)	cpu_relax()
> > > =20
> > > +/* The {read|write|spin}_lock() on x86 are full memory barriers.=
 */
> > > +static inline void smp_mb__after_lock(void) { }
> > > +#define ARCH_HAS_SMP_MB_AFTER_LOCK
> > > +
> > >  #endif /* _ASM_X86_SPINLOCK_H */
> > > diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
> > > index 252b245..4be57ab 100644
> > > --- a/include/linux/spinlock.h
> > > +++ b/include/linux/spinlock.h
> > > @@ -132,6 +132,11 @@ do {								\
> > >  #endif /*__raw_spin_is_contended*/
> > >  #endif
> > > =20
> > > +/* The lock does not imply full memory barrier. */
> > > +#ifndef ARCH_HAS_SMP_MB_AFTER_LOCK
> > > +static inline void smp_mb__after_lock(void) { smp_mb(); }
> > > +#endif
> > > +
> > >  /**
> > >   * spin_unlock_wait - wait until the spinlock gets unlocked
> > >   * @lock: the spinlock in question.
> > > diff --git a/include/net/sock.h b/include/net/sock.h
> > > index 4eb8409..98afcd9 100644
> > > --- a/include/net/sock.h
> > > +++ b/include/net/sock.h
> > > @@ -1271,6 +1271,9 @@ static inline int sk_has_allocations(const =
struct sock *sk)
> > >   * in its cache, and so does the tp->rcv_nxt update on CPU2 side=
=2E  The CPU1
> > >   * could then endup calling schedule and sleep forever if there =
are no more
> > >   * data on the socket.
> > > + *
> > > + * The sk_has_helper is always called right after a call to read=
_lock, so we
> > > + * can use smp_mb__after_lock barrier.
> > >   */
> > >  static inline int sk_has_sleeper(struct sock *sk)
> > >  {
> > > @@ -1280,7 +1283,7 @@ static inline int sk_has_sleeper(struct soc=
k *sk)
> > >  	 *
> > >  	 * This memory barrier is paired in the sock_poll_wait.
> > >  	 */
> > > -	smp_mb();
> > > +	smp_mb__after_lock();
> > >  	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
> > >  }
> > > =20
> >=20
> > any feedback on this?=20
> > I'd send v6 if this way is acceptable..
> >=20
> > thanks,
> > jirka
>=20
> also I checked the smp_mb__before_clear_bit/smp_mb__after_clear_bit a=
nd
> it is used quite extensivelly.
>=20
> I'd prefer to send it in a separate patch, so we can move on with the=
=20
> changes I've sent so far..
>=20

As with any optimization (and this is one that adds a semantic that wil=
l
just grow the memory barrier/locking rule complexity), it should come
with performance benchmarks showing real-life improvements.

Otherwise I'd recommend sticking to smp_mb() if this execution path is
not that critical, or to move to RCU if it's _that_ critical.

A valid argument would be if the data structures protected are so
complex that RCU is out of question but still the few cycles saved by
removing a memory barrier are really significant. And even then, the
proper solution would be more something like a
__read_lock()+smp_mb+smp_mb+__read_unlock(), so we get the performance
improvements on architectures other than x86 as well.

So in all cases, I don't think the smp_mb__after_lock() is the
appropriate solution.

Mathieu

> regards,
> jirka

--=20
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE =
9A68
