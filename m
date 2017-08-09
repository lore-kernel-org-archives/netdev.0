From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: ksz: fix skb freeing
Date: Wed, 9 Aug 2017 22:53:29 +0200
Message-ID: <20170809205329.GC28694@lunn.ch>
References: <20170809204609.8114-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170809204609.8114-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien

You missed sending a copy to Woojung Huh.

    Andrew

On Wed, Aug 09, 2017 at 04:46:09PM -0400, Vivien Didelot wrote:
> The DSA layer frees the original skb when an xmit function returns NULL,
> meaning an error occurred. But if the tagging code copied the original
> skb, it is responsible of freeing the copy if an error occurs.
> 
> The ksz tagging code currently has two issues: if skb_put_padto fails,
> the skb copy is not freed, and the original skb will be freed twice.
> 
> To fix that, move skb_put_padto inside both branches of the skb_tailroom
> condition, before freeing the original skb, and free the copy on error.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/tag_ksz.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
> index fab41de8e983..de66ca8e6201 100644
> --- a/net/dsa/tag_ksz.c
> +++ b/net/dsa/tag_ksz.c
> @@ -42,6 +42,9 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
>  	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
>  
>  	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
> +		if (skb_put_padto(skb, skb->len + padlen))
> +			return NULL;
> +
>  		nskb = skb;
>  	} else {
>  		nskb = alloc_skb(NET_IP_ALIGN + skb->len +
> @@ -56,13 +59,15 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
>  		skb_set_transport_header(nskb,
>  					 skb_transport_header(skb) - skb->head);
>  		skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
> +
> +		if (skb_put_padto(nskb, nskb->len + padlen)) {
> +			kfree_skb(nskb);
> +			return NULL;
> +		}
> +
>  		kfree_skb(skb);
>  	}
>  
> -	/* skb is freed when it fails */
> -	if (skb_put_padto(nskb, nskb->len + padlen))
> -		return NULL;
> -
>  	tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
>  	tag[0] = 0;
>  	tag[1] = 1 << p->dp->index; /* destination port */
> -- 
> 2.14.0
> 
