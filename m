From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/6] r8169: modify the flow hw reset
Date: Tue, 5 Jul 2011 20:55:15 +0200
Message-ID: <20110705185515.GB5105@electric-eye.fr.zoreil.com>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com> <1309859095-32031-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309859095-32031-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Replace rtl8169_asic_down with rtl8169_hw_reset. Clear RxConfig
> bit 0 ~ 3 and do some checking before reset. Remove hw reset
> which is before hw_start because reset would be done in close or
> down.

The whole description of the changes ought to explain why things are
changed.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/r8169.c |   43 ++++++++++++++++++++++++-------------------
>  1 files changed, 24 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 701ab6b..cdbbe47 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -731,6 +731,8 @@ static int rtl8169_poll(struct napi_struct *napi, int budget);
>  static const unsigned int rtl8169_rx_config =
>  	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
>  
> +static void rtl8169_init_ring_indexes(struct rtl8169_private *tp);
> +

rtl8169_init_ring_indexes is really short. Please move it before its first use
and avoid the forward declaration.

>  static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
>  {
>  	void __iomem *ioaddr = tp->mmio_addr;
> @@ -1076,13 +1078,6 @@ static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
>  	RTL_W16(IntrStatus, 0xffff);
>  }
>  
> -static void rtl8169_asic_down(void __iomem *ioaddr)
> -{
> -	RTL_W8(ChipCmd, 0x00);
> -	rtl8169_irq_mask_and_ack(ioaddr);
> -	RTL_R16(CPlusCmd);
> -}
> -
>  static unsigned int rtl8169_tbi_reset_pending(struct rtl8169_private *tp)
>  {
>  	void __iomem *ioaddr = tp->mmio_addr;
> @@ -3352,10 +3347,12 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
>  
>  	/* Check that the chip has finished the reset. */
>  	for (i = 0; i < 100; i++) {
> +		udelay(100);
>  		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
>  			break;

Nit: is it forbidden to perform the read - and thus the implicit PCI flush -
before the first 100 us delay ?

> -		msleep_interruptible(1);
>  	}
> +
> +	rtl8169_init_ring_indexes(tp);
>  }
>  
>  static int __devinit
> @@ -3737,6 +3734,16 @@ err_pm_runtime_put:
>  	goto out;
>  }
>  
> +static void rtl_rx_close(struct rtl8169_private *tp)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	u32 rxcfg = RTL_R32(RxConfig);
> +
> +	rxcfg &= ~(AcceptBroadcast | AcceptMulticast |
> +		   AcceptMyPhys | AcceptAllPhys);
> +	RTL_W32(RxConfig, rxcfg);
> +}
> +

Should not error and runt packets be considered too ?

<shot in the dark>
Is there any relationship with commit ca52efd5490f97f396d3c5863ba714624f272033 ?
</shot in the dark>

>  static void rtl8169_hw_reset(struct rtl8169_private *tp)
>  {
>  	void __iomem *ioaddr = tp->mmio_addr;
> @@ -3744,19 +3751,20 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
>  	/* Disable interrupts */
>  	rtl8169_irq_mask_and_ack(ioaddr);
>  
> +	rtl_rx_close(tp);
> +
>  	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
>  	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
>  	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
>  		while (RTL_R8(TxPoll) & NPQ)
>  			udelay(20);
>  
> +	} else {
> +		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
> +		udelay(100);

No posted PCI write flush ?

Please remove the empty line after the udelay(20). It should not
have been there in the first place.

>  	}
>  
> -	/* Reset the chipset */
> -	RTL_W8(ChipCmd, CmdReset);
> -
> -	/* PCI commit */
> -	RTL_R8(ChipCmd);
> +	rtl_hw_reset(tp);
>  }
>  
>  static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
> @@ -3776,8 +3784,6 @@ static void rtl_hw_start(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  
> -	rtl_hw_reset(tp);
> -
>  	tp->hw_start(dev);
>  
>  	netif_start_queue(dev);
> @@ -4718,7 +4724,6 @@ static void rtl8169_reset_task(struct work_struct *work)
>  
>  	rtl8169_tx_clear(tp);
>  
> -	rtl8169_init_ring_indexes(tp);
>  	rtl_hw_start(dev);
>  	netif_wake_queue(dev);
>  	rtl8169_check_link_status(dev, tp, tp->mmio_addr);

I do not see where the ring indexes will be set when __rtl8169_resume()
schedules rtl8169_reset_task. It could hurt.

-- 
Ueimor
