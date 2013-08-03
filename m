From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 7/8] qlcnic: Fix link speed and duplex display for 83xx adapter
Date: Fri, 2 Aug 2013 23:16:00 -0400
Message-ID: <1375499761-21141-8-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:60075 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746Ab3HCEDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 00:03:24 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Set link speed and duplex to unknown when link is not up.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   25 ++++++++++++-------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index bc483e1..94ff7a4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2075,18 +2075,25 @@ void qlcnic_83xx_config_intr_coal(struct qlcnic_adapter *adapter)
 static void qlcnic_83xx_handle_link_aen(struct qlcnic_adapter *adapter,
 					u32 data[])
 {
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u8 link_status, duplex;
 	/* link speed */
 	link_status = LSB(data[3]) & 1;
-	adapter->ahw->link_speed = MSW(data[2]);
-	adapter->ahw->link_autoneg = MSB(MSW(data[3]));
-	adapter->ahw->module_type = MSB(LSW(data[3]));
-	duplex = LSB(MSW(data[3]));
-	if (duplex)
-		adapter->ahw->link_duplex = DUPLEX_FULL;
-	else
-		adapter->ahw->link_duplex = DUPLEX_HALF;
-	adapter->ahw->has_link_events = 1;
+	if (link_status) {
+		ahw->link_speed = MSW(data[2]);
+		duplex = LSB(MSW(data[3]));
+		if (duplex)
+			ahw->link_duplex = DUPLEX_FULL;
+		else
+			ahw->link_duplex = DUPLEX_HALF;
+	} else {
+		ahw->link_speed = SPEED_UNKNOWN;
+		ahw->link_duplex = DUPLEX_UNKNOWN;
+	}
+
+	ahw->link_autoneg = MSB(MSW(data[3]));
+	ahw->module_type = MSB(LSW(data[3]));
+	ahw->has_link_events = 1;
 	qlcnic_advert_link_change(adapter, link_status);
 }
 
-- 
1.5.6
