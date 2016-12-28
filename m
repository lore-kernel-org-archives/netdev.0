From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence GEM.
Date: Wed, 28 Dec 2016 13:23:04 +0000
Message-ID: <BN3PR07MB25165782AD5A88D82BAA7EA8C9680@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "boris.brezillon@free-electrons.com" <boris.brezillon@free-electrons.com>,
 "alexandre.belloni@free-electrons.com"
 <alexandre.belloni@free-electrons.com>,
 "michals@xilinx.com" <michals@xilinx.com>,
 "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
 "anirudh@xilinx.com" <anirudh@xilinx.com>,
 "punnaia@xilinx.com" <punnaia@xilinx.com>,
 "richardcochran@gmail.com" <richardcochran@gmail.com>
To: Andrei Pistirica <andrei.pistirica@microchip.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "davem@davemloft.net"
 <davem@davemloft.net>, "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
 "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>,
 "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> From: Andrei Pistirica [mailto:andrei.pistirica@microchip.com] 
> Sent: 14 grudnia 2016 13:56
> Subject: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence GEM.
> 
> Cadence GEM provides a 102 bit time counter with 48 bits for seconds,
> 30 bits for nsecs and 24 bits for sub-nsecs to control 1588 timestamping.
> 
> This patch does the following:
> - Registers to ptp clock framework
> - Timer initialization is done by writing time of day to the timer counter.
> - ns increment register is programmed as NSEC_PER_SEC/tsu-clock-rate.
>   For a 16 bit subns precision, the subns increment equals
>   remainder of (NS_PER_SEC/TSU_CLK) * (2^16).
> - Timestamps are obtained from the TX/RX PTP event/PEER registers.
>   The timestamp obtained thus is updated in skb for upper layers to access.
> - The drivers register functions with ptp to perform time and frequency
>   adjustment.
> - Time adjustment is done by writing to the 1558_ADJUST register.
>   The controller will read the delta in this register and update the timer
>   counter register. Alternatively, for large time offset adjustments,
>   the driver reads the secs and nsecs counter values, adds/subtracts the
>   delta and updates the timer counter.
> - Frequency is adjusted by adjusting addend (8bit nanosecond increment) and
>   addendsub (16bit increment nanosecond fractions).
>   The 102bit counter is incremented at nominal frequency with addend and
>   addendsub values. Each period addend and addendsub values are adjusted
>   based on ppm drift.
> 
> Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> ---
> Patch history:
> 
> Version 1:
> This patch is based on original Harini's patch, implemented in a separate file to ease the review/maintanance and integration with other platforms (e.g. Zynq Ultrascale+ MPSoC).
> Feature was tested on SAMA5D2 platform using ptp4l v1.6 from linuxptp project and also with ptpd2 version 2.3.1. PTP was tested over
> IPv4,IPv6 and 802.3 protocols.
> 
> In case that macb is compiled as a module, it has been renamed to cadence-macb.ko to avoid naming confusion in Makefile.
> 
> Version 2 modifications:
> - bitfields for TSU are named according to SAMA5D2 data sheet
> - identify GEM-PTP support based on platform capability
> - add spinlock for TSU access
> - change macb_ptp_adjfreq and use fewer 64bit divisions
> 
> Version 3 modifications:
> - new adjfine api with one 64 division for frequency adjustment
>   (based on Richard's input)
> - add maximum adjustment frequency (ppb) based on nominal frequency
> - per platform PTP configuration
> - cosmetic changes
> Note 1: Kbuild uses "select" instead of "imply", and the macb maintainer agreed
>         to make the change when it will be available in net-next.
> 
> Version 4 modifications:
> - update adjfine for a better approximation
> - add maximum adjustment frequency callback to PTP platform configuraion
> 
> Note 1: This driver does not support GEM-GXL!
> Note 2: Patch on net-next, on December 14th. 
> 
>  drivers/net/ethernet/cadence/Kconfig    |  10 +-
>  drivers/net/ethernet/cadence/Makefile   |   8 +-
>  drivers/net/ethernet/cadence/macb.h     | 118 ++++++++++
>  drivers/net/ethernet/cadence/macb_ptp.c | 366 ++++++++++++++++++++++++++++++++
>  4 files changed, 500 insertions(+), 2 deletions(-)  create mode 100644 drivers/net/ethernet/cadence/macb_ptp.c
> 
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index f0bcb15..ebbc65f 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -29,6 +29,14 @@ config MACB
>  	  support for the MACB/GEM chip.
>  
>  	  To compile this driver as a module, choose M here: the module
> -	  will be called macb.
> +	  will be called cadence-macb.
> +
> +config MACB_USE_HWSTAMP
> +	bool "Use IEEE 1588 hwstamp"
> +	depends on MACB
> +	default y
> +	select PTP_1588_CLOCK
> +	---help---
> +	  Enable IEEE 1588 Precision Time Protocol (PTP) support for MACB.
>  
>  endif # NET_CADENCE
> diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
> index 91f79b1..4402d42 100644
> --- a/drivers/net/ethernet/cadence/Makefile
> +++ b/drivers/net/ethernet/cadence/Makefile
> @@ -2,4 +2,10 @@
>  # Makefile for the Atmel network device drivers.
>  #
>  
> -obj-$(CONFIG_MACB) += macb.o
> +cadence-macb-y	:= macb.o
> +
> +ifeq ($(CONFIG_MACB_USE_HWSTAMP),y)
> +cadence-macb-y	+= macb_ptp.o
> +endif
> +
> +obj-$(CONFIG_MACB) += cadence-macb.o
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index d67adad..e65e985 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -10,6 +10,9 @@
>  #ifndef _MACB_H
>  #define _MACB_H
>  
> +#include <linux/ptp_clock.h>
> +#include <linux/ptp_clock_kernel.h>
> +
>  #define MACB_GREGS_NBR 16
>  #define MACB_GREGS_VERSION 2
>  #define MACB_MAX_QUEUES 8
> @@ -131,6 +134,20 @@
>  #define GEM_RXIPCCNT		0x01a8 /* IP header Checksum Error Counter */
>  #define GEM_RXTCPCCNT		0x01ac /* TCP Checksum Error Counter */
>  #define GEM_RXUDPCCNT		0x01b0 /* UDP Checksum Error Counter */
> +#define GEM_TISUBN		0x01bc /* 1588 Timer Increment Sub-ns */
> +#define GEM_TSH			0x01c0 /* 1588 Timer Seconds High */
> +#define GEM_TSL			0x01d0 /* 1588 Timer Seconds Low */
> +#define GEM_TN			0x01d4 /* 1588 Timer Nanoseconds */
> +#define GEM_TA			0x01d8 /* 1588 Timer Adjust */
> +#define GEM_TI			0x01dc /* 1588 Timer Increment */
> +#define GEM_EFTSL		0x01e0 /* PTP Event Frame Tx Seconds Low */
> +#define GEM_EFTN		0x01e4 /* PTP Event Frame Tx Nanoseconds */
> +#define GEM_EFRSL		0x01e8 /* PTP Event Frame Rx Seconds Low */
> +#define GEM_EFRN		0x01ec /* PTP Event Frame Rx Nanoseconds */
> +#define GEM_PEFTSL		0x01f0 /* PTP Peer Event Frame Tx Secs Low */
> +#define GEM_PEFTN		0x01f4 /* PTP Peer Event Frame Tx Ns */
> +#define GEM_PEFRSL		0x01f8 /* PTP Peer Event Frame Rx Sec Low */
> +#define GEM_PEFRN		0x01fc /* PTP Peer Event Frame Rx Ns */
>  #define GEM_DCFG1		0x0280 /* Design Config 1 */
>  #define GEM_DCFG2		0x0284 /* Design Config 2 */
>  #define GEM_DCFG3		0x0288 /* Design Config 3 */
> @@ -174,6 +191,7 @@
>  #define MACB_NCR_TPF_SIZE	1
>  #define MACB_TZQ_OFFSET		12 /* Transmit zero quantum pause frame */
>  #define MACB_TZQ_SIZE		1
> +#define MACB_SRTSM_OFFSET	15
>  
>  /* Bitfields in NCFGR */
>  #define MACB_SPD_OFFSET		0 /* Speed */
> @@ -319,6 +337,32 @@
>  #define MACB_PTZ_SIZE		1
>  #define MACB_WOL_OFFSET		14 /* Enable wake-on-lan interrupt */
>  #define MACB_WOL_SIZE		1
> +#define MACB_DRQFR_OFFSET	18 /* PTP Delay Request Frame Received */
> +#define MACB_DRQFR_SIZE		1
> +#define MACB_SFR_OFFSET		19 /* PTP Sync Frame Received */
> +#define MACB_SFR_SIZE		1
> +#define MACB_DRQFT_OFFSET	20 /* PTP Delay Request Frame Transmitted */
> +#define MACB_DRQFT_SIZE		1
> +#define MACB_SFT_OFFSET		21 /* PTP Sync Frame Transmitted */
> +#define MACB_SFT_SIZE		1
> +#define MACB_PDRQFR_OFFSET	22 /* PDelay Request Frame Received */
> +#define MACB_PDRQFR_SIZE	1
> +#define MACB_PDRSFR_OFFSET	23 /* PDelay Response Frame Received */
> +#define MACB_PDRSFR_SIZE	1
> +#define MACB_PDRQFT_OFFSET	24 /* PDelay Request Frame Transmitted */
> +#define MACB_PDRQFT_SIZE	1
> +#define MACB_PDRSFT_OFFSET	25 /* PDelay Response Frame Transmitted */
> +#define MACB_PDRSFT_SIZE	1
> +#define MACB_SRI_OFFSET		26 /* TSU Seconds Register Increment */
> +#define MACB_SRI_SIZE		1
> +
> +/* Timer increment fields */
> +#define MACB_TI_CNS_OFFSET	0
> +#define MACB_TI_CNS_SIZE	8
> +#define MACB_TI_ACNS_OFFSET	8
> +#define MACB_TI_ACNS_SIZE	8
> +#define MACB_TI_NIT_OFFSET	16
> +#define MACB_TI_NIT_SIZE	8
>  
>  /* Bitfields in MAN */
>  #define MACB_DATA_OFFSET	0 /* data */
> @@ -386,6 +430,17 @@
>  #define GEM_PBUF_LSO_OFFSET			27
>  #define GEM_PBUF_LSO_SIZE			1
>  
> +/* Bitfields in TISUBN */
> +#define GEM_SUBNSINCR_OFFSET			0
> +#define GEM_SUBNSINCR_SIZE			16
> +
> +/* Bitfields in TI */
> +#define GEM_NSINCR_OFFSET			0
> +#define GEM_NSINCR_SIZE				8
> +
> +/* Bitfields in ADJ */
> +#define GEM_ADDSUB_OFFSET			31
> +#define GEM_ADDSUB_SIZE				1
>  /* Constants for CLK */
>  #define MACB_CLK_DIV8				0
>  #define MACB_CLK_DIV16				1
> @@ -417,6 +472,7 @@
>  #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
>  #define MACB_CAPS_SG_DISABLED			0x40000000
>  #define MACB_CAPS_MACB_IS_GEM			0x80000000
> +#define MACB_CAPS_GEM_HAS_PTP			0x00000020
>  
>  /* LSO settings */
>  #define MACB_LSO_UFO_ENABLE			0x01
> @@ -782,6 +838,20 @@ struct macb_or_gem_ops {
>  	int	(*mog_rx)(struct macb *bp, int budget);
>  };
>  
> +/* MACB-PTP interface: adapt to platform needs and GEM (e.g. GXL). */ 
> +struct macb_ptp_info {
> +	void (*ptp_init)(struct net_device *ndev);
> +	void (*ptp_remove)(struct net_device *ndev);
> +	s32 (*get_ptp_max_adj)(void);
> +	unsigned int (*get_tsu_rate)(struct macb *bp);
> +	int (*get_ts_info)(struct net_device *dev,
> +			   struct ethtool_ts_info *info);
> +	int (*get_hwtst)(struct net_device *netdev,
> +			 struct ifreq *ifr);
> +	int (*set_hwtst)(struct net_device *netdev,
> +			 struct ifreq *ifr, int cmd);
> +};
> +
>  struct macb_config {
>  	u32			caps;
>  	unsigned int		dma_burst_length;
> @@ -874,11 +944,59 @@ struct macb {
>  	unsigned int		jumbo_max_len;
>  
>  	u32			wol;
> +
> +	struct macb_ptp_info	*ptp_info;
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +	bool			hwts_tx_en;
> +	bool			hwts_rx_en;
> +	spinlock_t		tsu_clk_lock; /* gem tsu clock locking */
> +	unsigned int		tsu_rate;
> +
> +	struct ptp_clock	*ptp_clock;
> +	struct ptp_clock_info	ptp_caps;
> +	u32			ns_incr;
> +	u32			subns_incr;
> +#endif
>  };
>  
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +void gem_ptp_init(struct net_device *ndev); void gem_ptp_remove(struct 
> +net_device *ndev); void gem_ptp_txstamp(struct macb *bp, struct sk_buff 
> +*skb); void gem_ptp_rxstamp(struct macb *bp, struct sk_buff *skb);
> +
> +static inline void gem_ptp_do_txstamp(struct macb *bp, struct sk_buff 
> +*skb) {
> +	if (!bp->hwts_tx_en)
> +		return;
> +
> +	return gem_ptp_txstamp(bp, skb);
> +}
> +
> +static inline void gem_ptp_do_rxstamp(struct macb *bp, struct sk_buff 
> +*skb) {
> +	if (!bp->hwts_rx_en)
> +		return;
> +
> +	return gem_ptp_rxstamp(bp, skb);
> +}
> +
> +#else
> +static inline void gem_ptp_init(struct net_device *ndev) { } static 
> +inline void gem_ptp_remove(struct net_device *ndev) { }
> +
> +static inline void gem_ptp_do_txstamp(struct macb *bp, struct sk_buff 
> +*skb) { } static inline void gem_ptp_do_rxstamp(struct macb *bp, struct 
> +sk_buff *skb) { } #endif
> +
>  static inline bool macb_is_gem(struct macb *bp)  {
>  	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);  }
>  
> +static inline bool gem_has_ptp(struct macb *bp) {
> +	return !!(bp->caps & MACB_CAPS_GEM_HAS_PTP); }
> +
>  #endif /* _MACB_H */
> diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
> new file mode 100644
> index 0000000..6121b2a
> --- /dev/null
> +++ b/drivers/net/ethernet/cadence/macb_ptp.c
> @@ -0,0 +1,366 @@
> +/*
> + * 1588 PTP support for GEM device.
> + *
> + * Copyright (C) 2016 Microchip Technology
> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#include <linux/clk.h>
> +#include <linux/device.h>
> +#include <linux/etherdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/time64.h>
> +#include <linux/ptp_classify.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
> +#include <linux/net_tstamp.h>
> +
> +#include "macb.h"
> +
> +#define  GEM_PTP_TIMER_NAME "gem-ptp-timer"
> +
> +static inline void gem_tsu_get_time(struct macb *bp,
> +				    struct timespec64 *ts)
> +{
> +	u64 sec, sech, secl;
> +
> +	spin_lock(&bp->tsu_clk_lock);
> +
> +	/* GEM's internal time */
> +	sech = gem_readl(bp, TSH);
> +	secl = gem_readl(bp, TSL);
> +	ts->tv_nsec = gem_readl(bp, TN);
> +	ts->tv_sec = (sech << 32) | secl;
> +
> +	/* minimize error */
> +	sech = gem_readl(bp, TSH);
> +	secl = gem_readl(bp, TSL);
> +	sec = (sech << 32) | secl;
> +	if (ts->tv_sec != sec) {
> +		ts->tv_sec = sec;
> +		ts->tv_nsec = gem_readl(bp, TN);
> +	}
> +
> +	spin_unlock(&bp->tsu_clk_lock);
> +}
> +
> +static inline void gem_tsu_set_time(struct macb *bp,
> +				    const struct timespec64 *ts)
> +{
> +	u32 ns, sech, secl;
> +	s64 word_mask = 0xffffffff;
> +
> +	sech = (u32)ts->tv_sec;
> +	secl = (u32)ts->tv_sec;
> +	ns = ts->tv_nsec;
> +	if (ts->tv_sec > word_mask)
> +		sech = (ts->tv_sec >> 32);
> +
> +	spin_lock(&bp->tsu_clk_lock);
> +
> +	/* TSH doesn't latch the time and no atomicity! */
> +	gem_writel(bp, TN, 0); /* clear to avoid overflow */
> +	gem_writel(bp, TSH, sech);
> +	gem_writel(bp, TSL, secl);
> +	gem_writel(bp, TN, ns);
> +
> +	spin_unlock(&bp->tsu_clk_lock);
> +}
> +
> +static int gem_ptp_adjfine(struct ptp_clock_info *ptp, long scaled_ppm) 
> +{
> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +	u32 word, diff;
> +	u64 adj, rate;
> +	int neg_adj = 0;
> +
> +	if (scaled_ppm < 0) {
> +		neg_adj = 1;
> +		scaled_ppm = -scaled_ppm;
> +	}
> +	rate = scaled_ppm;
> +
> +	/* word: unused(8bit) | ns(8bit) | fractions(16bit) */
> +	word = (bp->ns_incr << 16) + bp->subns_incr;
> +
> +	adj = word;
> +	adj *= rate;
> +	adj += 500000UL << 16;
> +	adj >>= 16; /* remove fractions */
> +	diff = div_u64(adj, 1000000UL);
> +	word = neg_adj ? word - diff : word + diff;
> +
> +	spin_lock(&bp->tsu_clk_lock);
> +
> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, (word & 0xffff)));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, (word >> 16)));
> +
> +	spin_unlock(&bp->tsu_clk_lock);
> +	return 0;
> +}
> +
> +static int gem_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta) {
> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +	struct timespec64 now, then = ns_to_timespec64(delta);
> +	u32 adj, sign = 0;
> +
> +	if (delta < 0) {
> +		delta = -delta;
> +		sign = 1;
> +	}
> +
> +	if (delta > 0x3FFFFFFF) {
> +		gem_tsu_get_time(bp, &now);
> +
> +		if (sign)
> +			now = timespec64_sub(now, then);
> +		else
> +			now = timespec64_add(now, then);
> +
> +		gem_tsu_set_time(bp, (const struct timespec64 *)&now);
> +	} else {
> +		adj = delta;
> +		if (sign)
> +			adj |= GEM_BIT(ADDSUB);
> +
> +		gem_writel(bp, TA, adj);
> +	}
> +
> +	return 0;
> +}
> +
> +static int gem_ptp_gettime(struct ptp_clock_info *ptp, struct 
> +timespec64 *ts) {
> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +
> +	gem_tsu_get_time(bp, ts);
> +
> +	return 0;
> +}
> +
> +static int gem_ptp_settime(struct ptp_clock_info *ptp,
> +			   const struct timespec64 *ts)
> +{
> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +
> +	gem_tsu_set_time(bp, ts);
> +
> +	return 0;
> +}
> +
> +static int gem_ptp_enable(struct ptp_clock_info *ptp,
> +			  struct ptp_clock_request *rq, int on) {
> +	return -EOPNOTSUPP;
> +}
I think, we can support here:
1. PTP_CLK_REQ_EXTTS (interrupt mask register 0x030, bit 29: tsu_timer_comparison_mask)
2. PTP_CLK_REQ_PPS (interrupt mask register 0x030, bit 26: tsu_seconds_register_increment_mask)

