From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 15/16] dma-debug: x86 architecture bindings
Date: Sun, 11 Jan 2009 15:25:47 +0900
Message-ID: <20090111152209D.fujita.tomonori@lab.ntt.co.jp>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
	<1231517970-20288-16-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: joerg.roedel@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:45345 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbZAKG0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 01:26:12 -0500
In-Reply-To: <1231517970-20288-16-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Jan 2009 17:19:29 +0100
Joerg Roedel <joerg.roedel@amd.com> wrote:

> Impact: make use of DMA-API debugging code in x86
> 
> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> ---
>  arch/x86/Kconfig                   |    1 +
>  arch/x86/include/asm/dma-mapping.h |   30 ++++++++++++++++++++++++++----
>  arch/x86/kernel/pci-dma.c          |    5 +++++
>  3 files changed, 32 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 862adb9..68a806c 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -39,6 +39,7 @@ config X86
>  	select HAVE_GENERIC_DMA_COHERENT if X86_32
>  	select HAVE_EFFICIENT_UNALIGNED_ACCESS
>  	select USER_STACKTRACE_SUPPORT
> +	select HAVE_DMA_API_DEBUG
>  
>  config ARCH_DEFCONFIG
>  	string
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index 4035357..939d5b3 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -7,6 +7,7 @@
>   */
>  
>  #include <linux/scatterlist.h>
> +#include <linux/dma-debug.h>
>  #include <asm/io.h>
>  #include <asm/swiotlb.h>
>  #include <asm-generic/dma-coherent.h>
> @@ -93,9 +94,12 @@ dma_map_single(struct device *hwdev, void *ptr, size_t size,
>  	       int direction)
>  {
>  	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
> +	dma_addr_t addr;
>  
>  	BUG_ON(!valid_dma_direction(direction));
> -	return ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
> +	addr = ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
> +	debug_map_single(hwdev, ptr, size, direction, addr);
> +	return addr;

What happens if ops->map_single fails?

Seems that debug_map_single doesn't check the dma mapping fails. So it
allocates a new entries and nobody frees it?

Another problem is that what happens if ops->map_single succeeds but
debug_map_single fails? Seems that it gives a false warning.
