From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: skb->frag_list != NULL in start_xmit for device without
 NETIF_F_FRAGLIST
Date: Wed, 2 Mar 2011 13:12:26 +0000
Message-ID: <1299071546.17907.1755.camel@zakaz.uk.xensource.com>
References: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
	 <AANLkTinDmW1oirOFZCHe7yw8E8TGJfFe+fucAxOPpbjV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16686 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752140Ab1CBNM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 08:12:29 -0500
In-Reply-To: <AANLkTinDmW1oirOFZCHe7yw8E8TGJfFe+fucAxOPpbjV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

On Tue, 2011-03-01 at 23:41 +0000, Jesse Gross wrote:
> On Tue, Mar 1, 2011 at 3:46 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > Hi,
> >
> > We are seeing cases where Xen netback's start_xmit is being passed an
> > skb which has a ->frag_list, despite the driver not advertising the
> > NETIF_F_FRAGLIST feature.
> >
> > Is this indicative of a problem somewhere? Are drivers expected to
> > handle a frag_list? grepping for frag_list in drivers/net it appears not
> > many drivers do anything with the frag_list.
> 
> It certainly sounds like a problem to me.  Off the top of my head I
> don't know of any drivers that actually set and handle
> NETIF_F_FRAGLIST (except for pseudo-devices like bridging).

That's basically all I found with grep too.

> > The netback driver is bridged with a tg3 physical device and we think
> > the problematic skb's are originating on the wire.
> >
> > The case we are actually seeing is with 2.6.32 + tg3 3.110g so obviously
> > the next step is to reproduce on a more modern kernel and the in-tree
> > driver and then to attempt to determine if the fault is in what the
> > physical interface's driver is passing up the stack or in the stack's
> > handling of those skbs. Any hints on where to look would be much
> > appreciated.
> 
> I'd guess that the most likely source of frag_lists generated here are
> from GRO, in skb_gro_receive().  The driver/NIC can definitely
> influence the strategy that GRO uses for reassembly but it seems less
> likely that the driver itself will create frag_lists.

Agreed, I cant see anywhere in the driver which would do this and
skb_gro_receive does seem like the likely source of the frag list.

> > In particular I'm not sure where the frag_list is supposed to get
> > resolved in the case where dev_hard_start_xmit takes the netif_needs_gso
> > == true path and calls dev_gso_segment rather than taking the
> > __skb_linearize path (the issue appears to occur only when the netback
> > device has NETIF_F_GSO but not NETIF_F_TSO). AFAICT dev_gso_segment goes
> > to tcp_tso_segment and then to skb_segment which does appear to create
> > skbs with a frag_list (although it's not outside the realms of
> > possibility that I'm reading it wrong).
> 
> I'm fairly certain that the problem is in skb_segment().  It's not the
> most tolerant of skbs with frag_lists that do not line up with the
> requested mss.  Depending on how the original skb is laid out,
> sometimes this will trigger a BUG_ON and sometimes it creates new
> frag_lists.  Since there are no further checks after GSO, the skb with
> a frag_list will get passed to the driver, even if it is not
> supported.

I wondered if that was the case, but skb_segment made my head spin a
bit ;-)

Do you think there might be a case for adding a some skb_needs_linearize
and __skb_linearize calls on the netif_needs_gso paths too, perhaps with
some WARN_ON's?

The first check in skb_needs_linearize looks at skb->data_len, I thought
skb->data_len only covered the paged fragments but the conditions in
skb_needs_linearize seem to imply that it covers the frag_list length
too? Was I simply mistaken?

FWIW an example of the sort of thing we see is:

skb: len=0x59a, data_len=0x55a, headlen=64 (matches tail-data), no paged
frags

skb->frag_list: len=0x55a, data_len=0, headlen=0x55a (matches
tail-data), no paged frags

> I believe that not much has changed in this regard between 2.6.32 and net-next.

It turns out I cannot reproduce with either 2.6.32 (pvops xen.git) or a
more recent ((26.38-rc) kernel. The kernel where we see this is the XCP
kernel which is a 2.6.32 based thing derived from SLES11SP1 + XCP
specific updates.

I looked through the diff of net/core and net/ipv4 between a reproducing
and non-reproducing kernel and didn't see anything glaringly obvious.

Anyway, since I can't reproduce on a mainline kernel I'll stop bothering
you all with it.

Ian.


