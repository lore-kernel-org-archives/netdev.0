From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Mon, 06 Oct 2008 23:22:31 +0200
Message-ID: <48EA8197.6080502@cosmosbay.com>
References: <20081006185026.GA10383@minyard.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: minyard@acm.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755866AbYJFVXA@vger.kernel.org>
In-Reply-To: <20081006185026.GA10383@minyard.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Minyard a =E9crit :
> Change the UDP hash lock from an rwlock to RCU.
>=20
> Signed-off-by: Corey Minyard <cminyard@mvista.com>
> ---
>  include/net/udp.h |    9 +++++----
>  net/ipv4/udp.c    |   47 +++++++++++++++++++++++++++----------------=
----
>  net/ipv6/udp.c    |   17 +++++++++--------
>  3 files changed, 41 insertions(+), 32 deletions(-)
>=20
> diff --git a/include/net/udp.h b/include/net/udp.h
> index addcdc6..35aa104 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -51,7 +51,7 @@ struct udp_skb_cb {
>  #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
> =20
>  extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
> -extern rwlock_t udp_hash_lock;
> +extern spinlock_t udp_hash_wlock;
> =20
> =20
>  /* Note: this must match 'valbool' in sock_setsockopt */
> @@ -112,12 +112,13 @@ static inline void udp_lib_hash(struct sock *sk=
)
> =20
>  static inline void udp_lib_unhash(struct sock *sk)
>  {
> -	write_lock_bh(&udp_hash_lock);
> -	if (sk_del_node_init(sk)) {
> +	spin_lock_bh(&udp_hash_wlock);
> +	if (sk_del_node_init_rcu(sk)) {
>  		inet_sk(sk)->num =3D 0;
>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>  	}
> -	write_unlock_bh(&udp_hash_lock);
> +	spin_unlock_bh(&udp_hash_wlock);
> +	synchronize_rcu();

UDP central rwlock can hurt performance, because of cache line ping pon=
g,
so your patch really makes sense.

Me wondering what impact this synchronize_rcu() can have on mono-thread=
ed
VOIP applications using lot of UDP sockets. What is the maximum delay o=
f
this function ?

=46or "struct file" freeing, we chose call_rcu() instead of synchronize=
_rcu()

Maybe we could add a generic rcu head to struct sock, and use call_rcu(=
) in
sk_prot_free() for sockets needing RCU (udp after your patch is applied=
, maybe
tcp on future patches, while I believe previous work on the subject con=
cluded
RCU was not giving good results for short lived http sessions) ?

Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_register()
for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free()=20
done in sk_prot_free() can defer freeing to RCU...
