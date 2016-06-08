From: Vincent Palatin <vpalatin@chromium.org>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: keep PHY up for WoL
Date: Wed, 8 Jun 2016 15:25:38 -0700
Message-ID: <CAP_ceTwLg-e_gUaYLrUiBy8Fu31n=UemzbA_sDP2_-5wiY2p5A@mail.gmail.com>
References: <1464974960-26672-1-git-send-email-vpalatin@chromium.org> <f543c3e1-fa55-a6fd-c916-cf043e562ec2@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35303 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424140AbcFHWZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 18:25:58 -0400
Received: by mail-io0-f181.google.com with SMTP id o189so22481846ioe.2
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 15:25:58 -0700 (PDT)
In-Reply-To: <f543c3e1-fa55-a6fd-c916-cf043e562ec2@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 7, 2016 at 12:23 AM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> Hello
>
> On 6/3/2016 7:29 PM, Vincent Palatin wrote:
>>
>> Do not shutdown the PHY if Wake-on-Lan is enabled, else it cannot wake
>> us up.
>>
>
> I do not understand why you need that.
> This is done inside the PHY layer and it is tested on our platforms
> he idea is: If the parent wants to Wake the system then the PHY should
> not power-down.

I'm not sure I understand :
you mean that this path is not called if WoL is enabled ?
[ currently stmmac_pltfr_suspend() is calling priv->plat->exit() which
is the rk_gmac_exit() code I'm modifying ]
or the RK driver code should not power down the phy in its exit() callback ?


>> Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> index 0cd3ecf..2e45e75 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> @@ -534,6 +534,10 @@ static int rk_gmac_init(struct platform_device *pdev,
>> void *priv)
>>         struct rk_priv_data *bsp_priv = priv;
>>         int ret;
>>
>> +       /* Keep the PHY up if we use Wake-on-Lan. */
>> +       if (device_may_wakeup(&pdev->dev))
>> +               return 0;
>> +
>>         ret = phy_power_on(bsp_priv, true);
>>         if (ret)
>>                 return ret;
>> @@ -549,6 +553,10 @@ static void rk_gmac_exit(struct platform_device
>> *pdev, void *priv)
>>  {
>>         struct rk_priv_data *gmac = priv;
>>
>> +       /* The PHY was up for Wake-on-Lan. */
>> +       if (device_may_wakeup(&pdev->dev))
>> +               return;
>> +
>>         phy_power_on(gmac, false);
>>         gmac_clk_enable(gmac, false);
>>  }
>>
>
