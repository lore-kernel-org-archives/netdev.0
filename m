From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 00/13] Assorted mvneta fixes and improvements
Date: Thu, 16 Jan 2014 08:20:06 +0100
Message-ID: <1389856819-6503-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Arnaud Ebalard <arno@natisbad.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55491 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054AbaAPHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 02:21:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series provides some fixes for a number of issues met with the
mvneta driver, then adds some improvements. Patches 1-5 are fixes
and would be needed in 3.13 and likely -stable. The next ones are
performance improvements and cleanups :

  - driver lockup when reading stats while sending traffic from multiple
    CPUs : this obviously only happens on SMP and is the result of missing
    locking on the driver. The problem was present since the introduction
    of the driver in 3.8. The first patch performs some changes that are
    needed for the second one which actually fixes the issue by using
    per-cpu counters. It could make sense to backport this to the relevant
    stable versions.

  - mvneta_tx_timeout calls various functions to reset the NIC, and these
    functions sleep, which is not allowed here, resulting in a panic.
    Better completely disable this Tx timeout handler for now since it is
    never called. The problem was encountered while developing some new
    features, it's uncertain whether it's possible to reproduce it with
    regular usage, so maybe a backport to stable is not needed.

  - replace the Tx timer with a real Tx IRQ. As first reported by Arnaud
    Ebalard and explained by Eric Dumazet, there is no way this driver
    can work correctly if it uses a driver to recycle the Tx descriptors.
    If too many packets are sent at once, the driver quickly ends up with
    no descriptors (which happens twice as easily in GSO) and has to wait
    10ms for recycling its descriptors and being able to send again. Eric
    has worked around this in the core GSO code. But still when routing
    traffic or sending UDP packets, the limitation is very visible. Using
    Tx IRQs allows Tx descriptors to be recycled when sent. The coalesce
    value is still configurable using ethtool. This fix turns the UDP
    send bitrate from 134 Mbps to 987 Mbps (ie: line rate). It's made of
    two patches, one to add the relevant bits from the original Marvell's
    driver, and another one to implement the change. I don't know if it
    should be backported to stable, as the bug only causes poor performance.

  - Patches 6..8 are essentially cleanups, code deduplication and minor
    optimizations for not re-fetching a value we already have (status).

  - patch 9 changes the prefetch of Rx descriptor from current one to
    next one. In benchmarks, it results in about 1% general performance
    increase on HTTP traffic, probably because prefetching the current
    descriptor does not leave enough time between the start of prefetch
    and its usage.

  - patch 10 implements support for build_skb() on Rx path. The driver
    now preallocates frags instead of skbs and builds an skb just before
    delivering it. This results in a 2% performance increase on HTTP
    traffic, and up to 5% on small packet Rx rate.

  - patch 11 implements rx_copybreak for small packets (256 bytes). It
    avoids a dma_map_single()/dma_unmap_single() and increases the Rx
    rate by 16.4%, from 486kpps to 573kpps. Further improvements up to
    711kpps are possible depending how the DMA is used.

  - patches 12 and 13 are extra cleanups made possible by some of the
    simplifications above.

Thanks,
Willy

---
Arnaud Ebalard (2):
  net: mvneta: mvneta_tx_done_gbe() cleanups
  net: mvneta: make mvneta_txq_done() return void

Willy Tarreau (11):
  net: mvneta: increase the 64-bit rx/tx stats out of the hot path
  net: mvneta: use per_cpu stats to fix an SMP lock up
  net: mvneta: do not schedule in mvneta_tx_timeout
  net: mvneta: add missing bit descriptions for interrupt masks and
    causes
  net: mvneta: replace Tx timer with a real interrupt
  net: mvneta: remove tests for impossible cases in the tx_done path
  net: mvneta: factor rx refilling code
  net: mvneta: simplify access to the rx descriptor status
  net: mvneta: prefetch next rx descriptor instead of current one
  net: mvneta: convert to build_skb()
  net: mvneta: implement rx_copybreak

 drivers/net/ethernet/marvell/mvneta.c | 387 +++++++++++++++++++---------------
 1 file changed, 215 insertions(+), 172 deletions(-)

--
1.7.12.2.21.g234cd45.dirty
