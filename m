From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Wed, 1 Sep 2010 11:20:26 +0000
Message-ID: <20100901112026.GA9468@ff.dom.local>
References: <4LwrqITm-eJ.A.r8G.eFueMB@chimera> <4AUWBNzTkbD.A.ey.cGueMB@chimera> <courier.4C7C99F2.00001F74@fs.ru.acad.bg> <20100831192659.GA3093@del.dom.local> <1283338251.2556.124.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1283338251.2556.124.camel@edumazet-laptop>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2010 at 12:50:51PM +0200, Eric Dumazet wrote:
> Plamen, could you test following patch ?
> 
> I reproduced problem on a dev machine and following patch cured it.
> 
> Thanks
> 
> [PATCH] gro: fix different skb headrooms
> 
> packets entering GRO might have different headrooms, even for a given
> flow (because of implementation details in drivers, like copybreak).
> We cant force drivers to deliver packets with a fixed headroom.
> 
> 1) fix skb_segment()
> 
> skb_segment() makes the false assumption headrooms of fragments are same
> than the head. When CHECKSUM_PARTIAL is used, this can give csum_start
> errors, and crash later in skb_copy_and_csum_dev()

Eric, probably I missed something, but since the same test as in
skb_copy_and_csum_dev() gave different result a bit earlier on exactly
the same skb, I've suspected some sharing (or use after free)
problems, so I'm not sure your current diagnose can explain this.
(Unless this old test was dismissed later.)

Thanks,
Jarek P.

> 
> 2) allocate a minimal skb for head of frag_list
> 
> skb_gro_receive() uses netdev_alloc_skb(headroom + skb_gro_offset(p)) to
> allocate a fresh skb. This adds NET_SKB_PAD to a padding already
> provided by netdevice, depending on various things, like copybreak.
> 
> Use alloc_skb() to allocate an exact padding, to reduce cache line
> needs:
> NET_SKB_PAD + NET_IP_ALIGN
> 
> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=16626
> 
> Many thanks to Plamen Petrov, testing many debugging patches !
> With help of Jarek Poplawski.
> 
> Reported-by: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> patch against linux-2.6 current tree
> 
>  net/core/skbuff.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3a2513f..26396ff 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2573,6 +2573,10 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
>  		__copy_skb_header(nskb, skb);
>  		nskb->mac_len = skb->mac_len;
>  
> +		/* nskb and skb might have different headroom */
> +		if (nskb->ip_summed == CHECKSUM_PARTIAL)
> +			nskb->csum_start += skb_headroom(nskb) - headroom;
> +
>  		skb_reset_mac_header(nskb);
>  		skb_set_network_header(nskb, skb->mac_len);
>  		nskb->transport_header = (nskb->network_header +
> @@ -2702,8 +2706,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>  	} else if (skb_gro_len(p) != pinfo->gso_size)
>  		return -E2BIG;
>  
> -	headroom = skb_headroom(p);
> -	nskb = netdev_alloc_skb(p->dev, headroom + skb_gro_offset(p));
> +	headroom = NET_SKB_PAD + NET_IP_ALIGN;
> +	nskb = alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
>  	if (unlikely(!nskb))
>  		return -ENOMEM;
>  
> 
> 
