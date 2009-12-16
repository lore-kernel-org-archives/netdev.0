From: leitao@linux.vnet.ibm.com
Subject: [PATCH] bnx2: fixing a timout error due not refreshing TX timers correctly
Date: Wed, 16 Dec 2009 06:09:24 -0600
Message-ID: <1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
References: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:50301 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589AbZLPMKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 07:10:16 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp04.br.ibm.com (8.14.3/8.13.1) with ESMTP id nBGC0s2G010803
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:00:54 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBGCBssg909784
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:11:54 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBGCAB9B009564
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:10:11 -0200
In-Reply-To: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running the following script on an active bnx2 interface:

while(true); do ifconfig ethX mtu 9000; ifconfig ethX mtu 1500; done

A timeout error appears and dumps the following stack:

NETDEV WATCHDOG: eth4 (bnx2): transmit queue 0 timed out
------------[ cut here ]------------
Badness at net/sched/sch_generic.c:261
<snip>

This patch just fixes the way that ->trans_start is refreshed.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/bnx2.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4bfc808..f81f082 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -655,9 +655,17 @@ bnx2_netif_stop(struct bnx2 *bp)
 	bnx2_cnic_stop(bp);
 	bnx2_disable_int_sync(bp);
 	if (netif_running(bp->dev)) {
+		int i;
+
 		bnx2_napi_disable(bp);
 		netif_tx_disable(bp->dev);
-		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
+		/* prevent tx timeout */
+		for (i = 0; i <  bp->dev->num_tx_queues; i++) {
+			struct netdev_queue *txq;
+
+			txq = netdev_get_tx_queue(bp->dev, i);
+			txq->trans_start = jiffies;
+		}
 	}
 }
 
-- 
1.6.0.2

