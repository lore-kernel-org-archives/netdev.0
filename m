From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 3/5] qlcnic: track vxlan port count
Date: Thu, 17 Sep 2015 16:11:12 +0200
Message-ID: <dbf2967e209b64318d34cd18a637d12abdb939fb.1442498316.git.jbenc@redhat.com>
References: <cover.1442498316.git.jbenc@redhat.com>
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751737AbbIQOL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:11:26 -0400
In-Reply-To: <cover.1442498316.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The callback for adding vxlan port can be called with the same port for
both IPv4 and IPv6. Do not disable the offloading when the same port for
both protocols is added and later one of them removed.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 18 +++++++++++++-----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 06bcc734fe8d..d6696cfa11d2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -536,6 +536,7 @@ struct qlcnic_hardware_context {
 	u8 extend_lb_time;
 	u8 phys_port_id[ETH_ALEN];
 	u8 lb_mode;
+	u8 vxlan_port_count;
 	u16 vxlan_port;
 	struct device *hwmon_dev;
 	u32 post_mode;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8b08b20e8b30..d4481454b5f8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -483,11 +483,17 @@ static void qlcnic_add_vxlan_port(struct net_device *netdev,
 	/* Adapter supports only one VXLAN port. Use very first port
 	 * for enabling offload
 	 */
-	if (!qlcnic_encap_rx_offload(adapter) || ahw->vxlan_port)
+	if (!qlcnic_encap_rx_offload(adapter))
 		return;
+	if (!ahw->vxlan_port_count) {
+		ahw->vxlan_port_count = 1;
+		ahw->vxlan_port = ntohs(port);
+		adapter->flags |= QLCNIC_ADD_VXLAN_PORT;
+		return;
+	}
+	if (ahw->vxlan_port == ntohs(port))
+		ahw->vxlan_port_count++;
 
-	ahw->vxlan_port = ntohs(port);
-	adapter->flags |= QLCNIC_ADD_VXLAN_PORT;
 }
 
 static void qlcnic_del_vxlan_port(struct net_device *netdev,
@@ -496,11 +502,13 @@ static void qlcnic_del_vxlan_port(struct net_device *netdev,
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	if (!qlcnic_encap_rx_offload(adapter) || !ahw->vxlan_port ||
+	if (!qlcnic_encap_rx_offload(adapter) || !ahw->vxlan_port_count ||
 	    (ahw->vxlan_port != ntohs(port)))
 		return;
 
-	adapter->flags |= QLCNIC_DEL_VXLAN_PORT;
+	ahw->vxlan_port_count--;
+	if (!ahw->vxlan_port_count)
+		adapter->flags |= QLCNIC_DEL_VXLAN_PORT;
 }
 
 static netdev_features_t qlcnic_features_check(struct sk_buff *skb,
-- 
1.8.3.1
