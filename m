From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Tue, 1 Feb 2011 23:21:12 +0200
Message-ID: <20110201212110.GC30770@redhat.com>
References: <20110127193131.GD5228@redhat.com>
 <1296157547.1640.45.camel@localhost.localdomain>
 <20110127200548.GE5228@redhat.com>
 <20110127.130240.104065182.davem@davemloft.net>
 <1296163838.1640.53.camel@localhost.localdomain>
 <20110201172346.GA24392@redhat.com>
 <1296590943.26937.797.camel@localhost.localdomain>
 <20110201201715.GA30050@redhat.com>
 <1296591908.26937.809.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, steved@us.ibm.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266Ab1BAVV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 16:21:28 -0500
Content-Disposition: inline
In-Reply-To: <1296591908.26937.809.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 01, 2011 at 12:25:08PM -0800, Shirley Ma wrote:
> On Tue, 2011-02-01 at 22:17 +0200, Michael S. Tsirkin wrote:
> > On Tue, Feb 01, 2011 at 12:09:03PM -0800, Shirley Ma wrote:
> > > On Tue, 2011-02-01 at 19:23 +0200, Michael S. Tsirkin wrote:
> > > > On Thu, Jan 27, 2011 at 01:30:38PM -0800, Shirley Ma wrote:
> > > > > On Thu, 2011-01-27 at 13:02 -0800, David Miller wrote:
> > > > > > > Interesting. Could this is be a variant of the now famuous
> > > > > > bufferbloat then?
> > > > > > 
> > > > > > Sigh, bufferbloat is the new global warming... :-/ 
> > > > > 
> > > > > Yep, some places become colder, some other places become warmer;
> > > > Same as
> > > > > BW results, sometimes faster, sometimes slower. :)
> > > > > 
> > > > > Shirley
> > > > 
> > > > Sent a tuning patch (v2) that might help.
> > > > Could you try it and play with the module parameters please? 
> > > 
> > > Hello Michael,
> > > 
> > > Sure I will play with this patch to see how it could help. 
> > > 
> > > I am looking at guest side as well, I found a couple issues on guest
> > > side:
> > > 
> > > 1. free_old_xmit_skbs() should return the number of skbs instead of
> > the
> > > total of sgs since we are using ring size to stop/start netif queue.
> > > static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
> > > {
> > >         struct sk_buff *skb;
> > >         unsigned int len, tot_sgs = 0;
> > > 
> > >         while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > >                 pr_debug("Sent skb %p\n", skb);
> > >                 vi->dev->stats.tx_bytes += skb->len;
> > >                 vi->dev->stats.tx_packets++;
> > >                 tot_sgs += skb_vnet_hdr(skb)->num_sg;
> > >                 dev_kfree_skb_any(skb);
> > >         }
> > >         return tot_sgs; <---- should return numbers of skbs to track
> > > ring usage here, I think;
> > > }
> > > 
> > > Did the old guest use number of buffers to track ring usage before?
> > > 
> > > 2. In start_xmit, I think we should move capacity +=
> > free_old_xmit_skbs
> > > before netif_stop_queue(); so we avoid unnecessary netif queue
> > > stop/start. This condition is heavily hit for small message size.
> > > 
> > > Also we capacity checking condition should change to something like
> > half
> > > of the vring.num size, instead of comparing 2+MAX_SKB_FRAGS?
> > > 
> > >        if (capacity < 2+MAX_SKB_FRAGS) {
> > >                 netif_stop_queue(dev);
> > >                 if (unlikely(!virtqueue_enable_cb(vi->svq))) {
> > >                         /* More just got used, free them then
> > recheck.
> > > */
> > >                         capacity += free_old_xmit_skbs(vi);
> > >                         if (capacity >= 2+MAX_SKB_FRAGS) {
> > >                                 netif_start_queue(dev);
> > >                                 virtqueue_disable_cb(vi->svq);
> > >                         }
> > >                 }
> > >         }
> > > 
> > > 3. Looks like the xmit callback is only used to wake the queue when
> > the
> > > queue has stopped, right? Should we put a condition check here?
> > > static void skb_xmit_done(struct virtqueue *svq)
> > > {
> > >         struct virtnet_info *vi = svq->vdev->priv;
> > > 
> > >         /* Suppress further interrupts. */
> > >         virtqueue_disable_cb(svq);
> > > 
> > >         /* We were probably waiting for more output buffers. */
> > > --->   if (netif_queue_stopped(vi->dev))
> > >         netif_wake_queue(vi->dev);
> > > }
> > > 
> > > 
> > > Shirley
> > 
> > Well the return value is used to calculate capacity and that counts
> > the # of s/g. No?
> 
> Nope, the current guest kernel uses descriptors not number of sgs.

Confused. We compare capacity to skb frags, no?
That's sg I think ...

> not sure the old guest.
> 
> > From cache utilization POV it might be better to read from the skb and
> > not peek at virtio header though...
> > Pls Cc the lists on any discussions in the future.
> > 
> > -- 
> > MST
> 
> Sorry I missed reply all. :(
> 
> Shirley
