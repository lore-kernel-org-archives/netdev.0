From: Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 3/3] infiniband: rxe: fix 32-bit build warnings
Date: Mon, 13 Jun 2016 18:29:09 +0300
Message-ID: <CAG9sBKPUYo0WH5ecWhR55iNw=4teQ04mHHv+v7P2iOb6ymnE1A@mail.gmail.com>
References: <1465822509-4167617-1-git-send-email-arnd@arndb.de> <1465822509-4167617-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kamal Heib <kamalh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465822509-4167617-3-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

thanks. will be applied to next series.

On Mon, Jun 13, 2016 at 3:54 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> The new rxe infinband driver passes around pointers that have been
> converted to 64-bit integers. This is valid, but causes compile-time
> warnings on all 32-bit architectures:
>
> infiniband/hw/rxe/rxe_dma.c: In function 'rxe_dma_map_single':
> infiniband/hw/rxe/rxe_dma.c:49:9: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>   return (u64)cpu_addr;
>          ^
> infiniband/hw/rxe/rxe_dma.c: In function 'rxe_dma_map_page':
> infiniband/hw/rxe/rxe_dma.c:73:9: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
> infiniband/hw/rxe/rxe_dma.c: In function 'rxe_map_sg':
> infiniband/hw/rxe/rxe_dma.c:99:10: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
> infiniband/hw/rxe/rxe_dma.c: In function 'rxe_dma_alloc_coherent':
> infiniband/hw/rxe/rxe_dma.c:143:17: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>
> This changes the cast to use 'uintptr_t', which can always be
> cast to and from pointer, and can be assigned to and from 64-bit
> integers.
>
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> ---
>  drivers/infiniband/hw/rxe/rxe_dma.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/infiniband/hw/rxe/rxe_dma.c b/drivers/infiniband/hw/rxe/rxe_dma.c
> index f080bc5bda43..7634c1a81b2b 100644
> --- a/drivers/infiniband/hw/rxe/rxe_dma.c
> +++ b/drivers/infiniband/hw/rxe/rxe_dma.c
> @@ -46,7 +46,7 @@ static u64 rxe_dma_map_single(struct ib_device *dev,
>                               enum dma_data_direction direction)
>  {
>         WARN_ON(!valid_dma_direction(direction));
> -       return (u64)cpu_addr;
> +       return (uintptr_t)cpu_addr;
>  }
>
>  static void rxe_dma_unmap_single(struct ib_device *dev,
> @@ -70,7 +70,7 @@ static u64 rxe_dma_map_page(struct ib_device *dev,
>                 goto done;
>         }
>
> -       addr = (u64)page_address(page);
> +       addr = (uintptr_t)page_address(page);
>         if (addr)
>                 addr += offset;
>
> @@ -96,7 +96,7 @@ static int rxe_map_sg(struct ib_device *dev, struct scatterlist *sgl,
>         WARN_ON(!valid_dma_direction(direction));
>
>         for_each_sg(sgl, sg, nents, i) {
> -               addr = (u64)page_address(sg_page(sg));
> +               addr = (uintptr_t)page_address(sg_page(sg));
>                 if (!addr) {
>                         ret = 0;
>                         break;
> @@ -140,7 +140,7 @@ static void *rxe_dma_alloc_coherent(struct ib_device *dev, size_t size,
>                 addr = page_address(p);
>
>         if (dma_handle)
> -               *dma_handle = (u64)addr;
> +               *dma_handle = (uintptr_t)addr;
>
>         return addr;
>  }
> --
> 2.7.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
