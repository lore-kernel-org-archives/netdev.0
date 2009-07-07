From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 7 Jul 2009 19:28:11 -0400
Message-ID: <20090707232811.GC19217@Krystal>
References: <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <20090707143416.GB11704@redhat.com> <20090707150406.GC7124@Krystal> <20090707154440.GA15605@redhat.com> <1246981815.9777.12.camel@twins> <20090707194533.GB13858@Krystal> <4A53CFDC.6080005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Oleg Nesterov <oleg@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	davidel@xmailserver.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts13-srv.bellnexxia.net ([209.226.175.34]:36829 "EHLO
	tomts13-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755195AbZGGX2P convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 19:28:15 -0400
Content-Disposition: inline
In-Reply-To: <4A53CFDC.6080005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet (eric.dumazet@gmail.com) wrote:
> Mathieu Desnoyers a =E9crit :
> > * Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> >> On Tue, 2009-07-07 at 17:44 +0200, Oleg Nesterov wrote:
> >>> On 07/07, Mathieu Desnoyers wrote:
> >>>> Actually, thinking about it more, to appropriately support x86, =
as well
> >>>> as powerpc, arm and mips, we would need something like:
> >>>>
> >>>> read_lock_smp_mb()
> >>>>
> >>>> Which would be a read_lock with an included memory barrier.
> >>> Then we need read_lock_irq_smp_mb, read_lock_irqsave__smp_mb, wri=
te_lock_xxx,
> >>> otherwise it is not clear why only read_lock() has _smp_mb() vers=
ion.
> >>>
> >>> The same for spin_lock_xxx...
> >> At which time the smp_mb__{before,after}_{un,}lock become attracti=
ve
> >> again.
> >>
> >=20
> > Then having a new __read_lock() (without acquire semantic) which wo=
uld
> > be required to be followed by a smp__mb_after_lock() would make sen=
se. I
> > think this would fit all of x86, powerpc, arm, mips without having =
to
> > create tons of new primitives. Only "simpler" ones that clearly sep=
arate
> > locking from memory barriers.
> >=20
>=20
> Hmm... On x86, read_lock() is :
>=20
> 	lock subl $0x1,(%eax)
> 	jns   .Lok
> 	call	__read_lock_failed
> .Lok:	ret
>=20
>=20
> What would be __read_lock() ? I cant see how it could *not* use lock =
prefix
> actually and or being cheaper...
>=20

(I'll use read_lock_noacquire() instead of __read_lock() because
__read_lock() is already used for low-level primitives and will produce
name clashes. But I recognise that noacquire is just an ugly name.)

Here, a __read_lock_noacquire _must_ be followed by a
smp__mb_after_lock(), and a __read_unlock_norelease() _must_ be
preceded by a smp__mb_before_unlock().

x86 :

#define __read_lock_noacquire	read_lock
/* Assumes all __*_lock_noacquire primitives act as a full smp_mb() */
#define smp__mb_after_lock()

/* Assumes all __*_unlock_norelease primitives act as a full smp_mb() *=
/
#define smp__mb_before_unlock()
#define __read_unlock_norelease	read_unlock

it's that easy :-)


however, on powerpc, we have to stop and think about it a bit more:

quoting http://www.linuxjournal.com/article/8212

"lwsync, or lightweight sync, orders loads with respect to subsequent
loads and stores, and it also orders stores. However, it does not order
stores with respect to subsequent loads. Interestingly enough, the
lwsync instruction enforces the same ordering as does the zSeries and,
coincidentally, the SPARC TSO."

static inline long __read_trylock_noacquire(raw_rwlock_t *rw)
{
        long tmp;

        __asm__ __volatile__(
"1:     lwarx           %0,0,%1\n"
        __DO_SIGN_EXTEND
"       addic.          %0,%0,1\n\
        ble-            2f\n"
        PPC405_ERR77(0,%1)
"       stwcx.          %0,0,%1\n\
        bne-            1b\n\
        /* isync\n\ Removed the isync because following smp_mb (sync
         * instruction) includes a core synchronizing barrier. */
2:"     : "=3D&r" (tmp)
        : "r" (&rw->lock)
        : "cr0", "xer", "memory");

        return tmp;
}

#define smp__mb_after_lock()	smp_mb()


#define smp__mb_before_unlock()	smp_mb()

static inline void __raw_read_unlock_norelease(raw_rwlock_t *rw)
{
        long tmp;

        __asm__ __volatile__(
        "# read_unlock\n\t"
        /* LWSYNC_ON_SMP -------- can be removed, replace by prior
         * smp_mb() */
"1:     lwarx           %0,0,%1\n\
        addic           %0,%0,-1\n"
        PPC405_ERR77(0,%1)
"       stwcx.          %0,0,%1\n\
        bne-            1b"
        : "=3D&r"(tmp)
        : "r"(&rw->lock)
        : "cr0", "xer", "memory");
}

I assume here that lwarx/stwcx pairs for different addresses cannot be
reordered with other pairs. If they can, then we already have a problem
with the current powerpc read lock implementation.

I just wrote this as an example to show how this could become a
performance improvement on architectures different than x86. The code
proposed above comes without warranty and should be tested with care. :=
)

Mathieu

--=20
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE =
9A68
