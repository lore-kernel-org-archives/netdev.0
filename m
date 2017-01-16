From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing
 rings
Date: Mon, 16 Jan 2017 23:41:51 +0300
Message-ID: <8ab10450-5fe3-bc33-6c66-6f3ea861f561@cogentembedded.com>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
 <3e1d4324-4288-8d65-56fd-8c3e7283020b@cogentembedded.com>
 <20170112131821.GA16060@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170112131821.GA16060@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 01/12/2017 04:18 PM, Simon Horman wrote:

> ...

>>>>   Here, it stop once an untransmitted buffer is encountered...
>>>
>>> Yes, I see that now.
>>>
>>> I wonder if we should:
>>>
>>> a) paramatise ravb_tx_free() so it may either clear all transmitted buffers
>>>   (current behaviour) or all buffers (new behaviour).
>>> b) provide a different version of this loop in ravb_ring_free()
>>>
>>> What are your thoughts?
>>
>>    I'm voting for (b).

    After looking at this issue for another time, I'll vote for (a). Sorry for 
back-and-forth on this matter -- I somehow thought we could do a better job by 
scanning all the TX ring...

> Ok, something like this?
>
> @@ -215,6 +225,30 @@ static void ravb_ring_free(struct net_device *ndev, int q)
>  	}
>
>  	if (priv->tx_ring[q]) {
> +		for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
> +			struct ravb_tx_desc *desc;
> +			int entry;
> +
> +			entry = priv->dirty_tx[q] % (priv->num_tx_ring[q] *
> +						     NUM_TX_DESC);
> +			desc = &priv->tx_ring[q][entry];
> +
> +			/* Free the original skb. */
> +			if (priv->tx_skb[q][entry / NUM_TX_DESC]) {
> +				u32 size = le16_to_cpu(desc->ds_tagl) & TX_DS;
> +
> +				dma_unmap_single(ndev->dev.parent,
> +						 le32_to_cpu(desc->dptr),
> +						 size, DMA_TO_DEVICE);
> +				/* Last packet descriptor? */
> +				if (entry % NUM_TX_DESC == NUM_TX_DESC - 1) {
> +					entry /= NUM_TX_DESC;
> +					dev_kfree_skb_any(priv->tx_skb[q][entry]);
> +					priv->tx_skb[q][entry] = NULL;
> +				}
> +			}
> +		}
> +

    This is only different from ravb_tx_free() by not stopping on unfinished 
descriptor, so we must be good with adding an extra param to it...

[...]

MBR, Sergei
