From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 06/11] bnxt_en: Improve -ENOMEM logic in NAPI
 poll loop.
Date: Mon, 28 Aug 2017 12:05:04 -0700
Message-ID: <20170828190504.jdlbyemn5xvmalsr@kafai-mba.dhcp.thefacebook.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
 <1503942035-24924-7-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50811 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751284AbdH1TFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:05:09 -0400
Content-Disposition: inline
In-Reply-To: <1503942035-24924-7-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 01:40:30PM -0400, Michael Chan wrote:
> If we cannot allocate RX buffers in the NAPI poll loop when processing
> an RX event, the current code does not count that event towards the NAPI
> budget.  This can cause us to potentially loop forever in NAPI if we
> consistently cannot allocate new buffers.  Improve it by counting
> -ENOMEM event as 1 towards the NAPI budget.
>
> Cc: Martin KaFai Lau <kafai@fb.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
Thanks for fixing it.

Reported-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>

> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index 1afb408..a34fcdd 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -1850,6 +1850,13 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
>  							   &event);
>  			if (likely(rc >= 0))
>  				rx_pkts += rc;
> +			/* Increment rx_pkts when rc is -ENOMEM to count towards
> +			 * the NAPI budget.  Otherwise, we may potentially loop
> +			 * here forever if we consistently cannot allocate
> +			 * buffers.
> +			 */
> +			else if (rc == -ENOMEM)
> +				rx_pkts++;
>  			else if (rc == -EBUSY)	/* partial completion */
>  				break;
>  		} else if (unlikely((TX_CMP_TYPE(txcmp) ==
> --
> 1.8.3.1
>
