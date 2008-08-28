From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: cpu utilisation improvement when not doing netif_tx_{stop,wake}_queue()
Date: Thu, 28 Aug 2008 18:46:38 +0200
Message-ID: <20080828164638.GA25919@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dale@farnsworth.org, nico@cam.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:38481 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbYH1Qql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 12:46:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been hacking on mv643xx_eth to optimise small packet routing
throughput.  The version currently in my tree can route ~190kpps,
versus ~130kpps for the version in 2.6.27.

As part of the hacking, I implemented multiqueue TX, got rid of all
driver-private locking in favor of the per-subqueue _xmit_lock, and
did a bunch of other cleanups.  (Available in the tree below.)

At first, I didn't want to bother with proper synchronisation for
netif_tx_{stop,wake}_queue(), so I just disabled them entirely for the
time being (and would just drop skbs in ->hard_start_xmit() without
warning if the TX ring was full, while returning success).

When I had properly sorted out the locking and turned TX queue flow
control back on again, I started seeing a ~20% CPU usage hit on a TCP
throughput test relative to not doing said flow control.

I.e. transmitting wire speed gigabit over a single TCP session takes
around 90% CPU time (measured with cyclesoak) if I have the TX queue
flow control enabled, but only 70% if I rip the TX queue flow control
out.  (This is on a relatively underpowered ARM box.)

Looking at the profiles doesn't tell me much, and I can't explain what's
going on, but it seems pretty consistent: if I in the tree below revert
to any commit before the "mv643xx_eth: get rid of transmit queue flow
control" one, I get the CPU hit (~90%), whereas with that commit
included it's fine (~70%).

	http://git.marvell.com/?p=mv643xx_eth.git;a=shortlog;h=for-2.6.28
	git://git.marvell.com/mv643xx_eth.git for-2.6.28

Ideas?
