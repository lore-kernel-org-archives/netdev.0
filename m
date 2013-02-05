From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next] gianfar: dont conditionally alloc Rx/Err irq
 structs
Date: Tue, 5 Feb 2013 10:56:00 +0200
Message-ID: <5110C920.6090504@freescale.com>
References: <1360007382-7876-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:33047
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755624Ab3BEI4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 03:56:31 -0500
In-Reply-To: <1360007382-7876-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/4/2013 9:49 PM, Paul Gortmaker wrote:
> Commit ee873fda3bec7c668407b837fc5519eb961fcd37
>
>      "gianfar: Pack struct gfar_priv_grp into three cachelines"
>
> causes the following null dereference at driver init on sbc8548:
>
>     libphy: Freescale PowerQUICC MII Bus: probed
>     Unable to handle kernel paging request for data at address 0x00000000
>     Faulting instruction address: 0xc01d6a38
>     Oops: Kernel access of bad area, sig: 11 [#1]
>     [...]
>     NIP [c01d6a38] gfar_parse_group+0x228/0x280
>     LR [c01d6a34] gfar_parse_group+0x224/0x280
>     Call Trace:
>     [ef82dd60] [c01d6a34] gfar_parse_group+0x224/0x280 (unreliable)
>     [ef82dd90] [c01d73a4] gfar_probe+0x284/0xfe0
>
> The reason is that the commit also changed the allocation of the
> Rx and error handling irq structs to be skipped for !MQ_MG_MODE.
> In the !MQ_MG_MODE case, only the Tx irq struct is allocated.
>
> Digging further, we see that MQ_MG_MODE is set only if we find
> the OF compatible string "fsl,etsec2".
>
> A quick grep in the dts directory shows lots of boards that support
> Rx/Tx/Err, but without this specific compat string.  And hence they
> go after the unallocated Rx/Error structs and cause the above oops.
>
> Hence such a change can not be deployed until all the dts files
> are updated and sufficiently deployed.  Further, the optimization
> is of limited value, since the kmalloc'd struct in question has only
> a single unsigned int, and an (IFNAMSIZ + 6) sized string.
>
> Note that no changes to the freeing code are needed here, as it
> already did an unconditional free of Rx/Tx/Error gfar_irqinfo.
>
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>   drivers/net/ethernet/freescale/gianfar.c | 16 ++++------------
>   1 file changed, 4 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 19c54a0..75734bf 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -580,19 +580,11 @@ static int gfar_parse_group(struct device_node *np,
>   	u32 *queue_mask;
>   	int i;
>
> -	if (priv->mode == MQ_MG_MODE) {
> -		for (i = 0; i < GFAR_NUM_IRQS; i++) {
> -			grp->irqinfo[i] = kzalloc(sizeof(struct gfar_irqinfo),
> -						  GFP_KERNEL);
> -			if (!grp->irqinfo[i])
> -				return -ENOMEM;
> -		}
> -	} else {
> -		grp->irqinfo[GFAR_TX] = kzalloc(sizeof(struct gfar_irqinfo),
> -						GFP_KERNEL);
> -		if (!grp->irqinfo[GFAR_TX])
> +	for (i = 0; i < GFAR_NUM_IRQS; i++) {
> +		grp->irqinfo[i] = kzalloc(sizeof(struct gfar_irqinfo),
> +					  GFP_KERNEL);
> +		if (!grp->irqinfo[i])
>   			return -ENOMEM;
> -		grp->irqinfo[GFAR_RX] = grp->irqinfo[GFAR_ER] = NULL;
>   	}
>
>   	grp->regs = of_iomap(np, 0);
>
Thanks Paul.
I guess I was so fixated on the "FEC" model legacy code that I didn't
pay attention to the SQ_SG_MODE (which is btw a misleading mode name)
case that also features multiple interrupt sources.
Thanks,
Claudiu
