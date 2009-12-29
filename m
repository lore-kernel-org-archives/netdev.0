From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Tue, 29 Dec 2009 12:39:05 -0500
Message-ID: <4B3A3EB9.9070008@majjas.com>
References: <4B300A2A.8040305@gmail.com> <4B300E30.9090707@majjas.com>
 <4B3114E3.1070602@majjas.com> <4B329FA3.9090904@majjas.com>
 <20091223230102.4bb0100e.akpm@linux-foundation.org>
 <4B34E847.8010809@majjas.com> <20091225152200.1cf11dfe@nehalam>
 <4B3581C7.8000702@majjas.com> <20091226095723.7ac82b18@nehalam>
 <4B367409.5060202@majjas.com> <4B379378.4000102@majjas.com>
 <20091227102238.0df149f9@nehalam> <4B37B7E2.5070307@majjas.com>
 <20091229093023.3ad24786@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751488AbZL2Rjl@vger.kernel.org>
In-reply-to: <20091229093023.3ad24786@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok - I can also try with VT-D disabled for another data point.
On 12/29/2009 12:30 PM, Stephen Hemminger wrote:
> There could be DMA problems, either because chip isn't remembering
> upper address, or because of lack of wires from chip to memory controller;
> there have been problems on motherboards where I/O devices couldn't access
> all of memory.
>
> Try this, it forces each transmit to have full 64 bit address. It drops an
> optimization that was done to reduce the number of transmit descriptors
> used.
>
> --- a/drivers/net/sky2.c	2009-12-29 09:23:37.114074275 -0800
> +++ b/drivers/net/sky2.c	2009-12-29 09:26:38.699912035 -0800
> @@ -1038,10 +1038,11 @@ static void tx_init(struct sky2_port *sk
>   	sky2->tx_tcpsum = 0;
>   	sky2->tx_last_mss = 0;
>
> -	le = get_tx_le(sky2,&sky2->tx_prod);
> -	le->addr = 0;
> -	le->opcode = OP_ADDR64 | HW_OWNER;
> -	sky2->tx_last_upper = 0;
> +	if (sizeof(dma_addr_t) == sizeof(u32)) {
> +		le = get_tx_le(sky2,&sky2->tx_prod);
> +		le->addr = 0;
> +		le->opcode = OP_ADDR64 | HW_OWNER;
> +	}
>   }
>
>   /* Update chip's next pointer */
> @@ -1669,10 +1670,9 @@ static netdev_tx_t sky2_xmit_frame(struc
>
>   	/* Send high bits if needed */
>   	upper = upper_32_bits(mapping);
> -	if (upper != sky2->tx_last_upper) {
> +	if (sizeof(mapping)>  sizeof(u32)) {
>   		le = get_tx_le(sky2,&slot);
>   		le->addr = cpu_to_le32(upper);
> -		sky2->tx_last_upper = upper;
>   		le->opcode = OP_ADDR64 | HW_OWNER;
>   	}
>
> @@ -1762,10 +1762,9 @@ static netdev_tx_t sky2_xmit_frame(struc
>   			goto mapping_unwind;
>
>   		upper = upper_32_bits(mapping);
> -		if (upper != sky2->tx_last_upper) {
> +		if (sizeof(mapping)>  sizeof(u32)) {
>   			le = get_tx_le(sky2,&slot);
>   			le->addr = cpu_to_le32(upper);
> -			sky2->tx_last_upper = upper;
>   			le->opcode = OP_ADDR64 | HW_OWNER;
>   		}
>
> --- a/drivers/net/sky2.h	2009-12-29 09:23:37.164072886 -0800
> +++ b/drivers/net/sky2.h	2009-12-29 09:25:15.302197993 -0800
> @@ -2191,7 +2191,6 @@ struct sky2_port {
>
>   	u16		     tx_pending;
>   	u16		     tx_last_mss;
> -	u32		     tx_last_upper;
>   	u32		     tx_tcpsum;
>
>   	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>    
