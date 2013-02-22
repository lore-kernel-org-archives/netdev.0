From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fw: [Bug 54231] r8169 driver regression caused by the commit aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
Date: Sat, 23 Feb 2013 00:09:08 +0100
Message-ID: <20130222230908.GB4248@electric-eye.fr.zoreil.com>
References: <20130222095546.396e63a8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tomimo@ncircle.nullnet.fi
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36105 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756412Ab3BVXlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 18:41:04 -0500
Content-Disposition: inline
In-Reply-To: <20130222095546.396e63a8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> :
[...]
> https://bugzilla.kernel.org/show_bug.cgi?id=54231
> 
> --- Comment #1 from Tomi Orava <tomimo@ncircle.nullnet.fi>  2013-02-22 16:40:49 ---
> Although the r8169 has been working just fine on 3.4.31 for the past 5 days, it
> seems that I missed the second DMA Burst setting in the previous patch that
> should get fixed as well:
[...]
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4406,8 +4407,14 @@ static void rtl_set_rx_tx_config_registers(struct
> rtl8169_private *tp)
>      void __iomem *ioaddr = tp->mmio_addr;
> 
>      /* Set DMA burst size and Interframe Gap Time */
> -    RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
> -        (InterFrameGap << TxInterFrameGapShift));
> +
> +    if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
> +        RTL_W32(TxConfig, (TX_DMA_BURST_512 << TxDMAShift) |
> +            (InterFrameGap << TxInterFrameGapShift));
> +    } else {
> +        RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
> +            (InterFrameGap << TxInterFrameGapShift));
> +    }
>  }

This one should not be used in the (RTL_CFG_1) 8168 / RTL_GIGA_MAC_VER_11
path.

Tomi, what does lspci say about your 8168b device ?

>  static void rtl_hw_start(struct net_device *dev)
> @@ -5148,8 +5155,13 @@ static void rtl_hw_start_8168(struct net_device *dev)
> 
>      rtl_set_rx_mode(dev);
> 
> -    RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
> -        (InterFrameGap << TxInterFrameGapShift));
> +    if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
> +        RTL_W32(TxConfig, (TX_DMA_BURST_512 << TxDMAShift) |
> +            (InterFrameGap << TxInterFrameGapShift));
> +    } else {
> +        RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
> +            (InterFrameGap << TxInterFrameGapShift));
> +    }

	RTL_W32(TxConfig, (InterFrameGap << TxInterFrameGapShift) |
		(((tp->mac_version == RTL_GIGA_MAC_VER_11) ?
		 TX_DMA_BURST_512 : TX_DMA_BURST) << TxDMAShift));

-- 
Ueimor
