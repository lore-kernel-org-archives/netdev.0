From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/7] be2net: Add link state control for VFs
Date: Tue, 11 Mar 2014 18:53:04 +0530
Message-ID: <1394544189-20277-3-git-send-email-sathya.perla@emulex.com>
References: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:35589 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbaCKNT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:19:56 -0400
In-Reply-To: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

Add support to control VF's link state by implementing the
ndo_set_vf_link_state() hook.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |   50 +++++++++++++++++++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |   10 +++++
 drivers/net/ethernet/emulex/benet/be_main.c |   32 ++++++++++++++++-
 4 files changed, 88 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a91267b..d08c707 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -359,6 +359,7 @@ struct be_vf_cfg {
 	int pmac_id;
 	u16 vlan_tag;
 	u32 tx_rate;
+	u32 plink_tracking;
 };
 
 enum vf_state {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 72bde5d..ff353d7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -202,8 +202,12 @@ static void be_async_link_state_process(struct be_adapter *adapter,
 	/* When link status changes, link speed must be re-queried from FW */
 	adapter->phy.link_speed = -1;
 
-	/* Ignore physical link event */
-	if (lancer_chip(adapter) &&
+	/* On BEx the FW does not send a separate link status
+	 * notification for physical and logical link.
+	 * On other chips just process the logical link
+	 * status notification
+	 */
+	if (!BEx_chip(adapter) &&
 	    !(evt->port_link_status & LOGICAL_LINK_STATUS_MASK))
 		return;
 
@@ -211,7 +215,8 @@ static void be_async_link_state_process(struct be_adapter *adapter,
 	 * it may not be received in some cases.
 	 */
 	if (adapter->flags & BE_FLAGS_LINK_STATUS_INIT)
-		be_link_status_update(adapter, evt->port_link_status);
+		be_link_status_update(adapter,
+				      evt->port_link_status & LINK_STATUS_MASK);
 }
 
 /* Grp5 CoS Priority evt */
@@ -3743,6 +3748,45 @@ err:
 	return status;
 }
 
+int be_cmd_set_logical_link_config(struct be_adapter *adapter,
+				   int link_state, u8 domain)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_ll_link *req;
+	int status;
+
+	if (BEx_chip(adapter) || lancer_chip(adapter))
+		return 0;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_SET_LOGICAL_LINK_CONFIG,
+			       sizeof(*req), wrb, NULL);
+
+	req->hdr.version = 1;
+	req->hdr.domain = domain;
+
+	if (link_state == IFLA_VF_LINK_STATE_ENABLE)
+		req->link_config |= 1;
+
+	if (link_state == IFLA_VF_LINK_STATE_AUTO)
+		req->link_config |= 1 << PLINK_TRACK_SHIFT;
+
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 			int wrb_payload_size, u16 *cmd_status, u16 *ext_status)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index d0ab980..fda3e88 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -203,6 +203,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
 #define OPCODE_COMMON_GET_PORT_NAME			77
+#define OPCODE_COMMON_SET_LOGICAL_LINK_CONFIG		80
 #define OPCODE_COMMON_SET_INTERRUPT_ENABLE		89
 #define OPCODE_COMMON_SET_FN_PRIVILEGES			100
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
@@ -1991,6 +1992,13 @@ struct be_cmd_resp_get_iface_list {
 	struct be_if_desc if_desc;
 };
 
+/*************** Set logical link ********************/
+#define PLINK_TRACK_SHIFT	8
+struct be_cmd_req_set_ll_link {
+	struct be_cmd_req_hdr hdr;
+	u32 link_config; /* Bit 0: UP_DOWN, Bit 9: PLINK */
+};
+
 int be_pci_fnum_get(struct be_adapter *adapter);
 int be_fw_wait_ready(struct be_adapter *adapter);
 int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -2112,3 +2120,5 @@ int be_cmd_get_if_id(struct be_adapter *adapter, struct be_vf_cfg *vf_cfg,
 		     int vf_num);
 int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain);
 int be_cmd_intr_set(struct be_adapter *adapter, bool intr_enable);
+int be_cmd_set_logical_link_config(struct be_adapter *adapter,
+					  int link_state, u8 domain);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5ba1ea5..2f02bcb 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -652,7 +652,7 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 		adapter->flags |= BE_FLAGS_LINK_STATUS_INIT;
 	}
 
-	if ((link_status & LINK_STATUS_MASK) == LINK_UP)
+	if (link_status)
 		netif_carrier_on(netdev);
 	else
 		netif_carrier_off(netdev);
@@ -1288,6 +1288,7 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 	vi->vlan = vf_cfg->vlan_tag & VLAN_VID_MASK;
 	vi->qos = vf_cfg->vlan_tag >> VLAN_PRIO_SHIFT;
 	memcpy(&vi->mac, vf_cfg->mac_addr, ETH_ALEN);
+	vi->linkstate = adapter->vf_cfg[vf].plink_tracking;
 
 	return 0;
 }
@@ -1354,6 +1355,24 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 		adapter->vf_cfg[vf].tx_rate = rate;
 	return status;
 }
+static int be_set_vf_link_state(struct net_device *netdev, int vf,
+				int link_state)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status;
+
+	if (!sriov_enabled(adapter))
+		return -EPERM;
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	status = be_cmd_set_logical_link_config(adapter, link_state, vf+1);
+	if (!status)
+		adapter->vf_cfg[vf].plink_tracking = link_state;
+
+	return status;
+}
 
 static void be_aic_update(struct be_aic_obj *aic, u64 rx_pkts, u64 tx_pkts,
 			  ulong now)
@@ -3109,8 +3128,12 @@ static int be_vf_setup(struct be_adapter *adapter)
 		if (!status)
 			vf_cfg->tx_rate = lnk_speed;
 
-		if (!old_vfs)
+		if (!old_vfs) {
 			be_cmd_enable_vf(adapter, vf + 1);
+			be_cmd_set_logical_link_config(adapter,
+						       IFLA_VF_LINK_STATE_AUTO,
+						       vf+1);
+		}
 	}
 
 	if (!old_vfs) {
@@ -3467,6 +3490,10 @@ static int be_setup(struct be_adapter *adapter)
 		be_cmd_set_flow_control(adapter, adapter->tx_fc,
 					adapter->rx_fc);
 
+	if (be_physfn(adapter))
+		be_cmd_set_logical_link_config(adapter,
+					       IFLA_VF_LINK_STATE_AUTO, 0);
+
 	if (sriov_want(adapter)) {
 		if (be_max_vfs(adapter))
 			be_vf_setup(adapter);
@@ -4106,6 +4133,7 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_set_vf_vlan	= be_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= be_set_vf_tx_rate,
 	.ndo_get_vf_config	= be_get_vf_config,
+	.ndo_set_vf_link_state  = be_set_vf_link_state,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= be_netpoll,
 #endif
-- 
1.7.1
