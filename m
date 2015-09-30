From: Mathias Krause <minipli@googlemail.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Wed, 30 Sep 2015 07:54:29 +0200
Message-ID: <CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
References: <20150913195354.GA12352@jig.fritz.box>
	<20150914023949.GA15012@dcvr.yhbt.net>
	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
	<560AE202.4020402@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560AE202.4020402@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
> However, if we call connect on socket 's', to connect to a new socket 'o2', we
> drop the reference on the original socket 'o'. Thus, we can now close socket
> 'o' without unregistering from epoll. Then, when we either close the ep
> or unregister 'o', we end up with this list corruption. Thus, this is not a
> race per se, but can be triggered sequentially.

Sounds profound, but the reproducers calls connect only once per
socket. So there is no "connect to a new socket", no?
But w/e, see below.

> Linus explains the general case in the context the signalfd stuff here:
> https://lkml.org/lkml/2013/10/14/634

I also found that posting while looking for similar bug reports. Also
found that one: https://lkml.org/lkml/2014/5/15/532

> So this may be the case that we've been chasing here for a while...

That bug triggers since commit 3c73419c09 "af_unix: fix 'poll for
write'/ connected DGRAM sockets". That's v2.6.26-rc7, as noted in the
reproducer.

>
> In any case, we could fix with that same POLLFREE mechansim, the simplest
> would be something like:
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 03ee4d3..d499f81 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -392,6 +392,9 @@ static void unix_sock_destructor(struct sock *sk)
>         pr_debug("UNIX %p is destroyed, %ld are still alive.\n", sk,
>                 atomic_long_read(&unix_nr_socks));
>  #endif
> +       /* make sure we remove from epoll */
> +       wake_up_poll(&u->peer_wait, POLLFREE);
> +       synchronize_sched();
>  }
>
>  static void unix_release_sock(struct sock *sk, int embrion)
>
> I'm not suggesting we apply that, but that fixed the supplied test case.
> We could enhance the above, to avoid the free'ing latency there by doing
> the SLAB_DESTROY_BY_RCU for unix sockets. But I'm not convinced
> that this wouldn't be still broken for select()/poll() as well. I think
> we can be in a select() call for socket 's', and if we remove socket
> 'o' from it in the meantime (by doing a connect() on s to somewhere else
> and a close on 'o'), I think we can still crash there. So POLLFREE would
> have to be extended. I tried to hit this with select() but could not,
> but I think if I tried harder I could.
>
> Instead of going further down that route, perhaps something like below
> might be better. The basic idea would be to do away with the 'other'
> poll call in unix_dgram_poll(), and instead revert back to a registering
> on a single wait queue. We add a new wait queue to unix sockets such
> that we can register it with a remote other on connect(). Then we can
> use the wakeup from the remote to wake up the registered unix socket.
> Probably better explained with the patch below. Note I didn't add to
> the remote for SOCK_STREAM, since the poll() routine there doesn't do
> the double wait queue registering:
>
> diff --git a/include/net/af_unix.h b/include/net/af_unix.h
> index 4a167b3..9698aff 100644
> --- a/include/net/af_unix.h
> +++ b/include/net/af_unix.h
> @@ -62,6 +62,7 @@ struct unix_sock {
>  #define UNIX_GC_CANDIDATE      0
>  #define UNIX_GC_MAYBE_CYCLE    1
>         struct socket_wq        peer_wq;
> +       wait_queue_t            wait;
>  };
>  #define unix_sk(__sk) ((struct unix_sock *)__sk)
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 03ee4d3..9e0692a 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -420,6 +420,8 @@ static void unix_release_sock(struct sock *sk, int embrion)
>         skpair = unix_peer(sk);
>
>         if (skpair != NULL) {
> +               if (sk->sk_type != SOCK_STREAM)
> +                       remove_wait_queue(&unix_sk(skpair)->peer_wait, &u->wait);
>                 if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
>                         unix_state_lock(skpair);
>                         /* No more writes */
> @@ -636,6 +638,16 @@ static struct proto unix_proto = {
>   */
>  static struct lock_class_key af_unix_sk_receive_queue_lock_key;
>
> +static int peer_wake(wait_queue_t *wait, unsigned mode, int sync, void *key)
> +{
> +       struct unix_sock *u;
> +
> +       u = container_of(wait, struct unix_sock, wait);
> +       wake_up_interruptible_sync_poll(sk_sleep(&u->sk), key);
> +
> +       return 0;
> +}
> +
>  static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
>  {
>         struct sock *sk = NULL;
> @@ -664,6 +676,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
>         INIT_LIST_HEAD(&u->link);
>         mutex_init(&u->readlock); /* single task reading lock */
>         init_waitqueue_head(&u->peer_wait);
> +       init_waitqueue_func_entry(&u->wait, peer_wake);
>         unix_insert_socket(unix_sockets_unbound(sk), sk);
>  out:
>         if (sk == NULL)
> @@ -1030,7 +1043,10 @@ restart:
>          */
>         if (unix_peer(sk)) {
>                 struct sock *old_peer = unix_peer(sk);
> +
> +               remove_wait_queue(&unix_sk(old_peer)->peer_wait, &unix_sk(sk)->wait);
>                 unix_peer(sk) = other;
> +               add_wait_queue(&unix_sk(other)->peer_wait, &unix_sk(sk)->wait);
>                 unix_state_double_unlock(sk, other);
>
>                 if (other != old_peer)
> @@ -1038,8 +1054,12 @@ restart:
>                 sock_put(old_peer);
>         } else {
>                 unix_peer(sk) = other;
> +               add_wait_queue(&unix_sk(other)->peer_wait, &unix_sk(sk)->wait);
>                 unix_state_double_unlock(sk, other);
>         }
> +       /* New remote may have created write space for us */
> +       wake_up_interruptible_sync_poll(sk_sleep(sk),
> +                                       POLLOUT | POLLWRNORM | POLLWRBAND);
>         return 0;
>
>  out_unlock:
> @@ -1194,6 +1214,8 @@ restart:
>
>         sock_hold(sk);
>         unix_peer(newsk)        = sk;
> +       if (sk->sk_type == SOCK_SEQPACKET)
> +               add_wait_queue(&unix_sk(sk)->peer_wait, &unix_sk(newsk)->wait);
>         newsk->sk_state         = TCP_ESTABLISHED;
>         newsk->sk_type          = sk->sk_type;
>         init_peercred(newsk);
> @@ -1220,6 +1242,8 @@ restart:
>
>         smp_mb__after_atomic(); /* sock_hold() does an atomic_inc() */
>         unix_peer(sk)   = newsk;
> +       if (sk->sk_type == SOCK_SEQPACKET)
> +               add_wait_queue(&unix_sk(newsk)->peer_wait, &unix_sk(sk)->wait);
>
>         unix_state_unlock(sk);
>
> @@ -1254,6 +1278,10 @@ static int unix_socketpair(struct socket *socka, struct socket *sockb)
>         sock_hold(skb);
>         unix_peer(ska) = skb;
>         unix_peer(skb) = ska;
> +       if (ska->sk_type != SOCK_STREAM) {
> +               add_wait_queue(&unix_sk(ska)->peer_wait, &unix_sk(skb)->wait);
> +               add_wait_queue(&unix_sk(skb)->peer_wait, &unix_sk(ska)->wait);
> +       }
>         init_peercred(ska);
>         init_peercred(skb);
>
> @@ -1565,6 +1593,7 @@ restart:
>                 unix_state_lock(sk);
>                 if (unix_peer(sk) == other) {
>                         unix_peer(sk) = NULL;
> +                       remove_wait_queue(&unix_sk(other)->peer_wait, &u->wait);
>                         unix_state_unlock(sk);
>
>                         unix_dgram_disconnected(sk, other);
> @@ -2441,7 +2470,6 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>         other = unix_peer_get(sk);
>         if (other) {
>                 if (unix_peer(other) != sk) {
> -                       sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
>                         if (unix_recvq_full(other))
>                                 writable = 0;
>                 }
> --
> 1.8.2.rc2
>
>
>
> I think this makes more sense too, b/c it can also get the epoll() case
> correct where the socket s is connected to a new remote. In the old code
> we would continue to get wakeups then from the wrong remote. Here, we
> can fix that as well.
>
> There a perhaps a perfomance issue with this approach, since I'm adding
> to the poll list on connect(). So even if we are not in a poll(), we are
> still walking the list to do wakeups. That may or may not be a big deal,
> and I think can be fixed by setting something like the SOCK_NOSPACE bit
> in the unix_dgram_poll() when its not writeable, and condition the wakeup
> on that. The alternative would be to register with the remote on poll(),
> but then the unregister is more complex...

This one looks good to me. It survived almost 10 hours on a 2 CPU
system where the reproducer was able to trigger the bug within
seconds.

Thanks for fixing this!

> Perhaps, somebody more familiar with the unix socket code can comment
> on this. Thanks for the test case!

Eric Dumazet may have opinions concerning the performance impact. At
least he had in the past...

Regards,
Mathias
