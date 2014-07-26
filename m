From: Guy Harris <guy@alum.mit.edu>
Subject: Problems with TPACKET_V3 delivery of wakeups (and empty buffer blocks)
Date: Fri, 25 Jul 2014 17:43:44 -0700
Message-ID: <FBF13AD0-7721-4CEF-94AE-A14C1B06E84C@alum.mit.edu>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:53200 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbaGZAzX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 20:55:23 -0400
Received: from [10.0.1.4] (c-50-131-195-36.hsd1.ca.comcast.net [50.131.195.36])
	(authenticated bits=0)
	by c.mail.sonic.net (8.14.9/8.14.9) with ESMTP id s6Q0hi8J001396
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 17:43:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users of libpcap, which supports TPACKET_V3 as of libpcap 1.5.0, have reported problems that turned out to be due to some oddities in TPACKET_V3's behavior.

See, for example:

	https://github.com/the-tcpdump-group/libpcap/issues/335

	https://github.com/the-tcpdump-group/libpcap/issues/364

	http://thread.gmane.org/gmane.network.tcpdump.devel/6823

To quote one of my comments for the first issue:

It appears that PF_PACKET sockets deliver a wakeup when a packet is put in a buffer block or dropped due to no buffer blocks being empty, but *not* when a buffer block is handed to userland.

This means that if the kernel's timer expires, and there are no packets in the current buffer block being filled by the kernel, that buffer block will be handed to userland, but userland won't be woken up to tell it to consume that block.

Thus, libpcap will consume that block only if either:

	1. a packet is put in a buffer block, meaning it must pass the filter *and* there must be a current buffer block, belonging to the kernel, into which to put it;

	2. a packet arrives and passes the filter, but there are *no* current buffer blocks belonging to the kernel, so it's dropped;

	3. the poll() times out.

So, with a low packet acceptance rate (either because there isn't much network traffic or because there is but most of it is rejected by the packet filter), and with a poll() timeout of -1, meaning "block forever", 1) will happen infrequently, and 3) will never happen.  With an in-kernel timeout rate significantly lower than the rate of packet acceptance, the timeout will often occur when there are no packets in the current buffer block, in which case the kernel will hand an empty buffer block to userland and *not* tell userland about it.

If that happens often enough in sequence to cause *all* buffer blocks to be handed to userland before any wakeups occur, the kernel now has no buffer blocks into which to put packets, and the next time a packet arrives, it will be dropped, and a wakeup will finally occur.  libpcap will drain the ring, handing all buffer blocks to the kernel, *but* it won't have any packets to process!

So this is ultimately a problem with the TPACKET_V3 code in the kernel.  I personally think that it should *not* deliver empty buffer blocks to userland, and that it also should *not* deliver a wakeup when a packet is accepted, and *should* deliver a wakeup whenever a buffer block is handed to userland.  I'll report this to somebody and let them decide which of those changes should be done.
