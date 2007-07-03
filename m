From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH 2/9] pasemi_mac: Clean TX ring in poll
Date: Tue, 3 Jul 2007 15:31:31 -0500
Message-ID: <20070703203131.GA26181@lixom.net>
References: <20070622194720.614405000@lixom.net> <20070622200501.GC11723@lixom.net> <4688F0CE.9020600@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:35381 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757002AbXGCUVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 16:21:01 -0400
Content-Disposition: inline
In-Reply-To: <4688F0CE.9020600@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 08:34:22AM -0400, Jeff Garzik wrote:
> >Index: netdev-2.6/drivers/net/pasemi_mac.c
> >===================================================================
> >--- netdev-2.6.orig/drivers/net/pasemi_mac.c
> >+++ netdev-2.6/drivers/net/pasemi_mac.c
> >@@ -1052,6 +1052,7 @@ static int pasemi_mac_poll(struct net_de
> > 	int pkts, limit = min(*budget, dev->quota);
> > 	struct pasemi_mac *mac = netdev_priv(dev);
> > 
> >+	pasemi_mac_clean_tx(mac);
> > 	pkts = pasemi_mac_clean_rx(mac, limit);
> 
> Why is this needed?  Is your TX interrupt mitigated or delayed somehow?

On some level hardware, we only have the possibility of taking the
TX interrupt after a certain number of packets, and no way of doing a
(hw) timer-based one (i.e.  after no packets have been sent for x ms,
interrupt). Taking an interrupt for every TX packet isn't an interesting
proposal, and doing it solely based on count > 1 can leave stale packets
there for a long time when the network is otherwise idle.

So, I would need to do a software based timer. The poll function seemed like
a good enough solution for now though, since it's called periodically even
when the NAPI mode is such that interrupts are enabled.

> In general, drivers should only clean TX in one place.  Doing so in 
> multiple places tends to indicate a bug somewhere.

Yes, I wish I could just do it in the interrupt handler. I could do it
with a dedicated timer if you prefer, but I'd still need to have two
ways of entering the tx clean function.


-Olof
