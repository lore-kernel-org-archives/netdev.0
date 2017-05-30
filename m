From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 6/6] net: dsa: factor skb freeing on xmit
Date: Tue, 30 May 2017 13:59:03 -0700
Message-ID: <8487d628-874e-cc45-a15a-07725930dbc2@gmail.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
 <20170530183319.10718-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530183319.10718-7-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2017 11:33 AM, Vivien Didelot wrote:
> The taggers are currently responsible to free the original SKB if they
> made a copy of it, or in case of error.
> 
> This patch simplifies this by freeing the original SKB in the
> dsa_slave_xmit caller, but only if an error (NULL) is returned.

Is not it a clearer contract if the tagging protocol must always free
the original SKB, whether it succeeded in creating a new one or not?

> 
> It is still the responsibility of the tagger to free the original SKB if
> it returned a copy of it.
> 
> At the same time, fix the checkpatch NULL comparison check:
> 
>         CHECK: Comparison to NULL could be written "!nskb"
>     #208: FILE: net/dsa/tag_trailer.c:35:
>     +	if (nskb == NULL)
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/slave.c       | 8 ++++++--
>  net/dsa/tag_brcm.c    | 6 +-----
>  net/dsa/tag_dsa.c     | 8 ++------
>  net/dsa/tag_edsa.c    | 8 ++------
>  net/dsa/tag_lan9303.c | 5 +----
>  net/dsa/tag_mtk.c     | 6 +-----
>  net/dsa/tag_qca.c     | 6 +-----
>  net/dsa/tag_trailer.c | 4 +---
>  8 files changed, 15 insertions(+), 36 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 887e26695519..4473aec9dcda 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -362,10 +362,14 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
>  	dev->stats.tx_packets++;
>  	dev->stats.tx_bytes += skb->len;
>  
> -	/* Transmit function may have to reallocate the original SKB */
> +	/* Transmit function may have to reallocate the original SKB,
> +	 * in which case it must have freed it. Only free it here on error.
> +	 */
>  	nskb = p->xmit(skb, dev);
> -	if (!nskb)
> +	if (!nskb) {
> +		kfree_skb(skb);
>  		return NETDEV_TX_OK;
> +	}
>  
>  	/* SKB for netpoll still need to be mangled with the protocol-specific
>  	 * tag to be successfully transmitted
> diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
> index 10fa4c0ca46b..5db6bcfde025 100644
> --- a/net/dsa/tag_brcm.c
> +++ b/net/dsa/tag_brcm.c
> @@ -65,7 +65,7 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
>  	u8 *brcm_tag;
>  
>  	if (skb_cow_head(skb, BRCM_TAG_LEN) < 0)
> -		goto out_free;
> +		return NULL;
>  
>  	skb_push(skb, BRCM_TAG_LEN);
>  
> @@ -86,10 +86,6 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
>  	brcm_tag[3] = (1 << p->dp->index) & BRCM_IG_DSTMAP1_MASK;
>  
>  	return skb;
> -
> -out_free:
> -	kfree_skb(skb);
> -	return NULL;
>  }
>  
>  static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev)
> diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
> index 9f5fecaa4a93..6837ca9160a8 100644
> --- a/net/dsa/tag_dsa.c
> +++ b/net/dsa/tag_dsa.c
> @@ -28,7 +28,7 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
>  	 */
>  	if (skb->protocol == htons(ETH_P_8021Q)) {
>  		if (skb_cow_head(skb, 0) < 0)
> -			goto out_free;
> +			return NULL;
>  
>  		/*
>  		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
> @@ -46,7 +46,7 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
>  		}
>  	} else {
>  		if (skb_cow_head(skb, DSA_HLEN) < 0)
> -			goto out_free;
> +			return NULL;
>  		skb_push(skb, DSA_HLEN);
>  
>  		memmove(skb->data, skb->data + DSA_HLEN, 2 * ETH_ALEN);
> @@ -62,10 +62,6 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  
>  	return skb;
> -
> -out_free:
> -	kfree_skb(skb);
> -	return NULL;
>  }
>  
>  static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev)
> diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
> index a9a06e19abeb..96ddc90472a2 100644
> --- a/net/dsa/tag_edsa.c
> +++ b/net/dsa/tag_edsa.c
> @@ -30,7 +30,7 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
>  	 */
>  	if (skb->protocol == htons(ETH_P_8021Q)) {
>  		if (skb_cow_head(skb, DSA_HLEN) < 0)
> -			goto out_free;
> +			return NULL;
>  		skb_push(skb, DSA_HLEN);
>  
>  		memmove(skb->data, skb->data + DSA_HLEN, 2 * ETH_ALEN);
> @@ -55,7 +55,7 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
>  		}
>  	} else {
>  		if (skb_cow_head(skb, EDSA_HLEN) < 0)
> -			goto out_free;
> +			return NULL;
>  		skb_push(skb, EDSA_HLEN);
>  
>  		memmove(skb->data, skb->data + EDSA_HLEN, 2 * ETH_ALEN);
> @@ -75,10 +75,6 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  
>  	return skb;
> -
> -out_free:
> -	kfree_skb(skb);
> -	return NULL;
>  }
>  
>  static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev)
> diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
> index 82e150486497..e33348101e8f 100644
> --- a/net/dsa/tag_lan9303.c
> +++ b/net/dsa/tag_lan9303.c
> @@ -52,7 +52,7 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (skb_cow_head(skb, LAN9303_TAG_LEN) < 0) {
>  		dev_dbg(&dev->dev,
>  			"Cannot make room for the special tag. Dropping packet\n");
> -		goto out_free;
> +		return NULL;
>  	}
>  
>  	/* provide 'LAN9303_TAG_LEN' bytes additional space */
> @@ -66,9 +66,6 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
>  	lan9303_tag[1] = htons(p->dp->index | BIT(4));
>  
>  	return skb;
> -out_free:
> -	kfree_skb(skb);
> -	return NULL;
>  }
>  
>  static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev)
> diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
> index 327dd7b596df..ee62ae5f03e1 100644
> --- a/net/dsa/tag_mtk.c
> +++ b/net/dsa/tag_mtk.c
> @@ -27,7 +27,7 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
>  	u8 *mtk_tag;
>  
>  	if (skb_cow_head(skb, MTK_HDR_LEN) < 0)
> -		goto out_free;
> +		return NULL;
>  
>  	skb_push(skb, MTK_HDR_LEN);
>  
> @@ -41,10 +41,6 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
>  	mtk_tag[3] = 0;
>  
>  	return skb;
> -
> -out_free:
> -	kfree_skb(skb);
> -	return NULL;
>  }
>  
>  static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev)
> diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
> index 8080ad8f2abb..4d3bc2920477 100644
> --- a/net/dsa/tag_qca.c
> +++ b/net/dsa/tag_qca.c
> @@ -45,7 +45,7 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
>  	dev->stats.tx_bytes += skb->len;
>  
>  	if (skb_cow_head(skb, 0) < 0)
> -		goto out_free;
> +		return NULL;
>  
>  	skb_push(skb, QCA_HDR_LEN);
>  
> @@ -60,10 +60,6 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
>  	*phdr = htons(hdr);
>  
>  	return skb;
> -
> -out_free:
> -	kfree_skb(skb);
> -	return NULL;
>  }
>  
>  static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev)
> diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
> index 7422b1329712..8c9a7f5ecc66 100644
> --- a/net/dsa/tag_trailer.c
> +++ b/net/dsa/tag_trailer.c
> @@ -32,10 +32,8 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
>  		padlen = 60 - skb->len;
>  
>  	nskb = alloc_skb(NET_IP_ALIGN + skb->len + padlen + 4, GFP_ATOMIC);
> -	if (nskb == NULL) {
> -		kfree_skb(skb);
> +	if (!nskb)
>  		return NULL;
> -	}
>  	skb_reserve(nskb, NET_IP_ALIGN);
>  
>  	skb_reset_mac_header(nskb);
> 


-- 
Florian
