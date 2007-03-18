From: divy@chelsio.com
Subject: [PATCH 2.6.21 1/4] cxgb3 - fix ethtool cmd on multiple queues port
Date: Sun, 18 Mar 2007 13:10:01 -0700
Message-ID: <20070318201001.16269.86377.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28231 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933068AbXCRUKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 16:10:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Limit ethtool -g/-G to the given port's queues.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---
---

 drivers/net/cxgb3/cxgb3_main.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7ff834e..eb0a4e0 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1362,23 +1362,27 @@ static int set_rx_csum(struct net_device
 
 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	struct adapter *adapter = dev->priv;
+	const struct adapter *adapter = dev->priv;
+	const struct port_info *pi = netdev_priv(dev);
+	const struct qset_params *q = &adapter->params.sge.qset[pi->first_qset];
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
 	e->rx_mini_max_pending = 0;
 	e->rx_jumbo_max_pending = MAX_RX_JUMBO_BUFFERS;
 	e->tx_max_pending = MAX_TXQ_ENTRIES;
 
-	e->rx_pending = adapter->params.sge.qset[0].fl_size;
-	e->rx_mini_pending = adapter->params.sge.qset[0].rspq_size;
-	e->rx_jumbo_pending = adapter->params.sge.qset[0].jumbo_size;
-	e->tx_pending = adapter->params.sge.qset[0].txq_size[0];
+	e->rx_pending = q->fl_size;
+	e->rx_mini_pending = q->rspq_size;
+	e->rx_jumbo_pending = q->jumbo_size;
+	e->tx_pending = q->txq_size[0];
 }
 
 static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
 	int i;
+	struct qset_params *q;
 	struct adapter *adapter = dev->priv;
+	const struct port_info *pi = netdev_priv(dev);
 
 	if (e->rx_pending > MAX_RX_BUFFERS ||
 	    e->rx_jumbo_pending > MAX_RX_JUMBO_BUFFERS ||
@@ -1393,9 +1397,8 @@ static int set_sge_param(struct net_devi
 	if (adapter->flags & FULL_INIT_DONE)
 		return -EBUSY;
 
-	for (i = 0; i < SGE_QSETS; ++i) {
-		struct qset_params *q = &adapter->params.sge.qset[i];
-
+	q = &adapter->params.sge.qset[pi->first_qset];
+	for (i = 0; i < pi->nqsets; ++i, ++q) {
 		q->rspq_size = e->rx_mini_pending;
 		q->fl_size = e->rx_pending;
 		q->jumbo_size = e->rx_jumbo_pending;
