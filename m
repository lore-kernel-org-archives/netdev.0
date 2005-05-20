From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 16:04:21 -0700
Message-ID: <1116630261.31523.42.camel@rh4>
References: <1116609329.31523.16.camel@rh4>
 <20050520194220.GA18259@havoc.gtf.org>
 <20050520.152836.48528379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050520.152836.48528379.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-05-20 at 15:28 -0700, David S.Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Fri, 20 May 2005 15:42:20 -0400
> 
> > 9) [additional review]  DaveM, others: is this correct for all arches?
> > 
> > +       if (unlikely((align = (unsigned long) skb->data & 0x7))) {
> > +               skb_reserve(skb, 8 - align);
> > +       }
> 
> It's probably not even necessary.  dev_alloc_skb() should be returning
> an SKB with skb->data at least cache_line_size() aligned (see mm/slab.c)
> unless the platform defines an ARCH_KMALLOC_MINALIGN override.

If I remember correctly, I was seeing some SKB with skb->data that is 4-
byte aligned on some Fedora kernels. I don't remember which kernel. This
device has an alignment requirement of at least 8-bytes for the receive
buffers.

> 
> > 10) [additional review] doesn't bnx2_rx_int() need to move the rmb()
> > inside the loop?  Are you protecting against the compiler
> > reordering/caching loads/stores, or against SMP CPUs?
> 
> This rmb() is needed to strongly order the status block consumer
> index read, from that of the descriptor data.  I'm pretty sure it's
> in the right spot.
> 
> > 10.1) [additional review] is the rmb() even needed in bnx2_rx_int(),
> > since its caller also uses rmb()?
> 
> No, it's guarding status block consumer index read to the first
> RX descriptor read, as explained above.

That's right. We saw rare failures in Anton's PPC environment that
caused the driver to read stale rx buffer descriptors ahead of the rx
index in the status block without the rmb().

> 
> > 13) [additional review] why is CHECKSUM_UNNECESSARY used when
> > cksum==0xffff or cksum==0 ?
> > 
> > +                       u16 cksum = rx_hdr->l2_fhdr_tcp_udp_xsum;
> > +
> > +                       if ((cksum == 0xffff) || (cksum == 0)) {
> > +                               skb->ip_summed = CHECKSUM_UNNECESSARY;
> > +                       }
> 
> For UDP, a checksum value of zero means no checksum at all.

Yes, but in this case, cksum is the checksum calculated over the entire
TCP/UDP packet including the pseudo IP header. Jeff is right, it should
always be 0xffff when the checksum is correct. Checking for zero is a
bug.

> 
> > 18) you can eliminate one call to request_irq, by lengthening the 'if' test:
> 
> Of just assigning a function pointer and set of flags to a local variable.
> Then doing on request_irq call.
> 
> > 20) is there any reason to #ifdef BCM_TSO?  2.4.x kernels I suppose?
> 
> Yeah, same for MSI stuff as well.
> 
> > 27) isn't 'timer_interval == HZ' too rapid a timer?  Does it really need
> > to fire every second?
> 
> The pulse has to be written the the chip at least once every 50 milliseconds,
> or else the chip goes into OS absent mode.  Anyways, the timer interval can
> probably be extended, although link probing at 1 second intervals does seem
> reasonable.
> 
> 

Originally, the driver pulse interval was set at 250 msec, but it's been
extended to a few seconds. So the driver currently will write the pulse
every second and do the serdes related checking at the same time.

David, Do you want me to fix some of these things and send you a new
500K patch or just send incremental patches over the existing driver?
