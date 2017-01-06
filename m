From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3] net: stmmac: fix maxmtu assignment to be within valid range
Date: Fri, 6 Jan 2017 19:06:39 +0200
Message-ID: <CAHp75VdkGcQM_fW6LLuQ1JC67p4vGNWKcyxPs5Sc-4tFi2MGLg@mail.gmail.com>
References: <1483750143-11966-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com, Jarod Wilson <jarod@redhat.com>,
        Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        lars.persson@axis.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33244 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdAFRGl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 12:06:41 -0500
In-Reply-To: <1483750143-11966-1-git-send-email-hock.leong.kweh@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 7, 2017 at 2:49 AM, Kweh, Hock Leong
<hock.leong.kweh@intel.com> wrote:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>
> There is no checking valid value of maxmtu when getting it from device tree.
> This resolution added the checking condition to ensure the assignment is
> made within a valid range.

> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3345,8 +3345,14 @@ int stmmac_dvr_probe(struct device *device,
>                 ndev->max_mtu = JUMBO_LEN;
>         else
>                 ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
> -       if (priv->plat->maxmtu < ndev->max_mtu)

> +

The lines are logically grouped here. No need to split it. Thus,
remove this extra line.

> +       if ((priv->plat->maxmtu < ndev->max_mtu) &&
> +           (priv->plat->maxmtu >= ndev->min_mtu))

>                 ndev->max_mtu = priv->plat->maxmtu;

> +       else if (priv->plat->maxmtu < ndev->min_mtu)

And if it > ndev->max_mtu?..

> +               netdev_warn(priv->dev,
> +                           "%s: warning: maxmtu having invalid value (%d)\n",
> +                           __func__, priv->plat->maxmtu);


> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -204,6 +204,10 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
>
>         pci_set_master(pdev);
>
> +       /* Set the maxmtu to a default of JUMBO_LEN in case the
> +        * parameter is not defined for the device.
> +        */
> +       plat->maxmtu = JUMBO_LEN;

Please, use *_default_data() hooks for that.

At some point it might make sense to extract
static int common_default_data() {...}
and call it at the beginning of the rest of *_defautl_data() hooks.

-- 
With Best Regards,
Andy Shevchenko
