From: Tariq Toukan via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 01/11] net/mlx5e: Single flow order-0
 pages for Striding RQ
Date: Thu, 15 Sep 2016 17:28:18 +0300
Message-ID: <375b9772-ca04-3024-dacd-1a7293e2ae3a@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-2-git-send-email-saeedm@mellanox.com>
	<20160907211840.36c37ea0@redhat.com>
Reply-To: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Eric
	Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Saeed Mahameed
	<saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160907211840.36c37ea0-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hi Jesper,


On 07/09/2016 10:18 PM, Jesper Dangaard Brouer wrote:
> On Wed,  7 Sep 2016 15:42:22 +0300 Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>
>> From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>
>> To improve the memory consumption scheme, we omit the flow that
>> demands and splits high-order pages in Striding RQ, and stay
>> with a single Striding RQ flow that uses order-0 pages.
> Thanks you for doing this! MM-list people thanks you!
Thanks. I've just submitted it to net-next.
> For others to understand what this means:  This driver was doing
> split_page() on high-order pages (for Striding RQ).  This was really bad
> because it will cause fragmenting the page-allocator, and depleting the
> high-order pages available quickly.
>
> (I've left rest of patch intact below, if some MM people should be
> interested in looking at the changes).
>
> There is even a funny comment in split_page() relevant to this:
>
> /* [...]
>   * Note: this is probably too low level an operation for use in drivers.
>   * Please consult with lkml before using this in your driver.
>   */
>
>
>> Moving to fragmented memory allows the use of larger MPWQEs,
>> which reduces the number of UMR posts and filler CQEs.
>>
>> Moving to a single flow allows several optimizations that improve
>> performance, especially in production servers where we would
>> anyway fallback to order-0 allocations:
>> - inline functions that were called via function pointers.
>> - improve the UMR post process.
>>
>> This patch alone is expected to give a slight performance reduction.
>> However, the new memory scheme gives the possibility to use a page-cache
>> of a fair size, that doesn't inflate the memory footprint, which will
>> dramatically fix the reduction and even give a huge gain.
>>
>> We ran pktgen single-stream benchmarks, with iptables-raw-drop:
>>
>> Single stride, 64 bytes:
>> * 4,739,057 - baseline
>> * 4,749,550 - this patch
>> no reduction
>>
>> Larger packets, no page cross, 1024 bytes:
>> * 3,982,361 - baseline
>> * 3,845,682 - this patch
>> 3.5% reduction
>>
>> Larger packets, every 3rd packet crosses a page, 1500 bytes:
>> * 3,731,189 - baseline
>> * 3,579,414 - this patch
>> 4% reduction
>>
> Well, the reduction does not really matter than much, because your
> baseline benchmarks are from a freshly booted system, where you have
> not fragmented and depleted the high-order pages yet... ;-)
Indeed. On fragmented systems we'll get a gain, even w/o the page-cache 
mechanism, as no time is wasted looking for high-order-pages.
>
>
>> Fixes: 461017cb006a ("net/mlx5e: Support RX multi-packet WQE (Striding RQ)")
>> Fixes: bc77b240b3c5 ("net/mlx5e: Add fragmented memory support for RX multi packet WQE")
>> Signed-off-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> ---
>>   drivers/net/ethernet/mellanox/mlx5/core/en.h       |  54 ++--
>>   drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 136 ++++++++--
>>   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 292 ++++-----------------
>>   drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   4 -
>>   drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   2 +-
>>   5 files changed, 184 insertions(+), 304 deletions(-)
>>
Regards,
Tariq
