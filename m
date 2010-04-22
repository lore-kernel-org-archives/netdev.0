From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/8] qlcnic: define macro for driver state
Date: Thu, 22 Apr 2010 05:51:38 -0700
Message-ID: <1271940702-17064-5-git-send-email-amit.salecha@qlogic.com>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58772 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754580Ab0DVMvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:44 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defining macro to set and clear driver state.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hdr.h  |    6 ++++++
 drivers/net/qlcnic/qlcnic_main.c |   22 +++++++++++-----------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 8285a06..a984cd2 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -707,6 +707,12 @@ enum {
 #define QLCNIC_DEV_FAILED		0x6
 #define QLCNIC_DEV_QUISCENT		0x7
 
+#define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
+#define QLC_DEV_CLR_REF_CNT(VAL, FN)		((VAL) &= ~(1 << (FN * 4)))
+#define QLC_DEV_SET_RST_RDY(VAL, FN)		((VAL) |= (1 << (FN * 4)))
+#define QLC_DEV_SET_QSCNT_RDY(VAL, FN)		((VAL) |= (2 << (FN * 4)))
+#define QLC_DEV_CLR_RST_QSCNT(VAL, FN)		((VAL) &= ~(3 << (FN * 4)))
+
 #define QLCNIC_RCODE_DRIVER_INFO		0x20000000
 #define QLCNIC_RCODE_DRIVER_CAN_RELOAD		0x40000000
 #define QLCNIC_RCODE_FATAL_ERROR		0x80000000
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 0634990..3c8a963 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1963,9 +1963,9 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, int state)
 	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
 
 	if (state == QLCNIC_DEV_NEED_RESET)
-		val |= ((u32)0x1 << (adapter->portnum * 4));
+		QLC_DEV_SET_RST_RDY(val, adapter->portnum);
 	else if (state == QLCNIC_DEV_NEED_QUISCENT)
-		val |= ((u32)0x1 << ((adapter->portnum * 4) + 1));
+		QLC_DEV_SET_QSCNT_RDY(val, adapter->portnum);
 
 	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 
@@ -1981,7 +1981,7 @@ qlcnic_clr_drv_state(struct qlcnic_adapter *adapter)
 		return -EBUSY;
 
 	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	val &= ~((u32)0x3 << (adapter->portnum * 4));
+	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
 	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
@@ -1998,14 +1998,14 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter)
 		goto err;
 
 	val = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
-	val &= ~((u32)0x1 << (adapter->portnum * 4));
+	QLC_DEV_CLR_REF_CNT(val, adapter->portnum);
 	QLCWR32(adapter, QLCNIC_CRB_DEV_REF_COUNT, val);
 
 	if (!(val & 0x11111111))
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
 
 	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	val &= ~((u32)0x3 << (adapter->portnum * 4));
+	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
 	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
@@ -2036,7 +2036,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 {
 	u32 val, prev_state;
 	u8 dev_init_timeo = adapter->dev_init_timeo;
-	int portnum = adapter->portnum;
+	u8 portnum = adapter->portnum;
 
 	if (test_and_clear_bit(__QLCNIC_START_FW, &adapter->state))
 		return 1;
@@ -2045,8 +2045,8 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 		return -1;
 
 	val = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
-	if (!(val & ((int)0x1 << (portnum * 4)))) {
-		val |= ((u32)0x1 << (portnum * 4));
+	if (!(val & (1 << (portnum * 4)))) {
+		QLC_DEV_SET_REF_CNT(val, portnum);
 		QLCWR32(adapter, QLCNIC_CRB_DEV_REF_COUNT, val);
 	}
 
@@ -2065,13 +2065,13 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 
 	case QLCNIC_DEV_NEED_RESET:
 		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-		val |= ((u32)0x1 << (portnum * 4));
+		QLC_DEV_SET_RST_RDY(val, portnum);
 		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
 	case QLCNIC_DEV_NEED_QUISCENT:
 		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-		val |= ((u32)0x1 << ((portnum * 4) + 1));
+		QLC_DEV_SET_QSCNT_RDY(val, portnum);
 		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
@@ -2101,7 +2101,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 		return -1;
 
 	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	val &= ~((u32)0x3 << (portnum * 4));
+	QLC_DEV_CLR_RST_QSCNT(val, portnum);
 	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
-- 
1.6.0.2

