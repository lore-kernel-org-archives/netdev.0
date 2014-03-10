From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHv5 net-next 15/31] iw_cxgb4: save the correct map length
 for fast_reg_page_lists
Date: Mon, 10 Mar 2014 23:43:21 +0300
Message-ID: <531E23E9.4030702@cogentembedded.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com> <1394471308-4304-16-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394471308-4304-16-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/10/2014 08:08 PM, Hariprasad Shenai wrote:

> From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

> We cannot save the mapped length using the rdma max_page_list_len field
> of the ib_fast_reg_page_list struct because the core code uses it.  This
> results in an incorrect unmap of the page list in c4iw_free_fastreg_pbl().

> I found this with dma map debugging enabled in the kernel.  The fix is
> to save the length in the c4iw_fr_page_list struct.

> Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> ---
>   drivers/infiniband/hw/cxgb4/iw_cxgb4.h |  1 +
>   drivers/infiniband/hw/cxgb4/mem.c      | 12 ++++++++++--
>   2 files changed, 11 insertions(+), 2 deletions(-)

> diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
> index 8c32088..b75f8f5 100644
> --- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
> +++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
> @@ -375,6 +375,7 @@ struct c4iw_fr_page_list {
>   	DEFINE_DMA_UNMAP_ADDR(mapping);
>   	dma_addr_t dma_addr;
>   	struct c4iw_dev *dev;
> +	int pll_len;
>   };
>
>   static inline struct c4iw_fr_page_list *to_c4iw_fr_page_list(
> diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
> index 41b1195..cdaf257 100644
> --- a/drivers/infiniband/hw/cxgb4/mem.c
> +++ b/drivers/infiniband/hw/cxgb4/mem.c
> @@ -903,7 +903,11 @@ struct ib_fast_reg_page_list *c4iw_alloc_fastreg_pbl(struct ib_device *device,
>   	dma_unmap_addr_set(c4pl, mapping, dma_addr);
>   	c4pl->dma_addr = dma_addr;
>   	c4pl->dev = dev;
> -	c4pl->ibpl.max_page_list_len = pll_len;
> +	c4pl->pll_len = pll_len;
> +
> +	PDBG("%s c4pl %p pll_len %u page_list %p dma_addr %p\n",
> +	     __func__, c4pl, c4pl->pll_len, c4pl->ibpl.page_list,
> +	     (void *)c4pl->dma_addr);

    There's %pad format for printing dma_addr_t, no need to cast and use %p.

>
>   	return &c4pl->ibpl;
>   }
> @@ -912,8 +916,12 @@ void c4iw_free_fastreg_pbl(struct ib_fast_reg_page_list *ibpl)
>   {
>   	struct c4iw_fr_page_list *c4pl = to_c4iw_fr_page_list(ibpl);
>
> +	PDBG("%s c4pl %p pll_len %u page_list %p dma_addr %p\n",
> +	     __func__, c4pl, c4pl->pll_len, c4pl->ibpl.page_list,
> +	     (void *)c4pl->dma_addr);
> +

    Likewise.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
