From: jamal <hadi@cyberus.ca>
Subject: Re: take 3 [RFC] make qdisc_restart more readable
Date: Sat, 12 May 2007 15:56:13 -0400
Message-ID: <1178999773.15622.44.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>
	 <4645F325.3060607@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:58657 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757012AbXELT4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 15:56:18 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1204370wxd
        for <netdev@vger.kernel.org>; Sat, 12 May 2007 12:56:17 -0700 (PDT)
In-Reply-To: <4645F325.3060607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-12-05 at 19:02 +0200, Patrick McHardy wrote:
> jamal wrote:
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h

> >  #define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
> > +#define NETDEV_TX_DROP -2	/* request caller to drop packet */
> 
> This shouldn't be a NETDEV_TX code since its only handled correctly
> internally for handle_dev_cpu_collision().
> 
> > +#define NETDEV_TX_QUEUE -3	/* request caller to requeue packet */
> 
> How will this be used? The driver can simply stop the queue if
> it doesn't want to receive more packets.
> 

I can make those part of a different namespace; 
put defines in sch_generic sound reasonable?

> > +static inline int handle_dev_cpu_collision(struct net_device *dev)
> > +{
> > +	if (dev->xmit_lock_owner == smp_processor_id()) {
> 
> unlikely would make sense here.
> 

sure.

> > +static inline int
> > +handle_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
> > +{
> > +
> > +	if (unlikely(q == &noop_qdisc))
> > +		kfree_skb(skb);
> 
> Why is this special-casing needed? __qdisc_run already checks for
> noop_qdisc and noop has a proper requeue function.
> 

Good catch: That was a patch from Herbert after Thomas' "q refresh"
patch. So i was just replicating. I will fix it. Note: I think that
change may have made it to -stable?

> > +	else if (skb->next)
> > +		dev->gso_skb = skb;
> 
> The gso_skb cases could probably also be marked unlikely.
> 

will do.

> > +
> > +static inline int
> > +handle_tx_locked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
> 
> handle_.* sounds a bit like "I couldn't think of a better name" :)
> How about dev_tx_locked()?
> 

dev_tx_islocked()?

> > +	if (unlikely (ret != NETDEV_TX_BUSY)) {
> > +		/* XXX: Do we need a ratelimit? or put a
> > +		 * BUG_ON((int) ret != NETDEV_TX_BUSY) ?
> > +		 **/
> > +		printk("BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);
> 
> BUG_ON sounds a bit extreme, net_ratelimit() makes sense.

Ok. 

Thanks a lot Patrick.

cheers,
jamal

