From: "David S. Miller" <davem@davemloft.net>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 15:28:36 -0700 (PDT)
Message-ID: <20050520.152836.48528379.davem@davemloft.net>
References: <1116609329.31523.16.camel@rh4>
	<20050520194220.GA18259@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <20050520194220.GA18259@havoc.gtf.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 20 May 2005 15:42:20 -0400

> 9) [additional review]  DaveM, others: is this correct for all arches?
> 
> +       if (unlikely((align = (unsigned long) skb->data & 0x7))) {
> +               skb_reserve(skb, 8 - align);
> +       }

It's probably not even necessary.  dev_alloc_skb() should be returning
an SKB with skb->data at least cache_line_size() aligned (see mm/slab.c)
unless the platform defines an ARCH_KMALLOC_MINALIGN override.

> 10) [additional review] doesn't bnx2_rx_int() need to move the rmb()
> inside the loop?  Are you protecting against the compiler
> reordering/caching loads/stores, or against SMP CPUs?

This rmb() is needed to strongly order the status block consumer
index read, from that of the descriptor data.  I'm pretty sure it's
in the right spot.

> 10.1) [additional review] is the rmb() even needed in bnx2_rx_int(),
> since its caller also uses rmb()?

No, it's guarding status block consumer index read to the first
RX descriptor read, as explained above.

> 13) [additional review] why is CHECKSUM_UNNECESSARY used when
> cksum==0xffff or cksum==0 ?
> 
> +                       u16 cksum = rx_hdr->l2_fhdr_tcp_udp_xsum;
> +
> +                       if ((cksum == 0xffff) || (cksum == 0)) {
> +                               skb->ip_summed = CHECKSUM_UNNECESSARY;
> +                       }

For UDP, a checksum value of zero means no checksum at all.

> 18) you can eliminate one call to request_irq, by lengthening the 'if' test:

Of just assigning a function pointer and set of flags to a local variable.
Then doing on request_irq call.

> 20) is there any reason to #ifdef BCM_TSO?  2.4.x kernels I suppose?

Yeah, same for MSI stuff as well.

> 27) isn't 'timer_interval == HZ' too rapid a timer?  Does it really need
> to fire every second?

The pulse has to be written the the chip at least once every 50 milliseconds,
or else the chip goes into OS absent mode.  Anyways, the timer interval can
probably be extended, although link probing at 1 second intervals does seem
reasonable.
