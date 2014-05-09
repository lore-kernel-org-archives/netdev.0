From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH v2 net-next 3/5] qlcnic: Add mac learning support to SR-IOV VF.
Date: Fri, 9 May 2014 02:51:31 -0400
Message-ID: <1399618293-28633-4-git-send-email-rajesh.borundia@qlogic.com>
References: <1399618293-28633-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45841 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751410AbaEIHUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 03:20:25 -0400
In-Reply-To: <1399618293-28633-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o SR-IOV VF can be uplinked to bridge/macvtap device.
  Enable mac learning to support communication through
  embedded switch.
o Learn vlan filters based on QLCNIC_VLAN_FILTERING flag.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   12 +++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   12 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   16 +++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    1 +
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   51 +++++++++++++++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   14 ++----
 6 files changed, 78 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7bad613..557b911 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1019,6 +1019,8 @@ struct qlcnic_ipaddr {
 #define QLCNIC_DEL_VXLAN_PORT		0x200000
 #endif
 
+#define QLCNIC_VLAN_FILTERING		0x800000
+
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 #define QLCNIC_IS_TSO_CAPABLE(adapter)  \
@@ -2355,6 +2357,16 @@ static inline bool qlcnic_83xx_vf_check(struct qlcnic_adapter *adapter)
 	return (device == PCI_DEVICE_ID_QLOGIC_VF_QLE834X) ? true : false;
 }
 
+static inline bool qlcnic_sriov_check(struct qlcnic_adapter *adapter)
+{
+	bool status;
+
+	status = (qlcnic_sriov_pf_check(adapter) ||
+		  qlcnic_sriov_vf_check(adapter)) ? true : false;
+
+	return status;
+}
+
 static inline u32 qlcnic_get_vnic_func_count(struct qlcnic_adapter *adapter)
 {
 	if (qlcnic_84xx_check(adapter))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index deb2278..e45bf09 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -313,20 +313,16 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	u16 vlan_id = 0;
 	u8 hindex, hval;
 
-	if (!qlcnic_sriov_pf_check(adapter)) {
-		if (ether_addr_equal(phdr->h_source, adapter->mac_addr))
-			return;
-	} else {
+	if (ether_addr_equal(phdr->h_source, adapter->mac_addr))
+		return;
+
+	if (adapter->flags & QLCNIC_VLAN_FILTERING) {
 		if (protocol == ETH_P_8021Q) {
 			vh = (struct vlan_ethhdr *)skb->data;
 			vlan_id = ntohs(vh->h_vlan_TCI);
 		} else if (vlan_tx_tag_present(skb)) {
 			vlan_id = vlan_tx_tag_get(skb);
 		}
-
-		if (ether_addr_equal(phdr->h_source, adapter->mac_addr) &&
-		    !vlan_id)
-			return;
 	}
 
 	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1a52a78..8a570fa 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -378,7 +378,8 @@ static int qlcnic_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!adapter->fdb_mac_learn)
 		return ndo_dflt_fdb_del(ndm, tb, netdev, addr);
 
-	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
+	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+	    qlcnic_sriov_check(adapter)) {
 		if (is_unicast_ether_addr(addr)) {
 			err = dev_uc_del(netdev, addr);
 			if (!err)
@@ -402,7 +403,8 @@ static int qlcnic_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!adapter->fdb_mac_learn)
 		return ndo_dflt_fdb_add(ndm, tb, netdev, addr, flags);
 
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) &&
+	    !qlcnic_sriov_check(adapter)) {
 		pr_info("%s: FDB e-switch is not enabled\n", __func__);
 		return -EOPNOTSUPP;
 	}
@@ -432,7 +434,8 @@ static int qlcnic_fdb_dump(struct sk_buff *skb, struct netlink_callback *ncb,
 	if (!adapter->fdb_mac_learn)
 		return ndo_dflt_fdb_dump(skb, ncb, netdev, idx);
 
-	if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
+	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+	    qlcnic_sriov_check(adapter))
 		idx = ndo_dflt_fdb_dump(skb, ncb, netdev, idx);
 
 	return idx;
