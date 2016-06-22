From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 13/13] liquidio: ddr timeout
Date: Tue, 21 Jun 2016 22:53:15 -0700
Message-ID: <1466574795-4306-14-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0061.outbound.protection.outlook.com ([157.56.110.61]:4394
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750957AbcFVHeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 03:34:25 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for ddr_timeout during device init.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c      | 13 +++++++++----
 drivers/net/ethernet/cavium/liquidio/octeon_device.c |  3 ---
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a8328f2..1a584eb 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3805,14 +3805,19 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
 
-	if (ddr_timeout == 0) {
-		dev_info(&octeon_dev->pci_dev->dev,
-			 "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
-	}
+	if (ddr_timeout == 0)
+		dev_info(&octeon_dev->pci_dev->dev, "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
 
 	schedule_timeout_uninterruptible(HZ * LIO_RESET_SECS);
 
 	/* Wait for the octeon to initialize DDR after the soft-reset. */
+	while (ddr_timeout == 0) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (schedule_timeout(HZ / 10)) {
+			/* user probably pressed Control-C */
+			return 1;
+		}
+	}
 	ret = octeon_wait_for_ddr_init(octeon_dev, &ddr_timeout);
 	if (ret) {
 		dev_err(&octeon_dev->pci_dev->dev,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index bc4d6af..3372207 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1284,9 +1284,6 @@ int octeon_wait_for_ddr_init(struct octeon_device *oct, u32 *timeout)
 	if (!timeout)
 		return ret;
 
-	while (*timeout == 0)
-		schedule_timeout_uninterruptible(HZ / 10);
-
 	for (ms = 0; (ret != 0) && ((*timeout == 0) || (ms <= *timeout));
 	     ms += HZ / 10) {
 		ret = octeon_mem_access_ok(oct);
-- 
1.8.3.1
