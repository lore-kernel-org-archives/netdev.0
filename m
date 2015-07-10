From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: [PATCH] nohz: prevent tilegx network driver interrupts
Date: Fri, 10 Jul 2015 13:33:44 -0400
Message-ID: <1436549624-16104-1-git-send-email-cmetcalf@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Metcalf <cmetcalf@ezchip.com>
To: Frederic Weisbecker <fweisbec@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0078.outbound.protection.outlook.com ([157.56.112.78]:25136
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932256AbbGJRd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 13:33:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In nohz_full mode, by default distribute networking shim
interrupts across the housekeeping cores, not all the cores.

Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
---
The alternate approaches to this might be:

1. "#define housekeeping_mask cpu_online_mask" in the non-nohz_full
   arm in <linux/tick.h>, then just unconditionally use
   "housekeeping_mask".

2. Provide an accessor that returns the cpumask to use for housekeeping
   chores and implement it in the obvious ways for both nohz_full
   and non-nohz_full.

The latter seems like arguably the most satisfying approach, but
the patch below is, if nothing else, suitable to push for 4.3
without any further API development work.

Frederic (or others), comments?

 drivers/net/ethernet/tile/tilegx.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index a3f7610002aa..7687c62e7d75 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -40,6 +40,7 @@
 #include <linux/tcp.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <linux/tick.h>
 
 #include <asm/checksum.h>
 #include <asm/homecache.h>
@@ -2272,8 +2273,13 @@ static int __init tile_net_init_module(void)
 	for (i = 0; gxio_mpipe_link_enumerate_mac(i, name, mac) >= 0; i++)
 		tile_net_dev_init(name, mac);
 
-	if (!network_cpus_init())
+	if (!network_cpus_init()) {
+#ifdef CONFIG_NO_HZ_FULL
+		network_cpus_map = *housekeeping_mask;
+#else
 		network_cpus_map = *cpu_online_mask;
+#endif
+	}
 
 	return 0;
 }
-- 
2.1.2
