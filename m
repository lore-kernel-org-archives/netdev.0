From: Tomi Orava <tomimo@ncircle.nullnet.fi>
Subject: Re: [PATCH net 1/1] r8169: honor jumbo settings when chipset is requested
 to start.
Date: Sat, 02 Mar 2013 18:43:28 +0200
Message-ID: <51322C30.2090308@ncircle.nullnet.fi>
References: <20130227230157.GA30053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-83-150-88-111.nebulazone.fi ([83.150.88.111]:53089 "EHLO
	ncircle.nullnet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab3CBQnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Mar 2013 11:43:35 -0500
In-Reply-To: <20130227230157.GA30053@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 01:01 AM, Francois Romieu wrote:
> Some hardware start settings implicitely assume an usual 1500 bytes mtu
> that can't be guaranteed because changes of mtu may be requested both
> before and after the hardware is started.
> 
> Reported-by: Tomi Orava <tomimo@ncircle.nullnet.fi>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> ---
> 
>  Tomi, can you give this one a try ? It should be the "don't break non
>  jumbo setup and fix similar problem on different chipsets" patch that
>  my previous hack wasn't.

This latest worked just fine, no matter if the system was cold booted or
warm booted with jumbo frames enabled using this NIC:

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)

03:00.0 0200: 10ec:8168 (rev 01)
	Subsystem: 1043:8385
	Flags: bus master, fast devsel, latency 0, IRQ 40
	I/O ports at e800 [size=256]
	Memory at febff000 (64-bit, non-prefetchable) [size=4K]
	Expansion ROM at febc0000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 2
	Capabilities: [48] Vital Product Data
	Capabilities: [50] MSI: Enable+ Count=1/2 Maskable- 64bit+
	Capabilities: [60] Express Endpoint, MSI 00
	Capabilities: [84] Vendor Specific Information: Len=4c <?>
	Kernel driver in use: r8169

Ie. works for me.

Thanks!
Tomi

> 
>  drivers/net/ethernet/realtek/r8169.c | 27 ++++++++++++++++++---------
>  1 file changed, 18 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 8900398..28fb50a 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4765,8 +4765,10 @@ static void rtl_hw_start_8168bb(struct rtl8169_private *tp)
>  
>  	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
>  
> -	rtl_tx_performance_tweak(pdev,
> -		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
> +	if (tp->dev->mtu <= ETH_DATA_LEN) {
> +		rtl_tx_performance_tweak(pdev, (0x5 << MAX_READ_REQUEST_SHIFT) |
> +					 PCI_EXP_DEVCTL_NOSNOOP_EN);
> +	}
>  }
>  
>  static void rtl_hw_start_8168bef(struct rtl8169_private *tp)
> @@ -4789,7 +4791,8 @@ static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
>  
>  	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
>  
>  	rtl_disable_clock_request(pdev);
>  
> @@ -4822,7 +4825,8 @@ static void rtl_hw_start_8168cp_2(struct rtl8169_private *tp)
>  
>  	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
>  
>  	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
>  }
> @@ -4841,7 +4845,8 @@ static void rtl_hw_start_8168cp_3(struct rtl8169_private *tp)
>  
>  	RTL_W8(MaxTxPacketSize, TxPacketMax);
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
>  
>  	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
>  }
> @@ -4901,7 +4906,8 @@ static void rtl_hw_start_8168d(struct rtl8169_private *tp)
>  
>  	RTL_W8(MaxTxPacketSize, TxPacketMax);
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
>  
>  	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
>  }
> @@ -4913,7 +4919,8 @@ static void rtl_hw_start_8168dp(struct rtl8169_private *tp)
>  
>  	rtl_csi_access_enable_1(tp);
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
>  
>  	RTL_W8(MaxTxPacketSize, TxPacketMax);
>  
> @@ -4972,7 +4979,8 @@ static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
>  
>  	rtl_ephy_init(tp, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
>  
>  	RTL_W8(MaxTxPacketSize, TxPacketMax);
>  
> @@ -4998,7 +5006,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
>  
>  	rtl_ephy_init(tp, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
>  
>  	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
>  	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
> 
