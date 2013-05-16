From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Thu, 16 May 2013 15:09:06 +0300
Message-ID: <20130516120906.GC31841@redhat.com>
References: <5119E9DC.3000505@dlhnet.de>
 <1368541284.15129.317.camel@eboracum.office.bytemark.co.uk>
 <519249F6.3000900@dlhnet.de>
 <1368542949.15129.354.camel@eboracum.office.bytemark.co.uk>
 <1368615603.15129.1471.camel@eboracum.office.bytemark.co.uk>
 <20130516062405.GA26548@redhat.com>
 <20130516062743.GB26548@redhat.com>
 <1368692455.15129.1475.camel@eboracum.office.bytemark.co.uk>
 <20130516084021.GA28125@redhat.com>
 <1368703672.15129.1501.camel@eboracum.office.bytemark.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Lieven <pl@dlhnet.de>, Stefan Hajnoczi <stefanha@gmail.com>,
	qemu-devel@nongnu.org, netdev@vger.kernel.org
To: Nicholas Thomas <nick@bytemark.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30098 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033Ab3EPMJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 08:09:07 -0400
Content-Disposition: inline
In-Reply-To: <1368703672.15129.1501.camel@eboracum.office.bytemark.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 12:27:52PM +0100, Nicholas Thomas wrote:
> On Thu, 2013-05-16 at 11:40 +0300, Michael S. Tsirkin wrote:
> > On Thu, May 16, 2013 at 09:20:55AM +0100, Nicholas Thomas wrote:
> > > Hi,
> > > 
> > > On Thu, 2013-05-16 at 09:27 +0300, Michael S. Tsirkin wrote:
> > > > On Thu, May 16, 2013 at 09:24:05AM +0300, Michael S. Tsirkin wrote:
> > > > > Is this with or without vhost-net in host?
> > > > 
> > > > never mind, I see it's without.
> > > > Try to enable vhost-net (you'll have to switch to -netdev syntax
> > > > for that to work) and see if this help.
> > > > If it does it's likely a qemu bug if not probably a guest bug.
> > > 
> > > Switching to -netdev is non-trivial for me, unfortunately.
> > 
> > Interesting. Why is that?
> 
> Our setup is bond0 <-> vlanX <-> bridgeX <-> [ tap devices ] and we do
> all that outside of qemu at the moment, specifying -net tap,ifname=... -
> we also run some processes on the TAP interface and insert a bunch of
> ebtables rules between creating it and starting qemu. Duplicating that
> with -net bridge seemed close to impossible, and -netdev tap was
> throwing EBUSY from /dev/net/tun. I guess our external magic should be
> using ,fd= instead.

I'm not sure what's wrong with -netdev tap.
You don't have to use fd=, you can specify ifname= with netdev as well.
Here's what I use:

-net nic,model=virtio,netdev=foo
-netdev tap,id=foo,ifname=msttap0,script=/home/mst/ifup,downscript=no,vhost=on

the netdev/id pair above is almost the same as vlan=20
in your example, except there's always exactly one frontend
and one backend in the netdev case, vlans let you connect
more than 2 devices.

> > > Anyway, it's
> > > definitely a qemu bug - it happens on kernels 3.2 and 3.9 with 1.4.1,
> > > but doesn't happen with qemu 0.15.0 or 1.5.0rc1.
> > > 
> > > I'll have a dig through git to see if I can identify the patch that
> > > resolves it. It feels-like qemu sometimes stops reading from the tap
> > > file descriptor between ipxe exiting and the linux kernel bringing up
> > > the network interface, and never recovers from that.
> > > 
> > > /Nick
> > 
> > You can try to bisect, yes.
> 
> Work have decided to accept 1.5.0 when it arrives instead, so I'm afraid
> I won't be working on this after all. 
> 
> /Nick
> 
> 
