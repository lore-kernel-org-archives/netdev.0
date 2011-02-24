From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH v2] xen network backend driver
Date: Thu, 24 Feb 2011 13:23:12 +0000
Message-ID: <1298553792.5034.391.camel@zakaz.uk.xensource.com>
References: <1297160635.9149.21.camel@zakaz.uk.xensource.com>
	 <20110215213512.GA5587@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26009 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab1BXNXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 08:23:15 -0500
In-Reply-To: <20110215213512.GA5587@dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Konrad,

Sorry it took me a while to get back to this, got distracted by other
things.

On Tue, 2011-02-15 at 21:35 +0000, Konrad Rzeszutek Wilk wrote: 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> 
> Hey Ian,
> 
> I took a look at and provided some input. I got lost with the
> GSO, credit code, fragments, and the host of the other features
> that can get negotiated.  Will need to re-educate myself on the
> networking code some more.
> 
> Sure changed a lot since 2.6.18..

Everything up to upstream/dom0/backend/netback-base was in the xen.git
xen/next/2.6.32 branch, apart from the last ~half-dozen which are in an
outstanding pull request for that tree. I've added a lot of cleanup
stuff on top of that though.

> Would it make sense to split the review in the netback and netfront
> in two different patchsets (you might need to overlap the headers
> that define the operations .. which is OK)?

I've been thinking about whether to do this. The problem then becomes
how to maintain bisectability across both sides of the netback merge
(assuming the netfront bits went in first). On balance I think that
since the netfront changes are just mechanical renaming of variable
names it isn't worth the overhead of splitting it out into another
series unless someone insists.

As an aside trimming your quotes when reviewing a patch of this size is
useful -- it's quite hard to spot the couple of dozen lines of review in
among the ~3k lines of diff.

[...]
> > +
> > +#include <xen/interface/io/netif.h>
> > +#include <asm/pgalloc.h>
> 
> I don't think you need that file. Yeah, tested and it
> compiles fine.

Right, must be leftover from previous functionality.

> 
> > +#include <xen/interface/grant_table.h>
> > +#include <xen/grant_table.h>
> > +#include <xen/xenbus.h>
> > +
> > +struct xen_netbk;
> > +
> > +struct xenvif {
> > +     /* Unique identifier for this interface. */
> > +     domid_t          domid;
> > +     unsigned int     handle;
> > +
> > +     /* */
> 
> Looks like there was a comment there, but it went away?

There was an intention to add a comment ;-) Which I've now done.

