From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Spurious "TCP: too many of orphaned sockets", unable to
 allocate sockets
Date: Wed, 25 Aug 2010 10:47:37 +0200
Message-ID: <1282726057.2487.1.camel@edumazet-laptop>
References: <20100825071626.GA13681@kryten>
	 <20100825.005929.15250658.davem@davemloft.net>
	 <20100825.012058.116362511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anton@samba.org, netdev@vger.kernel.org, miltonm@bga.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34544 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0HYIrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 04:47:42 -0400
Received: by wyb35 with SMTP id 35so409805wyb.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 01:47:40 -0700 (PDT)
In-Reply-To: <20100825.012058.116362511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 01:20 -0700, David Miller a =C3=A9=
crit :
> From: David Miller <davem@davemloft.net>
> Date: Wed, 25 Aug 2010 00:59:29 -0700 (PDT)
>=20
> > Solution seems simple, if the too many orphan check triggers, simpl=
y
> > redo the check using the expensive but more accurate per-cpu counte=
r
> > read (which avoids the skew) to make sure.
>=20
> Something like this:
>=20
> tcp: Combat per-cpu skew in orphan tests.
>=20
> As reported by Anton Blanchard when we use
> percpu_counter_read_positive() to make our orphan socket limit checks=
,
> the check can be off by up to num_cpus_online() * batch (which is 32
> by default) which on a 128 cpu machine can be as large as the default
> orphan limit itself.
>=20
> Fix this by doing the full expensive sum check if the optimized check
> triggers.
>=20
> Reported-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Very nice !

tcp_too_many_orphans() might be a bit large to still be inlined ...

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


>=20
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index df6a2eb..eaa9582 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -268,11 +268,21 @@ static inline int between(__u32 seq1, __u32 seq=
2, __u32 seq3)
>  	return seq3 - seq2 >=3D seq1 - seq2;
>  }
> =20
> -static inline int tcp_too_many_orphans(struct sock *sk, int num)
> +static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
>  {
> -	return (num > sysctl_tcp_max_orphans) ||
> -		(sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
> -		 atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2]);
> +	struct percpu_counter *ocp =3D sk->sk_prot->orphan_count;
> +	int orphans =3D percpu_counter_read_positive(ocp);
> +
> +	if (orphans << shift > sysctl_tcp_max_orphans) {
> +		orphans =3D percpu_counter_sum_positive(ocp);
> +		if (orphans << shift > sysctl_tcp_max_orphans)
> +			return true;
> +	}
> +
> +	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
> +	    atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
> +		return true;
> +	return false;
>  }
> =20
>  /* syncookies: remember time of last synqueue overflow */
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 176e11a..197b9b7 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2011,11 +2011,8 @@ adjudge_to_death:
>  		}
>  	}
>  	if (sk->sk_state !=3D TCP_CLOSE) {
> -		int orphan_count =3D percpu_counter_read_positive(
> -						sk->sk_prot->orphan_count);
> -
>  		sk_mem_reclaim(sk);
> -		if (tcp_too_many_orphans(sk, orphan_count)) {
> +		if (tcp_too_many_orphans(sk, 0)) {
>  			if (net_ratelimit())
>  				printk(KERN_INFO "TCP: too many of orphaned "
>  				       "sockets\n");
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 808bb92..c35b469 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -66,18 +66,18 @@ static void tcp_write_err(struct sock *sk)
>  static int tcp_out_of_resources(struct sock *sk, int do_reset)
>  {
>  	struct tcp_sock *tp =3D tcp_sk(sk);
> -	int orphans =3D percpu_counter_read_positive(&tcp_orphan_count);
> +	int shift =3D 0;
> =20
>  	/* If peer does not open window for long time, or did not transmit
>  	 * anything for long time, penalize it. */
>  	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_res=
et)
> -		orphans <<=3D 1;
> +		shift++;
> =20
>  	/* If some dubious ICMP arrived, penalize even more. */
>  	if (sk->sk_err_soft)
> -		orphans <<=3D 1;
> +		shift++;
> =20
> -	if (tcp_too_many_orphans(sk, orphans)) {
> +	if (tcp_too_many_orphans(sk, shift)) {
>  		if (net_ratelimit())
>  			printk(KERN_INFO "Out of socket memory\n");
> =20


