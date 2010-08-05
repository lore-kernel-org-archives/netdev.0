From: Usha Srinivasan <usha.srinivasan@qlogic.com>
Subject: Receive processing stops when dev->poll returns 1
Date: Thu, 5 Aug 2010 09:20:03 -0500
Message-ID: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FB6@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:34109 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759057Ab0HEOUF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 10:20:05 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I have run into an interesting and frustrating problem which I've not been able to resolve. I am hoping someone can help me.  

I have a network driver which sets its dev->weight to 100 (like ipoib) and when it processes 100 received packets, following the rules, it decrements dev->quota and *budget and returns 1 without calling netif_rx_complete.  When my driver does that, all processing of incoming packets for all interfaces comes to a halt.  

How do I know this?  Because, as soon as my driver returns 1 to dev->poll, I lose my putty session and eth0 stops working; eth0 counters show that it stops receiving packets, though it is able to transmit.  My own device stops receiving packets.  I have scoured the code for ipoib and other network devices and I see no difference in what my driver does.  I have tried to lower weight for ipoib & eth0 hoping to reproduce with those device it but no luck.

One guess is that net_rx_action spent more than 1 tick processing all the incoming packets for all interfaces it polled; I verified that my driver by itself does not spend that much. When this happens, net_rx_action exits after marking NETIF_RX_SOFTIRQ as pending.  So one would expect it to be called again later, but my guess is that doesn't happen thereby resulting in a stoppage of incoming packets. Is that possible and, if so, what is the fix?

1814 static void net_rx_action(struct softirq_action *h)
1815 {
1816         struct softnet_data *queue = &__get_cpu_var(softnet_data);
1817         unsigned long start_time = jiffies;
1818         int budget = netdev_budget;
1819         void *have;
1820 
1821         local_irq_disable();
1822 
1823         while (!list_empty(&queue->poll_list)) {
1824                 struct net_device *dev;
1825 
1826                 if (budget <= 0 || jiffies - start_time > 1)
1827                         goto softnet_break;
1828 
1829                 local_irq_enable();
1830 
1831                 dev = list_entry(queue->poll_list.next,
1832                                  struct net_device, poll_list);
1833                 have = netpoll_poll_lock(dev);
1834 
1835                 if (dev->quota <= 0 || dev->poll(dev, &budget)) {
1836                         netpoll_poll_unlock(have);
1837                         local_irq_disable();
1838                         list_move_tail(&dev->poll_list, &queue->poll_list);
1839                         if (dev->quota < 0)
1840                                 dev->quota += dev->weight;
1841                         else
1842                                 dev->quota = dev->weight;
1843                 } else {
1844                         netpoll_poll_unlock(have);
1845                         dev_put(dev);
1846                         local_irq_disable();
1847                 }
1848         }
1849 out:
1850         local_irq_enable();
1851         return;
1852 
1853 softnet_break:
1854         __get_cpu_var(netdev_rx_stat).time_squeeze++;
1855         __raise_softirq_irqoff(NET_RX_SOFTIRQ);
1856         goto out;
1857 }
1858

I have run into this problem on four systems running RHEL5, SLES10 or SLES 11.  The above describes what happens in RHEL5/SLES10.  This is different in SLES11, wherein dev->poll has been replaced by netif_napi_add and the poll function returns done without quota/budget manipulation; yet, I run into the same behavior. 

Any help appreciated! Thanks in advance!

Usha

___________________
Usha Srinivasan
Software Engineer
QLogic Corporation
780 5th Ave, Suite A
King of Prussia, PA 19406
(610) 233-4844
(610) 233-4777 (Fax)
(610) 233-4838 (Main Desk)

