From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/6] 6lowpan: rework fragment-deleting routine
Date: Mon, 09 Jul 2012 12:53:35 +0200
Message-ID: <1341831215.3265.2523.camel@edumazet-glaptop>
References: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341829351-18485-5-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38594 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab2GIKxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:53:41 -0400
Received: by eeit10 with SMTP id t10so4262582eei.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:53:40 -0700 (PDT)
In-Reply-To: <1341829351-18485-5-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 14:22 +0400, Alexander Smirnov wrote:
> 6lowpan module starts collecting incomming frames and fragments
> right after lowpan_module_init() therefor it will be better to
> clean unfinished fragments in lowpan_cleanup_module() function
> instead of doing it when link goes down.
> 
> Changed spinlocks type to prevent deadlock with expired timer event
> and removed unused one.
> 
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
>  net/ieee802154/6lowpan.c |   28 ++++++++++++++++------------
>  1 files changed, 16 insertions(+), 12 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index b872515..e7de085 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -113,7 +113,6 @@ struct lowpan_dev_record {
>  
>  struct lowpan_fragment {
>  	struct sk_buff		*skb;		/* skb to be assembled */
> -	spinlock_t		lock;		/* concurency lock */
>  	u16			length;		/* length to be assemled */
>  	u32			bytes_rcv;	/* bytes received */
>  	u16			tag;		/* current fragment tag */
> @@ -761,7 +760,7 @@ lowpan_process_data(struct sk_buff *skb)
>  		if ((frame->bytes_rcv == frame->length) &&
>  		     frame->timer.expires > jiffies) {
>  			/* if timer haven't expired - first of all delete it */
> -			del_timer(&frame->timer);
> +			del_timer_sync(&frame->timer);
>  			list_del(&frame->list);
>  			spin_unlock(&flist_lock);
>  
> @@ -1196,19 +1195,9 @@ static void lowpan_dellink(struct net_device *dev, struct list_head *head)
>  	struct lowpan_dev_info *lowpan_dev = lowpan_dev_info(dev);
>  	struct net_device *real_dev = lowpan_dev->real_dev;
>  	struct lowpan_dev_record *entry, *tmp;
> -	struct lowpan_fragment *frame, *tframe;
>  
>  	ASSERT_RTNL();
>  
> -	spin_lock(&flist_lock);
> -	list_for_each_entry_safe(frame, tframe, &lowpan_fragments, list) {
> -		del_timer(&frame->timer);
> -		list_del(&frame->list);
> -		dev_kfree_skb(frame->skb);
> -		kfree(frame);
> -	}
> -	spin_unlock(&flist_lock);
> -
>  	mutex_lock(&lowpan_dev_info(dev)->dev_list_mtx);
>  	list_for_each_entry_safe(entry, tmp, &lowpan_devices, list) {
>  		if (entry->ldev == dev) {
> @@ -1264,9 +1253,24 @@ out:
>  
>  static void __exit lowpan_cleanup_module(void)
>  {
> +	struct lowpan_fragment *frame, *tframe;
> +
>  	lowpan_netlink_fini();
>  
>  	dev_remove_pack(&lowpan_packet_type);
> +
> +	/* Now 6lowpan packet_type is removed, so no new fragments are
> +	 * expected on RX, therefore that's the time to clean incomplete
> +	 * fragments.
> +	 */
> +	spin_lock_bh(&flist_lock);
> +	list_for_each_entry_safe(frame, tframe, &lowpan_fragments, list) {
> +		del_timer_sync(&frame->timer);
> +		list_del(&frame->list);
> +		dev_kfree_skb(frame->skb);
> +		kfree(frame);
> +	}
> +	spin_unlock_bh(&flist_lock);
>  }
>  
>  module_init(lowpan_init_module);

Problem is lowpan_fragment_timer_expired() can race with this code.

del_timer_sync() might block here if lowpan_fragment_timer_expired() is
waiting/spinning for spin_lock(&flist_lock)

You cant call del_timer_sync() holding flist_lock, you should find
another way to solve the problem.

Its explained in kernel/timer.c :

#ifdef CONFIG_SMP
/**
 * del_timer_sync - deactivate a timer and wait for the handler to finish.
 * @timer: the timer to be deactivated
 *
 * This function only differs from del_timer() on SMP: besides deactivating
 * the timer it also makes sure the handler has finished executing on other
 * CPUs.
 *
 * Synchronization rules: Callers must prevent restarting of the timer,
 * otherwise this function is meaningless. It must not be called from
 * interrupt contexts. The caller must not hold locks which would prevent
 * completion of the timer's handler. The timer's handler must not call
 * add_timer_on(). Upon exit the timer is not queued and the handler is
 * not running on any CPU.
 *
 * Note: You must not hold locks that are held in interrupt context
 *   while calling this function. Even if the lock has nothing to do
 *   with the timer in question.  Here's why:
 *
 *    CPU0                             CPU1
 *    ----                             ----
 *                                   <SOFTIRQ>
 *                                   call_timer_fn();
 *                                     base->running_timer = mytimer;
 *  spin_lock_irq(somelock);
 *                                     <IRQ>
 *                                        spin_lock(somelock);
 *  del_timer_sync(mytimer);
 *   while (base->running_timer == mytimer);
 *
 * Now del_timer_sync() will never return and never release somelock.
 * The interrupt on the other CPU is waiting to grab somelock but
 * it has interrupted the softirq that CPU0 is waiting to finish.
 *
 * The function returns whether it has deactivated a pending timer or not.
 */
