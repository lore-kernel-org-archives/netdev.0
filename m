From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 03/44] dmaengine: ioat: don't use DMA_ERROR_CODE
Date: Fri, 16 Jun 2017 13:40:24 -0700
Message-ID: <CAKgT0UdxrimWrxNVsLMQ9G6ABBJZwfWHTcP18qqd4rT0Fa-KWg@mail.gmail.com>
References: <20170616181059.19206-1-hch@lst.de> <20170616181059.19206-4-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "the arch/x86 maintainers" <x86@kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        "open list:INTEL IOMMU (VT-d)" <iommu@lists.linux-foundation.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-hexagon-owner@vger.kernel.org>
In-Reply-To: <20170616181059.19206-4-hch@lst.de>
Sender: linux-hexagon-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 11:10 AM, Christoph Hellwig <hch@lst.de> wrote:
> DMA_ERROR_CODE is not a public API and will go away.  Instead properly
> unwind based on the loop counter.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Dave Jiang <dave.jiang@intel.com>
> Acked-By: Vinod Koul <vinod.koul@intel.com>
> ---
>  drivers/dma/ioat/init.c | 24 +++++++-----------------
>  1 file changed, 7 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/dma/ioat/init.c b/drivers/dma/ioat/init.c
> index 6ad4384b3fa8..ed8ed1192775 100644
> --- a/drivers/dma/ioat/init.c
> +++ b/drivers/dma/ioat/init.c
> @@ -839,8 +839,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>                 goto free_resources;
>         }
>
> -       for (i = 0; i < IOAT_NUM_SRC_TEST; i++)
> -               dma_srcs[i] = DMA_ERROR_CODE;
>         for (i = 0; i < IOAT_NUM_SRC_TEST; i++) {
>                 dma_srcs[i] = dma_map_page(dev, xor_srcs[i], 0, PAGE_SIZE,
>                                            DMA_TO_DEVICE);
> @@ -910,8 +908,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>
>         xor_val_result = 1;
>
> -       for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
> -               dma_srcs[i] = DMA_ERROR_CODE;
>         for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++) {
>                 dma_srcs[i] = dma_map_page(dev, xor_val_srcs[i], 0, PAGE_SIZE,
>                                            DMA_TO_DEVICE);
> @@ -965,8 +961,6 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>         op = IOAT_OP_XOR_VAL;
>
>         xor_val_result = 0;
> -       for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
> -               dma_srcs[i] = DMA_ERROR_CODE;
>         for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++) {
>                 dma_srcs[i] = dma_map_page(dev, xor_val_srcs[i], 0, PAGE_SIZE,
>                                            DMA_TO_DEVICE);
> @@ -1017,18 +1011,14 @@ static int ioat_xor_val_self_test(struct ioatdma_device *ioat_dma)
>         goto free_resources;
>  dma_unmap:
>         if (op == IOAT_OP_XOR) {
> -               if (dest_dma != DMA_ERROR_CODE)
> -                       dma_unmap_page(dev, dest_dma, PAGE_SIZE,
> -                                      DMA_FROM_DEVICE);
> -               for (i = 0; i < IOAT_NUM_SRC_TEST; i++)
> -                       if (dma_srcs[i] != DMA_ERROR_CODE)
> -                               dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> -                                              DMA_TO_DEVICE);
> +               while (--i >= 0)
> +                       dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> +                                      DMA_TO_DEVICE);
> +               dma_unmap_page(dev, dest_dma, PAGE_SIZE, DMA_FROM_DEVICE);
>         } else if (op == IOAT_OP_XOR_VAL) {
> -               for (i = 0; i < IOAT_NUM_SRC_TEST + 1; i++)
> -                       if (dma_srcs[i] != DMA_ERROR_CODE)
> -                               dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> -                                              DMA_TO_DEVICE);
> +               while (--i >= 0)
> +                       dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE,
> +                                      DMA_TO_DEVICE);

Wouldn't it make more sense to pull out the while loop and just call
dma_unmap_page on dest_dma if "op == IOAT_OP_XOR"? Odds are it is what
the compiler is already generating and will save a few lines of code
so what you end up with is something like:
    while (--i >= 0)
        dma_unmap_page(dev, dma_srcs[i], PAGE_SIZE, DMA_TO_DEVICE);
    if (op == IOAT_OP_XOR)
        dma_unmap_page(dev, dest_dma, PAGE_SIZE, DMA_FROM_DEVICE);

>         }
>  free_resources:
>         dma->device_free_chan_resources(dma_chan);
> --
> 2.11.0
>
