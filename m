From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: Fix sleeping function called during get_stats64
Date: Thu, 10 Sep 2015 00:28:24 +0200
Message-ID: <20150909222824.GA21326@electric-eye.fr.zoreil.com>
References: <1441833400-2677-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38351 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbbIIW3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 18:29:06 -0400
Content-Disposition: inline
In-Reply-To: <1441833400-2677-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 24dcbe6..ffffc12 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -833,7 +833,8 @@ struct rtl8169_private {
>  	unsigned features;
>  
>  	struct mii_if_info mii;
> -	struct rtl8169_counters counters;
> +	dma_addr_t CntPhysAddr;
> +	struct rtl8169_counters *CntArray;

I'd rather see less camel case than more.

[...]
> @@ -2245,32 +2230,13 @@ static bool rtl8169_reset_counters(struct net_device *dev)
>  	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
>  		return true;
>  
> -	counters = rtl8169_map_counters(dev, &paddr, CounterReset);
> -	if (!counters)
> -		return false;
> -
> -	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
> -		ret = false;
> -
> -	rtl8169_unmap_counters(dev, paddr, counters);
> -
> -	return ret;
> -}
> -
> -DECLARE_RTL_COND(rtl_counters_cond)
> -{
> -	void __iomem *ioaddr = tp->mmio_addr;
> -
> -	return RTL_R32(CounterAddrLow) & CounterDump;
> +        return rtl8169_do_counters(dev, CounterReset);

spaces instead of tab.

[...]
> @@ -8483,7 +8451,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  out:
>  	return rc;
>  
> -err_out_msi_4:
> +err_out_msi_5:
> +	dma_free_coherent(&pdev->dev, sizeof(*tp->CntArray), tp->CntArray,
> +			  tp->CntPhysAddr);
> +err_out_cnt_4:
>  	netif_napi_del(&tp->napi);

These labels are supposed to suggest what should be done.

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Tested on 8168b (RTL_GIGA_MAC_VER_17).

-- 
Ueimor