> +
> +static struct ptp_clock_info gem_ptp_caps_template = {
> +	.owner		= THIS_MODULE,
> +	.name		= GEM_PTP_TIMER_NAME,
> +	.max_adj	= 0,
> +	.n_alarm	= 0,
> +	.n_ext_ts	= 0,
> +	.n_per_out	= 0,
> +	.n_pins		= 0,
> +	.pps		= 0,
> +	.adjfine	= gem_ptp_adjfine,
> +	.adjtime	= gem_ptp_adjtime,
> +	.gettime64	= gem_ptp_gettime,
> +	.settime64	= gem_ptp_settime,
> +	.enable		= gem_ptp_enable,
> +};
> +
> +static void gem_ptp_init_timer(struct macb *bp) {
> +	struct timespec64 now;
> +	u32 rem = 0;
> +
> +	getnstimeofday64(&now);
> +	gem_tsu_set_time(bp, (const struct timespec64 *)&now);
Why do you change TSU clock here? Is it necessary? You overwrite all values
even when someone doesn't need it. ptp4l calls ioctl SIOCSHWTSTAMP on start.
IMHO, there should be set up TSU and Increments.

> +
> +	bp->ns_incr = div_u64_rem(NSEC_PER_SEC, bp->tsu_rate, &rem);
> +	if (rem) {
> +		u64 adj = rem;
> +
> +		adj <<= 16; /* 16 bits nsec fragments */
> +		bp->subns_incr = div_u64(adj, bp->tsu_rate);
> +	} else {
> +		bp->subns_incr = 0;
> +	}
> +
> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, bp->subns_incr));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, bp->ns_incr));
The same comment like above.

