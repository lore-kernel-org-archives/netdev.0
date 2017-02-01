From: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCHv3 net-next 5/7] net: add confirm_neigh method to dst_ops
Date: Wed, 1 Feb 2017 08:44:02 +0100
Message-ID: <20170201074402.GX30338@gauss.secunet.com>
References: <1485899827-5212-1-git-send-email-ja@ssi.bg>
 <1485899827-5212-6-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, YueHaibing <yuehaibing-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1485899827-5212-6-git-send-email-ja-FgGsKACvmQM@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2017 at 11:57:05PM +0200, Julian Anastasov wrote:
>  
>  static unsigned int ip6_blackhole_mtu(const struct dst_entry *dst)
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 177e208..c010ee0 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2856,6 +2856,20 @@ static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
>  	return dst->path->ops->neigh_lookup(dst, skb, daddr);
>  }
>  
> +static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
> +{
> +	const struct dst_entry *path = dst->path;
> +
> +	if (path == dst) {

I think path can not be equal to dst here, otherwise we would
have an infinite recursion.

> +		dst->ops->confirm_neigh(dst, daddr);
> +	} else {
> +		/* daddr can be from different family and we need the
> +		 * tunnel address. How to get it?
> +		 */

This is only called on a xfrm_dst, so you should have dst->xfrm set.
You can get the daddr of this transform with:

xfrm_address_t *daddr = &xfrm->id.daddr;


> +		path->ops->confirm_neigh(path, NULL);

I think here it is better to go through the whole chain
of transformations with

child->ops->confirm_neigh(path, daddr);

> +	}
> +}
> +
>  int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
>  {
>  	int err = 0;
> @@ -2882,6 +2896,8 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
>  			dst_ops->link_failure = xfrm_link_failure;
>  		if (likely(dst_ops->neigh_lookup == NULL))
>  			dst_ops->neigh_lookup = xfrm_neigh_lookup;
> +		if (likely(!dst_ops->confirm_neigh))
> +			dst_ops->confirm_neigh = xfrm_confirm_neigh;

We also have address family depended dst_ops, look for
xfrm4_dst_ops_template/xfrm6_dst_ops_template.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
