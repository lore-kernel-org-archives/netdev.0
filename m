From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH net-next 0/6] mvneta driver performance improvements
Date: Sun, 12 Jan 2014 12:24:02 +0100
Message-ID: <1389525848-1814-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55230 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175AbaALLYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 06:24:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series implements several performance improvements on the
mvneta driver.

  - The first 3 patches are essentially cleanups, code deduplication
    and minor optimizations for not re-fetching a value we already have
    (status).

  - patch 4 changes the prefetch of Rx descriptor from current one to
    next one. In benchmarks, it results in about 1% general performance
    increase on HTTP traffic, probably because prefetching the current
    descriptor does not leave enough time between the start of prefetch
    and its usage.

  - patch 5 implements support for build_skb() on Rx path. The driver
    now preallocates frags instead of skbs and builds an skb just before
    delivering it. This results in a 2% performance increase on HTTP
    traffic, and up to 5% on small packet Rx rate.

  - patch 6 implements rx_copybreak for small packets (256 bytes). It
    avoids a dma_map_single()/dma_unmap_single() and increases the Rx
    rate by 16.4%, from 486kpps to 573kpps. Further improvements up to
    711kpps are possible depending how the DMA is used.

This patch series depends on the previous series of fixes and is only
for the net-next tree.

Thanks!
Willy

---

Willy Tarreau (6):
  net: mvneta: remove tests for impossible cases in the tx_done path
  net: mvneta: factor rx refilling code
  net: mvneta: simplify access to the rx descriptor status
  net: mvneta: prefetch next rx descriptor instead of current one
  net: mvneta: convert to build_skb()
  net: mvneta: implement rx_copybreak

 drivers/net/ethernet/marvell/mvneta.c | 152 +++++++++++++++++++++-------------
 1 file changed, 95 insertions(+), 57 deletions(-)

-- 
1.7.12.2.21.g234cd45.dirty
