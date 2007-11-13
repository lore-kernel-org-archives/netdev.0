From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] PATCH 1/2 [SCHED 2.6.24]: Check subqueue status before
	calling hard_start_xmit
Date: Tue, 13 Nov 2007 09:44:50 -0800
Message-ID: <20071113174450.27916.80538.stgit@localhost.localdomain>
References: <20071113174444.27916.1892.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7297 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755525AbXKNAsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 19:48:52 -0500
In-Reply-To: <20071113174444.27916.1892.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The only qdiscs that check subqueue state before dequeue'ing are PRIO
and RR.  The other qdiscs, including the default pfifo_fast qdisc, will
allow traffic bound for subqueue 0 through to hard_start_xmit.  The check
for netif_queue_stopped() is done above in pkt_sched.h, so it is
unnecessary for qdisc_restart().  However, if the underlying driver is
multiqueue capable, and only sets queue states on subqueues, this will
allow packets to enter the driver when it's currently unable to process
packets, resulting in expensive requeues and driver entries.  This patch
re-adds the check for the subqueue status before calling hard_start_xmit,
so we can try and avoid the driver entry when the queues are stopped.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 net/sched/sch_generic.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index fa1a6f4..e595e65 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -134,7 +134,7 @@ static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
-	int ret;
+	int ret = NETDEV_TX_BUSY;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
@@ -145,7 +145,8 @@ static inline int qdisc_restart(struct net_device *dev)
 	spin_unlock(&dev->queue_lock);
 
 	HARD_TX_LOCK(dev, smp_processor_id());
-	ret = dev_hard_start_xmit(skb, dev);
+	if (!netif_subqueue_stopped(dev, skb))
+		ret = dev_hard_start_xmit(skb, dev);
 	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);
