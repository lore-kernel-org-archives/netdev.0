From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: Page allocator order-0 optimizations merged
Date: Sun, 26 Mar 2017 11:21:37 +0300
Message-ID: <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <20170301144845.783f8cad@redhat.com>
 <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
 <20170322234004.kffsce4owewgpqnm@techsingularity.net>
 <20170323144347.1e6f29de@redhat.com>
 <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <tariqt@mellanox.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
 Saeed Mahameed <saeedm@mellanox.com>
To: Mel Gorman <mgorman@techsingularity.net>,
 Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org



On 23/03/2017 4:51 PM, Mel Gorman wrote:
> On Thu, Mar 23, 2017 at 02:43:47PM +0100, Jesper Dangaard Brouer wrote:
>> On Wed, 22 Mar 2017 23:40:04 +0000
>> Mel Gorman <mgorman@techsingularity.net> wrote:
>>
>>> On Wed, Mar 22, 2017 at 07:39:17PM +0200, Tariq Toukan wrote:
>>>>>>> This modification may slow allocations from IRQ context slightly
>>>>>>> but the
>>>>>>> main gain from the per-cpu allocator is that it scales better for
>>>>>>> allocations from multiple contexts.  There is an implicit
>>>>>>> assumption that
>>>>>>> intensive allocations from IRQ contexts on multiple CPUs from a single
>>>>>>> NUMA node are rare
>>>> Hi Mel, Jesper, and all.
>>>>
>>>> This assumption contradicts regular multi-stream traffic that is naturally
>>>> handled
>>>> over close numa cores.  I compared iperf TCP multistream (8 streams)
>>>> over CX4 (mlx5 driver) with kernels v4.10 (before this series) vs
>>>> kernel v4.11-rc1 (with this series).
>>>> I disabled the page-cache (recycle) mechanism to stress the page allocator,
>>>> and see a drastic degradation in BW, from 47.5 G in v4.10 to 31.4 G in
>>>> v4.11-rc1 (34% drop).
>>>> I noticed queued_spin_lock_slowpath occupies 62.87% of CPU time.
>>>
>>> Can you get the stack trace for the spin lock slowpath to confirm it's
>>> from IRQ context?
>>
>> AFAIK allocations happen in softirq.  Argh and during review I missed
>> that in_interrupt() also covers softirq.  To Mel, can we use a in_irq()
>> check instead?
>>
>> (p.s. just landed and got home)

Glad to hear. Thanks for your suggestion.

>
> Not built or even boot tested. I'm unable to run tests at the moment

Thanks Mel, I will test it soon.

>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6cbde310abed..f82225725bc1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2481,7 +2481,7 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>
> -	if (in_interrupt()) {
> +	if (in_irq()) {
>  		__free_pages_ok(page, 0);
>  		return;
>  	}
> @@ -2647,7 +2647,7 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
>  {
>  	struct page *page;
>
> -	VM_BUG_ON(in_interrupt());
> +	VM_BUG_ON(in_irq());
>
>  	do {
>  		if (list_empty(list)) {
> @@ -2704,7 +2704,7 @@ struct page *rmqueue(struct zone *preferred_zone,
>  	unsigned long flags;
>  	struct page *page;
>
> -	if (likely(order == 0) && !in_interrupt()) {
> +	if (likely(order == 0) && !in_irq()) {
>  		page = rmqueue_pcplist(preferred_zone, zone, order,
>  				gfp_flags, migratetype);
>  		goto out;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
