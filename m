From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4: Force cxgb4 driver as MASTER in kdump kernel
Date: Tue, 14 Jun 2016 14:39:30 +0530
Message-ID: <1465895372-21101-2-git-send-email-hariprasad@chelsio.com>
References: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:10357 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751834AbcFNJEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 05:04:14 -0400
In-Reply-To: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When is_kdump_kernel() is true, Forcing cxgb4 driver as Master so we can
reinitialize the Firmware/Chip. Also reduce memory usage by disabling
offload.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 477db477b133..c045f65d4106 100644
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
@@ -4366,6 +4368,11 @@ static void cfg_queues(struct adapter *adap)
 	if (q10g > netif_get_num_default_rss_queues())
 		q10g = netif_get_num_default_rss_queues();
 
+	/* Reduce memory usage in kdump environment, disable all offload.
+	 */
+	if (is_kdump_kernel())
+		adap->params.offload = 0;
+
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
 
-- 
2.3.4
