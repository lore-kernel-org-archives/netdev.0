From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: [PATCH net-next-2.6] net: sk_add_backlog() take rmem_alloc into
 account
Date: Wed, 28 Apr 2010 11:41:12 -0400
Message-ID: <4BD85718.5000404@athenacr.com>
References: <4BD6E887.3000804@athenacr.com>	 <20100427.095108.68126984.davem@davemloft.net>	 <1272388439.2295.369.camel@edumazet-laptop>	 <20100427.102038.57469310.davem@davemloft.net>	 <1272389872.2295.405.camel@edumazet-laptop> <1272399662.2343.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:12908 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754907Ab0D1PlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 11:41:16 -0400
In-Reply-To: <1272399662.2343.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 27 avril 2010 =C3=A0 19:37 +0200, Eric Dumazet a =C3=A9crit =
:
>=20
>> We might use the ticket spinlock paradigm to let writers go in paral=
lel
>> and let the user the socket lock
>>
>> Instead of having the bh_lock_sock() to protect receive_queue *and*
>> backlog, writers get a unique slot in a table, that 'user' can handl=
e
>> later.
>>
>> Or serialize writers (before they try to bh_lock_sock()) with a
>> dedicated lock, so that user has 50% chances to get the sock lock,
>> contending with at most one writer.
>=20
> Following patch fixes the issue for me, with little performance hit o=
n
> fast path.
>=20
> Under huge stress from a multiqueue/RPS enabled NIC, a single flow ud=
p
> receiver can now process ~200.000 pps (instead of ~100 pps before the
> patch) on my dev machine.
>=20
> Thanks !
>=20
> [PATCH net-next-2.6] net: sk_add_backlog() take rmem_alloc into accou=
nt
>=20
> Current socket backlog limit is not enough to really stop DDOS attack=
s,
> because user thread spend many time to process a full backlog each
> round, and user might crazy spin on socket lock.
>=20
> We should add backlog size and receive_queue size (aka rmem_alloc) to
> pace writers, and let user run without being slow down too much.
>=20
> Introduce a sk_rcvqueues_full() helper, to avoid taking socket lock i=
n
> stress situations.
>=20
> Under huge stress from a multiqueue/RPS enabled NIC, a single flow ud=
p
> receiver can now process ~200.000 pps (instead of ~100 pps before the
> patch) on a 8 core machine.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Wow that was awesome.

> ---
>  include/net/sock.h |   13 +++++++++++--
>  net/core/sock.c    |    5 ++++-
>  net/ipv4/udp.c     |    4 ++++
>  net/ipv6/udp.c     |    8 ++++++++
>  4 files changed, 27 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 86a8ca1..4b0097d 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -255,7 +255,6 @@ struct sock {
>  		struct sk_buff *head;
>  		struct sk_buff *tail;
>  		int len;
> -		int limit;
>  	} sk_backlog;
>  	wait_queue_head_t	*sk_sleep;
>  	struct dst_entry	*sk_dst_cache;
> @@ -604,10 +603,20 @@ static inline void __sk_add_backlog(struct sock=
 *sk, struct sk_buff *skb)
>  	skb->next =3D NULL;
>  }
> =20
> +/*
> + * Take into account size of receive queue and backlog queue
> + */
> +static inline bool sk_rcvqueues_full(const struct sock *sk, const st=
ruct sk_buff *skb)
> +{
> +	unsigned int qsize =3D sk->sk_backlog.len + atomic_read(&sk->sk_rme=
m_alloc);
> +
> +	return qsize + skb->truesize > sk->sk_rcvbuf;
> +}
> +

Reading sk_backlog.len without the socket lock held seems to
contradict the comment in sock.h:
  *	@sk_backlog: always used with the per-socket spinlock held
  ...
struct sock {

        ...
	/*
	 * The backlog queue is special, it is always used with
	 * the per-socket spinlock held and requires low latency
	 * access. Therefore we special case it's implementation.
	 */
	struct { ... } sk_backlog;

Is this just a doc mismatch or does sk_backlog.len need to use
atomic_read & atomic_set?

>  /* The per-socket spinlock must be held here. */
>  static inline __must_check int sk_add_backlog(struct sock *sk, struc=
t sk_buff *skb)
>  {
> -	if (sk->sk_backlog.len >=3D max(sk->sk_backlog.limit, sk->sk_rcvbuf=
 << 1))
> +	if (sk_rcvqueues_full(sk, skb))
>  		return -ENOBUFS;
> =20
>  	__sk_add_backlog(sk, skb);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 58ebd14..5104175 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -327,6 +327,10 @@ int sk_receive_skb(struct sock *sk, struct sk_bu=
ff *skb, const int nested)
> =20
>  	skb->dev =3D NULL;
> =20
> +	if (sk_rcvqueues_full(sk, skb)) {
> +		atomic_inc(&sk->sk_drops);
> +		goto discard_and_relse;
> +	}
>  	if (nested)
>  		bh_lock_sock_nested(sk);
>  	else
> @@ -1885,7 +1889,6 @@ void sock_init_data(struct socket *sock, struct=
 sock *sk)
>  	sk->sk_allocation	=3D	GFP_KERNEL;
>  	sk->sk_rcvbuf		=3D	sysctl_rmem_default;
>  	sk->sk_sndbuf		=3D	sysctl_wmem_default;
> -	sk->sk_backlog.limit	=3D	sk->sk_rcvbuf << 1;
>  	sk->sk_state		=3D	TCP_CLOSE;
>  	sk_set_socket(sk, sock);
> =20
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 1e18f9c..776c844 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1372,6 +1372,10 @@ int udp_queue_rcv_skb(struct sock *sk, struct =
sk_buff *skb)
>  			goto drop;
>  	}
> =20
> +
> +	if (sk_rcvqueues_full(sk, skb))
> +		goto drop;
> +
>  	rc =3D 0;
> =20
>  	bh_lock_sock(sk);
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 2850e35..3ead20a 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -584,6 +584,10 @@ static void flush_stack(struct sock **stack, uns=
igned int count,
> =20
>  		sk =3D stack[i];
>  		if (skb1) {
> +			if (sk_rcvqueues_full(sk, skb)) {
> +				kfree_skb(skb1);
> +				goto drop;
> +			}
>  			bh_lock_sock(sk);
>  			if (!sock_owned_by_user(sk))
>  				udpv6_queue_rcv_skb(sk, skb1);
> @@ -759,6 +763,10 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct u=
dp_table *udptable,
> =20
>  	/* deliver */
> =20
> +	if (sk_rcvqueues_full(sk, skb)) {
> +		sock_put(sk);
> +		goto discard;
> +	}
>  	bh_lock_sock(sk);
>  	if (!sock_owned_by_user(sk))
>  		udpv6_queue_rcv_skb(sk, skb);
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

