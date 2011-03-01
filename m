From: Jesse Gross <jesse@nicira.com>
Subject: Re: skb->frag_list != NULL in start_xmit for device without NETIF_F_FRAGLIST
Date: Tue, 1 Mar 2011 15:41:38 -0800
Message-ID: <AANLkTinDmW1oirOFZCHe7yw8E8TGJfFe+fucAxOPpbjV@mail.gmail.com>
References: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Paul Durrant <Paul.Durrant@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62752 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799Ab1CAXlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:41:39 -0500
Received: by vxi39 with SMTP id 39so4725592vxi.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 15:41:38 -0800 (PST)
In-Reply-To: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2011 at 3:46 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> Hi,
>
> We are seeing cases where Xen netback's start_xmit is being passed an
> skb which has a ->frag_list, despite the driver not advertising the
> NETIF_F_FRAGLIST feature.
>
> Is this indicative of a problem somewhere? Are drivers expected to
> handle a frag_list? grepping for frag_list in drivers/net it appears not
> many drivers do anything with the frag_list.

It certainly sounds like a problem to me.  Off the top of my head I
don't know of any drivers that actually set and handle
NETIF_F_FRAGLIST (except for pseudo-devices like bridging).

>
> The netback driver is bridged with a tg3 physical device and we think
> the problematic skb's are originating on the wire.
>
> The case we are actually seeing is with 2.6.32 + tg3 3.110g so obviously
> the next step is to reproduce on a more modern kernel and the in-tree
> driver and then to attempt to determine if the fault is in what the
> physical interface's driver is passing up the stack or in the stack's
> handling of those skbs. Any hints on where to look would be much
> appreciated.

I'd guess that the most likely source of frag_lists generated here are
from GRO, in skb_gro_receive().  The driver/NIC can definitely
influence the strategy that GRO uses for reassembly but it seems less
likely that the driver itself will create frag_lists.

>
> In particular I'm not sure where the frag_list is supposed to get
> resolved in the case where dev_hard_start_xmit takes the netif_needs_gso
> == true path and calls dev_gso_segment rather than taking the
> __skb_linearize path (the issue appears to occur only when the netback
> device has NETIF_F_GSO but not NETIF_F_TSO). AFAICT dev_gso_segment goes
> to tcp_tso_segment and then to skb_segment which does appear to create
> skbs with a frag_list (although it's not outside the realms of
> possibility that I'm reading it wrong).

I'm fairly certain that the problem is in skb_segment().  It's not the
most tolerant of skbs with frag_lists that do not line up with the
requested mss.  Depending on how the original skb is laid out,
sometimes this will trigger a BUG_ON and sometimes it creates new
frag_lists.  Since there are no further checks after GSO, the skb with
a frag_list will get passed to the driver, even if it is not
supported.

I believe that not much has changed in this regard between 2.6.32 and net-next.

> I did wonder if perhaps we should just ignore the field, since something
> higher up the stack walked the list and called start_xmit repeatedly,
> but if that's the case I can't see where...

That will happen for GSO but those packets shouldn't have a frag_list
if the driver doesn't support it.
