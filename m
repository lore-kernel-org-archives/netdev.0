From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Fri, 23 Feb 2007 22:27:23 +0300
Message-ID: <45DF401B.6050304@ru.mvista.com>
References: <200701312144.56497.sshtylyov@ru.mvista.com>	<45DDBD96.10000@ru.mvista.com>	<45DDC7C0.8050100@ru.mvista.com>	<200702231238.40474.amitkale@linsyssoft.com>	<45DF2E20.305@mvista.com>	<20070223110451.44066f09@freekitty>	<45DF3BDC.2070806@ru.mvista.com>	<20070223111354.2e25db9d@freekitty>	<45DF3DAB.3010902@ru.mvista.com> <20070223112246.0712e7de@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>,
	"Amit S. Kale" <amitkale@linsyssoft.com>, netdev@vger.kernel.org,
	Mithlesh Thukral <mithlesh@linsyssoft.com>,
	Vitaly Wool <vwool@ru.mvista.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:42474 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933198AbXBWT1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 14:27:38 -0500
In-Reply-To: <20070223112246.0712e7de@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>>>>>>>This thread came up on kgdb-bugreport mailing list. Could you please suggest 
>>>>>>>us what's the correct way of fixing this problem?

>>>>>>>1. When running a kgdb on RTL8139 ethernet interface: 8139too driver prints 
>>>>>>>too many "Out-of-sync dirty pointer" messages on console and gdb can't 
>>>>>>>connect to kgdb stub. These messages can be suppressed, though it still 
>>>>>>>results in connection failures frequently. 

>>>>>>We think this comes from calling the driver while the queue is stopped.  
>>>>>>Drivers should not do horrible things when hard start is called with the 
>>>>>>queue stopped, but unfortunately, at this time, at least some drivers 
>>>>>>do  explode or complain under that condition.

>>>>>The kernel is built on a set of assumptions about calling context. Your
>>>>>out of tree code is violating one of them. Why not check for stopped queue
>>>>>and do some action to try and clear it, that is what netconsole does.

>>>>   The queue can't be stopped when the netpoll traffic trapping is enabled 
>>>>(cause this effectively bypasses queue control), So, the stopped queue 
>>>>indoication doesn't work also -- *that* is the problem. It's not at all 
>>>>specific to KGBoE -- only to traffic trapping.

>>>You can't ask a device to send a packet when it has no resources.

>>    When traffic trapping is enabled, and driver stops the queue, the 
>>__LINK_STATE_XOFF flag does *not* get set, so netif_queue_stopped() resturns 
>>*zero*.  What may be done in this situation?

> Read netpoll_send_skb()

> 	int status = NETDEV_TX_BUSY;
> ...
> 		if (netif_tx_trylock(dev)) {
> 			/* try until next clock tick */
> 			for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
> 					tries > 0; --tries) {
> 				if (!netif_queue_stopped(dev))
> 					status = dev->hard_start_xmit(skb, dev);
> 
> 				if (status == NETDEV_TX_OK)
> 					break;
> 
> 				/* tickle device maybe there is some cleanup */
> 				netpoll_poll(np);
> 
> 				udelay(USEC_PER_POLL);
> 			}
> 			netif_tx_unlock(dev);

> netpoll_poll() allows device to try and cleanup transmit resources.

    Read <linux/netdevice.h>:

static inline void netif_stop_queue(struct net_device *dev)
{
#ifdef CONFIG_NETPOLL_TRAP
         if (netpoll_trap())
                 return;
#endif
         set_bit(__LINK_STATE_XOFF, &dev->state);
}

static inline int netif_queue_stopped(const struct net_device *dev)
{
         return test_bit(__LINK_STATE_XOFF, &dev->state);
}

    When the driver calls netif_stop_queue() having his TX queue filled to the 
brim (4 buffers in case of 8139too) and netpoll_trap() returns 1, what will 
happen?

WBR, Sergei
