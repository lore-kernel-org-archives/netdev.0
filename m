From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v3] 8139cp: Add dma_mapping_error checking
Date: Tue, 30 Jul 2013 18:01:51 -0700 (PDT)
Message-ID: <20130730.180151.2062213596812240686.davem@davemloft.net>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
	<1375117535-12906-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385Ab3GaBBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 21:01:54 -0400
In-Reply-To: <1375117535-12906-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 29 Jul 2013 13:05:35 -0400

> @@ -716,6 +722,22 @@ static inline u32 cp_tx_vlan_tag(struct sk_buff *skb)
>  		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
>  }
>  
> +static void unwind_rx_frag_mapping(struct cp_private *cp, struct sk_buff *skb,
> +				   int first, int entry_last)
> +{
> +	int frag, index;
> +	struct cp_desc *txd;
> +	skb_frag_t *this_frag;
> +	for (frag = 0; frag+first < entry_last; frag++) {
> +		index = first+frag;
> +		cp->tx_skb[index] = NULL;
> +		txd = &cp->tx_ring[index];
> +		this_frag = &skb_shinfo(skb)->frags[frag];
> +		dma_unmap_single(&cp->pdev->dev, le64_to_cpu(txd->addr),
> +				 skb_frag_size(this_frag), PCI_DMA_TODEVICE);
> +	}
> +}

This is using PCI_DMA_TODEVICE, so seems to be dealing with TX mappings.
Yet the function is named "unwind_rx_frame_mapping()".

> @@ -799,6 +827,11 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
>  			mapping = dma_map_single(&cp->pdev->dev,
>  						 skb_frag_address(this_frag),
>  						 len, PCI_DMA_TODEVICE);
> +			if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> +				unwind_rx_frag_mapping(cp, skb, first_entry, entry);
> +				goto out_dma_error;
> +			}

And you're invoking it from the cp_start_xmit() function, which further
confirms the incorrect function name :-)

Please fix this and resubmit, thanks.
