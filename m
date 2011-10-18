From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 7/7] stmmac: add CHAINED descriptor mode support (V3)
Date: Tue, 18 Oct 2011 11:51:56 +0200
Message-ID: <4E9D4C3C.2030105@st.com>
References: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com> <1318927331-20855-8-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Rayagond Kokatanur <rayagond@vayavyalabs.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:53448 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754424Ab1JRJ6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 05:58:54 -0400
In-Reply-To: <1318927331-20855-8-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please discard these. I'm sending the V4 (with the Eric patch for mtu
and dma_init).

Peppe

On 10/18/2011 10:42 AM, Giuseppe CAVALLARO wrote:
> This patch enhances the STMMAC driver to support CHAINED mode of
> descriptor.
> 
> STMMAC supports DMA descriptor to operate both in dual buffer(RING)
> and linked-list(CHAINED) mode. In RING mode (default) each descriptor
> points to two data buffer pointers whereas in CHAINED mode they point
> to only one data buffer pointer.
> 
> In CHAINED mode each descriptor will have pointer to next descriptor in
> the list, hence creating the explicit chaining in the descriptor itself,
> whereas such explicit chaining is not possible in RING mode.
> 
> First version of this work has been done by Rayagond.
> Then the patch has been reworked avoiding ifdef inside the C code.
> A new header file has been added to define all the functions needed for
> managing enhanced and normal descriptors.
> In fact, these have to be specialized according to the ring/chain usage.
> Two new C files have been also added to implement the helper routines
> needed to manage: jumbo frames, chain and ring setup (i.e. desc3).
> 
> Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/Kconfig       |   18 +++
>  drivers/net/ethernet/stmicro/stmmac/Makefile      |    2 +
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |  137 +++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/common.h      |   13 ++
>  drivers/net/ethernet/stmicro/stmmac/descs_com.h   |  126 +++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   22 ++--
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   20 +--
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |  126 +++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    2 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  130 ++++++++------------
>  10 files changed, 491 insertions(+), 105 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/chain_mode.c
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/descs_com.h
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> index 8cd9dde..ac6f190 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> @@ -63,4 +63,22 @@ config STMMAC_RTC_TIMER
>  
>  endchoice
>  
> +choice
> +	prompt "Select the DMA TX/RX descriptor operating modes"
> +	depends on STMMAC_ETH
> +	---help---
> +	  This driver supports DMA descriptor to operate both in dual buffer
> +	  (RING) and linked-list(CHAINED) mode. In RING mode each descriptor
> +	  points to two data buffer pointers whereas in CHAINED mode they
> +	  points to only one data buffer pointer.
> +
> +config STMMAC_RING
> +	bool "Enable Descriptor Ring Mode"
> +
> +config STMMAC_CHAINED
> +	bool "Enable Descriptor Chained Mode"
> +
> +endchoice
> +
> +
>  endif
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
> index 0f23d95..d7c4516 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
> @@ -1,5 +1,7 @@
>  obj-$(CONFIG_STMMAC_ETH) += stmmac.o
>  stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
> +stmmac-$(CONFIG_STMMAC_RING) += ring_mode.o
> +stmmac-$(CONFIG_STMMAC_CHAINED) += chain_mode.o
>  stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
>  	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
>  	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
> diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> new file mode 100644
> index 0000000..0668659
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> @@ -0,0 +1,137 @@
> +/*******************************************************************************
> +  Specialised functions for managing Chained mode
> +
> +  Copyright(C) 2011  STMicroelectronics Ltd
> +
> +  It defines all the functions used to handle the normal/enhanced
> +  descriptors in case of the DMA is configured to work in chained or
> +  in ring mode.
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
> +  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> +*******************************************************************************/
> +
> +#include "stmmac.h"
> +
> +unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
> +{
> +	struct stmmac_priv *priv = (struct stmmac_priv *) p;
> +	unsigned int txsize = priv->dma_tx_size;
> +	unsigned int entry = priv->cur_tx % txsize;
> +	struct dma_desc *desc = priv->dma_tx + entry;
> +	unsigned int nopaged_len = skb_headlen(skb);
> +	unsigned int bmax;
> +	unsigned int i = 1, len;
> +
> +	if (priv->plat->enh_desc)
> +		bmax = BUF_SIZE_8KiB;
> +	else
> +		bmax = BUF_SIZE_2KiB;
> +
> +	len = nopaged_len - bmax;
> +
> +	desc->des2 = dma_map_single(priv->device, skb->data,
> +				    bmax, DMA_TO_DEVICE);
> +	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum);
> +
> +	while (len != 0) {
> +		entry = (++priv->cur_tx) % txsize;
> +		desc = priv->dma_tx + entry;
> +
> +		if (len > bmax) {
> +			desc->des2 = dma_map_single(priv->device,
> +						    (skb->data + bmax * i),
> +						    bmax, DMA_TO_DEVICE);
> +			priv->hw->desc->prepare_tx_desc(desc, 0, bmax,
> +							csum);
> +			priv->hw->desc->set_tx_owner(desc);
> +			priv->tx_skbuff[entry] = NULL;
> +			len -= bmax;
> +			i++;
> +		} else {
> +			desc->des2 = dma_map_single(priv->device,
> +						    (skb->data + bmax * i), len,
> +						    DMA_TO_DEVICE);
> +			priv->hw->desc->prepare_tx_desc(desc, 0, len,
> +							csum);
> +			priv->hw->desc->set_tx_owner(desc);
> +			priv->tx_skbuff[entry] = NULL;
> +			len = 0;
> +		}
> +	}
> +	return entry;
> +}
> +
> +static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
> +{
> +	unsigned int ret = 0;
> +
> +	if ((enh_desc && (len > BUF_SIZE_8KiB)) ||
> +	    (!enh_desc && (len > BUF_SIZE_2KiB))) {
> +		ret = 1;
> +	}
> +
> +	return ret;
> +}
> +
> +static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
> +{
> +}
> +
> +static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
> +{
> +}
> +
> +static void stmmac_clean_desc3(struct dma_desc *p)
> +{
> +}
> +
> +static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
> +				  unsigned int size)
> +{
> +	/*
> +	 * In chained mode the des3 points to the next element in the ring.
> +	 * The latest element has to point to the head.
> +	 */
> +	int i;
> +	struct dma_desc *p = des;
> +	dma_addr_t dma_phy = phy_addr;
> +
> +	for (i = 0; i < (size - 1); i++) {
> +		dma_phy += sizeof(struct dma_desc);
> +		p->des3 = (unsigned int)dma_phy;
> +		p++;
> +	}
> +	p->des3 = (unsigned int)phy_addr;
> +}
> +
> +static int stmmac_set_16kib_bfsize(int mtu)
> +{
> +	/* Not supported */
> +	return 0;
> +}
> +
> +const struct stmmac_ring_mode_ops ring_mode_ops = {
> +	.is_jumbo_frm = stmmac_is_jumbo_frm,
> +	.jumbo_frm = stmmac_jumbo_frm,
> +	.refill_desc3 = stmmac_refill_desc3,
> +	.init_desc3 = stmmac_init_desc3,
> +	.init_dma_chain = stmmac_init_dma_chain,
> +	.clean_desc3 = stmmac_clean_desc3,
> +	.set_16kib_bfsize = stmmac_set_16kib_bfsize,
> +};
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index ffba014..9100c10 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -287,10 +287,22 @@ struct mii_regs {
>  	unsigned int data;	/* MII Data */
>  };
>  
> +struct stmmac_ring_mode_ops {
> +	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
> +	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
> +	void (*refill_desc3) (int bfsize, struct dma_desc *p);
> +	void (*init_desc3) (int des3_as_data_buf, struct dma_desc *p);
> +	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
> +				unsigned int size);
> +	void (*clean_desc3) (struct dma_desc *p);
> +	int (*set_16kib_bfsize) (int mtu);
> +};
> +
>  struct mac_device_info {
>  	const struct stmmac_ops		*mac;
>  	const struct stmmac_desc_ops	*desc;
>  	const struct stmmac_dma_ops	*dma;
> +	const struct stmmac_ring_mode_ops	*ring;
>  	struct mii_regs mii;	/* MII register Addresses */
>  	struct mac_link link;
>  	unsigned int synopsys_uid;
> @@ -304,3 +316,4 @@ extern void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
>  extern void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
>  				unsigned int high, unsigned int low);
>  extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
> +extern const struct stmmac_ring_mode_ops ring_mode_ops;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
> new file mode 100644
> index 0000000..1652c86
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
> @@ -0,0 +1,126 @@
> +/*******************************************************************************
> +  Header File to describe Normal/enhanced descriptor functions used for RING
> +  and CHAINED modes.
> +
> +  Copyright(C) 2011  STMicroelectronics Ltd
> +
> +  It defines all the functions used to handle the normal/enhanced
> +  descriptors in case of the DMA is configured to work in chained or
> +  in ring mode.
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
> +  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> +*******************************************************************************/
> +
> +#if defined(CONFIG_STMMAC_RING)
> +static inline void ehn_desc_rx_set_on_ring_chain(struct dma_desc *p, int end)
> +{
> +	p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
> +	if (end)
> +		p->des01.erx.end = 1;
> +}
> +
> +static inline void ehn_desc_tx_set_on_ring_chain(struct dma_desc *p, int end)
> +{
> +	if (end)
> +		p->des01.etx.end = 1;
> +}
> +
> +static inline void enh_desc_end_tx_desc(struct dma_desc *p, int ter)
> +{
> +	p->des01.etx.end = ter;
> +}
> +
> +static inline void enh_set_tx_desc_len(struct dma_desc *p, int len)
> +{
> +	if (unlikely(len > BUF_SIZE_4KiB)) {
> +		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
> +		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
> +	} else
> +		p->des01.etx.buffer1_size = len;
> +}
> +
> +static inline void ndesc_rx_set_on_ring_chain(struct dma_desc *p, int end)
> +{
> +	p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
> +	if (end)
> +		p->des01.rx.end = 1;
> +}
> +
> +static inline void ndesc_tx_set_on_ring_chain(struct dma_desc *p, int end)
> +{
> +	if (end)
> +		p->des01.tx.end = 1;
> +}
> +
> +static inline void ndesc_end_tx_desc(struct dma_desc *p, int ter)
> +{
> +	p->des01.tx.end = ter;
> +}
> +
> +static inline void norm_set_tx_desc_len(struct dma_desc *p, int len)
> +{
> +	if (unlikely(len > BUF_SIZE_2KiB)) {
> +		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
> +		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
> +	} else
> +		p->des01.tx.buffer1_size = len;
> +}
> +
> +#else
> +
> +static inline void ehn_desc_rx_set_on_ring_chain(struct dma_desc *p, int end)
> +{
> +	p->des01.erx.second_address_chained = 1;
> +}
> +
> +static inline void ehn_desc_tx_set_on_ring_chain(struct dma_desc *p, int end)
> +{
> +	p->des01.etx.second_address_chained = 1;
> +}
> +
> +static inline void enh_desc_end_tx_desc(struct dma_desc *p, int ter)
> +{
> +	p->des01.etx.second_address_chained = 1;
> +}
> +
> +static inline void enh_set_tx_desc_len(struct dma_desc *p, int len)
> +{
> +	p->des01.etx.buffer1_size = len;
> +}
> +
> +static inline void ndesc_rx_set_on_ring_chain(struct dma_desc *p, int end)
> +{
> +	p->des01.rx.second_address_chained = 1;
> +}
> +
> +static inline void ndesc_tx_set_on_ring_chain(struct dma_desc *p, int ring_size)
> +{
> +	p->des01.tx.second_address_chained = 1;
> +}
> +
> +static inline void ndesc_end_tx_desc(struct dma_desc *p, int ter)
> +{
> +	p->des01.tx.second_address_chained = 1;
> +}
> +
> +static inline void norm_set_tx_desc_len(struct dma_desc *p, int len)
> +{
> +	p->des01.tx.buffer1_size = len;
> +}
> +#endif
> diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> index e5dfb6a..d879763 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> @@ -23,6 +23,7 @@
>  *******************************************************************************/
>  
>  #include "common.h"
> +#include "descs_com.h"
>  
>  static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
>  				  struct dma_desc *p, void __iomem *ioaddr)
> @@ -233,10 +234,9 @@ static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
>  	for (i = 0; i < ring_size; i++) {
>  		p->des01.erx.own = 1;
>  		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
> -		/* To support jumbo frames */
> -		p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
> -		if (i == ring_size - 1)
> -			p->des01.erx.end_ring = 1;
> +
> +		ehn_desc_rx_set_on_ring_chain(p, (i == ring_size - 1));
> +
>  		if (disable_rx_ic)
>  			p->des01.erx.disable_ic = 1;
>  		p++;
> @@ -249,8 +249,7 @@ static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
>  
>  	for (i = 0; i < ring_size; i++) {
>  		p->des01.etx.own = 0;
> -		if (i == ring_size - 1)
> -			p->des01.etx.end_ring = 1;
> +		ehn_desc_tx_set_on_ring_chain(p, (i == ring_size - 1));
>  		p++;
>  	}
>  }
> @@ -285,19 +284,16 @@ static void enh_desc_release_tx_desc(struct dma_desc *p)
>  	int ter = p->des01.etx.end_ring;
>  
>  	memset(p, 0, offsetof(struct dma_desc, des2));
> -	p->des01.etx.end_ring = ter;
> +	enh_desc_end_tx_desc(p, ter);
>  }
>  
>  static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
>  				     int csum_flag)
>  {
>  	p->des01.etx.first_segment = is_fs;
> -	if (unlikely(len > BUF_SIZE_4KiB)) {
> -		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
> -		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
> -	} else {
> -		p->des01.etx.buffer1_size = len;
> -	}
> +
> +	enh_set_tx_desc_len(p, len);
> +
>  	if (likely(csum_flag))
>  		p->des01.etx.checksum_insertion = cic_full;
>  }
> diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> index e13226b..f7e8ba7 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> @@ -23,6 +23,7 @@
>  *******************************************************************************/
>  
>  #include "common.h"
> +#include "descs_com.h"
>  
>  static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
>  			       struct dma_desc *p, void __iomem *ioaddr)
> @@ -126,9 +127,9 @@ static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
>  	for (i = 0; i < ring_size; i++) {
>  		p->des01.rx.own = 1;
>  		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
> -		p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
> -		if (i == ring_size - 1)
> -			p->des01.rx.end_ring = 1;
> +
> +		ndesc_rx_set_on_ring_chain(p, (i == ring_size - 1));
> +
>  		if (disable_rx_ic)
>  			p->des01.rx.disable_ic = 1;
>  		p++;
> @@ -140,8 +141,7 @@ static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
>  	int i;
>  	for (i = 0; i < ring_size; i++) {
>  		p->des01.tx.own = 0;
> -		if (i == ring_size - 1)
> -			p->des01.tx.end_ring = 1;
> +		ndesc_tx_set_on_ring_chain(p, (i == (ring_size - 1)));
>  		p++;
>  	}
>  }
> @@ -176,20 +176,14 @@ static void ndesc_release_tx_desc(struct dma_desc *p)
>  	int ter = p->des01.tx.end_ring;
>  
>  	memset(p, 0, offsetof(struct dma_desc, des2));
> -	/* set termination field */
> -	p->des01.tx.end_ring = ter;
> +	ndesc_end_tx_desc(p, ter);
>  }
>  
>  static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
>  				  int csum_flag)
>  {
>  	p->des01.tx.first_segment = is_fs;
> -
> -	if (unlikely(len > BUF_SIZE_2KiB)) {
> -		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
> -		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
> -	} else
> -		p->des01.tx.buffer1_size = len;
> +	norm_set_tx_desc_len(p, len);
>  }
>  
>  static void ndesc_clear_tx_ic(struct dma_desc *p)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> new file mode 100644
> index 0000000..fb8377d
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> @@ -0,0 +1,126 @@
> +/*******************************************************************************
> +  Specialised functions for managing Ring mode
> +
> +  Copyright(C) 2011  STMicroelectronics Ltd
> +
> +  It defines all the functions used to handle the normal/enhanced
> +  descriptors in case of the DMA is configured to work in chained or
> +  in ring mode.
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
> +  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> +*******************************************************************************/
> +
> +#include "stmmac.h"
> +
> +static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
> +{
> +	struct stmmac_priv *priv = (struct stmmac_priv *) p;
> +	unsigned int txsize = priv->dma_tx_size;
> +	unsigned int entry = priv->cur_tx % txsize;
> +	struct dma_desc *desc = priv->dma_tx + entry;
> +	unsigned int nopaged_len = skb_headlen(skb);
> +	unsigned int bmax, len;
> +
> +	if (priv->plat->enh_desc)
> +		bmax = BUF_SIZE_8KiB;
> +	else
> +		bmax = BUF_SIZE_2KiB;
> +
> +	len = nopaged_len - bmax;
> +
> +	if (nopaged_len > BUF_SIZE_8KiB) {
> +
> +		desc->des2 = dma_map_single(priv->device, skb->data,
> +					    bmax, DMA_TO_DEVICE);
> +		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
> +		priv->hw->desc->prepare_tx_desc(desc, 1, bmax,
> +						csum);
> +
> +		entry = (++priv->cur_tx) % txsize;
> +		desc = priv->dma_tx + entry;
> +
> +		desc->des2 = dma_map_single(priv->device, skb->data + bmax,
> +					    len, DMA_TO_DEVICE);
> +		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
> +		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum);
> +		priv->hw->desc->set_tx_owner(desc);
> +		priv->tx_skbuff[entry] = NULL;
> +	} else {
> +		desc->des2 = dma_map_single(priv->device, skb->data,
> +					    nopaged_len, DMA_TO_DEVICE);
> +		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
> +		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum);
> +	}
> +
> +	return entry;
> +}
> +
> +static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
> +{
> +	unsigned int ret = 0;
> +
> +	if (len >= BUF_SIZE_4KiB)
> +		ret = 1;
> +
> +	return ret;
> +}
> +
> +static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
> +{
> +	/* Fill DES3 in case of RING mode */
> +	if (bfsize >= BUF_SIZE_8KiB)
> +		p->des3 = p->des2 + BUF_SIZE_8KiB;
> +}
> +
> +/* In ring mode we need to fill the desc3 because it is used
> + * as buffer */
> +static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
> +{
> +	if (unlikely(des3_as_data_buf))
> +		p->des3 = p->des2 + BUF_SIZE_8KiB;
> +}
> +
> +static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
> +				  unsigned int size)
> +{
> +}
> +
> +static void stmmac_clean_desc3(struct dma_desc *p)
> +{
> +	if (unlikely(p->des3))
> +		p->des3 = 0;
> +}
> +
> +static int stmmac_set_16kib_bfsize(int mtu)
> +{
> +	int ret = 0;
> +	if (unlikely(mtu >= BUF_SIZE_8KiB))
> +		ret = BUF_SIZE_16KiB;
> +	return ret;
> +}
> +
> +const struct stmmac_ring_mode_ops ring_mode_ops = {
> +	.is_jumbo_frm = stmmac_is_jumbo_frm,
> +	.jumbo_frm = stmmac_jumbo_frm,
> +	.refill_desc3 = stmmac_refill_desc3,
> +	.init_desc3 = stmmac_init_desc3,
> +	.init_dma_chain = stmmac_init_dma_chain,
> +	.clean_desc3 = stmmac_clean_desc3,
> +	.set_16kib_bfsize = stmmac_set_16kib_bfsize,
> +};
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index 49a4af3..9bafa6c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -22,7 +22,7 @@
>  
>  #define DRV_MODULE_VERSION	"Oct_2011"
>  #include <linux/stmmac.h>
> -
> +#include <linux/phy.h>
>  #include "common.h"
>  #ifdef CONFIG_STMMAC_TIMER
>  #include "stmmac_timer.h"
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 7325256..1848a16 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2,7 +2,7 @@
>    This is the driver for the ST MAC 10/100/1000 on-chip Ethernet controllers.
>    ST Ethernet IPs are built around a Synopsys IP Core.
>  
> -  Copyright (C) 2007-2009  STMicroelectronics Ltd
> +	Copyright(C) 2007-2011 STMicroelectronics Ltd
>  
>    This program is free software; you can redistribute it and/or modify it
>    under the terms and conditions of the GNU General Public License,
> @@ -41,17 +41,16 @@
>  #include <linux/if_ether.h>
>  #include <linux/crc32.h>
>  #include <linux/mii.h>
> -#include <linux/phy.h>
>  #include <linux/if.h>
>  #include <linux/if_vlan.h>
>  #include <linux/dma-mapping.h>
>  #include <linux/slab.h>
>  #include <linux/prefetch.h>
> -#include "stmmac.h"
>  #ifdef CONFIG_STMMAC_DEBUG_FS
>  #include <linux/debugfs.h>
>  #include <linux/seq_file.h>
>  #endif
> +#include "stmmac.h"
>  
>  #define STMMAC_RESOURCE_NAME	"stmmaceth"
>  
> @@ -388,11 +387,28 @@ static void display_ring(struct dma_desc *p, int size)
>  	}
>  }
>  
> +static int stmmac_set_bfsize(int mtu, int bufsize)
> +{
> +	int ret = bufsize;
> +
> +	if (mtu >= BUF_SIZE_4KiB)
> +		ret = BUF_SIZE_8KiB;
> +	else if (mtu >= BUF_SIZE_2KiB)
> +		ret = BUF_SIZE_4KiB;
> +	else if (mtu >= DMA_BUFFER_SIZE)
> +		ret = BUF_SIZE_2KiB;
> +	else
> +		ret = DMA_BUFFER_SIZE;
> +
> +	return ret;
> +}
> +
>  /**
>   * init_dma_desc_rings - init the RX/TX descriptor rings
>   * @dev: net device structure
>   * Description:  this function initializes the DMA RX/TX descriptors
> - * and allocates the socket buffers.
> + * and allocates the socket buffers. It suppors the chained and ring
> + * modes.
>   */
>  static void init_dma_desc_rings(struct net_device *dev)
>  {
> @@ -401,31 +417,24 @@ static void init_dma_desc_rings(struct net_device *dev)
>  	struct sk_buff *skb;
>  	unsigned int txsize = priv->dma_tx_size;
>  	unsigned int rxsize = priv->dma_rx_size;
> -	unsigned int bfsize = priv->dma_buf_sz;
> -	int buff2_needed = 0, dis_ic = 0;
> +	unsigned int bfsize;
> +	int dis_ic = 0;
> +	int des3_as_data_buf = 0;
>  
> -	/* Set the Buffer size according to the MTU;
> -	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
> -	 */
> -	if (unlikely(dev->mtu >= BUF_SIZE_8KiB))
> -		bfsize = BUF_SIZE_16KiB;
> -	else if (unlikely(dev->mtu >= BUF_SIZE_4KiB))
> -		bfsize = BUF_SIZE_8KiB;
> -	else if (unlikely(dev->mtu >= BUF_SIZE_2KiB))
> -		bfsize = BUF_SIZE_4KiB;
> -	else if (unlikely(dev->mtu >= DMA_BUFFER_SIZE))
> -		bfsize = BUF_SIZE_2KiB;
> +	/* Set the max buffer size according to the DESC mode
> +	 * and the MTU. Note that RING mode allows 16KiB bsize. */
> +	bfsize = priv->hw->ring->set_16kib_bfsize(dev->mtu);
> +
> +	if (bfsize == BUF_SIZE_16KiB)
> +		des3_as_data_buf = 1;
>  	else
> -		bfsize = DMA_BUFFER_SIZE;
> +		bfsize = stmmac_set_bfsize(dev->mtu, priv->dma_buf_sz);
>  
>  #ifdef CONFIG_STMMAC_TIMER
>  	/* Disable interrupts on completion for the reception if timer is on */
>  	if (likely(priv->tm->enable))
>  		dis_ic = 1;
>  #endif
> -	/* If the MTU exceeds 8k so use the second buffer in the chain */
> -	if (bfsize >= BUF_SIZE_8KiB)
> -		buff2_needed = 1;
>  
>  	DBG(probe, INFO, "stmmac: txsize %d, rxsize %d, bfsize %d\n",
>  	    txsize, rxsize, bfsize);
> @@ -453,7 +462,7 @@ static void init_dma_desc_rings(struct net_device *dev)
>  		return;
>  	}
>  
> -	DBG(probe, INFO, "stmmac (%s) DMA desc rings: virt addr (Rx %p, "
> +	DBG(probe, INFO, "stmmac (%s) DMA desc: virt addr (Rx %p, "
>  	    "Tx %p)\n\tDMA phy addr (Rx 0x%08x, Tx 0x%08x)\n",
>  	    dev->name, priv->dma_rx, priv->dma_tx,
>  	    (unsigned int)priv->dma_rx_phy, (unsigned int)priv->dma_tx_phy);
> @@ -475,8 +484,9 @@ static void init_dma_desc_rings(struct net_device *dev)
>  						bfsize, DMA_FROM_DEVICE);
>  
>  		p->des2 = priv->rx_skbuff_dma[i];
> -		if (unlikely(buff2_needed))
> -			p->des3 = p->des2 + BUF_SIZE_8KiB;
> +
> +		priv->hw->ring->init_desc3(des3_as_data_buf, p);
> +
>  		DBG(probe, INFO, "[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
>  			priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
>  	}
> @@ -490,6 +500,12 @@ static void init_dma_desc_rings(struct net_device *dev)
>  		priv->tx_skbuff[i] = NULL;
>  		priv->dma_tx[i].des2 = 0;
>  	}
> +
> +	/* In case of Chained mode this sets the des3 to the next
> +	 * element in the chain */
> +	priv->hw->ring->init_dma_chain(priv->dma_rx, priv->dma_rx_phy, rxsize);
> +	priv->hw->ring->init_dma_chain(priv->dma_tx, priv->dma_tx_phy, txsize);
> +
>  	priv->dirty_tx = 0;
>  	priv->cur_tx = 0;
>  
> @@ -620,8 +636,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
>  			dma_unmap_single(priv->device, p->des2,
>  					 priv->hw->desc->get_tx_len(p),
>  					 DMA_TO_DEVICE);
> -		if (unlikely(p->des3))
> -			p->des3 = 0;
> +		priv->hw->ring->clean_desc3(p);
>  
>  		if (likely(skb != NULL)) {
>  			/*
> @@ -728,7 +743,6 @@ static void stmmac_no_timer_stopped(void)
>   */
>  static void stmmac_tx_err(struct stmmac_priv *priv)
>  {
> -
>  	netif_stop_queue(priv->dev);
>  
>  	priv->hw->dma->stop_tx(priv->ioaddr);
> @@ -1028,47 +1042,6 @@ static int stmmac_release(struct net_device *dev)
>  	return 0;
>  }
>  
> -static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
> -					       struct net_device *dev,
> -					       int csum_insertion)
> -{
> -	struct stmmac_priv *priv = netdev_priv(dev);
> -	unsigned int nopaged_len = skb_headlen(skb);
> -	unsigned int txsize = priv->dma_tx_size;
> -	unsigned int entry = priv->cur_tx % txsize;
> -	struct dma_desc *desc = priv->dma_tx + entry;
> -
> -	if (nopaged_len > BUF_SIZE_8KiB) {
> -
> -		int buf2_size = nopaged_len - BUF_SIZE_8KiB;
> -
> -		desc->des2 = dma_map_single(priv->device, skb->data,
> -					    BUF_SIZE_8KiB, DMA_TO_DEVICE);
> -		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
> -		priv->hw->desc->prepare_tx_desc(desc, 1, BUF_SIZE_8KiB,
> -						csum_insertion);
> -
> -		entry = (++priv->cur_tx) % txsize;
> -		desc = priv->dma_tx + entry;
> -
> -		desc->des2 = dma_map_single(priv->device,
> -					skb->data + BUF_SIZE_8KiB,
> -					buf2_size, DMA_TO_DEVICE);
> -		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
> -		priv->hw->desc->prepare_tx_desc(desc, 0, buf2_size,
> -						csum_insertion);
> -		priv->hw->desc->set_tx_owner(desc);
> -		priv->tx_skbuff[entry] = NULL;
> -	} else {
> -		desc->des2 = dma_map_single(priv->device, skb->data,
> -					nopaged_len, DMA_TO_DEVICE);
> -		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
> -		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
> -						csum_insertion);
> -	}
> -	return entry;
> -}
> -
>  /**
>   *  stmmac_xmit:
>   *  @skb : the socket buffer
> @@ -1083,6 +1056,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int i, csum_insertion = 0;
>  	int nfrags = skb_shinfo(skb)->nr_frags;
>  	struct dma_desc *desc, *first;
> +	unsigned int nopaged_len = skb_headlen(skb);
>  
>  	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
>  		if (!netif_queue_stopped(dev)) {
> @@ -1103,7 +1077,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  		pr_info("stmmac xmit:\n"
>  		       "\tskb addr %p - len: %d - nopaged_len: %d\n"
>  		       "\tn_frags: %d - ip_summed: %d - %s gso\n",
> -		       skb, skb->len, skb_headlen(skb), nfrags, skb->ip_summed,
> +		       skb, skb->len, nopaged_len, nfrags, skb->ip_summed,
>  		       !skb_is_gso(skb) ? "isn't" : "is");
>  #endif
>  
> @@ -1116,14 +1090,14 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if ((nfrags > 0) || (skb->len > ETH_FRAME_LEN))
>  		pr_debug("stmmac xmit: skb len: %d, nopaged_len: %d,\n"
>  		       "\t\tn_frags: %d, ip_summed: %d\n",
> -		       skb->len, skb_headlen(skb), nfrags, skb->ip_summed);
> +		       skb->len, nopaged_len, nfrags, skb->ip_summed);
>  #endif
>  	priv->tx_skbuff[entry] = skb;
> -	if (unlikely(skb->len >= BUF_SIZE_4KiB)) {
> -		entry = stmmac_handle_jumbo_frames(skb, dev, csum_insertion);
> +
> +	if (priv->hw->ring->is_jumbo_frm(skb->len, priv->plat->enh_desc)) {
> +		entry = priv->hw->ring->jumbo_frm(priv, skb, csum_insertion);
>  		desc = priv->dma_tx + entry;
>  	} else {
> -		unsigned int nopaged_len = skb_headlen(skb);
>  		desc->des2 = dma_map_single(priv->device, skb->data,
>  					nopaged_len, DMA_TO_DEVICE);
>  		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
> @@ -1214,11 +1188,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
>  					   DMA_FROM_DEVICE);
>  
>  			(p + entry)->des2 = priv->rx_skbuff_dma[entry];
> -			if (unlikely(priv->plat->has_gmac)) {
> -				if (bfsize >= BUF_SIZE_8KiB)
> -					(p + entry)->des3 =
> -					    (p + entry)->des2 + BUF_SIZE_8KiB;
> -			}
> +
> +			if (unlikely(priv->plat->has_gmac))
> +				priv->hw->ring->refill_desc3(bfsize, p + entry);
> +
>  			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
>  		}
>  		wmb();
> @@ -1795,6 +1768,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
>  		device->desc = &ndesc_ops;
>  
>  	priv->hw = device;
> +	priv->hw->ring = &ring_mode_ops;
>  
>  	if (device_can_wakeup(priv->device)) {
>  		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
