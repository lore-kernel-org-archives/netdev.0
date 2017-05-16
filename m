From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: reduce resource allocation in kdump kernel
Date: Tue, 16 May 2017 21:17:42 +0530
Message-ID: <1494949662-8339-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:4652 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752314AbdEPPr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 11:47:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When is_kdump_kernel() is true, reduce memory footprint of
cxgb4 by using a single "Queue Set".

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 38a5c67..4249ffb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -891,7 +891,7 @@ static u16 cxgb_select_queue(struct net_device *dev, struct sk_buff *skb,
 	 * The skb's priority is determined via the VLAN Tag Priority Code
 	 * Point field.
 	 */
-	if (cxgb4_dcb_enabled(dev)) {
+	if (cxgb4_dcb_enabled(dev) && !is_kdump_kernel()) {
 		u16 vlan_tci;
 		int err;
 
@@ -4007,10 +4007,7 @@ static void cfg_queues(struct adapter *adap)
 
 	/* Reduce memory usage in kdump environment, disable all offload.
 	 */
-	if (is_kdump_kernel()) {
-		adap->params.offload = 0;
-		adap->params.crypto = 0;
-	} else if (is_uld(adap) && t4_uld_mem_alloc(adap)) {
+	if (is_kdump_kernel() || (is_uld(adap) && t4_uld_mem_alloc(adap))) {
 		adap->params.offload = 0;
 		adap->params.crypto = 0;
 	}
@@ -4031,7 +4028,7 @@ static void cfg_queues(struct adapter *adap)
 		struct port_info *pi = adap2pinfo(adap, i);
 
 		pi->first_qset = qidx;
-		pi->nqsets = 8;
+		pi->nqsets = is_kdump_kernel() ? 1 : 8;
 		qidx += pi->nqsets;
 	}
 #else /* !CONFIG_CHELSIO_T4_DCB */
@@ -4044,6 +4041,9 @@ static void cfg_queues(struct adapter *adap)
 	if (q10g > netif_get_num_default_rss_queues())
 		q10g = netif_get_num_default_rss_queues();
 
+	if (is_kdump_kernel())
+		q10g = 1;
+
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
 
-- 
2.1.0
