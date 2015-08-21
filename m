From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Fri, 21 Aug 2015 21:39:26 +0200
Message-ID: <20150821193926.GA16437@electric-eye.fr.zoreil.com>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54517 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbbHUTkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 15:40:02 -0400
Content-Disposition: inline
In-Reply-To: <1440151756-18165-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index f790f61..f26a48d 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -2179,6 +2191,47 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
>  	}
>  }
>  
> +DECLARE_RTL_COND(rtl_reset_counters_cond)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +
> +	return RTL_R32(CounterAddrLow) & CounterReset;
> +}
> +
> +static void rtl8169_reset_counters(struct net_device *dev)
> +{

rtl8169_reset_counters duplicates most of rtl8169_update_counters. Please
factor out the dma_alloc + parametrized CounterAddrLow write + cleanup.

[...]
> @@ -2220,6 +2273,39 @@ static void rtl8169_update_counters(struct net_device *dev)
>  	dma_free_coherent(d, sizeof(*counters), counters, paddr);
>  }
>  
> +static void rtl8169_init_counter_offsets(struct net_device *dev)
> +{
> +	struct rtl8169_private *tp = netdev_priv(dev);
> +
> +	/*
> +	 * rtl8169_init_counter_offsets is called from rtl_open.  On chip
> +	 * versions prior to RTL_GIGA_MAC_VER_19 the tally counters are only
> +	 * reset by a power cycle, while the counter values collected by the
> +	 * driver are reset at every driver unload/load cycle.
> +	 *
> +	 * To make sure the HW values returned by @get_stats64 match the SW
> +	 * values, we collect the initial values at first open(*) and use them
> +	 * as offsets to normalize the values returned by @get_stats64.
> +	 *
> +	 * (*) We can't call rtl8169_init_counter_offsets from rtl_init_one
> +	 * for the reason stated in rtl8169_update_counters; CmdRxEnb is only
> +	 * set at open time by rtl_hw_start.
> +	 */
> +
> +	if (tp->tc_offset.inited)
> +		return;
> +
> +	rtl8169_reset_counters(dev);
> +
> +	rtl8169_update_counters(dev);


The code should propagate failure when both rtl8169_reset_counters and
rtl8169_update_counters fail.

--
Ueimor
