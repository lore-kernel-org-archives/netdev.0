From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 10 Nov 2010 18:16:00 +0200
Message-ID: <20101110161600.GC3891@redhat.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
 <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com>
 <20101026085709.GC23530@redhat.com>
 <OF529E89EE.84DB37B8-ON652577D6.001665CF-652577D6.00192784@in.ibm.com>
 <20101109132239.GF22705@redhat.com>
 <OF24E08752.2087FFA4-ON652577D6.00532DF1-652577D6.0054B291@in.ibm.com>
 <20101109153325.GB26153@redhat.com>
 <OFFE63B7F4.D491BE12-ON652577D6.005B4090-652577D6.005F565A@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756405Ab0KJQQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 11:16:25 -0500
Content-Disposition: inline
In-Reply-To: <OFFE63B7F4.D491BE12-ON652577D6.005B4090-652577D6.005F565A@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 10:54:57PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 11/09/2010 09:03:25 PM:
> 
> > > > Something strange here, right?
> > > > 1. You are consistently getting >10G/s here, and even with a single
> > > stream?
> > >
> > > Sorry, I should have mentioned this though I had stated in my
> > > earlier mails. Each test result has two iterations, each of 60
> > > seconds, except when #netperfs is 1 for which I do 10 iteration
> > > (sum across 10 iterations).
> >
> > So need to divide the number by 10?
> 
> Yes, that is what I get with 512/1K macvtap I/O size :)
> 
> > >  I started doing many more iterations
> > > for 1 netperf after finding the issue earlier with single stream.
> > > So the BW is only 4.5-7 Gbps.
> > >
> > > > 2. With 2 streams, is where we get < 10G/s originally. Instead of
> > > >    doubling that we get a marginal improvement with 2 queues and
> > > >    about 30% worse with 1 queue.
> > >
> > > (doubling happens consistently for guest -> host, but never for
> > > remote host) I tried 512/txqs=2 and 1024/txqs=8 to get a varied
> > > testing scenario. In first case, there is a slight improvement in
> > > BW and good reduction in SD. In the second case, only SD improves
> > > (though BW drops for 2 stream for some reason).  In both cases,
> > > BW and SD improves as the number of sessions increase.
> >
> > I guess this is another indication that something's wrong.
> 
> The patch - both virtio-net and vhost-net, doesn't have any
> locking/mutex's/ or any synchronization method. Guest -> host
> performance improvement of upto 100% shows the patch is not
> doing anything wrong.

My concern is this: we don't seem to do anything in tap or macvtap to
help packets from separate virtio queues get to separate queues in the
hardware device and to avoid reordering when we do this.

- skb_tx_hash calculation will get different results
- hash math that e.g. tcp does will run on guest and seems to be discarded

etc

Maybe it's as simple as some tap/macvtap ioctls to set up the queue number
in skbs. Or maybe we need to pass the skb hash from guest to host.
It's this last option that should make us especially cautios as it'll
affect guest/host interface.

Also see d5a9e24afb4ab38110ebb777588ea0bd0eacbd0a: if we have
hardware which records an RX queue, it appears important to
pass that info to guest and to use that in selecting the TX queue.
Of course we won't see this in netperf runs but this needs to
be given thought too - supporting this seems to suggest either
sticking the hash in the virtio net header for both tx and rx,
or using multiplease RX queues.

> > We are quite far from line rate, the fact BW does not scale
> > means there's some contention in the code.
> 
> Attaining line speed with macvtap seems to be a generic issue
> and unrelated to my patch specifically. IMHO if there is nothing
> wrong in the code (review) and is accepted, it will benefit as
> others can also help to find what needs to be implemented in
> vhost/macvtap/qemu to get line speed for guest->remote-host.

No problem, I will queue these patches in some branch
to help enable cooperation, as well as help you
iterate with incremental patches instead of resending it all each time.


> PS: bare-metal performance for host->remote-host is also
>     2.7 Gbps and 2.8 Gbps for 512/1024 for the same card.
> 
> Thanks,

You mean native linux BW does not scale for your host with
# of connections either? I guess this just means need another
setup for testing?

> - KK
