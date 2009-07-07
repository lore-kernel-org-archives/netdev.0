From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 7 Jul 2009 12:18:16 +0200
Message-ID: <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com>
References: <20090703081219.GE2902@jolsa.lab.eng.brq.redhat.com> <20090703081445.GG2902@jolsa.lab.eng.brq.redhat.com> <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55410 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbZGGKSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 06:18:38 -0400
Content-Disposition: inline
In-Reply-To: <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 03, 2009 at 01:18:48PM +0200, Jiri Olsa wrote:
> On Fri, Jul 03, 2009 at 12:25:30PM +0200, Ingo Molnar wrote:
> >=20
> > * Jiri Olsa <jolsa@redhat.com> wrote:
> >=20
> > > On Fri, Jul 03, 2009 at 11:24:38AM +0200, Ingo Molnar wrote:
> > > >=20
> > > > * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > >=20
> > > > > Ingo Molnar a =E9crit :
> > > > > > * Jiri Olsa <jolsa@redhat.com> wrote:
> > > > > >=20
> > > > > >> +++ b/arch/x86/include/asm/spinlock.h
> > > > > >> @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(=
raw_rwlock_t *rw)
> > > > > >>  #define _raw_read_relax(lock)	cpu_relax()
> > > > > >>  #define _raw_write_relax(lock)	cpu_relax()
> > > > > >> =20
> > > > > >> +/* The {read|write|spin}_lock() on x86 are full memory ba=
rriers. */
> > > > > >> +#define smp_mb__after_lock() do { } while (0)
> > > > > >=20
> > > > > > Two small stylistic comments, please make this an inline fu=
nction:
> > > > > >=20
> > > > > > static inline void smp_mb__after_lock(void) { }
> > > > > > #define smp_mb__after_lock
> > > > > >=20
> > > > > > (untested)
> > > > > >=20
> > > > > >> +/* The lock does not imply full memory barrier. */
> > > > > >> +#ifndef smp_mb__after_lock
> > > > > >> +#define smp_mb__after_lock() smp_mb()
> > > > > >> +#endif
> > > > > >=20
> > > > > > ditto.
> > > > > >=20
> > > > > > 	Ingo
> > > > >=20
> > > > > This was following existing implementations of various smp_mb=
__??? helpers :
> > > > >=20
> > > > > # grep -4 smp_mb__before_clear_bit include/asm-generic/bitops=
=2Eh
> > > > >=20
> > > > > /*
> > > > >  * clear_bit may not imply a memory barrier
> > > > >  */
> > > > > #ifndef smp_mb__before_clear_bit
> > > > > #define smp_mb__before_clear_bit()      smp_mb()
> > > > > #define smp_mb__after_clear_bit()       smp_mb()
> > > > > #endif
> > > >=20
> > > > Did i mention that those should be fixed too? :-)
> > > >=20
> > > > 	Ingo
> > >=20
> > > ok, could I include it in the 2/2 or you prefer separate patch?
> >=20
> > depends on whether it will regress ;-)
> >=20
> > If it regresses, it's better to have it separate. If it wont, it ca=
n=20
> > be included. If unsure, default to the more conservative option.
> >=20
> > 	Ingo
>=20
>=20
> how about this..=20
> and similar change for smp_mb__before_clear_bit in a separate patch
>=20
>=20
> diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm/s=
pinlock.h
> index b7e5db8..4e77853 100644
> --- a/arch/x86/include/asm/spinlock.h
> +++ b/arch/x86/include/asm/spinlock.h
> @@ -302,4 +302,8 @@ static inline void __raw_write_unlock(raw_rwlock_=
t *rw)
>  #define _raw_read_relax(lock)	cpu_relax()
>  #define _raw_write_relax(lock)	cpu_relax()
> =20
> +/* The {read|write|spin}_lock() on x86 are full memory barriers. */
> +static inline void smp_mb__after_lock(void) { }
> +#define ARCH_HAS_SMP_MB_AFTER_LOCK
> +
>  #endif /* _ASM_X86_SPINLOCK_H */
> diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
> index 252b245..4be57ab 100644
> --- a/include/linux/spinlock.h
> +++ b/include/linux/spinlock.h
> @@ -132,6 +132,11 @@ do {								\
>  #endif /*__raw_spin_is_contended*/
>  #endif
> =20
> +/* The lock does not imply full memory barrier. */
> +#ifndef ARCH_HAS_SMP_MB_AFTER_LOCK
> +static inline void smp_mb__after_lock(void) { smp_mb(); }
> +#endif
> +
>  /**
>   * spin_unlock_wait - wait until the spinlock gets unlocked
>   * @lock: the spinlock in question.
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 4eb8409..98afcd9 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1271,6 +1271,9 @@ static inline int sk_has_allocations(const stru=
ct sock *sk)
>   * in its cache, and so does the tp->rcv_nxt update on CPU2 side.  T=
he CPU1
>   * could then endup calling schedule and sleep forever if there are =
no more
>   * data on the socket.
> + *
> + * The sk_has_helper is always called right after a call to read_loc=
k, so we
> + * can use smp_mb__after_lock barrier.
>   */
>  static inline int sk_has_sleeper(struct sock *sk)
>  {
> @@ -1280,7 +1283,7 @@ static inline int sk_has_sleeper(struct sock *s=
k)
>  	 *
>  	 * This memory barrier is paired in the sock_poll_wait.
>  	 */
> -	smp_mb();
> +	smp_mb__after_lock();
>  	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
>  }
> =20

any feedback on this?=20
I'd send v6 if this way is acceptable..

thanks,
jirka
