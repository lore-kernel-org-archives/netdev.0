From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure qlcnic_hardware_context
Date: Sat, 22 Jun 2013 04:12:04 -0400
Message-ID: <1371888727-16422-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:5397 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932344Ab3FVIi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 04:38:29 -0400
In-Reply-To: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h       |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c    |    3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index cc2c2c1..5694d59 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -449,7 +449,7 @@ struct qlcnic_hardware_context {
 	u16 max_pci_func;
 
 	u32 capabilities;
-	u32 capabilities2;
+	u32 extra_capability[3];
 	u32 temp;
 	u32 int_vec_bit;
 	u32 fw_hal_version;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index e7f305d..9fcbfd4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -786,7 +786,8 @@ int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 	word = 0;
 	if (enable) {
 		word = QLCNIC_ENABLE_IPV4_LRO | QLCNIC_NO_DEST_IPV4_CHECK;
-		if (adapter->ahw->capabilities2 & QLCNIC_FW_CAP2_HW_LRO_IPV6)
+		if (adapter->ahw->extra_capability[0] &
+		    QLCNIC_FW_CAP2_HW_LRO_IPV6)
 			word |= QLCNIC_ENABLE_IPV6_LRO |
 				QLCNIC_NO_DEST_IPV6_CHECK;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8e1453a..3963e78 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -994,7 +994,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
 		u32 temp;
 		temp = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
-		adapter->ahw->capabilities2 = temp;
+		adapter->ahw->extra_capability[0] = temp;
 	}
 	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
 	adapter->ahw->max_mtu = nic_info.max_mtu;
@@ -1486,7 +1486,7 @@ static void qlcnic_get_lro_mss_capability(struct qlcnic_adapter *adapter)
 	u32 capab = 0;
 
 	if (qlcnic_82xx_check(adapter)) {
-		if (adapter->ahw->capabilities2 &
+		if (adapter->ahw->extra_capability[0] &
 		    QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
 			adapter->flags |= QLCNIC_FW_LRO_MSS_CAP;
 	} else {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 7ec030a..10ed82b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -168,7 +168,7 @@ static int qlcnic_82xx_store_beacon(struct qlcnic_adapter *adapter,
 	if (err)
 		return err;
 
-	if ((ahw->capabilities2 & QLCNIC_FW_CAPABILITY_2_BEACON)) {
+	if (ahw->extra_capability[0] & QLCNIC_FW_CAPABILITY_2_BEACON) {
 		err = qlcnic_get_beacon_state(adapter, &h_beacon_state);
 		if (!err) {
 			dev_info(&adapter->pdev->dev,
-- 
1.7.1
