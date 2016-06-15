From: Vincent Palatin <vpalatin@chromium.org>
Subject: Re: [PATCH 2/3] net: stmmac: dwmac-rk: keep the PHY up for WoL
Date: Wed, 15 Jun 2016 09:03:20 -0700
Message-ID: <CAP_ceTxFuCsqRQJ_9GMc5PSKqczA8Qwaa0jX22wQ2Dq=+GZUuQ@mail.gmail.com>
References: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com> <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
 <1465606839-7722-3-git-send-email-vpalatin@chromium.org> <2847430.O0lKQgdM0K@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Shunqian Zheng <zhengsq@rock-chips.com>
To: Heiko Stuebner <heiko@sntech.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2847430.O0lKQgdM0K@phil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 10, 2016 at 6:57 PM, Heiko Stuebner <heiko@sntech.de> wrote:
> Am Freitag, 10. Juni 2016, 18:00:38 schrieb Vincent Palatin:
>> When suspending the machine, do not shutdown the external PHY by cutting
>> its regulator in the mac platform driver suspend code if Wake-on-Lan is
>> enabled, else it cannot wake us up.
>> In order to do this, split the suspend/resume callbacks from the
>> init/exit callbacks, so we can condition the power-down on the lack of
>> need to wake-up from the LAN but do it unconditionally when unloading the
>> module.
>>
>> Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 49
>> +++++++++++++++++++++++--- 1 file changed, 44 insertions(+), 5
>> deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c index 0cd3ecf..fa05771
>> 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> @@ -46,6 +46,7 @@ struct rk_priv_data {
>>       struct platform_device *pdev;
>>       int phy_iface;
>>       struct regulator *regulator;
>> +     bool powered_down;
>>       const struct rk_gmac_ops *ops;
>>
>>       bool clk_enabled;
>> @@ -529,9 +530,8 @@ static struct rk_priv_data *rk_gmac_setup(struct
>> platform_device *pdev, return bsp_priv;
>>  }
>>
>> -static int rk_gmac_init(struct platform_device *pdev, void *priv)
>> +static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
>>  {
>> -     struct rk_priv_data *bsp_priv = priv;
>>       int ret;
>>
>>       ret = phy_power_on(bsp_priv, true);
>> @@ -542,15 +542,52 @@ static int rk_gmac_init(struct platform_device
>> *pdev, void *priv) if (ret)
>>               return ret;
>>
>> +     bsp_priv->powered_down = true;
>> +
>>       return 0;
>>  }
>>
>> -static void rk_gmac_exit(struct platform_device *pdev, void *priv)
>> +static void rk_gmac_powerdown(struct rk_priv_data *gmac)
>>  {
>> -     struct rk_priv_data *gmac = priv;
>> -
>>       phy_power_on(gmac, false);
>>       gmac_clk_enable(gmac, false);
>> +     gmac->powered_down = true;
>
> naming it gmac->suspended and doing all accesses in the suspend/resume
> callback might provide a nicer way? Now the check is in resume while the
> powerdown callback is setting it.
>
>> +}
>> +
>> +static int rk_gmac_init(struct platform_device *pdev, void *priv)
>> +{
>> +     struct rk_priv_data *bsp_priv = priv;
>> +
>> +     return rk_gmac_powerup(bsp_priv);
>> +}
>> +
>> +static void rk_gmac_exit(struct platform_device *pdev, void *priv)
>> +{
>> +     struct rk_priv_data *bsp_priv = priv;
>> +
>> +     rk_gmac_powerdown(bsp_priv);
>> +}
>> +
>> +static void rk_gmac_suspend(struct platform_device *pdev, void *priv)
>> +{
>> +     struct rk_priv_data *bsp_priv = priv;
>> +
>> +     /* Keep the PHY up if we use Wake-on-Lan. */
>> +     if (device_may_wakeup(&pdev->dev))
>> +             return;
>> +
>> +     rk_gmac_powerdown(bsp_priv);
>
> aka do
>         bsp_priv->suspended = true;
> here
>
>> +}
>> +
>> +static void rk_gmac_resume(struct platform_device *pdev, void *priv)
>> +{
>> +     struct rk_priv_data *bsp_priv = priv;
>> +
>> +     /* The PHY was up for Wake-on-Lan. */
>> +     if (!bsp_priv->powered_down)
>> +             return;
>> +
>> +     rk_gmac_powerup(bsp_priv);
>
> missing something like
>         bsp_priv->suspended = false;
>
> Right now it looks like your bsp_priv->powered_down will always be true
> after the first suspend with powerdown.

Yes I screw up badly, that's a good reason to use a more sensible name
for the variable.

>
>>  }
>>
>>  static void rk_fix_speed(void *priv, unsigned int speed)
>> @@ -591,6 +628,8 @@ static int rk_gmac_probe(struct platform_device *pdev)
>> plat_dat->init = rk_gmac_init;
>>       plat_dat->exit = rk_gmac_exit;
>>       plat_dat->fix_mac_speed = rk_fix_speed;
>> +     plat_dat->suspend = rk_gmac_suspend;
>> +     plat_dat->resume = rk_gmac_resume;
>>
>>       plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
>>       if (IS_ERR(plat_dat->bsp_priv))
>> --
>> 2.8.0.rc3.226.g39d4020
>
