From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Reduce resource allocation in kdump kernel
Date: Fri,  3 Jun 2016 23:05:45 +0530
Message-ID: <1464975345-12484-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:49890 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752304AbcFCRao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When is_kdump_kernel() is true, reduce our memory footprint by only using
a single "Queue Set" and Forcing Master so we can reinitialize the
Firmware/Chip.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 477db477b133..5317187d0073 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -64,6 +64,7 @@
 #include <net/bonding.h>
 #include <net/addrconf.h>
 #include <asm/uaccess.h>
+#include <linux/crash_dump.h>
 
 #include "cxgb4.h"
 #include "t4_regs.h"
@@ -3735,7 +3736,8 @@ static int adap_init0(struct adapter *adap)
 		return ret;
 
 	/* Contact FW, advertising Master capability */
-	ret = t4_fw_hello(adap, adap->mbox, adap->mbox, MASTER_MAY, &state);
+	ret = t4_fw_hello(adap, adap->mbox, adap->mbox,
+			  is_kdump_kernel() ? MASTER_MUST : MASTER_MAY, &state);
 	if (ret < 0) {
 		dev_err(adap->pdev_dev, "could not connect to FW, error %d\n",
 			ret);
@@ -4366,6 +4368,14 @@ static void cfg_queues(struct adapter *adap)
 	if (q10g > netif_get_num_default_rss_queues())
 		q10g = netif_get_num_default_rss_queues();
 
+	/* Reduce memory usage in kdump environment by using only one queue
+	 * and disable all offload.
+	 */
+	if (is_kdump_kernel()) {
+		q10g = 1;
+		adap->params.offload = 0;
+	}
+
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
 
-- 
2.3.4
