From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH 2/2] net: netcp: Allocate RX packet buffers using __GFP_DMA
Date: Wed, 29 Jul 2015 17:22:55 -0400
Message-ID: <55B9442F.6040501@ti.com>
References: <1438182653-2136-1-git-send-email-w-kwok2@ti.com>	 <1438182653-2136-2-git-send-email-w-kwok2@ti.com> <1438203596.20182.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	WingMan Kwok <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438203596.20182.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/29/2015 04:59 PM, Eric Dumazet wrote:
> On Wed, 2015-07-29 at 11:10 -0400, WingMan Kwok wrote:
>> The Keystone II DMA hardware can only access addresses in the
>> lower 2 GiB of SDRAM. This patch makes sure the RX buffers are
>> allocated using the __GFP_DMA flag so they meet this requirement.
>>
>> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
>> Signed-off-by: Reece R. Pollack <x0183204@ti.com>
>> ---
>>   drivers/net/ethernet/ti/netcp_core.c |   11 +++++++----
>>   1 file changed, 7 insertions(+), 4 deletions(-)
>
> Following patch gets rid of netdev_alloc_frag() which is not GFP_DMA
> ready (and wont be)
>
Eric,

Thanks for the suggestion.

I think the original assumption was that kmalloc() always allocate a 
minimum of 1 page for regular or small sized packets. The usage of 
netdev_alloc_frag() is to allocate small sized buffers. However 
kmalloc() can return different size buffers (/proc/slabinfo) and your 
below code should work fine for our driver. We will rework the patch as 
per your suggestion.

Murali

> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
> index 3ca87f26582a..0971c46d6cd5 100644
> --- a/drivers/net/ethernet/ti/netcp_core.c
> +++ b/drivers/net/ethernet/ti/netcp_core.c
> @@ -808,14 +808,8 @@ static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>   		primary_buf_len = SKB_DATA_ALIGN(buf_len) +
>   				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>
> -		if (primary_buf_len <= PAGE_SIZE) {
> -			bufptr = netdev_alloc_frag(primary_buf_len);
> -			pad[1] = primary_buf_len;
> -		} else {
> -			bufptr = kmalloc(primary_buf_len, GFP_ATOMIC |
> -					 GFP_DMA32 | __GFP_COLD);
> -			pad[1] = 0;
> -		}
> +		bufptr = kmalloc(primary_buf_len, GFP_ATOMIC | GFP_DMA);
> +		pad[1] = 0;
>
>   		if (unlikely(!bufptr)) {
>   			dev_warn_ratelimited(netcp->ndev_dev, "Primary RX buffer alloc failed\n");
> @@ -827,7 +821,7 @@ static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>
>   	} else {
>   		/* Allocate a secondary receive queue entry */
> -		page = alloc_page(GFP_ATOMIC | GFP_DMA32 | __GFP_COLD);
> +		page = alloc_page(GFP_ATOMIC | GFP_DMA | __GFP_COLD);
>   		if (unlikely(!page)) {
>   			dev_warn_ratelimited(netcp->ndev_dev, "Secondary page alloc failed\n");
>   			goto fail;
>
>
>
>


-- 
Murali Karicheri
Linux Kernel, Keystone
