From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
Date: Mon, 22 Oct 2012 21:27:48 +0200
Message-ID: <20121022192748.GA16370@electric-eye.fr.zoreil.com>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jean@google.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1350893153-18320-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Enable ALDPS function to save power when link down. Note that the
> feature should be set after the other PHY settings. And the firmware
> is necessary. Don't enable it without loading the firmware.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 46 +++++++++++++++++++++++++++++++++++-
>  1 file changed, 45 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index e7ff886..ba29e4d 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -687,6 +687,7 @@ enum features {
>  	RTL_FEATURE_WOL		= (1 << 0),
>  	RTL_FEATURE_MSI		= (1 << 1),
>  	RTL_FEATURE_GMII	= (1 << 2),
> +	RTL_FEATURE_EXTENDED	= (1 << 3),

Is there a specific reason why it is not named RTL_FEATURE_ALDPS ?

RTL_FEATURE_EXTENDED is anything but enlightning.

>  };
>  
>  struct rtl8169_counters {
> @@ -2394,8 +2395,10 @@ static void rtl_apply_firmware(struct rtl8169_private *tp)
>  	struct rtl_fw *rtl_fw = tp->rtl_fw;
>  
>  	/* TODO: release firmware once rtl_phy_write_fw signals failures. */
> -	if (!IS_ERR_OR_NULL(rtl_fw))
> +	if (!IS_ERR_OR_NULL(rtl_fw)) {
>  		rtl_phy_write_fw(tp, rtl_fw);
> +		tp->features |= RTL_FEATURE_EXTENDED;
> +	}


>  }
>  
>  static void rtl_apply_firmware_cond(struct rtl8169_private *tp, u8 reg, u16 val)
> @@ -3178,6 +3181,12 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
>  	rtl_w1w0_phy(tp, 0x19, 0x0000, 0x0001);
>  	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
>  	rtl_writephy(tp, 0x1f, 0x0000);
> +
> +	/* ALDPS enable */
> +	if (tp->features & RTL_FEATURE_EXTENDED) {
> +		rtl_writephy(tp, 0x1f, 0x0000);
> +		rtl_w1w0_phy(tp, 0x15, 0x1000, 0x0000);
> +	}


This same code fragment will be repeated 3 extra times. The patch duplicates
a different fragment 3 times and the driver already repeats the disable
ALDPS sequence 3 times.

What about some factoring out frenzy ? :o)

[...]
> @@ -6391,6 +6433,8 @@ static void rtl8169_net_suspend(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  
> +	tp->features &= ~RTL_FEATURE_EXTENDED;
> +

The commit message does not explain this part.

What are you trying to achieve ?


After this patch the driver would look like:
1. disable ALDPS before setting firmware (unmodified by patch)
   RTL_GIGA_MAC_VER_29 "RTL8105e"
   RTL_GIGA_MAC_VER_30 "RTL8105e"
   RTL_GIGA_MAC_VER_37 "RTL8402"
   RTL_GIGA_MAC_VER_39 "RTL8106e"

2. apply_firmware (unmodified by patch)
   RTL_GIGA_MAC_VER_25 "RTL8168d/8111d"
   RTL_GIGA_MAC_VER_26 "RTL8168d/8111d"
   RTL_GIGA_MAC_VER_29 "RTL8105e"
   RTL_GIGA_MAC_VER_30 "RTL8105e"
   RTL_GIGA_MAC_VER_32 "RTL8168e/8111e"
   RTL_GIGA_MAC_VER_33 "RTL8168e/8111e"
   RTL_GIGA_MAC_VER_34 "RTL8168evl/8111evl"
   RTL_GIGA_MAC_VER_35 "RTL8168f/8111f"
   RTL_GIGA_MAC_VER_36 "RTL8168f/8111f"
   RTL_GIGA_MAC_VER_37 "RTL8402"
   RTL_GIGA_MAC_VER_38 "RTL8411"
   RTL_GIGA_MAC_VER_39 "RTL8106e"
   RTL_GIGA_MAC_VER_40 "RTL8168g/8111g"

3. enable ALDPS after firmware
   RTL_GIGA_MAC_VER_34 "RTL8168evl/8111evl"
   RTL_GIGA_MAC_VER_35 "RTL8168f/8111f"
   RTL_GIGA_MAC_VER_36 "RTL8168f/8111f"
   RTL_GIGA_MAC_VER_37 "RTL8402"
   RTL_GIGA_MAC_VER_38 "RTL8411"
   RTL_GIGA_MAC_VER_39 "RTL8106e"
   RTL_GIGA_MAC_VER_40 "RTL8168g/8111g"

The disable/enable ALDPS code is not trivially balanced.

Do we exactly perform the required ALDPS operations ? Nothing more,
nothing less ?

-- 
Ueimor
