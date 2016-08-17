From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Fixes resource allocation for ULD's in kdump kernel
Date: Wed, 17 Aug 2016 14:09:28 +0530
Message-ID: <1471423168-7354-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:13813 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751352AbcHQIeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 04:34:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At present the code to check in kdump kernel was not disabling
allocation of resources when CONFIG_CHELSIO_T4_DCB is defined, move the
code outside #defines so that it gets disabled irrespective of #define,
when in kdump kernel.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c45de49dc963..c762a8c8c954 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4335,6 +4335,11 @@ static void cfg_queues(struct adapter *adap)
 #endif
 	int ciq_size;
 
+	/* Reduce memory usage in kdump environment, disable all offload.
+	 */
+	if (is_kdump_kernel())
+		adap->params.offload = 0;
+
 	for_each_port(adap, i)
 		n10g += is_x_10g_port(&adap2pinfo(adap, i)->link_cfg);
 #ifdef CONFIG_CHELSIO_T4_DCB
@@ -4365,11 +4370,6 @@ static void cfg_queues(struct adapter *adap)
 	if (q10g > netif_get_num_default_rss_queues())
 		q10g = netif_get_num_default_rss_queues();
 
-	/* Reduce memory usage in kdump environment, disable all offload.
-	 */
-	if (is_kdump_kernel())
-		adap->params.offload = 0;
-
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
 
-- 
2.3.4
