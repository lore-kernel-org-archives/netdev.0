From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: bcmgenet: use skb_put_padto()
Date: Sat, 14 Mar 2015 13:48:55 +0900
Message-ID: <6CCFE062-6F9D-48CB-9D6A-B169874A27AA@gmail.com>
References: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com> <1426287512-10742-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2089\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
	pgynther@google.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33871 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbbCNEs7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 00:48:59 -0400
Received: by pdbni2 with SMTP id ni2so4583312pdb.1
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 21:48:58 -0700 (PDT)
In-Reply-To: <1426287512-10742-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 14, 2015, at 7:58 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
> We use skb_pad() to pad small packets, and then we need to enforce again
> in bcmgenet_xmit() a check on ETH_ZLEN. Use skb_put_padto() which pads
> up to the specified length and also increases skb->len accordingly. Note
> that we still need to use skb_headlen() since we might transmitting the
> first part out of a train of fragments.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> drivers/net/ethernet/broadcom/genet/bcmgenet.c | 5 ++---
> 1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index e74ae628bbb9..cee86c24b35f 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1108,8 +1108,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
> 
> 	tx_cb_ptr->skb = skb;
> 
> -	skb_len = skb_headlen(skb) < ETH_ZLEN ? ETH_ZLEN : skb_headlen(skb);
> -
> +	skb_len = skb_headlen(skb);
> 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
> 	ret = dma_mapping_error(kdev, mapping);
> 	if (ret) {
> @@ -1272,7 +1271,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
> 		goto out;
> 	}
> 
> -	if (skb_padto(skb, ETH_ZLEN)) {
> +	if (skb_put_padto(skb, ETH_ZLEN)) {

I suggest to use the eth_skb_pad helper.

	if (eth_skb_pad(skb)) {
		dev->stats.tx_dropped++;
> 		ret = NETDEV_TX_OK;
> 		goto out;
> 	}
> -- 
> 2.1.0
> 
