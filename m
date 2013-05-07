From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 6/8] qlcnic: Fix bug in diagnostics test reset recovery path
Date: Tue, 7 May 2013 15:55:04 -0400
Message-ID: <1367956506-3290-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:40243
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758587Ab3EGUUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 16:20:23 -0400
In-Reply-To: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o In order to perform reset recovery during diagnostics tests,
  current device status information need to be preserved.
  This patch makes the required changes in diagnostics routines

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 8a82003..c38c6f6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1276,11 +1276,13 @@ out:
 	return err;
 }
 
-static int qlcnic_83xx_diag_alloc_res(struct net_device *netdev, int test)
+static int qlcnic_83xx_diag_alloc_res(struct net_device *netdev, int test,
+				      int num_sds_ring)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_host_rds_ring *rds_ring;
+	u16 adapter_state = adapter->is_up;
 	u8 ring;
 	int ret;
 
@@ -1304,6 +1306,10 @@ static int qlcnic_83xx_diag_alloc_res(struct net_device *netdev, int test)
 	ret = qlcnic_fw_create_ctx(adapter);
 	if (ret) {
 		qlcnic_detach(adapter);
+		if (adapter_state == QLCNIC_ADAPTER_UP_MAGIC) {
+			adapter->max_sds_rings = num_sds_ring;
+			qlcnic_attach(adapter);
+		}
 		netif_device_attach(netdev);
 		return ret;
 	}
@@ -1596,7 +1602,8 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
 		return -EBUSY;
 
-	ret = qlcnic_83xx_diag_alloc_res(netdev, QLCNIC_LOOPBACK_TEST);
+	ret = qlcnic_83xx_diag_alloc_res(netdev, QLCNIC_LOOPBACK_TEST,
+					 max_sds_rings);
 	if (ret)
 		goto fail_diag_alloc;
 
@@ -3109,7 +3116,8 @@ int qlcnic_83xx_interrupt_test(struct net_device *netdev)
 	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
 		return -EIO;
 
-	ret = qlcnic_83xx_diag_alloc_res(netdev, QLCNIC_INTERRUPT_TEST);
+	ret = qlcnic_83xx_diag_alloc_res(netdev, QLCNIC_INTERRUPT_TEST,
+					 max_sds_rings);
 	if (ret)
 		goto fail_diag_irq;
 
-- 
1.5.6
