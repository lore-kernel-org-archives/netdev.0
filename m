From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: net: stmmac: dwmac-rk: fixes for Wake-on-Lan on RK3288
Date: Fri, 17 Jun 2016 07:38:12 +0200
Message-ID: <cff4a16e-9af2-3855-27a5-8f5fba5a8cb0@st.com>
References: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com>
 <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
 <3d278dd6-0b61-f618-b723-52f9c302c999@st.com>
 <CAP_ceTwbrx0vO8ufMO_SiwXFAxv5OUuQaYYS27gNqPTR6kRXyQ@mail.gmail.com>
 <1a9e4f56-37b0-892f-97b5-b61106e6d40b@st.com>
 <CAP_ceTweCVNsLONayu6woxyK7p1975w-t0LU4VUjwkqp+1G13A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	=?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>,
	David Miller <davem@davemloft.net>
To: Vincent Palatin <vpalatin@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP_ceTweCVNsLONayu6woxyK7p1975w-t0LU4VUjwkqp+1G13A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/16/2016 4:51 PM, Vincent Palatin wrote:
> Hi Giuseppe,
>
> On Thu, Jun 16, 2016 at 6:37 AM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>>
>> Hi Vincent
>>
>>
>> On 6/15/2016 7:04 PM, Vincent Palatin wrote:
>>>
>>> On Sun, Jun 12, 2016 at 11:46 PM, Giuseppe CAVALLARO
>>> <peppe.cavallaro@st.com> wrote:
>>>>
>>>> On 6/11/2016 3:00 AM, Vincent Palatin wrote:
>>>>>
>>>>>
>>>>> In order to support Wake-On-Lan when using the RK3288 integrated MAC
>>>>> (with an external RGMII PHY), we need to avoid shutting down the regulator
>>>>> of the external PHY when the MAC is suspended as it's currently done in
>>>>> the MAC
>>>>> platform code.
>>>>> As a first step, create independant callbacks for suspend/resume rather
>>>>> than
>>>>> re-using exit/init callbacks. So the dwmac platform driver can behave
>>>>> differently
>>>>> on suspend where it might skip shutting the PHY and at module unloading.
>>>>> Then update the dwmac-rk driver to switch off the PHY regulator only if we
>>>>> are
>>>>> not planning to wake up from the LAN.
>>>>> Finally add the PMT interrupt to the MAC device tree configuration, so we
>>>>> can
>>>>> wake up the core from it when the PHY has received the magic packet.
>>>>
>>>>
>>>>
>>>> IMO these could be sent for net-next and also other glue logic
>>>> files should be reworked in order to use the new API for coherence.
>>>
>>>
>>> Given they will have the same set of functions for exit/init and
>>> suspend/resume, you mean duplicating the callbacks like this :
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
>>> @@ -359,6 +359,8 @@ static int sti_dwmac_probe(struct platform_device *pdev)
>>>         plat_dat->bsp_priv = dwmac;
>>>         plat_dat->init = sti_dwmac_init;
>>>         plat_dat->exit = sti_dwmac_exit;
>>> +       plat_dat->suspend = sti_dwmac_exit;
>>> +       plat_dat->resume = sti_dwmac_init;
>>>         plat_dat->fix_mac_speed = data->fix_retime_src;
>>>
>>>         ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
>>>
>>> Is this anyhow useful ?
>>
>>
>> I think this is mandatory otherwise you are not guaranteeing the PM
>> stuff working on the rest of the glue-logics (not only sti); because
>> init/exit calls won't be called anymore.
>
>
> As mentioned in the PATCH 1/3 description: "If the driver does not
> provide the suspend or resume callback, we fall
> back to the old behavior trying to use exit or init. [...]"
> ie.
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -411,7 +411,9 @@ static int stmmac_pltfr_suspend(struct device *dev)
>         struct platform_device *pdev = to_platform_device(dev);
>
>         ret = stmmac_suspend(dev);
> -       if (priv->plat->exit)
> +       if (priv->plat->suspend)
> +               priv->plat->suspend(pdev, priv->plat->bsp_priv);
> +       else if (priv->plat->exit)
>                 priv->plat->exit(pdev, priv->plat->bsp_priv);
>
>         return ret;
> @@ -430,7 +432,9 @@ static int stmmac_pltfr_resume(struct device *dev)
>         struct stmmac_priv *priv = netdev_priv(ndev);
>         struct platform_device *pdev = to_platform_device(dev);
>
> -       if (priv->plat->init)
> +       if (priv->plat->resume)
> +               priv->plat->resume(pdev, priv->plat->bsp_priv);
> +       else if (priv->plat->init)
>                 priv->plat->init(pdev, priv->plat->bsp_priv);
>
>         return stmmac_resume(dev);
>
> So I was under the impression that everything should continue working
> as before for drivers only providing init/exit,
> by falling back on calling ->exit() if there is no suspend() callback
> initialized for the PM calls.
> You think that won't work ?

it's ok for me.

Peppe

>
>>
>> So I kindly ask you to
>> propagate the fix and send the V3.  The implementation above is ok for
>> me.
>>
>> peppe
>>
>
