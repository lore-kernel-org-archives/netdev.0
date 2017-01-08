From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v5] net: stmmac: fix maxmtu assignment to be within valid range
Date: Sun, 8 Jan 2017 03:06:46 +0200
Message-ID: <CAHp75Ve6AJ_1_ZisKE+Zr1Vy-ftFbzbM3H04SHr7WYFnV4_0Lw@mail.gmail.com>
References: <1483781523-14334-1-git-send-email-hock.leong.kweh@intel.com>
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
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36466 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933164AbdAHBGr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 20:06:47 -0500
In-Reply-To: <1483781523-14334-1-git-send-email-hock.leong.kweh@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 7, 2017 at 11:32 AM, Kweh, Hock Leong
<hock.leong.kweh@intel.com> wrote:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>
> There is no checking valid value of maxmtu when getting it from
> device tree. This resolution added the checking condition to
> ensure the assignment is made within a valid range.

FWIW:
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>

>
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
> ---
> changelog v5:
> * revert back that plat->maxmtu > ndev->max_mtu is a valid case
>   when ndev->max_mtu assignment is entering to the else statement
> * add comment to enchance clarification
>
> changelog v4:
> * add print warning message when maxmtu > max_mtu as well
> * add maxmtu = JUMBO_LEN into each *_default_data() at stmmac_pci.c
>
> changelog v3:
> * print the warning message only if maxmtu < min_mtu
> * add maxmtu = JUMBO_LEN at stmmac_pci.c to follow stmmac_platform.c
>
> changelog v2:
> * correction of "devicetree" to "device tree" reported by Andy
> * print warning message while maxmtu is not in valid range
>
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   10 +++++++++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c  |    6 ++++++
>  2 files changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 92ac006..8e56dc4 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3345,8 +3345,16 @@ int stmmac_dvr_probe(struct device *device,
>                 ndev->max_mtu = JUMBO_LEN;
>         else
>                 ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
> -       if (priv->plat->maxmtu < ndev->max_mtu)
> +       /* Will not overwrite ndev->max_mtu if plat->maxmtu > ndev->max_mtu
> +        * as well as plat->maxmtu < ndev->min_mtu which is a invalid range.
> +        */
> +       if ((priv->plat->maxmtu < ndev->max_mtu) &&
> +           (priv->plat->maxmtu >= ndev->min_mtu))
>                 ndev->max_mtu = priv->plat->maxmtu;
> +       else if (priv->plat->maxmtu < ndev->min_mtu)
> +               netdev_warn(priv->dev,
> +                           "%s: warning: maxmtu having invalid value (%d)\n",
> +                           __func__, priv->plat->maxmtu);
>
>         if (flow_ctrl)
>                 priv->flow_ctrl = FLOW_AUTO;    /* RX/TX pause on */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index a283177..3da4737 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -89,6 +89,9 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
>
>         /* Set default value for unicast filter entries */
>         plat->unicast_filter_entries = 1;
> +
> +       /* Set the maxmtu to a default of JUMBO_LEN */
> +       plat->maxmtu = JUMBO_LEN;
>  }
>
>  static int quark_default_data(struct plat_stmmacenet_data *plat,
> @@ -126,6 +129,9 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>         /* Set default value for unicast filter entries */
>         plat->unicast_filter_entries = 1;
>
> +       /* Set the maxmtu to a default of JUMBO_LEN */
> +       plat->maxmtu = JUMBO_LEN;
> +
>         return 0;
>  }
>
> --
> 1.7.9.5
>



-- 
With Best Regards,
Andy Shevchenko
