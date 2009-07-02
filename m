From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv4 1/2] net: adding memory barrier to the poll and receive
 callbacks
Date: Thu, 02 Jul 2009 08:55:57 +0200
Message-ID: <4A4C59FD.6080408@gmail.com>
References: <20090702063259.GA3429@jolsa.lab.eng.brq.redhat.com> <20090702063509.GB3429@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53738 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698AbZGBG4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 02:56:12 -0400
In-Reply-To: <20090702063509.GB3429@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa a =E9crit :
> Adding memory barrier after the poll_wait function, paired with
> receive callbacks. Adding fuctions sock_poll_wait and sock_has_sleepe=
r
> to wrap the memory barrier.
>=20
> Without the memory barrier, following race can happen.
> The race fires, when following code paths meet, and the tp->rcv_nxt=20
> and __add_wait_queue updates stay in CPU caches.
>=20
>=20
> CPU1                         CPU2
>=20
> sys_select                   receive packet
>   ...                        ...
>   __add_wait_queue           update tp->rcv_nxt
>   ...                        ...
>   tp->rcv_nxt check          sock_def_readable
>   ...                        {
>   schedule                      ...
>                                 if (sk->sk_sleep && waitqueue_active(=
sk->sk_sleep))
>                                         wake_up_interruptible(sk->sk_=
sleep)
>                                 ...
>                              }
>=20
> If there was no cache the code would work ok, since the wait_queue an=
d
> rcv_nxt are opposit to each other.
>=20
> Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either alr=
eady
> passed the tp->rcv_nxt check and sleeps, or will get the new value fo=
r
> tp->rcv_nxt and will return with new data mask.
> In both cases the process (CPU1) is being added to the wait queue, so=
 the
> waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
>=20
> The bad case is when the __add_wait_queue changes done by CPU1 stay i=
n its
> cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 wil=
l then
> endup calling schedule and sleep forever if there are no more data on=
 the
