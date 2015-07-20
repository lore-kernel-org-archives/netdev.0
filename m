From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Several races in "usbnet" module (kernel 4.1.x)
Date: Mon, 20 Jul 2015 21:13:21 +0300
Message-ID: <55AD3A41.2040100@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have recently found several data races in "usbnet" module, checked on 
vanilla kernel 4.1.0 on x86_64. The races do actually happen, I have 
confirmed it by adding delays and using hardware breakpoints to detect 
the conflicting memory accesses (with RaceHound tool, 
https://github.com/winnukem/racehound).

I have not analyzed yet how harmful these races are (if they are), but 
it is better to report them anyway, I think.

Everything was checked using YOTA 4G LTE Modem that works via "usbnet" 
and "cdc_ether" kernel modules.
--------------------------

[Race #1]

Race on skb_queue ('next' pointer) between usbnet_stop() and rx_complete().

Reproduced that by unplugging the device while the system was 
downloading a large file from the Net.

Here is part of the call stack with the code where the changes to the 
queue happen:

#0 __skb_unlink (skbuff.h:1517)	
	prev->next = next;
#1 defer_bh (usbnet.c:430)
	spin_lock_irqsave(&list->lock, flags);
	old_state = entry->state;
	entry->state = state;
	__skb_unlink(skb, list);
	spin_unlock(&list->lock);
	spin_lock(&dev->done.lock);
	__skb_queue_tail(&dev->done, skb);
	if (dev->done.qlen == 1)
		tasklet_schedule(&dev->bh);
	spin_unlock_irqrestore(&dev->done.lock, flags);
#2 rx_complete (usbnet.c:640)
	state = defer_bh(dev, skb, &dev->rxq, state);

At the same time, the following code repeatedly checks if the queue is 
empty and reads the same values concurrently with the above changes:

#0  usbnet_terminate_urbs (usbnet.c:765)
	/* maybe wait for deletions to finish. */
	while (!skb_queue_empty(&dev->rxq)
		&& !skb_queue_empty(&dev->txq)
		&& !skb_queue_empty(&dev->done)) {
			schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
			set_current_state(TASK_UNINTERRUPTIBLE);
			netif_dbg(dev, ifdown, dev->net,
				  "waited for %d urb completions\n", temp);
	}
#1  usbnet_stop (usbnet.c:806)
	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
		usbnet_terminate_urbs(dev);

For example, it is possible that the skb is removed from dev->rxq by 
__skb_unlink() before the check "!skb_queue_empty(&dev->rxq)" in 
usbnet_terminate_urbs() is made. It is also possible in this case that 
the skb is added to dev->done queue after "!skb_queue_empty(&dev->done)" 
is checked. So usbnet_terminate_urbs() may stop waiting and return while 
dev->done queue still has an item.
--------------------------

Unrelated the that race, if the goal of that while loop in 
usbnet_terminate_urbs() is to wait till all three queues (dev->rxq, 
dev->txq, dev->done) become empty, perhaps the code should be changed as 
follows:

	while (!skb_queue_empty(&dev->rxq)
-		&& !skb_queue_empty(&dev->txq)
-		&& !skb_queue_empty(&dev->done)) {
+		|| !skb_queue_empty(&dev->txq)
+		|| !skb_queue_empty(&dev->done)) {
			schedule_timeout(...));
--------------------------

[Race #2]

Races on dev->rx_qlen. Reproduced these by repeatedly changing MTU (1500 
<-> 1400) while downloading large files.

dev->rx_qlen is written to here:
#0  usbnet_update_max_qlen (usbnet.c:351)
	case USB_SPEED_HIGH:
		dev->rx_qlen = MAX_QUEUE_MEMORY / dev->rx_urb_size;
#1  __handle_link_change (usbnet.c:1049)
	/* hard_mtu or rx_urb_size may change during link change */
	usbnet_update_max_qlen(dev);
#2  usbnet_deferred_kevent (usbnet.c:1172)
	if (test_bit (EVENT_LINK_CHANGE, &dev->flags))
		__handle_link_change(dev);

Here are the conflicting reads from dev->rx_qlen (via RX_QLEN(dev)), 3 
code locations:

* usbnet_bh (usbnet.c:1492)
	if (temp < RX_QLEN(dev)) { ...
* usbnet_bh (usbnet.c:1499)
	if (dev->rxq.qlen < RX_QLEN(dev)) ...
* rx_alloc_submit (usbnet.c:1431)
	for (i = 0; i < 10 && dev->rxq.qlen < RX_QLEN(dev); i++) { ...
--------------------------

[Race #3]

Similar to race #2 but on dev->tx_qlen. I reproduced it the same way.

dev->tx_qlen is written to here:
#0  usbnet_update_max_qlen (usbnet.c:352)
	case USB_SPEED_HIGH:
		dev->rx_qlen = MAX_QUEUE_MEMORY / dev->rx_urb_size;
		dev->tx_qlen = MAX_QUEUE_MEMORY / dev->hard_mtu;
#1  __handle_link_change (usbnet.c:1049)
	/* hard_mtu or rx_urb_size may change during link change */
	usbnet_update_max_qlen(dev);
#2  usbnet_deferred_kevent (usbnet.c:1172)
	if (test_bit (EVENT_LINK_CHANGE, &dev->flags))
		__handle_link_change(dev);

Here are the conflicting reads from dev->tx_qlen (via TX_QLEN(dev)), 2 
code locations:

* usbnet_bh (usbnet.c:1502)
		if (dev->txq.qlen < TX_QLEN (dev))
			netif_wake_queue (dev->net);
* usbnet_start_xmit (usbnet.c:1398)
		if (dev->txq.qlen >= TX_QLEN (dev))
			netif_stop_queue (net);
--------------------------

[Race #4]

Race on dev->flags. It happened when I unplugged the device while a 
large file was being downloaded.

dev->flags is set to 0 here:

#0  usbnet_stop (usbnet.c:816)
	/* deferred work (task, timer, softirq) must also stop.
	 * can't flush_scheduled_work() until we drop rtnl (later),
	 * else workers could deadlock; so make workers a NOP.
	 */
	dev->flags = 0;
	del_timer_sync (&dev->delay);
	tasklet_kill (&dev->bh);

And here, the code clears EVENT_RX_KILL bit in dev->flags, which may 
execute concurrently with the above operation:
#0 clear_bit (bitops.h:113, inlined)
#1 usbnet_bh (usbnet.c:1475)
	/* restart RX again after disabling due to high error rate */
	clear_bit(EVENT_RX_KILL, &dev->flags);
	
If clear_bit() is atomic w.r.t. setting dev->flags to 0, this race is 
not a problem, I guess. Otherwise, it may be.
--------------------------

[Race #5]

Race on dev->rx_urb_size. I reproduced it a similar way as the races #2 
and #3 (changing MTU while downloading files).

dev->rx_urb_size is written to here:
#0  usbnet_change_mtu (usbnet.c:392)
	dev->rx_urb_size = dev->hard_mtu;

Here is the conflicting read from dev->rx_urb_size:
* rx_submit (usbnet.c:467)
	size_t			size = dev->rx_urb_size;
--------------------------

Regards,
Eugene

-- 
Eugene Shatokhin, ROSA
www.rosalab.com
