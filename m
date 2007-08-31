From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/5]S2io: Enable all the error and alarm indications
Date: Fri, 31 Aug 2007 09:01:13 -0400
Message-ID: <46D81119.6080700@garzik.org>
References: <1187223130.23940.331.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53749 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964921AbXHaNBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:01:17 -0400
In-Reply-To: <1187223130.23940.331.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Added support to unmask entire set of device errors and alarms.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
> --- orig/drivers/net/s2io.c	2007-08-15 08:04:06.000000000 -0700
> +++ patch1/drivers/net/s2io.c	2007-08-15 08:55:53.000000000 -0700
> @@ -892,8 +892,9 @@ static void free_shared_mem(struct s2io_
>  					k++;
>  				}
>  				kfree(mac_control->rings[i].ba[j]);
> -				nic->mac_control.stats_info->sw_stat.mem_freed 				+= (sizeof(struct buffAdd) * 
> -				(rxd_count[nic->rxd_mode] + 1));
> +				nic->mac_control.stats_info->sw_stat.mem_freed += 
> +					(sizeof(struct buffAdd) * 
> +					(rxd_count[nic->rxd_mode] + 1));
>  			}
>  			kfree(mac_control->rings[i].ba);
>  			nic->mac_control.stats_info->sw_stat.mem_freed += 
> @@ -1732,6 +1733,365 @@ static int s2io_link_fault_indication(st
>  		return MAC_RMAC_ERR_TIMER;
>  }
>  
> +void en_dis_err_alarms(struct s2io_nic *nic, u16 mask, int flag)
> +{
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
> +	register u64 val64 = 0, temp64 = 0, gen_int_mask = 0;
> +
> +	if (mask & TX_DMA_INTR) {
> +		gen_int_mask |= TXDMA_INT_M;
> +
> +		if (flag == ENABLE_INTRS) {
> +
> +			val64 = TXDMA_TDA_INT|TXDMA_PFC_INT|TXDMA_PCC_INT
> +				|TXDMA_TTI_INT|TXDMA_LSO_INT|TXDMA_TPA_INT
> +				|TXDMA_SM_INT;
> +			temp64 = readq(&bar0->txdma_int_mask);
> +			temp64 &= ~((u64) val64);
> +			writeq(temp64, &bar0->txdma_int_mask);


reduce the size of this huge functions by creating a helper function 
whose use would look something like

	writebits(TXDMA_TDA_INT|TXDMA_PFC_INT|TXDMA_PCC_INT|
		  TXDMA_TTI_INT|TXDMA_LSO_INT|TXDMA_TPA_INT|
		  TXDMA_SM_INT,
		  flag,
		  &bar0->txdma_int_mask);

That eliminates the wholesale duplication of code based on the 
'flags==ENABLE_INTRS' test, and overall increases readability and 
decreases code size

