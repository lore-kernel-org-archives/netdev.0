From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Thu, 3 Feb 2011 07:59:26 +0200
Message-ID: <20110203055926.GB22230@redhat.com>
References: <20110202154706.GA12738@redhat.com>
 <1296666635.25430.35.camel@localhost.localdomain>
 <20110202173213.GA13907@redhat.com>
 <1296670311.25430.49.camel@localhost.localdomain>
 <20110202182720.GB14257@redhat.com>
 <1296674975.25430.59.camel@localhost.localdomain>
 <20110202201731.GB15150@redhat.com>
 <1296680585.25430.98.camel@localhost.localdomain>
 <20110202212047.GD15150@redhat.com>
 <1296682893.25430.112.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611Ab1BCF7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 00:59:46 -0500
Content-Disposition: inline
In-Reply-To: <1296682893.25430.112.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 02, 2011 at 01:41:33PM -0800, Shirley Ma wrote:
> On Wed, 2011-02-02 at 23:20 +0200, Michael S. Tsirkin wrote:
> > > On Wed, 2011-02-02 at 22:17 +0200, Michael S. Tsirkin wrote:
> > > > Well, this is also the only case where the queue is stopped, no?
> > > Yes. I got some debugging data, I saw that sometimes there were so
> > many
> > > packets were waiting for free in guest between vhost_signal & guest
> > xmit
> > > callback.
> > 
> > What does this mean?
> 
> Let's look at the sequence here:
> 
> guest start_xmit()
> 	xmit_skb()
> 	if ring is full,
> 		enable_cb()
> 
> guest skb_xmit_done()
> 	disable_cb,
>         printk free_old_xmit_skbs <-- it was between more than 1/2 to
> full ring size
> 	printk vq->num_free 
> 
> vhost handle_tx()
> 	if (guest interrupt is enabled)
> 		signal guest to free xmit buffers
> 
> So between guest queue full/stopped queue/enable call back to guest
> receives the callback from host to free_old_xmit_skbs, there were about
> 1/2 to full ring size descriptors available. I thought there were only a
> few. (I disabled your vhost patch for this test.)


The expected number is vq->num - max skb frags - 2.

> 
> > > Looks like the time spent too long from vhost_signal to guest
> > > xmit callback?
> > 
> > 
> > 
> > > > > I tried to accumulate multiple guest to host notifications for
> > TX
> > > > xmits,
> > > > > it did help multiple streams TCP_RR results;
> > > > I don't see a point to delay used idx update, do you?
> > > 
> > > It might cause per vhost handle_tx processed more packets.
> > 
> > I don't understand. It's a couple of writes - what is the issue?
> 
> Oh, handle_tx could process more packets per loop for multiple streams
> TCP_RR case. I need to print out the data rate per loop to confirm this.
> 
> Shirley
