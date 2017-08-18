From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 2/2] liquidio: with embedded f/w, issue droq credits
 before enablement
Date: Thu, 17 Aug 2017 23:11:30 -0700
Message-ID: <20170818061130.GA4045@felix-thinkpad.cavium.com>
References: <20170818061037.GA4024@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0060.outbound.protection.outlook.com ([104.47.34.60]:11399
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751176AbdHRGLW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 02:11:22 -0400
Content-Disposition: inline
In-Reply-To: <20170818061037.GA4024@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

1. Issue credits BEFORE enabling DROQ's; this prevents PKTPF_ERR interrupt.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index dccd447..89d4bbc 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -4040,6 +4040,18 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	atomic_set(&octeon_dev->status, OCT_DEV_INTR_SET_DONE);
 
+	/* Send Credit for Octeon Output queues. Credits are always sent BEFORE
+	 * the output queue is enabled.
+	 * This ensures that we'll receive the f/w CORE DRV_ACTIVE message in
+	 * case we've configured CN23XX_SLI_GBL_CONTROL[NOPTR_D] = 0.
+	 * Otherwise, it is possible that the DRV_ACTIVE message will be sent
+	 * before any credits have been issued, causing the ring to be reset
+	 * (and the f/w appear to never have started).
+	 */
+	for (j = 0; j < octeon_dev->num_oqs; j++)
+		writel(octeon_dev->droq[j]->max_count,
+		       octeon_dev->droq[j]->pkts_credit_reg);
+
 	/* Enable the input and output queues for this Octeon device */
 	ret = octeon_dev->fn_list.enable_io_queues(octeon_dev);
 	if (ret) {
@@ -4124,14 +4136,6 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	atomic_set(&octeon_dev->status, OCT_DEV_HOST_OK);
 
-	/* Send Credit for Octeon Output queues. Credits are always sent after
-	 * the output queue is enabled.
-	 */
-	for (j = 0; j < octeon_dev->num_oqs; j++)
-		writel(octeon_dev->droq[j]->max_count,
-		       octeon_dev->droq[j]->pkts_credit_reg);
-
-	/* Packets can start arriving on the output queues from this point. */
 	return 0;
 }
 
-- 
2.9.0
