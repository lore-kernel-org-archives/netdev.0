From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3] net: macb: Added PCI wrapper for Platform Driver.
Date: Mon, 19 Dec 2016 00:43:16 +0200
Message-ID: <CAHp75VeOcAsTDsYDuQ_2nG1RUWn-txuHBJqyJnY-ywvPfeiK6g@mail.gmail.com>
References: <1481648560-25927-1-git-send-email-bfolta@cadence.com> <SN1PR0701MB19516D29452ABA2695B2F061CC9A0@SN1PR0701MB1951.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Simon Horman <simon.horman@netronome.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Rafal Ozieblo <rafalo@cadence.com>
To: Bartosz Folta <bfolta@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <SN1PR0701MB19516D29452ABA2695B2F061CC9A0@SN1PR0701MB1951.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2016 at 8:39 AM, Bartosz Folta <bfolta@cadence.com> wrote:
> There are hardware PCI implementations of Cadence GEM network
> controller. This patch will allow to use such hardware with reuse of
> existing Platform Driver.

Since it's already applied, perhaps you would consider addressing my
below comments as follow up clean up.

> +++ b/drivers/net/ethernet/cadence/macb_pci.c
> @@ -0,0 +1,153 @@
> +/**

> + * macb_pci.c - Cadence GEM PCI wrapper.

If at some point file is renamed it will be a bit more work to change
this line. Perhaps drop file name?

> +static int macb_probe(struct pci_dev *pdev, const struct pci_device_id *id)
> +{
> +       int err;
> +       struct platform_device *plat_dev;
> +       struct platform_device_info plat_info;
> +       struct macb_platform_data plat_data;
> +       struct resource res[2];
> +

> +       /* sanity check */
> +       if (!id)
> +               return -EINVAL;

Is it even possible in modern kernels?

> +
> +       /* enable pci device */
> +       err = pci_enable_device(pdev);

pcim_enable_device();

> +       if (err < 0) {
> +               dev_err(&pdev->dev, "Enabling PCI device has failed: 0x%04X",

%x for error code?! Confusing.

> +                       err);

> +               return -EACCES;

return err;

> +       }
> +
> +       pci_set_master(pdev);
> +
> +       /* set up resources */
> +       memset(res, 0x00, sizeof(struct resource) * ARRAY_SIZE(res));

> +       res[0].start = pdev->resource[0].start;
> +       res[0].end = pdev->resource[0].end;

pci_resource_start()
pci_resource_end()

> +       res[0].name = PCI_DRIVER_NAME;
> +       res[0].flags = IORESOURCE_MEM;

> +       res[1].start = pdev->irq;

Btw, does it support MSI? If so and are planning to use it,
pci_irq_...() API would help here.

> +       res[1].name = PCI_DRIVER_NAME;
> +       res[1].flags = IORESOURCE_IRQ;
> +
> +       dev_info(&pdev->dev, "EMAC physical base addr = 0x%p\n",

> +                (void *)(uintptr_t)pci_resource_start(pdev, 0));

Oh, %pa

> +
> +       /* set up macb platform data */
> +       memset(&plat_data, 0, sizeof(plat_data));
> +
> +       /* initialize clocks */
> +       plat_data.pclk = clk_register_fixed_rate(&pdev->dev, "pclk", NULL, 0,
> +                                                GEM_PCLK_RATE);
> +       if (IS_ERR(plat_data.pclk)) {
> +               err = PTR_ERR(plat_data.pclk);
> +               goto err_pclk_register;
> +       }
> +
> +       plat_data.hclk = clk_register_fixed_rate(&pdev->dev, "hclk", NULL, 0,
> +                                                GEM_HCLK_RATE);
> +       if (IS_ERR(plat_data.hclk)) {
> +               err = PTR_ERR(plat_data.hclk);
> +               goto err_hclk_register;
> +       }
> +
> +       /* set up platform device info */
> +       memset(&plat_info, 0, sizeof(plat_info));
> +       plat_info.parent = &pdev->dev;
> +       plat_info.fwnode = pdev->dev.fwnode;
> +       plat_info.name = PLAT_DRIVER_NAME;
> +       plat_info.id = pdev->devfn;
> +       plat_info.res = res;
> +       plat_info.num_res = ARRAY_SIZE(res);
> +       plat_info.data = &plat_data;
> +       plat_info.size_data = sizeof(plat_data);
> +       plat_info.dma_mask = DMA_BIT_MASK(32);
> +
> +       /* register platform device */
> +       plat_dev = platform_device_register_full(&plat_info);
> +       if (IS_ERR(plat_dev)) {
> +               err = PTR_ERR(plat_dev);
> +               goto err_plat_dev_register;
> +       }
> +
> +       pci_set_drvdata(pdev, plat_dev);
> +
> +       return 0;
> +
> +err_plat_dev_register:
> +       clk_unregister(plat_data.hclk);
> +
> +err_hclk_register:
> +       clk_unregister(plat_data.pclk);
> +

> +err_pclk_register:
> +       pci_disable_device(pdev);

Redundant when use pcim_enable_device().

> +       return err;
> +}
> +
> +static void macb_remove(struct pci_dev *pdev)
> +{
> +       struct platform_device *plat_dev = pci_get_drvdata(pdev);
> +       struct macb_platform_data *plat_data = dev_get_platdata(&plat_dev->dev);
> +
> +       platform_device_unregister(plat_dev);

> +       pci_disable_device(pdev);

Ditto.

> +       clk_unregister(plat_data->pclk);
> +       clk_unregister(plat_data->hclk);
> +}


-- 
With Best Regards,
Andy Shevchenko
