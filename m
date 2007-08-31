From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 5/5]S2io: Optimize isr fast path
Date: Fri, 31 Aug 2007 09:05:41 -0400
Message-ID: <46D81225.5090209@garzik.org>
References: <1187223158.23940.339.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53790 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbXHaNFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:05:42 -0400
In-Reply-To: <1187223158.23940.339.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Optimized interrupt routine fast path.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

patch description is completely inadequate.  how was it optimized?  what 
are the gains / why is this patch worth having?


> diff -Nurp patch4/drivers/net/s2io.c patch5/drivers/net/s2io.c
> --- patch4/drivers/net/s2io.c	2007-08-15 08:42:14.000000000 -0700
> +++ patch5/drivers/net/s2io.c	2007-08-15 08:42:51.000000000 -0700
> @@ -84,7 +84,7 @@
>  #include "s2io.h"
>  #include "s2io-regs.h"
>  
> -#define DRV_VERSION "2.0.26.1"
> +#define DRV_VERSION "2.0.26.2"
>  
>  /* S2io Driver name & version. */
>  static char s2io_driver_name[] = "Neterion";
> @@ -4917,71 +4917,76 @@ static irqreturn_t s2io_isr(int irq, voi
>  	 * 1. Rx of packet.
>  	 * 2. Tx complete.
>  	 * 3. Link down.
> -	 * 4. Error in any functional blocks of the NIC.
>  	 */
>  	reason = readq(&bar0->general_int_status);
>  
> -	if (!reason) {
> -		/* The interrupt was not raised by us. */
> +	if (unlikely(reason == S2IO_MINUS_ONE) ) {
> +		/* Nothing much can be done. Get out */
>  		atomic_dec(&sp->isr_cnt);
> -		return IRQ_NONE;
> -	}
> -	else if (unlikely(reason == S2IO_MINUS_ONE) ) {
> -		/* Disable device and get out */
> -		atomic_dec(&sp->isr_cnt);
> -		return IRQ_NONE;
> +		return IRQ_HANDLED;
>  	}
>  
> -	if (napi) {
> -		if (reason & GEN_INTR_RXTRAFFIC) {
> -			if ( likely ( netif_rx_schedule_prep(dev)) ) {
> -				__netif_rx_schedule(dev);
> -				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
> +	if (reason & (GEN_INTR_RXTRAFFIC |
> +		GEN_INTR_TXTRAFFIC | GEN_INTR_TXPIC))
> +	{
> +		writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
> +
> +		if (config->napi) {
> +			if (reason & GEN_INTR_RXTRAFFIC) {
> +				if ( likely (netif_rx_schedule_prep(dev)) ) {
> +					__netif_rx_schedule(dev);
> +					writeq(S2IO_MINUS_ONE,
> +						&bar0->rx_traffic_mask);
> +				} else
> +					writeq(S2IO_MINUS_ONE,
> +						&bar0->rx_traffic_int);
>  			}
> -			else
> +		} else {
> +			/*
> +			 * rx_traffic_int reg is an R1 register, writing all 1's
> +			 * will ensure that the actual interrupt causing bit
> +			 * get's cleared and hence a read can be avoided.
> +			 */
> +			if (reason & GEN_INTR_RXTRAFFIC)
>  				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
> +
> +			for (i = 0; i < config->rx_ring_num; i++)
> +				rx_intr_handler(&mac_control->rings[i]);
>  		}
> -	} else {
> +
>  		/*
> -		 * Rx handler is called by default, without checking for the
> -		 * cause of interrupt.
> -		 * rx_traffic_int reg is an R1 register, writing all 1's
> +		 * tx_traffic_int reg is an R1 register, writing all 1's
>  		 * will ensure that the actual interrupt causing bit get's
>  		 * cleared and hence a read can be avoided.
>  		 */
> -		if (reason & GEN_INTR_RXTRAFFIC)
> -			writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
> +		if (reason & GEN_INTR_TXTRAFFIC)
> +			writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
>  
> -		for (i = 0; i < config->rx_ring_num; i++) {
> -			rx_intr_handler(&mac_control->rings[i]);
> -		}
> -	}
> +		for (i = 0; i < config->tx_fifo_num; i++)
> +			tx_intr_handler(&mac_control->fifos[i]);
>  
> -	/*
> -	 * tx_traffic_int reg is an R1 register, writing all 1's
> -	 * will ensure that the actual interrupt causing bit get's
> -	 * cleared and hence a read can be avoided.
> -	 */
> -	if (reason & GEN_INTR_TXTRAFFIC)
> -		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
> +		if (reason & GEN_INTR_TXPIC)
> +			s2io_txpic_intr_handle(sp);
>  
> -	for (i = 0; i < config->tx_fifo_num; i++)
> -		tx_intr_handler(&mac_control->fifos[i]);
> +		/*
> +		 * Reallocate the buffers from the interrupt handler itself.
> +		 */
> +		if (!config->napi) {
> +			for (i = 0; i < config->rx_ring_num; i++)
> +				s2io_chk_rx_buffers(sp, i);
> +		}
> +		writeq(sp->general_int_mask, &bar0->general_int_mask);
> +		readl(&bar0->general_int_status);
>  
> -	if (reason & GEN_INTR_TXPIC)
> -		s2io_txpic_intr_handle(sp);
> -	/*
> -	 * If the Rx buffer count is below the panic threshold then
> -	 * reallocate the buffers from the interrupt handler itself,
> -	 * else schedule a tasklet to reallocate the buffers.
> -	 */
> -	if (!napi) {
> -		for (i = 0; i < config->rx_ring_num; i++)
> -			s2io_chk_rx_buffers(sp, i);
> -	}
> +		atomic_dec(&sp->isr_cnt);
> +		return IRQ_HANDLED;
>  
> -	writeq(0, &bar0->general_int_mask);
> -	readl(&bar0->general_int_status);
> +	}
> +	else if (!reason) {
> +		/* The interrupt was not raised by us */
> +		atomic_dec(&sp->isr_cnt);
> +		return IRQ_NONE;
> +	}
>  
>  	atomic_dec(&sp->isr_cnt);
>  	return IRQ_HANDLED;
> @@ -7109,6 +7114,14 @@ static void s2io_rem_isr(struct s2io_nic
>  	struct net_device *dev = sp->dev;
>  	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
>  
> +	/* Waiting till all Interrupt handlers are complete */
> +	do {
> +		if (!atomic_read(&sp->isr_cnt))
> +			break;
> +		msleep(10);
> +		cnt++;
> +	} while(cnt < 5);
> +
>  	if (sp->config.intr_type == MSI_X) {
>  		int i;
>  		u16 msi_control;
> @@ -7138,14 +7151,6 @@ static void s2io_rem_isr(struct s2io_nic
>  	} else {
>  		free_irq(sp->pdev->irq, dev);
>  	}
> -	/* Waiting till all Interrupt handlers are complete */
> -	cnt = 0;
> -	do {
> -		msleep(10);
> -		if (!atomic_read(&sp->isr_cnt))
> -			break;
> -		cnt++;
> -	} while(cnt < 5);
>  }

this is bogus code -- you should use synchronize_irq() and other 
standard kernel functions, rather than duplicating all that state in the 
driver-private structs

