From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] net,rcu: don't assume the size of struct rcu_head
Date: Tue, 01 Mar 2011 09:20:26 +0100
Message-ID: <1298967626.2676.65.camel@edumazet-laptop>
References: <4D6CA860.3020409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney"
 <paulmck@linux.vnet.ibm.com>,  Christoph Lameter <cl@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4D6CA860.3020409@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 16:03 +0800, Lai Jiangshan a =C3=A9crit :
> struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(long=
)
> and manually adds pads for aligning for "__refcnt".
>=20
> When the size of struct rcu_head is changed, these manual padding
> is wrong. Use __attribute__((aligned (64))) instead.
>=20
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---

> diff --git a/include/net/dst.h b/include/net/dst.h
> index 93b0310..4ef6c4a 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -62,8 +62,6 @@ struct dst_entry {
>  	struct hh_cache		*hh;
>  #ifdef CONFIG_XFRM
>  	struct xfrm_state	*xfrm;
> -#else
> -	void			*__pad1;
>  #endif
>  	int			(*input)(struct sk_buff*);
>  	int			(*output)(struct sk_buff*);
> @@ -74,23 +72,18 @@ struct dst_entry {
> =20
>  #ifdef CONFIG_NET_CLS_ROUTE
>  	__u32			tclassid;
> -#else
> -	__u32			__pad2;
>  #endif
> =20
>=20
>  	/*
>  	 * Align __refcnt to a 64 bytes alignment
>  	 * (L1_CACHE_SIZE would be too much)
> -	 */
> -#ifdef CONFIG_64BIT
> -	long			__pad_to_align_refcnt[1];
> -#endif
> -	/*
> +	 *
>  	 * __refcnt wants to be on a different cache line from
>  	 * input/output/ops or performance tanks badly
>  	 */
> -	atomic_t		__refcnt;	/* client references	*/
> +	atomic_t		__refcnt	/* client references	*/
> +				__attribute__((aligned (64)));
>  	int			__use;
>  	unsigned long		lastuse;
>  	union {

If struct rcu_head is bigger, this is for debugging purposes, so we dont
care about performance, and can avoid wasting ~64 bytes.

Some machines still have about 2.000.000 active dst entries : the
convoluted checks we added in include/net/dst.h are here to make sure we
dont have huge holes in the dst structure.

(This might change when/if IP route cache is gone)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
