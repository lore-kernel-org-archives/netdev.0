From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 2/2] r8169: Support RTL8105E
Date: Mon, 21 Feb 2011 08:33:28 +0100
Message-ID: <20110221073328.GA12326@electric-eye.fr.zoreil.com>
References: <1298018085-1370-1-git-send-email-hayeswang@realtek.com> <1298018085-1370-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1298018085-1370-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Support the new chips for RTL8105E
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/r8169.c |   92 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 90 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 9eaf78f..ffe6b00 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
[...]
> @@ -267,6 +272,12 @@ enum rtl8168_8101_registers {
>  #define	EPHYAR_REG_MASK			0x1f
>  #define	EPHYAR_REG_SHIFT		16
>  #define	EPHYAR_DATA_MASK		0xffff
> +	DLLPR			= 0xd0,
> +#define	PM_SWITCH			(1 << 6)
> +	TWSI			= 0xd2,
> +	MCU			= 0xd3,
> +#define	EN_NDP				(1 << 3)
> +#define	EN_OOB_RESET			(1 << 2)
>  	DBG_REG			= 0xd1,
>  #define	FIX_NAK_1			(1 << 4)
>  #define	FIX_NAK_2			(1 << 3)

Please pack them in increasing order and it will be perfect
(i.e. 0xd0, 0xd1, 0xd2, 0xd3 instead of current 0xd0, 0xd2 (?), 0xd3, 0xd1).

[...]
> @@ -2435,6 +2452,33 @@ static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
>  	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
>  }
>  
> +static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
> +{
> +	static const struct phy_reg phy_reg_init[] = {
> +		{0x1f, 0x0005},
> +		{0x1a, 0x0000},
> +		{0x1f, 0x0000},
> +
> +		{0x1f, 0x0004},
> +		{0x1c, 0x0000},
> +		{0x1f, 0x0000},
> +
> +		{0x1f, 0x0001},
> +		{0x15, 0x7701},
> +		{0x1f, 0x0000}
                ^^          ^^
Minor nit: please insert spaces (as in similar declarations).

> +	};
> +
> +	/* Diable ALDPS before ram code */
            ^^ Missing "b".

> +	rtl_writephy(tp, 0x1f, 0x0000);
> +	rtl_writephy(tp, 0x18, 0x0310);
> +	msleep(100);
> +
> +	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
> +		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
> +
> +	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
> +}

The "if (RTL_R8(0xef) & 0x08)" and "if (RTL_R8(0xef) & 0x010)" conditionals
from the previous iteration have been removed. If it is done on purpose, a
short explanation or notification in the description of the patch is always
welcome.

-- 
Ueimor
