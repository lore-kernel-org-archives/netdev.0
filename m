From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/3] qlcnic: Fix loopback diagnostic test
Date: Thu, 2 Jan 2014 13:38:43 -0500
Message-ID: <1388687925-17882-2-git-send-email-manish.chopra@qlogic.com>
References: <1388687925-17882-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41135 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751067AbaABTS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 14:18:27 -0500
In-Reply-To: <1388687925-17882-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Adapter requires that if the port is in loopback mode no traffic should
  be flowing through that port, so on arrival of Link up AEN, do not advertise
  Link up to the stack until port is out of loopback mode

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         | 2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 7 +------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c      | 4 ++++
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 631ea0a..4dfef81 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -487,6 +487,7 @@ struct qlcnic_hardware_context {
 	struct qlcnic_mailbox *mailbox;
 	u8 extend_lb_time;
 	u8 phys_port_id[ETH_ALEN];
+	u8 lb_mode;
 };
 
 struct qlcnic_adapter_stats {
@@ -808,6 +809,7 @@ struct qlcnic_mac_list_s {
 
 #define QLCNIC_ILB_MODE		0x1
 #define QLCNIC_ELB_MODE		0x2
+#define QLCNIC_LB_MODE_MASK	0x3
 
 #define QLCNIC_LINKEVENT	0x1
 #define QLCNIC_LB_RESPONSE	0x2
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 6055d39..f776f99 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1684,12 +1684,6 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 		}
 	} while ((adapter->ahw->linkup && ahw->has_link_events) != 1);
 
-	/* Make sure carrier is off and queue is stopped during loopback */
-	if (netif_running(netdev)) {
-		netif_carrier_off(netdev);
-		netif_tx_stop_all_queues(netdev);
-	}
-
 	ret = qlcnic_do_lb_test(adapter, mode);
 
 	qlcnic_83xx_clear_lb_mode(adapter, mode);
@@ -2121,6 +2115,7 @@ static void qlcnic_83xx_handle_link_aen(struct qlcnic_adapter *adapter,
 	ahw->link_autoneg = MSB(MSW(data[3]));
 	ahw->module_type = MSB(LSW(data[3]));
 	ahw->has_link_events = 1;
+	ahw->lb_mode = data[4] & QLCNIC_LB_MODE_MASK;
 	qlcnic_advert_link_change(adapter, link_status);
 }
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index eda6c69..1362976 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -689,6 +689,10 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 		adapter->ahw->linkup = 0;
 		netif_carrier_off(netdev);
 	} else if (!adapter->ahw->linkup && linkup) {
+		/* Do not advertise Link up if the port is in loopback mode */
+		if (qlcnic_83xx_check(adapter) && adapter->ahw->lb_mode)
+			return;
+
 		netdev_info(netdev, "NIC Link is up\n");
 		adapter->ahw->linkup = 1;
 		netif_carrier_on(netdev);
-- 
1.8.3.1
