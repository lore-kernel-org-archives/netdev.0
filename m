From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [V3 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Mon, 11 May 2015 18:12:29 +0100
Message-ID: <20150511171229.GK18655@e104818-lin.cambridge.arm.com>
References: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1431045436-8690-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rjw@rjwysocki.net, lenb@kernel.org, will.deacon@arm.com,
	thomas.lendacky@amd.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, arnd@arndb.de, al.stone@linaro.org,
	linaro-acpi@lists.linaro.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	leo.duran@amd.com, hanjun.guo@linaro.org, msalter@redhat.com,
	grant.likely@linaro.org, linux-arm-kernel@lists.infradead.org,
	linux-crypto@vger.kernel.org
To: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431045436-8690-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 07, 2015 at 07:37:13PM -0500, Suravee Suthikulpanit wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 4269dba..c7227e8 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1,5 +1,6 @@
>  config ARM64
>  	def_bool y
> +	select ACPI_CCA_REQUIRED if ACPI
>  	select ACPI_GENERIC_GSI if ACPI
>  	select ACPI_REDUCED_HARDWARE_ONLY if ACPI
>  	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
> @@ -19,6 +20,7 @@ config ARM64
>  	select ARM_GIC_V2M if PCI_MSI
>  	select ARM_GIC_V3
>  	select ARM_GIC_V3_ITS if PCI_MSI
> +	select ARM64_SUPPORT_ACPI_CCA_ZERO if ACPI

As per the other sub-thread, I don't think we need this option at all.

> diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
> index 9437e3d..f0d6d0b 100644
> --- a/arch/arm64/include/asm/dma-mapping.h
> +++ b/arch/arm64/include/asm/dma-mapping.h
> @@ -18,6 +18,7 @@
>  
>  #ifdef __KERNEL__
>  
> +#include <linux/acpi.h>
>  #include <linux/types.h>
>  #include <linux/vmalloc.h>
>  
> @@ -28,13 +29,23 @@
>  
>  #define DMA_ERROR_CODE	(~(dma_addr_t)0)
>  extern struct dma_map_ops *dma_ops;
> +extern struct dma_map_ops dummy_dma_ops;
>  
>  static inline struct dma_map_ops *__generic_dma_ops(struct device *dev)
>  {
> -	if (unlikely(!dev) || !dev->archdata.dma_ops)
> +	if (unlikely(!dev))
>  		return dma_ops;
> -	else
> +	else if (dev->archdata.dma_ops)
>  		return dev->archdata.dma_ops;
> +	else if (acpi_disabled)
> +		return dma_ops;
> +
> +	/*
> +	 * When ACPI is enabled, if arch_set_dma_ops is not called,
> +	 * we will disable device DMA capability by setting it
> +	 * to dummy_dma_ops.
> +	 */
> +	return &dummy_dma_ops;
>  }

The code looks fine to me but Arnd had some comments that I didn't fully
understand (dropping dummy_map_ops in favour of simply setting dma_mask
to NULL; I don't think the existing swiotlb ops would behave in a way
that always return NULL).

-- 
Catalin
