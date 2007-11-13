From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] PATCH 2/2 [SCHED 2.6.23-stable]: Check subqueue state before
	hard_start_xmit
Date: Tue, 13 Nov 2007 09:44:56 -0800
Message-ID: <20071113174456.27939.72073.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60047 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761523AbXKNAmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 19:42:53 -0500
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
index c81649c..a35d7ce 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -135,7 +135,7 @@ static inline int qdisc_restart(struct net_device *dev)
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
 	unsigned lockless;
-	int ret;
+	int ret = NETDEV_TX_BUSY;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
@@ -158,7 +158,8 @@ static inline int qdisc_restart(struct net_device *dev)
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
-	ret = dev_hard_start_xmit(skb, dev);
+	if (!netif_subqueue_stopped(dev, skb->queue_mapping))
+		ret = dev_hard_start_xmit(skb, dev);
 
 	if (!lockless)
 		netif_tx_unlock(dev);
