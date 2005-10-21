From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] forcedeth: add support for interrupt mitigation
Date: Fri, 21 Oct 2005 17:33:14 -0400
Message-ID: <43595E9A.7090505@pobox.com>
References: <43592FE5.20106@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <43592FE5.20106@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> Hi,
> 
> The current forcedeth driver doesn't support interrupt mitigation, this 
> can result in an incredible number of interrupts/sec for gigabit links. 
> The attached patch adds a throughput mode that enables an interrupt 
> mitigation scheme.
> 
> 
> -- 
>    Manfred
> 
> 
> ------------------------------------------------------------------------
> 
> --- 2.6/drivers/net/forcedeth.c	2005-10-20 23:17:24.000000000 +0200
> +++ build-2.6/drivers/net/forcedeth.c	2005-10-19 21:01:55.000000000 +0200
> @@ -98,6 +98,7 @@
>   *	0.43: 10 Aug 2005: Add support for tx checksum.
>   *	0.44: 20 Aug 2005: Add support for scatter gather and segmentation.
>   *	0.45: 18 Sep 2005: Remove nv_stop/start_rx from every link check
> + *	0.46: 20 Aug 2005: Add irq optimization modes.
>   *
>   * Known bugs:
>   * We suspect that on some hardware no TX done interrupts are generated.
> @@ -109,7 +110,7 @@
>   * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
>   * superfluous timer interrupts from the nic.
>   */
> -#define FORCEDETH_VERSION		"0.45"
> +#define FORCEDETH_VERSION		"0.46"
>  #define DRV_NAME			"forcedeth"
>  
>  #include <linux/module.h>
> @@ -164,7 +165,8 @@
>  #define NVREG_IRQ_LINK			0x0040
>  #define NVREG_IRQ_TX_ERROR		0x0080
>  #define NVREG_IRQ_TX1			0x0100
> -#define NVREG_IRQMASK_WANTED		0x00df
> +#define NVREG_IRQMASK_THROUGHPUT	0x00df
> +#define NVREG_IRQMASK_CPU		0x0040
>  
>  #define NVREG_IRQ_UNKNOWN	(~(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR| \
>  					NVREG_IRQ_TX_OK|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_TX_ERROR| \
> @@ -178,7 +180,8 @@
>   * NVREG_POLL_DEFAULT=97 would result in an interval length of 1 ms
>   */
>  	NvRegPollingInterval = 0x00c,
> -#define NVREG_POLL_DEFAULT	970
> +#define NVREG_POLL_DEFAULT_THROUGHPUT	970
> +#define NVREG_POLL_DEFAULT_CPU	13
>  	NvRegMisc1 = 0x080,
>  #define NVREG_MISC1_HD		0x02
>  #define NVREG_MISC1_FORCE	0x3b0f3c
> @@ -539,6 +542,18 @@
>   */
>  static int max_interrupt_work = 5;
>  
> +/*
> + * Optimization can be either throuput mode or cpu mode
> + */
> +#define NV_OPTIMIZATION_MODE_THROUGHPUT 0
> +#define NV_OPTIMIZATION_MODE_CPU        1
> +static int optimization_mode = NV_OPTIMIZATION_MODE_THROUGHPUT;
> +
> +/*
> + * Poll interval for timer irq
> + */
> +static int poll_interval = -1;

The code changes themselves seem correct, but this patch suffers from a 
few overall problems.

* "throughput or cpu" doesn't tell the user very much -- or me, for that 
matter.  Does "cpu mode" mean low latency, high interrupt count?  If so, 
just allow the user to choose between throughput and latency.

* making this a static decision at module load time is sub-optimal.  99% 
of users will simply use the default.  the option should be 
per-interface, ideally.  controlled by ethtool?

* there is zero information on how to use poll interval.  again, 99% of 
users will simply use the default.  since the poll interval is written 
directly to a hardware register, you should give the user some idea of 
the unit of measure (ms? ticks? bus cycles? ns?), and some idea of min/max.
