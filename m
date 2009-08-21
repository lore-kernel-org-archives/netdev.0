From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC][PATCH] smc91x: let smc91x work well with netpoll
Date: Fri, 21 Aug 2009 13:13:32 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0908211304000.6044@xanadu.home>
References: <1250861616.24178.20.camel@dengdd-desktop>
 <1250862005.24178.28.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jason Wessel <jason.wessel@windriver.com>
To: DDD <Dongdong.deng@windriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932549AbZHURNi@vger.kernel.org>
In-reply-to: <1250862005.24178.28.camel@dengdd-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Aug 2009, DDD wrote:

> This patch changes too much and I didn't have the environment to test, so it is unverified patch.
> That's why I separate it from my previous patch, and send it solely as a RFC patch.
> 
> 
> Hi Nicolas, 
> Given that you are the maintainer of "smc91x" driver since 2004. Could you say somethings about this
> patch? Your input on this patch is greatly appreciated. :-)

Looks fine to me.  The most significant changes affect usage of this 
driver on a SMP system.  I'm afraid those might be hard to find now 
(this network chip is already a strange piece of hardware, and I knew 
about only one platform with it being SMP), so the best I can do is 
review your patch only.

Which I now did and you can add my:

Acked-by: Nicolas Pitre <nico@cam.org>


> Thank you very much,
> Dongdong
> 
> 
> Patch Note:
> @@ -520,21 +522,21
> -       local_irq_disable();                                        \
> +       local_irq_save(flags);                                      \
>         __ret = spin_trylock(lock);                                 \
>         if (!__ret)                                                 \
> -               local_irq_enable();                                 \
> +               local_irq_restore(flags);                           \
> 
> Here, for "__ret = spin_trylock(lock)", I didn't use
> spin_trylock_irqsave() to replace spin_trylock(), because
> the current irq state have got by local_irq_save(flags).
> 
> 
> 
> ---
>  drivers/net/smc91x.c |   40 ++++++++++++++++++++++------------------
>  1 files changed, 22 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index 1c70e99..7cabea1 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -196,21 +196,23 @@ static void PRINT_PKT(u_char *buf, int length)
>  /* this enables an interrupt in the interrupt mask register */
>  #define SMC_ENABLE_INT(lp, x) do {					\
>  	unsigned char mask;						\
> -	spin_lock_irq(&lp->lock);					\
> +	unsigned long smc_enable_flags;					\
> +	spin_lock_irqsave(&lp->lock, smc_int_flags);			\
>  	mask = SMC_GET_INT_MASK(lp);					\
>  	mask |= (x);							\
>  	SMC_SET_INT_MASK(lp, mask);					\
> -	spin_unlock_irq(&lp->lock);					\
> +	spin_unlock_irqrestore(&lp->lock, smc_int_flags);		\
>  } while (0)
>  
>  /* this disables an interrupt from the interrupt mask register */
>  #define SMC_DISABLE_INT(lp, x) do {					\
>  	unsigned char mask;						\
> -	spin_lock_irq(&lp->lock);					\
> +	unsigned long smc_disable_flags;				\
> +	spin_lock_irqsave(&lp->lock, smc_disable_flags);		\
>  	mask = SMC_GET_INT_MASK(lp);					\
>  	mask &= ~(x);							\
>  	SMC_SET_INT_MASK(lp, mask);					\
> -	spin_unlock_irq(&lp->lock);					\
> +	spin_unlock_irqrestore(&lp->lock, smc_disable_flags);		\
>  } while (0)
>  
>  /*
> @@ -520,21 +522,21 @@ static inline void  smc_rcv(struct net_device *dev)
>   * any other concurrent access and C would always interrupt B. But life
>   * isn't that easy in a SMP world...
>   */
> -#define smc_special_trylock(lock)					\
> +#define smc_special_trylock(lock, flags)				\
>  ({									\
>  	int __ret;							\
> -	local_irq_disable();						\
> +	local_irq_save(flags);						\
>  	__ret = spin_trylock(lock);					\
>  	if (!__ret)							\
> -		local_irq_enable();					\
> +		local_irq_restore(flags);				\
>  	__ret;								\
>  })
> -#define smc_special_lock(lock)		spin_lock_irq(lock)
> -#define smc_special_unlock(lock)	spin_unlock_irq(lock)
> +#define smc_special_lock(lock, flags)		spin_lock_irq(lock, flags)
> +#define smc_special_unlock(lock, flags) 	spin_unlock_irqrestore(lock, flags)
>  #else
> -#define smc_special_trylock(lock)	(1)
> -#define smc_special_lock(lock)		do { } while (0)
> -#define smc_special_unlock(lock)	do { } while (0)
> +#define smc_special_trylock(lock, flags)	(1)
> +#define smc_special_lock(lock, flags)   	do { } while (0)
> +#define smc_special_unlock(lock, flags)	do { } while (0)
>  #endif
>  
>  /*
> @@ -548,10 +550,11 @@ static void smc_hardware_send_pkt(unsigned long data)
>  	struct sk_buff *skb;
>  	unsigned int packet_no, len;
>  	unsigned char *buf;
> +	unsigned long flags;
>  
>  	DBG(3, "%s: %s\n", dev->name, __func__);
>  
> -	if (!smc_special_trylock(&lp->lock)) {
> +	if (!smc_special_trylock(&lp->lock, flags)) {
>  		netif_stop_queue(dev);
>  		tasklet_schedule(&lp->tx_task);
>  		return;
> @@ -559,7 +562,7 @@ static void smc_hardware_send_pkt(unsigned long data)
>  
>  	skb = lp->pending_tx_skb;
>  	if (unlikely(!skb)) {
> -		smc_special_unlock(&lp->lock);
> +		smc_special_unlock(&lp->lock, flags);
>  		return;
>  	}
>  	lp->pending_tx_skb = NULL;
> @@ -569,7 +572,7 @@ static void smc_hardware_send_pkt(unsigned long data)
>  		printk("%s: Memory allocation failed.\n", dev->name);
>  		dev->stats.tx_errors++;
>  		dev->stats.tx_fifo_errors++;
> -		smc_special_unlock(&lp->lock);
> +		smc_special_unlock(&lp->lock, flags);
>  		goto done;
>  	}
>  
> @@ -608,7 +611,7 @@ static void smc_hardware_send_pkt(unsigned long data)
>  
>  	/* queue the packet for TX */
>  	SMC_SET_MMU_CMD(lp, MC_ENQUEUE);
> -	smc_special_unlock(&lp->lock);
> +	smc_special_unlock(&lp->lock, flags);
>  
>  	dev->trans_start = jiffies;
>  	dev->stats.tx_packets++;
> @@ -633,6 +636,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct smc_local *lp = netdev_priv(dev);
>  	void __iomem *ioaddr = lp->base;
>  	unsigned int numPages, poll_count, status;
> +	unsigned long flags;
>  
>  	DBG(3, "%s: %s\n", dev->name, __func__);
>  
> @@ -658,7 +662,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		return 0;
>  	}
>  
> -	smc_special_lock(&lp->lock);
> +	smc_special_lock(&lp->lock, flags);
>  
>  	/* now, try to allocate the memory */
>  	SMC_SET_MMU_CMD(lp, MC_ALLOC | numPages);
> @@ -676,7 +680,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		}
>     	} while (--poll_count);
>  
> -	smc_special_unlock(&lp->lock);
> +	smc_special_unlock(&lp->lock, flags);
>  
>  	lp->pending_tx_skb = skb;
>     	if (!poll_count) {
> -- 
> 1.6.0.4
> 
> 
