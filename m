From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169:add support for RTL8168EP
Date: Sat, 27 Sep 2014 22:39:21 +0200
Message-ID: <20140927203921.GB28553@electric-eye.fr.zoreil.com>
References: <1411726731-15304-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chun-Hao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1411726731-15304-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chun-Hao Lin <hau@realtek.com> :
> RTL8168EP is Realtek PCIe Gigabit Ethernet controller.
> It is a successor chip of RTL8168DP.
> 
> This patch add support for this chip.

It does more than that.

Did Hayes review it ?

> Signed-off-by: Chun-Hao Lin <hau@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 611 +++++++++++++++++++++++++++++------
>  1 file changed, 514 insertions(+), 97 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 1d81238..0ead9a7 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -155,6 +155,9 @@ enum mac_version {
>  	RTL_GIGA_MAC_VER_46,
>  	RTL_GIGA_MAC_VER_47,
>  	RTL_GIGA_MAC_VER_48,
> +	RTL_GIGA_MAC_VER_49,
> +	RTL_GIGA_MAC_VER_50,
> +	RTL_GIGA_MAC_VER_51,
>  	RTL_GIGA_MAC_NONE   = 0xff,
>  };
>  
> @@ -302,6 +305,15 @@ static const struct {
>  	[RTL_GIGA_MAC_VER_48] =
>  		_R("RTL8107e",		RTL_TD_1, FIRMWARE_8107E_2,
>  							JUMBO_1K, false),
> +	[RTL_GIGA_MAC_VER_49] =
> +		_R("RTL8168ep/8111ep",	RTL_TD_1, NULL,
> +							JUMBO_9K, false),
> +	[RTL_GIGA_MAC_VER_50] =
> +		_R("RTL8168ep/8111ep",	RTL_TD_1, NULL,
> +							JUMBO_9K, false),
> +	[RTL_GIGA_MAC_VER_51] =
> +		_R("RTL8168ep/8111ep",	RTL_TD_1, NULL,
> +							JUMBO_9K, false),
>  };
>  #undef _R
>  
> @@ -400,6 +412,10 @@ enum rtl_registers {
>  	FuncEvent	= 0xf0,
>  	FuncEventMask	= 0xf4,
>  	FuncPresetState	= 0xf8,
> +	IBCR0           = 0xf8,
> +	IBCR2           = 0xf9,
> +	IBIMR0          = 0xfa,
> +	IBISR0          = 0xfb,
>  	FuncForceEvent	= 0xfc,
>  };
>  
> @@ -467,6 +483,7 @@ enum rtl8168_registers {
>  #define ERIAR_EXGMAC			(0x00 << ERIAR_TYPE_SHIFT)
>  #define ERIAR_MSIX			(0x01 << ERIAR_TYPE_SHIFT)
>  #define ERIAR_ASF			(0x02 << ERIAR_TYPE_SHIFT)
> +#define ERIAR_OOB			(0x02 << ERIAR_TYPE_SHIFT)
>  #define ERIAR_MASK_SHIFT		12
>  #define ERIAR_MASK_0001			(0x1 << ERIAR_MASK_SHIFT)
>  #define ERIAR_MASK_0011			(0x3 << ERIAR_MASK_SHIFT)
> @@ -935,93 +952,10 @@ static const struct rtl_cond name = {			\
>  							\
>  static bool name ## _check(struct rtl8169_private *tp)
>  
> -DECLARE_RTL_COND(rtl_ocpar_cond)
> -{
> -	void __iomem *ioaddr = tp->mmio_addr;
> -
> -	return RTL_R32(OCPAR) & OCPAR_FLAG;
> -}

Feel free to move this function around but please do it in a separate
patch. You are adding extra noise and thus making this stuff harder
to review than it should be.

> -
> -static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
> -{
> -	void __iomem *ioaddr = tp->mmio_addr;
> -
> -	RTL_W32(OCPAR, ((u32)mask & 0x0f) << 12 | (reg & 0x0fff));
> -
> -	return rtl_udelay_loop_wait_high(tp, &rtl_ocpar_cond, 100, 20) ?
> -		RTL_R32(OCPDR) : ~0;
> -}

(this one is modified)

> -
> -static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
> -{
> -	void __iomem *ioaddr = tp->mmio_addr;
> -
> -	RTL_W32(OCPDR, data);
> -	RTL_W32(OCPAR, OCPAR_FLAG | ((u32)mask & 0x0f) << 12 | (reg & 0x0fff));
> -
> -	rtl_udelay_loop_wait_low(tp, &rtl_ocpar_cond, 100, 20);
> -}

(this one is modified)

> -
> -DECLARE_RTL_COND(rtl_eriar_cond)
> -{
> -	void __iomem *ioaddr = tp->mmio_addr;
> -
> -	return RTL_R32(ERIAR) & ERIAR_FLAG;
> -}

Feel free to move this function around but please do it in a separate
patch.

> -
> -static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
> -{
> -	void __iomem *ioaddr = tp->mmio_addr;
> -
> -	RTL_W8(ERIDR, cmd);
> -	RTL_W32(ERIAR, 0x800010e8);
> -	msleep(2);
> -
> -	if (!rtl_udelay_loop_wait_low(tp, &rtl_eriar_cond, 100, 5))
> -		return;
> -
> -	ocp_write(tp, 0x1, 0x30, 0x00000001);
> -}

This one is modified but it is also modified for the existing 8168DP.

Mantra: please do it in a separate patch.

> -
>  #define OOB_CMD_RESET		0x00
>  #define OOB_CMD_DRIVER_START	0x05
>  #define OOB_CMD_DRIVER_STOP	0x06
>  
> -static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
> -{
> -	return (tp->mac_version == RTL_GIGA_MAC_VER_31) ? 0xb8 : 0x10;
> -}
> -
> -DECLARE_RTL_COND(rtl_ocp_read_cond)
> -{
> -	u16 reg;
> -
> -	reg = rtl8168_get_ocp_reg(tp);
> -
> -	return ocp_read(tp, 0x0f, reg) & 0x00000800;
> -}

(this one is simply moved around)

> -
> -static void rtl8168_driver_start(struct rtl8169_private *tp)
> -{
> -	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
> -
> -	rtl_msleep_loop_wait_high(tp, &rtl_ocp_read_cond, 10, 10);
> -}

(this one is modified)

> -
> -static void rtl8168_driver_stop(struct rtl8169_private *tp)
> -{
> -	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_STOP);
> -
> -	rtl_msleep_loop_wait_low(tp, &rtl_ocp_read_cond, 10, 10);
> -}

(this one is modified)

> -
> -static int r8168dp_check_dash(struct rtl8169_private *tp)
> -{
> -	u16 reg = rtl8168_get_ocp_reg(tp);
> -
> -	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
> -}

(this one is modified)

[...]
> @@ -1329,6 +1277,45 @@ static void rtl_w1w0_eri(struct rtl8169_private *tp, int addr, u32 mask, u32 p,
>  	rtl_eri_write(tp, addr, mask, (val & ~m) | p, type);
>  }
>  
> +static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_49 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_50 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_51) {
> +		return rtl_eri_read(tp, reg, ERIAR_OOB);
> +	} else if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> +		   tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> +		   tp->mac_version == RTL_GIGA_MAC_VER_31) {
> +		RTL_W32(OCPAR, ((u32)mask & 0x0f) << 12 | (reg & 0x0fff));
> +		return rtl_udelay_loop_wait_high(tp, &rtl_ocpar_cond, 100, 20)
> +		? RTL_R32(OCPDR) : ~0;

Please:
- use a local "bool rc" variable for rtl_udelay_loop_wait_high status
  so that you can line things correctly.
- use a switch case
- croak in the default case

> +	}
> +
> +	return ~0;
> +}
> +
> +static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_49 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_50 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_51) {
> +		rtl_eri_write(tp, reg, ((u32)mask & 0x0f) << ERIAR_MASK_SHIFT,
> +		data, ERIAR_OOB);

It should line up after the opening parenthesis in "rtl_eri_write("

> +	} else if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> +		   tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> +		   tp->mac_version == RTL_GIGA_MAC_VER_31) {
> +		RTL_W32(OCPDR, data);
> +		RTL_W32(OCPAR, OCPAR_FLAG | ((u32)mask & 0x0f) << 12 |
> +		(reg & 0x0fff));

It should line up after the opening parenthesis in "RTL_W32("

Please:
- use a switch case
- croak in the default case

You may state in a comment that this function is only designed for 8168DP
and derivatives (whence the reduced switch case). 

[...]
> @@ -1361,6 +1348,103 @@ static u8 rtl8168d_efuse_read(struct rtl8169_private *tp, int reg_addr)
[...]
> +static void rtl8168_driver_start(struct rtl8169_private *tp)
> +{
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_49 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_50 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_51) {
> +		u32 tmp;
> +
> +		ocp_write(tp, 0x01, 0x180, OOB_CMD_DRIVER_START);
> +		tmp = ocp_read(tp, 0x01, 0x30);
> +		tmp |= 0x01;
> +		ocp_write(tp, 0x01, 0x30, tmp);
> +		rtl_msleep_loop_wait_high(tp, &rtl_ep_ocp_read_cond, 10, 10);
> +	} else if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> +		   tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> +		   tp->mac_version == RTL_GIGA_MAC_VER_31) {
> +		rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
> +		rtl_msleep_loop_wait_high(tp, &rtl_ocp_read_cond, 10, 10);

switch case + croak on default please.

[snip]
> @@ -3724,6 +3819,143 @@ static void rtl8168h_2_hw_phy_config(struct rtl8169_private *tp)
>  	rtl_writephy(tp, 0x1f, 0x0000);
>  }
>  
> +static void rtl8168ep_1_hw_phy_config(struct rtl8169_private *tp)
> +{
> +	rtl_apply_firmware(tp);

?

You did not specify any firmware information in rtl_chip_infos.

It some firmware is supposed to help, please be sure to add the relevant
#define FIRMWARE_8xyz as well.

[...]
> +static void rtl8168ep_2_hw_phy_config(struct rtl8169_private *tp)
> +{
> +	rtl_apply_firmware(tp);

See above.

[...]
> @@ -4265,7 +4511,7 @@ static void r810x_pll_power_up(struct rtl8169_private *tp)
>  		break;
>  	case RTL_GIGA_MAC_VER_47:
>  	case RTL_GIGA_MAC_VER_48:
> -		RTL_W8(PMCH, RTL_R8(PMCH) | 0xC0);
> +		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);
>  		break;

It's welcome but it should be done in a different patch.

[...]
> @@ -4339,8 +4585,11 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
>  
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
>  	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> -	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
> -	    r8168dp_check_dash(tp)) {
> +	     tp->mac_version == RTL_GIGA_MAC_VER_31 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_49 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_50 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_51) &&
> +	     r8168_check_dash(tp)) {
>  		return;

Unrelated behavior change for RTL_GIGA_MAC_VER_2[78]. Different patch.

>  	}
>  
> @@ -4369,12 +4618,16 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
>  	case RTL_GIGA_MAC_VER_33:
>  	case RTL_GIGA_MAC_VER_45:
>  	case RTL_GIGA_MAC_VER_46:
> +	case RTL_GIGA_MAC_VER_50:
> +	case RTL_GIGA_MAC_VER_51:
>  		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
>  		break;
>  	case RTL_GIGA_MAC_VER_40:
>  	case RTL_GIGA_MAC_VER_41:
> +	case RTL_GIGA_MAC_VER_49:
>  		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0x00000000,
>  			     0xfc000000, ERIAR_EXGMAC);
> +		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);

