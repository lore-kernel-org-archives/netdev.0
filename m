From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Subject: RE: [PATCH RESEND 2/2] bnx2x: Fix kernel crash and data miscompare
 after EEH recovery
Date: Wed, 28 May 2014 08:38:04 +0000
Message-ID: <87B4DDAD5EAFA041BDC28F314593782D01748FFB@avmb3.qlogic.org>
References: <20140527191122.750711568@linux.vnet.ibm.com>
 <20140527191235.743680910@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>, Milton Miller <miltonm@bga.com>
To: "wenxiong@linux.vnet.ibm.com" <wenxiong@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:9619 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752520AbaE1IiM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 04:38:12 -0400
In-Reply-To: <20140527191235.743680910@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wen
> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of wenxiong@linux.vnet.ibm.com
> Sent: Tuesday, May 27, 2014 10:11 PM
> To: David Miller
> Cc: Ariel Elior; netdev; Milton Miller; Wen Xiong
> Subject: [PATCH RESEND 2/2] bnx2x: Fix kernel crash and data miscompare
> after EEH recovery
>
> A rmb() is required to ensure that the CQE is not read before it is written by
> the adapter DMA.  PCI ordering rules will make sure the other fields are
> written before the marker at the end of struct eth_fast_path_rx_cqe but
> without rmb() a weakly ordered processor can process stale data.
>
> Without the barrier we have observed various crashes including
> bnx2x_tpa_start being called on queues not stopped (resulting in message
> start of bin not in stop) and NULL pointer exceptions from bnx2x_rx_int.
>
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Wen Xiong <wenxiong@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> Index: b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> ===================================================================
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c 2014-05-23
> 10:34:21.000000000 -0500
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c 2014-05-27
> 13:51:12.067764759 -0500
> @@ -906,6 +906,18 @@ static int bnx2x_rx_int(struct bnx2x_fas
>               bd_prod = RX_BD(bd_prod);
>               bd_cons = RX_BD(bd_cons);
>
> +             /* A rmb() is required to ensure that the CQE is not read
> +              * before it is written by the adapter DMA.  PCI ordering
> +              * rules will make sure the other fields are written before
> +              * the marker at the end of struct eth_fast_path_rx_cqe
> +              * but without rmb() a weakly ordered processor can process
> +              * stale data.  Without the barrier we have observed various
> +              * crashes including bnx2x_tpa_start being called on queues
> +              * not stopped (resulting in message start of bin not in
> +              * stop) and NULL pointer exceptions from bnx2x_rx_int.
> +             */
Can you please drop third sentence from the comment or rephrase it in more generic way like:
Without the barrier TPA state-machine might enter inconsistent state and kernel stack might be provided with incorrect packet description - these lead to various kernel crashes.

Thanks
Dmitry
> +             rmb();
> +
>               cqe_fp_flags = cqe_fp->type_error_flags;
>               cqe_fp_type = cqe_fp_flags &
> ETH_FAST_PATH_RX_CQE_TYPE;
>
>
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
