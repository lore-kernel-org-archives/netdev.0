From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to generic iopa
Date: Tue, 6 Feb 2007 08:26:50 -0600
Message-ID: <001EB06E-FC1D-4F0A-A910-8E08EE0B8CE2@kernel.crashing.org>
References: <45C86715.6090600@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:56647 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938AbXBFO1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 09:27:44 -0500
In-Reply-To: <45C86715.6090600@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 6, 2007, at 5:31 AM, Li Yang wrote:

> Get rid of private immrbar_virt_to_phys() routine and
> use generic iopa().

Nack. iopa() isn't that generic, shouldn't we really be using the dma  
mapping API here?

- k

>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> drivers/net/ucc_geth.c |   29 ++++++-----------------------
> 1 files changed, 6 insertions(+), 23 deletions(-)
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 7e4b23c..722a89f 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3065,21 +3065,11 @@ static int ucc_geth_startup(struct  
> ucc_geth_private *ugeth)
> 		endOfRing =
> 		    ugeth->p_tx_bd_ring[i] + (ug_info->bdRingLenTx[i] -
> 					      1) * sizeof(struct qe_bd);
> -		if (ugeth->ug_info->uf_info.bd_mem_part == MEM_PART_SYSTEM) {
> -			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
> -				 (u32) virt_to_phys(ugeth->p_tx_bd_ring[i]));
> -			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
> +		out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
> +				iopa((unsigned long)ugeth->p_tx_bd_ring[i]));
> +		out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
> 				 last_bd_completed_address,
> -				 (u32) virt_to_phys(endOfRing));
> -		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
> -			   MEM_PART_MURAM) {
> -			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
> -				 (u32) immrbar_virt_to_phys(ugeth->
> -							    p_tx_bd_ring[i]));
> -			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
> -				 last_bd_completed_address,
> -				 (u32) immrbar_virt_to_phys(endOfRing));
> -		}
> +				iopa((unsigned long)endOfRing));
> 	}
> 	/* schedulerbasepointer */
> @@ -3331,15 +3321,8 @@ static int ucc_geth_startup(struct  
> ucc_geth_private *ugeth)
> 	/* Setup the table */
> 	/* Assume BD rings are already established */
> 	for (i = 0; i < ug_info->numQueuesRx; i++) {
> -		if (ugeth->ug_info->uf_info.bd_mem_part == MEM_PART_SYSTEM) {
> -			out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
> -				 (u32) virt_to_phys(ugeth->p_rx_bd_ring[i]));
> -		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
> -			   MEM_PART_MURAM) {
> -			out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
> -				 (u32) immrbar_virt_to_phys(ugeth->
> -							    p_rx_bd_ring[i]));
> -		}
> +		out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
> +			 iopa((unsigned long)ugeth->p_rx_bd_ring[i]));
> 		/* rest of fields handled by QE */
> 	}
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

