From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [V5 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Fri, 22 May 2015 23:56:45 +0200
Message-ID: <1815824.lIg0NQ97lU@vostro.rjw.lan>
References: <1432159758-4486-1-git-send-email-Suravee.Suthikulpanit@amd.com> <1432159758-4486-2-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com,
	thomas.lendacky@amd.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, arnd@arndb.de, msalter@redhat.com,
	hanjun.guo@linaro.org, al.stone@linaro.org,
	grant.likely@linaro.org, leo.duran@amd.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432159758-4486-2-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, May 20, 2015 05:09:14 PM Suravee Suthikulpanit wrote:
> This patch implements support for ACPI _CCA object, which is introduced in
> ACPIv5.1, can be used for specifying device DMA coherency attribute.
> 
> The parsing logic traverses device namespace to parse coherency
> information, and stores it in acpi_device_flags. Then uses it to call
> arch_setup_dma_ops() when creating each device enumerated in DSDT
> during ACPI scan.
> 
> This patch also introduces acpi_dma_is_coherent(), which provides
> an interface for device drivers to check the coherency information
> similarly to the of_dma_is_coherent().
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>
> Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
> ---
>  drivers/acpi/Kconfig         |  3 +++
>  drivers/acpi/acpi_platform.c |  2 +-
>  drivers/acpi/glue.c          |  5 +++++
>  drivers/acpi/scan.c          | 35 +++++++++++++++++++++++++++++++++++
>  include/acpi/acpi_bus.h      | 37 ++++++++++++++++++++++++++++++++++++-
>  include/linux/acpi.h         |  5 +++++
>  6 files changed, 85 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index ab2cbb5..212735f 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -54,6 +54,9 @@ config ACPI_GENERIC_GSI
>  config ACPI_SYSTEM_POWER_STATES_SUPPORT
>  	bool
>  
> +config ACPI_CCA_REQUIRED
> +	bool
> +
>  config ACPI_SLEEP
>  	bool
>  	depends on SUSPEND || HIBERNATION
> diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
> index 4bf7559..06a67d5 100644
> --- a/drivers/acpi/acpi_platform.c
> +++ b/drivers/acpi/acpi_platform.c
> @@ -103,7 +103,7 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *adev)
>  	pdevinfo.res = resources;
>  	pdevinfo.num_res = count;
>  	pdevinfo.fwnode = acpi_fwnode_handle(adev);
> -	pdevinfo.dma_mask = DMA_BIT_MASK(32);
> +	pdevinfo.dma_mask = acpi_check_dma(adev, NULL) ? DMA_BIT_MASK(32) : 0;
>  	pdev = platform_device_register_full(&pdevinfo);
>  	if (IS_ERR(pdev))
>  		dev_err(&adev->dev, "platform device creation failed: %ld\n",
> diff --git a/drivers/acpi/glue.c b/drivers/acpi/glue.c
> index 39c485b..b9657af 100644
> --- a/drivers/acpi/glue.c
> +++ b/drivers/acpi/glue.c
> @@ -13,6 +13,7 @@
>  #include <linux/slab.h>
>  #include <linux/rwsem.h>
>  #include <linux/acpi.h>
> +#include <linux/dma-mapping.h>
>  
>  #include "internal.h"
>  
> @@ -167,6 +168,7 @@ int acpi_bind_one(struct device *dev, struct acpi_device *acpi_dev)
>  	struct list_head *physnode_list;
>  	unsigned int node_id;
>  	int retval = -EINVAL;
> +	bool coherent;
>  
>  	if (has_acpi_companion(dev)) {
>  		if (acpi_dev) {
> @@ -223,6 +225,9 @@ int acpi_bind_one(struct device *dev, struct acpi_device *acpi_dev)
>  	if (!has_acpi_companion(dev))
>  		ACPI_COMPANION_SET(dev, acpi_dev);
>  
> +	if (acpi_check_dma(acpi_dev, &coherent))
> +		arch_setup_dma_ops(dev, 0, 0, NULL, coherent);
> +

Well, so is this going to work for PCI too after all?

>  	acpi_physnode_link_name(physical_node_name, node_id);
>  	retval = sysfs_create_link(&acpi_dev->dev.kobj, &dev->kobj,
>  				   physical_node_name);


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
