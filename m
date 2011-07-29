From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: Fix delay in reset path
Date: Fri, 29 Jul 2011 16:30:27 -0700
Message-ID: <1311982230-10543-3-git-send-email-anirban.chakraborty@qlogic.com>
References: <1311982230-10543-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:28032
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753058Ab1G2Xjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 19:39:53 -0400
In-Reply-To: <1311982230-10543-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Driver should not check for heart beat anymore when FW is hung, rather it
should restart the FW.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_init.c |    3 ++-
 drivers/net/qlcnic/qlcnic_main.c |    5 +++++
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 4200ef8..5f0141b 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -911,6 +911,7 @@ struct qlcnic_ipaddr {
 #define QLCNIC_PROMISC_DISABLED		0x800
 #define QLCNIC_NEED_FLR			0x1000
 #define QLCNIC_FW_RESET_OWNER		0x2000
+#define QLCNIC_FW_HANG			0x4000
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index ee8a398..3b6741e 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1056,7 +1056,8 @@ qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
 int
 qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
 {
-	if (qlcnic_check_fw_hearbeat(adapter)) {
+	if ((adapter->flags & QLCNIC_FW_HANG) ||
+			qlcnic_check_fw_hearbeat(adapter)) {
 		qlcnic_rom_lock_recovery(adapter);
 		return 1;
 	}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 5ca1b56..248ebbd 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2682,6 +2682,7 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8 failed)
 	qlcnic_api_unlock(adapter);
 err:
 	adapter->fw_fail_cnt = 0;
+	adapter->flags &= ~QLCNIC_FW_HANG;
 	clear_bit(__QLCNIC_START_FW, &adapter->state);
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 }
@@ -2859,6 +2860,7 @@ skip_ack_check:
 		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
 			QLCDB(adapter, DRV, "Take FW dump\n");
 			qlcnic_dump_fw(adapter);
+			adapter->flags |= QLCNIC_FW_HANG;
 		}
 		rtnl_unlock();
 
@@ -3046,6 +3048,7 @@ attach:
 done:
 	netif_device_attach(netdev);
 	adapter->fw_fail_cnt = 0;
+	adapter->flags &= ~QLCNIC_FW_HANG;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
 	if (!qlcnic_clr_drv_state(adapter))
@@ -3090,6 +3093,8 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 	if (++adapter->fw_fail_cnt < FW_FAIL_THRESH)
 		return 0;
 
+	adapter->flags |= QLCNIC_FW_HANG;
+
 	qlcnic_dev_request_reset(adapter);
 
 	if (auto_fw_reset)
-- 
1.7.4.1


