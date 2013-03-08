From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next.git 2/9] stmmac: add IEEE 1588-2002 PTP support
Date: Fri, 8 Mar 2013 07:34:37 +0100
Message-ID: <20130308063437.GB2382@netboy.at.omicron.at>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
 <1362653419-1047-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	ayagond@vayavyalabs.com,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:35683 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab3CHGen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 01:34:43 -0500
Received: by mail-ee0-f53.google.com with SMTP id e53so821554eek.26
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 22:34:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1362653419-1047-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a few comments, below.

On Thu, Mar 07, 2013 at 11:50:12AM +0100, Giuseppe CAVALLARO wrote:
> From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> 
> This patch enhances the stmmac driver to support IEEE 1588-2002
> PTP (Precision Time Protocol) version 1.
> 
> IEEE 1588-2002 standard defines a protocol, Precision Time
> Protocol(PTP),
> which enables precise synchronization of clocks in measurement and
> control systems implemented with technologies such as network
> communication,local computing, & distributed objects.
> 
> HW Timestamp support can be enabled while configuring the Kernel and
> the Koption is: STMMAC_USE_HWSTAMP
> At runtime, the support is verified by looking at the HW capability
> register.

As davem said, since you have the ability to detect this at run time,
then there is no need for a kconfig option.

> Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |   11 +
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   23 ++-
>  drivers/net/ethernet/stmicro/stmmac/common.h       |   27 ++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |    1 -
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   37 +++
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   34 +++
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   14 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    8 +
>  .../net/ethernet/stmicro/stmmac/stmmac_hwstamp.c   |  129 ++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  255 +++++++++++++++++++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |   72 ++++++
>  12 files changed, 588 insertions(+), 24 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> index c0ea838..ef703b3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> @@ -71,5 +71,16 @@ config STMMAC_CHAINED
>  
>  endchoice
>  
> +config STMMAC_USE_HWSTAMP
> +	bool "Use IEEE 1588 Precision Time Protocol"
> +	depends on STMMAC_ETH
> +	select PTP_1588_CLOCK
> +	default n
> +	---help---
> +	  Enable this option to support the IEEE 1588 Precision Time Protocol
> +	  (PTP) and HW Timestamps.
> +	  At runtime, on new chip generations, the hardware capability
> +	  register will be used to verify if either the IEEE 1588-2008 Advanced
> +	  Timestamping (PTPv2) or IEEE 1588-2002 (PTPv1) is actually supported.
>  
>  endif
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
> index c8e8ea6..cc97c07 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
> @@ -3,6 +3,7 @@ stmmac-$(CONFIG_STMMAC_RING) += ring_mode.o
>  stmmac-$(CONFIG_STMMAC_CHAINED) += chain_mode.o
>  stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
>  stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
> +stmmac-$(CONFIG_STMMAC_USE_HWSTAMP) += stmmac_hwstamp.o
>  stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
>  	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
>  	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
> diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> index ad3d75f..dd60f6b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> @@ -92,16 +92,35 @@ static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
>  	return ret;
>  }
>  
> -static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
> +static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
>  {
> +	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
> +
> +	if (priv->hwts_rx_en)
> +		/* NOTE: Device will overwrite des3 with timestamp value if
> +		 * 1588-2002 time stamping is enabled, hence reinitialize it
> +		 * to keep explicit chaining in the descriptor.
> +		 */
> +		p->des3 = (unsigned int)(priv->dma_rx +
> +			((priv->dirty_rx) + 1) % priv->dma_rx_size);
>  }
>  
>  static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
>  {
>  }
>  
> -static void stmmac_clean_desc3(struct dma_desc *p)
> +static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p,
> +				int tstamp_taken)
>  {
> +	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
> +
> +	if (tstamp_taken && priv->hw->desc->get_tx_ls(p))
> +		/* NOTE: Device will overwrite des3 with timestamp value if
> +		 * 1588-2002 time stamping is enabled, hence reinitialize it
> +		 * to keep explicit chaining in the descriptor.
> +		 */
> +		p->des3 = (unsigned int)(priv->dma_tx +
> +			((priv->dirty_tx + 1) % priv->dma_tx_size));
>  }
>  
>  static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 186d148..fa8ff9b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -290,6 +290,16 @@ struct stmmac_desc_ops {
>  	/* Return the reception status looking at the RDES1 */
>  	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
>  			  struct dma_desc *p);
> +	/* Set tx timestamp enable bit */
> +	void (*enable_tx_timestamp) (struct dma_desc *p);
> +	/* get tx timestamp status */
> +	int (*get_tx_timestamp_status) (struct dma_desc *p);

