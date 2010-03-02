From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Tue, 2 Mar 2010 04:50:59 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2B40C@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1267351922.10409.2.camel@lb-tlvb-vladz>
 <20100301133339.GB2440@dhcp-lab-161.englab.brq.redhat.com>
 <1267466347.19491.31.camel@nseg_linux_HP1.broadcom.com>
 <20100302113032.GA2362@dhcp-lab-161.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4969 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718Ab0CBMvK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 07:51:10 -0500
In-Reply-To: <20100302113032.GA2362@dhcp-lab-161.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw barrier() is not a memory barrier - it's a compiler barrier. I don't think removing it from bnx2x_tx_avail() will improve anything. If u think I'm wrong, could u, pls., provide a specific example.

Regarding the patch u've proposed - I don't see any obvious benefit in the code change u've suggested except for replacing the smp_wmb() to smp_mb() in the bnx2x_tx_int() and would prefer to wait for Dave's reply on that matter.

Let's recall that the bxn2x_start_xmit() is called under tx_lock(), so no additional memory barriers needed to ensure that bnx2x_tx_avail() has fresh values of BD consumer and producer at the beginning of bnx2x_start_xmit(). That's why we don't need the more complicated logic putting the queue asleep at the beginning of bnx2x_start_xmit() as we need at the end. That's why I think your "goto" change in the beginning of bnx2x_start_xmit() is suboptimal.

Thanks,
vlad

> -----Original Message-----
> From: Stanislaw Gruszka [mailto:sgruszka@redhat.com] 
> Sent: Tuesday, March 02, 2010 1:31 PM
> To: Michael Chan
> Cc: Vladislav Zolotarov; netdev@vger.kernel.org; 
> davem@davemloft.net; Eilon Greenstein; Matthew Carlson
> Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
> 
> On Mon, Mar 01, 2010 at 09:59:07AM -0800, Michael Chan wrote:
> > > There is still difference between what we have in bnx2x 
> and bnx2/tg3
> > > regarding memory barriers in tx_poll/start_xmit code. 
> Mainly we have
> > > smp_mb() in bnx2/tg3_tx_avail(), and in bnx2/tg3_tx_int() 
> is smp_mb()
> > > not smp_wmb(). I do not see that bnx2x is wrong, but 
> would like to know
> > > why there is a difference, maybe bnx2/tg3 should be changed?
> > > 
> > 
> > The memory barrier in tx_int() is to make the tx index update happen
> > before the netif_tx_queue_stopped() check.  The barrier is 
> to prevent a
> > situation like this:
> > 
> >     CPU0					CPU1
> >     start_xmit()
> >     	if (tx_ring_full) {
> >     						tx_int()
> >     							
> if (!netif_tx_queue_stopped)
> >     		netif_tx_stop_queue()
> >     		if (!tx_ring_full)
> >     							
> update_tx_index 
> >     			netif_tx_wake_queue()
> >     	}
> >     
> > 
> > The update_tx_index code is before the if statement in 
> program order,
> > but the CPU and/or compiler can reorder it as shown above. 
> smp_mb() will
> > prevent that.  Will smp_wmb() prevent that as well?
> 
> No. smp_wmb() affect only write orders on CPU1 performing tx_int(), so
> that should be fixed in bnx2x.
> 
> Regarding memory barrier in tx_avail(), I don't think it its 
> needed for
> anything, except maybe usage at the beginning of 
> start_xmit(), but we can
> just remove that like in the patch below. I going to post "official"
> patches for tg3, bnx2 and bnx2x, if no nobody has nothing against.
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index ed785a3..0f406b8 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -893,7 +893,6 @@ static inline u16 bnx2x_tx_avail(struct 
> bnx2x_fastpath *fp)
>  	u16 prod;
>  	u16 cons;
>  
> -	barrier(); /* Tell compiler that prod and cons can change */
>  	prod = fp->tx_bd_prod;
>  	cons = fp->tx_bd_cons;
>  
> @@ -963,9 +962,8 @@ static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
>  	 * start_xmit() will miss it and cause the queue to be stopped
>  	 * forever.
>  	 */
> -	smp_wmb();
> +	smp_mb();
>  
> -	/* TBD need a thresh? */
>  	if (unlikely(netif_tx_queue_stopped(txq))) {
>  		/* Taking tx_lock() is needed to prevent 
> reenabling the queue
>  		 * while it's empty. This could have happen if 
> rx_action() gets
> @@ -11177,10 +11175,9 @@ static netdev_tx_t 
> bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
>  	struct eth_tx_parse_bd *pbd = NULL;
>  	u16 pkt_prod, bd_prod;
> -	int nbd, fp_index;
> +	int nbd, fp_index, i, ret;
>  	dma_addr_t mapping;
>  	u32 xmit_type = bnx2x_xmit_type(bp, skb);
> -	int i;
>  	u8 hlen = 0;
>  	__le16 pkt_size = 0;
>  
> @@ -11195,10 +11192,9 @@ static netdev_tx_t 
> bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	fp = &bp->fp[fp_index];
>  
>  	if (unlikely(bnx2x_tx_avail(fp) < 
> (skb_shinfo(skb)->nr_frags + 3))) {
> -		fp->eth_q_stats.driver_xoff++;
> -		netif_tx_stop_queue(txq);
>  		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
> -		return NETDEV_TX_BUSY;
> +		ret = NETDEV_TX_BUSY;				
> 		
> +		goto stop_queue;
>  	}
>  
>  	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  
> protocol(%x,%x)"
> @@ -11426,19 +11422,24 @@ static netdev_tx_t 
> bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	mmiowb();
>  
>  	fp->tx_bd_prod += nbd;
> -
> -	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
> -		netif_tx_stop_queue(txq);
> -		/* We want bnx2x_tx_int to "see" the updated tx_bd_prod
> -		   if we put Tx into XOFF state. */
> -		smp_mb();
> -		fp->eth_q_stats.driver_xoff++;
> -		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
> -			netif_tx_wake_queue(txq);
> -	}
>  	fp->tx_pkt++;
> +	
> +	ret = NETDEV_TX_OK;
> +	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3))
> +		goto stop_queue;
> +
> +	return ret;
>  
> -	return NETDEV_TX_OK;
> +stop_queue:
> +	netif_tx_stop_queue(txq);
> +	/* paired barrier is in bnx2x_tx_int(), update of tx_bd_cons
> +	 * have to be visable here, after we XOFF bit setting */
> +	smp_mb();
> +	fp->eth_q_stats.driver_xoff++;
> +	if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
> +		netif_tx_wake_queue(txq);
> +	
> +	return ret;
>  }
>  
>  /* called with rtnl_lock */
> 
> 
