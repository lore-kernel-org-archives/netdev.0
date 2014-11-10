From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: split to core library and probe drivers
Date: Mon, 10 Nov 2014 15:28:06 +0100
Message-ID: <5460CB76.5080806@st.com>
References: <1415615939-6671-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:42789 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751992AbaKJO2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 09:28:24 -0500
In-Reply-To: <1415615939-6671-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy

On 11/10/2014 11:38 AM, Andy Shevchenko wrote:
> Instead of registering the platform and PCI drivers in one module let's move
> necessary bits to where it belongs. During this procedure we convert the module
> registration part to use module_*_driver() macros which makes code simplier.
>
>>From now on the driver consists three parts: core library, PCI, and platform
> drivers.
>
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

patch looks fine and net-next.

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/Kconfig        |  4 +-
>   drivers/net/ethernet/stmicro/stmmac/Makefile       | 15 +++---
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h       | 61 ----------------------
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 36 ++-----------
>   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  4 +-
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 13 ++---
>   6 files changed, 25 insertions(+), 108 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> index 33b85ba..7d3af19 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> @@ -14,7 +14,7 @@ config STMMAC_ETH
>   if STMMAC_ETH
>
>   config STMMAC_PLATFORM
> -	bool "STMMAC Platform bus support"
> +	tristate "STMMAC Platform bus support"
>   	depends on STMMAC_ETH
>   	default y
>   	---help---
> @@ -27,7 +27,7 @@ config STMMAC_PLATFORM
>   	  If unsure, say N.
>
>   config STMMAC_PCI
> -	bool "STMMAC PCI bus support"
> +	tristate "STMMAC PCI bus support"
>   	depends on STMMAC_ETH && PCI
>   	---help---
>   	  This is to select the Synopsys DWMAC available on PCI devices,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
> index 034da70..ac4d562 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
> @@ -1,9 +1,12 @@
>   obj-$(CONFIG_STMMAC_ETH) += stmmac.o
> -stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
> -stmmac-$(CONFIG_STMMAC_PLATFORM) +=	stmmac_platform.o dwmac-meson.o \
> -					dwmac-sunxi.o dwmac-sti.o \
> -					dwmac-socfpga.o
>   stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
> -	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
> -	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
> +	      chain_mode.o dwmac_lib.o dwmac1000_core.o dwmac1000_dma.o	\
> +	      dwmac100_core.o dwmac100_dma.o enh_desc.o norm_desc.o	\
>   	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o $(stmmac-y)
> +
> +obj-$(CONFIG_STMMAC_PLATFORM) += stmmac-platform.o
> +stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
> +		       dwmac-sti.o dwmac-socfpga.o
> +
> +obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
> +stmmac-pci-objs:= stmmac_pci.o
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index bd75ee8..c0a3919 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -134,65 +134,4 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>   void stmmac_disable_eee_mode(struct stmmac_priv *priv);
>   bool stmmac_eee_init(struct stmmac_priv *priv);
>
> -#ifdef CONFIG_STMMAC_PLATFORM
> -extern struct platform_driver stmmac_pltfr_driver;
> -
> -static inline int stmmac_register_platform(void)
> -{
> -	int err;
> -
> -	err = platform_driver_register(&stmmac_pltfr_driver);
> -	if (err)
> -		pr_err("stmmac: failed to register the platform driver\n");
> -
> -	return err;
> -}
> -
> -static inline void stmmac_unregister_platform(void)
> -{
> -	platform_driver_unregister(&stmmac_pltfr_driver);
> -}
> -#else
> -static inline int stmmac_register_platform(void)
> -{
> -	pr_debug("stmmac: do not register the platf driver\n");
> -
> -	return 0;
> -}
> -
> -static inline void stmmac_unregister_platform(void)
> -{
> -}
> -#endif /* CONFIG_STMMAC_PLATFORM */
> -
> -#ifdef CONFIG_STMMAC_PCI
> -extern struct pci_driver stmmac_pci_driver;
> -static inline int stmmac_register_pci(void)
> -{
> -	int err;
> -
> -	err = pci_register_driver(&stmmac_pci_driver);
> -	if (err)
> -		pr_err("stmmac: failed to register the PCI driver\n");
> -
> -	return err;
> -}
> -
> -static inline void stmmac_unregister_pci(void)
> -{
> -	pci_unregister_driver(&stmmac_pci_driver);
> -}
> -#else
> -static inline int stmmac_register_pci(void)
> -{
> -	pr_debug("stmmac: do not register the PCI driver\n");
> -
> -	return 0;
> -}
> -
> -static inline void stmmac_unregister_pci(void)
> -{
> -}
> -#endif /* CONFIG_STMMAC_PCI */
> -
>   #endif /* __STMMAC_H__ */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 53db11b..0f1c146 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2885,6 +2885,7 @@ error_clk_get:
>
>   	return ERR_PTR(ret);
>   }
> +EXPORT_SYMBOL_GPL(stmmac_dvr_probe);
>
>   /**
>    * stmmac_dvr_remove
> @@ -2914,8 +2915,8 @@ int stmmac_dvr_remove(struct net_device *ndev)
>
>   	return 0;
>   }
> +EXPORT_SYMBOL_GPL(stmmac_dvr_remove);
>
> -#ifdef CONFIG_PM
>   int stmmac_suspend(struct net_device *ndev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(ndev);
> @@ -2957,6 +2958,7 @@ int stmmac_suspend(struct net_device *ndev)
>   	priv->oldduplex = -1;
>   	return 0;
>   }
> +EXPORT_SYMBOL_GPL(stmmac_suspend);
>
>   int stmmac_resume(struct net_device *ndev)
>   {
> @@ -3003,37 +3005,7 @@ int stmmac_resume(struct net_device *ndev)
>
>   	return 0;
>   }
> -#endif /* CONFIG_PM */
> -
> -/* Driver can be configured w/ and w/ both PCI and Platf drivers
> - * depending on the configuration selected.
> - */
> -static int __init stmmac_init(void)
> -{
> -	int ret;
> -
> -	ret = stmmac_register_platform();
> -	if (ret)
> -		goto err;
> -	ret = stmmac_register_pci();
> -	if (ret)
> -		goto err_pci;
> -	return 0;
> -err_pci:
> -	stmmac_unregister_platform();
> -err:
> -	pr_err("stmmac: driver registration failed\n");
> -	return ret;
> -}
> -
> -static void __exit stmmac_exit(void)
> -{
> -	stmmac_unregister_platform();
> -	stmmac_unregister_pci();
> -}
> -
> -module_init(stmmac_init);
> -module_exit(stmmac_exit);
> +EXPORT_SYMBOL_GPL(stmmac_resume);
>
>   #ifndef MODULE
>   static int __init stmmac_cmdline_opt(char *str)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 5084699..77a6d68 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -158,7 +158,7 @@ static const struct pci_device_id stmmac_id_table[] = {
>
>   MODULE_DEVICE_TABLE(pci, stmmac_id_table);
>
> -struct pci_driver stmmac_pci_driver = {
> +static struct pci_driver stmmac_pci_driver = {
>   	.name = STMMAC_RESOURCE_NAME,
>   	.id_table = stmmac_id_table,
>   	.probe = stmmac_pci_probe,
> @@ -168,6 +168,8 @@ struct pci_driver stmmac_pci_driver = {
>   	},
>   };
>
> +module_pci_driver(stmmac_pci_driver);
> +
>   MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet PCI driver");
>   MODULE_AUTHOR("Rayagond Kokatanur <rayagond.kokatanur@vayavyalabs.com>");
>   MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 9f18401..e22a960 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -362,7 +362,7 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
>   	return ret;
>   }
>
> -#ifdef CONFIG_PM
> +#ifdef CONFIG_PM_SLEEP
>   static int stmmac_pltfr_suspend(struct device *dev)
>   {
>   	int ret;
> @@ -388,13 +388,12 @@ static int stmmac_pltfr_resume(struct device *dev)
>
>   	return stmmac_resume(ndev);
>   }
> -
> -#endif /* CONFIG_PM */
> +#endif /* CONFIG_PM_SLEEP */
>
>   static SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops,
> -			stmmac_pltfr_suspend, stmmac_pltfr_resume);
> +			 stmmac_pltfr_suspend, stmmac_pltfr_resume);
>
> -struct platform_driver stmmac_pltfr_driver = {
> +static struct platform_driver stmmac_pltfr_driver = {
>   	.probe = stmmac_pltfr_probe,
>   	.remove = stmmac_pltfr_remove,
>   	.driver = {
> @@ -402,9 +401,11 @@ struct platform_driver stmmac_pltfr_driver = {
>   		   .owner = THIS_MODULE,
>   		   .pm = &stmmac_pltfr_pm_ops,
>   		   .of_match_table = of_match_ptr(stmmac_dt_ids),
> -		   },
> +	},
>   };
>
> +module_platform_driver(stmmac_pltfr_driver);
> +
>   MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet PLATFORM driver");
>   MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
>   MODULE_LICENSE("GPL");
>
