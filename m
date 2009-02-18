From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
Date: Wed, 18 Feb 2009 08:38:35 -0800
Message-ID: <20090218163835.GA29728@ovro.caltech.edu>
References: <20090217222425.GA18801@ovro.caltech.edu> <200902181713.03820.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:59533 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbZBRQih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 11:38:37 -0500
Content-Disposition: inline
In-Reply-To: <200902181713.03820.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2009 at 05:13:03PM +1030, Rusty Russell wrote:
> On Wednesday 18 February 2009 08:54:25 Ira Snyder wrote:
> > This adds support to Linux for using virtio between two computers linked by
> > a PCI interface. This allows the use of virtio_net to create a familiar,
> > fast interface for communication. It should be possible to use other virtio
> > devices in the future, but this has not been tested.
> 
> Hi Ira,
> 
>   It's only first glance, but this looks sane.  Two things on first note:
> don't restrict yourself to 32 feature bits (only PCI does this, and they're
> going to have to hack when we reach feature 32).
> 

There isn't any problem adding more feature bits. Do you think 128 bits
is enough?

>   Secondly:
> > +You will notice that the algorithm has no way of handling chains that are
> > +not exactly the same on the host and guest system. Without setting any of
> > +the fancier virtio_net features, this is the case.
> 
> Hmm, I think we can do slightly better than this.
> 

I think so too :) I just wasn't able to come up with an algorithm to
make it work. And I wanted input from more experienced people.

> How about prepending a 4 byte length on the host buffers?  Allows host to
> specify length (for host->guest), and guest writes it to allow truncated
> buffers on guest->host.
> 
> That won't allow you to transfer *more* than one buffersize to the host, but
> you could use a different method (perhaps the 4 bytes indicates the *total*
> length?).
> 

I don't understand how this will help.

I looked at virtio_net's implemention with VIRTIO_NET_F_MRG_RXBUF, which
seems like it could really help performance. The problems with that are:
1) virtio_net doesn't write the merged header's num_buffers field
2) virtio_net doesn't actually split packets in xmit

The problem with 1 is that one instance of virtio_net cannot talk to
another, if they're using that feature. The sender never sets the field,
so the receiver doesn't know how many buffers to expect.

I'm using two instances of virtio_net to talk to each other, rather than
a special userspace implementation like lguest and kvm use. Is this a
good approach?

The problem with 2 is that xmit may add the following to the
descriptors: (the network stack doesn't have to split the packet)

idx address  len flags next
0   XXXXXXX   12     N    1
1   XXXXXXX 8000     -    2

With VIRTIO_NET_F_MRG_RXBUF, the other side's recv ring will look like
the following:

idx address  len flags next
0   YYYYYYY 4096     -    1
1   YYYYYYY 4096     -    2
2   YYYYYYY 4096     -    3
....

So how do we pair up buffers to do DMA? Do I munge the header from
virtio_net to set the num_headers field, and split the 8000 bytes of
data into two parts? (Giving 12 bytes in desc 0, 4096 bytes in desc 1,
and 3904 bytes in desc 2)


The current implementation only handles something like the following,
which would be an ARP:

xmit descriptors:
idx address  len flags next
0   XXXXXXX   10     N    1
1   XXXXXXX   42     -    2


recv descriptors:
idx address  len flags next
0   YYYYYYY   10     N    1
1   YYYYYYY 1518     -    2
....

Then the algorithm is simple, no munging necessary. All chains are the
same length (2 entries) and the length of each buffer is suffient to
handle the data. The network stack splits the packets into <= 1518 byte
chunks for us (as long as MTU isn't changed).

> Do 4-byte DMA's suck for some reason?
> 

I don't think it would hurt much. Some of the fancier features might
offset any overhead that is added.


Thanks, I appreciate the feedback.
Ira
