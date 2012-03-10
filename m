From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RE-SUBMIT 2/2] net/pch_gbe: supports eg20t ptp clock
Date: Sat, 10 Mar 2012 12:11:50 +0100
Message-ID: <20120310111149.GC3489@netboy.at.omicron.at>
References: <1331194587-29114-1-git-send-email-tshimizu818@gmail.com>
 <1331194587-29114-2-git-send-email-tshimizu818@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, arnd@arndb.de, khc@pm.waw.pl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com
To: Takahiro Shimizu <tshimizu818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63610 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab2CJLME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 06:12:04 -0500
Content-Disposition: inline
In-Reply-To: <1331194587-29114-2-git-send-email-tshimizu818@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a few issues, below.

Thanks,
Richard


On Thu, Mar 08, 2012 at 05:16:27PM +0900, Takahiro Shimizu wrote:
> From: Takahiroi Shimizu <tshimizu818@gmail.com>
> 
> Supports EG20T ptp clock in the driver
> 
> Changes e-mail address.
> 
> Adds number.
> 
> Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
> ---
>  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |   13 ++
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |   13 ++
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |  217 +++++++++++++++++++-
>  3 files changed, 240 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> index 00bc4fc..bce0164 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> @@ -20,3 +20,16 @@ config PCH_GBE
>  	  purpose use.
>  	  ML7223/ML7831 is companion chip for Intel Atom E6xx series.
>  	  ML7223/ML7831 is completely compatible for Intel EG20T PCH.
> +
> +if PCH_GBE
> +
> +config PCH_PTP
> +	bool "PCH PTP clock support"
> +	default n
> +	depends on PTP_1588_CLOCK_PCH
> +	---help---
> +	  Say Y here if you want to use Precision Time Protocol (PTP) in the
> +	  driver. PTP is a method to precisely synchronize distributed clocks
> +	  over Ethernet networks.
> +
> +endif # PCH_GBE
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> index a09a071..dd14915 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> @@ -630,6 +630,9 @@ struct pch_gbe_adapter {
>  	unsigned long tx_queue_len;
>  	bool have_msi;
>  	bool rx_stop_flag;
> +	int hwts_tx_en;
> +	int hwts_rx_en;
> +	struct pci_dev *ptp_pdev;
>  };
>  
>  extern const char pch_driver_version[];
> @@ -648,6 +651,16 @@ extern void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
>  extern void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
>  				       struct pch_gbe_rx_ring *rx_ring);
>  extern void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
> +#ifdef CONFIG_PCH_PTP
> +extern u32 pch_ch_control_read(struct pci_dev *pdev);
> +extern void pch_ch_control_write(struct pci_dev *pdev, u32 val);
> +extern u32 pch_ch_event_read(struct pci_dev *pdev);
> +extern void pch_ch_event_write(struct pci_dev *pdev, u32 val);
> +extern u32 pch_src_uuid_lo_read(struct pci_dev *pdev);
> +extern u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
> +extern u64 pch_rx_snap_read(struct pci_dev *pdev);
> +extern u64 pch_tx_snap_read(struct pci_dev *pdev);
> +#endif
>  
>  /* pch_gbe_param.c */
>  extern void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 3ead111..aa54ede 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -1,6 +1,6 @@
>  /*
>   * Copyright (C) 1999 - 2010 Intel Corporation.
> - * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
> + * Copyright (C) 2010 - 2012 LAPIS SEMICONDUCTOR CO., LTD.
>   *
>   * This code was derived from the Intel e1000e Linux driver.
>   *
> @@ -21,6 +21,10 @@
>  #include "pch_gbe.h"
>  #include "pch_gbe_api.h"
>  #include <linux/module.h>
> +#ifdef CONFIG_PCH_PTP
> +#include <linux/net_tstamp.h>
> +#include <linux/ptp_classify.h>
> +#endif
>  
>  #define DRV_VERSION     "1.00"
>  const char pch_driver_version[] = DRV_VERSION;
> @@ -95,12 +99,195 @@ const char pch_driver_version[] = DRV_VERSION;
>  
>  #define PCH_GBE_INT_DISABLE_ALL		0
>  
> +#ifdef CONFIG_PCH_PTP
> +/* Macros for ieee1588 */
> +#define TICKS_NS_SHIFT  5

Remove this macro and keep it internal to ptp_pch.c.

