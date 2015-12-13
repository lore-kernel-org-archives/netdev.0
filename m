From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 24/28] net: pch_gbe: add device tree support
Date: Sun, 13 Dec 2015 03:22:19 +0200
Message-ID: <CAHp75VdezHXFcV9T=bd8k5JHoogC39Hew5GCdd02rk=PEM6ajw@mail.gmail.com>
References: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
        <1448900513-20856-25-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-mips@linux-mips.org, netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1448900513-20856-25-git-send-email-paul.burton@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 6:21 PM, Paul Burton <paul.burton@imgtec.com> wrote:
> Introduce support for retrieving the PHY reset GPIO from device tree,
> which will be used on the MIPS Boston development board. This requires
> support for probe deferral in order to work correctly, since the order
> of device probe is not guaranteed & typically the EG20T GPIO controller
> device will be probed after the ethernet MAC.
>
> Signed-off-by: Paul Burton <paul.burton@imgtec.com>
> ---
>
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 33 +++++++++++++++++++++-
>  1 file changed, 32 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 824ff9e..f2a9a38 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -23,6 +23,8 @@
>  #include <linux/net_tstamp.h>
>  #include <linux/ptp_classify.h>
>  #include <linux/gpio.h>
> +#include <linux/gpio/consumer.h>
> +#include <linux/of_gpio.h>
>
>  #define DRV_VERSION     "1.01"
>  const char pch_driver_version[] = DRV_VERSION;
> @@ -2594,13 +2596,41 @@ static void pch_gbe_remove(struct pci_dev *pdev)
>         free_netdev(netdev);
>  }
>
> +static int pch_gbe_parse_dt(struct pci_dev *pdev,
> +                           struct pch_gbe_privdata **pdata)

Why not to return pdata as it done in many other drivers?
You have ERR_PTR() macro to pass errors.

> +{
> +       struct device_node *np = pdev->dev.of_node;
> +       struct gpio_desc *gpio;
> +
> +       if (!config_enabled(CONFIG_OF) || !np)

Before I saw IS_ENABLED(). Is this one a preferable new API?

> +               return 0;
> +
> +       if (!*pdata)
> +               *pdata = devm_kzalloc(&pdev->dev, sizeof(**pdata), GFP_KERNEL);
> +       if (!*pdata)
> +               return -ENOMEM;
> +
> +       gpio = devm_gpiod_get(&pdev->dev, "phy-reset", GPIOD_ASIS);
> +       if (IS_ERR(gpio))
> +               return PTR_ERR(gpio);
> +
> +       (*pdata)->phy_reset_gpio = gpio;
> +       return 0;
> +}
> +
>  static int pch_gbe_probe(struct pci_dev *pdev,
>                           const struct pci_device_id *pci_id)
>  {
>         struct net_device *netdev;
>         struct pch_gbe_adapter *adapter;
> +       struct pch_gbe_privdata *pdata;
>         int ret;
>
> +       pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
> +       ret = pch_gbe_parse_dt(pdev, &pdata);

So, I didn;t see anything related to dt in that function.
Maybe you just call it always? In that case remove check for np.

> +       if (ret)
> +               goto err_out;
> +
>         ret = pcim_enable_device(pdev);
>         if (ret)
>                 return ret;
> @@ -2638,7 +2668,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>         adapter->pdev = pdev;
>         adapter->hw.back = adapter;
>         adapter->hw.reg = pcim_iomap_table(pdev)[PCH_GBE_PCI_BAR];
> -       adapter->pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
> +       adapter->pdata = pdata;
>         if (adapter->pdata && adapter->pdata->platform_init)
>                 adapter->pdata->platform_init(pdev, pdata);
>
> @@ -2729,6 +2759,7 @@ err_free_adapter:
>         pch_gbe_hal_phy_hw_reset(&adapter->hw);
>  err_free_netdev:
>         free_netdev(netdev);
> +err_out:

Redundant.

>         return ret;
>  }

For now it's a common practice to mix styles in probe due to usage of
devres API.

-- 
With Best Regards,
Andy Shevchenko
