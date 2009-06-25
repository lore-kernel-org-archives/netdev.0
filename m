From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: race in receive part
Date: Thu, 25 Jun 2009 12:28:50 +0200
Message-ID: <4A435162.90109@gmail.com>
References: <20090618102727.GC3782@jolsa.lab.eng.brq.redhat.com> <4A3A49F2.6060705@gmail.com> <20090623091257.GA4850@jolsa.lab.eng.brq.redhat.com> <4A40AF2A.3050509@gmail.com> <20090624102038.GA5409@jolsa.lab.eng.brq.redhat.com> <4A42082D.9060402@gmail.com> <20090624162112.GB5409@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47683 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbZFYK3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 06:29:24 -0400
In-Reply-To: <20090624162112.GB5409@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa a =C3=A9crit :
>=20
> I made the modification, plz check the attached diff.
>=20
> I found some places where the read_lock is not ahead of the check:
>   "if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))"
>=20
> I'm not sure we dont want to address those as well; located in follow=
ing
> files:
>         drivers/net/tun.c
>         net/core/stream.c
>         net/sctp/socket.c
>         net/sunrpc/svcsock.c

We'll take care of them later :)

>=20
>=20
> thanks,
> jirka
>=20

This patch is OK with me, please submit a new formal patch with
fresh ChangeLog so that we can all agree and Signed-off-by/Acked-by

Oleg, I think your comment can be addressed in a followup patch ?

Thanks to all

