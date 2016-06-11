From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 3/8] Adding TSN-driver to Intel I210 controller
Date: Sun, 12 Jun 2016 00:53:52 +0200
Message-ID: <20160611225352.GF10685@sisyphus.home.austad.us>
References: <1465683741-20390-1-git-send-email-henrik@austad.us>
 <1465683741-20390-4-git-send-email-henrik@austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
	netdev@vger.kernel.org, henrk@austad.us,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org,
	"David S. Miller" <davem@davemloft.net>,
	Henrik Austad <haustad@cisco.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35835 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbcFKWx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 18:53:57 -0400
Received: by mail-lf0-f68.google.com with SMTP id w130so5442864lfd.2
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2016 15:53:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1465683741-20390-4-git-send-email-henrik@austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clearing up netdev-typo
-H

On Sun, Jun 12, 2016 at 12:22:16AM +0200, Henrik Austad wrote:
> This adds support for loading the igb.ko module with tsn
> capabilities. This requires a 2-step approach. First enabling TSN in
> .config, then load the module with use_tsn=1.
> 
> Once enabled and loaded, the controller will be placed in "Qav-mode"
> which is when the credit-based shaper is available, 3 of the queues are
> removed from regular traffic, max payload is set to 1522 octets (no
> jumboframes allowed).
> 
> It dumps the registers of interest before and after, so this clutters
> kern.log a bit. In time this will be reduced / tied to the debug-param
> for the module.
> 
> Note: currently this driver is *not* stable, it is still a work in
> progress.
> 
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Henrik Austad <haustad@cisco.com>
> ---
>  drivers/net/ethernet/intel/Kconfig        |  18 ++
>  drivers/net/ethernet/intel/igb/Makefile   |   2 +-
>  drivers/net/ethernet/intel/igb/igb.h      |  19 ++
>  drivers/net/ethernet/intel/igb/igb_main.c |  10 +-
>  drivers/net/ethernet/intel/igb/igb_tsn.c  | 396 ++++++++++++++++++++++++++++++
>  5 files changed, 443 insertions(+), 2 deletions(-)
>  create mode 100644 drivers/net/ethernet/intel/igb/igb_tsn.c
> 
> diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
> index 714bd10..8e620a9 100644
> --- a/drivers/net/ethernet/intel/Kconfig
> +++ b/drivers/net/ethernet/intel/Kconfig
> @@ -99,6 +99,24 @@ config IGB
>  	  To compile this driver as a module, choose M here. The module
>  	  will be called igb.
>  
> +config IGB_TSN
> +       tristate "TSN Support for Intel(R) 82575/82576 i210 Network Controller"
> +       depends on IGB && TSN
> +	---help---
> +	  This driver supports TSN (AVB) on Intel I210 network controllers.
> +
> +	  When enabled, it will allow the module to be loaded with
> +	  "use_tsn" which will initialize the controller to A/V-mode
> +	  instead of legacy-mode. This will take 3 of the tx-queues and
> +	  place them in 802.1Q QoS mode and enable the credit-based
> +	  shaper for 2 of the queues.
> +
> +	  If built with this option, but not loaded with use_tsn, the
> +	  only difference is a slightly larger module, no extra
> +	  code paths are called.
> +
> +	  If unsure, say No
> +
>  config IGB_HWMON
>  	bool "Intel(R) PCI-Express Gigabit adapters HWMON support"
>  	default y
> diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
> index 5bcb2de..1a9b776 100644
> --- a/drivers/net/ethernet/intel/igb/Makefile
> +++ b/drivers/net/ethernet/intel/igb/Makefile
> @@ -33,4 +33,4 @@ obj-$(CONFIG_IGB) += igb.o
>  
>  igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
>  	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o \
> -	    e1000_i210.o igb_ptp.o igb_hwmon.o
> +	    e1000_i210.o igb_ptp.o igb_hwmon.o igb_tsn.o
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index b9609af..708f705 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -356,6 +356,7 @@ struct hwmon_buff {
>  #define IGB_RETA_SIZE	128
>  
>  /* board specific private data structure */
> +
>  struct igb_adapter {
>  	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
>  
> @@ -472,6 +473,13 @@ struct igb_adapter {
>  	int copper_tries;
>  	struct e1000_info ei;
>  	u16 eee_advert;
> +
> +#if IS_ENABLED(CONFIG_IGB_TSN)
> +	/* Reserved BW for class A and B */
> +	u16 sra_idleslope_res;
> +	u16 srb_idleslope_res;
> +	u8 tsn_ready:1;
> +#endif	/* IGB_TSN */
>  };
>  
>  #define IGB_FLAG_HAS_MSI		BIT(0)
> @@ -552,6 +560,17 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, unsigned char *va,
>  			 struct sk_buff *skb);
>  int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
>  int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
> +/* This should be the only place where we add ifdeffery
> + * to include tsn-stuff or not. Everything else is located in igb_tsn.c
> + */
> +#if IS_ENABLED(CONFIG_IGB_TSN)
> +void igb_tsn_init(struct igb_adapter *adapter);
> +int igb_tsn_capable(struct net_device *netdev);
> +int igb_tsn_link_configure(struct net_device *netdev, enum sr_class sr_class,
> +			   u16 framesize, u16 vid);
> +#else
> +static inline void igb_tsn_init(struct igb_adapter *adapter) { }
> +#endif	/* CONFIG_IGB_TSN */
>  void igb_set_flag_queue_pairs(struct igb_adapter *, const u32);
>  #ifdef CONFIG_IGB_HWMON
>  void igb_sysfs_exit(struct igb_adapter *adapter);
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index ef3d642..4d8789f 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2142,6 +2142,10 @@ static const struct net_device_ops igb_netdev_ops = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= igb_netpoll,
>  #endif
> +#if IS_ENABLED(CONFIG_IGB_TSN)
> +	.ndo_tsn_capable	= igb_tsn_capable,
> +	.ndo_tsn_link_configure = igb_tsn_link_configure,
> +#endif	/* CONFIG_IGB_TSN */
>  	.ndo_fix_features	= igb_fix_features,
>  	.ndo_set_features	= igb_set_features,
>  	.ndo_fdb_add		= igb_ndo_fdb_add,
> @@ -2665,6 +2669,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	/* do hw tstamp init after resetting */
>  	igb_ptp_init(adapter);
>  
> +	igb_tsn_init(adapter);
> +
>  	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
>  	/* print bus type/speed/width info, not applicable to i354 */
>  	if (hw->mac.type != e1000_i354) {
> @@ -5323,8 +5329,10 @@ static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
>  	/* The minimum packet size with TCTL.PSP set is 17 so pad the skb
>  	 * in order to meet this minimum size requirement.
>  	 */
> -	if (skb_put_padto(skb, 17))
> +	if (skb_put_padto(skb, 17)) {
> +		pr_err("%s: skb_put_padto FAILED. skb->len < 17\n", __func__);
>  		return NETDEV_TX_OK;
> +	}
>  
>  	return igb_xmit_frame_ring(skb, igb_tx_queue_mapping(adapter, skb));
>  }
> diff --git a/drivers/net/ethernet/intel/igb/igb_tsn.c b/drivers/net/ethernet/intel/igb/igb_tsn.c
> new file mode 100644
> index 0000000..641f4f2
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/igb/igb_tsn.c
> @@ -0,0 +1,396 @@
> +/*
> + * Copyright(c) 2015-2016 Henrik Austad <haustad@cisco.com>
> + *                        Cisco Systems, Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + */
> +
> +/* FIXME: This should probably be handled by some Makefile-magic */
> +
> +#if IS_ENABLED(CONFIG_IGB_TSN)
> +#include "igb.h"
> +#include <linux/module.h>
> +
> +/* NOTE: keep the defines not present in e1000_regs.h to avoid
> + * cluttering too many files. Once we are pretty stable, these will move
> + * into it's proper home. Until then, make merge a bit easier by
> + * avoiding it
> + */
> +
> +/* Qav regs */
> +#define E1000_IRPBS	 0x02404 /* Rx Packet Buffer Size - RW */
> +#define E1000_ITPBS	 0x03404 /* Tx buffer size assignment */
> +#define E1000_TQAVCTRL   0x03570 /* Tx Qav Control */
> +#define E1000_DTXMXPKTSZ 0x0355C /* DMA TX Maximum Packet Size */
> +
> +/* Qav defines. */
> +#define E1000_TQAVCH_ZERO_CREDIT       0x80000000
> +#define E1000_LINK_RATE		       0x7735
> +
> +/* queue mode, 0=strict, 1=SR mode */
> +#define E1000_TQAVCC_QUEUEMODE         0x80000000
> +/* Transmit mode, 0=legacy, 1=QAV */
> +#define E1000_TQAVCTRL_TXMODE          0x00000001
> +/* report DMA time of tx packets */
> +#define E1000_TQAVCTRL_1588_STAT_EN    0x00000004
> +/* data fetch arbitration */
> +#define E1000_TQAVCTRL_DATA_FETCH_ARB  0x00000010
> +/* data tx arbitration */
> +#define E1000_TQAVCTRL_DATA_TRAN_ARB   0x00000100
> +/* data launch time valid */
> +#define E1000_TQAVCTRL_DATA_TRAN_TIM   0x00000200
> +/* stall SP to guarantee SR */
> +#define E1000_TQAVCTRL_SP_WAIT_SR      0x00000400
> +
> +/* ... and associated shift value */
> +#define E1000_TQAVCTRL_FETCH_TM_SHIFT  (16)
> +
> +/* QAV Tx mode control registers where _n can be 0 or 1. */
> +#define E1000_TQAVCC(_idx)			(0x03004 + 0x40 * (_idx))
> +
> +/* Tx Qav High Credit - See 7.2.7.6 for calculations
> + * intel 8.12.18
> + */
> +#define E1000_TQAVHC(_idx)			(0x0300C + 0x40 * (_idx))
> +
> +/* Queues priority masks where _n and _p can be 0-3. */
> +
> +#define MAX_FRAME_SIZE 1522
> +#define MIN_FRAME_SIZE   64
> +
> +static int use_tsn = -1;
> +static int debug_tsn = -1;
> +module_param(use_tsn, int, 0);
> +module_param(debug_tsn, int, 0);
> +MODULE_PARM_DESC(use_tsn, "use_tsn (0=off, 1=enabled)");
> +MODULE_PARM_DESC(debug_tsn, "debug_tsn (0=off, 1=enabled)");
> +
> +/* For a full list of the registers dumped here, see sec 8.1.3 in the
> + * i210 controller datasheet.
> + */
> +static inline void _tsn_dump_regs(struct igb_adapter *adapter)
> +{
> +	u32 val = 0;
> +	struct device *dev;
> +	struct e1000_hw *hw = &adapter->hw;
> +
> +	/* do not dump regs if we're not debugging driver */
> +	if (debug_tsn != 1)
> +		return;
> +
> +	dev = &adapter->pdev->dev;
> +	dev_info(dev, "num_tx_queues=%d, num_rx_queues=%d\n",
> +		 adapter->num_tx_queues, adapter->num_rx_queues);
> +
> +	/* 0x0008 - E1000_STATUS Device status register */
> +	val = rd32(E1000_STATUS);
> +	dev_info(&adapter->pdev->dev, "\n");
> +	dev_info(dev, "Status: FullDuplex=%s, LinkUp=%s, speed=%0x01x\n",
> +		 val & 0x1 ? "FD" : "HD",
> +		 val & 0x2 ? "LU" : "LD",
> +		 val & 0xc0 >> 6);
> +
> +	/* E1000_VET vlan ether type */
> +	val = rd32(E1000_VET);
> +	dev_info(dev, "VLAN ether type: VET.VET=0x%04x, VET.VET_EXT=0x%04x\n",
> +		 val & 0xffff, (val >> 16) & 0xffff);
> +
> +	/* E1000_RXPBS (RXPBSIZE) Rx Packet Buffer Size */
> +	val = rd32(E1000_RXPBS);
> +	dev_info(dev, "Rx Packet buffer: RXPBSIZE=%dkB, Bmc2ospbsize=%dkB, cfg_ts_en=%s\n",
> +		 val & 0x1f,
> +		 (val >> 6) & 0x1f,
> +		 (val & (1 << 31)) ? "cfg_ts_en" : "cfg_ts_dis");
> +
> +	/* Transmit stuff */
> +	/* E1000_TXPBS (TXPBSIZE) Tx Packet Buffer Size - RW */
> +	val = rd32(E1000_TXPBS);
> +	dev_info(dev, "Tx Packet buffer: Txpb0size=%dkB, Txpb1size=%dkB, Txpb2size=%dkB, Txpb3size=%dkB, os2Bmcpbsize=%dkB\n",
> +		 val & 0x3f, (val >> 6) & 0x3f, (val >> 12) & 0x3f,
> +		 (val >> 18) & 0x3f, (val >> 24) & 0x3f);
> +
> +	/* E1000_TCTL (TCTL) Tx control - RW*/
> +	val = rd32(E1000_TCTL);
> +	dev_info(dev, "Tx control reg: TxEnable=%s, CT=0x%X\n",
> +		 val & 2 ? "EN" : "DIS", (val >> 3) & 0x3F);
> +
> +	/* TQAVHC     : Transmit Qav High credits 0x300C + 0x40*n - RW */
> +	val = rd32(E1000_TQAVHC(0));
> +	dev_info(dev, "E1000_TQAVHC0: %0x08x\n", val);
> +	val = rd32(E1000_TQAVHC(1));
> +	dev_info(dev, "E1000_TQAVHC1: %0x08x\n", val);
> +
> +	/* TQAVCC[0-1]: Transmit Qav 0x3004 + 0x40*n  - RW */
> +	val = rd32(E1000_TQAVCC(0));
> +	dev_info(dev, "E1000_TQAVCC0: idleSlope=%02x, QueueMode=%s\n",
> +		 val % 0xff,
> +		 val > 31 ? "Stream reservation" : "Strict priority");
> +	val = rd32(E1000_TQAVCC(1));
> +	dev_info(dev, "E1000_TQAVCC1: idleSlope=%02x, QueueMode=%s\n",
> +		 val % 0xff,
> +		 val > 31 ? "Stream reservation" : "Strict priority");
> +
> +	/* TQAVCTRL   : Transmit Qav control - RW */
> +	val = rd32(E1000_TQAVCTRL);
> +	dev_info(dev, "E1000_TQAVCTRL: TransmitMode=%s,1588_STAT_EN=%s,DataFetchARB=%s,DataTranARB=%s,DataTranTIM=%s,SP_WAIT_SR=%s,FetchTimDelta=%dns (0x%04x)\n",
> +		 (val & 0x0001) ? "Qav" : "Legacy",
> +		 (val & 0x0004) ? "En" : "Dis",
> +		 (val & 0x0010) ? "Most Empty" : "Round Robin",
> +		 (val & 0x0100) ? "Credit Shaper" : "Strict priority",
> +		 (val & 0x0200) ? "Valid" : "N/A",
> +		 (val & 0x0400) ? "Wait" : "nowait",
> +		 (val >> 16) * 32, (val >> 16));
> +}
> +
> +/* Place the NIC in Qav-mode.
> + *
> + * This will result in a _single_ queue for normal BE traffic, the rest
> + * will be grabbed by the Qav-machinery and kept for strict priority
> + * transmission.
> + *
> + * I210 Datasheet Sec 7.2.7.7 gives a lot of information.
> + */
> +void igb_tsn_init(struct igb_adapter *adapter)
> +{
> +	struct e1000_hw *hw = &adapter->hw;
> +	u32 val;
> +
> +	if (use_tsn != 1) {
> +		adapter->tsn_ready = 0;
> +		dev_info(&adapter->pdev->dev, "%s got use_tsn > 0 (%d)\n",
> +			 __func__, use_tsn);
> +		return;
> +	}
> +
> +	if (debug_tsn < 0 || debug_tsn > 1)
> +		debug_tsn = 0;
> +
> +	if (!adapter->pdev) {
> +		adapter->tsn_ready = 0;
> +		return;
> +	}
> +
> +	switch (adapter->pdev->device) {
> +	case 0x1533:   /* E1000_DEV_ID_I210_COPPER */
> +	case 0x1536:   /* E1000_DEV_ID_I210_FIBER */
> +	case 0x1537:   /* E1000_DEV_ID_I210_SERDES: */
> +	case 0x1538:   /* E1000_DEV_ID_I210_SGMII: */
> +	case 0x157b:   /* E1000_DEV_ID_I210_COPPER_FLASHLESS: */
> +	case 0x157c:   /* E1000_DEV_ID_I210_SERDES_FLASHLESS: */
> +		break;
> +	default:
> +		/* not a known IGB-TSN capable device */
> +		adapter->tsn_ready = 0;
> +		return;
> +	}
> +	_tsn_dump_regs(adapter);
> +
> +	/* Set Tx packet buffer size assignment, see 7.2.7.7 in i210
> +	 * PB0: 8kB
> +	 * PB1: 8kB
> +	 * PB2: 4kB
> +	 * PB3: 4kB
> +	 * os2bmcsize: 2kB
> +	 * sumTx: 26kB
> +	 *
> +	 * Rxpbsize: 0x20 (32kB)
> +	 * bmc2ossize: 0x02
> +	 * sumRx: 34kB
> +	 *
> +	 * See 8.3.1 && 8.3.2
> +	 */
> +	val = (0x02 << 24 | 0x04 << 18 | 0x04 << 12 | 0x08 << 6 | 0x08);
> +	wr32(E1000_ITPBS, val);
> +	wr32(E1000_IRPBS, (0x02 << 6 | 0x20));
> +
> +	/* DMA Tx maximum packet size, the largest frame DMA should transport
> +	 * do not allow frames larger than 1522 + preample. Reg expects
> +	 * size in 64B increments. 802.1BA 6.3
> +	 * Round up to 1536 to handle 64B increments
> +	 *
> +	 * Initial value: 0x98 (152 => 9728 bytes)
> +	 */
> +	wr32(E1000_DTXMXPKTSZ, 1536 >> 6);
> +
> +	/* Place card in Qav-mode, use tx-queue 0,1 for Qav
> +	 * (Credit-based shaper), 2,3 for standard priority (and
> +	 * best-effort) traffic.
> +	 *
> +	 * i210 8.12.19 and 8.12.21
> +	 *
> +	 * - Fetch: most empty and time based (not round-robin)
> +	 * - Transmit: Credit based shaper for SR queues
> +	 * - Data launch time valid (in Qav mode)
> +	 * - Wait for SR queues to ensure that launch time is always valid.
> +	 * - Set ~10us wait-time-delta, 32ns granularity
> +	 *
> +	 * Do *not* enable Tx for shaper (E1000_TQAVCTRL_DATA_TRAN_ARB)
> +	 * yet as we do not have data to Tx
> +	 */
> +	val = E1000_TQAVCTRL_TXMODE           |
> +		E1000_TQAVCTRL_DATA_FETCH_ARB |
> +		E1000_TQAVCTRL_DATA_TRAN_TIM  |
> +		E1000_TQAVCTRL_SP_WAIT_SR     |
> +		320 << E1000_TQAVCTRL_FETCH_TM_SHIFT;
> +
> +	wr32(E1000_TQAVCTRL, val);
> +
> +	/* For now, only set CreditBased shaper for A and B, not set
> +	 * idleSlope as we have not yet gotten any streams.
> +	 * 8.12.19
> +	 */
> +	wr32(E1000_TQAVCC(0), E1000_TQAVCC_QUEUEMODE);
> +	wr32(E1000_TQAVCC(1), E1000_TQAVCC_QUEUEMODE);
> +
> +	wr32(E1000_TQAVHC(0), E1000_TQAVCH_ZERO_CREDIT);
> +	wr32(E1000_TQAVHC(1), E1000_TQAVCH_ZERO_CREDIT);
> +
> +	/* reset Tx Descriptor tail and head for the queues */
> +	wr32(E1000_TDT(0), 0);
> +	wr32(E1000_TDT(1), 0);
> +	wr32(E1000_TDH(0), 0);
> +	wr32(E1000_TDH(1), 0);
> +
> +	_tsn_dump_regs(adapter);
> +	dev_info(&adapter->pdev->dev, "\n");
> +
> +	adapter->sra_idleslope_res = 0;
> +	adapter->srb_idleslope_res = 0;
> +	adapter->tsn_ready = 1;
> +
> +	dev_info(&adapter->pdev->dev, "%s: setup done\n", __func__);
> +}
> +
> +int igb_tsn_capable(struct net_device *netdev)
> +{
> +	struct igb_adapter *adapter;
> +
> +	if (!netdev)
> +		return -EINVAL;
> +	adapter = netdev_priv(netdev);
> +	if (use_tsn == 1)
> +		return adapter->tsn_ready == 1;
> +	return 0;
> +}
> +
> +/* igb_tsn_link_configure - configure NIC to handle a new stream
> + *
> + * @netdev: pointer to NIC device
> + * @class: the class for the stream used to find the correct queue.
> + * @framesize: size of each frame, *including* headers (not preamble)
> + * @vid: VLAN ID
> + *
> + * NOTE: the sr_class only instructs the driver which queue to use, not
> + * what priority the network expects for a given class. This is
> + * something userspace must find out and then let the tsn-driver set in
> + * the frame before xmit.
> + *
> + * FIXME: remove bw-req from a stream that goes away.
> + */
> +int igb_tsn_link_configure(struct net_device *netdev, enum sr_class class,
> +			   u16 framesize, u16 vid)
> +{
> +	/* FIXME: push into adapter-storage */
> +	static int class_a_size;
> +	static int class_b_size;
> +	int err;
> +	u32 idle_slope_a = 0;
> +	u32 idle_slope_b = 0;
> +	u32 new_is = 0;
> +	u32 hicred_a = 0;
> +	u32 hicred_b = 0;
> +	u32 tqavctrl;
> +
> +	struct igb_adapter *adapter;
> +	struct e1000_hw *hw;
> +
> +	if (!netdev)
> +		return -EINVAL;
> +	adapter  = netdev_priv(netdev);
> +	hw = &adapter->hw;
> +
> +	if (!igb_tsn_capable(netdev)) {
> +		pr_err("%s:  NIC not capable\n", __func__);
> +		return -EINVAL;
> +	}
> +
> +	if (framesize > MAX_FRAME_SIZE || framesize < MIN_FRAME_SIZE) {
> +		pr_err("%s: framesize (%u) must be [%d,%d]\n", __func__,
> +		       framesize, MIN_FRAME_SIZE, MAX_FRAME_SIZE);
> +		return -EINVAL;
> +	}
> +
> +	/* TODO: is this the correct place/way? Is it required? */
> +	rtnl_lock();
> +	pr_info("%s: adding VLAN %u to HW filter on device %s\n",
> +		__func__, vid, netdev->name);
> +	err = vlan_vid_add(netdev, htons(ETH_P_8021Q), vid);
> +	if (err != 0)
> +		pr_err("%s: error adding vlan %u, res=%d\n",
> +		       __func__, vid, err);
> +	rtnl_unlock();
> +
> +	/* Grab current values of idle_slope */
> +	idle_slope_a = rd32(E1000_TQAVHC(0)) & ~E1000_TQAVCH_ZERO_CREDIT;
> +	idle_slope_b = rd32(E1000_TQAVHC(1)) & ~E1000_TQAVCH_ZERO_CREDIT;
> +
> +	/* Calculate new idle slope and add to appropriate idle_slope
> +	 * idle_slope = BW * linkrate * 2 (0r 0.2 for 100Mbit)
> +	 * BW: % of total bandwidth
> +	 */
> +	new_is = framesize * E1000_LINK_RATE * 16 / 1000000;
> +
> +	switch (class) {
> +	case SR_CLASS_A:
> +		new_is *= 2; /* A is 8kHz, B is 4kHz */
> +		idle_slope_a += new_is;
> +		class_a_size  = framesize;
> +		break;
> +	case SR_CLASS_B:
> +		idle_slope_b += new_is;
> +		class_b_size  = framesize;
> +		break;
> +	default:
> +		pr_err("%s: unhandled SR-class (%d)\n", __func__, class);
> +		return -EINVAL;
> +	}
> +
> +	/* HiCred: cred obtained while waiting for current frame &&
> +	 * higher-class frames to finish xmit.
> +	 *
> +	 * Covered in detail in 7.2.7.6 in i210 datasheet
> +	 * For class A: only worst-case framesize that just started;
> +	 *		i.e. 1522 * idleSlope / linkrate;
> +	 * For class B: (worst-case framesize + burstSize(A))*idleSlope
> +	 *
> +	 * See 802.1Q Annex L, eq L.10 for hicred_a and L.41 for
> +	 * hicred_b
> +	 */
> +	if (class == SR_CLASS_A) {
> +		hicred_a = E1000_TQAVCH_ZERO_CREDIT + idle_slope_a * MAX_FRAME_SIZE / E1000_LINK_RATE;
> +		wr32(E1000_TQAVCC(0), E1000_TQAVCC_QUEUEMODE | idle_slope_a);
> +		wr32(E1000_TQAVHC(0), hicred_a);
> +	} else {
> +		hicred_b = E1000_TQAVCH_ZERO_CREDIT | idle_slope_b * (MAX_FRAME_SIZE + class_a_size) / (E1000_LINK_RATE - idle_slope_a);
> +		wr32(E1000_TQAVCC(1), E1000_TQAVCC_QUEUEMODE | idle_slope_b);
> +		wr32(E1000_TQAVHC(1), hicred_b);
> +	}
> +
> +	/* Enable Tx for shaper now that we have data */
> +	tqavctrl = rd32(E1000_TQAVCTRL);
> +	if (!(tqavctrl & E1000_TQAVCTRL_DATA_TRAN_ARB)) {
> +		tqavctrl |= E1000_TQAVCTRL_DATA_TRAN_ARB;
> +		wr32(E1000_TQAVCTRL, tqavctrl);
> +	}
> +	_tsn_dump_regs(netdev_priv(netdev));
> +	return 0;
> +}
> +
> +#endif	/* #if IS_ENABLED(CONFIG_IGB_TSN) */
> -- 
> 2.7.4
> 

-- 
Henrik Austad