> > +     snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
> > +     dev = alloc_netdev(sizeof(struct xenvif), name, ether_setup);
> > +     if (dev == NULL) {
> > +             pr_debug("Could not allocate netdev\n");
> 
> pr_warn?

ACK.

> > +     if (err) {
> > +             pr_debug("Could not register new net device %s: err=%d\n",
> > +                      dev->name, err);

> pr_warn?

Yes. Here and in a bunch of other places I actually switched to netdev_foo too.

> > +
> > +     if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
> > +             BUG();
> 
> How about something less severe? Say return the error code?

Yes, I folded this into the following check of op.status.

> > +             HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &unop, 1);
> > +             pr_debug("Gnttab failure mapping rx_ring_ref!\n");
> 
> pr_warn I think.

Done.

> > +#define MAX_BUFFER_OFFSET PAGE_SIZE
> 
> Why not use PAGE_SIZE instead of MAX_BUFFER_OFFSET?

It used to be < PAGE_SIZE until I convinced myself it was safe.

Old guests used to keep book-keeping stuff at the end of the page, so
the maximum offset was PAGE_SIZE/2 for safety. However those kernels
predate the addition of the scatter-gather support in the PV protocol
and the only way we take a path where MAX_BUFFER_OFFSET matters is if SG
is enabled, otherwise MTU <= 1500 and hence an individual SKB cannot
fill a guest with more than 1500 bytes.

I think the MAX_BUFFER_OFFSET name makes the intention clearer.

> > +     /*
> > +      * Each head or fragment can be up to 4096 bytes. Given
> > +      * MAX_BUFFER_OFFSET of 4096 the worst case is that each
> > +      * head/fragment uses 2 copy operation.
> 
> For an MTU of 9000 won't we have two fragments and one head?

Not necessarily, you can end up with any (within reason) combination of
bits in the head and frags adding up to the MTU (or more if GSO is on)

This comment is a bit out of date -- we now handle heads which cross
page boundaries where previously netbk_copy_skb would have modified
things such that the head didn't cross a page by copying bits into frag
space. 

I changed it to:
	/*
	 * Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
	 * head/fragment page uses 2 copy operations because it
	 * straddles two buffers in the frontend.
	 */

> > +      */
> > +     struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
> > +     unsigned char rx_notify[NR_IRQS];
> 
> So a 2KB array on which we poke a value most of the time (if not all)
> past the nr_irq_gsi.. Is there a better way of doing this?

This and ...

> > +     u16 notify_list[XEN_NETIF_RX_RING_SIZE];

... this are effectively used to implement a queue of vifs which have a
pending irq notification saved up which is created while processing the
list of skbs (which may come from a variety of vif interfaces) in
xen_netbk_rx_action and dequeued later in that same function.

The reason for not simply notifying as we send is that this allow us to
collect all the notifications for a vif arising from a given pass over
the queue into a single notification.

Anyway, I've replaced these arrays with a list_head in each vif.

> > +     while (size > 0) {
> > +             BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
> > +
> > +             if (start_new_rx_buffer(npo->copy_off, size, *head)) {
> > +                     /*
> > +                      * Netfront requires there to be some data in the head
> > +                      * buffer.
> > +                      */
> > +                     BUG_ON(*head);
> 
> What if we just WARN?

This is an assertion and should never happen by construction, if someone
breaks it we want them to find out pretty quickly.

> > +     for (i = 0; i < nr_meta_slots; i++) {
> > +             copy_op = npo->copy + npo->copy_cons++;
> > +             if (copy_op->status != GNTST_okay) {
> > +                             pr_debug("Bad status %d from copy to DOM%d.\n",
> > +                                      copy_op->status, domid);
> 
> pr_warn or pr_info?

I'm wary of the guest guest being able to trigger that particular message.

> > +                             status = XEN_NETIF_RSP_ERROR;
> 
> should we just break here?

I think it's useful to know if there are a rash of these or just a one
off. Also the loop increments copy_cons (not that this couldn't be
solved by the application of mathematics ;-))

> > +kick:
> > +     smp_mb();
> > +     if ((nr_pending_reqs(netbk) < (MAX_PENDING_REQS/2)) &&
> 
> Would it make sense to make this a runtime knob to increase/decrease
> the batching count?

AFAIK It's not something which has been identified as a particular
bottleneck or whatever. I'm wary of adding knobs just for the sake of
it. Far better just to provide the user with the right number which
works.

> > +     if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-sg",
> > +                      "%d", &val) < 0)
> > +             val = 0;
> > +     vif->can_sg = !!val;
> > +
> > +     if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
> > +                      "%d", &val) < 0)
> > +             val = 0;
> > +     vif->gso = !!val;
> > +
> > +     if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-prefix",
> > +                      "%d", &val) < 0)
> > +             val = 0;
> > +     vif->gso_prefix = !!val;
> > +
> > +     if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-offload",
> > +                      "%d", &val) < 0)
> > +             val = 0;
> > +     vif->csum = !val;
> 
> Would it make sense to have a URL link or a short explanation of what each
> feature provides?

More documentation is always useful but I'm not sure the PV network
protocol should be documented in one particular implementation of it. A
spec on xen.org would be better I think, and that's (perpetually :-() on
my todo list.

Ian.

