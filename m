From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 1/2][RFC] virtio_net: Enable setting MAC, promisc, and
 allmulti mode
Date: Fri, 09 Jan 2009 08:34:48 -0700
Message-ID: <1231515288.7109.203.camel@lappy>
References: <1231351562.7109.129.camel@lappy>
	 <1231500840.4481.71.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:34588 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbZAIPeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 10:34:19 -0500
In-Reply-To: <1231500840.4481.71.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-09 at 11:34 +0000, Mark McLoughlin wrote:
> On Wed, 2009-01-07 at 11:06 -0700, Alex Williamson wrote:
> > --- a/include/linux/virtio_net.h
> > +++ b/include/linux/virtio_net.h
> > @@ -23,6 +23,8 @@
> >  #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
> >  
> >  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
> > +#define VIRTIO_NET_S_PROMISC	2	/* Promiscuous mode */

Thanks for the rest of your comments and tips, I'll incorporate them.

> The current behaviour is PROMISC, right?
> 
> So, by not setting this flag you get PROMISC anyway?
> 
> Does that suggest we need a feature flag for this, or make zero reflect
> the current host behaviour ... i.e. change the bit to S_CHASTE ?
> 
> (Chaste is the antonym to promiscuous, apparently :-)

We could just have the "power on" state of virtio-net set the PROMISC
status bit, so it's up to the driver to clear it.  That's what I did for
the case of doing a load-vm from an older save state.  I think that will
give us the right behavior, but it's not clear to me if we need another
feature bit.

> > +#define VIRTIO_NET_S_ALLMULTI	4	/* All-multicast mode */
> 
> An issue here is that the LINK_UP bit is controlled by the host, but the
> PROMISC and ALLMULTI are controlled by the guest - i.e. they can race.
> 
> Suggest giving the top 8 bits to the guest and keeping the bottom 8 bits
> for the host.

Good thought, I was simply ignoring writes to the link bit.  AFAIK, it's
not uncommon that a status register on real hardware might have both RO
and RW bits next to each other.  I'm also toying with the idea that if
the mac table and vlan table gets moved to a virt-queue, maybe setting
and clearing these bits should be done via the vq too.  Thoughts?

> >  struct virtio_net_config
> >  {
> > @@ -30,7 +32,14 @@ struct virtio_net_config
> >  	__u8 mac[6];
> >  	/* Status supplied by host; see VIRTIO_NET_F_STATUS and VIRTIO_NET_S_*
> >  	 * bits above */
> > -	__u16 status;
> > +	union {
> > +		__u16 raw;
> > +		struct {
> > +			__u16 link:1;
> > +			__u16 promisc:1;
> > +			__u16 allmulti:1;
> > +		} bits;
> > +       } status;
> 
> Agree with Anthony on this, much rather we continued using the #defines.

Yeah, I do too now.  I've got a local copy working this way and it's no
messier.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

