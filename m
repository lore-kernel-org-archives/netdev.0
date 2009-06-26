From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Thu, 25 Jun 2009 18:31:04 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	eric.dumazet@gmail.com, Tejun Heo <htejun@gmail.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:54274 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbZFZBfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 21:35:37 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2F3B03> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Thu, 25 Jun 2009 21:35:21 -0400
In-Reply-To: <20090625122416.GA23613@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Jun 2009, Oleg Nesterov wrote:

> Can't really comment this patch, except this all looks reasonable to me.
> Add more CCs.

While this can work, IMO it'd be cleaner to have the smp_mb() moved from 
fs/select.c to the ->poll() function.
Having a barrier that matches another one in another susbsystem, because 
of the special locking logic of such subsystem, is not too shiny IMHO.




> 
> On 06/25, Jiri Olsa wrote:
> >
> > Adding memory barrier to the __pollwait function paired with
> > receive callbacks.  The smp_mb__after_lock define is added,
> > since {read|write|spin}_lock() on x86 are full memory barriers.
> >
> > The race fires, when following code paths meet, and the tp->rcv_nxt and
> > __add_wait_queue updates stay in CPU caches.
> >
> >
> > CPU1                         CPU2
> >
> > sys_select                   receive packet
> >   ...                        ...
> >   __add_wait_queue           update tp->rcv_nxt
> >   ...                        ...
> >   tp->rcv_nxt check          sock_def_readable
> >   ...                        {
> >   schedule                      ...
> >                                 if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> >                                         wake_up_interruptible(sk->sk_sleep)
> >                                 ...
> >                              }
> >
> > If there was no cache the code would work ok, since the wait_queue and
> > rcv_nxt are opposit to each other.
> >
> > Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either already
> > passed the tp->rcv_nxt check and sleeps, or will get the new value for
> > tp->rcv_nxt and will return with new data mask.
> > In both cases the process (CPU1) is being added to the wait queue, so the
> > waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
> >
> > The bad case is when the __add_wait_queue changes done by CPU1 stay in its
> > cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 will then
> > endup calling schedule and sleep forever if there are no more data on the
> > socket.
> >
> > wbr,
> > jirka
> >
> >
> > Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> >
> > ---
> >  arch/x86/include/asm/spinlock.h |    3 +++
> >  fs/select.c                     |    4 ++++
> >  include/linux/spinlock.h        |    5 +++++
> >  include/net/sock.h              |   18 ++++++++++++++++++
> >  net/atm/common.c                |    4 ++--
> >  net/core/sock.c                 |    8 ++++----
> >  net/dccp/output.c               |    2 +-
> >  net/iucv/af_iucv.c              |    2 +-
> >  net/rxrpc/af_rxrpc.c            |    2 +-
> >  net/unix/af_unix.c              |    2 +-
> >  10 files changed, 40 insertions(+), 10 deletions(-)
> >
> > diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm/spinlock.h
> > index b7e5db8..39ecc5f 100644
> > --- a/arch/x86/include/asm/spinlock.h
> > +++ b/arch/x86/include/asm/spinlock.h
> > @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(raw_rwlock_t *rw)
> >  #define _raw_read_relax(lock)	cpu_relax()
> >  #define _raw_write_relax(lock)	cpu_relax()
> >
> > +/* The {read|write|spin}_lock() on x86 are full memory barriers. */
> > +#define smp_mb__after_lock() do { } while (0)
> > +
> >  #endif /* _ASM_X86_SPINLOCK_H */
> > diff --git a/fs/select.c b/fs/select.c
> > index d870237..c4bd5f0 100644
> > --- a/fs/select.c
> > +++ b/fs/select.c
> > @@ -219,6 +219,10 @@ static void __pollwait(struct file *filp, wait_queue_head_t *wait_address,
> >  	init_waitqueue_func_entry(&entry->wait, pollwake);
> >  	entry->wait.private = pwq;
> >  	add_wait_queue(wait_address, &entry->wait);
> > +
> > +	/* This memory barrier is paired with the smp_mb__after_lock
> > +	 * in the sk_has_sleeper. */
> > +	smp_mb();
> >  }
> >
> >  int poll_schedule_timeout(struct poll_wqueues *pwq, int state,
> > diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
> > index 252b245..ae053bd 100644
> > --- a/include/linux/spinlock.h
> > +++ b/include/linux/spinlock.h
> > @@ -132,6 +132,11 @@ do {								\
> >  #endif /*__raw_spin_is_contended*/
> >  #endif
> >
> > +/* The lock does not imply full memory barrier. */
> > +#ifndef smp_mb__after_lock
> > +#define smp_mb__after_lock() smp_mb()
> > +#endif
> > +
> >  /**
> >   * spin_unlock_wait - wait until the spinlock gets unlocked
> >   * @lock: the spinlock in question.
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 352f06b..7fbb143 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -1241,6 +1241,24 @@ static inline int sk_has_allocations(const struct sock *sk)
> >  	return sk_wmem_alloc_get(sk) || sk_rmem_alloc_get(sk);
> >  }
> >
> > +/**
> > + * sk_has_sleeper - check if there are any waiting processes
> > + * @sk: socket
> > + *
> > + * Returns true if socket has waiting processes
> > + */
> > +static inline int sk_has_sleeper(struct sock *sk)
> > +{
> > +	/*
> > +	 * We need to be sure we are in sync with the
> > +	 * add_wait_queue modifications to the wait queue.
> > +	 *
> > +	 * This memory barrier is paired in the __pollwait.
> > +	 */
> > +	smp_mb__after_lock();
> > +	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
> > +}
> > +
> >  /*
> >   * 	Queue a received datagram if it will fit. Stream and sequenced
> >   *	protocols can't normally use this as they need to fit buffers in
> > diff --git a/net/atm/common.c b/net/atm/common.c
> > index c1c9793..67a8642 100644
> > --- a/net/atm/common.c
> > +++ b/net/atm/common.c
> > @@ -92,7 +92,7 @@ static void vcc_sock_destruct(struct sock *sk)
> >  static void vcc_def_wakeup(struct sock *sk)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> > -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +	if (sk_has_sleeper(sk))
> >  		wake_up(sk->sk_sleep);
> >  	read_unlock(&sk->sk_callback_lock);
> >  }
> > @@ -110,7 +110,7 @@ static void vcc_write_space(struct sock *sk)
> >  	read_lock(&sk->sk_callback_lock);
> >
> >  	if (vcc_writable(sk)) {
> > -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +		if (sk_has_sleeper(sk))
> >  			wake_up_interruptible(sk->sk_sleep);
> >
> >  		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index b0ba569..6354863 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1715,7 +1715,7 @@ EXPORT_SYMBOL(sock_no_sendpage);
> >  static void sock_def_wakeup(struct sock *sk)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> > -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +	if (sk_has_sleeper(sk))
> >  		wake_up_interruptible_all(sk->sk_sleep);
> >  	read_unlock(&sk->sk_callback_lock);
> >  }
> > @@ -1723,7 +1723,7 @@ static void sock_def_wakeup(struct sock *sk)
> >  static void sock_def_error_report(struct sock *sk)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> > -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +	if (sk_has_sleeper(sk))
> >  		wake_up_interruptible_poll(sk->sk_sleep, POLLERR);
> >  	sk_wake_async(sk, SOCK_WAKE_IO, POLL_ERR);
> >  	read_unlock(&sk->sk_callback_lock);
> > @@ -1732,7 +1732,7 @@ static void sock_def_error_report(struct sock *sk)
> >  static void sock_def_readable(struct sock *sk, int len)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> > -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +	if (sk_has_sleeper(sk))
> >  		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN |
> >  						POLLRDNORM | POLLRDBAND);
> >  	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
> > @@ -1747,7 +1747,7 @@ static void sock_def_write_space(struct sock *sk)
> >  	 * progress.  --DaveM
> >  	 */
> >  	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
> > -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +		if (sk_has_sleeper(sk))
> >  			wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT |
> >  						POLLWRNORM | POLLWRBAND);
> >
> > diff --git a/net/dccp/output.c b/net/dccp/output.c
> > index c0e88c1..c96119f 100644
> > --- a/net/dccp/output.c
> > +++ b/net/dccp/output.c
> > @@ -196,7 +196,7 @@ void dccp_write_space(struct sock *sk)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> >
> > -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +	if (sk_has_sleeper(sk))
> >  		wake_up_interruptible(sk->sk_sleep);
> >  	/* Should agree with poll, otherwise some programs break */
> >  	if (sock_writeable(sk))
> > diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
> > index 6be5f92..ba0149d 100644
> > --- a/net/iucv/af_iucv.c
> > +++ b/net/iucv/af_iucv.c
> > @@ -306,7 +306,7 @@ static inline int iucv_below_msglim(struct sock *sk)
> >  static void iucv_sock_wake_msglim(struct sock *sk)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> > -	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +	if (sk_has_sleeper(sk))
> >  		wake_up_interruptible_all(sk->sk_sleep);
> >  	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
> >  	read_unlock(&sk->sk_callback_lock);
> > diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
> > index eac5e7b..60e0e38 100644
> > --- a/net/rxrpc/af_rxrpc.c
> > +++ b/net/rxrpc/af_rxrpc.c
> > @@ -63,7 +63,7 @@ static void rxrpc_write_space(struct sock *sk)
> >  	_enter("%p", sk);
> >  	read_lock(&sk->sk_callback_lock);
> >  	if (rxrpc_writable(sk)) {
> > -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +		if (sk_has_sleeper(sk))
> >  			wake_up_interruptible(sk->sk_sleep);
> >  		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
> >  	}
> > diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> > index 36d4e44..143143a 100644
> > --- a/net/unix/af_unix.c
> > +++ b/net/unix/af_unix.c
> > @@ -315,7 +315,7 @@ static void unix_write_space(struct sock *sk)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> >  	if (unix_writable(sk)) {
> > -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > +		if (sk_has_sleeper(sk))
> >  			wake_up_interruptible_sync(sk->sk_sleep);
> >  		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
> >  	}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


- Davide


