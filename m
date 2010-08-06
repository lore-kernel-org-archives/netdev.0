From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: Using virtio as a physical (wire-level) transport
Date: Fri, 6 Aug 2010 08:34:28 -0700
Message-ID: <20100806153427.GB12392@ovro.caltech.edu>
References: <20100804230441.GJ23951@ovro.caltech.edu>
 <20100805213050.GA24984@redhat.com>
 <20100805230102.GD4757@ovro.caltech.edu>
 <20100805232042.GA27651@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Zang Roy <r61911@freescale.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:51933 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774Ab0HFPe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 11:34:29 -0400
Content-Disposition: inline
In-Reply-To: <20100805232042.GA27651@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 06, 2010 at 02:20:42AM +0300, Michael S. Tsirkin wrote:
> On Thu, Aug 05, 2010 at 04:01:03PM -0700, Ira W. Snyder wrote:
> > On Fri, Aug 06, 2010 at 12:30:50AM +0300, Michael S. Tsirkin wrote:
> > > Hi Ira,
> > > 
> > > > Making my life harder since the last time I tried this, mainline commit
> > > > 7c5e9ed0c (virtio_ring: remove a level of indirection) has removed the
> > > > possibility of using an alternative virtqueue implementation. The commit
> > > > message suggests that you might be willing to add this capability back.
> > > > Would this be an option?
> > > 
> > > Sorry about that.
> > > 
> > > With respect to this commit, we only had one implementation upstream
> > > and extra levels of indirection made extending the API
> > > much harder for no apparent benefit.
> > > 
> > > When there's more than one ring implementation with very small amount of
> > > common code, I think that it might make sense to readd the indirection
> > > back, to separate the code cleanly.
> > > 
> > > OTOH if the two implementations share a lot of code, I think that it
> > > might be better to just add a couple of if statements here and there.
> > > This way compiler even might have a chance to compile the code out if
> > > the feature is disabled in kernel config.
> > > 
> > 
> > The virtqueue implementation I envision will be almost identical to the
> > current virtio_ring virtqueue implementation, with the following
> > exceptions:
> > 
> > * the "shared memory" will actually be remote, on the PCI BAR of a device
> > * iowrite32(), ioread32() and friends will be needed to access the memory
> > * there will only be a fixed number of virtqueues available, due to PCI
> >   BAR size
> > * cross-endian virtqueues must work
> > * kick needs to be cross-machine (using PCI IRQ's)
> > 
> > I don't think it is feasible to add this to the existing implementation.
> > I think the requirement of being cross-endian will be the hardest to
> > overcome. Rusty did not envision the cross-endian use case when he
> > designed this, and it shows, in virtio_ring, virtio_net and vhost. I
> > have no idea what to do about this. Do you have any ideas?
> 
> My guess is sticking an if around each access in virtio would hurt,
> if this is what you are asking about.
> 

Yes, I think so too. I think using le32 byte order everywhere in virtio
would be a good thing. In addition, it means that on all x86, things
continue to work as-is. It would also have no overhead in the most
common case: x86-on-x86.

This problem is not limited to my new use of virtio. Virtio is
completely useless in a relatively common virtualization scenario:
x86 host with qemu-ppc guest. Or any other big endian guest system.

> Just a crazy idea: vhost already uses wrappers like get_user etc,
> maybe when building kernel for your board you could
> redefine these to also byteswap?
> 

I think idea is clever, but also psychotic :) I'm sure it would work,
but that only solves the problem of virtio ring descriptors. The
virtio-net header contains several __u16 fields which would also need
to be fixed-endianness.

Thanks,
Ira
