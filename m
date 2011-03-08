From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/3] [RFC] Changes for MQ virtio-net
Date: Tue, 8 Mar 2011 17:41:04 +0200
Message-ID: <20110308154104.GA13931@redhat.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
 <20110228063437.24908.29435.sendpatchset@krkumar2.in.ibm.com>
 <20110228094320.GB28006@redhat.com>
 <OF2E9005A4.28D2C8A6-ON65257846.0054C7BB-65257846.00580600@in.ibm.com>
 <20110302100600.GB31309@redhat.com>
 <OFCDD0BC16.2EA548B2-ON6525784D.00551582-6525784D.00553911@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, horms@verge.net.au,
	kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755422Ab1CHPl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 10:41:27 -0500
Content-Disposition: inline
In-Reply-To: <OFCDD0BC16.2EA548B2-ON6525784D.00551582-6525784D.00553911@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2011 at 09:02:38PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 03/02/2011 03:36:00 PM:
> 
> Sorry for the delayed response, I have been sick the last few days.
> I am responding to both your posts here.
> 
> > > Both virtio-net and vhost need some check to make sure very
> > > high values are not passed by userspace. Is this not required?
> >
> > Whatever we stick in the header is effectively part of
> > host/gues interface. Are you sure we'll never want
> > more than 16 VQs? This value does not seem that high.
> 
> OK, so even constants cannot change?

Parse error :).

> Given that, should I remove all
> checks and use kcalloc?

I think that it's not a bad idea to avoid crashing if
hardware (in our case, host) misbehaves.
But as long as the code is prepared to handle any # of vqs,
I don't see a point of limiting that arbitrarily,
and if the code to handle hardware errors is complex
it'll have bugs itself.

> > > OK, so virtio_net_config has num_queue_pairs, and this gets converted to
> > > numtxqs in virtnet_info?
> >
> > Or put num_queue_pairs in virtnet_info too.
> 
> For virtnet_info, having numtxqs is easier since all code that loops needs
> only 'numtxq'.

It seemed to me that the code used numtxqs for # of rx qs as well
sometimes.

> > > Also, vhost has some
> > > code that processes tx first before rx (e.g. vhost_net_stop/flush),
> >
> > No idea why did I do it this way. I don't think it matters.
> >
> > > so this approach seemed helpful.
> > > I am OK either way, what do you
> > > suggest?
> >
> > We get less code generated but also less flexibility.
> > I am not sure, I'll play around with code, for now
> > let's keep it as is.
> 
> OK.
> 
> > > Yes, it is a waste to have these vectors for tx ints. I initially
> > > thought of adding a flag to virtio_device to pass to vp_find_vqs,
> > > but it won't work, so a new API is needed. I can work with you on
> > > this in the background if you like.
> >
> > OK. For starters, how about we change find_vqs to get a structure?  Then
> > we can easily add flags that tell us that some interrupts are rare.
> 
> Yes. OK to work on this outside this patch series, I guess?

We could work on this in parallel. Changing APIs is not a problem,
I'm a bit concerned that this might affect the host/guest ABI as well.

> > > vq's are matched between qemu, virtio-net and vhost. Isn't some check
> > > required that userspace has not passed a bad value?
> >
> >
> > For virtio, I'm not too concerned: qemu can already easily
> > crash the guest :)
> > For vhost yes, but I'm concerned that even with 16 VQs we are
> > drinking a lot of resources already. I would be happier
> > if we had a file descriptor per VQs pair in some way.
> > The the amount of memory userspace can use up is
> > limited by the # of file descriptors.
> 
> I will start working on this approach this week and see how it goes.

Also, could you post your current version of the qemu code pls?
It's useful for testing and to see the whole picture.

> > > OK, so define free_unused_bufs() as:
> > >
> > > static void free_unused_bufs(struct virtnet_info *vi, struct virtqueue
> > > *svq,
> > > 		 		 		      struct virtqueue *rvq)
> > > {
> > > 		 /* Use svq and rvq with the remaining code unchanged */
> > > }
> >
> > Not sure I understand. I am just suggesting
> > adding symmetrical functions like init/cleanup
> > alloc/free etc instead of adding stuff in random
> > functions that just happens to be called at the right time.
> 
> OK, I will clean up this part in the next revision.
> 
> > > I was not sure what is the best way - a sysctl parameter? Or should the
> > > maximum depend on number of host cpus? But that results in too many
> > > threads, e.g. if I have 16 cpus and 16 txqs.
> >
> > I guess the question is, wouldn't # of threads == # of vqs work best?
> > If we process stuff on a single CPU, let's make it pass through
> > a single VQ.
> > And to do this, we could simply open multiple vhost fds without
> > changing vhost at all.
> >
> > Would this work well?
> >
> > > > > -		 		  enum vhost_net_poll_state tx_poll_state;
> > > > > +		 		  enum vhost_net_poll_state *tx_poll_state;
> > > >
> > > > another array?
> > >
> > > Yes... I am also allocating twice the space than what is required
> > > to make it's usage simple.
> >
> > Where's the allocation? Couldn't find it.
> 
> vhost_setup_vqs(net.c) allocates it based on nvqs, though numtxqs is
> enough.
> 
> Thanks,
> 
> - KK
