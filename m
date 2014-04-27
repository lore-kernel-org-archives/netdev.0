From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: RFC: sharing config interrupt between virtio devices for saving
 MSI
Date: Sun, 27 Apr 2014 18:44:16 +0300
Message-ID: <20140427154416.GA19772@redhat.com>
References: <20140330111427.GD24476@redhat.com>
 <20140419040815.GB4681@amosk.info>
 <20140427143541.GA8623@amosk.info>
 <20140427150304.GA19401@redhat.com>
 <20140427152214.GA25172@amosk.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: Amos Kong <akong@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858AbaD0Pn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2014 11:43:28 -0400
Content-Disposition: inline
In-Reply-To: <20140427152214.GA25172@amosk.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2014 at 11:22:14PM +0800, Amos Kong wrote:
> On Sun, Apr 27, 2014 at 06:03:04PM +0300, Michael S. Tsirkin wrote:
> > On Sun, Apr 27, 2014 at 10:35:41PM +0800, Amos Kong wrote:
> > > On Sat, Apr 19, 2014 at 12:08:15PM +0800, Amos Kong wrote:
> > > > 
> > > > Hi all,
> > > > 
> > > > I'm working on this item in Upstream Networking todolist:
> > > > 
> > > > | - Sharing config interrupts
> > > > |    Support more devices by sharing a single msi vector
> > > > |    between multiple virtio devices.
> > > > |    (Applies to virtio-blk too).
> > > > 
> > > > I have this solution here, and only have draft patches of Solution
> > > > 1 & 2, let's discuss if solution 3 is feasible.
> > > > 
> > > > * We should not introduce perf regression in this change
> > > > * little effect is acceptable because we are _sharing_ interrupt
> > > > 
> > > > Solution 1:
> > > > ==========
> > > > share one LSI interrupt for configuration change of all virtio devices.
> > > > Draft patch: share_lsi_for_all_config.patch
> > > > 
> > > > Solution 2:
> > > > ==========
> > > > share one MSI interrupt for configuration change of all virtio devices.
> > > > Draft patch: share_msix_for_all_config.patch
> > > > 
> > > > Solution 3:
> > > > ==========
> > > > dynamic adjust interrupt policy when device is added or removed
> > > > Current:
> > > > -------
> > > > - try to allocate a MSI to device's config
> > > > - try to allocate a MSI for each vq
> > > > - share one MSI for all vqs of one device
> > > > - share one LSI for config & vqs of one device
> > > > 
> > > > additional dynamic policies:
> > > > ---------------------------
> > > > - if there is no enough MSI, adjust interrupt allocation for returning
> > > >   some MSI
> > > >    - try to find a device that allocated one MSI for each vq, change
> > > >      it to share one MSI for saving the MSI
> > > >    - try to share one MSI for config of all virtio_pci devices
> > > >    - try to share one LSI for config of all devices
> > > > 
> > > > - if device is removed, try to re-allocate freed MSI to existed
> > > >   devices, if they aren't in best status (one MSI for config, one
> > > >   MSI for each vq)
> > > >    - if config of all devices is sharing one LSI, try to upgrade it to MSI
> > > >    - if config of all devices is sharing one MSI, try to allocate one
> > > >      MSI for configuration change of each device
> > > >    - try to find a device that is sharing one MSI for all vqs, try to
> > > >      allocate one MSI for each vq
> > > 
> > > Hi Michael, Alex
> > > 
> > > Any thoughts about this ? :)
> > > 
> > > 
> > > Thanks, Amos
> > 
> > 
> > I don't think we need to worry about dynamic.
>  
> Dynamic policy can always get good balance. If we use a fixed policy,
> devices might share IRQ with some unused msix, or sometimes it's not
> fair enough for all devices.


Yes but can we not make this up to the OS as a whole?
Why would we want to make this virtio specific?


> > Questions: just by using IRQF_SHARED, do we always end
> > up with a shared interrupt? Or only if system is running
> > out of vectors?
> 
> In solution1: always share one LSI for config of all virtio devices

Don't get this one. LSI is already shared unconditionally.

> In solution2: always share one MSI for config of all virtio devices
>
> > Did you test that interrupt is actually shared and all
> > handlers are called?
> 
> Yes. I can find many devices (virtio.0, virtio.1,...) share same
> interrupt in guest's /proc/interrupts. And nics work well.

I haven't looked into this, I would imagine that we mark
the config interrupt as shared, then linux would
start by allocating dedicated interrupts but as we start
running out of these, consolidate interrupts together.
This isn't what's happening?

> > We don't stop after the 1st handler that
> > returned OK?
> 
> When we set IRQF_SHARED flag, dev_id is necessary. In
> irq_wake_thread() it's used to identify the device for which
> the irq_thread should be woke.
> So when we share one IRQ, one single interrupt will only wake one
> handler once.
> 
> -- 
> 			Amos.
