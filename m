From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 10/14] virtio_net: limit xmit polling
Date: Sun, 22 May 2011 15:10:08 +0300
Message-ID: <20110522121008.GA12155@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
	<aced8619c07018b5495f9ceb2c02d4fbf897a098.1305846412.git.mst@redhat.com>
	<877h9kvlps.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877h9kvlps.fsf-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 21, 2011 at 11:49:59AM +0930, Rusty Russell wrote:
> On Fri, 20 May 2011 02:11:56 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > Current code might introduce a lot of latency variation
> > if there are many pending bufs at the time we
> > attempt to transmit a new one. This is bad for
> > real-time applications and can't be good for TCP either.
> 
> Do we have more than speculation to back that up, BTW?

Need to dig this up: I thought we saw some reports of this on the list?

> This patch is pretty sloppy; the previous ones were better polished.
> 
> > -static void free_old_xmit_skbs(struct virtnet_info *vi)
> > +static bool free_old_xmit_skbs(struct virtnet_info *vi, int capacity)
> >  {
> 
> A comment here indicating it returns true if it frees something?

Agree.

> >  	struct sk_buff *skb;
> >  	unsigned int len;
> > -
> > -	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > +	bool c;
> > +	int n;
> > +
> > +	/* We try to free up at least 2 skbs per one sent, so that we'll get
> > +	 * all of the memory back if they are used fast enough. */
> > +	for (n = 0;
> > +	     ((c = virtqueue_get_capacity(vi->svq) < capacity) || n < 2) &&
> > +	     ((skb = virtqueue_get_buf(vi->svq, &len)));
> > +	     ++n) {
> >  		pr_debug("Sent skb %p\n", skb);
> >  		vi->dev->stats.tx_bytes += skb->len;
> >  		vi->dev->stats.tx_packets++;
> >  		dev_kfree_skb_any(skb);
> >  	}
> > +	return !c;
> 
> This is for() abuse :)
> 
> Why is the capacity check in there at all?  Surely it's simpler to try
> to free 2 skbs each time around?

This is in case we can't use indirect: we want to free up
enough buffers for the following add_buf to succeed.


>    for (n = 0; n < 2; n++) {
>         skb = virtqueue_get_buf(vi->svq, &len);
>         if (!skb)
>                 break;
> 	pr_debug("Sent skb %p\n", skb);
> 	vi->dev->stats.tx_bytes += skb->len;
> 	vi->dev->stats.tx_packets++;
> 	dev_kfree_skb_any(skb);
>    }
> 
> >  static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
> > @@ -574,8 +582,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  	struct virtnet_info *vi = netdev_priv(dev);
> >  	int capacity;
> >  
> > -	/* Free up any pending old buffers before queueing new ones. */
> > -	free_old_xmit_skbs(vi);
> > +	/* Free enough pending old buffers to enable queueing new ones. */
> > +	free_old_xmit_skbs(vi, 2+MAX_SKB_FRAGS);
> >  
> >  	/* Try to transmit */
> >  	capacity = xmit_skb(vi, skb);
> > @@ -609,9 +617,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  		netif_stop_queue(dev);
> >  		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
> >  			/* More just got used, free them then recheck. */
> > -			free_old_xmit_skbs(vi);
> > -			capacity = virtqueue_get_capacity(vi->svq);
> > -			if (capacity >= 2+MAX_SKB_FRAGS) {
> > +			if (!likely(free_old_xmit_skbs(vi, 2+MAX_SKB_FRAGS))) {
> 
> This extra argument to free_old_xmit_skbs seems odd, unless you have
> future plans?
> 
> Thanks,
> Rusty.

I just wanted to localize the 2+MAX_SKB_FRAGS logic that tries to make
sure we have enough space in the buffer. Another way to do
that is with a define :).

-- 
MST