> socket.
>=20
>=20
> Calls to poll_wait in following modules were ommited:
> 	net/bluetooth/af_bluetooth.c
> 	net/irda/af_irda.c
> 	net/irda/irnet/irnet_ppp.c
> 	net/mac80211/rc80211_pid_debugfs.c
> 	net/phonet/socket.c
> 	net/rds/af_rds.c
> 	net/rfkill/core.c
> 	net/sunrpc/cache.c
> 	net/sunrpc/rpc_pipe.c
> 	net/tipc/socket.c
>=20
> wbr,
> jirka
>=20
>=20
> Signed-off-by: Jiri Olsa <jolsa@redhat.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Jiri
>=20
> ---
>  include/net/sock.h   |   66 ++++++++++++++++++++++++++++++++++++++++=
++++++++++
>  net/atm/common.c     |    6 ++--
>  net/core/datagram.c  |    2 +-
>  net/core/sock.c      |    8 +++---
>  net/dccp/output.c    |    2 +-
>  net/dccp/proto.c     |    2 +-
>  net/ipv4/tcp.c       |    2 +-
>  net/iucv/af_iucv.c   |    4 +-
>  net/rxrpc/af_rxrpc.c |    4 +-
>  net/unix/af_unix.c   |    8 +++---
>  10 files changed, 85 insertions(+), 19 deletions(-)
>=20
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 352f06b..4eb8409 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -54,6 +54,7 @@
> =20
>  #include <linux/filter.h>
>  #include <linux/rculist_nulls.h>
> +#include <linux/poll.h>
> =20
>  #include <asm/atomic.h>
>  #include <net/dst.h>
> @@ -1241,6 +1242,71 @@ static inline int sk_has_allocations(const str=
uct sock *sk)
>  	return sk_wmem_alloc_get(sk) || sk_rmem_alloc_get(sk);
>  }
> =20
> +/**
> + * sk_has_sleeper - check if there are any waiting processes
> + * @sk: socket
> + *
> + * Returns true if socket has waiting processes
> + *
> + * The purpose of the sk_has_sleeper and sock_poll_wait is to wrap t=
he memory
> + * barrier call. They were added due to the race found within the tc=
p code.
> + *
> + * Consider following tcp code paths:
> + *
> + * CPU1                  CPU2
> + *
> + * sys_select            receive packet
> + *   ...                 ...
> + *   __add_wait_queue    update tp->rcv_nxt
> + *   ...                 ...
> + *   tp->rcv_nxt check   sock_def_readable
> + *   ...                 {
> + *   schedule               ...
> + *                          if (sk->sk_sleep && waitqueue_active(sk-=
>sk_sleep))
> + *                              wake_up_interruptible(sk->sk_sleep)
> + *                          ...
> + *                       }
> + *
> + * The race for tcp fires when the __add_wait_queue changes done by =
CPU1 stay
> + * in its cache, and so does the tp->rcv_nxt update on CPU2 side.  T=
he CPU1
> + * could then endup calling schedule and sleep forever if there are =
no more
> + * data on the socket.
> + */
> +static inline int sk_has_sleeper(struct sock *sk)
> +{
> +	/*
> +	 * We need to be sure we are in sync with the
> +	 * add_wait_queue modifications to the wait queue.
> +	 *
> +	 * This memory barrier is paired in the sock_poll_wait.
> +	 */
> +	smp_mb();
> +	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
> +}
> +
> +/**
> + * sock_poll_wait - place memory barrier behind the poll_wait call.
> + * @filp:           file
> + * @wait_address:   socket wait queue
> + * @p:              poll_table
> + *
> + * See the comments in the sk_has_sleeper function.
> + */
> +static inline void sock_poll_wait(struct file *filp,
> +		wait_queue_head_t *wait_address, poll_table *p)
> +{
> +	if (p && wait_address) {
> +		poll_wait(filp, wait_address, p);
> +		/*
> +		 * We need to be sure we are in sync with the
> +		 * socket flags modification.
> +		 *
> +		 * This memory barrier is paired in the sk_has_sleeper.
> +		*/
> +		smp_mb();
> +	}
> +}
> +
>  /*
>   * 	Queue a received datagram if it will fit. Stream and sequenced
>   *	protocols can't normally use this as they need to fit buffers in
> diff --git a/net/atm/common.c b/net/atm/common.c
> index c1c9793..8c4d843 100644
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
> @@ -594,7 +594,7 @@ unsigned int vcc_poll(struct file *file, struct s=
ocket *sock, poll_table *wait)
>  	struct atm_vcc *vcc;
>  	unsigned int mask;
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
>  	mask =3D 0;
> =20
>  	vcc =3D ATM_SD(sock);
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 58abee1..b0fe692 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -712,7 +712,7 @@ unsigned int datagram_poll(struct file *file, str=
uct socket *sock,
>  	struct sock *sk =3D sock->sk;
>  	unsigned int mask;
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
>  	mask =3D 0;
> =20
>  	/* exceptional events? */
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
> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> index 314a1b5..94ca8ea 100644
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -311,7 +311,7 @@ unsigned int dccp_poll(struct file *file, struct =
socket *sock,
>  	unsigned int mask;
>  	struct sock *sk =3D sock->sk;
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
>  	if (sk->sk_state =3D=3D DCCP_LISTEN)
>  		return inet_csk_listen_poll(sk);
> =20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 7870a53..9114524 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -339,7 +339,7 @@ unsigned int tcp_poll(struct file *file, struct s=
ocket *sock, poll_table *wait)
>  	struct sock *sk =3D sock->sk;
>  	struct tcp_sock *tp =3D tcp_sk(sk);
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
>  	if (sk->sk_state =3D=3D TCP_LISTEN)
>  		return inet_csk_listen_poll(sk);
> =20
> diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
> index 6be5f92..49c15b4 100644
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
> @@ -1256,7 +1256,7 @@ unsigned int iucv_sock_poll(struct file *file, =
struct socket *sock,
>  	struct sock *sk =3D sock->sk;
>  	unsigned int mask =3D 0;
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
> =20
>  	if (sk->sk_state =3D=3D IUCV_LISTEN)
>  		return iucv_accept_poll(sk);
> diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
> index eac5e7b..bfe493e 100644
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
> @@ -588,7 +588,7 @@ static unsigned int rxrpc_poll(struct file *file,=
 struct socket *sock,
>  	unsigned int mask;
>  	struct sock *sk =3D sock->sk;
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
>  	mask =3D 0;
> =20
>  	/* the socket is readable if there are any messages waiting on the =
Rx
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 36d4e44..fc3ebb9 100644
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
> @@ -1985,7 +1985,7 @@ static unsigned int unix_poll(struct file *file=
, struct socket *sock, poll_table
>  	struct sock *sk =3D sock->sk;
>  	unsigned int mask;
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
>  	mask =3D 0;
> =20
>  	/* exceptional events? */
> @@ -2022,7 +2022,7 @@ static unsigned int unix_dgram_poll(struct file=
 *file, struct socket *sock,
>  	struct sock *sk =3D sock->sk, *other;
>  	unsigned int mask, writable;
> =20
> -	poll_wait(file, sk->sk_sleep, wait);
> +	sock_poll_wait(file, sk->sk_sleep, wait);
>  	mask =3D 0;
> =20
>  	/* exceptional events? */
> @@ -2053,7 +2053,7 @@ static unsigned int unix_dgram_poll(struct file=
 *file, struct socket *sock,
>  		other =3D unix_peer_get(sk);
>  		if (other) {
>  			if (unix_peer(other) !=3D sk) {
> -				poll_wait(file, &unix_sk(other)->peer_wait,
> +				sock_poll_wait(file, &unix_sk(other)->peer_wait,
>  					  wait);
>  				if (unix_recvq_full(other))
>  					writable =3D 0;

