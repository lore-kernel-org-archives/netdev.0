From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]: 8139cp: Don't blindly enable interrupts in cp_start_xmit
Date: Mon, 15 Jan 2007 20:56:35 +0100
Message-ID: <20070115195635.GA14205@electric-eye.fr.zoreil.com>
References: <45ABAE69.4070105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45977 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451AbXAOUAg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 15:00:36 -0500
To: Chris Lalancette <clalance@redhat.com>
Content-Disposition: inline
In-Reply-To: <45ABAE69.4070105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Lalancette <clalance@redhat.com> :
[...]
>      Similar to this commit:
> 
> http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=d15e9c4d9a75702b30e00cdf95c71c88e3f3f51e
> 
> It's not safe in cp_start_xmit to blindly call spin_lock_irq and then
> spin_unlock_irq, since it may very well be the case that cp_start_xmit
> was called with interrupts already disabled (I came across this bug in
> the context of netdump in RedHat kernels, but the same issue holds, for
> example, in netconsole).  Therefore, replace all instances of spin_lock_irq
> and spin_unlock_irq with spin_lock_irqsave and spin_unlock_irqrestore,
> respectively, in cp_start_xmit().  I tested this against a fully-virtualized
> Xen guest, which happens to use the 8139cp driver to talk to the emulated
> hardware.  I don't have a real piece of 8139cp hardware to test on, so
> someone else will have to do that.

(message reformated to fit in 80 columns, please fix your mailer)

As I understand http://lkml.org/lkml/2006/12/12/239, something like the
patch below should had been sent instead. Herbert, ack/nak ?

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 823215d..ff95641 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -55,7 +55,6 @@ static void queue_process(struct work_struct *work)
 	struct netpoll_info *npinfo =
 		container_of(work, struct netpoll_info, tx_work.work);
 	struct sk_buff *skb;
-	unsigned long flags;
 
 	while ((skb = skb_dequeue(&npinfo->txq))) {
 		struct net_device *dev = skb->dev;
@@ -65,19 +64,16 @@ static void queue_process(struct work_struct *work)
 			continue;
 		}
 
-		local_irq_save(flags);
 		netif_tx_lock(dev);
 		if (netif_queue_stopped(dev) ||
 		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			netif_tx_unlock(dev);
-			local_irq_restore(flags);
 
 			schedule_delayed_work(&npinfo->tx_work, HZ/10);
 			return;
 		}
 		netif_tx_unlock(dev);
-		local_irq_restore(flags);
 	}
 }
 
