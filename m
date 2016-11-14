From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH nf-next,RFC] netfilter: nft_meta: add cgroup version 2
 support
Date: Mon, 14 Nov 2016 11:10:04 +0100
Message-ID: <e4e0bc59-5a97-118b-2d4e-af12c2055e7e@zonque.org>
References: <1479114761-19534-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
        netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479114761-19534-1-git-send-email-pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On 11/14/2016 10:12 AM, Pablo Neira Ayuso wrote:
> Add cgroup version 2 support to nf_tables.
> 
> This extension allows us to fetch the cgroup i-node number from the
> cgroup socket data, place it in a register, then match it against any
> value specified by user. This approach scales up nicely since it
> integrates well in the existing nf_tables map infrastructure.
> 
> Contrary to what iptables cgroup v2 match does, this patch doesn't use
> cgroup_is_descendant() because this call cannot guarantee that the cgroup
> hierarchy is honored in anyway given that the cgroup v2 field becomes yet
> another packet selector that you can use to build your filtering policy.
> 
> Actually, using the i-node approach, it should be easy to build a policy
> that honors the hierarchy if you need this, eg.
> 
> 	meta cgroup2 vmap { "/A/B" : jump b-cgroup-chain,
> 			    "/A/C" : jump c-cgroup-chain,
> 			    "/A" : jump a-cgroup-chain }
> 
> then, the b-cgroup-chain looks like:
> 
> 	jump a-cgroup-chain
> 	... # specific policy b-cgroup-chain goes here
> 
> similarly, the c-cgroup-chain looks like:
> 
> 	jump a-cgroup-chain
> 	... # specific policy c-cgroup-chain goes here
> 
> So both B and C would evaluate A's ruleset. Note that cgroup A would
> also jump to the root cgroup chain policy.
> 
> Anyway, this cgroup i-node approach provides way more flexibility since
> it is up to the sysadmin to decide if he wants to honor the hierarchy or
> simply define a fast path to skip any further classification.

I don't think this can work. The problem is that inodes in cgroupfs are
dynamically allocated when a cgroup is created, so the sysadmin cannot
install the jump rules before that. Worse yet, inode numbers in pseudo
filesystems are recycled, so if a cgroup goes away and a new one is
created, the latter may well end up having the same inode than the old
one. As cgroupfs decoupled from netfilter tables, this will lead to
major chaos in the field.

Note that this was different with the netclass controller in v1 that
would assign a user-controlled numeric value to each cgroup, so both
sides were in the control of the sysadmin. It is also different with the
path matching logic for v2 which does a full path string comparison.
That's potentially expensive, it does lead to predictable runtime behavior.

One way forward here would be to assign a atomically increasing 64-bit
sequence number to each cgroup and expose that. I've recently talked to
Tejun about that. While that won't solve the predictability issue, it
would at least make it practically impossible to have re-used IDs.

Anyway - I think it would be great to have an alternative to the v2 path
matching here, but of course this patch does not solve the ingress issue
we've been discussing. It is still impossible to reliably determine the
cgroup of a local receiver at the time when the netfilter rules are
processed, even for unicast packets.



Thanks,
Daniel


> 
> Signed-off-by: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
> ---
>  include/uapi/linux/netfilter/nf_tables.h |  2 ++
>  net/netfilter/nft_meta.c                 | 15 +++++++++++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
> index 0da7ccf65511..5d4d08367a87 100644
> --- a/include/uapi/linux/netfilter/nf_tables.h
> +++ b/include/uapi/linux/netfilter/nf_tables.h
> @@ -729,6 +729,7 @@ enum nft_exthdr_attributes {
>   * @NFT_META_OIFGROUP: packet output interface group
>   * @NFT_META_CGROUP: socket control group (skb->sk->sk_classid)
>   * @NFT_META_PRANDOM: a 32bit pseudo-random number
> + * @NFT_META_CGROUP2: socket control group v2 (skb->sk->sk_cgrp_data)
>   */
>  enum nft_meta_keys {
>  	NFT_META_LEN,
> @@ -756,6 +757,7 @@ enum nft_meta_keys {
>  	NFT_META_OIFGROUP,
>  	NFT_META_CGROUP,
>  	NFT_META_PRANDOM,
> +	NFT_META_CGROUP2,
>  };
>  
>  /**
> diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
> index 6c1e0246706e..1e793e133903 100644
> --- a/net/netfilter/nft_meta.c
> +++ b/net/netfilter/nft_meta.c
> @@ -190,6 +190,18 @@ void nft_meta_get_eval(const struct nft_expr *expr,
>  		*dest = prandom_u32_state(state);
>  		break;
>  	}
> +#ifdef CONFIG_SOCK_CGROUP_DATA
> +	case NFT_META_CGROUP2: {
> +		struct cgroup *cgrp;
> +
> +		if (!skb->sk || !sk_fullsock(skb->sk))
> +			goto err;
> +
> +		cgrp = sock_cgroup_ptr(&skb->sk->sk_cgrp_data);
> +		*dest = cgrp->kn->ino;
> +		break;
> +	}
> +#endif
>  	default:
>  		WARN_ON(1);
>  		goto err;
> @@ -273,6 +285,9 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
>  #ifdef CONFIG_CGROUP_NET_CLASSID
>  	case NFT_META_CGROUP:
>  #endif
> +#ifdef CONFIG_SOCK_CGROUP_DATA
> +	case NFT_META_CGROUP2:
> +#endif
>  		len = sizeof(u32);
>  		break;
>  	case NFT_META_IIFNAME:
> 
