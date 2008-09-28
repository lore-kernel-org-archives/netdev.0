From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv2 0/2] skb recycling
Date: Sun, 28 Sep 2008 22:46:16 +0200
Message-ID: <20080928204616.GA19070@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ram.Natarajan@Emulex.Com, Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:60270 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbYI1UqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 16:46:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements skb recycling, which is basically just reusing skbuffs
that have finished transmitting as receive buffers, avoiding skbuff
freeing/reallocation overhead.  This is done by having the networking
provide skb_recycle_check(), which drivers can then use in their tx
ring cleanup (example implementation for mv643xx_eth included).

This is v2, incorporating feedback from Eric Dumazet to limit the size
of the recycle list to the size of the receive ring, and to manage the
recycle list in LIFO rather than FIFO mode for an extra bit of speedup.

Packet-per-second routing rates on mv643xx_eth without recycling, with
the IP stack cut out of the loop:
- 322165 322165 336022 343407 332447

Packet-per-second routing rates on mv643xx_eth with recycling (i.e.
with these two patches), with the IP stack cut out of the loop:
- 428082 422297 428082 428082 422297

So a ~30% speedup on synthetic benchmark.  On a 'real' benchmark (i.e.
routing using the IP stack without hacks in the driver), the speedup
is on the order of 20% (~230 -> ~270 kpps).
