From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH 1/5] r8169: more magic during initialization of the hardware
Date: Wed, 06 Dec 2006 15:28:27 +1000
Message-ID: <457654FB.5020507@snapgear.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061203235454.GB3625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Darren Salt <linux@youmustbejoking.demon.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:35789 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760138AbWLFF2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 00:28:36 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061203235454.GB3625@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Mostly taken from Realtek's driver.
> 
> It's a bit yucky but the original is even worse.

This patch fixes a performance regression for my 8169s.
But it appears to have a typo, see below.


> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Signed-off-by: Darren Salt <linux@youmustbejoking.demon.co.uk>
> ---
>  drivers/net/r8169.c |   58 +++++++++++++++++++++++++++++++++++++++------------
>  1 files changed, 44 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 45d3ca4..c8fa9b1 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1815,12 +1815,25 @@ static void rtl8169_hw_reset(void __iome
>  	RTL_R8(ChipCmd);
>  }
>  
> -static void
> -rtl8169_hw_start(struct net_device *dev)
> +static void rtl8169_set_rx_tx_config_registers(struct rtl8169_private *tp)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	u32 cfg = rtl8169_rx_config;
> +
> +	cfg |= (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
> +	RTL_W32(RxConfig, cfg);
> +
> +	/* Set DMA burst size and Interframe Gap Time */
> +	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
> +		(InterFrameGap << TxInterFrameGapShift));
> +}
> +
> +static void rtl8169_hw_start(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  	void __iomem *ioaddr = tp->mmio_addr;
>  	struct pci_dev *pdev = tp->pci_dev;
> +	u16 cmd;
>  	u32 i;
>  
>  	/* Soft reset the chip. */
> @@ -1833,6 +1846,11 @@ rtl8169_hw_start(struct net_device *dev)
>  		msleep_interruptible(1);
>  	}
>  
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
> +		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | PCIMulRW);
> +		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
> +	}
> +
>  	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
>  		pci_write_config_word(pdev, 0x68, 0x00);
>  		pci_write_config_word(pdev, 0x69, 0x08);
> @@ -1840,8 +1858,6 @@ rtl8169_hw_start(struct net_device *dev)
>  
>  	/* Undocumented stuff. */
>  	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
> -		u16 cmd;
> -
>  		/* Realtek's r1000_n.c driver uses '&& 0x01' here. Well... */
>  		if ((RTL_R8(Config2) & 0x07) & 0x01)
>  			RTL_W32(0x7c, 0x0007ffff);
> @@ -1853,23 +1869,29 @@ rtl8169_hw_start(struct net_device *dev)
>  		pci_write_config_word(pdev, PCI_COMMAND, cmd);
>  	}
>  
> -
>  	RTL_W8(Cfg9346, Cfg9346_Unlock);
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
> +		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
> +
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
>  	/* Low hurts. Let's disable the filtering. */
>  	RTL_W16(RxMaxSize, 16383);
>  
> -	/* Set Rx Config register */
> -	i = rtl8169_rx_config |
> -		(RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
> -	RTL_W32(RxConfig, i);
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
> +		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
> +		rtl8169_set_rx_tx_config_registers(tp);

Should this RTL_W8() be deleted?
Otherwise there is an indentation/braces mismatch.


>  
> -	/* Set DMA burst size and Interframe Gap Time */
> -	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
> -		(InterFrameGap << TxInterFrameGapShift));
> +	cmd = RTL_R16(CPlusCmd);
> +	RTL_W16(CPlusCmd, cmd);
>  
> -	tp->cp_cmd |= RTL_R16(CPlusCmd) | PCIMulRW;
> +	tp->cp_cmd |= cmd | PCIMulRW;
>  
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
> @@ -1895,7 +1917,15 @@ rtl8169_hw_start(struct net_device *dev)
>  	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
>  	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
>  	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
> -	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
> +
> +	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
> +	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
> +	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
> +	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
> +		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
> +		rtl8169_set_rx_tx_config_registers(tp);
> +	}
> +
>  	RTL_W8(Cfg9346, Cfg9346_Lock);
>  
>  	/* Initially a 10 us delay. Turned it into a PCI commit. - FR */

