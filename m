From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [V3 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Fri, 08 May 2015 22:55:02 +0200
Message-ID: <2525460.a0fQVdHbTU@vostro.rjw.lan>
References: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com> <1431045436-8690-3-git-send-email-Suravee.Suthikulpanit@amd.com>
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
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1431045436-8690-3-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 07, 2015 07:37:13 PM Suravee Suthikulpanit wrote:
> From http://www.uefi.org/sites/default/files/resources/ACPI_6.0.pdf,
> section 6.2.17 _CCA states that ARM platforms require ACPI _CCA
> object to be specified for DMA-cabpable devices. This patch introduces
> ACPI_MUST_HAVE_CCA in arm64 Kconfig to specify such requirement.
> 
> In case _CCA is missing, arm64 would assign dummy_dma_ops
> to disable DMA capability of the device.
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>
> Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>

This won't go in without any ACKs from the ARM64 maintainers.

> ---
>  arch/arm64/Kconfig                   |  2 +
>  arch/arm64/include/asm/dma-mapping.h | 18 ++++++-
>  arch/arm64/mm/dma-mapping.c          | 92 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 110 insertions(+), 2 deletions(-)
> 
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
>  	select BUILDTIME_EXTABLE_SORT
>  	select CLONE_BACKWARDS
>  	select COMMON_CLK
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
>  
>  static inline struct dma_map_ops *get_dma_ops(struct device *dev)
> @@ -48,6 +59,9 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
>  static inline void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
>  				      struct iommu_ops *iommu, bool coherent)
>  {
> +	if (!acpi_disabled && !dev->archdata.dma_ops)
> +		dev->archdata.dma_ops = dma_ops;
> +
>  	dev->archdata.dma_coherent = coherent;
>  }
>  #define arch_setup_dma_ops	arch_setup_dma_ops
> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index ef7d112..6e6d6ad 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
> @@ -415,6 +415,98 @@ out:
>  	return -ENOMEM;
>  }
>  
> +/********************************************
> + * The following APIs are for dummy DMA ops *
> + ********************************************/
> +
> +static void *__dummy_alloc(struct device *dev, size_t size,
> +			   dma_addr_t *dma_handle, gfp_t flags,
> +			   struct dma_attrs *attrs)
> +{
> +	return NULL;
> +}
> +
> +static void __dummy_free(struct device *dev, size_t size,
> +			 void *vaddr, dma_addr_t dma_handle,
> +			 struct dma_attrs *attrs)
> +{
> +}
> +
> +static int __dummy_mmap(struct device *dev,
> +			struct vm_area_struct *vma,
> +			void *cpu_addr, dma_addr_t dma_addr, size_t size,
> +			struct dma_attrs *attrs)
> +{
> +	return -ENXIO;
> +}
> +
> +static dma_addr_t __dummy_map_page(struct device *dev, struct page *page,
> +				   unsigned long offset, size_t size,
> +				   enum dma_data_direction dir,
> +				   struct dma_attrs *attrs)
> +{
> +	return DMA_ERROR_CODE;
> +}
> +
> +static void __dummy_unmap_page(struct device *dev, dma_addr_t dev_addr,
> +			       size_t size, enum dma_data_direction dir,
> +			       struct dma_attrs *attrs)
> +{
> +}
> +
> +static int __dummy_map_sg(struct device *dev, struct scatterlist *sgl,
> +			  int nelems, enum dma_data_direction dir,
> +			  struct dma_attrs *attrs)
> +{
> +	return 0;
> +}
> +
> +static void __dummy_unmap_sg(struct device *dev,
> +			     struct scatterlist *sgl, int nelems,
> +			     enum dma_data_direction dir,
> +			     struct dma_attrs *attrs)
> +{
> +}
> +
> +static void __dummy_sync_single(struct device *dev,
> +				dma_addr_t dev_addr, size_t size,
> +				enum dma_data_direction dir)
> +{
> +}
> +
> +static void __dummy_sync_sg(struct device *dev,
> +			    struct scatterlist *sgl, int nelems,
> +			    enum dma_data_direction dir)
> +{
> +}
> +
> +static int __dummy_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
> +{
> +	return 1;
> +}
> +
> +static int __dummy_dma_supported(struct device *hwdev, u64 mask)
> +{
> +	return 0;
> +}
> +
> +struct dma_map_ops dummy_dma_ops = {
> +	.alloc                  = __dummy_alloc,
> +	.free                   = __dummy_free,
> +	.mmap                   = __dummy_mmap,
> +	.map_page               = __dummy_map_page,
> +	.unmap_page             = __dummy_unmap_page,
> +	.map_sg                 = __dummy_map_sg,
> +	.unmap_sg               = __dummy_unmap_sg,
> +	.sync_single_for_cpu    = __dummy_sync_single,
> +	.sync_single_for_device = __dummy_sync_single,
> +	.sync_sg_for_cpu        = __dummy_sync_sg,
> +	.sync_sg_for_device     = __dummy_sync_sg,
> +	.mapping_error          = __dummy_mapping_error,
> +	.dma_supported          = __dummy_dma_supported,
> +};
> +EXPORT_SYMBOL(dummy_dma_ops);
> +
>  static int __init arm64_dma_init(void)
>  {
>  	int ret;
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
