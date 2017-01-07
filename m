From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3] net: stmmac: fix maxmtu assignment to be within valid range
Date: Sat, 7 Jan 2017 02:07:14 +0200
Message-ID: <CAHp75VeWs8LXS+zaCht8reLMLRtz+583K91QvoPquuUxC-rwWg@mail.gmail.com>
References: <1483750143-11966-1-git-send-email-hock.leong.kweh@intel.com>
 <CAHp75VdkGcQM_fW6LLuQ1JC67p4vGNWKcyxPs5Sc-4tFi2MGLg@mail.gmail.com> <F54AEECA5E2B9541821D670476DAE19C5A918C87@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        Jarod Wilson <jarod@redhat.com>,
        Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36479 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdAGAHQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 19:07:16 -0500
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C5A918C87@PGSMSX102.gar.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 7, 2017 at 1:47 AM, Kweh, Hock Leong
<hock.leong.kweh@intel.com> wrote:

>> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> > @@ -3345,8 +3345,14 @@ int stmmac_dvr_probe(struct device *device,
>> >                 ndev->max_mtu = JUMBO_LEN;
>> >         else
>> >                 ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
>> > -       if (priv->plat->maxmtu < ndev->max_mtu)
>>
>> > +       if ((priv->plat->maxmtu < ndev->max_mtu) &&
>> > +           (priv->plat->maxmtu >= ndev->min_mtu))
>>
>> >                 ndev->max_mtu = priv->plat->maxmtu;
>>
>> > +       else if (priv->plat->maxmtu < ndev->min_mtu)
>>
>> And if it > ndev->max_mtu?..
>>
>
> Base on my understanding to the original code, the "maxmtu >= ndev->max_mtu"
> is meant for products that would want to use the value from logic which is just above
> this statement where you just ask me not to add new line. That the reason the
> stmmac_platform.c put in "plat->maxmtu = JUMBO_LEN;" as generic and I also
> follow it in stmmac_pci.c.
>
> Or do you mean only take maxmtu = JUMBO_LEN for the option to use driver itself
> assignment statement above and all the > max_mtu consider invalid?

So, just answer to the simple question: is it a valid case to have
plat->maxmtu > ndev->max_mtu? If it so, how is it used?
Otherwise we need a warning in such case. What did I miss?

>
>> > +               netdev_warn(priv->dev,
>> > +                           "%s: warning: maxmtu having invalid value (%d)\n",
>> > +                           __func__, priv->plat->maxmtu);


>> > +       /* Set the maxmtu to a default of JUMBO_LEN in case the
>> > +        * parameter is not defined for the device.
>> > +        */
>> > +       plat->maxmtu = JUMBO_LEN;
>>
>> Please, use *_default_data() hooks for that.
>>
>> At some point it might make sense to extract
>> static int common_default_data() {...}
>> and call it at the beginning of the rest of *_defautl_data() hooks.
>>
>
> Just try to understand, are you referring changing the code something
> like this:
>
>         stmmac_default_data(plat);
>         if (info) {
>                 info->pdev = pdev;
>                 if (info->setup) {
>                         ret = info->setup(plat, info);
>                         if (ret)
>                                 return ret;
>                 }
>         }
>
> Where all the common code is inside the stmmac_default_data()?

No.

common_default_data()
{
 ... common defaults among *_default_data() ...
}

*_default_data()
{
...
 common_default_data();
 ...
}

-- 
With Best Regards,
Andy Shevchenko
