From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: skb->frag_list != NULL in start_xmit for device without
 NETIF_F_FRAGLIST
Date: Tue, 1 Mar 2011 11:46:59 +0000
Message-ID: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <Paul.Durrant@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60964 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756288Ab1CALrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 06:47:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are seeing cases where Xen netback's start_xmit is being passed an
skb which has a ->frag_list, despite the driver not advertising the
NETIF_F_FRAGLIST feature.

Is this indicative of a problem somewhere? Are drivers expected to
handle a frag_list? grepping for frag_list in drivers/net it appears not
many drivers do anything with the frag_list.

The netback driver is bridged with a tg3 physical device and we think
the problematic skb's are originating on the wire.

The case we are actually seeing is with 2.6.32 + tg3 3.110g so obviously
the next step is to reproduce on a more modern kernel and the in-tree
driver and then to attempt to determine if the fault is in what the
physical interface's driver is passing up the stack or in the stack's
handling of those skbs. Any hints on where to look would be much
appreciated.

In particular I'm not sure where the frag_list is supposed to get
resolved in the case where dev_hard_start_xmit takes the netif_needs_gso
== true path and calls dev_gso_segment rather than taking the
__skb_linearize path (the issue appears to occur only when the netback
device has NETIF_F_GSO but not NETIF_F_TSO). AFAICT dev_gso_segment goes
to tcp_tso_segment and then to skb_segment which does appear to create
skbs with a frag_list (although it's not outside the realms of
possibility that I'm reading it wrong).

I did wonder if perhaps we should just ignore the field, since something
higher up the stack walked the list and called start_xmit repeatedly,
but if that's the case I can't see where...

Ian.


