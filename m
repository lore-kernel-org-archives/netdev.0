From: jamal <hadi@cyberus.ca>
Subject: Re: [RFR] gianfar ethernet driver
Date: 06 Jul 2004 23:18:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089170282.1038.80.camel@jzny.localdomain>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com>
	 <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>,
        netdev@oss.sgi.com, dwmw2@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-07-06 at 20:42, Andy Fleming wrote:
> I've made many of the changes, and am working on others, but I would 
> like a few clarifications:
> 
> Jeff Wrote:
> >> 2) I'm strongly pondering vetoing try_fastroute() code in this driver.
> >> Surely this should be in core net stack code... if it isn't already?  
> >> Jamal?
> 
> Jamal wrote:
> > I hardly know anybody still using this interface - i believe it is not
> > useful after NAPI; maybe this comment would bring out some of the
> > believers out of the woodwork to comment.
> > Otherwise i would say kill it.
> 
> Hmm.. We had some testing done (admittedly in 2.4), and this code 
> substantially increased routing speed for some cases.  I admit, though, 
> that the code is ugly.  It would be nice if the part which is clearly 
> generic across all controllers were inside the stack, but if no one 
> uses it (and finding an example of a driver which did was difficult), 
> then maybe it's not worth the effort.

Can you describe your test scenarios where it was valuable and what kind
of throughput (and possibly latency) you were seeing? 
BTW, is this a gige interface?

> >> 8) I recommend enabling _both_ hardware interrupt coalescing and NAPI,
> >> at the same time.  Several other Linux net drivers need to be changed 
> >> to
> >> do this, as well
> 
> Ok... but this is possible with the driver as it is.  Interrupt 
> Coalescing is runtime configurable, and NAPI is a compile-time option.  
> NAPI can sometimes hurt performance, and so we'd like to have the 
> ability to disable it for some deployments.  I guess I'm not sure what 
> change this suggestion was meant to cause.

In your observation when is NAPI hurting performance?
I am familiar with one case where extra PCI reads become a
problem consuming extra CPU. We have so far rejected to "fix" 
that. 

> > if (txbdp == priv->dirty_tx) {
> > 	netif_stop_queue(dev)
> > 	unlock
> > 	return 1;
> > }
> > The rest of your code goes here ..
> >
> > Do this before the skb is touched. Note the return 1. This means dont
> > add it to your priv->tx_skbuff[priv->skb_curtx] = skb before you do
> > this.
> 
> Right.  Technically, I'm doing that one full call before the skb is 
> touched.  I think you're just missing the line above it where I 
> increment the descriptor pointer to the next one.

You dont return a 1 anywhere.
Heres what i mean (substitute your code):
if no more descriptors
netif_stop_queue(dev)
unlock
return 1
process packet and stash on ring
return 0

> > Dont understand why you have your own proivate list btw.
> 
> Is there another list which deallocates skbs after I have transmitted 
> them?

TX completion interupt is supposed to keep free them typically at the
interupt handler. So no need to track them unless you are trying
something fancy - hence my question.

> >
> > 2) Also its pretty scary if you are doing:
> > txbdp->status |= TXBD_INTERRUPT for every packet.
> > Look at other drivers, they try to do this every few packets;
> > or enable tx mitigation to slow the rate  of those interupts.
> 
> I don't believe this is as dire as you think.  This bit only indicates 
> that, if the conditions are right, an interrupt will be generated once 
> that descriptor is processed, and its data sent.  Conditions which 
> mitigate that are:
> 1) coalescing is on, and the timer and counter have not triggered the 
> interrupt yet

This is what i was recommending; but even without this, look at the
Becker style approach in a lot of drivers of not triggering interupts in
all cases.

> 2) NAPI is enabled, and so interrupts are disabled after the first 
> packet arrives

Depends on approach you took for NAPI (sorry deleted code/email).
If you went e1000 styloe, then you are correct. If you went tulip style,
the tx interupts are still on.

> 3) NAPI is disabled, but the driver is currently handling a previous 
> interrupt, so the interrupts are disabled for now.
>
> Since interrupts are so often disabled at the controller, this has the 
> effect of not letting each packet trigger an interrupt.

You are theorizing here and doing a very poor job. Have you actually
tried and proven this? This will discount everything to date thats been
done to reduce interupt rates.

>   However, in a 
> low-traffic case, not setting the Interrupt bit in the descriptor will 
> cause the packet to sit around indefinitely, until a packet with the 
> bit set is sent. 

I am not sure i followed. But it seems to me thats a bug.

>  Obviously, with interrupt coalescing enabled, this 
> becomes less of an issue (assuming our hardware doesn't require the bit 
> in order to increment the frame counter or start the timeout timer...).

Your hardware seems to be buggy or you not explaining well.
Anyways, you know what to do in this area.

cheers,
jamal
