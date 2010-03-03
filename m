From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/8] net: add limit for socket backlog
Date: Wed, 03 Mar 2010 07:54:29 +0100
Message-ID: <1267599269.2839.84.camel@edumazet-laptop>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:38149 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754608Ab0CCGyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 01:54:36 -0500
Received: by bwz4 with SMTP id 4so763942bwz.28
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 22:54:35 -0800 (PST)
In-Reply-To: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 14:35 +0800, Zhu Yi a =C3=A9crit :
> We got system OOM while running some UDP netperf testing on the loopb=
ack
> device. The case is multiple senders sent stream UDP packets to a sin=
gle
> receiver via loopback on local host. Of course, the receiver is not a=
ble
> to handle all the packets in time. But we surprisingly found that the=
se
> packets were not discarded due to the receiver's sk->sk_rcvbuf limit.
> Instead, they are kept queuing to sk->sk_backlog and finally ate up a=
ll
> the memory. We believe this is a secure hole that a none privileged u=
ser
> can crash the system.
>=20
> The root cause for this problem is, when the receiver is doing
> __release_sock() (i.e. after userspace recv, kernel udp_recvmsg ->
> skb_free_datagram_locked -> release_sock), it moves skbs from backlog=
 to
> sk_receive_queue with the softirq enabled. In the above case, multipl=
e
> busy senders will almost make it an endless loop. The skbs in the
> backlog end up eat all the system memory.
>=20
> The issue is not only for UDP. Any protocols using socket backlog is
> potentially affected. The patch adds limit for socket backlog so that
> the backlog size cannot be expanded endlessly.
>=20
> Reported-by: Alex Shi <alex.shi@intel.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru
> Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Cc: Per Liden <per.liden@ericsson.com>
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Allan Stephens <allan.stephens@windriver.com>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>

Your SOB should be before mine, you are the main author of this patch, =
I
am a contributor

> ---
>  include/net/sock.h |   17 +++++++++++++++--
>  net/core/sock.c    |   15 +++++++++++++--
>  2 files changed, 28 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 6cb1676..847119a 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -253,6 +253,8 @@ struct sock {
>  	struct {
>  		struct sk_buff *head;
>  		struct sk_buff *tail;
> +		int len;
> +		int limit;

This new limit field is really not needed

>  	} sk_backlog;
>  	wait_queue_head_t	*sk_sleep;
>  	struct dst_entry	*sk_dst_cache;
> @@ -589,8 +591,8 @@ static inline int sk_stream_memory_free(struct so=
ck *sk)
>  	return sk->sk_wmem_queued < sk->sk_sndbuf;
>  }
> =20
> -/* The per-socket spinlock must be held here. */
> -static inline void sk_add_backlog(struct sock *sk, struct sk_buff *s=
kb)
> +/* OOB backlog add */
> +static inline void __sk_add_backlog(struct sock *sk, struct sk_buff =
*skb)
>  {
>  	if (!sk->sk_backlog.tail) {
>  		sk->sk_backlog.head =3D sk->sk_backlog.tail =3D skb;
> @@ -601,6 +603,17 @@ static inline void sk_add_backlog(struct sock *s=
k, struct sk_buff *skb)
>  	skb->next =3D NULL;
>  }
> =20
> +/* The per-socket spinlock must be held here. */
> +static inline int sk_add_backlog(struct sock *sk, struct sk_buff *sk=
b)
> +{
> +	if (sk->sk_backlog.len >=3D max(sk->sk_backlog.limit, sk->sk_rcvbuf=
 >> 1))
> +		return -ENOBUFS;
> +
> +	__sk_add_backlog(sk, skb);
> +	sk->sk_backlog.len +=3D skb->truesize;
> +	return 0;
> +}
> +

Ouch, this patch breaks bisection, since all protocols currently ignore
-ENOBUFS value and dont free skb

If you split your work on several patches, you still have to make
resulting kernels usable.

>  static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *sk=
b)
>  {
>  	return sk->sk_backlog_rcv(sk, skb);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index fcd397a..fa042bc 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -340,8 +340,12 @@ int sk_receive_skb(struct sock *sk, struct sk_bu=
ff *skb, const int nested)
>  		rc =3D sk_backlog_rcv(sk, skb);
> =20
>  		mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
> -	} else
> -		sk_add_backlog(sk, skb);
> +	} else if (sk_add_backlog(sk, skb)) {
> +		bh_unlock_sock(sk);
> +		atomic_inc(&sk->sk_drops);
> +		goto discard_and_relse;
> +	}
> +
>  	bh_unlock_sock(sk);
>  out:
>  	sock_put(sk);
> @@ -1139,6 +1142,7 @@ struct sock *sk_clone(const struct sock *sk, co=
nst gfp_t priority)
>  		sock_lock_init(newsk);
>  		bh_lock_sock(newsk);
>  		newsk->sk_backlog.head	=3D newsk->sk_backlog.tail =3D NULL;
> +		newsk->sk_backlog.len =3D 0;
> =20
>  		atomic_set(&newsk->sk_rmem_alloc, 0);
>  		/*
> @@ -1542,6 +1546,12 @@ static void __release_sock(struct sock *sk)
> =20
>  		bh_lock_sock(sk);
>  	} while ((skb =3D sk->sk_backlog.head) !=3D NULL);
> +
> +	/*
> +	 * Doing the zeroing here guarantee we can not loop forever
> +	 * while a wild producer attempts to flood us.
> +	 */
> +	sk->sk_backlog.len =3D 0;
>  }
> =20
>  /**
> @@ -1874,6 +1884,7 @@ void sock_init_data(struct socket *sock, struct=
 sock *sk)
>  	sk->sk_allocation	=3D	GFP_KERNEL;
>  	sk->sk_rcvbuf		=3D	sysctl_rmem_default;
>  	sk->sk_sndbuf		=3D	sysctl_wmem_default;
> +	sk->sk_backlog.limit	=3D	sk->sk_rcvbuf >> 1;

Didnt we agreed to use sk_>rcvbuf << 1  in previous round ?

>  	sk->sk_state		=3D	TCP_CLOSE;
>  	sk_set_socket(sk, sock);
> =20



