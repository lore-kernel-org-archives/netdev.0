From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 6/9] qlcnic: check IDC version
Date: Thu, 13 May 2010 06:07:47 -0700
Message-ID: <1273756070-7205-7-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58024 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753949Ab0EMNHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:53 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Warn user if IDC version mismatch with different class of drivers.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_main.c |   20 ++++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index ed9df15..8a9412f 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -53,6 +53,7 @@
 #define _QLCNIC_LINUX_MINOR 0
 #define _QLCNIC_LINUX_SUBVERSION 2
 #define QLCNIC_LINUX_VERSIONID  "5.0.2"
+#define QLCNIC_DRV_IDC_VER  0x01
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index d86c50d..e94a96d 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1976,12 +1976,25 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 		return 1;
 }
 
+static int qlcnic_check_idc_ver(struct qlcnic_adapter *adapter)
+{
+	u32 val = QLCRD32(adapter, QLCNIC_CRB_DRV_IDC_VER);
+
+	if (val != QLCNIC_DRV_IDC_VER) {
+		dev_warn(&adapter->pdev->dev, "IDC Version mismatch, driver's"
+			" idc ver = %x; reqd = %x\n", QLCNIC_DRV_IDC_VER, val);
+	}
+
+	return 0;
+}
+
 static int
 qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 {
 	u32 val, prev_state;
 	u8 dev_init_timeo = adapter->dev_init_timeo;
 	u8 portnum = adapter->portnum;
+	u8 ret;
 
 	if (test_and_clear_bit(__QLCNIC_START_FW, &adapter->state))
 		return 1;
@@ -2001,12 +2014,14 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR32(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
 		qlcnic_api_unlock(adapter);
 		return 1;
 
 	case QLCNIC_DEV_READY:
+		ret = qlcnic_check_idc_ver(adapter);
 		qlcnic_api_unlock(adapter);
-		return 0;
+		return ret;
 
 	case QLCNIC_DEV_NEED_RESET:
 		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
@@ -2049,9 +2064,10 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	QLC_DEV_CLR_RST_QSCNT(val, portnum);
 	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 
+	ret = qlcnic_check_idc_ver(adapter);
 	qlcnic_api_unlock(adapter);
 
-	return 0;
+	return ret;
 }
 
 static void
-- 
1.6.0.2

