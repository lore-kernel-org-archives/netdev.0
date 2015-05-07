From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: deinline netif_tx_stop_queue() and netif_tx_stop_all_queues()
Date: Thu, 07 May 2015 10:14:42 -0700
Message-ID: <554B9D82.80101@gmail.com>
References: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36717 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbbEGROo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 13:14:44 -0400
In-Reply-To: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2015 04:41 AM, Denys Vlasenko wrote:
> These functions compile to ~60 bytes of machine code each.
>
> With this .config: http://busybox.net/~vda/kernel_config
> there are 617 calls to netif_tx_stop_queue()
> and 49 calls to netif_tx_stop_all_queues() in vmlinux.
>
> Code size is reduced by 27 kbytes:
>
>      text     data      bss       dec     hex filename
> 82426986 22255416 20627456 125309858 77813a2 vmlinux.before
> 82399481 22255416 20627456 125282353 777a831 vmlinux
>
> It may seem strange that a seemingly simple code like one in
> netif_tx_stop_queue() compiles to ~60 bytes of code.
> Well, it's true. Here's its disassembly:
>
>      netif_tx_stop_queue:
>         e8 b0 15 4d 00          callq  <__fentry__>

This bit was added because you converted this to a function.

>         48 85 ff                test   %rdi,%rdi
>         75 25                   jne    <netif_tx_stop_queue+0x2f>

This bit is your WARN_ON test

>         55                      push   %rbp
>         be 7a 18 00 00          mov    $0x187a,%esi
>         48 c7 c7 50 59 d8 85    mov    $.rodata+0x1d85950,%rdi
>         48 89 e5                mov    %rsp,%rbp
>         e8 54 5a 7d fd          callq  <warn_slowpath_null>
>         48 c7 c7 5f 59 d8 85    mov    $.rodata+0x1d8595f,%rdi
>         31 c0                   xor    %eax,%eax
>         e8 b0 47 48 00          callq  <printk>
>         eb 09                   jmp    <netif_tx_stop_queue+0x38>

This is the WARN_ON action.  One thing you might try doing is moving 
this to a function of its own instead of moving the entire thing out of 
being an inline.  You may find you still get most of the space savings 
as I wonder if the string for the printk isn't being duplicated for each 
caller.

>         f0 80 8f e0 01 00 00 01 lock orb $0x1,0x1e0(%rdi)

This is your set bit operation.  If you were to drop the whole WARN_ON 
then this is the only thing you would be inlining.  That is only 8 bytes 
in size which would probably be comparable to the callq and register 
sorting needed for a function call.

>         c3                      retq
>         5d                      pop    %rbp
>         c3                      retq

The rest of this is just more function overhead, one return for your 
standard path, and  a pop and a return for the WARN_ON path.

>
> This causes gcc to auto-deinline it before this patch, but with 203 separate
> copies in each module which uses this function:
>
> $ nm --size-sort vmlinux.before | grep -e ' netif_tx_stop_queue$' | wc -l
> 203
>
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Jiri Pirko <jpirko@redhat.com>
> CC: linux-kernel@vger.kernel.org
> CC: netdev@vger.kernel.org
> CC: netfilter-devel@vger.kernel.org
> ---

Have you done any performance testing on this change?  I suspect there 
will likely be a noticeable impact some some tests.

>   include/linux/netdevice.h | 19 ++-----------------
>   net/core/dev.c            | 21 +++++++++++++++++++++
>   2 files changed, 23 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index dcf6ec2..f650d16 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2546,14 +2546,7 @@ static inline void netif_tx_wake_all_queues(struct net_device *dev)
>   	}
>   }
>   
> -static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
> -{
> -	if (WARN_ON(!dev_queue)) {
> -		pr_info("netif_stop_queue() cannot be called before register_netdev()\n");
> -		return;
> -	}
> -	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
> -}
> +void netif_tx_stop_queue(struct netdev_queue *dev_queue);

It looks to me like most of the overhead for this function is the 
WARN_ON.  Without that function would just be the "lock orb".

The question I would have is why do we need the WARN_ON?  Why not let 
any drivers that call netif_stop_queue before the netdev is registered 
take the NULL pointer dereference?  The would likely learn real quick 
not to do that and a NULL pointer deference is fairly easy to debug.  
You could probably even just replace the WARN_ON with a comment that if 
you get a NULL pointer dereference here you probably called it before 
register_netdev.

>   
>   /**
>    *	netif_stop_queue - stop transmitted packets
> @@ -2567,15 +2560,7 @@ static inline void netif_stop_queue(struct net_device *dev)
>   	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
>   }
>   
> -static inline void netif_tx_stop_all_queues(struct net_device *dev)
> -{
> -	unsigned int i;
> -
> -	for (i = 0; i < dev->num_tx_queues; i++) {
> -		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		netif_tx_stop_queue(txq);
> -	}
> -}
> +void netif_tx_stop_all_queues(struct net_device *dev);
>   
>   static inline bool netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
>   {

This is usually slow path for most device drivers so it should fine to 
uninline.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 962ee9d..569031f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6261,6 +6261,27 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
>   	return 0;
>   }
>   
> +void netif_tx_stop_queue(struct netdev_queue *dev_queue)
> +{
> +	if (WARN_ON(!dev_queue)) {
> +		pr_info("netif_stop_queue() cannot be called before register_netdev()\n");
> +		return;
> +	}
> +	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
> +}
> +EXPORT_SYMBOL(netif_tx_stop_queue);
> +

One thing I noticed on reviewing the assembly above was that you should 
probably wrap the !dev_queue check in an unlikely.  It would save you 
some unnecessary jumps instructions.

> +void netif_tx_stop_all_queues(struct net_device *dev)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < dev->num_tx_queues; i++) {
> +		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> +		netif_tx_stop_queue(txq);
> +	}
> +}
> +EXPORT_SYMBOL(netif_tx_stop_all_queues);
> +
>   /**
>    *	register_netdevice	- register a network device
>    *	@dev: device to register
