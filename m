From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/macb: Use non-coherent memory for rx buffers
Date: Mon, 26 Nov 2012 11:44:03 +0100
Message-ID: <50B347F3.7050109@atmel.com>
References: <1353678601-26888-1-git-send-email-nicolas.ferre@atmel.com> <CAGhQ9VwWmP_B17LnAEqDHcL8Yd-s0C-Bf35z3+=vnJmK_NoCSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Havard Skinnemoen <havard@skinnemoen.net>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGhQ9VwWmP_B17LnAEqDHcL8Yd-s0C-Bf35z3+=vnJmK_NoCSw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/23/2012 05:12 PM, Joachim Eastwood :
> Hi Nicolas,
> 
> On 23 November 2012 14:50, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
>> From: Havard Skinnemoen <havard@skinnemoen.net>
>>
>> Allocate regular pages to use as backing for the RX ring and use the
>> DMA API to sync the caches. This should give a bit better performance
>> since it allows the CPU to do burst transfers from memory. It is also
>> a necessary step on the way to reduce the amount of copying done by
>> the driver.
>>
>> Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
>> [nicolas.ferre@atmel.com: adapt to newer kernel]
>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 206 +++++++++++++++++++++++-------------
>>  drivers/net/ethernet/cadence/macb.h |  20 +++-
>>  2 files changed, 148 insertions(+), 78 deletions(-)
> 
> <snip>
> 
>> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
>> index 570908b..74e68a3 100644
>> --- a/drivers/net/ethernet/cadence/macb.h
>> +++ b/drivers/net/ethernet/cadence/macb.h
>> @@ -453,6 +453,23 @@ struct macb_dma_desc {
>>  #define MACB_TX_USED_SIZE                      1
>>
>>  /**
>> + * struct macb_rx_page - data associated with a page used as RX buffers
>> + * @page: Physical page used as storage for the buffers
>> + * @phys: DMA address of the page
>> + *
>> + * Each page is used to provide %MACB_RX_BUFFERS_PER_PAGE RX buffers.
>> + * The page gets an initial reference when it is inserted into the
>> + * ring, and an additional reference each time it is passed up the
>> + * stack as a fragment. When all the buffers have been used, we drop
>> + * the initial reference and allocate a new page. Any additional
>> + * references are dropped when the higher layers free the skb.
>> + */
>> +struct macb_rx_page {
>> +       struct page             *page;
>> +       dma_addr_t              phys;
>> +};
>> +
>> +/**
>>   * struct macb_tx_skb - data about an skb which is being transmitted
>>   * @skb: skb currently being transmitted
>>   * @mapping: DMA address of the skb's data buffer
>> @@ -543,7 +560,7 @@ struct macb {
>>
>>         unsigned int            rx_tail;
>>         struct macb_dma_desc    *rx_ring;
>> -       void                    *rx_buffers;
>> +       struct macb_rx_page     *rx_page;
>>
>>         unsigned int            tx_head, tx_tail;
>>         struct macb_dma_desc    *tx_ring;
>> @@ -564,7 +581,6 @@ struct macb {
>>
>>         dma_addr_t              rx_ring_dma;
>>         dma_addr_t              tx_ring_dma;
>> -       dma_addr_t              rx_buffers_dma;
>>
>>         struct mii_bus          *mii_bus;
>>         struct phy_device       *phy_dev;
>> --
> 
> struct macb is shared between at91_ether and macb. Removing
> rx_buffers_dma and rx_buffers will break compilation on at91_ether.

OMG, you are absolutely right.

> So please either leave the two struct members alone, for now, or fix
> up at91_ether at the same time.

Well, I do not plan to touch at91_ether driver for the moment, so I
certainly will keep the two struct members for now.

I will wait a little more feedback before sending a v2 patch with these
changes.

Best regards,
-- 
Nicolas Ferre