> +
> +/* 0x40 Time Synchronization Channel Control Register Bits */
> +#define MASTER_MODE   (1<<0)
> +#define SLAVE_MODE    (0<<0)
> +#define V2_MODE       (1<<31)
> +#define CAP_MODE0     (0<<16)
> +#define CAP_MODE2     (1<<17)
> +
> +/* 0x44 Time Synchronization Channel Event Register Bits */
> +#define TX_SNAPSHOT_LOCKED (1<<0)
> +#define RX_SNAPSHOT_LOCKED (1<<1)
> +#endif
> +
>  static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
>  
>  static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
>  static void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg,
>  			       int data);
>  
> +#ifdef CONFIG_PCH_PTP
> +static struct sock_filter ptp_filter[] = {
> +	PTP_FILTER
> +};
> +
> +static int pch_ptp_match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seqid)
> +{
> +	u8 *data = skb->data;
> +	unsigned int offset;
> +	u16 *hi, *id;
> +	u32 lo;
> +
> +	if ((sk_run_filter(skb, ptp_filter) != PTP_CLASS_V2_IPV4) &&
> +		(sk_run_filter(skb, ptp_filter) != PTP_CLASS_V1_IPV4)) {

No, just run the filter once and test the result twice.

Also, doesn't the timestamping unit work with IPv6 and L2?  If so,
don't restrict the driver to IPv4.

> +		return 0;
> +	}
> +
> +	offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
> +
> +	if (skb->len < offset + OFF_PTP_SEQUENCE_ID + sizeof(seqid))
> +		return 0;
> +
> +	hi = (u16 *)(data + offset + OFF_PTP_SOURCE_UUID);
> +	id = (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
> +
> +	memcpy(&lo, &hi[1], sizeof(lo));
> +
> +	return (uid_hi == *hi &&
> +		uid_lo == lo &&
> +		seqid  == *id);
> +}
> +
> +static void pch_rx_timestamp(
> +			struct pch_gbe_adapter *adapter, struct sk_buff *skb)

Ugly line break. If you are worrried about the 80 character limit,
then how about something like this instead?

static void pch_rx_timestamp(struct pch_gbe_adapter *pga, struct sk_buff *skb)

> +{
> +	struct skb_shared_hwtstamps *shhwtstamps;
> +	struct pci_dev *pdev;
> +	u64 ns;
> +	u32 hi, lo, val;
> +	u16 uid, seq;
> +
> +	if (!adapter->hwts_rx_en)
> +		return;
> +
> +	/* Get ieee1588's dev information */
> +	pdev = adapter->ptp_pdev;
> +
> +	val = pch_ch_event_read(pdev);
> +
> +	if (!(val & RX_SNAPSHOT_LOCKED))
> +		return;
> +
> +	lo = pch_src_uuid_lo_read(pdev);
> +	hi = pch_src_uuid_hi_read(pdev);
> +
> +	uid = hi & 0xffff;
> +	seq = (hi >> 16) & 0xffff;
> +
> +	if (!pch_ptp_match(skb, htons(uid), htonl(lo), htons(seq)))
> +		goto out;
> +
> +	ns = pch_rx_snap_read(pdev);
> +	ns <<= TICKS_NS_SHIFT;

Do this shift in pch_rx_snap_read() instead.

> +
> +	shhwtstamps = skb_hwtstamps(skb);
> +	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
> +	shhwtstamps->hwtstamp = ns_to_ktime(ns);
> +out:
> +	pch_ch_event_write(pdev, RX_SNAPSHOT_LOCKED);
> +}
> +
> +static void pch_tx_timestamp(
> +			struct pch_gbe_adapter *adapter, struct sk_buff *skb)

Another ugly line break.

> +{
> +	struct skb_shared_hwtstamps shhwtstamps;
> +	struct pci_dev *pdev;
> +	struct skb_shared_info *shtx;
> +	u64 ns;
> +	u32 cnt, val;
> +
> +	shtx = skb_shinfo(skb);
> +	if (unlikely(shtx->tx_flags & SKBTX_HW_TSTAMP && adapter->hwts_tx_en))
> +		shtx->tx_flags |= SKBTX_IN_PROGRESS;
> +	else
> +		return;
> +
> +	/* Get ieee1588's dev information */
> +	pdev = adapter->ptp_pdev;
> +
> +	/*
> +	 * This really stinks, but we have to poll for the Tx time stamp.
> +	 * Usually, the time stamp is ready after 4 to 6 microseconds.
> +	 */
> +	for (cnt = 0; cnt < 100; cnt++) {
> +		val = pch_ch_event_read(pdev);
> +		if (val & TX_SNAPSHOT_LOCKED)
> +			break;
> +		udelay(1);
> +	}
> +	if (!(val & TX_SNAPSHOT_LOCKED)) {
> +		shtx->tx_flags &= ~SKBTX_IN_PROGRESS;
> +		return;
> +	}
> +
> +	ns = pch_tx_snap_read(pdev);
> +	ns <<= TICKS_NS_SHIFT;

Do the shift in pch_tx_snap_read().

> +
> +	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> +	shhwtstamps.hwtstamp = ns_to_ktime(ns);
> +	skb_tstamp_tx(skb, &shhwtstamps);
> +
> +	pch_ch_event_write(pdev, TX_SNAPSHOT_LOCKED);
> +}
> +
> +static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
> +{
> +	struct hwtstamp_config cfg;
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	struct pci_dev *pdev;
> +
> +	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
> +		return -EFAULT;
> +
> +	if (cfg.flags) /* reserved for future extensions */
> +		return -EINVAL;
> +
> +	/* Get ieee1588's dev information */
> +	pdev = adapter->ptp_pdev;
> +
> +	switch (cfg.tx_type) {
> +	case HWTSTAMP_TX_OFF:
> +		adapter->hwts_tx_en = 0;
> +		break;
> +	case HWTSTAMP_TX_ON:
> +		adapter->hwts_tx_en = 1;
> +		break;
> +	default:
> +		return -ERANGE;
> +	}
> +
> +	switch (cfg.rx_filter) {
> +	case HWTSTAMP_FILTER_NONE:
> +		adapter->hwts_rx_en = 0;
> +		break;
> +	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
> +		adapter->hwts_rx_en = 0;
> +		pch_ch_control_write(pdev, (SLAVE_MODE | CAP_MODE0));
> +		break;
> +	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
> +		adapter->hwts_rx_en = 1;
> +		pch_ch_control_write(pdev, (MASTER_MODE | CAP_MODE0));
> +		break;
> +	case HWTSTAMP_FILTER_PTP_V2_EVENT:
> +		adapter->hwts_rx_en = 1;
> +		pch_ch_control_write(pdev, (V2_MODE | CAP_MODE2));
> +		break;
> +	default:
> +		return -ERANGE;
> +	}
> +
> +	/* Clear out any old time stamps. */
> +	pch_ch_event_write(pdev, TX_SNAPSHOT_LOCKED | RX_SNAPSHOT_LOCKED);
> +
> +	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
> +}
> +#endif
> +
>  inline void pch_gbe_mac_load_mac_addr(struct pch_gbe_hw *hw)
>  {
>  	iowrite32(0x01, &hw->reg->MAC_ADDR_LOAD);
> @@ -1072,6 +1259,11 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
>  	iowrite32(tx_ring->dma +
>  		  (int)sizeof(struct pch_gbe_tx_desc) * ring_num,
>  		  &hw->reg->TX_DSC_SW_P);
> +
> +#ifdef CONFIG_PCH_PTP
> +	pch_tx_timestamp(adapter, skb);
> +#endif
> +
>  	dev_kfree_skb_any(skb);
>  }
>  
> @@ -1543,6 +1735,11 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
>  				adapter->stats.multicast++;
>  			/* Write meta date of skb */
>  			skb_put(skb, length);
> +
> +#ifdef CONFIG_PCH_PTP
> +			pch_rx_timestamp(adapter, skb);
> +#endif
> +
>  			skb->protocol = eth_type_trans(skb, netdev);
>  			if (tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK)
>  				skb->ip_summed = CHECKSUM_NONE;
> @@ -2147,6 +2344,11 @@ static int pch_gbe_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>  
>  	pr_debug("cmd : 0x%04x\n", cmd);
>  
> +#ifdef CONFIG_PCH_PTP
> +	if (cmd == SIOCSHWTSTAMP)
> +		return hwtstamp_ioctl(netdev, ifr, cmd);
> +#endif
> +
>  	return generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
>  }
>  
> @@ -2440,6 +2642,15 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>  		goto err_free_netdev;
>  	}
>  
> +#ifdef CONFIG_PCH_PTP
> +	adapter->ptp_pdev = pci_get_bus_and_slot(adapter->pdev->bus->number,
> +					       PCI_DEVFN(12, 4));
> +	if (ptp_filter_init(ptp_filter, ARRAY_SIZE(ptp_filter))) {
> +		pr_err("Bad ptp filter\n");
> +		return -EINVAL;
> +	}
> +#endif
> +
>  	netdev->netdev_ops = &pch_gbe_netdev_ops;
>  	netdev->watchdog_timeo = PCH_GBE_WATCHDOG_PERIOD;
>  	netif_napi_add(netdev, &adapter->napi,
> @@ -2504,7 +2715,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>  	netif_carrier_off(netdev);
>  	netif_stop_queue(netdev);
>  
> -	dev_dbg(&pdev->dev, "OKIsemi(R) PCH Network Connection\n");
> +	dev_dbg(&pdev->dev, "PCH Network Connection\n");
>  
>  	device_set_wakeup_enable(&pdev->dev, 1);
>  	return 0;
> @@ -2605,7 +2816,7 @@ module_init(pch_gbe_init_module);
>  module_exit(pch_gbe_exit_module);
>  
>  MODULE_DESCRIPTION("EG20T PCH Gigabit ethernet Driver");
> -MODULE_AUTHOR("OKI SEMICONDUCTOR, <toshiharu-linux@dsn.okisemi.com>");
> +MODULE_AUTHOR("LAPIS SEMICONDUCTOR, <tshimizu818@gmail.com>");
>  MODULE_LICENSE("GPL");
>  MODULE_VERSION(DRV_VERSION);
>  MODULE_DEVICE_TABLE(pci, pch_gbe_pcidev_id);
> -- 
> 1.7.4.4
> 
