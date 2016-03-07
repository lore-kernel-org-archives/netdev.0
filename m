From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: thunderx: Set recevie buffer page usage count
 in bulk
Date: Mon, 07 Mar 2016 11:15:34 -0500 (EST)
Message-ID: <20160307.111534.235286977900488968.davem@davemloft.net>
References: <1457336157-31508-1-git-send-email-sunil.kovvuri@gmail.com>
	<1457336157-31508-2-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: sunil.kovvuri@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbcCGQPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:15:36 -0500
In-Reply-To: <1457336157-31508-2-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sunil.kovvuri@gmail.com
Date: Mon,  7 Mar 2016 13:05:56 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> Instead of calling get_page() for every receive buffer carved out
> of page, set page's usage count at the end, to reduce no of atomic
> calls.
> 
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> ---
>  drivers/net/ethernet/cavium/thunder/nic.h          |    1 +
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.c |   31 ++++++++++++++-----
>  2 files changed, 24 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
> index 00cc915..5628aea 100644
> --- a/drivers/net/ethernet/cavium/thunder/nic.h
> +++ b/drivers/net/ethernet/cavium/thunder/nic.h
> @@ -285,6 +285,7 @@ struct nicvf {
>  	u32			speed;
>  	struct page		*rb_page;
>  	u32			rb_page_offset;
> +	u16			rb_pageref;
>  	bool			rb_alloc_fail;
>  	bool			rb_work_scheduled;
>  	struct delayed_work	rbdr_work;
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> index 0dd1abf..fa05e34 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> @@ -18,6 +18,15 @@
>  #include "q_struct.h"
>  #include "nicvf_queues.h"
>  
> +static void nicvf_get_page(struct nicvf *nic)
> +{
> +	if (!nic->rb_pageref || !nic->rb_page)
> +		return;
> +
> +	atomic_add(nic->rb_pageref, &nic->rb_page->_count);
> +	nic->rb_pageref = 0;
> +}
> +
>  /* Poll a register for a specific value */
>  static int nicvf_poll_reg(struct nicvf *nic, int qidx,
>  			  u64 reg, int bit_pos, int bits, int val)
> @@ -81,16 +90,15 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, gfp_t gfp,
>  	int order = (PAGE_SIZE <= 4096) ?  PAGE_ALLOC_COSTLY_ORDER : 0;
>  
>  	/* Check if request can be accomodated in previous allocated page */
> -	if (nic->rb_page) {
> -		if ((nic->rb_page_offset + buf_len + buf_len) >
> -		    (PAGE_SIZE << order)) {
> -			nic->rb_page = NULL;
> -		} else {
> -			nic->rb_page_offset += buf_len;
> -			get_page(nic->rb_page);
> -		}
> +	if (nic->rb_page &&
> +	    ((nic->rb_page_offset + buf_len) < (PAGE_SIZE << order))) {
> +		nic->rb_pageref++;
> +		goto ret;
>  	}

I do not see how this can sanely work.

By deferring the atomic increment of the page count, you create a window of
time during which the consumer can release the page and prematurely free it.

I'm not applying this, as it looks extremely buggy.  Sorry.
