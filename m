From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv7 2/2] memory barrier: adding smp_mb__after_lock
Date: Thu, 09 Jul 2009 06:25:55 +0200
Message-ID: <4A557153.8000108@gmail.com>
References: <20090708220717.GB2945@jolsa.redhat.com> <20090708221031.GD2945@jolsa.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mathieu.desnoyers@polymtl.ca,
	mingo@elte.hu, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org, davem@davemloft.net
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55142 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbZGIE02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 00:26:28 -0400
In-Reply-To: <20090708221031.GD2945@jolsa.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa a =E9crit :
> Adding smp_mb__after_lock define to be used as a smp_mb call after
> a lock.
>=20
> Making it nop for x86, since {read|write|spin}_lock() on x86 are
> full memory barriers.
>=20
> wbr,
> jirka
>=20
>=20
> Signed-off-by: Jiri Olsa <jolsa@redhat.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  arch/x86/include/asm/spinlock.h |    4 ++++
>  include/linux/spinlock.h        |    5 +++++
>  include/net/sock.h              |    5 ++++-
>  3 files changed, 13 insertions(+), 1 deletions(-)
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
> index 4eb8409..2c0da92 100644
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
> + * The sk_has_sleeper is always called right after a call to read_lo=
ck, so we
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