>=20
> diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm/s=
pinlock.h
> index b7e5db8..570c0ff 100644
> --- a/arch/x86/include/asm/spinlock.h
> +++ b/arch/x86/include/asm/spinlock.h
> @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(raw_rwlock_=
t *rw)
>  #define _raw_read_relax(lock)	cpu_relax()
>  #define _raw_write_relax(lock)	cpu_relax()
> =20
> +/* The read_lock() on x86 is a full memory barrier. */
> +#define smp_mb__after_read_lock() barrier()
> +
>  #endif /* _ASM_X86_SPINLOCK_H */
> diff --git a/fs/select.c b/fs/select.c
> index d870237..cf5d80b 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -219,6 +219,10 @@ static void __pollwait(struct file *filp, wait_q=
ueue_head_t *wait_address,
>  	init_waitqueue_func_entry(&entry->wait, pollwake);
>  	entry->wait.private =3D pwq;
>  	add_wait_queue(wait_address, &entry->wait);
> +
> +	/* This memory barrier is paired with the smp_mb__after_read_lock
> +	 * in the sk_has_sleeper. */
> +	smp_mb();
>  }
> =20
>  int poll_schedule_timeout(struct poll_wqueues *pwq, int state,
> diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
> index 252b245..dd28726 100644
> --- a/include/linux/spinlock.h
> +++ b/include/linux/spinlock.h
> @@ -132,6 +132,11 @@ do {								\
>  #endif /*__raw_spin_is_contended*/
>  #endif
> =20
> +/* The read_lock does not imply full memory barrier. */
> +#ifndef smp_mb__after_read_lock
> +#define smp_mb__after_read_lock() smp_mb()
> +#endif
> +
>  /**
>   * spin_unlock_wait - wait until the spinlock gets unlocked
>   * @lock: the spinlock in question.
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 07133c5..a02a956 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1241,6 +1241,24 @@ static inline int sk_has_allocations(const str=
uct sock *sk)
>  	return sk_wmem_alloc_get(sk) || sk_rmem_alloc_get(sk);
>  }
> =20
> +/**
> + * sk_has_sleeper - check if there are any waiting processes
> + * @sk: socket
> + *
> + * Returns true if socket has waiting processes
> + */
> +static inline int sk_has_sleeper(struct sock *sk)
> +{
> +	/*
> +	 * We need to be sure we are in sync with the
> +	 * add_wait_queue modifications to the wait queue.
> +	 *
> +	 * This memory barrier is paired in the __pollwait.
> +	 */
> +	smp_mb__after_read_lock();
> +	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
> +}
> +
>  /*
>   * 	Queue a received datagram if it will fit. Stream and sequenced
>   *	protocols can't normally use this as they need to fit buffers in
> diff --git a/net/atm/common.c b/net/atm/common.c
> index c1c9793..67a8642 100644
> --- a/net/atm/common.c
> +++ b/net/atm/common.c
> @@ -92,7 +92,7 @@ static void vcc_sock_destruct(struct sock *sk)
>  static void vcc_def_wakeup(struct sock *sk)
>  {
>  	read_lock(&sk->sk_callback_lock);
> -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +	if (sk_has_sleeper(sk))
>  		wake_up(sk->sk_sleep);
>  	read_unlock(&sk->sk_callback_lock);
>  }
> @@ -110,7 +110,7 @@ static void vcc_write_space(struct sock *sk)
>  	read_lock(&sk->sk_callback_lock);
> =20
>  	if (vcc_writable(sk)) {
> -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +		if (sk_has_sleeper(sk))
>  			wake_up_interruptible(sk->sk_sleep);
> =20
>  		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index b0ba569..6354863 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1715,7 +1715,7 @@ EXPORT_SYMBOL(sock_no_sendpage);
>  static void sock_def_wakeup(struct sock *sk)
>  {
>  	read_lock(&sk->sk_callback_lock);
> -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +	if (sk_has_sleeper(sk))
>  		wake_up_interruptible_all(sk->sk_sleep);
>  	read_unlock(&sk->sk_callback_lock);
>  }
> @@ -1723,7 +1723,7 @@ static void sock_def_wakeup(struct sock *sk)
>  static void sock_def_error_report(struct sock *sk)
>  {
>  	read_lock(&sk->sk_callback_lock);
> -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +	if (sk_has_sleeper(sk))
>  		wake_up_interruptible_poll(sk->sk_sleep, POLLERR);
>  	sk_wake_async(sk, SOCK_WAKE_IO, POLL_ERR);
>  	read_unlock(&sk->sk_callback_lock);
> @@ -1732,7 +1732,7 @@ static void sock_def_error_report(struct sock *=
sk)
>  static void sock_def_readable(struct sock *sk, int len)
>  {
>  	read_lock(&sk->sk_callback_lock);
> -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +	if (sk_has_sleeper(sk))
>  		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN |
>  						POLLRDNORM | POLLRDBAND);
>  	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
> @@ -1747,7 +1747,7 @@ static void sock_def_write_space(struct sock *s=
k)
>  	 * progress.  --DaveM
>  	 */
>  	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) {
> -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +		if (sk_has_sleeper(sk))
>  			wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT |
>  						POLLWRNORM | POLLWRBAND);
> =20
> diff --git a/net/dccp/output.c b/net/dccp/output.c
> index c0e88c1..c96119f 100644
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -196,7 +196,7 @@ void dccp_write_space(struct sock *sk)
>  {
>  	read_lock(&sk->sk_callback_lock);
> =20
> -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +	if (sk_has_sleeper(sk))
>  		wake_up_interruptible(sk->sk_sleep);
>  	/* Should agree with poll, otherwise some programs break */
>  	if (sock_writeable(sk))
> diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
> index 6be5f92..ba0149d 100644
> --- a/net/iucv/af_iucv.c
> +++ b/net/iucv/af_iucv.c
> @@ -306,7 +306,7 @@ static inline int iucv_below_msglim(struct sock *=
sk)
>  static void iucv_sock_wake_msglim(struct sock *sk)
>  {
>  	read_lock(&sk->sk_callback_lock);
> -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +	if (sk_has_sleeper(sk))
>  		wake_up_interruptible_all(sk->sk_sleep);
>  	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
>  	read_unlock(&sk->sk_callback_lock);
> diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
> index eac5e7b..60e0e38 100644
> --- a/net/rxrpc/af_rxrpc.c
> +++ b/net/rxrpc/af_rxrpc.c
> @@ -63,7 +63,7 @@ static void rxrpc_write_space(struct sock *sk)
>  	_enter("%p", sk);
>  	read_lock(&sk->sk_callback_lock);
>  	if (rxrpc_writable(sk)) {
> -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +		if (sk_has_sleeper(sk))
>  			wake_up_interruptible(sk->sk_sleep);
>  		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
>  	}
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 36d4e44..143143a 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -315,7 +315,7 @@ static void unix_write_space(struct sock *sk)
>  {
>  	read_lock(&sk->sk_callback_lock);
>  	if (unix_writable(sk)) {
> -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +		if (sk_has_sleeper(sk))
>  			wake_up_interruptible_sync(sk->sk_sleep);
>  		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
>  	}
>=20

