From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch: Backport of link state notification to 2.4.20
Date: Tue, 03 Dec 2002 19:43:32 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DED4FB4.5070700@pobox.com>
References: <3DD2D204.C9B7FA2D@isg.de> <3DED302A.E3DEB585@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DED302A.E3DEB585@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:
> Hi David,
> 
> attached is the recent backport of link state notification for the
> stable kernel series. The feature is optional and can be configured away
> to nothing, and tested on several systems.
> 

It might be a backport, but I haven't seen a 2.5.x version posted in a 
while.  If this is going into the stable series, it should already be 
merged in 2.5.x at the same time, if not first.


> I'd really like to have it in 2.4.21, and as your the one to decide
> before Marcelo gets it, can you have a look?

s/before/if/   :)

comments follow.  note these are all minor objections:  I think the 
patch needs revising, but I also think it is ok overall and support its 
eventual inclusion [after tidying].  Not that my opinion matters much 
here compared to DaveM's (and Jamal's and Alexey's and...)...

overall, I have one question:  how does netdev_state_change(dev) 
propagate link status to userspace?  Via the IFF_RUNNING flag's 
presence/absence when IFF_UP is true?



> diff -uNr linux-2.4.20rc1/include/linux/netdevice.h linux/include/linux/netdevice.h
> --- linux-2.4.20rc1/include/linux/netdevice.h	2002-11-05 00:31:42.000000000 +0100
> +++ linux/include/linux/netdevice.h	2002-11-13 22:32:46.000000000 +0100
> @@ -630,6 +631,10 @@
>   * who is responsible for serialization of these calls.
>   */
>  
> +#ifdef CONFIG_LINKWATCH
> +extern void linkwatch_fire_event(struct net_device *dev);
> +#endif


remove the ifdef, not needed and ifdefs are discouraged in all Linux code.




> diff -uNr linux-2.4.20rc1/net/Config.in linux/net/Config.in
> --- linux-2.4.20rc1/net/Config.in	2002-08-03 02:39:46.000000000 +0200
> +++ linux/net/Config.in	2002-11-13 22:32:46.000000000 +0100
> @@ -48,6 +48,7 @@
>              bool '    Per-VC IP filter kludge' CONFIG_ATM_BR2684_IPFILTER
>        fi
>     fi
> +   bool 'Device link state notification (EXPERIMENTAL)' CONFIG_LINKWATCH

ifyou mark it experimental, then it should be
	dep_bool ... CONFIG_LINKWATCH $CONFIG_EXPERIMENTAL



> diff -uNr linux-2.4.20rc1/net/core/Makefile linux/net/core/Makefile
> --- linux-2.4.20rc1/net/core/Makefile	2002-08-03 02:39:46.000000000 +0200
> +++ linux/net/core/Makefile	2002-11-13 22:33:32.000000000 +0100
> @@ -31,4 +31,6 @@
>  # Ugly. I wish all wireless drivers were moved in drivers/net/wireless
>  obj-$(CONFIG_NET_PCMCIA_RADIO) += wireless.o
>  
> +obj-$(CONFIG_LINKWATCH) += link_watch.o
> +
>  include $(TOPDIR)/Rules.make

add it to export-objs too (because of below change)



> diff -uNr linux-2.4.20rc1/net/core/dev.c linux/net/core/dev.c
> --- linux-2.4.20rc1/net/core/dev.c	2002-11-05 00:31:42.000000000 +0100
> +++ linux/net/core/dev.c	2002-11-13 22:32:46.000000000 +0100
> @@ -194,6 +194,12 @@
>  #endif
>  
>  
> +#ifdef CONFIG_LINKWATCH
> +extern void linkwatch_init(void);
> +extern void linkwatch_run_queue(void);
> +#endif


ug :)

the ifdef can be killed, and the prototypes should be in netdevice.h (or 
any other header), not in mainline code.




> @@ -2675,6 +2693,10 @@
>  	dv_init();
>  #endif /* CONFIG_NET_DIVERT */
>  	
> +#ifdef CONFIG_LINKWATCH
> +	linkwatch_init();
> +#endif


no need for an ifdef, make linkwatch_init() a no-op static inline for 
the !CONFIG_LINKWATCH case.




> +static unsigned long linkwatch_flags = 0;
> +static unsigned long linkwatch_nextevent = 0;

statics are automatically initialized to zero, don't do it explicitly. 
you waste a couple bytes in the kernel image storing a zero value.



> +
> +static void linkwatch_event(void *dummy);
> +static void linkwatch_timer(unsigned long dummy);
> +
> +static struct tq_struct linkwatch_tq;
> +static struct timer_list linkwatch_ti;
> +
> +static LIST_HEAD(lweventlist);
> +static spinlock_t lweventlist_lock = SPIN_LOCK_UNLOCKED;

why initialize some complex structs programmatically and some 
explicitly?  IMO for consistency you should initialize lweventlist_lock 
in linkwatch_init().  (or vice versa)


> +/* Must be called with the rtnl semaphore held */
> +void linkwatch_run_queue(void) {
> +	LIST_HEAD(head);
> +	struct list_head *n, *next;
> +
> +	spin_lock_irq(&lweventlist_lock);
> +	list_splice_init(&lweventlist, &head);
> +	spin_unlock_irq(&lweventlist_lock);

spin_lock_irq{save,restore} would probably better serve you here...


> +
> +	list_for_each_safe(n, next, &head) {
> +		struct lw_event *event = list_entry(n, struct lw_event, list);
> +		struct net_device *dev = event->dev;
> +
> +		if (event == &singleevent) {
> +			clear_bit(LW_SE_USED, &linkwatch_flags);
> +		} else {
> +			kfree(event);
> +		}

style: braces not needed


> +
> +		/* We are about to handle this device,
> +		 * so new events can be accepted
> +		 */
> +		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
> +
> +		if (dev->flags & IFF_UP) {
> +			netdev_state_change(dev);
> +		}

likewise.  (pointlessly makes code longer)


> +
> +		dev_put(dev);
> +	}
> +}       
> +
> +
> +static void linkwatch_event(void *dummy)
> +{
> +	/* Limit the number of linkwatch events to one
> +	 * per second so that a runaway driver does not
> +	 * cause a storm of messages on the netlink
> +	 * socket
> +	 */	
> +	linkwatch_nextevent = jiffies + HZ;
> +	clear_bit(LW_RUNNING, &linkwatch_flags);


the high availability folks would prefer a half-second (HZ >> 1).


> +void __init linkwatch_init(void) {
> +	linkwatch_ti.function = linkwatch_timer;
> +	init_timer(&linkwatch_ti);
> +	INIT_TQUEUE(&linkwatch_tq, linkwatch_event, NULL);
> +}


set the timer function after the initialize the timer :)



> +
> diff -uNr linux-2.4.20rc1/net/netsyms.c linux/net/netsyms.c
> --- linux-2.4.20rc1/net/netsyms.c	2002-11-05 00:31:42.000000000 +0100
> +++ linux/net/netsyms.c	2002-11-13 22:33:32.000000000 +0100
> @@ -591,6 +591,10 @@
>  
>  EXPORT_SYMBOL(softnet_data);
>  
> +#ifdef CONFIG_LINKWATCH
> +EXPORT_SYMBOL(linkwatch_fire_event);
> +#endif

move this to link_watch.c so that the featureset is fully encapsulated.

	Jeff
