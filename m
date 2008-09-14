From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/5] mv643xx_eth: some more changes for 2.6.28
Date: Sun, 14 Sep 2008 19:12:53 +0200
Message-ID: <20080914171253.GB28798@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:39709 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbYINRM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 13:12:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple more patches for mv643xx_eth:
- Four patches that reduce the runtime Dcache footprint of the driver
  and avoid some avoidable reads from uncached memory, providing some
  more speedup in routing benchmarks.
- One patch to make mv643xx_eth work on another variation of the
  hardware (the ethernet unit in the Marvell 88f6183 ARM SoC), which
  has no transmit bandwidth control registers at all.


I've added these patches to the set of 17 patches I posted on the 3rd,
and that is the set I intend to ask Jeff to pull for 2.6.28 if no other
problems appear over the next couple of days (i.e. I'll send a pull
request in a couple of days).  The set is available here:

	http://git.marvell.com/?p=mv643xx_eth.git;a=shortlog;h=for-2.6.28
	git://git.marvell.com/mv643xx_eth.git for-2.6.28


I see the following packet-per-second routing numbers on various
versions of the driver (five trials for each kernel version) on a
given ARM box:

- (Vanilla 2.6.27-rc4: typically anywhere between 90kpps and 130kpps,
  due to the bug fixed by 819ddcafb33136f2ba18018a22edcf857f640528.)

- Vanilla 2.6.27-rc5: 144009 145349 144009 143349 146028

- 2.6.27-rc5 with some changes to reorder various routing-related
  functions that are hot in profiles within the kernel text segment
  to avoid them conflicting in the Icache (see the skb recycling
  thread on netdev@): 163613 167112 166223 169837 168011

- 2.6.27-rc5 plus the 22 patches from the 'for-2.6.28' mv643xx_eth
  branch: 183824 184911 182824 183824 183824

- 2.6.27-rc5 plus the 22 patches from the 'for-2.6.28' mv643xx_eth
  branch plus the function reordering changes: 206954 208333 208333
  208333 206954.

(- The above plus disabling of TX flow control plus some more
   performance hacks with varying degrees of nastyness: 267094
   269397 264831 269397 269397)

(Due to limitations in the setup of this test, the routing is done from
and to the same interface, causing the networking to spend a bunch of
extra cycles per packet trying to send out ICMP redirects -- #if 0'ing
out the REDIRECT check in ip_forward() adds another 20kpps or so.)


I have some more patches in my tree:
- phylib conversion (needs ACK from Andrew Fleming for phylib changes).
- skb recycling (still under discussion).
- Move pegasosppc sram window setting code into the driver (needs
  someone with a Pegasos PPC platform to test whether this actually
  works.)
