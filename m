From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Thu, 7 Nov 2013 16:18:38 -0800
Message-ID: <20131108001838.GB11529@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73EF@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53216 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753806Ab3KHASn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 19:18:43 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73EF@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 05:20:49PM -0000, David Laight wrote:
> 
> Section 4.11.7.1 of rev 1.0 of the xhci specification states that a link TRB
> can only occur at a boundary between underlying USB frames (512 bytes for 480M).

Which version of the spec are you looking at?  I'm looking at the
updated version from 08/2012 and I don't see any such requirement.

I do see that section says "A TD Fragment shall not span Transfer Ring
Segments" where a TD fragment is defined as exact multiples of Max Burst
Size * Max Packet Size bytes for the endpoint.  Is that what you mean
about USB frames?

> If this isn't done the USB frames aren't formatted correctly and, for example,
> the USB3 ethernet ax88179_178a card will stop sending (while still receiving)
> when running a netperf tcp transmit test with (say) and 8k buffer.

Which driver does that use?  Is it using the scatter gather list
mechanism for URBs (i.e. urb->sg)?  Or is it submitting multiple URBs
for fragmented buffers?  Or is it submitting isochronous URBs with
multiple frames?  Or is it submitting bulk URBs with one transfer buffer
that crosses the 64KB boundary?

I'm trying to understand what the USB device driver is doing in order to
create multi-TRB TDs that would violate the TD fragment rules.

> While this change improves things a lot (it runs for 20 minutes rather than
> a few seconds), there is still something else wrong.
> 
> This should be a candidate for stable, the ax88179_178a driver defaults to
> gso and tso enabled so it passes a lot of fragmented skb to the USB stack.

I want to understand what the larger issue is here before pushing
bandaid fixes.

I don't think this is the right approach, because prepare_ring() can be
called for isochronous URBs that get mapped to multiple TDs.  The TD
fragment rules only apply to one TD, so failing URB submission because
many isochronous TDs span more than one ring segment doesn't seem like
the right approach.  Inserting no-op TRBs will also result in odd
isochronous behavior, since a no-op TRB means the xHC should not send or
request an isochronous packet for that service interval.

The patch also doesn't address the underlying issue of constructing
multi-TRB TDs so that it fits the TD fragment rules.  Your patch ensures
there are no link TRBs in the middle of a TD, but it doesn't ensure that
the TRBs in the TD are exact multiples of the Max Burst Size * Max
Packet Size bytes for the endpoint.

Instead, new code in count_sg_trbs_needed() should break the TD into
proper TD fragments.  The queueing code for all endpoints would also
have to follow those rules.  This would have to happen while still
respecting the 64KB boundary rule.

The driver would also have to make sure that TD fragments didn't have
link TRBs in them.  That's an issue, since the spec decidedly unclear
about what exactly comprises a TD fragment.  Is the xHC host greedy, and
will lump all multiples into one TD fragment?  Or will it assume the TD
fragment has ended once it consumes one multiple of Max Burst Size * Max
Packet Size bytes?

This ambiguity means it's basically impossible to figure out whether a
TD with a link TRB in the middle is constructed properly.  The xHCI spec
architect didn't have a good solution to this problem, so I punted and
never implemented TD fragments.  If this is really an issue, it's going
to be pretty complex to solve.

> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
> 
> Although I've got a USB2 analyser its trigger and trace stuff is almost
> unusable! In any case this fails much faster on USB3 (Intel i7 cpu).

I thought you were using a big endian system?

> diff --git a/drivers/usb/host/xhci-ring.c b/drivers/usb/host/xhci-ring.c
> index 5480215..23abc9b 100644
> --- a/drivers/usb/host/xhci-ring.c
> +++ b/drivers/usb/host/xhci-ring.c
> @@ -2927,8 +2932,43 @@ static int prepare_ring(struct xhci_hcd *xhci, struct xhci_ring *ep_ring,
>  	}
>  
>  	while (1) {
> -		if (room_on_ring(xhci, ep_ring, num_trbs))
> -			break;
> +		if (room_on_ring(xhci, ep_ring, num_trbs)) {
> +			union xhci_trb *trb = ep_ring->enqueue;
> +			unsigned int usable = ep_ring->enq_seg->trbs +
> +					TRBS_PER_SEGMENT - 1 - trb;
> +			u32 nop_cmd;
> +
> +			/*
> +			 * Section 4.11.7.1 TD Fragments states that a link
> +			 * TRB must only occur at the boundary between
> +			 * data bursts (eg 512 bytes for 480M).
> +			 * While it is possible to split a large fragment
> +			 * we don't know the size yet.
> +			 * Simplest solution is to fill the trb before the
> +			 * LINK with nop commands.
> +			 */
> +			if (num_trbs == 1 || num_trbs <= usable || usable == 0)
> +				break;
> +
> +			if (num_trbs >= TRBS_PER_SEGMENT) {
> +				xhci_err(xhci, "Too many fragments %d, max %d\n",
> +						num_trbs, TRBS_PER_SEGMENT - 1);
> +				return -ENOMEM;
> +			}
> +
> +			nop_cmd = cpu_to_le32(TRB_TYPE(TRB_TR_NOOP) |
> +					ep_ring->cycle_state);
> +			for (; !TRB_TYPE_LINK_LE32(trb->link.control); trb++) {
> +				trb->generic.field[0] = 0;
> +				trb->generic.field[1] = 0;
> +				trb->generic.field[2] = 0;
> +				trb->generic.field[3] = nop_cmd;
> +				ep_ring->num_trbs_free--;
> +			}
> +			ep_ring->enqueue = trb;
> +			if (room_on_ring(xhci, ep_ring, num_trbs))
> +				break;
> +		}
>  
>  		if (ep_ring == xhci->cmd_ring) {
>  			xhci_err(xhci, "Do not support expand command ring\n");

Sarah Sharp
