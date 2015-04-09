From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/4] sh_eth: Ensure proper ordering of descriptor
 active bit write/read
Date: Fri, 10 Apr 2015 01:21:14 +0300
Message-ID: <5526FB5A.8090005@cogentembedded.com>
References: <1425343868.4288.8.camel@xylophone.i.decadent.org.uk> <1425343920.4288.9.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34894 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbbDIWVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 18:21:19 -0400
Received: by lbbuc2 with SMTP id uc2so857724lbb.2
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 15:21:17 -0700 (PDT)
In-Reply-To: <1425343920.4288.9.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/03/2015 03:52 AM, Ben Hutchings wrote:

> When submitting a DMA descriptor, the active bit must be written last.
> When reading a completed DMA descriptor, the active bit must be read
> first.

> Add memory barriers to ensure that this ordering is maintained.

    Looks like those should have been lighter dma_rmb() and dma_wmb() instead.
Correct, Alexander?

> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 654b48d1e61a..5c212a833bcf 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1410,6 +1410,8 @@ static int sh_eth_txfree(struct net_device *ndev)
>   		txdesc = &mdp->tx_ring[entry];
>   		if (txdesc->status & cpu_to_edmac(mdp, TD_TACT))
>   			break;
> +		/* TACT bit must be checked before all the following reads */
> +		rmb();
>   		/* Free the original skb. */
>   		if (mdp->tx_skbuff[entry]) {
>   			dma_unmap_single(&ndev->dev, txdesc->addr,
> @@ -1447,6 +1449,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>   	limit = boguscnt;
>   	rxdesc = &mdp->rx_ring[entry];
>   	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
> +		/* RACT bit must be checked before all the following reads */
> +		rmb();
>   		desc_status = edmac_to_cpu(mdp, rxdesc->status);
>   		pkt_len = rxdesc->frame_length;
>
> @@ -1526,6 +1530,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>   			skb_checksum_none_assert(skb);
>   			rxdesc->addr = dma_addr;
>   		}
> +		wmb(); /* RACT bit must be set after all the above writes */
>   		if (entry >= mdp->num_rx_ring - 1)
>   			rxdesc->status |=
>   				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDEL);
> @@ -2195,6 +2200,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>   	}
>   	txdesc->buffer_length = skb->len;
>
> +	wmb(); /* TACT bit must be set after all the above writes */
>   	if (entry >= mdp->num_tx_ring - 1)
>   		txdesc->status |= cpu_to_edmac(mdp, TD_TACT | TD_TDLE);
>   	else

WBR, Sergei
