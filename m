From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Thu, 3 Feb 2011 08:16:08 +0200
Message-ID: <20110203061608.GA14824@redhat.com>
References: <20110202173213.GA13907@redhat.com>
 <1296670311.25430.49.camel@localhost.localdomain>
 <20110202182720.GB14257@redhat.com>
 <1296674975.25430.59.camel@localhost.localdomain>
 <20110202201731.GB15150@redhat.com>
 <1296680585.25430.98.camel@localhost.localdomain>
 <20110202212047.GD15150@redhat.com>
 <1296682893.25430.112.camel@localhost.localdomain>
 <20110203055926.GB22230@redhat.com>
 <1296713354.25430.143.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013Ab1BCGQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 01:16:29 -0500
Content-Disposition: inline
In-Reply-To: <1296713354.25430.143.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 02, 2011 at 10:09:14PM -0800, Shirley Ma wrote:
> On Thu, 2011-02-03 at 07:59 +0200, Michael S. Tsirkin wrote:
> > > Let's look at the sequence here:
> > > 
> > > guest start_xmit()
> > >       xmit_skb()
> > >       if ring is full,
> > >               enable_cb()
> > > 
> > > guest skb_xmit_done()
> > >       disable_cb,
> > >         printk free_old_xmit_skbs <-- it was between more than 1/2
> > to
> > > full ring size
> > >       printk vq->num_free 
> > > 
> > > vhost handle_tx()
> > >       if (guest interrupt is enabled)
> > >               signal guest to free xmit buffers
> > > 
> > > So between guest queue full/stopped queue/enable call back to guest
> > > receives the callback from host to free_old_xmit_skbs, there were
> > about
> > > 1/2 to full ring size descriptors available. I thought there were
> > only a
> > > few. (I disabled your vhost patch for this test.)
> > 
> > 
> > The expected number is vq->num - max skb frags - 2. 
> 
> It was various (up to the ring size 256). This is using indirection
> buffers, it returned how many freed descriptors, not number of buffers.
> 
> Why do you think it is vq->num - max skb frags - 2 here?
> 
> Shirley

well queue is stopped which happens when

        if (capacity < 2+MAX_SKB_FRAGS) {
                netif_stop_queue(dev);
                if (unlikely(!virtqueue_enable_cb(vi->svq))) {
                        /* More just got used, free them then recheck.
 * */
                        capacity += free_old_xmit_skbs(vi);
                        if (capacity >= 2+MAX_SKB_FRAGS) {
                                netif_start_queue(dev);
                                virtqueue_disable_cb(vi->svq);
                        }
                }
        }

This should be the most common case.
I guess the case with += free_old_xmit_skbs is what can get us more.
But it should be rare. Can you count how common it is?

-- 
MST
