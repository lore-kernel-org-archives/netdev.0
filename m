From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Tue, 23 Mar 2004 10:14:23 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4060544F.2090702@pobox.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com>	<405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <8765cvmyaq.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi wrote:
> Jeff Garzik <jgarzik@pobox.com> writes:
> 
> 
>>>+	if (work_done < orig_budget) {
>>>+		unsigned long flags;
>>>+		int status;
>>>+
>>>+		spin_lock_irqsave(&ep->napi_lock, flags);
>>>+		epic_napi_irq_on(dev, ep);
>>>+		__netif_rx_complete(dev);
>>>+		spin_unlock_irqrestore(&ep->napi_lock, flags);
>>>+
>>>+		status = inl(ioaddr + INTSTAT);
>>>+		if (status & EpicNapiEvent) {
>>>+			epic_napi_irq_off(dev, ep);
>>>+			goto rx_action;
>>>+		}
>>
>>Need to add a netif_running() check to the 'if' test at the top of the
>>quote.
>>
>>Are you (or somebody else?) interested in reviewing all the in-tree
>>NAPI drivers, and seeing if other drivers have this bug?  I think
>>8139cp.c does at least, maybe e100 too...  Such a fix would need to go
>>into 2.4.x as well.
> 
> 
> Umm.. the above code is part of ->poll(). I think xxx_interrut() need
> netif_running() instead. The driver must clear __LINK_STATE_RX_SCHED
> flag...

Most interrupt routines already test this, look at

static inline int netif_rx_schedule_prep(struct net_device *dev)
{
         return netif_running(dev) &&
                 !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
}

It shouldn't schedule unless the interface is running.

However...  I believe it was you that added this check to 8139cp.c:

         /* close possible race's with dev_close */
         if (unlikely(!netif_running(dev))) {
                 cpw16(IntrMask, 0);
                 goto out;
         }

I like this, because regardless of NAPI, most drivers have 
non-NAPI-related interrupts they must still process.  This check handles 
that.

Although this code is a bit redundant to some of the locking and 
synchronization found in net driver dev->close() methods, I think it is 
a nice thing to do.

I do wonder about the consequences, on some hardware, about receiving an 
interrupt and -not- processing the RX or TX completions associated with 
that.  For most NIC hardware, you'll get sane behavior, but not all, I 
bet...


> BTW, ->napi_lock is unneeded because netif_schedule() is already
> atomic, it need only local_irq_enable/disable().
> 
> After __netif_rx_complete() must not do "goto rx_action", otherwise it

Agreed.

	Jeff