@@ -2809,6 +2812,8 @@ static int qlcnic_close(struct net_device *netdev)
 	return 0;
 }
 
+#define QLCNIC_VF_LB_BUCKET_SIZE 1
+
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 {
 	void *head;
@@ -2824,7 +2829,10 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 	spin_lock_init(&adapter->mac_learn_lock);
 	spin_lock_init(&adapter->rx_mac_learn_lock);
 
-	if (qlcnic_82xx_check(adapter)) {
+	if (qlcnic_sriov_vf_check(adapter)) {
+		filter_size = QLCNIC_83XX_SRIOV_VF_MAX_MAC - 1;
+		adapter->fhash.fbucket_size = QLCNIC_VF_LB_BUCKET_SIZE;
+	} else if (qlcnic_82xx_check(adapter)) {
 		filter_size = QLCNIC_LB_MAX_FILTERS;
 		adapter->fhash.fbucket_size = QLCNIC_LB_BUCKET_SIZE;
 	} else {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 54159bd..335b50f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -52,6 +52,7 @@ enum qlcnic_bc_commands {
 	QLCNIC_BC_CMD_CFG_GUEST_VLAN = 0x3,
 };
 
+#define QLCNIC_83XX_SRIOV_VF_MAX_MAC 2
 #define QLC_BC_CMD 1
 
 struct qlcnic_trans_list {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 44cd5bd..3b39ab2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -199,6 +199,7 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 				goto qlcnic_destroy_async_wq;
 			}
 			sriov->vf_info[i].vp = vp;
+			vp->vlan_mode = QLC_GUEST_VLAN_MODE;
 			vp->max_tx_bw = MAX_BW;
 			vp->spoofchk = false;
 			random_ether_addr(vp->mac);
@@ -517,6 +518,8 @@ static int qlcnic_sriov_setup_vf(struct qlcnic_adapter *adapter,
 {
 	int err;
 
+	adapter->flags |= QLCNIC_VLAN_FILTERING;
+	adapter->ahw->total_nic_func = 1;
 	INIT_LIST_HEAD(&adapter->vf_mc_list);
 	if (!qlcnic_use_msi_x && !!qlcnic_use_msi)
 		dev_warn(&adapter->pdev->dev,
@@ -772,6 +775,7 @@ static int qlcnic_sriov_prepare_bc_hdr(struct qlcnic_bc_trans *trans,
 		cmd->req.arg = (u32 *)trans->req_pay;
 		cmd->rsp.arg = (u32 *)trans->rsp_pay;
 		cmd_op = cmd->req.arg[0] & 0xff;
+		cmd->cmd_op = cmd_op;
 		remainder = (trans->rsp_pay_size) % (bc_pay_sz);
 		num_frags = (trans->rsp_pay_size) / (bc_pay_sz);
 		if (remainder)
@@ -1410,12 +1414,17 @@ retry:
 	    (mbx_err_code == QLCNIC_MBX_PORT_RSP_OK)) {
 		rsp = QLCNIC_RCODE_SUCCESS;
 	} else {
-		rsp = mbx_err_code;
-		if (!rsp)
-			rsp = 1;
-		dev_err(dev,
-			"MBX command 0x%x failed with err:0x%x for VF %d\n",
-			opcode, mbx_err_code, func);
+		if (cmd->type == QLC_83XX_MBX_CMD_NO_WAIT) {
+			rsp = QLCNIC_RCODE_SUCCESS;
+		} else {
+			rsp = mbx_err_code;
+			if (!rsp)
+				rsp = 1;
+
+			dev_err(dev,
+				"MBX command 0x%x failed with err:0x%x for VF %d\n",
+				opcode, mbx_err_code, func);
+		}
 	}
 
 err_out:
@@ -1537,6 +1546,28 @@ void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
 		}
 	}
 
+	/* configure unicast MAC address, if there is not sufficient space
+	 * to store all the unicast addresses then enable promiscuous mode
+	 */
+	if (netdev_uc_count(netdev) > ahw->max_uc_count) {
+		mode = VPORT_MISS_MODE_ACCEPT_ALL;
+	} else if (!netdev_uc_empty(netdev)) {
+		netdev_for_each_uc_addr(ha, netdev)
+			qlcnic_vf_add_mc_list(netdev, ha->addr);
+	}
+
+	if (adapter->pdev->is_virtfn) {
+		if (mode == VPORT_MISS_MODE_ACCEPT_ALL &&
+		    !adapter->fdb_mac_learn) {
+			qlcnic_alloc_lb_filters_mem(adapter);
+			adapter->drv_mac_learn = 1;
+			adapter->rx_mac_learn = true;
+		} else {
+			adapter->drv_mac_learn = 0;
+			adapter->rx_mac_learn = false;
+		}
+	}
+
 	qlcnic_nic_set_promisc(adapter, mode);
 }
 
@@ -1830,6 +1861,12 @@ static int qlcnic_sriov_vf_idc_unknown_state(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+static void qlcnic_sriov_vf_periodic_tasks(struct qlcnic_adapter *adapter)
+{
+	if (adapter->fhash.fnum)
+		qlcnic_prune_lb_filters(adapter);
+}
+
 static void qlcnic_sriov_vf_poll_dev_state(struct work_struct *work)
 {
 	struct qlcnic_adapter *adapter;
@@ -1861,6 +1898,8 @@ static void qlcnic_sriov_vf_poll_dev_state(struct work_struct *work)
 	}
 
 	idc->prev_state = idc->curr_state;
+	qlcnic_sriov_vf_periodic_tasks(adapter);
+
 	if (!ret && test_bit(QLC_83XX_MODULE_LOADED, &idc->status))
 		qlcnic_schedule_work(adapter, qlcnic_sriov_vf_poll_dev_state,
 				     idc->delay);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 199ab7c..6d2f72f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -84,7 +84,7 @@ static int qlcnic_sriov_pf_cal_res_limit(struct qlcnic_adapter *adapter,
 	info->max_tx_ques = res->num_tx_queues / max;
 
 	if (qlcnic_83xx_pf_check(adapter))
-		num_macs = 1;
+		num_macs = QLCNIC_83XX_SRIOV_VF_MAX_MAC;
 
 	info->max_rx_mcast_mac_filters = res->num_rx_mcast_mac_filters;
 
@@ -338,9 +338,12 @@ static int qlcnic_sriov_pf_cfg_vlan_filtering(struct qlcnic_adapter *adapter,
 
 	cmd.req.arg[1] = 0x4;
 	if (enable) {
+		adapter->flags |= QLCNIC_VLAN_FILTERING;
 		cmd.req.arg[1] |= BIT_16;
 		if (qlcnic_84xx_check(adapter))
 			cmd.req.arg[1] |= QLC_SRIOV_ALLOW_VLAN0;
+	} else {
+		adapter->flags &= ~QLCNIC_VLAN_FILTERING;
 	}
 
 	err = qlcnic_issue_cmd(adapter, &cmd);
@@ -1253,7 +1256,6 @@ static int qlcnic_sriov_validate_cfg_macvlan(struct qlcnic_adapter *adapter,
 					     struct qlcnic_vf_info *vf,
 					     struct qlcnic_cmd_args *cmd)
 {
-	struct qlcnic_macvlan_mbx *macvlan;
 	struct qlcnic_vport *vp = vf->vp;
 	u8 op, new_op;
 
@@ -1263,14 +1265,6 @@ static int qlcnic_sriov_validate_cfg_macvlan(struct qlcnic_adapter *adapter,
 	cmd->req.arg[1] |= (vf->vp->handle << 16);
 	cmd->req.arg[1] |= BIT_31;
 
-	macvlan = (struct qlcnic_macvlan_mbx *)&cmd->req.arg[2];
-	if (!(macvlan->mac_addr0 & BIT_0)) {
-		dev_err(&adapter->pdev->dev,
-			"MAC address change is not allowed from VF %d",
-			vf->pci_func);
-		return -EINVAL;
-	}
-
 	if (vp->vlan_mode == QLC_PVID_MODE) {
 		op = cmd->req.arg[1] & 0x7;
 		cmd->req.arg[1] &= ~0x7;
-- 
1.6.3.3
