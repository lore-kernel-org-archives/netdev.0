From: Hanjun Guo <hanjun.guo@linaro.org>
Subject: Re: [V2 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Wed, 06 May 2015 11:13:25 +0800
Message-ID: <554986D5.5010102@linaro.org>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com> <1430838729-21572-2-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: msalter@redhat.com, al.stone@linaro.org, grant.likely@linaro.org,
	arnd@arndb.de, leo.duran@amd.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
	rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com,
	will.deacon@arm.com, thomas.lendacky@amd.com,
	herbert@gondor.apana.org.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35451 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757824AbbEFDNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 23:13:43 -0400
Received: by pdbqd1 with SMTP id qd1so217079450pdb.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 20:13:42 -0700 (PDT)
In-Reply-To: <1430838729-21572-2-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015=E5=B9=B405=E6=9C=8805=E6=97=A5 23:12, Suravee Suthikulpanit wro=
te:
> This patch implements support for ACPI _CCA object, which is introduc=
ed in
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
> NOTE:
>   * Since there seem to be conflict opinions regarding how
>     architecture should handle _CCA=3D0. So, I am proposing the
>     CONFIG_ARCH_SUPPORT_CCA_ZERO, which can be specified by
>     for each architecture to define behavior of the ACPI
>     scanning code when _CCA=3D0. Let me know if this is acceptable.
>
>   drivers/acpi/Kconfig         |  6 +++++
>   drivers/acpi/acpi_platform.c |  4 ++-
>   drivers/acpi/scan.c          | 62 +++++++++++++++++++++++++++++++++=
+++++++++++
>   include/acpi/acpi_bus.h      | 11 +++++++-
>   include/linux/acpi.h         |  5 ++++
>   5 files changed, 86 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index ab2cbb5..dd386e9 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -54,6 +54,12 @@ config ACPI_GENERIC_GSI
>   config ACPI_SYSTEM_POWER_STATES_SUPPORT
>   	bool
>
> +config ACPI_MUST_HAVE_CCA
> +	bool
> +
> +config ACPI_SUPPORT_CCA_ZERO
> +	bool
> +
>   config ACPI_SLEEP
>   	bool
>   	depends on SUSPEND || HIBERNATION
> diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platfor=
m.c
> index 4bf7559..a6feca4 100644
> --- a/drivers/acpi/acpi_platform.c
> +++ b/drivers/acpi/acpi_platform.c
> @@ -108,9 +108,11 @@ struct platform_device *acpi_create_platform_dev=
ice(struct acpi_device *adev)
>   	if (IS_ERR(pdev))
>   		dev_err(&adev->dev, "platform device creation failed: %ld\n",
>   			PTR_ERR(pdev));
> -	else
> +	else {
> +		acpi_setup_device_dma(adev, &pdev->dev);
>   		dev_dbg(&adev->dev, "created platform device %s\n",
>   			dev_name(&pdev->dev));
> +	}
>
>   	kfree(resources);
>   	return pdev;
> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
> index 849b699..ac33b29 100644
> --- a/drivers/acpi/scan.c
> +++ b/drivers/acpi/scan.c
> @@ -11,6 +11,7 @@
>   #include <linux/kthread.h>
>   #include <linux/dmi.h>
>   #include <linux/nls.h>
> +#include <linux/dma-mapping.h>
>
>   #include <asm/pgtable.h>
>
> @@ -2137,6 +2138,66 @@ void acpi_free_pnp_ids(struct acpi_device_pnp =
*pnp)
>   	kfree(pnp->unique_id);
>   }
>
> +void acpi_setup_device_dma(struct acpi_device *adev, struct device *=
dev)

I aasume adev->dev in struct *adev is the same as struct device *dev
passed here, so

> +{
> +	int coherent =3D acpi_dma_is_coherent(adev);
> +
> +	/**
> +	 * Currently, we only support DMA for devices that _CCA=3D1
> +	 * since this seems to be the case on most ACPI platforms.
> +	 *
> +	 * For the case when _CCA=3D0 (i.e. is_coherent=3D0 && cca_seen=3D1=
),
> +	 * we would rely on arch-specific cache maintenance for
> +	 * non-coherence DMA operations if architecture enables
> +	 * CONFIG_ACPI_SUPPORT_CCA_ZERO.
> +	 *
> +	 * For the case when _CCA is missing but platform requires it
> +	 * (i.e. is_coherent=3D0 && cca_seen=3D0), we do not call
> +	 * arch_setup_dma_ops() and fallback to arch-specific default
> +	 * handling.
> +	 */
> +	if (adev->flags.cca_seen) {
> +		if (!coherent && !IS_ENABLED(CONFIG_ACPI_SUPPORT_CCA_ZERO))
> +			return;
> +		arch_setup_dma_ops(dev, 0, 0, NULL, coherent);

how about using &adev->dev here, and just pass struct acpi_device *adev
for this function?

Thanks
Hanjun
