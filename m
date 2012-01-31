From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Tue, 31 Jan 2012 09:51:18 +0100
Message-ID: <4F27AB86.5080009@uclouvain.be>
References: <1327963304-24828-1-git-send-email-asharma@fb.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327963304-24828-1-git-send-email-asharma@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2012 11:41 PM, Arun Sharma wrote:
> Some of our machines were reporting:
>=20
> TCP: too many of orphaned sockets
>=20
> even when the number of orphaned sockets was well below the
> limit.
>=20
> We print a different message depending on whether we're out
> of TCP memory or there are too many orphan sockets.
>=20
> Signed-off-by: Arun Sharma <asharma@fb.com>
> Suggested-by: Mohan Srinivasan <mohan@fb.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: David Miller <davem@davemloft.net>
> Cc: Glauber Costa <glommer@parallels.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> ---
>  include/net/tcp.h    |   12 ++++++++----
>  net/ipv4/tcp.c       |   14 +++++++++++++-
>  net/ipv4/tcp_timer.c |    9 +++++++--
>  3 files changed, 28 insertions(+), 7 deletions(-)
>=20
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 0118ea9..92965dd 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -273,6 +273,14 @@ static inline int between(__u32 seq1, __u32 seq2=
, __u32 seq3)
>  	return seq3 - seq2 >=3D seq1 - seq2;
>  }
> =20
> +static inline bool tcp_out_of_memory(struct sock *sk)
> +{
> +	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
> +	    sk_memory_allocated(sk) > sk_prot_mem_limits(sk, 2))
> +		return true;
> +	return false;
> +}
> +
>  static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
>  {
>  	struct percpu_counter *ocp =3D sk->sk_prot->orphan_count;
> @@ -283,10 +291,6 @@ static inline bool tcp_too_many_orphans(struct s=
ock *sk, int shift)
>  		if (orphans << shift > sysctl_tcp_max_orphans)
>  			return true;
>  	}
> -
> -	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
> -	    sk_memory_allocated(sk) > sk_prot_mem_limits(sk, 2))
> -		return true;
>  	return false;
>  }
> =20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 9bcdec3..395a4ef 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2015,10 +2015,22 @@ adjudge_to_death:
>  	}
>  	if (sk->sk_state !=3D TCP_CLOSE) {
>  		sk_mem_reclaim(sk);
> -		if (tcp_too_many_orphans(sk, 0)) {
> +		bool too_many_orphans =3D tcp_too_many_orphans(sk, 0);
> +		bool out_of_socket_memory =3D tcp_out_of_memory(sk);

This introduces a compiler warning because you have the declarations
after the code (sk_mem_reclaim()):

Cheers,
Christoph



--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=E9 Catholique de Louvain
--=20