> +	/* get tx/rx timestamp low value */
> +	u32 (*get_timestamp_low) (struct dma_desc *p);
> +	/* get tx/rx timestamp high value */
> +	u32 (*get_timestamp_high) (struct dma_desc *p);

These two separate functions should be combined into one.

> +	/* get rx timestamp status */
> +	int (*get_rx_timestamp_status) (struct dma_desc *p);
>  };
>  
>  struct stmmac_dma_ops {
> @@ -346,6 +356,15 @@ struct stmmac_ops {
>  	void (*set_eee_pls) (void __iomem *ioaddr, int link);
>  };
>  
> +#ifdef CONFIG_STMMAC_USE_HWSTAMP
> +struct stmmac_hwtimestamp {
> +	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
> +	void (*config_sub_second_increment) (void __iomem *ioaddr);
> +	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
> +	int (*config_addend)(void __iomem *ioaddr, u32 addend);
> +};
> +#endif
> +
>  struct mac_link {
>  	int port;
>  	int duplex;
> @@ -360,11 +379,11 @@ struct mii_regs {
>  struct stmmac_ring_mode_ops {
>  	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
>  	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
> -	void (*refill_desc3) (int bfsize, struct dma_desc *p);
> +	void (*refill_desc3) (void *priv, struct dma_desc *p);
>  	void (*init_desc3) (int des3_as_data_buf, struct dma_desc *p);
>  	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
>  				unsigned int size);
> -	void (*clean_desc3) (struct dma_desc *p);
> +	void (*clean_desc3) (void *priv, struct dma_desc *p, int tstamp_taken);
>  	int (*set_16kib_bfsize) (int mtu);
>  };
>  
> @@ -373,6 +392,9 @@ struct mac_device_info {
>  	const struct stmmac_desc_ops	*desc;
>  	const struct stmmac_dma_ops	*dma;
>  	const struct stmmac_ring_mode_ops	*ring;
> +#ifdef CONFIG_STMMAC_USE_HWSTAMP
> +	const struct stmmac_hwtimestamp	*ptp;
> +#endif
>  	struct mii_regs mii;	/* MII register Addresses */
>  	struct mac_link link;
>  	unsigned int synopsys_uid;
> @@ -390,5 +412,4 @@ extern void stmmac_set_mac(void __iomem *ioaddr, bool enable);
>  
>  extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
>  extern const struct stmmac_ring_mode_ops ring_mode_ops;
> -
>  #endif /* __COMMON_H__ */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> index 491d7e9..8c4ea93 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> @@ -286,4 +286,3 @@ void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
>  	addr[4] = hi_addr & 0xff;
>  	addr[5] = (hi_addr >> 8) & 0xff;
>  }
> -
> diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> index 2fc8ef9..4d635d5 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> @@ -323,6 +323,38 @@ static int enh_desc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
>  		return p->des01.erx.frame_length;
>  }
>  
> +static void enh_desc_enable_tx_timestamp(struct dma_desc *p)
> +{
> +	p->des01.etx.time_stamp_enable = 1;
> +}
> +
> +static int enh_desc_get_tx_timestamp_status(struct dma_desc *p)
> +{
> +	return p->des01.etx.time_stamp_status;
> +}
> +
> +static u32 enh_desc_get_timestamp_low(struct dma_desc *p)
> +{
> +	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
> +	return p->des2;
> +}
> +
> +static u32 enh_desc_get_timestamp_high(struct dma_desc *p)
> +{
> +	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
> +	return p->des3;
> +}
> +
> +static int enh_desc_get_rx_timestamp_status(struct dma_desc *p)
> +{
> +	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */

Why not fix these FIXMEs for the next respin?

> +	if ((p->des2 == 0xffffffff) && (p->des3 == 0xffffffff))
> +		/* timestamp is currupted, hence don't store it */

corrupted

> +		return 0;
> +	else
> +		return 1;
> +}
> +
>  const struct stmmac_desc_ops enh_desc_ops = {
>  	.tx_status = enh_desc_get_tx_status,
>  	.rx_status = enh_desc_get_rx_status,
> @@ -339,4 +371,9 @@ const struct stmmac_desc_ops enh_desc_ops = {
>  	.set_tx_owner = enh_desc_set_tx_owner,
>  	.set_rx_owner = enh_desc_set_rx_owner,
>  	.get_rx_frame_len = enh_desc_get_rx_frame_len,
> +	.enable_tx_timestamp = enh_desc_enable_tx_timestamp,
> +	.get_tx_timestamp_status = enh_desc_get_tx_timestamp_status,
> +	.get_timestamp_low = enh_desc_get_timestamp_low,
> +	.get_timestamp_high = enh_desc_get_timestamp_high,
> +	.get_rx_timestamp_status = enh_desc_get_rx_timestamp_status,
>  };
> diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> index 68962c5..edb5e88 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> @@ -215,6 +215,35 @@ static int ndesc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
>  		return p->des01.rx.frame_length;
>  }
>  
> +static void ndesc_enable_tx_timestamp(struct dma_desc *p)
> +{
> +	p->des01.tx.time_stamp_enable = 1;
> +}
> +
> +static int ndesc_get_tx_timestamp_status(struct dma_desc *p)
> +{
> +	return p->des01.tx.time_stamp_status;
> +}
> +
> +static u32 ndesc_get_timestamp_low(struct dma_desc *p)
> +{
> +	return p->des2;
> +}
> +
> +static u32 ndesc_get_timestamp_high(struct dma_desc *p)
> +{
> +	return p->des3;
> +}
> +
> +static int ndesc_get_rx_timestamp_status(struct dma_desc *p)
> +{
> +	if ((p->des2 == 0xffffffff) && (p->des3 == 0xffffffff))
> +		/* timestamp is currupted, hence don't store it */

corrupted

> +		return 0;
> +	else
> +		return 1;
> +}
> +
>  const struct stmmac_desc_ops ndesc_ops = {
>  	.tx_status = ndesc_get_tx_status,
>  	.rx_status = ndesc_get_rx_status,
> @@ -231,4 +260,9 @@ const struct stmmac_desc_ops ndesc_ops = {
>  	.set_tx_owner = ndesc_set_tx_owner,
>  	.set_rx_owner = ndesc_set_rx_owner,
>  	.get_rx_frame_len = ndesc_get_rx_frame_len,
> +	.enable_tx_timestamp = ndesc_enable_tx_timestamp,
> +	.get_tx_timestamp_status = ndesc_get_tx_timestamp_status,
> +	.get_timestamp_low = ndesc_get_timestamp_low,
> +	.get_timestamp_high = ndesc_get_timestamp_high,
> +	.get_rx_timestamp_status = ndesc_get_rx_timestamp_status,
>  };
> diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> index 839e349..94a1c2f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> @@ -85,11 +85,14 @@ static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
>  	return ret;
>  }
>  
> -static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
> +static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
>  {
> -	/* Fill DES3 in case of RING mode */
> -	if (bfsize >= BUF_SIZE_8KiB)
> -		p->des3 = p->des2 + BUF_SIZE_8KiB;
> +	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
> +
> +	if (unlikely(priv->plat->has_gmac))
> +		/* Fill DES3 in case of RING mode */
> +		if (priv->dma_buf_sz >= BUF_SIZE_8KiB)
> +			p->des3 = p->des2 + BUF_SIZE_8KiB;
>  }
>  
>  /* In ring mode we need to fill the desc3 because it is used
> @@ -105,7 +108,8 @@ static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
>  {
>  }
>  
> -static void stmmac_clean_desc3(struct dma_desc *p)
> +static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p,
> +				int tstamp_taken)
>  {
>  	if (unlikely(p->des3))
>  		p->des3 = 0;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index 013a7d5..665f2a2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -94,6 +94,11 @@ struct stmmac_priv {
>  	u32 tx_coal_timer;
>  	int use_riwt;
>  	u32 rx_riwt;
> +#ifdef CONFIG_STMMAC_USE_HWSTAMP
> +	int hwts_tx_en;
> +	int hwts_rx_en;
> +	unsigned int default_addend;
> +#endif
>  };
>  
>  extern int phyaddr;
> @@ -103,6 +108,9 @@ extern int stmmac_mdio_register(struct net_device *ndev);
>  extern void stmmac_set_ethtool_ops(struct net_device *netdev);
>  extern const struct stmmac_desc_ops enh_desc_ops;
>  extern const struct stmmac_desc_ops ndesc_ops;
> +#ifdef CONFIG_STMMAC_USE_HWSTAMP
> +extern const struct stmmac_hwtimestamp stmmac_ptp;
> +#endif
>  int stmmac_freeze(struct net_device *ndev);
>  int stmmac_restore(struct net_device *ndev);
>  int stmmac_resume(struct net_device *ndev);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
> new file mode 100644
> index 0000000..be9e399
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
> @@ -0,0 +1,129 @@
> +/*******************************************************************************
> +  Copyright (C) 2013  Vayavya Labs Pvt Ltd
> +
> +  This implements all the API for managing HW timestamp & PTP.
> +
> +  This program is free software; you can redistribute it and/or modify it
> +  under the terms and conditions of the GNU General Public License,
> +  version 2, as published by the Free Software Foundation.
> +
> +  This program is distributed in the hope it will be useful, but WITHOUT
> +  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> +  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> +  more details.
> +
> +  You should have received a copy of the GNU General Public License along with
> +  this program; if not, write to the Free Software Foundation, Inc.,
> +  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
> +
> +  The full GNU General Public License is included in this distribution in
> +  the file called "COPYING".
> +
> +  Author: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> +  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> +*******************************************************************************/
> +
> +#include <linux/io.h>
> +#include <linux/delay.h>
> +#include "common.h"
> +#include "stmmac_ptp.h"
> +
> +static void stmmac_config_hw_tstamping(void __iomem *ioaddr, u32 data)
> +{
> +	writel(data, ioaddr + PTP_TCR);
> +}
> +
> +static void stmmac_config_sub_second_increment(void __iomem *ioaddr)
> +{
> +	u32 value = readl(ioaddr + PTP_TCR);
> +	unsigned long data;
> +
> +	/* Convert the ptp_clock to nano second
> +	 * formula = (1/ptp_clock) * 1000000000
> +	 * where, ptp_clock = 50MHz for FINE correction method &
> +	 * ptp_clock = STMMAC_SYSCLOCK for COARSE correction method
> +	 */

What are these coarse/fine method? Can't we always use the fine one?

> +	if (value & PTP_TCR_TSCFUPDT)
> +		data = (1000000000ULL / 50000000);
> +	else
> +		data = (1000000000ULL / STMMAC_SYSCLOCK);
> +
> +	writel(data, ioaddr + PTP_SSIR);
> +}
> +
> +static int stmmac_init_systime(void __iomem *ioaddr, u32 sec, u32 nsec)
> +{
> +	int limit;
> +	u32 value;
> +
> +	/* wait for previous(if any) system time initialize to complete */
> +	limit = 100;
> +	while (limit--) {
> +		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSINIT))
> +			break;
> +		mdelay(10);
> +	}
> +
> +	if (limit < 0)
> +		return -EBUSY;
> +

