From: Oliver Neukum <oneukum@suse.com>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Tue, 21 Jul 2015 14:04:03 +0200
Message-ID: <1437480243.3823.5.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55AD3A41.2040100@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-07-20 at 21:13 +0300, Eugene Shatokhin wrote:
> Hi,
> 
> I have recently found several data races in "usbnet" module, checked on 
> vanilla kernel 4.1.0 on x86_64. The races do actually happen, I have 
> confirmed it by adding delays and using hardware breakpoints to detect 
> the conflicting memory accesses (with RaceHound tool, 
> https://github.com/winnukem/racehound).
> 
> I have not analyzed yet how harmful these races are (if they are), but 
> it is better to report them anyway, I think.
> 
> Everything was checked using YOTA 4G LTE Modem that works via "usbnet" 
> and "cdc_ether" kernel modules.
> --------------------------
> 
> [Race #1]
> 
> Race on skb_queue ('next' pointer) between usbnet_stop() and rx_complete().
> 
> Reproduced that by unplugging the device while the system was 
> downloading a large file from the Net.
> 
> Here is part of the call stack with the code where the changes to the 
> queue happen:
> 
> #0 __skb_unlink (skbuff.h:1517)	
> 	prev->next = next;
> #1 defer_bh (usbnet.c:430)
> 	spin_lock_irqsave(&list->lock, flags);
> 	old_state = entry->state;
> 	entry->state = state;
> 	__skb_unlink(skb, list);
> 	spin_unlock(&list->lock);
> 	spin_lock(&dev->done.lock);
> 	__skb_queue_tail(&dev->done, skb);
> 	if (dev->done.qlen == 1)
> 		tasklet_schedule(&dev->bh);
> 	spin_unlock_irqrestore(&dev->done.lock, flags);
> #2 rx_complete (usbnet.c:640)
> 	state = defer_bh(dev, skb, &dev->rxq, state);
> 
> At the same time, the following code repeatedly checks if the queue is 
> empty and reads the same values concurrently with the above changes:
> 
> #0  usbnet_terminate_urbs (usbnet.c:765)
> 	/* maybe wait for deletions to finish. */
> 	while (!skb_queue_empty(&dev->rxq)
> 		&& !skb_queue_empty(&dev->txq)
> 		&& !skb_queue_empty(&dev->done)) {
> 			schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
> 			set_current_state(TASK_UNINTERRUPTIBLE);
> 			netif_dbg(dev, ifdown, dev->net,
> 				  "waited for %d urb completions\n", temp);
> 	}
> #1  usbnet_stop (usbnet.c:806)
> 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
> 		usbnet_terminate_urbs(dev);
> 
> For example, it is possible that the skb is removed from dev->rxq by 
> __skb_unlink() before the check "!skb_queue_empty(&dev->rxq)" in 
> usbnet_terminate_urbs() is made. It is also possible in this case that 
> the skb is added to dev->done queue after "!skb_queue_empty(&dev->done)" 
> is checked. So usbnet_terminate_urbs() may stop waiting and return while 
> dev->done queue still has an item.

Hi,

your analysis is correct and it looks like in addition to your proposed
fix locking needs to be simplified and a common lock to be taken.
Suggestions?

	Regards
		Oliver
