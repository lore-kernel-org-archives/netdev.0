From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] xfrm: fix RCU bugs
Date: Mon, 20 Aug 2012 12:40:17 +0800
Message-ID: <5031BFB1.200@windriver.com>
References: <1345372308.5158.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, <fengguang.wu@intel.com>,
	Priyanka Jain <Priyanka.Jain@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40182 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab2HTEjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 00:39:08 -0400
In-Reply-To: <1345372308.5158.54.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric

Please correct me if I'm wrong about below comments.

On 2012=E5=B9=B408=E6=9C=8819=E6=97=A5 18:31, Eric Dumazet wrote:
> From: Eric Dumazet<edumazet@google.com>
>
> This patch reverts commit 56892261ed1a (xfrm: Use rcu_dereference_bh =
to
> deference pointer protected by rcu_read_lock_bh), and fixes bugs
> introduced in commit 418a99ac6ad ( Replace rwlock on xfrm_policy_afin=
fo
> with rcu )
>
> 1) We properly use RCU variant in this file, not a mix of RCU/RCU_BH
>
> 2) We must defer some writes after the synchronize_rcu() call or a re=
ader
>   can crash dereferencing NULL pointer.

Not exactly.

net/ipv4/xfrm4_policy.c
static void __exit xfrm4_policy_fini(void)
   -> xfrm_policy_unregister_afinfo

IMHO, ip stack can never be compiled as module, so is xfrm4_policy_fini
freed up after system bootup? which means xfrm4_policy_fini can never b=
e
called.

so an dereferencing NULL pointer by a reader could not happen.

>
> 3) Now we use the xfrm_policy_afinfo_lock spinlock only from process
> context, we no longer need to block BH in xfrm_policy_register_afinfo=
()
> and xfrm_policy_unregister_afinfo()
>
I don't think it's related to what kinds of locks we are using.
we call xfrm_policy_register_afinfo in process context, but actually
what xfrm_policy_afinfo_lock protected can be used in soft irq context.
that's why xx_bh is used in:

e959d812 " [XFRM]: fix incorrect xfrm_policy_afinfo_lock use"

Is such scenario still valid?

