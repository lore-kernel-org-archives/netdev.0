From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/7] via-velocity: Enable support for adaptive interrupt
 supression
Date: Fri, 20 Nov 2009 09:05:05 -0800
Message-ID: <20091120090505.0fa700e6@nehalam>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091120161217.45e611a6@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	romieu@fr.zoreil.com
To: Simon Kagstrom <simon.kagstrom@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40756 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbZKTRFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 12:05:15 -0500
In-Reply-To: <20091120161217.45e611a6@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Nov 2009 16:12:17 +0100
Simon Kagstrom <simon.kagstrom@netinsight.net> wrote:

> (From the upstream VIA driver). This reduces the amount of interrupts
> under load and improves performance by quite a bit by reducing the
> amount of work for the CPU.
> 
> Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
> ---
>  drivers/net/via-velocity.c |   70 +++++++++++++++++++++++++++++++++++++++++++-
>  drivers/net/via-velocity.h |    7 ++++-
>  2 files changed, 75 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index 944a678..932339b 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
> @@ -364,6 +364,26 @@ static int rx_copybreak = 200;
>  module_param(rx_copybreak, int, 0644);
>  MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
>  
> +#define TXQUEUE_TIMER_DEF     0x59
> +#define TXQUEUE_TIMER_MIN     0x00
> +#define TXQUEUE_TIMER_MAX     0xFF
> +VELOCITY_PARAM(txqueue_timer, "Tx Queue Empty defer timer");
> +
> +#define RXQUEUE_TIMER_DEF     0x14
> +#define RXQUEUE_TIMER_MIN     0x00
> +#define RXQUEUE_TIMER_MAX     0xFF
> +VELOCITY_PARAM(rxqueue_timer, "Rx Queue Empty defer timer");
> +
> +#define TX_INTSUP_DEF       0x1F
> +#define TX_INTSUP_MIN       0x01
> +#define TX_INTSUP_MAX       0x3F
> +VELOCITY_PARAM(tx_intsup, "Tx Interrupt Suppression Threshold");
> +
> +#define RX_INTSUP_DEF       0x1F
> +#define RX_INTSUP_MIN       0x01
> +#define RX_INTSUP_MAX       0x3F
> +VELOCITY_PARAM(rx_intsup, "Rx Interrupt Suppression Threshold");
> +
>  #ifdef CONFIG_PM
>  static DEFINE_SPINLOCK(velocity_dev_list_lock);
>  static LIST_HEAD(velocity_dev_list);
> @@ -517,6 +537,10 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
>  	velocity_set_int_opt((int *) &opts->spd_dpx, speed_duplex[index], MED_LNK_MIN, MED_LNK_MAX, MED_LNK_DEF, "Media link mode", devname);
>  	velocity_set_int_opt((int *) &opts->wol_opts, wol_opts[index], WOL_OPT_MIN, WOL_OPT_MAX, WOL_OPT_DEF, "Wake On Lan options", devname);
>  	velocity_set_int_opt((int *) &opts->int_works, int_works[index], INT_WORKS_MIN, INT_WORKS_MAX, INT_WORKS_DEF, "Interrupt service works", devname);
> +	velocity_set_int_opt((int *) &opts->txqueue_timer, txqueue_timer[index], TXQUEUE_TIMER_MIN, TXQUEUE_TIMER_MAX, TXQUEUE_TIMER_DEF, "TX queue empty defer timer", devname);
> +	velocity_set_int_opt((int *) &opts->rxqueue_timer, rxqueue_timer[index], RXQUEUE_TIMER_MIN, RXQUEUE_TIMER_MAX, RXQUEUE_TIMER_DEF, "RX queue empty defer timer", devname);
> +	velocity_set_int_opt((int *) &opts->tx_intsup, tx_intsup[index], TX_INTSUP_MIN, TX_INTSUP_MAX, TX_INTSUP_DEF, "TX interrupt suppression threshold", devname);
> +	velocity_set_int_opt((int *) &opts->rx_intsup, rx_intsup[index], RX_INTSUP_MIN, RX_INTSUP_MAX, RX_INTSUP_DEF, "RX interrupt suppression threshold", devname);
>  	opts->numrx = (opts->numrx & ~3);
>  }

This should be done via ethtool irq coalescing settings not more module paramets.

-- 
