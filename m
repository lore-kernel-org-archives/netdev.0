From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH v2 3/4] I/OAT: tcp_dma_copybreak default valuedependant onI/OAT version
Date: Mon, 21 Jul 2008 17:13:24 +0100
Message-ID: <7F38996F7185A24AB9071ED4950AD8C101D2CD4F@swsmsx413.ger.corp.intel.com>
References: <1216407254.18755.4.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Nelson, Shannon" <shannon.nelson@intel.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20812 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816AbYGUQNc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:13:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1216407254.18755.4.camel@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Dan J wrote:
> On Fri, 2008-07-18 at 08:29 -0700, Sosnowski, Maciej wrote:
>> I/OAT DMA performance tuning showed different optimal values
>> of tcp_dma_copybreak for different I/OAT versions
>> (4096 for 1.2 and 2048 for 2.0).
>> This patch lets ioatdma driver set tcp_dma_copybreak value according
>> to these results. 
>> 
>> Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> 
> Let's kill some ifdef's... how about the following instead?
> 
> diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
> index 171cad6..1c0dafc 100644
> --- a/drivers/dma/ioat_dma.c
> +++ b/drivers/dma/ioat_dma.c
> @@ -1330,6 +1330,8 @@ struct ioatdma_device *ioat_dma_probe(struct
>  	pci_dev *pdev, if (err)
>  		goto err_self_test;
> 
> +	ioat_set_tcp_copy_break(device);
> +
>  	dma_async_device_register(&device->common);
> 
>  	return device;
> diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
> index f2c7fed..23e3196 100644
> --- a/drivers/dma/ioatdma.h
> +++ b/drivers/dma/ioatdma.h
> @@ -27,6 +27,7 @@
>  #include <linux/dmapool.h>
>  #include <linux/cache.h>
>  #include <linux/pci_ids.h>
> +#include <net/tcp.h>
> 
>  #define IOAT_DMA_VERSION  "2.04"
> 
> @@ -121,6 +122,20 @@ struct ioat_desc_sw {
>  	struct dma_async_tx_descriptor async_tx;
>  };
> 
> +static inline void ioat_set_tcp_copy_break(struct ioatdma_device
> *dev) +{
> +	#ifdef CONFIG_NET_DMA
> +	switch (dev->version) {
> +	case IOAT_VER_1_2:
> +		sysctl_tcp_dma_copybreak = 4096;
> +		break;
> +	case IOAT_VER_2_0:
> +		sysctl_tcp_dma_copybreak = 2048;
> +		break;
> +	}
> +	#endif
> +}
> +
>  #if defined(CONFIG_INTEL_IOATDMA) ||
>  defined(CONFIG_INTEL_IOATDMA_MODULE) struct ioatdma_device
>  				      *ioat_dma_probe(struct pci_dev
*pdev, void __iomem
> *iobase); 
> diff --git a/net/core/user_dma.c b/net/core/user_dma.c
> index 0ad1cd5..de76050 100644
> --- a/net/core/user_dma.c
> +++ b/net/core/user_dma.c
> @@ -34,6 +34,7 @@
>  #define NET_DMA_DEFAULT_COPYBREAK 4096
> 
>  int sysctl_tcp_dma_copybreak = NET_DMA_DEFAULT_COPYBREAK;
> +EXPORT_SYMBOL(sysctl_tcp_dma_copybreak);
> 
>  /**
>   *	dma_skb_copy_datagram_iovec - Copy a datagram to an iovec.

Yes, I'm fine with this version.

Regards,
Maciej
