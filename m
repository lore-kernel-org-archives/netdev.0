From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv4 2/2] memory barrier: adding smp_mb__after_lock
Date: Thu, 02 Jul 2009 08:53:55 +0200
Message-ID: <4A4C5983.7000501@gmail.com>
References: <20090702063259.GA3429@jolsa.lab.eng.brq.redhat.com> <20090702063624.GC3429@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org, eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53732 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbZGBGy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 02:54:58 -0400
In-Reply-To: <20090702063624.GC3429@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa a =E9crit :
> Adding smp_mb__after_lock define to be used as a smp_mb call after
> a lock. =20
>=20
> Making it nop for x86, since {read|write|spin}_lock() on x86 are=20
> full memory barriers.
>=20
> wbr,
> jirka
>=20
>=20
> Signed-off-by: Jiri Olsa <jolsa@redhat.com>


Maybe we should remind that sk_has_helper() is always called
right after a call to read_lock() as in :

	read_lock(&sk->sk_callback_lock);
	if (sk_has_sleeper(sk))
		wake_up_interruptible_all(sk->sk_sleep);

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Jiri

>=20
> ---
>  arch/x86/include/asm/spinlock.h |    3 +++
>  include/linux/spinlock.h        |    5 +++++
>  include/net/sock.h              |    2 +-
>  3 files changed, 9 insertions(+), 1 deletions(-)
>=20
> diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm/s=
pinlock.h
> index b7e5db8..39ecc5f 100644
> --- a/arch/x86/include/asm/spinlock.h
> +++ b/arch/x86/include/asm/spinlock.h
> @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(raw_rwlock_=
t *rw)
>  #define _raw_read_relax(lock)	cpu_relax()
>  #define _raw_write_relax(lock)	cpu_relax()
> =20
> +/* The {read|write|spin}_lock() on x86 are full memory barriers. */
> +#define smp_mb__after_lock() do { } while (0)
> +
>  #endif /* _ASM_X86_SPINLOCK_H */
> diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
> index 252b245..ae053bd 100644
> --- a/include/linux/spinlock.h
> +++ b/include/linux/spinlock.h
> @@ -132,6 +132,11 @@ do {								\
>  #endif /*__raw_spin_is_contended*/
>  #endif
> =20
> +/* The lock does not imply full memory barrier. */
> +#ifndef smp_mb__after_lock
> +#define smp_mb__after_lock() smp_mb()
> +#endif
> +
>  /**
>   * spin_unlock_wait - wait until the spinlock gets unlocked
>   * @lock: the spinlock in question.
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 4eb8409..b3e96a4 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1280,7 +1280,7 @@ static inline int sk_has_sleeper(struct sock *s=
k)
>  	 *
>  	 * This memory barrier is paired in the sock_poll_wait.
>  	 */
> -	smp_mb();
> +	smp_mb__after_lock();
>  	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
>  }
> =20
> --

