From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Re: [PATCH] natsemi: add checks for dma mapping errors
Date: Sat, 19 Dec 2015 15:06:45 +0300
Message-ID: <56754855.6080808@ispras.ru>
References: <1450475737-5959-1-git-send-email-khoroshilov@ispras.ru>
 <20151218.213607.1270121670262037282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151218.213607.1270121670262037282.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.12.2015 05:36, David Miller wrote:
> From: Alexey Khoroshilov <khoroshilov@ispras.ru>
> Date: Sat, 19 Dec 2015 00:55:37 +0300
>
>> @@ -2093,6 +2099,10 @@ static netdev_tx_t start_tx(struct sk_buff
*skb, struct net_device *dev)
>>  	np->tx_skbuff[entry] = skb;
>>  	np->tx_dma[entry] = pci_map_single(np->pci_dev,
>>  				skb->data,skb->len, PCI_DMA_TODEVICE);
>> +	if (pci_dma_mapping_error(np->pci_dev, np->tx_dma[entry])) {
>> +		np->tx_skbuff[entry] = NULL;
>> +		return NETDEV_TX_BUSY;
>> +	}
>>
>>  	np->tx_ring[entry].addr = cpu_to_le32(np->tx_dma[entry]);
>>
>
> Returning NETDEV_TX_BUSY and freeing the SKB will crash the system.

I do not quite understand what do you mean by 'freeing the SKB'.
At least the patch left skb untouched.

But I saw such pattern, for example, in
drivers/net/ethernet/freescale/fec_main.c:

	addr = dma_map_single(&fep->pdev->dev, data, size, DMA_TO_DEVICE);
	if (dma_mapping_error(&fep->pdev->dev, addr)) {
		dev_kfree_skb_any(skb);
		if (net_ratelimit())
			netdev_err(ndev, "Tx DMA memory map failed\n");
		return NETDEV_TX_BUSY;
	}

>
> NETDEV_TX_BUSY is only for buggy drivers that do not manage their
> TX ring busy condition correctly, and thus need retries.

Ok, I will replace NETDEV_TX_BUSY by dropping the packet.

--
Alexey
