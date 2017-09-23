From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 2/3] liquidio: verify firmware version when
 auto-loaded from flash.
Date: Fri, 22 Sep 2017 17:12:47 -0700
Message-ID: <20170923001247.GA1496@felix-thinkpad.cavium.com>
References: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0087.outbound.protection.outlook.com ([104.47.32.87]:5728
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751845AbdIWAMw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 20:12:52 -0400
Content-Disposition: inline
In-Reply-To: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index ce08f71..a3c9867 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3303,7 +3303,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 {
 	struct lio *lio = NULL;
 	struct net_device *netdev;
-	u8 mac[6], i, j;
+	u8 mac[6], i, j, *fw_ver;
 	struct octeon_soft_command *sc;
 	struct liquidio_if_cfg_context *ctx;
 	struct liquidio_if_cfg_resp *resp;
@@ -3414,6 +3414,22 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			goto setup_nic_dev_fail;
 		}
 
+		/* Verify f/w version (in case of 'auto' loading from flash) */
+		fw_ver = octeon_dev->fw_info.liquidio_firmware_version;
+		if (memcmp(LIQUIDIO_BASE_VERSION,
+			   fw_ver,
+			   strlen(LIQUIDIO_BASE_VERSION))) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				"Unmatched firmware version. Expected %s.x, got %s.\n",
+				LIQUIDIO_BASE_VERSION, fw_ver);
+			goto setup_nic_dev_fail;
+		} else if (atomic_read(octeon_dev->adapter_fw_state) ==
+			   FW_IS_PRELOADED) {
+			dev_info(&octeon_dev->pci_dev->dev,
+				 "Using auto-loaded firmware version %s.\n",
+				 fw_ver);
+		}
+
 		octeon_swap_8B_data((u64 *)(&resp->cfg_info),
 				    (sizeof(struct liquidio_if_cfg_info)) >> 3);
 
-- 
1.8.3.1
