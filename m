From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/2] r8169: support RTL8168G
Date: Fri, 29 Jun 2012 15:51:11 +0200
Message-ID: <20120629135111.GB8560@electric-eye.fr.zoreil.com>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com> <1340966060-2749-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340966060-2749-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> @@ -264,6 +267,11 @@ static const struct {
>  	[RTL_GIGA_MAC_VER_39] =
>  		_R("RTL8106e",		RTL_TD_1, FIRMWARE_8106E_1,
>  							JUMBO_1K, true),
> +	[RTL_GIGA_MAC_VER_40] =
> +		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_1,
> +							JUMBO_9K, false),
> +	[RTL_GIGA_MAC_VER_41] =
> +		_R("RTL8168g/8111g",	RTL_TD_1, NULL, JUMBO_9K, false),

You may explicitely state that jumbo operation requires no special action
by completing rtl_init_jumbo_ops.

(no checksuming with jumbo, sigh)

[...]
>  static void rtl_lock_work(struct rtl8169_private *tp)
>  {
> @@ -919,6 +936,99 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
>  	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
>  }
>  
> +static void r8168_phy_ocp_write(void __iomem *ioaddr, u32 reg, u32 data)
> +{
> +	int i;
> +
> +	if (reg & 0xffff0001)
> +		BUG();

The patch adds a lot of BUG(). BUG is terrible from a system or end user
viewpoint.

Were they only a devel helper or are they still supposed to be of use
in the future ? If the latter applies, why ?

[...]
> +static u16 r8168_phy_ocp_read(void __iomem *ioaddr, u32 reg)
> +{
> +	int i;
> +	u32 data;
> +
> +	if (reg & 0xffff0001)
> +		BUG();
> +
> +	RTL_W32(GPHY_OCP, (reg << 15));

You can save on parenthesis here.

[...]
> +static void r8168g_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
> +{
> +	if (reg_addr == 0x1f)
> +		return;
> +
> +	r8168_phy_ocp_write(ioaddr, 0xa400 + reg_addr * 2, value);
> +}
> +
> +static int r8168g_mdio_read(void __iomem *ioaddr, int reg_addr)
> +{
> +	return r8168_phy_ocp_read(ioaddr, 0xa400 + reg_addr * 2);
> +}

#define XYZ_{BASE/OFFSET}	0xa400 ?

[...]
> @@ -2241,6 +2355,92 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
>  	}
>  }
>  
> +static void rtl_ocp_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
> +{
> +	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	u32 predata, count;
> +	u32 base_addr;
> +	size_t index;
> +
> +	predata = count = 0;
> +	base_addr = 0xa400;
> +
> +	for (index = 0; index < pa->size; ) {
> +		u32 action = le32_to_cpu(pa->code[index]);
> +		u32 data = action & 0x0000ffff;
> +		u32 regno = (action & 0x0fff0000) >> 16;
> +
> +		if (!action)
> +			break;
> +
> +		switch(action & 0xf0000000) {
> +		case PHY_READ:
> +			predata = r8168_phy_ocp_read(ioaddr,
> +					base_addr + (regno -16) * 2);
> +			count++;
> +			index++;
> +			break;
[duplicated code removed]
> +		case PHY_WRITE:
> +			if (regno == 0x1f)
> +				base_addr = data << 4;
> +			else
> +				r8168_phy_ocp_write(ioaddr,
> +						base_addr + (regno - 0x10) * 2,
> +						data);
> +			index++;
> +			break;
[duplicated code removed]
> +		case PHY_WRITE_PREVIOUS:
> +			r8168_phy_ocp_write(ioaddr, base_addr + (regno -16) * 2,
> +					    predata);
> +			index++;
> +			break;

I can't believe that the hardware people have designed something which
needs a different firmware write method, especially as it copies at lot
of code.

How did you come to the conclusion that it was not possible to hide this
stuff behind r8168g_mdio_{read / write} ?

I would not mind replacing the PHY_{READ/WRITE/WRITE_PREVIOUS} case with
chipset specific {READ/WRITE/WRITE_PREVIOUS} methods as long as the
semantic looks the same but going through a different (*write_fw) does not
trivially seem to be the best abstraction.

[...]
> @@ -3221,6 +3421,56 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
>  	rtl_writephy(tp, 0x1f, 0x0000);
>  }
>  
> +static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	u32 mac_ocp_addr, i;
> +	static const u16 mac_ocp_patch[] = {
> +		0xE008, 0xE01B, 0xE01D, 0xE01F,
> +		0xE021, 0xE023, 0xE025, 0xE027,
> +		0x49D2 ,0xF10D, 0x766C, 0x49E2,
> +		0xF00A, 0x1EC0, 0x8EE1, 0xC60A,
> +		0x77C0, 0x4870, 0x9FC0, 0x1EA0,
> +		0xC707, 0x8EE1, 0x9D6C, 0xC603,
> +		0xBE00, 0xB416, 0x0076, 0xE86C,
> +		0xC602, 0xBE00, 0x0000, 0xC602,
> +		0xBE00, 0x0000, 0xC602, 0xBE00,
> +		0x0000, 0xC602, 0xBE00, 0x0000,
> +		0xC602, 0xBE00, 0x0000, 0xC602,
> +		0xBE00, 0x0000, 0xC602, 0xBE00,
> +		0x0000, 0x0000, 0x0000, 0x0000

Please s/\(.*\)/\L\1/

> +	};
> +
> +	/* patch code for GPHY reset */
> +	mac_ocp_addr = 0xf800;
> +	for (i = 0; mac_ocp_addr < 0xf868; i++) {
> +		r8168_mac_ocp_write(ioaddr, mac_ocp_addr, mac_ocp_patch[i]);
> +		mac_ocp_addr += 2;
> +	}

	for (i = 0; i < ARRAY_SIZE(mac_ocp_patch); i++)
		r8168_mac_ocp_write(ioaddr, 0xf800 + 2*i, mac_ocp_patch[i]);

The array must be correctly sized anyway. :o)

You may save a bit on the 'mac_ocp_patch' identifier and replace 0xf800 with
a #define.

> +	r8168_mac_ocp_write(ioaddr, 0xfc26, 0x8000);
> +	r8168_mac_ocp_write(ioaddr, 0xfc28, 0x0075);
> +
> +	rtl_apply_firmware(tp);
> +
> +	if (r8168_phy_ocp_read(ioaddr, 0xa460) & 0x0100)
> +		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x0000, 0x8000);
> +	else
> +		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x8000, 0x0000);
> +
> +	if (r8168_phy_ocp_read(ioaddr, 0xa466) & 0x0100)
> +		rtl_w1w0_phy_ocp(ioaddr, 0xc41a, 0x0002, 0x0000);
> +	else
> +		rtl_w1w0_phy_ocp(ioaddr, 0xbcc4, 0x0000, 0x0002);
> +
> +	rtl_w1w0_phy_ocp(ioaddr, 0xa442, 0x000c, 0x0000);
> +	rtl_w1w0_phy_ocp(ioaddr, 0xa4b2, 0x0004, 0x0000);
> +
> +	r8168_phy_ocp_write(ioaddr, 0xa436, 0x8012);
> +	rtl_w1w0_phy_ocp(ioaddr, 0xa438, 0x8000, 0x0000);
> +
> +	rtl_w1w0_phy_ocp(ioaddr, 0xc422, 0x4000, 0x2000);
> +}

