From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module loadable
 parameter.
Date: Tue, 23 Jan 2007 00:40:46 -0500
Message-ID: <45B59FDE.4080503@garzik.org>
References: <Pine.GSO.4.10.10701190226300.22012-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	alicia.pena@neterion.com, ramkrishna.vepa@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	sriram.rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45320 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932289AbXAWFkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:40:51 -0500
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10701190226300.22012-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju wrote:
> This patch adds two load parameters napi and ufo. Previously NAPI was
> compilation option with these changes wan enable disable NAPI using load
> parameter. Also we are introducing ufo load parameter to enable/disable
> ufo feature
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> ---
> diff -urpN orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
> --- orig/drivers/net/s2io.c	2006-12-21 10:06:58.000000000 +0530
> +++ patch1/drivers/net/s2io.c	2007-01-08 11:56:23.000000000 +0530
> @@ -401,9 +401,10 @@ S2IO_PARM_INT(lro, 0);
>   * aggregation happens until we hit max IP pkt size(64K)
>   */
>  S2IO_PARM_INT(lro_max_pkts, 0xFFFF);
> -#ifndef CONFIG_S2IO_NAPI
>  S2IO_PARM_INT(indicate_max_pkts, 0);
> -#endif
> +
> +S2IO_PARM_INT(napi, 1);
> +S2IO_PARM_INT(ufo, 0);
>  
>  static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
>      {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
> @@ -2275,9 +2276,7 @@ static int fill_rx_buffers(struct s2io_n
>  	struct config_param *config;
>  	u64 tmp;
>  	buffAdd_t *ba;
> -#ifndef CONFIG_S2IO_NAPI
>  	unsigned long flags;
> -#endif
>  	RxD_t *first_rxdp = NULL;
>  
>  	mac_control = &nic->mac_control;
> @@ -2321,12 +2320,15 @@ static int fill_rx_buffers(struct s2io_n
>  			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
>  				  dev->name, rxdp);
>  		}
> -#ifndef CONFIG_S2IO_NAPI
> -		spin_lock_irqsave(&nic->put_lock, flags);
> -		mac_control->rings[ring_no].put_pos =
> -		    (block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
> -		spin_unlock_irqrestore(&nic->put_lock, flags);
> -#endif
> +		if(!napi) {
> +			spin_lock_irqsave(&nic->put_lock, flags);
> +			mac_control->rings[ring_no].put_pos =
> +		    	(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
> +			spin_unlock_irqrestore(&nic->put_lock, flags);
> +		} else {
> +			mac_control->rings[ring_no].put_pos =
> +			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
> +		}	
>  		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
>  			((nic->rxd_mode >= RXD_MODE_3A) &&
>  				(rxdp->Control_2 & BIT(0)))) {
> @@ -2569,7 +2571,7 @@ static void free_rx_buffers(struct s2io_
>   * 0 on success and 1 if there are No Rx packets to be processed.
>   */
>  
> -#if defined(CONFIG_S2IO_NAPI)
> +#if defined(HAVE_NETDEV_POLL)

ACK the entire patch except for the above change:  don't bother with 
HAVE_NETDEV_POLL.  In current kernels you may assume we have it.

	Jeff



