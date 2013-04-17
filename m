From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has
 been received.
Date: Wed, 17 Apr 2013 11:49:25 +0530
Message-ID: <516E3EED.4000200@ti.com>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:40722 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754342Ab3DQGTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 02:19:52 -0400
In-Reply-To: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/16/2013 11:51 PM, Sebastian Andrzej Siewior wrote:
> This driver has usually four interrupts registered with the same ISR.
> The ISR masks the interrupt source in DMA engine and CPSW, disables the
> interrupt and schedules NAPI. After the NAPI routine completes, the
> source is activated and interrupts are re-enabled.
> With threaded-interrupts enabled, the enable/disable might go wrong.
> After the RX interrupt arrived, the core marks the interrupt pending. If
> the TX interrupt arrives before the RX started, then both lines are
> marked pending and both disable the interrupt which then is disabled
> twice. In NAPI complete the interrupt is enabled only once which means
> the four interrupts are still masked and the device plays dead.
>
> While playing with this on my beagle bone I didn't understand why
> the interrupts are deactivated in the first place. According to my
> testing, after calling cpsw_intr_disable() the interrupt is not active
> anymore. I haven't seen the ISR being invoked again until after
> cpsw_poll() enabled them (except for a different interrupt number).
> Therefore I remove this.
>
> In my testing I didn't notice anything unusual except one thing: I start
> a wget of a 126MiB file (which is sttored on MMC) from the beagle bone.
> On the first invocation I receive almost steady 5MiB/sec. In the
> following invocations of wget I see the performance floating between
> 1MiB/sec and 4MiB/sec. It usually ends with overall around 2MiB/sec.
> I couldn't notice nothing wrong. The only difference compared to the
> first invocation is (most likely) that the file is now served from
> memory and not read from MMC which should perform better but not worse.
> After executing "while ((1)); do /bin/true; done" on the beagle bone
> while the file was downloaded, I noticed that the speed rose to 9MiB/sec
> - 10/MiB/sec. Now this looks like power/idle optimization on the beagle
> bone side.
>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   16 ----------------
>   1 file changed, 16 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index e2ba702..acb229c 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -133,19 +133,6 @@ do {								\
>   #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
>   #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
>   
> -#define cpsw_enable_irq(priv)	\
> -	do {			\
> -		u32 i;		\
> -		for (i = 0; i < priv->num_irqs; i++) \
> -			enable_irq(priv->irqs_table[i]); \
> -	} while (0);
> -#define cpsw_disable_irq(priv)	\
> -	do {			\
> -		u32 i;		\
> -		for (i = 0; i < priv->num_irqs; i++) \
> -			disable_irq_nosync(priv->irqs_table[i]); \
> -	} while (0);
> -
>   #define cpsw_slave_index(priv)				\
>   		((priv->data.dual_emac) ? priv->emac_port :	\
>   		priv->data.active_slave)
> @@ -513,13 +500,11 @@ static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
>   
>   	if (likely(netif_running(priv->ndev))) {
>   		cpsw_intr_disable(priv);
> -		cpsw_disable_irq(priv);
>   		napi_schedule(&priv->napi);
>   	} else {
>   		priv = cpsw_get_slave_priv(priv, 1);
>   		if (likely(priv) && likely(netif_running(priv->ndev))) {
>   			cpsw_intr_disable(priv);
> -			cpsw_disable_irq(priv);
>   			napi_schedule(&priv->napi);
>   		}
>   	}
> @@ -540,7 +525,6 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
>   		napi_complete(napi);
>   		cpsw_intr_enable(priv);
>   		cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
> -		cpsw_enable_irq(priv);
>   	}
>   
>   	if (num_rx || num_tx)
When using cpsw_intr_disable, it actually only disables future interrupts
from CPSW ip. But the current interrupt generated to interrupt controller
will be still pending and will not allow ARM to do any thing till either
interrups is disabled or acked, thus CPU will be in CPSW ISR continuously
and system will hang. This patch is applicable only when kernel is always
built with RT enabled which is not the current case in Vanilla kernel

I have tested this patch and it hangs the CPU after net open (CPSW init).

Regards
Mugunthan V N
