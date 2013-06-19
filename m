From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next rfc 1/3] net: avoid high order memory allocation for
 queues by using flex array
Date: Tue, 18 Jun 2013 23:31:58 -0700
Message-ID: <1371623518.3252.267.camel@edumazet-glaptop>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
	 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, hkchu@google.com,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371620452-49349-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 13:40 +0800, Jason Wang wrote:
> Currently, we use kcalloc to allocate rx/tx queues for a net device which could
> be easily lead to a high order memory allocation request when initializing a
> multiqueue net device. We can simply avoid this by switching to use flex array
> which always allocate at order zero.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  include/linux/netdevice.h |   13 ++++++----
>  net/core/dev.c            |   57 ++++++++++++++++++++++++++++++++------------
>  net/core/net-sysfs.c      |   15 +++++++----
>  3 files changed, 58 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 09b4188..c0b5d04 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -32,6 +32,7 @@
>  #include <linux/atomic.h>
>  #include <asm/cache.h>
>  #include <asm/byteorder.h>
> +#include <linux/flex_array.h>
>  
>  #include <linux/percpu.h>
>  #include <linux/rculist.h>
> @@ -1230,7 +1231,7 @@ struct net_device {
>  
> 
>  #ifdef CONFIG_RPS
> -	struct netdev_rx_queue	*_rx;
> +	struct flex_array	*_rx;
>  
>  	/* Number of RX queues allocated at register_netdev() time */
>  	unsigned int		num_rx_queues;
> @@ -1250,7 +1251,7 @@ struct net_device {
>  /*
>   * Cache lines mostly used on transmit path
>   */
> -	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
> +	struct flex_array	*_tx ____cacheline_aligned_in_smp;
>  

Using flex_array and adding overhead in this super critical part of
network stack, only to avoid order-1 allocations done in GFP_KERNEL
context is simply insane.

We can revisit this in 2050 if we ever need order-4 allocations or so,
and still use 4K pages.
