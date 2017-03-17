From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: add debug error messages to report
 command timeout
Date: Fri, 17 Mar 2017 11:23:08 -0700
Message-ID: <20170317182308.GA2319@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0088.outbound.protection.outlook.com ([104.47.37.88]:16448
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751100AbdCQSXr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 14:23:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Add timeout error message in lio_process_ordered_list().  Add host failure
status in existing error message in if_cfg_callback().

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c         | 4 ++--
 drivers/net/ethernet/cavium/liquidio/response_manager.c | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index be9c0e3..046d816 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2209,8 +2209,8 @@ static void if_cfg_callback(struct octeon_device *oct,
 
 	oct = lio_get_device(ctx->octeon_id);
 	if (resp->status)
-		dev_err(&oct->pci_dev->dev, "nic if cfg instruction failed. Status: %llx\n",
-			CVM_CAST64(resp->status));
+		dev_err(&oct->pci_dev->dev, "nic if cfg instruction failed. Status: 0x%llx (0x%08x)\n",
+			CVM_CAST64(resp->status), status);
 	WRITE_ONCE(ctx->cond, 1);
 
 	snprintf(oct->fw_info.liquidio_firmware_version, 32, "%s",
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 2fbaae9..a50ee98 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -113,6 +113,8 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 			}
 		} else if (force_quit || (sc->timeout &&
 			time_after(jiffies, (unsigned long)sc->timeout))) {
+			dev_err(&octeon_dev->pci_dev->dev, "%s: cmd failed, timeout (%ld, %ld)\n",
+				__func__, (long)jiffies, (long)sc->timeout);
 			status = OCTEON_REQUEST_TIMEOUT;
 		}
 
