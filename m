From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: carrier off initially to avoid root mount
 failure
Date: Sun, 10 Oct 2010 21:19:56 -0700 (PDT)
Message-ID: <20101010.211956.112597497.davem@davemloft.net>
References: <1286454630-7396-1-git-send-email-oskar@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan@embeddedalley.com,
	bigeasy@linutronix.de, hjk@linutronix.de
To: oskar@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48808
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713Ab0JKETe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 00:19:34 -0400
In-Reply-To: <1286454630-7396-1-git-send-email-oskar@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oskar Schirmer <oskar@linutronix.de>
Date: Thu,  7 Oct 2010 14:30:30 +0200

> with hardware slow in negotiation, the system did freeze
> while trying to mount root on nfs at boot time.
> 
> the link state has not been initialised so network stack
> tried to start transmission right away. this caused instant
> retries, as the driver solely stated business upon link down,
> rendering the system unusable.
> 
> notify carrier off initially to prevent transmission until
> phylib will report link up.
> 
> Signed-off-by: Oskar Schirmer <oskar@linutronix.de>

I did some more investigation into this situation, and for now I'm
going to apply your patch.  It is correct, and it also matches what
the only other seemingly correct driver I could find using phylib does
(gianfar) :-) Actually, although I didn't check, bi-modal drivers
(those that only use phylib for some phy types) like tg3 probably do
the right thing here too.

Longer term I think the right thing to do might be:

1) Create some notion of "network device has managed carrier"

   This could simply be a flag bit in the netdev or netdev_ops,
   or some other kind of attribute.

2) Managed carrier devices start with netif_carrier_off(), otherwise
   the device starts with netif_carrier_on().

Then we gut all of the probe time netif_carrir_*() calls in all
of the drivers.

And hopefully it's less error prone than it is right now.
