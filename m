From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V2 6/8] net: mediatek: fix TX locking
Date: Thu, 7 Apr 2016 22:46:47 +0300
Message-ID: <5706B927.8090309@cogentembedded.com>
References: <1460057210-55786-1-git-send-email-blogic@openwrt.org>
 <1460057210-55786-7-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?B?U2VhbiBXYW5nICjnjovlv5fkupgp?= <sean.wang@mediatek.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: John Crispin <blogic@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:33127 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757315AbcDGTqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 15:46:52 -0400
Received: by mail-lb0-f176.google.com with SMTP id u8so56575066lbk.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 12:46:51 -0700 (PDT)
In-Reply-To: <1460057210-55786-7-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/07/2016 10:26 PM, John Crispin wrote:

> Inside the TX path there is a lock inside the tx_map function. This is
> however too late. The patch moves the lock to the start of the xmit
> function right before the free count check of the DMA ring happens.
> If we do not do this, the code becomes racy leading to TX stalls and
> dropped packets. This happens as there are 2 netdevs running on the
> same physical DMA ring.
>
> Signed-off-by: John Crispin <blogic@openwrt.org>
> ---
>   drivers/net/ethernet/mediatek/mtk_eth_soc.c |   20 ++++++++++----------
>   1 file changed, 10 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 60b66ab..8434355 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
[...]
> @@ -712,14 +702,22 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	struct mtk_eth *eth = mac->hw;
>   	struct mtk_tx_ring *ring = &eth->tx_ring;
>   	struct net_device_stats *stats = &dev->stats;
> +	unsigned long flags;
>   	bool gso = false;
>   	int tx_num;
>
> +	/* normally we can rely on the stack not calling this more than once,
> +	 * however we have 2 queues running ont he same ring so we need to lock

    s/ont he/ on the/, perhaps a good chance to fix the comment?

> +	 * the ring access
> +	 */
> +	spin_lock_irqsave(&eth->page_lock, flags);
> +
>   	tx_num = mtk_cal_txd_req(skb);
>   	if (unlikely(atomic_read(&ring->free_count) <= tx_num)) {
>   		mtk_stop_queue(eth);
>   		netif_err(eth, tx_queued, dev,
>   			  "Tx Ring full when queue awake!\n");
> +		spin_unlock_irqrestore(&eth->page_lock, flags);
>   		return NETDEV_TX_BUSY;
>   	}
>
[...]

MBR, Sergei
