From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Thu, 18 Dec 2008 09:04:14 +0000
Message-ID: <20081218090414.GB8416@ff.dom.local>
References: <20081211181528.GB10558@hmsendeavour.rdu.redhat.com> <20081211160307.20709435@s6510> <20081212121835.GA2402@hmsreliant.think-freely.org> <20081216.155540.34452478.davem@davemloft.net> <20081217211628.GD7356@hmsreliant.think-freely.org> <20081217133131.44a4f67f@extreme> <20081218011306.GA32191@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:59394 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbYLRJEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 04:04:22 -0500
Received: by ewy10 with SMTP id 10so354272ewy.13
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 01:04:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081218011306.GA32191@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 08:13:06PM -0500, Neil Horman wrote:
...
> Since we migrated the napi polling infrastructure out of the net_device
> structure, the netif_rx_[prep|schedule|complete] api has taken a net_device
> structure pointer, which in all cases goes unused.  This patch modifies the api
> to remove that parameter, and fixes up all the required call sites.
> 
> I've obviously not tested it with all available NICS, but I built an
> allmodconfig sucessfully with no errors introduced, and booted a kernel with
> htis change on a few systems.
> 
> Regards
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
...
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e26f549..d2f692d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1444,8 +1444,7 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
>  }
>  
>  /* Test if receive needs to be scheduled but only if up */
> -static inline int netif_rx_schedule_prep(struct net_device *dev,
> -					 struct napi_struct *napi)
> +static inline int netif_rx_schedule_prep(struct napi_struct *napi)
>  {
>  	return napi_schedule_prep(napi);
>  }
> @@ -1453,27 +1452,24 @@ static inline int netif_rx_schedule_prep(struct net_device *dev,
>  /* Add interface to tail of rx poll list. This assumes that _prep has
>   * already been called and returned 1.
>   */
> -static inline void __netif_rx_schedule(struct net_device *dev,
> -				       struct napi_struct *napi)
> +static inline void __netif_rx_schedule(struct napi_struct *napi)
>  {
>  	__napi_schedule(napi);
>  }

My proposal is to remove this duplication (in another patch/patches) by
renaming __napi_schedule() to __netif_rx_schedule() etc. (__netif_rx
instead of __napi as much as possible).

Jarek P.

>  
>  /* Try to reschedule poll. Called by irq handler. */
>  
> -static inline void netif_rx_schedule(struct net_device *dev,
> -				     struct napi_struct *napi)
> +static inline void netif_rx_schedule(struct napi_struct *napi)
>  {
> -	if (netif_rx_schedule_prep(dev, napi))
> -		__netif_rx_schedule(dev, napi);
> +	if (netif_rx_schedule_prep(napi))
> +		__netif_rx_schedule(napi);
>  }
>  
>  /* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().  */
> -static inline int netif_rx_reschedule(struct net_device *dev,
> -				      struct napi_struct *napi)
> +static inline int netif_rx_reschedule(struct napi_struct *napi)
>  {
>  	if (napi_schedule_prep(napi)) {
> -		__netif_rx_schedule(dev, napi);
> +		__netif_rx_schedule(napi);
>  		return 1;
>  	}
>  	return 0;
> @@ -1482,8 +1478,7 @@ static inline int netif_rx_reschedule(struct net_device *dev,
>  /* same as netif_rx_complete, except that local_irq_save(flags)
>   * has already been issued
>   */
> -static inline void __netif_rx_complete(struct net_device *dev,
> -				       struct napi_struct *napi)
> +static inline void __netif_rx_complete(struct napi_struct *napi)
>  {
>  	__napi_complete(napi);
>  }
> @@ -1493,8 +1488,7 @@ static inline void __netif_rx_complete(struct net_device *dev,
>   * it completes the work. The device cannot be out of poll list at this
>   * moment, it is BUG().
>   */
> -static inline void netif_rx_complete(struct net_device *dev,
> -				     struct napi_struct *napi)
> +static inline void netif_rx_complete(struct napi_struct *napi)
>  {
>  	unsigned long flags;
>  
> @@ -1505,7 +1499,7 @@ static inline void netif_rx_complete(struct net_device *dev,
>  	if (unlikely(test_bit(NAPI_STATE_NPSVC, &napi->state)))
>  		return;
>  	local_irq_save(flags);
> -	__netif_rx_complete(dev, napi);
> +	__netif_rx_complete(napi);
>  	local_irq_restore(flags);
>  }
>  
> -- 
> /****************************************************
>  * Neil Horman <nhorman@tuxdriver.com>
>  * Software Engineer, Red Hat
>  ****************************************************/
