From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 13:41:41 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007184141.GL31237@waste.org>
References: <20041006232544.53615761@jack.colino.net> <20041006214322.GG31237@waste.org> <20041007075319.6b31430d@jack.colino.net> <20041006234912.66bfbdcc.davem@davemloft.net> <20041007160532.60c3f26b@pirandello> <20041007112846.5c85b2d9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin Leroy <colin@colino.net>, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041007112846.5c85b2d9.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2004 at 11:28:46AM -0700, David S. Miller wrote:
> On Thu, 7 Oct 2004 16:05:32 +0200
> Colin Leroy <colin@colino.net> wrote:
> 
> > First, my newbie question: is it possible to deadlock a spinlock on a
> > Uniprocessor kernel ? For example, there's something I find suspect in
> > netpoll/sungem interaction:
> > 
> 
> Oh yes, it appears that netpoll doesn't support NETIF_F_LLTX locking,
> crap :(
> 
> When a device has NETIF_F_LLTX set, it means that the driver's
> dev->hard_start_xmit() routine is what takes the xmit_lock, not
> the caller one level up.
> 
> Andi Kleen didn't fix up netpoll when he did his LLTX changes, oops.
> 
> So, netpoll needs to have the NETIF_F_LLTX stuff added to it.
> Basically:
> 
> 1) If NETIF_F_LLTX is clear, same as before
> 2) If NETIF_F_LLTX is set:
> 	a) Do not take xmit_lock
> 	b) Check ->hard_start_xmit() return value,
> 	   if it is NETDEV_TX_LOCKED, then
> 	   spin_trylock(&dev->xmit_lock) failed
>            in ->hard_start_xmit()

Colin, feeling adventurous enough to take a stab at this? It looks
pretty straightforward but I'm going to be even more useless than
usual for the next two weeks.

> 
> The best example is in net/sched/sch_generic.c:qdisc_restart()
> 
> 		unsigned nolock = (dev->features & NETIF_F_LLTX);
> 		/*
> 		 * When the driver has LLTX set it does its own locking
> 		 * in start_xmit. No need to add additional overhead by
> 		 * locking again. These checks are worth it because
> 		 * even uncongested locks can be quite expensive.
> 		 * The driver can do trylock like here too, in case
> 		 * of lock congestion it should return -1 and the packet
> 		 * will be requeued.
> 		 */
> 		if (!nolock) {
> 			if (!spin_trylock(&dev->xmit_lock)) {
> 			collision:
> 				/* So, someone grabbed the driver. */
> 				
> 				/* It may be transient configuration error,
> 				   when hard_start_xmit() recurses. We detect
> 				   it by checking xmit owner and drop the
> 				   packet when deadloop is detected.
> 				*/
> 				if (dev->xmit_lock_owner == smp_processor_id()) {
> 					kfree_skb(skb);
> 					if (net_ratelimit())
> 						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
> 					return -1;
> 				}
> 				__get_cpu_var(netdev_rx_stat).cpu_collision++;
> 				goto requeue;
> 			}
> 			/* Remember that the driver is grabbed by us. */
> 			dev->xmit_lock_owner = smp_processor_id();
> 		}
> 		
> 		{
> 			/* And release queue */
> 			spin_unlock(&dev->queue_lock);
> 
> 			if (!netif_queue_stopped(dev)) {
> 				int ret;
> 				if (netdev_nit)
> 					dev_queue_xmit_nit(skb, dev);
> 
> 				ret = dev->hard_start_xmit(skb, dev);
> 				if (ret == NETDEV_TX_OK) { 
> 					if (!nolock) {
> 						dev->xmit_lock_owner = -1;
> 						spin_unlock(&dev->xmit_lock);
> 					}
> 					spin_lock(&dev->queue_lock);
> 					return -1;
> 				}
> 				if (ret == NETDEV_TX_LOCKED && nolock) {
> 					spin_lock(&dev->queue_lock);
> 					goto collision; 
> 				}
> 			}
> 
> 			/* NETDEV_TX_BUSY - we need to requeue */
> 			/* Release the driver */
> 			if (!nolock) { 
> 				dev->xmit_lock_owner = -1;
> 				spin_unlock(&dev->xmit_lock);
> 			} 
> 			spin_lock(&dev->queue_lock);
> 			q = dev->qdisc;
> 		}

-- 
Mathematics is the supreme nostalgia of our time.
