From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v3 1/3] can: kvaser_usb: Fix tx queue start/stop race
 conditions
Date: Thu, 12 Mar 2015 15:30:57 -0400
Message-ID: <20150312193057.GA5947@linux>
References: <20150226152011.GA6075@linux>
 <20150311173744.GA13095@linux>
 <5500B6EB.8050905@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux-netdev <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5500B6EB.8050905@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Wed, Mar 11, 2015 at 10:43:07PM +0100, Marc Kleine-Budde wrote:
> On 03/11/2015 06:37 PM, Ahmed S. Darwish wrote:
> > From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > 
> > A number of tx queue wake-up events went missing due to the
> > outlined scenario below. Start state is a pool of 16 tx URBs,
> > active tx_urbs count = 15, with the netdev tx queue open.
> > 
> > start_xmit()                             tx_acknowledge()
> > ............                             ................
> > atomic_inc(&tx_urbs);
> > if (atomic_read(&tx_urbs) >= 16) {
> >                         URB completion IRQ!
> >                         -->
> >                                          atomic_dec(&tx_urbs);
> >                                          netif_wake_queue();
> >                                          return;
> >                         <--
> >                         end of IRQ!
> >     netif_stop_queue();
> > }
> > 
> > At the end, the correct state expected is a 15 tx_urbs count
> > value with the tx queue state _open_. Due to the race, we get
> > the same tx_urbs value but with the tx queue state _stopped_.
> > The wake-up event is completely lost.
> > 
> > Thus avoid hand-rolled concurrency mechanisms and use a proper
> > lock for contexts protection.
> > 
> > Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > ---
> >  drivers/net/can/usb/kvaser_usb.c | 83 ++++++++++++++++++++++++----------------
> >  1 file changed, 51 insertions(+), 32 deletions(-)
> > 
> > changelog-v3: Added missing spin_lock_init(). With all kernel
> > lock debugging options set, I've been running my test suite
> > for an hour now without apparent problems in dmesg so far.
> > 
> > changelog-v2: Put bugfix patch at the start of the series.
> > 
> > diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> > index a316fa4..e97a08c 100644
> > --- a/drivers/net/can/usb/kvaser_usb.c
> > +++ b/drivers/net/can/usb/kvaser_usb.c
> > @@ -14,6 +14,7 @@
> >   * Copyright (C) 2015 Valeo S.A.
> >   */
> >  
> > +#include <linux/spinlock.h>
> >  #include <linux/kernel.h>
> >  #include <linux/completion.h>
> >  #include <linux/module.h>
> > @@ -467,10 +468,11 @@ struct kvaser_usb {
> >  struct kvaser_usb_net_priv {
> >  	struct can_priv can;
> >  
> > -	atomic_t active_tx_urbs;
> > -	struct usb_anchor tx_submitted;
> > +	spinlock_t tx_contexts_lock;
> > +	int active_tx_contexts;
> >  	struct kvaser_usb_tx_urb_context tx_contexts[MAX_TX_URBS];
> >  
> > +	struct usb_anchor tx_submitted;
> >  	struct completion start_comp, stop_comp;
> >  
> >  	struct kvaser_usb *dev;
> > @@ -694,6 +696,7 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
> >  	struct kvaser_usb_net_priv *priv;
> >  	struct sk_buff *skb;
> >  	struct can_frame *cf;
> > +	unsigned long flags;
> >  	u8 channel, tid;
> >  
> >  	channel = msg->u.tx_acknowledge_header.channel;
> > @@ -737,12 +740,15 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
> >  
> >  	stats->tx_packets++;
> >  	stats->tx_bytes += context->dlc;
> > -	can_get_echo_skb(priv->netdev, context->echo_index);
> >  
> > -	context->echo_index = MAX_TX_URBS;
> > -	atomic_dec(&priv->active_tx_urbs);
> > +	spin_lock_irqsave(&priv->tx_contexts_lock, flags);
> >  
> > +	can_get_echo_skb(priv->netdev, context->echo_index);
> > +	context->echo_index = MAX_TX_URBS;
> > +	--priv->active_tx_contexts;
> >  	netif_wake_queue(priv->netdev);
> > +
> > +	spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);
> 
> I think it should be possible to move tun unlock before waking up the queue?
> 

Hmmm... I've kept thinking about this today. Here's my
understanding of the whole situation:

1) start_xmit() runs in NET_TX_SOFTIRQ softirq context
2) tx_acknowledge() occurs in URB completion softirq context
3) In an SMP machine, softirqs can run parallel to each other
4) start_xmit is protected from itself by the _xmit_lock spin
5) start_xmit() and tx_acknowledge() can, and do, run in parallel
   to each other

>From the above, we can imagine the following:

################################################################
#  Transfer queue length = 16
#  Transfer queue index = 15
#  
#  CPU #1                                    CPU #2
#  start_xmit()                              tx_acknowledge()
#  ------------                              ----------------
#                                            ...
#                                            spin_lock(ctx_lock)
#                                            index--
#                                            spin_unlock(ctx__lock)
#                          <---
#  ...
#  spin_lock(ctx_lock)
#  index++
#  spin_unlock(ctx_lock)
#  return;
#  
#  /* Another invocation of start_xmit */
#  
#  ...
#  spin_lock(ctx_lock)
#  index++
#  /* We've filled the tx queue */
#  if (index == 16)
#      netif_stop_queue()
#  spin_unlock(ctx_lock)
#  return;
#  
#  /* Transfer queue stopped */
#
#                          --->
#                                            /* Queue woken up
#  					     while it's full */
#                                            netif_wake_queue()
#                        
################################################################

I admit that unlike the race in the patch commit message, which
actually appeared in practice in a normal but heavy use case,
the one in the box above is highly theoretical. 

Nonetheless, I was actually able to fully and reliably produce
it by inserting a busy loop as follows:

static void kvaser_usb_tx_acknowledge(...)
{
   ...
   spin_lock_irqsave(&priv->tx_contexts_lock, flags);

   can_get_echo_skb(priv->netdev, context->echo_index);
   context->echo_index = dev->max_tx_urbs;
   --priv->active_tx_contexts;

   spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);

   /* Manual delay; use cpu_relax() not to be optimized out */
   for (n = 0; n < 1000; n++)
       cpu_relax();

   netif_wake_queue(priv->netdev);
   ...
}

Then running a very heavy transmission load:

   $ for i in {1..10}; do (cangen -i -I 111 -g1 -Di -L4 can0 &); done

And as I've expected, dmesg began seeing entries of "cannot find
free context" due to waking up the tx queue while being full:

[  +0.000002] kvaser_usb 1-1.2.1.1:1.0 can0: cannot find free context
[  +0.000003] kvaser_usb 1-1.2.1.1:1.0 can0: cannot find free context
[  +0.000002] kvaser_usb 1-1.2.1.1:1.0 can0: cannot find free context
[  +0.000002] kvaser_usb 1-1.2.1.1:1.0 can0: cannot find free context

Puting the netif_wake_queue() back inside the critical section,
even while keeping the delay loop in place, avoided such a race
condition.

Under normal conditions, such a heavy delay between the critical
section exit and netif_wake_queue() will not usually occur. This
is even more true since a softirq cannot preempt another softirq
running on the same CPU.

Nonetheless, since the race can be manually triggered as seen
above, I'd be safe and wake the queue inside the critical section
rather than sorry...

What do you think?

Regards,
Darwish
