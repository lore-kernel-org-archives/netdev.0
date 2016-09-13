From: Tariq Toukan via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 03/11] net/mlx5e: Implement RX mapped
 page cache for page recycle
Date: Tue, 13 Sep 2016 13:16:29 +0300
Message-ID: <549ee0e2-b76b-ec62-4287-e63c4320e7c6@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-4-git-send-email-saeedm@mellanox.com>
	<20160907204501.08cc4ede@redhat.com>
Reply-To: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Eric
	Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Saeed Mahameed
	<saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160907204501.08cc4ede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org


On 07/09/2016 9:45 PM, Jesper Dangaard Brouer wrote:
> On Wed,  7 Sep 2016 15:42:24 +0300 Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>
>> From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>
>> Instead of reallocating and mapping pages for RX data-path,
>> recycle already used pages in a per ring cache.
>>
>> We ran pktgen single-stream benchmarks, with iptables-raw-drop:
>>
>> Single stride, 64 bytes:
>> * 4,739,057 - baseline
>> * 4,749,550 - order0 no cache
>> * 4,786,899 - order0 with cache
>> 1% gain
>>
>> Larger packets, no page cross, 1024 bytes:
>> * 3,982,361 - baseline
>> * 3,845,682 - order0 no cache
>> * 4,127,852 - order0 with cache
>> 3.7% gain
>>
>> Larger packets, every 3rd packet crosses a page, 1500 bytes:
>> * 3,731,189 - baseline
>> * 3,579,414 - order0 no cache
>> * 3,931,708 - order0 with cache
>> 5.4% gain
>>
>> Signed-off-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> ---
>>   drivers/net/ethernet/mellanox/mlx5/core/en.h       | 16 ++++++
>>   drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 15 ++++++
>>   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 57 ++++++++++++++++++++--
>>   drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 16 ++++++
>>   4 files changed, 99 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
>> index 075cdfc..afbdf70 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
>> @@ -287,6 +287,18 @@ struct mlx5e_rx_am { /* Adaptive Moderation */
>>   	u8					tired;
>>   };
>>   
>> +/* a single cache unit is capable to serve one napi call (for non-striding rq)
>> + * or a MPWQE (for striding rq).
>> + */
>> +#define MLX5E_CACHE_UNIT	(MLX5_MPWRQ_PAGES_PER_WQE > NAPI_POLL_WEIGHT ? \
>> +				 MLX5_MPWRQ_PAGES_PER_WQE : NAPI_POLL_WEIGHT)
>> +#define MLX5E_CACHE_SIZE	(2 * roundup_pow_of_two(MLX5E_CACHE_UNIT))
>> +struct mlx5e_page_cache {
>> +	u32 head;
>> +	u32 tail;
>> +	struct mlx5e_dma_info page_cache[MLX5E_CACHE_SIZE];
>> +};
>> +
> [...]
>>   
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> index c1cb510..8e02af3 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> @@ -305,11 +305,55 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
>>   	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
>>   }
>>   
>> +static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
>> +				      struct mlx5e_dma_info *dma_info)
>> +{
>> +	struct mlx5e_page_cache *cache = &rq->page_cache;
>> +	u32 tail_next = (cache->tail + 1) & (MLX5E_CACHE_SIZE - 1);
>> +
>> +	if (tail_next == cache->head) {
>> +		rq->stats.cache_full++;
>> +		return false;
>> +	}
>> +
>> +	cache->page_cache[cache->tail] = *dma_info;
>> +	cache->tail = tail_next;
>> +	return true;
>> +}
>> +
>> +static inline bool mlx5e_rx_cache_get(struct mlx5e_rq *rq,
>> +				      struct mlx5e_dma_info *dma_info)
>> +{
>> +	struct mlx5e_page_cache *cache = &rq->page_cache;
>> +
>> +	if (unlikely(cache->head == cache->tail)) {
>> +		rq->stats.cache_empty++;
>> +		return false;
>> +	}
>> +
>> +	if (page_ref_count(cache->page_cache[cache->head].page) != 1) {
>> +		rq->stats.cache_busy++;
>> +		return false;
>> +	}
> Hmmm... doesn't this cause "blocking" of the page_cache recycle
> facility until the page at the head of the queue gets (page) refcnt
> decremented?  Real use-case could fairly easily block/cause this...
Hi Jesper,

That's right. We are aware of this issue.
We considered ways of solving this, but decided to keep current 
implementation for now.
One way of solving this is to look deeper in the cache.
Cons:
- this will consume time, and the chance of finding an available page is 
not that high: if the page in head of queue is busy then there's a good 
chance that all the others are too (because of FIFO).
in other words, you already checked all pages and anyway you're going to 
allocate a new one (higher penalty for same decision).
- this will make holes in the array causing complex accounting when 
looking for an available page (this can easily be fixed by swapping 
between the page in head and the available one).

Another way is sharing pages between different RQs.
- For now we're not doing this for simplicity and to keep 
synchronization away.

What do you think?

Anyway, we're looking forward to use your page-pool API which solves 
these issues.

Regards,
Tariq
>
>> +
>> +	*dma_info = cache->page_cache[cache->head];
>> +	cache->head = (cache->head + 1) & (MLX5E_CACHE_SIZE - 1);
>> +	rq->stats.cache_reuse++;
>> +
>> +	dma_sync_single_for_device(rq->pdev, dma_info->addr, PAGE_SIZE,
>> +				   DMA_FROM_DEVICE);
>> +	return true;
>> +}
>> +
>>   static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
>>   					  struct mlx5e_dma_info *dma_info)
>>   {
>> -	struct page *page = dev_alloc_page();
>> +	struct page *page;
>> +
>> +	if (mlx5e_rx_cache_get(rq, dma_info))
>> +		return 0;
>>   
>> +	page = dev_alloc_page();
>>   	if (unlikely(!page))
>>   		return -ENOMEM;
