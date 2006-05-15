From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [RFC] changing value of NETDEV_ALIGN to cacheline size
Date: Mon, 15 May 2006 08:02:58 -0700
Message-ID: <20060515080258.bdcfba5f.rdunlap@xenotime.net>
References: <200605151408.29688.borntrae@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:20133 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751470AbWEOPAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 11:00:32 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 15 May 2006 08:00:29 -0700
To: Christian Borntraeger <borntrae@de.ibm.com>
In-Reply-To: <200605151408.29688.borntrae@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006 14:08:29 +0200 Christian Borntraeger wrote:

> while digging through the alloc_netdev function I asked myself why there is a
> fixed alignment for netdevices. Is there a special reason for choosing 32? If
> yes, I suggest to add a comment to the definition. 
> 
> If not, I suspect cacheline alignment might be beneficial:
> struct net_device contains several variables which are cache aligned 
> (poll_list, queue_lock .....). As far as I can see, the compiler tries to 
> increase the size of the structure to make that possible, but expects the
> whole structure to be aligned to cache line size as well. With the current
> value for NETDEV_ALIGN we dont align "struct net_device" to the cache line,
> instead we align it to 32 bytes. That means that poll_list, queue_lock and 
> friends are not always cache aligned, but 32 bytes aligned.
> 
> The only reason why everything worked so far is the slab allocator design, 
> which gives us a page aligned struct net_device in most cases. I think we 
> should not rely on the behaviour of the memory allocator and use a different 
> value for NETDEV_ALIGN instead. Any comments or corrections?
> 
> cheers Christian
> 
> 
> 
> The patch below is compile and boot tested on s390 and x86.
> 
> Signed-off-by: Christian Borntraeger <borntrae@de.ibm.com>
> 
> include/linux/netdevice.h |    2 +-
> net/core/dev.c            |    2 +-
> 2 files changed, 2 insertions(+), 2 deletions(-)
> ----------
> 
> --- a/include/linux/netdevice.h	4 Apr 2006 07:25:47 -0000
> +++ b/include/linux/netdevice.h	15 May 2006 11:06:05 -0000
> @@ -504,7 +504,7 @@
>  	struct class_device	class_dev;
>  };
>  
> -#define	NETDEV_ALIGN		32
> +#define	NETDEV_ALIGN		L1_CACHE_BYTES
>  #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)

I don't know about the fixed value of 32, but if this patch is
accepted, I'd prefer NETDEV_ALIGN_MASK instead of NETDEV_ALIGN_CONST.

>  static inline void *netdev_priv(struct net_device *dev)
> --- a/net/core/dev.c	4 Apr 2006 07:25:50 -0000
> +++ b/net/core/dev.c	15 May 2006 11:06:05 -0000
> @@ -2986,7 +2986,7 @@
>  	struct net_device *dev;
>  	int alloc_size;
>  
> -	/* ensure 32-byte alignment of both the device and private area */
> +	/* ensure cacheline alignment of both the device and private area */
>  	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
>  	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;

---
~Randy
