From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] r8169: Support RTL8105E
Date: Thu, 17 Feb 2011 14:39:51 +0100
Message-ID: <20110217133951.GA11996@electric-eye.fr.zoreil.com>
References: <1297942668-23274-1-git-send-email-hayeswang@realtek.com> <1297942668-23274-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1297942668-23274-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> @@ -227,6 +232,10 @@ enum rtl_registers {
>  	MultiIntr	= 0x5c,
>  	PHYAR		= 0x60,
>  	PHYstatus	= 0x6c,
> +	DLLPR		= 0xd0,
> +	DbgReg		= 0xd1,
> +	TWSI		= 0xd2,
> +	MCU		= 0xd3,

You can probably fill some of those in 'enum rtl8168_8101_registers'
(DbgReg is already there).

>  	RxMaxSize	= 0xda,
>  	CPlusCmd	= 0xe0,
>  	IntrMitigate	= 0xe2,
> @@ -427,6 +436,13 @@ enum rtl_register_content {
>  
>  	/* DumpCounterCommand */
>  	CounterDump	= 0x8,
> +
> +	/* MCU */
> +	EnNDP		= (1 << 3),
> +	EnOOBReset		= (1 << 2),
                  ^^^^ -> extraneous tab
> +
> +	/* DLLPR */
> +	PmSwitch	= (1 << 6),

They are a bit old-fashioned.

See rtl8168_8101_registers / DBG_REG / FIX_NAK_{1, 2}.

[...]
> @@ -2435,6 +2457,57 @@ static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
>  	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
>  }
>  
> +static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
> +{
> +	void __iomem *ioaddr = tp->mmio_addr;
> +	static const struct phy_reg phy_reg_init[] = {
> +		{ 0x1f, 0x0001},
> +		{ 0x15, 0x7701},
> +		{ 0x1f, 0x0000}
> +	};
> +
> +	rtl_writephy(tp, 0x1f, 0x0000);
> +	rtl_writephy(tp, 0x18, 0x0310);
> +	msleep(100);
> +
> +	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
> +		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
> +
> +	if(RTL_R8(0xef) & 0x08) {
         ^^ -> missing space.

Add a symbol for the 0xef register ?

> +		static const struct phy_reg phy_reg_init1[] = {
> +			{ 0x1f, 0x0005},
> +			{ 0x1a, 0x0004},
> +			{ 0x1f, 0x0000}
> +		};
> +		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
> +	} else {
> +		static const struct phy_reg phy_reg_init1[] = {
> +			{ 0x1f, 0x0005},
> +			{ 0x1a, 0x0000},
> +			{ 0x1f, 0x0000}
> +		};
> +		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
> +	}
> +
> +	if(RTL_R8(0xef) & 0x010) {
         ^^ -> missing space.

> +		static const struct phy_reg phy_reg_init1[] = {
> +			{ 0x1f, 0x0004},
> +			{ 0x1c, 0x0000},
> +			{ 0x1f, 0x0000}
> +		};
> +		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
> +	} else {
> +		static const struct phy_reg phy_reg_init1[] = {
> +			{ 0x1f, 0x0004},
> +			{ 0x1c, 0x0200},
> +			{ 0x1f, 0x0000}
> +		};
> +		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
> +	}

Nit: I would rather use an array of array and remove some code duplication.

Otherwise ok.

-- 
Ueimor
