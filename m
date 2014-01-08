From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 6/9] xen-netback: Handle guests with too
 many frags
Date: Tue, 07 Jan 2014 18:12:21 -0800
Message-ID: <1389147141.26646.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
	 <1389139818-24458-7-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jonathan.davies@citrix.com
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389139818-24458-7-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-01-08 at 00:10 +0000, Zoltan Kiss wrote:

>  
> +		if (skb_shinfo(skb)->frag_list) {
> +			nskb = skb_shinfo(skb)->frag_list;
> +			xenvif_fill_frags(vif, nskb, INVALID_PENDING_IDX);
> +			skb->len += nskb->len;
> +			skb->data_len += nskb->len;
> +			skb->truesize += nskb->truesize;
> +			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +			skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +			vif->tx_zerocopy_sent += 2;
> +			nskb = skb;
> +
> +			skb = skb_copy_expand(skb,
> +					0,
> +					0,
> +					GFP_ATOMIC | __GFP_NOWARN);

skb can be NULL here

> +			skb_shinfo(skb)->destructor_arg = NULL;
> +		}
>  		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
>  			int target = min_t(int, skb->len, PKT_PROT_LEN);
>  			__pskb_pull_tail(skb, target - skb_headlen(skb));
> @@ -1568,6 +1660,9 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  		}
>  
