From: Jon Mason <mason@myri.com>
Subject: [PATCH 4/9] myri10ge: allow small_bytes = 0
Date: Mon, 27 Jun 2011 10:05:03 -0500
Message-ID: <1309187108-12715-4-git-send-email-mason@myri.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:39466 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202Ab1F0PFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 11:05:30 -0400
Received: by pvg12 with SMTP id 12so2905334pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 08:05:29 -0700 (PDT)
In-Reply-To: <1309187108-12715-1-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow page-based receive to work when small_bytes is set to 0.

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index f3df5eb..71461e5 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2004,8 +2004,12 @@ static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 	ss->rx_big.page_offset = MYRI10GE_ALLOC_SIZE;
 	ss->rx_small.watchdog_needed = 0;
 	ss->rx_big.watchdog_needed = 0;
-	myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
-				mgp->small_bytes + MXGEFW_PAD, 0);
+	if (mgp->small_bytes == 0) {
+		ss->rx_small.fill_cnt = ss->rx_small.mask + 1;
+	} else {
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
+					mgp->small_bytes + MXGEFW_PAD, 0);
+	}
 
 	if (ss->rx_small.fill_cnt < ss->rx_small.mask + 1) {
 		netdev_err(dev, "slice-%d: alloced only %d small bufs\n",
@@ -2031,6 +2035,8 @@ abort_with_rx_big_ring:
 	}
 
 abort_with_rx_small_ring:
+	if (mgp->small_bytes == 0)
+		ss->rx_small.fill_cnt = ss->rx_small.cnt;
 	for (i = ss->rx_small.cnt; i < ss->rx_small.fill_cnt; i++) {
 		int idx = i & ss->rx_small.mask;
 		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_small.info[idx],
@@ -2081,6 +2087,8 @@ static void myri10ge_free_rings(struct myri10ge_slice_state *ss)
 		put_page(ss->rx_big.info[idx].page);
 	}
 
+	if (mgp->small_bytes == 0)
+		ss->rx_small.fill_cnt = ss->rx_small.cnt;
 	for (i = ss->rx_small.cnt; i < ss->rx_small.fill_cnt; i++) {
 		idx = i & ss->rx_small.mask;
 		if (i == ss->rx_small.fill_cnt - 1)
@@ -2418,7 +2426,7 @@ static int myri10ge_open(struct net_device *dev)
 		mgp->small_bytes = VLAN_ETH_FRAME_LEN;
 
 	/* Override the small buffer size? */
-	if (myri10ge_small_bytes > 0)
+	if (myri10ge_small_bytes >= 0)
 		mgp->small_bytes = myri10ge_small_bytes;
 
 	/* Firmware needs the big buff size as a power of 2.  Lie and
-- 
1.7.5.4

