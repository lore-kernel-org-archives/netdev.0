From: Bhavesh Davda <bhavesh@vmware.com>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: must split too big fragments
Date: Mon, 29 Oct 2012 10:52:51 -0700 (PDT)
Message-ID: <1948210032.25549736.1351533171670.JavaMail.root@vmware.com>
References: <1351531849.12280.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	jongman heo <jongman.heo@samsung.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351531849.12280.54.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LGTM. Thanks for doing this! Did you do any performance testing with this patch?

Reviewed-by: Bhavesh Davda <bhavesh@vmware.com>

--
Bhavesh Davda

----- Original Message -----
> From: "Eric Dumazet" <eric.dumazet@gmail.com>
> To: "Shreyas Bhatewara" <sbhatewara@vmware.com>, "David Miller" <davem@davemloft.net>
> Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "jongman heo"
> <jongman.heo@samsung.com>
> Sent: Monday, October 29, 2012 10:30:49 AM
> Subject: [Pv-drivers] [PATCH] vmxnet3: must split too big fragments
> 
> From: Eric Dumazet <edumazet@google.com>
> 
> vmxnet3 has a 16Kbytes limit per tx descriptor, that happened to work
> as long as we provided PAGE_SIZE fragments.
> 
> Our stack can now build larger fragments, so we need to split them to
> the 16kbytes boundary.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: jongman heo <jongman.heo@samsung.com>
> Tested-by: jongman heo <jongman.heo@samsung.com>
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |   65
>  +++++++++++++++++++---------
>  1 file changed, 45 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> index ce9d4f2..0ae1bcc 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -744,28 +744,43 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct
> vmxnet3_tx_ctx *ctx,
>  
>  	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
> +		u32 buf_size;
>  
> -		tbi = tq->buf_info + tq->tx_ring.next2fill;
> -		tbi->map_type = VMXNET3_MAP_PAGE;
> -		tbi->dma_addr = skb_frag_dma_map(&adapter->pdev->dev, frag,
> -						 0, skb_frag_size(frag),
> -						 DMA_TO_DEVICE);
> +		buf_offset = 0;
> +		len = skb_frag_size(frag);
> +		while (len) {
> +			tbi = tq->buf_info + tq->tx_ring.next2fill;
> +			if (len < VMXNET3_MAX_TX_BUF_SIZE) {
> +				buf_size = len;
> +				dw2 |= len;
> +			} else {
> +				buf_size = VMXNET3_MAX_TX_BUF_SIZE;
> +				/* spec says that for TxDesc.len, 0 == 2^14 */
> +			}
> +			tbi->map_type = VMXNET3_MAP_PAGE;
> +			tbi->dma_addr = skb_frag_dma_map(&adapter->pdev->dev, frag,
> +							 buf_offset, buf_size,
> +							 DMA_TO_DEVICE);
>  
> -		tbi->len = skb_frag_size(frag);
> +			tbi->len = buf_size;
>  
> -		gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
> -		BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
> +			gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
> +			BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
>  
> -		gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
> -		gdesc->dword[2] = cpu_to_le32(dw2 | skb_frag_size(frag));
> -		gdesc->dword[3] = 0;
> +			gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
> +			gdesc->dword[2] = cpu_to_le32(dw2);
> +			gdesc->dword[3] = 0;
>  
> -		dev_dbg(&adapter->netdev->dev,
> -			"txd[%u]: 0x%llu %u %u\n",
> -			tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
> -			le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
> -		vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
> -		dw2 = tq->tx_ring.gen << VMXNET3_TXD_GEN_SHIFT;
> +			dev_dbg(&adapter->netdev->dev,
> +				"txd[%u]: 0x%llu %u %u\n",
> +				tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
> +				le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
> +			vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
> +			dw2 = tq->tx_ring.gen << VMXNET3_TXD_GEN_SHIFT;
> +
> +			len -= buf_size;
> +			buf_offset += buf_size;
> +		}
>  	}
>  
>  	ctx->eop_txd = gdesc;
> @@ -886,6 +901,18 @@ vmxnet3_prepare_tso(struct sk_buff *skb,
>  	}
>  }
>  
> +static int txd_estimate(const struct sk_buff *skb)
> +{
> +	int count = VMXNET3_TXD_NEEDED(skb_headlen(skb)) + 1;
> +	int i;
> +
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
> +
> +		count += VMXNET3_TXD_NEEDED(skb_frag_size(frag));
> +	}
> +	return count;
> +}
>  
>  /*
>   * Transmits a pkt thru a given tq
> @@ -914,9 +941,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct
> vmxnet3_tx_queue *tq,
>  	union Vmxnet3_GenericDesc tempTxDesc;
>  #endif
>  
> -	/* conservatively estimate # of descriptors to use */
> -	count = VMXNET3_TXD_NEEDED(skb_headlen(skb)) +
> -		skb_shinfo(skb)->nr_frags + 1;
> +	count = txd_estimate(skb);
>  
>  	ctx.ipv4 = (vlan_get_protocol(skb) == cpu_to_be16(ETH_P_IP));
>  
> 
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
> 
