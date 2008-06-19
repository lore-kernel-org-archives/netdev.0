From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3]: TX backlog management in-driver...
Date: Thu, 19 Jun 2008 04:10:11 -0700 (PDT)
Message-ID: <20080619.041011.193691281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33949
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756735AbYFSLKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:10:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is an experimental set of patches which demonstrate the kind of
changes we can make to more fluently handle TX queueing inside the
drivers.

The idea is that once a driver does things this way, we can basically
shut off all of the mid-layer driver queue handling and locking (using
some feature bit or function pointers), and this furthermore opens up
the doors for multiqueue TX infrastructure and support.

I've converted tg3 simply because that's the driver for hardware I
feel the most comfortable hacking and which a decent number of people
have access to.  These patches are against net-next-2.6

If people are looking for an area to contribute, right now what is
really useful is coding up a similar set of patches for other popular
drivers.  I would suggest e1000/e1000e, r8169, bnx2, bnx2x,
ixgb/ixgbe.

Personally I plan on doing an NIU patch set simply because it is a
heavily multiqueued device on which I can perform real experiments
once we get further along with this.

This driver work is useful no matter how we decide to actually
proceed.  For example, if we have put the batching logic into the
mid-layer, these driver transformations are still going to be needed
and used.

The main idea is to seperate the code that queues up packets into the
chip's TX ring, from the higher level code that does things like
set the new producer index in the hardware and update ->trans_start.

For example, if you look at these 3 tg3 patches, the first two look
large and scary but they are just refactoring code blocks into
seperate functions.  The third patch is the simplest to read but
was the hardest to get working because there are all sorts of details
to get right :-)

There are some aspects of the third patch I am still unhappy with and
one known problem.  For one thing there is a race between TX completion
handling and the ->hard_start_xmit() code.  I simply don't think the
unlocked skb_queue_empty() test is safe in tg3_tx().

Secondly, it is possible for ->hard_start_xmit() to queue up packets
before the TX backlog list is handled by tg3_tx().  I'm still thinking
about how to resolve that reordering bug.

Anyways even though this isn't %100 perfect I'm posting it to get the
ball rolling since people have been poking me a lot lately.  Oh well,
that's what I get for writing so much slide-ware :)

After a little bit (say, once we have 2 or 3 drivers in pretty decent
shape) I'll open up a GIT tree to track this work.
