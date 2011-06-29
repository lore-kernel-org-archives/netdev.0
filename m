From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/core: Convert to current logging forms
Date: Wed, 29 Jun 2011 07:57:15 -0700
Message-ID: <1309359435.29598.72.camel@Joe-Laptop>
References: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
	 <20110629111109.GA1613@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110629111109.GA1613@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-06-29 at 07:11 -0400, Neil Horman wrote:
> On Tue, Jun 28, 2011 at 12:40:10PM -0700, Joe Perches wrote:
> > Use pr_fmt, pr_<level>, and netdev_<level> as appropriate.
> > Coalesce long formats.
[]
> > diff --git a/net/core/dev.c b/net/core/dev.c
[]
> > @@ -5397,8 +5380,8 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
> >  
> >  	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
> >  	if (!tx) {
> > -		pr_err("netdev: Unable to allocate %u tx queues.\n",
> > -		       count);
> > +		netdev_err(dev, "netdev: Unable to allocate %u tx queues\n",
> > +			   count);
> >  		return -ENOMEM;
> >  	}
> Don't all of these get called prior to device registration?  This change will
> have us printing out unregistered net device: ... rather than netdev: ... on
> these errors.

True, that's not particularly good.

> Not tragic, but I rather think its nicer to just say netdev:...

If the second suggested patch is also applied,
it shows the "devicename (unregistered)".

I think that's appropriate.

> Ditto on the unregistered net device thing.

ditto back.

[]
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
[]
> >   */
> >  static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
> >  {
> > -	printk(KERN_EMERG "skb_over_panic: text:%p len:%d put:%d head:%p "
> > -			  "data:%p tail:%#lx end:%#lx dev:%s\n",
> > -	       here, skb->len, sz, skb->head, skb->data,
> > -	       (unsigned long)skb->tail, (unsigned long)skb->end,
> > -	       skb->dev ? skb->dev->name : "<NULL>");
> > +	netdev_emerg(skb->dev, "skb_over_panic: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx\n",
> > +		     here, skb->len, sz, skb->head, skb->data,
> > +		     (unsigned long)skb->tail, (unsigned long)skb->end);
> >  	BUG();
> >  }
> Are you guaranteed to have skb->dev be non-null here?

I think not.

> netdev_printk handles
> that, but flaggin the fact that we have a NULL net device when thats not really
> an issue seems like it would destract from the purpose of this printk.  Same
> with the others in this file below

With the skb_<foo>_panics, I think rearranging the
message output may actually help a _very_ little bit.
The next bit is a BUG which dumps stack and stops the
system anyway so it's not much of an issue.

[]

> > @@ -3061,9 +3057,8 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
> >  	if (unlikely(start > skb_headlen(skb)) ||
> >  	    unlikely((int)start + off > skb_headlen(skb) - 2)) {
> >  		if (net_ratelimit())
> > -			printk(KERN_WARNING
> > -			       "bad partial csum: csum=%u/%u len=%u\n",
> > -			       start, off, skb_headlen(skb));
> > +			netdev_warn(skb->dev, "bad partial csum: csum=%u/%u len=%u\n",
> > +				    start, off, skb_headlen(skb));
> >  		return false;
> >  	}
> >  	skb->ip_summed = CHECKSUM_PARTIAL;

I think netdev_warn is an improvement here.

> > @@ -3076,7 +3071,6 @@ EXPORT_SYMBOL_GPL(skb_partial_csum_set);
> >  void __skb_warn_lro_forwarding(const struct sk_buff *skb)
> >  {
> >  	if (net_ratelimit())
> > -		pr_warning("%s: received packets cannot be forwarded"
> > -			   " while LRO is enabled\n", skb->dev->name);
> > +		netdev_warn(skb->dev, "received packets cannot be forwarded while LRO is enabled\n");
> >  }
> >  EXPORT_SYMBOL(__skb_warn_lro_forwarding);

and not a change here.

I'll reorder the patches to do netdev_name changes
first and resubmit if there aren't more comments
in awhile.

cheers, Joe
