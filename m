From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: NAPI and shared interrupt control
Date: Thu, 07 Dec 2006 15:21:40 +1100
Message-ID: <1165465300.5469.187.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40750 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968733AbWLGEVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 23:21:50 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave !

I'd like your advice on something we need to deal with in the EMAC
ethernet driver (an IBM part). The driver is maintainedby Eugene (CC'd),
I'm mostly adding support for some new hardware at this point, which
involves making it SMP safe among other things ;-)

So the problem this driver has is with NAPI polling and its shared DMA
engine. Basically, the DMA engine can be shared between several EMAC
ethernet cells. It has separate "channels" (and thus separate rings) so
in that area, all is fine... except the interrupt control. The is only
one global interrupt enable/disable bit for packet interrupts, shared by
all the EMACs using that DMA engine cell.

That means complications for NAPI polling as we can't just
disable/enable Rx interrupts as NAPI would normally expect on a
per-device basis.

What Eugene does currently, which seems to me like it's actually the
only proper solution, is to create a separate net_device structure for
the DMA engine and thus have a single NAPI poll & weighting for all the
EMACs sharing a given MAL (MAL is the name of that DMA engine). This
means that Rx from any of the channels schedules the poll, and
interrupts can be properly masked/unmasked globally based on the
presence/absence of work on all the channels.

I'd still like to run it through you, make sure you are ok or see if you
have a better idea as you are way more familiar with the network stack
than I am :-)

My main concern with the approach is purely due to how the additional
net_device is initialized. It's currently allocated as part of some
private data structure in the driver which then manually initializes
some fields that are used by NAPI polling. While it certainly works, I
find the approach a bit fragile (what if the NAPI code internals change
and some initialisations have to be done differently ?)

Thus I was wondering, if you think the approach is sane, wether it would
make sense to provide a low level netif_init_device() thingy that makes
sure a net_device data structure is fully initialized and suitable for
use ? (make sure spinlocks are initialized etc...). Something similar to
the code used to initialize the backlog "fake" device ?

The driver currently does:

	set_bit(__LINK_STATE_START, &mal->poll_dev.state);
	mal->poll_dev.weight = CONFIG_IBM_EMAC_POLL_WEIGHT;
	mal->poll_dev.poll = mal_poll;
	mal->poll_dev.priv = mal;
	atomic_set(&mal->poll_dev.refcnt, 1);

(None of the spinlocks are initialized, but then, the driver was only
ever used on UP only embedded CPUs so far and it's possible that none of
the NAPI code path for which this net_device structure is used are
hitting any spinlock). 

Or do you think that net_device should be fully registered with
register_netdev ? (that would involve a lot more than what is currently
needed/used though).

Cheers,
Ben.

