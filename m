From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V3 net-next 13/14] net/ena: change condition for host attribute configuration
Date: Fri, 27 Jan 2017 00:18:15 +0200
Message-ID: <1485469096-5271-14-git-send-email-netanel@annapurnalabs.com>
References: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35069 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754303AbdAZWTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:19:02 -0500
Received: by mail-wm0-f49.google.com with SMTP id r126so92516121wmr.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 14:19:02 -0800 (PST)
In-Reply-To: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the host info config to be the first admin command that is executed.
This change require the driver to remove the 'feature check'
from host info configuration flow.
The check is removed since the supported features bitmask field
is retrieved only after calling ENA_ADMIN_DEVICE_ATTRIBUTES admin command.

If set host info is not supported an error will be returned by the device.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c    | 8 +++-----
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 5 +++--
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 8029e7c..08d11ce 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -2451,11 +2451,9 @@ int ena_com_set_host_attributes(struct ena_com_dev *ena_dev)
 
 	int ret;
 
-	if (!ena_com_check_supported_feature_id(ena_dev,
-						ENA_ADMIN_HOST_ATTR_CONFIG)) {
-		pr_warn("Set host attribute isn't supported\n");
-		return -EPERM;
-	}
+	/* Host attribute config is called before ena_com_get_dev_attr_feat
+	 * so ena_com can't check if the feature is supported.
+	 */
 
 	memset(&cmd, 0x0, sizeof(cmd));
 	admin_queue = &ena_dev->admin_queue;
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 96048bd..7b9c80f 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2416,6 +2416,8 @@ static int ena_device_init(struct ena_com_dev *ena_dev, struct pci_dev *pdev,
 	 */
 	ena_com_set_admin_polling_mode(ena_dev, true);
 
+	ena_config_host_info(ena_dev);
+
 	/* Get Device Attributes*/
 	rc = ena_com_get_dev_attr_feat(ena_dev, get_feat_ctx);
 	if (rc) {
@@ -2440,11 +2442,10 @@ static int ena_device_init(struct ena_com_dev *ena_dev, struct pci_dev *pdev,
 
 	*wd_state = !!(aenq_groups & BIT(ENA_ADMIN_KEEP_ALIVE));
 
-	ena_config_host_info(ena_dev);
-
 	return 0;
 
 err_admin_init:
+	ena_com_delete_host_info(ena_dev);
 	ena_com_admin_destroy(ena_dev);
 err_mmio_read_less:
 	ena_com_mmio_reg_read_request_destroy(ena_dev);
-- 
2.7.4
