From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [PATCH] s2io: Fix warnings due to -Wunused-but-set-variable.
Date: Tue, 12 Apr 2011 11:00:04 -0500
Message-ID: <20110412160002.GB1433@kudzu.us>
References: <20110411.160143.258100330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38470 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058Ab1DLQAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 12:00:10 -0400
Received: by iyb14 with SMTP id 14so6754443iyb.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 09:00:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110411.160143.258100330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 04:01:43PM -0700, David Miller wrote:
> 
> Most of these are cases where we are trying to read back a register
> after a write to ensure completion.
> 
> Simply pre-fixing the readl() or readq() with "(void)" is sufficient
> because these are volatile operations and the compiler cannot eliminate
> them just because no real assignment takes place.
> 
> The case of free_rxd_blk()'s assignments to "struct buffAdd *ba" is a
> real spurious assignment as this variable is completely otherwise
> unused.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
Acked-by: Jon Mason <jdmason@kudzu.us>
> ---
>  drivers/net/s2io.c |    5 +----
>  drivers/net/s2io.h |   10 ++++------
>  2 files changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index ca8e75e..2d5cc61 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -2244,13 +2244,12 @@ static int verify_xena_quiescence(struct s2io_nic *sp)
>  static void fix_mac_address(struct s2io_nic *sp)
>  {
>  	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> -	u64 val64;
>  	int i = 0;
>  
>  	while (fix_mac[i] != END_SIGN) {
>  		writeq(fix_mac[i++], &bar0->gpio_control);
>  		udelay(10);
> -		val64 = readq(&bar0->gpio_control);
> +		(void) readq(&bar0->gpio_control);
>  	}
>  }
>  
> @@ -2727,7 +2726,6 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
>  	int j;
>  	struct sk_buff *skb;
>  	struct RxD_t *rxdp;
> -	struct buffAdd *ba;
>  	struct RxD1 *rxdp1;
>  	struct RxD3 *rxdp3;
>  	struct mac_info *mac_control = &sp->mac_control;
> @@ -2751,7 +2749,6 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
>  			memset(rxdp, 0, sizeof(struct RxD1));
>  		} else if (sp->rxd_mode == RXD_MODE_3B) {
>  			rxdp3 = (struct RxD3 *)rxdp;
> -			ba = &mac_control->rings[ring_no].ba[blk][j];
>  			pci_unmap_single(sp->pdev,
>  					 (dma_addr_t)rxdp3->Buffer0_ptr,
>  					 BUF0_LEN,
> diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
> index 628fd27..800b3a4 100644
> --- a/drivers/net/s2io.h
> +++ b/drivers/net/s2io.h
> @@ -1002,18 +1002,16 @@ static inline void writeq(u64 val, void __iomem *addr)
>  #define LF	2
>  static inline void SPECIAL_REG_WRITE(u64 val, void __iomem *addr, int order)
>  {
> -	u32 ret;
> -
>  	if (order == LF) {
>  		writel((u32) (val), addr);
> -		ret = readl(addr);
> +		(void) readl(addr);
>  		writel((u32) (val >> 32), (addr + 4));
> -		ret = readl(addr + 4);
> +		(void) readl(addr + 4);
>  	} else {
>  		writel((u32) (val >> 32), (addr + 4));
> -		ret = readl(addr + 4);
> +		(void) readl(addr + 4);
>  		writel((u32) (val), addr);
> -		ret = readl(addr);
> +		(void) readl(addr);
>  	}
>  }
>  
> -- 
> 1.7.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