Ugh, this is terrible...

> +	writel(sec, ioaddr + PTP_STSUR);
> +	writel(nsec, ioaddr + PTP_STNSUR);
> +	/* issue command to initialize the system time value */
> +	value = readl(ioaddr + PTP_TCR);
> +	value |= PTP_TCR_TSINIT;
> +	writel(value, ioaddr + PTP_TCR);
> +
> +	/* wait for present system time initialize to complete */
> +	limit = 100;
> +	while (limit--) {
> +		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSINIT))
> +			break;
> +		mdelay(10);
> +	}
> +	if (limit < 0)
> +		return -EBUSY;

... for a number of reasons.

1. You are polling for 100*10ms = one second, and the caller has
   disabled interrupts! This is way too long. Is the hardware really
   that slow? If so, then you need to use delayed work or find some
   other way not to block.

2. You are waiting both before and after for the status bit. Pick one
   or the other. You don't need both.

This same pattern is repeated a few times here, and it needs fixing in
each case.

> +
> +	return 0;
> +}
> +
> +static int stmmac_config_addend(void __iomem *ioaddr, u32 addend)
> +{
> +	u32 value;
> +	int limit;
> +
> +	/* wait for previous (if any) addend update to complete */
> +	limit = 100;
> +	while (limit--) {
> +		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSADDREG))
> +			break;
> +		mdelay(10);
> +	}
> +	if (limit < 0)
> +		return -EBUSY;
> +
> +	writel(addend, ioaddr + PTP_TAR);
> +	/* issue command to update the addend value */
> +	value = readl(ioaddr + PTP_TCR);
> +	value |= PTP_TCR_TSADDREG;
> +	writel(value, ioaddr + PTP_TCR);
> +
> +	/* wait for present addend update to complete */
> +	limit = 100;
> +	while (limit--) {
> +		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSADDREG))
> +			break;
> +		mdelay(10);
> +	}
> +	if (limit < 0)
> +		return -EBUSY;
> +
> +	return 0;
> +}
> +
> +const struct stmmac_hwtimestamp stmmac_ptp = {
> +	.config_hw_tstamping = stmmac_config_hw_tstamping,
> +	.init_systime = stmmac_init_systime,
> +	.config_sub_second_increment = stmmac_config_sub_second_increment,
> +	.config_addend = stmmac_config_addend,
> +};
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 260af93..3bbd554 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -47,6 +47,10 @@
>  #include <linux/debugfs.h>
>  #include <linux/seq_file.h>
>  #endif
> +#ifdef CONFIG_STMMAC_USE_HWSTAMP
> +#include <linux/net_tstamp.h>
> +#include "stmmac_ptp.h"
> +#endif
>  #include "stmmac.h"
>  
>  #undef STMMAC_DEBUG
> @@ -304,6 +308,192 @@ static void stmmac_eee_adjust(struct stmmac_priv *priv)
>  		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
>  }
>  
> +#ifdef CONFIG_STMMAC_USE_HWSTAMP
> +/* stmmac_get_tx_hwtstamp:
> + * @priv : pointer to private device structure.
> + * @p : pointer to desc structure.
> + * @skb : the socket buffer
> + * Description :
> + * This function will read timestamp from the descriptor & pass it to stack.
> + * and also perform some sanity checks.
> + * Return value :
> + * 1 if time stamp is taken & 0 if time stamp is not taken.
> + */
> +static unsigned int stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
> +					   struct dma_desc *p,
> +					   struct sk_buff *skb)
> +{
> +	struct skb_shared_hwtstamps shhwtstamp;
> +	u64 ns;
> +
> +	if (!priv->hwts_tx_en)
> +		return 0;
> +
> +	/* if skb doesn't support hw tstamp */
> +	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
> +		return 0;
> +
> +	/* check tx tstamp status */
> +	if (!priv->hw->desc->get_tx_timestamp_status(p))
> +		return 0;
> +
> +	/* get the valid tstamp */
> +	ns = priv->hw->desc->get_timestamp_low(p);
> +	/* convert high/sec time stamp value to nanosecond */
> +	ns += priv->hw->desc->get_timestamp_high(p) * 1000000000ULL;
> +
> +	memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
> +	shhwtstamp.hwtstamp = ns_to_ktime(ns);
> +	/* pass tstamp to stack */
> +	skb_tstamp_tx(skb, &shhwtstamp);
> +
> +	return 1;
> +}
> +
> +/* stmmac_get_rx_hwtstamp:
> + * @priv : pointer to private device structure.
> + * @p : pointer to desc structure.
> + * @skb : the socket buffer
> + * Description :
> + * This function will read received packet's timestamp from the descriptor
> + * and pass it to stack. It also perform some sanity checks.
> + */
> +static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
> +				   struct sk_buff *skb)
> +{
> +	struct skb_shared_hwtstamps *shhwtstamp = NULL;
> +	u64 ns;
> +
> +	if (!priv->hwts_rx_en)
> +		return;
> +
> +	/* if rx tstamp is not valid */
> +	if (!priv->hw->desc->get_rx_timestamp_status(p))
> +		return;
> +
> +	/* get valid tstamp */
> +	ns = priv->hw->desc->get_timestamp_low(p);
> +	/* convert high/sec time stamp value to nanosecond */
> +	ns += priv->hw->desc->get_timestamp_high(p) * 1000000000ULL;
> +	shhwtstamp = skb_hwtstamps(skb);
> +	memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
> +	shhwtstamp->hwtstamp = ns_to_ktime(ns);
> +}
> +
> +/**
> + *  stmmac_hwtstamp_ioctl - control hardware timestamping.
> + *  @dev: device pointer.
> + *  @ifr: An IOCTL specefic structure, that can contain a pointer to
> + *  a proprietary structure used to pass information to the driver.
> + *  Description:
> + *  This function configures the MAC to enable/disable both outgoing(TX)
> + *  and incoming(RX) packets time stamping based on user input.
> + *  Return Value:
> + *  0 on success and an appropriate -ve integer on failure.
> + */
> +static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
> +{
> +	struct stmmac_priv *priv = netdev_priv(dev);
> +	struct hwtstamp_config config;
> +	struct timespec now;
> +	u64 temp = 0;

You add this new code here, but you change it all around again a few
patches later. Please just submit the final, combined version.

Thanks,
Richard
