From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] LSO feature added to Cadence GEM driver
Date: Mon, 24 Oct 2016 08:40:56 -0700
Message-ID: <1477323656.7065.130.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477315088-28396-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477315088-28396-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-10-24 at 14:18 +0100, Rafal Ozieblo wrote:
> New Cadence GEM hardware support Large Segment Offload (LSO):
> TCP segmentation offload (TSO) as well as UDP fragmentation
> offload (UFO). Support for those features was added to the driver.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>

...
>  
> +static int macb_lso_check_compatibility(struct sk_buff *skb, unsigned int hdrlen)
> +{
> +	unsigned int nr_frags, f;
> +
> +	if (skb_shinfo(skb)->gso_size == 0)
> +		/* not LSO */
> +		return -EPERM;
> +
> +	/* there is only one buffer */
> +	if (!skb_is_nonlinear(skb))
> +		return 0;
> +
> +	/* For LSO:
> +	 * When software supplies two or more payload buffers all payload buffers
> +	 * apart from the last must be a multiple of 8 bytes in size.
> +	 */
> +	if (!IS_ALIGNED(skb_headlen(skb) - hdrlen, MACB_TX_LEN_ALIGN))
> +		return -EPERM;
> +
> +	nr_frags = skb_shinfo(skb)->nr_frags;
> +	/* No need to check last fragment */
> +	nr_frags--;
> +	for (f = 0; f < nr_frags; f++) {
> +		const skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
> +
> +		if (!IS_ALIGNED(skb_frag_size(frag), MACB_TX_LEN_ALIGN))
> +			return -EPERM;
> +	}
> +	return 0;
> +}
> +

Very strange hardware requirements ;(

You should implement an .ndo_features_check method
to perform the checks from core networking stack, and not from your
ndo_start_xmit()

This has the huge advantage of not falling back to skb_linearize(skb)
which is very likely to fail with ~64 KB skbs anyway.

(Your ndo_features_check() would request software GSO instead ...)