Is there any chance for this part to be a bit more literate ?

[...]
> @@ -4921,6 +5193,28 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
>  		     ERIAR_EXGMAC);
>  }
>  
> +static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	struct pci_dev *pdev = tp->pci_dev;
> +
> +	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_0101, 0x080002, ERIAR_EXGMAC);
> +	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_0001, 0x38, ERIAR_EXGMAC);
> +	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_0001, 0x48, ERIAR_EXGMAC);
> +	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);

> +	rtl_csi_access_enable_1(tp);

> +	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);

> +	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
> +	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);

> +	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
> +	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
> +	RTL_W8(MaxTxPacketSize, EarlySize);

> +	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
> +	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);

> +	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);

> +	rtl_w1w0_eri(ioaddr, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
> +}

(ok, now it can be compared with similar functions)

[...]
> @@ -6491,6 +6790,47 @@ static unsigned rtl_try_msi(struct rtl8169_private *tp,
>  	return msi;
>  }
>  
> +static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	u32 tmp_data;
> +
> +	RTL_W32(MISC, RTL_R32(MISC) | RXDV_GATED_EN);
> +	while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
> +		udelay(100);
> +
> +	while ((RTL_R8(MCU) & (TX_EMPTY | RX_EMPTY)) != (TX_EMPTY | RX_EMPTY))
> +		udelay(100);

#define RXTX_EMPTY	(TX_EMPTY | RX_EMPTY) ?

> +
> +	RTL_W8(ChipCmd, RTL_R8(ChipCmd) & ~(CmdTxEnb | CmdRxEnb));
> +	msleep(1);
> +	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
> +
> +	tmp_data = r8168_mac_ocp_read(ioaddr, 0xe8de);
> +	tmp_data &= ~(1 << 14);
> +	r8168_mac_ocp_write(ioaddr, 0xe8de, tmp_data);
> +	while (!(RTL_R8(MCU) & LINK_LIST_RDY))
> +		udelay(100);
> +
> +	tmp_data = r8168_mac_ocp_read(ioaddr, 0xe8de);

Same 0xe8de offset used twice. #define ?

> +	tmp_data |= (1 << 15);
> +	r8168_mac_ocp_write(ioaddr, 0xe8de, tmp_data);
> +	while (!(RTL_R8(MCU) & LINK_LIST_RDY))
> +		udelay(100);
> +}
> +
> +static void __devinit rtl_hw_initialize(struct rtl8169_private *tp)
> +{
> +	switch (tp->mac_version) {
> +	case RTL_GIGA_MAC_VER_40:
> +	case RTL_GIGA_MAC_VER_41:
> +		rtl_hw_init_8168g(tp);
> +		break;
> +	default:
> +		break;
> +	}
> +}

Why doesn't it belong to hw_start ?

Is it completely unneeded if the device requires a rtl8169_hw_reset,
resumes or such ?

Thanks.

-- 
Ueimor
