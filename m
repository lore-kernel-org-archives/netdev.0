From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: reconfigure resources for kdump crash kernel
Date: Sat,  3 Jan 2015 19:35:44 +0530
Message-ID: <1420293944-7614-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:58161 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917AbbACOGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jan 2015 09:06:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in kdump kernel, reduce number of resources used by the driver.
This will enable NIC to operate in low memory kdump kernel environment.

Also change the driver version to .83

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c | 17 +++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index d2a1035..84b6a2b 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.67"
+#define DRV_VERSION		"2.1.1.83"
 #define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 142c9b5..9027fc1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -45,6 +45,7 @@
 #ifdef CONFIG_NET_RX_BUSY_POLL
 #include <net/busy_poll.h>
 #endif
+#include <linux/crash_dump.h>
 
 #include "cq_enet_desc.h"
 #include "vnic_dev.h"
@@ -2265,6 +2266,18 @@ static void enic_dev_deinit(struct enic *enic)
 	enic_clear_intr_mode(enic);
 }
 
+static void enic_kdump_kernel_config(struct enic *enic)
+{
+	if (is_kdump_kernel()) {
+		dev_info(enic_get_dev(enic), "Running from within kdump kernel. Using minimal resources\n");
+		enic->rq_count = 1;
+		enic->wq_count = 1;
+		enic->config.rq_desc_count = ENIC_MIN_RQ_DESCS;
+		enic->config.wq_desc_count = ENIC_MIN_WQ_DESCS;
+		enic->config.mtu = min_t(u16, 1500, enic->config.mtu);
+	}
+}
+
 static int enic_dev_init(struct enic *enic)
 {
 	struct device *dev = enic_get_dev(enic);
@@ -2294,6 +2307,10 @@ static int enic_dev_init(struct enic *enic)
 
 	enic_get_res_counts(enic);
 
+	/* modify resource count if we are in kdump_kernel
+	 */
+	enic_kdump_kernel_config(enic);
+
 	/* Set interrupt mode based on resource counts and system
 	 * capabilities
 	 */
-- 
2.2.1
