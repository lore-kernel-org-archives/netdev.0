From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 16:43:22 +0100
Message-ID: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: <netdev@vger.kernel.org>, xen-devel <xen-devel@lists.xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:64016 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137Ab1FXPnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 11:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I was preparing Xen's netback driver for upstream one of the things
I removed was the zero-copy guest transmit (i.e. netback receive)
support.

In this mode guest data pages ("foreign pages") were mapped into the
backend domain (using Xen grant-table functionality) and placed into the
skb's paged frag list (skb_shinfo(skb)->frags, I hope I am using the
right term). Once the page is finished with netback unmaps it in order
to return it to the guest (we really want to avoid returning such pages
to the general allocation pool!). Unfortunately "page is finished with"
is an event which there is no way for the driver to see[0] and therefore
I replaced the grant-mapping with a grant-copy for upstreaming which has
performance and scalability implications (since the copy happens in, and
therefore is accounted to, the backend domain instead of the frontend
domain).

The root of the problem here is that the network stack manipulates the
paged frags using bare get/put_page and therefore has no visibility into
when a page reference count drops to zero and therefore there is no way
to provide an interface for netback to know when it has to tear down the
grant map.

I think this has implications for users other than Xen as well. For
instance I have previously observed an issue where NFS can transmit
bogus data onto the wire due to ACKs which arrive late and cross over
with the queuing of a retransmit on the client side (see
http://marc.info/?l=linux-nfs&m=122424132729720&w=2 which mainly
discusses RPC protocol level retransmit but I subsequently saw similar
issues due to TCP retransmission too). The issue here is that an ACK
from the server which is delayed in the network (but not dropped) can
arrive after a retransmission has been queued. The arrival of this ACK
causes the NFS client to complete the write back to userspace but the
same page is still referenced from the retransmitted skb. Therefore if
userspace reuses the write buffer quickly enough then incorrect data can
go out in the retransmission. Ideally NFS (and I suspect any network
filesystem or block device, e.g. iSCSI, could suffer from this sort of
issue) would be able to wait to complete the write until the buffer was
actually completely finished with.

Someone also suggested the Infiniband might also have an interest in
this sort of thing, although I must admit I don't know enough about IB
to imagine why (perhaps it's just the same as the NFS/iSCSI cases).

We've previously looked into solutions using the skb destructor callback
but that falls over if the skb is cloned since you also need to know
when the clone is destroyed. Jeremy Fitzhardinge and I subsequently
looked at the possibility of a no-clone skb flag (i.e. always forcing a
copy instead of a clone) but IIRC honouring it universally turned into a
very twisty maze with a number of nasty corner cases etc. It also seemed
that the proportion of SKBs which get cloned at least once appeared as
if it could be quite high which would presumably make the performance
impact unacceptable when using the flag. Another issue with using the
skb destructor is that functions such as __pskb_pull_tail will eat (and
free) pages from the start of the frag array such that by the time the
skb destructor is called they are no longer there.

AIUI Rusty Russell had previously looked into a per-page destructor in
the shinfo but found that it couldn't be made to work (I don't remember
why, or if I even knew at the time). Could that be an approach worth
reinvestigating?

I can't really think of any other solution which doesn't involve some
sort of driver callback at the time a page is free()d.

I expect that wrapping the uses of get/put_page in a network specific
wrapper (e.g. skb_{get,frag}_frag(skb, nr) would be a useful first step
in any solution. That's a pretty big task/patch in itself but could be
done. Might it be worthwhile in for its own sake?

Does anyone have any ideas or advice for other approaches I could try
(either on the driver or stack side)?

FWIW I proposed a session on the subject for LPC this year. The proposal
was for the virtualisation track although as I say I think the class of
problem reaches a bit wider than that. Whether the session will be a
discussion around ways of solving the issue or a presentation on the
solution remains to be seen ;-)

Ian.

[0] at least with a mainline kernel, in the older out-of-tree Xen stuff
we had a PageForeign page-flag and a destructor function in a spare
struct page field which was called from the mm free routines
(free_pages_prepare and free_hot_cold_page). I'm under no illusions
about the upstreamability of this approach...

