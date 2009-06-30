From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 30 Jun 2009 13:14:20 +0200
Message-ID: <4A49F38C.80104@gmail.com>
References: <20090630103642.GB9657@jolsa.lab.eng.brq.redhat.com> <20090630104106.GD9657@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org, eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35349 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbZF3LOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 07:14:43 -0400
In-Reply-To: <20090630104106.GD9657@jolsa.lab.eng.brq.redhat.com>
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
> index a12df10..0d57e83 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1277,7 +1277,7 @@ static inline void sock_poll_wait(struct file *=
filp,
>  		 *
>  		 * This memory barrier is paired in the sk_has_sleeper.
>  		*/
> -		smp_mb();
> +		smp_mb__after_lock();
>  	}
>  }

I believe you took wrong point to use this new thing :)

It was meant to be used in sk_has_sleeper() only (as sk_has_sleeper()
 follows a read_lock())

