From: David Miller <davem@davemloft.net>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 10 Jul 2008 03:09:20 -0700 (PDT)
Message-ID: <20080710.030920.141237050.davem@davemloft.net>
References: <1215622625.5532.43.camel@dell>
	<20080709.164659.157912631.davem@davemloft.net>
	<3000d2e90807100245j74a11b97q7d01f9f0b94dfbe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, joy@debian.org, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org
To: avivgnet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752419AbYGJKJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:09:20 -0400
In-Reply-To: <3000d2e90807100245j74a11b97q7d01f9f0b94dfbe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Aviv Greenberg" <avivgnet@gmail.com>
Date: Thu, 10 Jul 2008 12:45:54 +0300

> On Thu, Jul 10, 2008 at 02:46, David Miller <davem@davemloft.net> wrote:
> >
> > So it has to be something else.
> 
> What mechanism prevents the clone from happening between
> the skb_clone() and skb_split() calls in tcp_fragment?

The TCP packet is guarenteed to be cloned when the driver
first gets it.  That's fundamentally how TCP's retransmission
handling works.

It makes a clone, and sends it down to the driver.

You can't make clones of clones, so in such situations
code makes a full copy instead.

TCP always had the whole state of the retransmit queue,
and thus the base SKB state, locked when it makes all
of these operations.

When TCP is looking at an SKB on the retransmit queue it can only go
from cloned to uncloned, not the other way around.

> Maybe there's a path that doesn't take a lock...

I doubt it.

I think it's some piece of code not making careful enough
checks on the way down to an SKB modification.
