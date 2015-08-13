From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 2/2] net: sch_generic: react upon IFF_NO_QUEUE flag
Date: Thu, 13 Aug 2015 19:01:07 +0200
Message-ID: <1439485268-20953-3-git-send-email-phil@nwl.cc>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
 <1439485268-20953-2-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, alexei.starovoitov@gmail.com,
	davem@davemloft.net, fw@strlen.de, cwang@twopensource.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57832 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175AbbHMRBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 13:01:10 -0400
In-Reply-To: <1439485268-20953-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle IFF_NO_QUEUE as alternative to tx_queue_len being zero.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sched/sch_generic.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6efca30..942fea8 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -735,7 +735,7 @@ static void attach_one_default_qdisc(struct net_device *dev,
 {
 	struct Qdisc *qdisc = &noqueue_qdisc;
 
-	if (dev->tx_queue_len) {
+	if (dev->tx_queue_len && !(dev->priv_flags & IFF_NO_QUEUE)) {
 		qdisc = qdisc_create_dflt(dev_queue,
 					  default_qdisc_ops, TC_H_ROOT);
 		if (!qdisc) {
@@ -755,7 +755,9 @@ static void attach_default_qdiscs(struct net_device *dev)
 
 	txq = netdev_get_tx_queue(dev, 0);
 
-	if (!netif_is_multiqueue(dev) || dev->tx_queue_len == 0) {
+	if (!netif_is_multiqueue(dev) ||
+	    dev->tx_queue_len == 0 ||
+	    dev->priv_flags & IFF_NO_QUEUE) {
 		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
 		dev->qdisc = txq->qdisc_sleeping;
 		atomic_inc(&dev->qdisc->refcnt);
-- 
2.1.2