Unrelated behavior change for RTL_GIGA_MAC_VER_4[01] (8168g, huh ?).
-> Different patch.

[...]
> @@ -4395,10 +4648,14 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
>  		break;
>  	case RTL_GIGA_MAC_VER_45:
>  	case RTL_GIGA_MAC_VER_46:
> -		RTL_W8(PMCH, RTL_R8(PMCH) | 0xC0);
> +	case RTL_GIGA_MAC_VER_50:
> +	case RTL_GIGA_MAC_VER_51:
> +		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);

See above.

>  		break;
>  	case RTL_GIGA_MAC_VER_40:
>  	case RTL_GIGA_MAC_VER_41:
> +	case RTL_GIGA_MAC_VER_49:
> +		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);
>  		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0xfc000000,
>  			     0x00000000, ERIAR_EXGMAC);

See above.

[...]
> @@ -7366,9 +7766,13 @@ static void rtl_remove_one(struct pci_dev *pdev)
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_31 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_49 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_50 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_51) &&
> +	     r8168_check_dash(tp)) {

It does not line up correctly (one space excess).

Unrelated behavior change for RTL_GIGA_MAC_VER_{27, 28, 31}. Different patch.

>  		rtl8168_driver_stop(tp);
>  	}
>  
[...]
> @@ -7703,11 +8113,14 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	if (tp->mac_version == RTL_GIGA_MAC_VER_45 ||
>  	    tp->mac_version == RTL_GIGA_MAC_VER_46 ||
>  	    tp->mac_version == RTL_GIGA_MAC_VER_47 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_48) {
> +	    tp->mac_version == RTL_GIGA_MAC_VER_48 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_49 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_50 ||
> +	    tp->mac_version == RTL_GIGA_MAC_VER_51) {
>  		u16 mac_addr[3];
>  
> -		*(u32 *)&mac_addr[0] = rtl_eri_read(tp, 0xE0, ERIAR_EXGMAC);
> -		*(u16 *)&mac_addr[2] = rtl_eri_read(tp, 0xE4, ERIAR_EXGMAC);
> +		*(u32 *)&mac_addr[0] = rtl_eri_read(tp, 0xe0, ERIAR_EXGMAC);
> +		*(u16 *)&mac_addr[2] = rtl_eri_read(tp, 0xe4, ERIAR_EXGMAC);

It's welcome but it brings noise in the current patch. Different patch.

>  
>  		if (is_valid_ether_addr((u8 *)mac_addr))
>  			rtl_rar_set(tp, (u8 *)mac_addr);
> @@ -7780,9 +8193,13 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  			   rtl_chip_infos[chipset].jumbo_tx_csum ? "ok" : "ko");
>  	}
>  
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_31 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_49 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_50 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_51) &&
> +	     r8168_check_dash(tp)) {

See above. Unrelated change, etc.

>  		rtl8168_driver_start(tp);
>  	}

-- 
Ueimor