> +	gem_writel(bp, TA, 0);
What is the reason for zeroing Timer Adjust Register?

> +}
> +
> +static void gem_ptp_clear_timer(struct macb *bp) {
> +	bp->ns_incr = 0;
> +	bp->subns_incr = 0;
> +
> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, 0));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, 0));
> +	gem_writel(bp, TA, 0);
> +}
> +
> +/* While GEM can timestamp PTP packets, it does not mark the RX 
> +descriptor
> + * to identify them. UDP packets must be parsed to identify PTP packets.
> + *
> + * Note: Inspired from drivers/net/ethernet/ti/cpts.c  */ static int 
> +gem_get_ptp_peer(struct sk_buff *skb, int ptp_class) {
> +	unsigned int offset = 0;
> +	u8 *msgtype, *data = skb->data;
> +
> +	/* PTP frames are rare! */
> +	if (likely(ptp_class == PTP_CLASS_NONE))
> +		return -1;
> +
> +	if (ptp_class & PTP_CLASS_VLAN)
> +		offset += VLAN_HLEN;
> +
> +	switch (ptp_class & PTP_CLASS_PMASK) {
> +	case PTP_CLASS_IPV4:
> +		offset += ETH_HLEN + IPV4_HLEN(data + offset) + UDP_HLEN;
> +	break;
> +	case PTP_CLASS_IPV6:
> +		offset += ETH_HLEN + IP6_HLEN + UDP_HLEN;
> +	break;
> +	case PTP_CLASS_L2:
> +		offset += ETH_HLEN;
> +		break;
> +
> +	/* something went wrong! */
> +	default:
> +		return -1;
> +	}
> +
> +	if (skb->len + ETH_HLEN < offset + OFF_PTP_SEQUENCE_ID)
> +		return -1;
> +
> +	if (unlikely(ptp_class & PTP_CLASS_V1))
> +		msgtype = data + offset + OFF_PTP_CONTROL;
> +	else
> +		msgtype = data + offset;
> +
> +	return (*msgtype) & 0x2;
> +}
> +
> +static void gem_ptp_tx_hwtstamp(struct macb *bp, struct sk_buff *skb,
> +				int peer_ev)
> +{
> +	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +	struct timespec64 ts;
> +	u64 ns;
> +
> +	/* PTP Peer Event Frame packets */
> +	if (peer_ev) {
> +		ts.tv_sec = gem_readl(bp, PEFTSL);
> +		ts.tv_nsec = gem_readl(bp, PEFTN);
> +
> +	/* PTP Event Frame packets */
> +	} else {
> +		ts.tv_sec = gem_readl(bp, EFTSL);
> +		ts.tv_nsec = gem_readl(bp, EFTN);
> +	}
I'm wondering what is a difference between timestamp in transmit buffer descriptor (Word 2 and 3)
and PTP Event Frame Transmitted Seconds/Nanoseconds Register (0x1E0, 0x1E4).

> +	ns = timespec64_to_ns(&ts);
> +
> +	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> +	shhwtstamps->hwtstamp = ns_to_ktime(ns);
> +	skb_tstamp_tx(skb, skb_hwtstamps(skb)); }
> +
> +static void gem_ptp_rx_hwtstamp(struct macb *bp, struct sk_buff *skb,
> +				int peer_ev)
> +{
> +	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +	struct timespec64 ts;
> +	u64 ns;
> +
> +	if (peer_ev) {
> +		/* PTP Peer Event Frame packets */
> +		ts.tv_sec = gem_readl(bp, PEFRSL);
> +		ts.tv_nsec = gem_readl(bp, PEFRN);
> +	} else {
> +		/* PTP Event Frame packets */
> +		ts.tv_sec = gem_readl(bp, EFRSL);
> +		ts.tv_nsec = gem_readl(bp, EFRN);
> +	}
The same concerns like above.

> +	ns = timespec64_to_ns(&ts);
> +
> +	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> +	shhwtstamps->hwtstamp = ns_to_ktime(ns); }
> +
> +/* no static, GEM PTP interface functions */ void 
> +gem_ptp_txstamp(struct macb *bp, struct sk_buff *skb) {
> +	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
> +		int class = ptp_classify_raw(skb);
> +		int peer;
> +
> +		peer = gem_get_ptp_peer(skb, class);
> +		if (peer < 0)
> +			return;
> +
> +		/* Timestamp this packet */
> +		gem_ptp_tx_hwtstamp(bp, skb, peer);
> +	}
> +}
> +
> +void gem_ptp_rxstamp(struct macb *bp, struct sk_buff *skb) {
> +	int class, peer;
> +
> +	__skb_push(skb, ETH_HLEN);
> +	class = ptp_classify_raw(skb);
> +	__skb_pull(skb, ETH_HLEN);
> +
> +	peer = gem_get_ptp_peer(skb, class);
> +	if (peer < 0)
> +		return;
> +
> +	gem_ptp_rx_hwtstamp(bp, skb, peer);
> +}
> +
> +void gem_ptp_init(struct net_device *ndev) {
> +	struct macb *bp = netdev_priv(ndev);
> +
> +	spin_lock_init(&bp->tsu_clk_lock);
> +	bp->ptp_caps = gem_ptp_caps_template;
> +
> +	/* nominal frequency and maximum adjustment in ppb */
> +	bp->tsu_rate = bp->ptp_info->get_tsu_rate(bp);
> +	bp->ptp_caps.max_adj = bp->ptp_info->get_ptp_max_adj();
> +
> +	gem_ptp_init_timer(bp);
> +
> +	bp->ptp_clock = ptp_clock_register(&bp->ptp_caps, NULL);
> +	if (IS_ERR(&bp->ptp_clock)) {
> +		bp->ptp_clock = NULL;
> +		pr_err("ptp clock register failed\n");
> +		return;
But you have already overwritten TSU and Increments.

> +	}
> +
> +	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n",
> +		 GEM_PTP_TIMER_NAME);
> +}
> +
> +void gem_ptp_remove(struct net_device *ndev) {
> +	struct macb *bp = netdev_priv(ndev);
> +
> +	if (bp->ptp_clock)
> +		ptp_clock_unregister(bp->ptp_clock);
> +
> +	gem_ptp_clear_timer(bp);
> +
> +	dev_info(&bp->pdev->dev, "%s ptp clock unregistered.\n",
> +		 GEM_PTP_TIMER_NAME);
> +}
> --
> 2.7.4
> 

Why don't you support HWTSTAMP_TX_ONESTEP_SYNC?
(Network control register 0x000, bit 24: one_step_sync_mode)

Best regards, 
Rafal Ozieblo   |   Firmware System Engineer, 
www.cadence.com