> 4) Can use RCU_INIT_POINTER() instead of rcu_assign_pointer() in
> xfrm_policy_unregister_afinfo()
>
> 5) Remove a forward inline declaration (xfrm_policy_put_afinfo()),
>    and also move xfrm_policy_get_afinfo() declaration.
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>
> Cc: Fan Du<fan.du@windriver.com>
> Cc: Priyanka Jain<Priyanka.Jain@freescale.com>
> ---
>   net/xfrm/xfrm_policy.c |   76 ++++++++++++++++++++-----------------=
--
>   1 file changed, 39 insertions(+), 37 deletions(-)
>
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 6405764..e52f50f 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -48,8 +48,6 @@ static struct xfrm_policy_afinfo __rcu *xfrm_policy=
_afinfo[NPROTO]
>
>   static struct kmem_cache *xfrm_dst_cache __read_mostly;
>
> -static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned sh=
ort family);
> -static inline void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo =
*afinfo);
>   static void xfrm_init_pmtu(struct dst_entry *dst);
>   static int stale_bundle(struct dst_entry *dst);
>   static int xfrm_bundle_ok(struct xfrm_dst *xdst);
> @@ -96,6 +94,24 @@ bool xfrm_selector_match(const struct xfrm_selecto=
r *sel, const struct flowi *fl
>   	return false;
>   }
>
> +static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned sh=
ort family)
> +{
> +	struct xfrm_policy_afinfo *afinfo;
> +
> +	if (unlikely(family>=3D NPROTO))
> +		return NULL;
> +	rcu_read_lock();
> +	afinfo =3D rcu_dereference(xfrm_policy_afinfo[family]);
> +	if (unlikely(!afinfo))
> +		rcu_read_unlock();
> +	return afinfo;
> +}
> +
> +static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo=
)
> +{
> +	rcu_read_unlock();
> +}
> +
>   static inline struct dst_entry *__xfrm_dst_lookup(struct net *net, =
int tos,
>   						  const xfrm_address_t *saddr,
>   						  const xfrm_address_t *daddr,
> @@ -2419,7 +2435,7 @@ int xfrm_policy_register_afinfo(struct xfrm_pol=
icy_afinfo *afinfo)
>   		return -EINVAL;
>   	if (unlikely(afinfo->family>=3D NPROTO))
>   		return -EAFNOSUPPORT;
> -	spin_lock_bh(&xfrm_policy_afinfo_lock);
> +	spin_lock(&xfrm_policy_afinfo_lock);
>   	if (unlikely(xfrm_policy_afinfo[afinfo->family] !=3D NULL))
>   		err =3D -ENOBUFS;
>   	else {
> @@ -2442,7 +2458,7 @@ int xfrm_policy_register_afinfo(struct xfrm_pol=
icy_afinfo *afinfo)
>   			afinfo->garbage_collect =3D xfrm_garbage_collect_deferred;
>   		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
>   	}
> -	spin_unlock_bh(&xfrm_policy_afinfo_lock);
> +	spin_unlock(&xfrm_policy_afinfo_lock);
>
>   	rtnl_lock();
>   	for_each_net(net) {
> @@ -2475,23 +2491,26 @@ int xfrm_policy_unregister_afinfo(struct xfrm=
_policy_afinfo *afinfo)
>   		return -EINVAL;
>   	if (unlikely(afinfo->family>=3D NPROTO))
>   		return -EAFNOSUPPORT;
> -	spin_lock_bh(&xfrm_policy_afinfo_lock);
> +	spin_lock(&xfrm_policy_afinfo_lock);
>   	if (likely(xfrm_policy_afinfo[afinfo->family] !=3D NULL)) {
>   		if (unlikely(xfrm_policy_afinfo[afinfo->family] !=3D afinfo))
>   			err =3D -EINVAL;
> -		else {
> -			struct dst_ops *dst_ops =3D afinfo->dst_ops;
> -			rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family],
> -									NULL);
> -			dst_ops->kmem_cachep =3D NULL;
> -			dst_ops->check =3D NULL;
> -			dst_ops->negative_advice =3D NULL;
> -			dst_ops->link_failure =3D NULL;
> -			afinfo->garbage_collect =3D NULL;
> -		}
> +		else
> +			RCU_INIT_POINTER(xfrm_policy_afinfo[afinfo->family],
> +					 NULL);
> +	}
> +	spin_unlock(&xfrm_policy_afinfo_lock);
> +	if (!err) {
> +		struct dst_ops *dst_ops =3D afinfo->dst_ops;
> +
> +		synchronize_rcu();
> +
> +		dst_ops->kmem_cachep =3D NULL;
> +		dst_ops->check =3D NULL;
> +		dst_ops->negative_advice =3D NULL;
> +		dst_ops->link_failure =3D NULL;
> +		afinfo->garbage_collect =3D NULL;
>   	}
> -	spin_unlock_bh(&xfrm_policy_afinfo_lock);
> -	synchronize_rcu();
>   	return err;
>   }
>   EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
> @@ -2500,32 +2519,15 @@ static void __net_init xfrm_dst_ops_init(stru=
ct net *net)
>   {
>   	struct xfrm_policy_afinfo *afinfo;
>
> -	rcu_read_lock_bh();
> -	afinfo =3D rcu_dereference_bh(xfrm_policy_afinfo[AF_INET]);
> +	rcu_read_lock();
> +	afinfo =3D rcu_dereference(xfrm_policy_afinfo[AF_INET]);
>   	if (afinfo)
>   		net->xfrm.xfrm4_dst_ops =3D *afinfo->dst_ops;
>   #if IS_ENABLED(CONFIG_IPV6)
> -	afinfo =3D rcu_dereference_bh(xfrm_policy_afinfo[AF_INET6]);
> +	afinfo =3D rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
>   	if (afinfo)
>   		net->xfrm.xfrm6_dst_ops =3D *afinfo->dst_ops;
>   #endif
> -	rcu_read_unlock_bh();
> -}
> -
> -static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned sh=
ort family)
> -{
> -	struct xfrm_policy_afinfo *afinfo;
> -	if (unlikely(family>=3D NPROTO))
> -		return NULL;
> -	rcu_read_lock();
> -	afinfo =3D rcu_dereference(xfrm_policy_afinfo[family]);
> -	if (unlikely(!afinfo))
> -		rcu_read_unlock();
> -	return afinfo;
> -}
> -
> -static inline void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo =
*afinfo)
> -{
>   	rcu_read_unlock();
>   }
>
>
>
>

--=20

Love each day!
--fan
