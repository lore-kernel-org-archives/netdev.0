From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Tue, 14 Sep 2010 09:27:23 +0200
Message-ID: <4C8F23DB.2040105@voltaire.com>
References: <adapqx5rtez.fsf@cisco.com>	<alpine.DEB.2.00.1008261613160.24174@router.home>	<alpine.DEB.2.00.1008261629440.24174@router.home>	<20100826.151553.242147157.davem@davemloft.net>	<20100826222146.GA23025@obsidianresearch.com>	<alpine.DEB.2.00.1008261825490.26351@router.home>	<20100826234342.GA24333@obsidianresearch.com> <alpine.DEB.2.00.1008270827280.11792@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	linux-rdma@vger.kernel.org, yosefe@voltaire.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux.com>, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:16336 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752034Ab0INH13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 03:27:29 -0400
In-Reply-To: <alpine.DEB.2.00.1008270827280.11792@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> Here is the patch somewhat cleaned up with PACKET_BROADCAST.
> Subject: [IPoIB] Identify multicast packets and fix IGMP breakage V3
>   

I don't see this patch in Roland's for-next branch nor Dave's 
net-next-2.6 tree, is anything else needed to merge that?

Or.

> IGMP processing is broken because the IPOIB does not set the
> skb->pkt_type the right way for Multicast traffic. All incoming
> packets are set to PACKET_HOST which means that the igmp_recv()
> function will ignore the IGMP broadcasts/multicasts.
>
> This in turn means that the IGMP timers are firing and are sending
> information about multicast subscriptions unnecessarily. In a large
> private network this can cause traffic spikes.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> ---
>
> Index: linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> ===================================================================
> --- linux-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2010-08-26 18:24:07.842079559 -0500
> +++ linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2010-08-27 08:26:37.929641162 -0500
> @@ -223,6 +223,7 @@
>  	unsigned int wr_id = wc->wr_id & ~IPOIB_OP_RECV;
>  	struct sk_buff *skb;
>  	u64 mapping[IPOIB_UD_RX_SG];
> +	union ib_gid *dgid;
>
>  	ipoib_dbg_data(priv, "recv completion: id %d, status: %d\n",
>  		       wr_id, wc->status);
> @@ -271,6 +272,21 @@
>  	ipoib_ud_dma_unmap_rx(priv, mapping);
>  	ipoib_ud_skb_put_frags(priv, skb, wc->byte_len);
>
> +	/* First byte of dgid signals multicast when 0xff */
> +	dgid = &((struct ib_grh *)skb->data)->dgid;
> +
> +	if (!(wc->wc_flags & IB_WC_GRH) || dgid->raw[0] != 0xff)
> +
> +		skb->pkt_type = PACKET_HOST;
> +
> +	else if (memcmp(dgid, dev->broadcast + 4, sizeof(union ib_gid)) == 0)
> +
> +		skb->pkt_type = PACKET_BROADCAST;
> +
> +	else
> +
> +		skb->pkt_type = PACKET_MULTICAST;
> +
>  	skb_pull(skb, IB_GRH_BYTES);
>
>  	skb->protocol = ((struct ipoib_header *) skb->data)->proto;
> @@ -281,9 +297,6 @@
>  	dev->stats.rx_bytes += skb->len;
>
>  	skb->dev = dev;
> -	/* XXX get correct PACKET_ type here */
> -	skb->pkt_type = PACKET_HOST;
> -
>  	if (test_bit(IPOIB_FLAG_CSUM, &priv->flags) && likely(wc->csum_ok))
>  		skb->ip_summed = CHECKSUM_UNNECESSARY;
>
>   

