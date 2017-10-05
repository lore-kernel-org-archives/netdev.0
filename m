From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: ethernet: stmmac: Convert timers to use
Date: Thu, 5 Oct 2017 07:21:25 +0200
Message-ID: <436427d6-242f-073f-ddc6-a9c07c95414c@st.com>
References: <20171005005057.GA23332@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005005057.GA23332@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/5/2017 2:50 AM, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre Torgue <alexandre.torgue@st.com>
> Cc: netdev@vger.kernel.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by:  Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
> This requires commit 686fef928bba ("timer: Prepare to change timer
> callback argument type") in v4.14-rc3, but should be otherwise
> stand-alone.
> ---
>   drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c | 22 ++++++++++------------
>   1 file changed, 10 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
> index 6a9c954492f2..8b50afcdb52d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
> @@ -118,10 +118,9 @@ int tse_pcs_init(void __iomem *base, struct tse_pcs *pcs)
>   	return ret;
>   }
>   
> -static void pcs_link_timer_callback(unsigned long data)
> +static void pcs_link_timer_callback(struct tse_pcs *pcs)
>   {
>   	u16 val = 0;
> -	struct tse_pcs *pcs = (struct tse_pcs *)data;
>   	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
>   	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
>   
> @@ -138,12 +137,11 @@ static void pcs_link_timer_callback(unsigned long data)
>   	}
>   }
>   
> -static void auto_nego_timer_callback(unsigned long data)
> +static void auto_nego_timer_callback(struct tse_pcs *pcs)
>   {
>   	u16 val = 0;
>   	u16 speed = 0;
>   	u16 duplex = 0;
> -	struct tse_pcs *pcs = (struct tse_pcs *)data;
>   	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
>   	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
>   
> @@ -201,14 +199,14 @@ static void auto_nego_timer_callback(unsigned long data)
>   	}
>   }
>   
> -static void aneg_link_timer_callback(unsigned long data)
> +static void aneg_link_timer_callback(struct timer_list *t)
>   {
> -	struct tse_pcs *pcs = (struct tse_pcs *)data;
> +	struct tse_pcs *pcs = from_timer(pcs, t, aneg_link_timer);
>   
>   	if (pcs->autoneg == AUTONEG_ENABLE)
> -		auto_nego_timer_callback(data);
> +		auto_nego_timer_callback(pcs);
>   	else if (pcs->autoneg == AUTONEG_DISABLE)
> -		pcs_link_timer_callback(data);
> +		pcs_link_timer_callback(pcs);
>   }
>   
>   void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
> @@ -237,8 +235,8 @@ void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
>   
>   		tse_pcs_reset(tse_pcs_base, pcs);
>   
> -		setup_timer(&pcs->aneg_link_timer,
> -			    aneg_link_timer_callback, (unsigned long)pcs);
> +		timer_setup(&pcs->aneg_link_timer, aneg_link_timer_callback,
> +			    0);
>   		mod_timer(&pcs->aneg_link_timer, jiffies +
>   			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
>   	} else if (phy_dev->autoneg == AUTONEG_DISABLE) {
> @@ -270,8 +268,8 @@ void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
>   
>   		tse_pcs_reset(tse_pcs_base, pcs);
>   
> -		setup_timer(&pcs->aneg_link_timer,
> -			    aneg_link_timer_callback, (unsigned long)pcs);
> +		timer_setup(&pcs->aneg_link_timer, aneg_link_timer_callback,
> +			    0);
>   		mod_timer(&pcs->aneg_link_timer, jiffies +
>   			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
>   	}
