From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Add support to process commands in atomic context
Date: Wed, 7 May 2014 13:39:35 -0400
Message-ID: <1399484378-22864-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1399484378-22864-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:36596 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751298AbaEGSI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 14:08:28 -0400
In-Reply-To: <1399484378-22864-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Commands from VF may sleep during PF-VF communication.
  Earlier we use to process qlcnic_sriov_vf_set_multi
  function in process context. Now individual commands
  that are called in atomic context are processed in
  process context without waiting for completion of
  command.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   24 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    3 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |  136 ++++++++++----------
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   36 +++--
 6 files changed, 99 insertions(+), 106 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 09fe9c2..7bad613 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1693,7 +1693,7 @@ int qlcnic_read_mac_addr(struct qlcnic_adapter *);
 int qlcnic_setup_netdev(struct qlcnic_adapter *, struct net_device *, int);
 void qlcnic_set_netdev_features(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
-void qlcnic_sriov_vf_schedule_multi(struct net_device *);
+void qlcnic_sriov_vf_set_multi(struct net_device *);
 int qlcnic_is_valid_nic_func(struct qlcnic_adapter *, u8);
 int qlcnic_get_pci_func_type(struct qlcnic_adapter *, u16, u16 *, u16 *,
 			     u16 *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 9f3adf4..e5352b7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -567,28 +567,14 @@ static void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 void qlcnic_set_multi(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	struct qlcnic_mac_vlan_list *cur;
-	struct netdev_hw_addr *ha;
-	size_t temp;
 
 	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
 		return;
-	if (qlcnic_sriov_vf_check(adapter)) {
-		if (!netdev_mc_empty(netdev)) {
-			netdev_for_each_mc_addr(ha, netdev) {
-				temp = sizeof(struct qlcnic_mac_vlan_list);
-				cur = kzalloc(temp, GFP_ATOMIC);
-				if (cur == NULL)
-					break;
-				memcpy(cur->mac_addr,
-				       ha->addr, ETH_ALEN);
-				list_add_tail(&cur->list, &adapter->vf_mc_list);
-			}
-		}
-		qlcnic_sriov_vf_schedule_multi(adapter->netdev);
-		return;
-	}
-	__qlcnic_set_multi(netdev, 0);
+
+	if (qlcnic_sriov_vf_check(adapter))
+		qlcnic_sriov_vf_set_multi(netdev);
+	else
+		__qlcnic_set_multi(netdev, 0);
 }
 
 int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 28ebe1b..1a52a78 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1917,8 +1917,6 @@ void __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (!test_and_clear_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
 
-	if (qlcnic_sriov_vf_check(adapter))
-		qlcnic_sriov_cleanup_async_list(&adapter->ahw->sriov->bc);
 	smp_mb();
 	netif_carrier_off(netdev);
 	adapter->ahw->linkup = 0;
@@ -1930,6 +1928,8 @@ void __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 		qlcnic_delete_lb_filters(adapter);
 
 	qlcnic_nic_set_promisc(adapter, QLCNIC_NIU_NON_PROMISC_MODE);
+	if (qlcnic_sriov_vf_check(adapter))
+		qlcnic_sriov_cleanup_async_list(&adapter->ahw->sriov->bc);
 
 	qlcnic_napi_disable(adapter);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 396bd1f..54159bd 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -151,13 +151,14 @@ struct qlcnic_vf_info {
 	struct qlcnic_trans_list	rcv_pend;
 	struct qlcnic_adapter		*adapter;
 	struct qlcnic_vport		*vp;
-	struct mutex			vlan_list_lock;	/* Lock for VLAN list */
+	spinlock_t			vlan_list_lock;	/* Lock for VLAN list */
 };
 
 struct qlcnic_async_work_list {
 	struct list_head	list;
 	struct work_struct	work;
 	void			*ptr;
+	struct qlcnic_cmd_args	*cmd;
 };
 
 struct qlcnic_back_channel {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 4eccc2b..8f9c244 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -39,6 +39,8 @@ static int qlcnic_sriov_channel_cfg_cmd(struct qlcnic_adapter *, u8);
 static void qlcnic_sriov_process_bc_cmd(struct work_struct *);
 static int qlcnic_sriov_vf_shutdown(struct pci_dev *);
 static int qlcnic_sriov_vf_resume(struct qlcnic_adapter *);
+static int qlcnic_sriov_async_issue_cmd(struct qlcnic_adapter *,
+					struct qlcnic_cmd_args *);
 
 static struct qlcnic_hardware_ops qlcnic_sriov_vf_hw_ops = {
 	.read_crb			= qlcnic_83xx_read_crb,
@@ -181,7 +183,7 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 		vf->adapter = adapter;
 		vf->pci_func = qlcnic_sriov_virtid_fn(adapter, i);
 		mutex_init(&vf->send_cmd_lock);
-		mutex_init(&vf->vlan_list_lock);
+		spin_lock_init(&vf->vlan_list_lock);
 		INIT_LIST_HEAD(&vf->rcv_act.wait_list);
 		INIT_LIST_HEAD(&vf->rcv_pend.wait_list);
 		spin_lock_init(&vf->rcv_act.lock);
@@ -1356,7 +1358,7 @@ static int qlcnic_sriov_retry_bc_cmd(struct qlcnic_adapter *adapter,
 	return -EIO;
 }
 
-static int qlcnic_sriov_issue_cmd(struct qlcnic_adapter *adapter,
+static int __qlcnic_sriov_issue_cmd(struct qlcnic_adapter *adapter,
 				  struct qlcnic_cmd_args *cmd)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -1428,6 +1430,16 @@ cleanup_transaction:
 	return rsp;
 }
 
+
+static int qlcnic_sriov_issue_cmd(struct qlcnic_adapter *adapter,
+				  struct qlcnic_cmd_args *cmd)
+{
+	if (cmd->type == QLC_83XX_MBX_CMD_NO_WAIT)
+		return qlcnic_sriov_async_issue_cmd(adapter, cmd);
+	else
+		return __qlcnic_sriov_issue_cmd(adapter, cmd);
+}
+
 static int qlcnic_sriov_channel_cfg_cmd(struct qlcnic_adapter *adapter, u8 cmd_op)
 {
 	struct qlcnic_cmd_args cmd;
@@ -1458,58 +1470,28 @@ out:
 	return ret;
 }
 
-static void qlcnic_vf_add_mc_list(struct net_device *netdev)
+static void qlcnic_vf_add_mc_list(struct net_device *netdev, const u8 *mac)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
-	struct qlcnic_mac_vlan_list *cur;
-	struct list_head *head, tmp_list;
 	struct qlcnic_vf_info *vf;
 	u16 vlan_id;
 	int i;
 
-	static const u8 bcast_addr[ETH_ALEN] = {
-		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
-	};
-
 	vf = &adapter->ahw->sriov->vf_info[0];
-	INIT_LIST_HEAD(&tmp_list);
-	head = &adapter->vf_mc_list;
-	netif_addr_lock_bh(netdev);
-
-	while (!list_empty(head)) {
-		cur = list_entry(head->next, struct qlcnic_mac_vlan_list, list);
-		list_move(&cur->list, &tmp_list);
-	}
-
-	netif_addr_unlock_bh(netdev);
 
-	while (!list_empty(&tmp_list)) {
-		cur = list_entry((&tmp_list)->next,
-				 struct qlcnic_mac_vlan_list, list);
-		if (!qlcnic_sriov_check_any_vlan(vf)) {
-			qlcnic_nic_add_mac(adapter, bcast_addr, 0);
-			qlcnic_nic_add_mac(adapter, cur->mac_addr, 0);
-		} else {
-			mutex_lock(&vf->vlan_list_lock);
-			for (i = 0; i < sriov->num_allowed_vlans; i++) {
-				vlan_id = vf->sriov_vlans[i];
-				if (vlan_id) {
-					qlcnic_nic_add_mac(adapter, bcast_addr,
-							   vlan_id);
-					qlcnic_nic_add_mac(adapter,
-							   cur->mac_addr,
-							   vlan_id);
-				}
-			}
-			mutex_unlock(&vf->vlan_list_lock);
-			if (qlcnic_84xx_check(adapter)) {
-				qlcnic_nic_add_mac(adapter, bcast_addr, 0);
-				qlcnic_nic_add_mac(adapter, cur->mac_addr, 0);
-			}
+	if (!qlcnic_sriov_check_any_vlan(vf)) {
+		qlcnic_nic_add_mac(adapter, mac, 0);
+	} else {
+		spin_lock(&vf->vlan_list_lock);
+		for (i = 0; i < sriov->num_allowed_vlans; i++) {
+			vlan_id = vf->sriov_vlans[i];
+			if (vlan_id)
+				qlcnic_nic_add_mac(adapter, mac, vlan_id);
 		}
-		list_del(&cur->list);
-		kfree(cur);
+		spin_unlock(&vf->vlan_list_lock);
+		if (qlcnic_84xx_check(adapter))
+			qlcnic_nic_add_mac(adapter, mac, 0);
 	}
 }
 
@@ -1518,6 +1500,7 @@ void qlcnic_sriov_cleanup_async_list(struct qlcnic_back_channel *bc)
 	struct list_head *head = &bc->async_list;
 	struct qlcnic_async_work_list *entry;
 
+	flush_workqueue(bc->bc_async_wq);
 	while (!list_empty(head)) {
 		entry = list_entry(head->next, struct qlcnic_async_work_list,
 				   list);
@@ -1527,10 +1510,14 @@ void qlcnic_sriov_cleanup_async_list(struct qlcnic_back_channel *bc)
 	}
 }
 
-static void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
+void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	static const u8 bcast_addr[ETH_ALEN] = {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
+	struct netdev_hw_addr *ha;
 	u32 mode = VPORT_MISS_MODE_DROP;
 
 	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
@@ -1542,23 +1529,28 @@ static void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
 	} else if ((netdev->flags & IFF_ALLMULTI) ||
 		   (netdev_mc_count(netdev) > ahw->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
+	} else {
+		qlcnic_vf_add_mc_list(netdev, bcast_addr);
+		if (!netdev_mc_empty(netdev)) {
+			netdev_for_each_mc_addr(ha, netdev)
+				qlcnic_vf_add_mc_list(netdev, ha->addr);
+		}
 	}
 
-	if (qlcnic_sriov_vf_check(adapter))
-		qlcnic_vf_add_mc_list(netdev);
-
 	qlcnic_nic_set_promisc(adapter, mode);
 }
 
-static void qlcnic_sriov_handle_async_multi(struct work_struct *work)
+static void qlcnic_sriov_handle_async_issue_cmd(struct work_struct *work)
 {
 	struct qlcnic_async_work_list *entry;
-	struct net_device *netdev;
+	struct qlcnic_cmd_args *cmd;
+	struct qlcnic_adapter *adapter;
 
 	entry = container_of(work, struct qlcnic_async_work_list, work);
-	netdev = (struct net_device *)entry->ptr;
+	adapter = (struct qlcnic_adapter *)entry->ptr;
 
-	qlcnic_sriov_vf_set_multi(netdev);
+	cmd = entry->cmd;
+	__qlcnic_sriov_issue_cmd(adapter, cmd);
 	return;
 }
 
@@ -1588,8 +1580,9 @@ qlcnic_sriov_get_free_node_async_work(struct qlcnic_back_channel *bc)
 	return entry;
 }
 
-static void qlcnic_sriov_schedule_bc_async_work(struct qlcnic_back_channel *bc,
-						work_func_t func, void *data)
+static void qlcnic_sriov_schedule_async_cmd(struct qlcnic_back_channel *bc,
+					    work_func_t func, void *data,
+					    struct qlcnic_cmd_args *cmd)
 {
 	struct qlcnic_async_work_list *entry = NULL;
 
@@ -1598,21 +1591,23 @@ static void qlcnic_sriov_schedule_bc_async_work(struct qlcnic_back_channel *bc,
 		return;
 
 	entry->ptr = data;
+	entry->cmd = cmd;
 	INIT_WORK(&entry->work, func);
 	queue_work(bc->bc_async_wq, &entry->work);
 }
 
-void qlcnic_sriov_vf_schedule_multi(struct net_device *netdev)
+static int qlcnic_sriov_async_issue_cmd(struct qlcnic_adapter *adapter,
+					struct qlcnic_cmd_args *cmd)
 {
 
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_back_channel *bc = &adapter->ahw->sriov->bc;
 
 	if (adapter->need_fw_reset)
-		return;
+		return 0;
 
-	qlcnic_sriov_schedule_bc_async_work(bc, qlcnic_sriov_handle_async_multi,
-					    netdev);
+	qlcnic_sriov_schedule_async_cmd(bc, qlcnic_sriov_handle_async_issue_cmd,
+					adapter, cmd);
+	return 0;
 }
 
 static int qlcnic_sriov_vf_reinit_driver(struct qlcnic_adapter *adapter)
@@ -1890,7 +1885,7 @@ static int qlcnic_sriov_check_vlan_id(struct qlcnic_sriov *sriov,
 	if (!vf->sriov_vlans)
 		return err;
 
-	mutex_lock(&vf->vlan_list_lock);
+	spin_lock_bh(&vf->vlan_list_lock);
 
 	for (i = 0; i < sriov->num_allowed_vlans; i++) {
 		if (vf->sriov_vlans[i] == vlan_id) {
@@ -1899,7 +1894,7 @@ static int qlcnic_sriov_check_vlan_id(struct qlcnic_sriov *sriov,
 		}
 	}
 
-	mutex_unlock(&vf->vlan_list_lock);
+	spin_unlock_bh(&vf->vlan_list_lock);
 	return err;
 }
 
@@ -1908,12 +1903,12 @@ static int qlcnic_sriov_validate_num_vlans(struct qlcnic_sriov *sriov,
 {
 	int err = 0;
 
-	mutex_lock(&vf->vlan_list_lock);
+	spin_lock_bh(&vf->vlan_list_lock);
 
 	if (vf->num_vlan >= sriov->num_allowed_vlans)
 		err = -EINVAL;
 
-	mutex_unlock(&vf->vlan_list_lock);
+	spin_unlock_bh(&vf->vlan_list_lock);
 	return err;
 }
 
@@ -1966,7 +1961,7 @@ static void qlcnic_sriov_vlan_operation(struct qlcnic_vf_info *vf, u16 vlan_id,
 	if (!vf->sriov_vlans)
 		return;
 
-	mutex_lock(&vf->vlan_list_lock);
+	spin_lock_bh(&vf->vlan_list_lock);
 
 	switch (opcode) {
 	case QLC_VLAN_ADD:
@@ -1979,7 +1974,7 @@ static void qlcnic_sriov_vlan_operation(struct qlcnic_vf_info *vf, u16 vlan_id,
 		netdev_err(adapter->netdev, "Invalid VLAN operation\n");
 	}
 
-	mutex_unlock(&vf->vlan_list_lock);
+	spin_unlock_bh(&vf->vlan_list_lock);
 	return;
 }
 
@@ -1987,6 +1982,7 @@ int qlcnic_sriov_cfg_vf_guest_vlan(struct qlcnic_adapter *adapter,
 				   u16 vid, u8 enable)
 {
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
+	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_vf_info *vf;
 	struct qlcnic_cmd_args cmd;
 	int ret;
@@ -2012,14 +2008,18 @@ int qlcnic_sriov_cfg_vf_guest_vlan(struct qlcnic_adapter *adapter,
 		dev_err(&adapter->pdev->dev,
 			"Failed to configure guest VLAN, err=%d\n", ret);
 	} else {
+		netif_addr_lock_bh(netdev);
 		qlcnic_free_mac_list(adapter);
+		netif_addr_unlock_bh(netdev);
 
 		if (enable)
 			qlcnic_sriov_vlan_operation(vf, vid, QLC_VLAN_ADD);
 		else
 			qlcnic_sriov_vlan_operation(vf, vid, QLC_VLAN_DELETE);
 
-		qlcnic_set_multi(adapter->netdev);
+		netif_addr_lock_bh(netdev);
+		qlcnic_set_multi(netdev);
+		netif_addr_unlock_bh(netdev);
 	}
 
 	qlcnic_free_mbx_args(&cmd);
@@ -2150,11 +2150,11 @@ bool qlcnic_sriov_check_any_vlan(struct qlcnic_vf_info *vf)
 {
 	bool err = false;
 
-	mutex_lock(&vf->vlan_list_lock);
+	spin_lock_bh(&vf->vlan_list_lock);
 
 	if (vf->num_vlan)
 		err = true;
 
-	mutex_unlock(&vf->vlan_list_lock);
+	spin_unlock_bh(&vf->vlan_list_lock);
 	return err;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index df40908..199ab7c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -784,7 +784,7 @@ static int qlcnic_sriov_cfg_vf_def_mac(struct qlcnic_adapter *adapter,
 				       struct qlcnic_vf_info *vf,
 				       u16 vlan, u8 op)
 {
-	struct qlcnic_cmd_args cmd;
+	struct qlcnic_cmd_args *cmd;
 	struct qlcnic_macvlan_mbx mv;
 	struct qlcnic_vport *vp;
 	u8 *addr;
@@ -794,21 +794,27 @@ static int qlcnic_sriov_cfg_vf_def_mac(struct qlcnic_adapter *adapter,
 
 	vp = vf->vp;
 
-	if (qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_MAC_VLAN))
+	cmd = kzalloc(sizeof(*cmd), GFP_ATOMIC);
+	if (!cmd)
 		return -ENOMEM;
 
+	err = qlcnic_alloc_mbx_args(cmd, adapter, QLCNIC_CMD_CONFIG_MAC_VLAN);
+	if (err)
+		goto free_cmd;
+
+	cmd->type = QLC_83XX_MBX_CMD_NO_WAIT;
 	vpid = qlcnic_sriov_pf_get_vport_handle(adapter, vf->pci_func);
 	if (vpid < 0) {
 		err = -EINVAL;
-		goto out;
+		goto free_args;
 	}
 
 	if (vlan)
 		op = ((op == QLCNIC_MAC_ADD || op == QLCNIC_MAC_VLAN_ADD) ?
 		      QLCNIC_MAC_VLAN_ADD : QLCNIC_MAC_VLAN_DEL);
 
-	cmd.req.arg[1] = op | (1 << 8) | (3 << 6);
-	cmd.req.arg[1] |= ((vpid & 0xffff) << 16) | BIT_31;
+	cmd->req.arg[1] = op | (1 << 8) | (3 << 6);
+	cmd->req.arg[1] |= ((vpid & 0xffff) << 16) | BIT_31;
 
 	addr = vp->mac;
 	mv.vlan = vlan;
@@ -818,18 +824,18 @@ static int qlcnic_sriov_cfg_vf_def_mac(struct qlcnic_adapter *adapter,
 	mv.mac_addr3 = addr[3];
 	mv.mac_addr4 = addr[4];
 	mv.mac_addr5 = addr[5];
-	buf = &cmd.req.arg[2];
+	buf = &cmd->req.arg[2];
 	memcpy(buf, &mv, sizeof(struct qlcnic_macvlan_mbx));
 
-	err = qlcnic_issue_cmd(adapter, &cmd);
+	err = qlcnic_issue_cmd(adapter, cmd);
 
-	if (err)
-		dev_err(&adapter->pdev->dev,
-			"MAC-VLAN %s to CAM failed, err=%d.\n",
-			((op == 1) ? "add " : "delete "), err);
+	if (!err)
+		return err;
 
-out:
-	qlcnic_free_mbx_args(&cmd);
+free_args:
+	qlcnic_free_mbx_args(cmd);
+free_cmd:
+	kfree(cmd);
 	return err;
 }
 
@@ -851,7 +857,7 @@ static void qlcnic_83xx_cfg_default_mac_vlan(struct qlcnic_adapter *adapter,
 
 	sriov = adapter->ahw->sriov;
 
-	mutex_lock(&vf->vlan_list_lock);
+	spin_lock_bh(&vf->vlan_list_lock);
 	if (vf->num_vlan) {
 		for (i = 0; i < sriov->num_allowed_vlans; i++) {
 			vlan = vf->sriov_vlans[i];
@@ -860,7 +866,7 @@ static void qlcnic_83xx_cfg_default_mac_vlan(struct qlcnic_adapter *adapter,
 							    opcode);
 		}
 	}
-	mutex_unlock(&vf->vlan_list_lock);
+	spin_unlock_bh(&vf->vlan_list_lock);
 
 	if (vf->vp->vlan_mode != QLC_PVID_MODE) {
 		if (qlcnic_83xx_pf_check(adapter) &&
-- 
1.6.3.3
