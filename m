From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/3] qlcnic: fix data structure corruption in async mbx command handling
Date: Wed, 3 Aug 2016 04:02:02 -0400
Message-ID: <1470211324-23430-2-git-send-email-manish.chopra@qlogic.com>
References: <1470211324-23430-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:38814 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757236AbcHCIot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 04:44:49 -0400
In-Reply-To: <1470211324-23430-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a data structure corruption bug in the SRIOV VF mailbox
handler code. While handling mailbox commands from the atomic context,
driver is accessing and updating qlcnic_async_work_list_struct entry fields
in the async work list. These fields could be concurrently accessed by the
work function resulting in data corruption.

This patch restructures async mbx command handling by using a separate
async command list instead of using a list of work_struct structures.
A single work_struct is used to schedule and handle the async commands
with proper locking mechanism.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    9 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   95 +++++++++++--------
 2 files changed, 60 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 017d8c2..24061b9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -156,10 +156,8 @@ struct qlcnic_vf_info {
 	spinlock_t			vlan_list_lock;	/* Lock for VLAN list */
 };
 
-struct qlcnic_async_work_list {
+struct qlcnic_async_cmd {
 	struct list_head	list;
-	struct work_struct	work;
-	void			*ptr;
 	struct qlcnic_cmd_args	*cmd;
 };
 
@@ -168,7 +166,10 @@ struct qlcnic_back_channel {
 	struct workqueue_struct *bc_trans_wq;
 	struct workqueue_struct *bc_async_wq;
 	struct workqueue_struct *bc_flr_wq;
-	struct list_head	async_list;
+	struct qlcnic_adapter	*adapter;
+	struct list_head	async_cmd_list;
+	struct work_struct	vf_async_work;
+	spinlock_t		queue_lock; /* async_cmd_list queue lock */
 };
 
 struct qlcnic_sriov {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 7327b72..d710705 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -29,6 +29,7 @@
 #define QLC_83XX_VF_RESET_FAIL_THRESH	8
 #define QLC_BC_CMD_MAX_RETRY_CNT	5
 
+static void qlcnic_sriov_handle_async_issue_cmd(struct work_struct *work);
 static void qlcnic_sriov_vf_free_mac_list(struct qlcnic_adapter *);
 static int qlcnic_sriov_alloc_bc_mbx_args(struct qlcnic_cmd_args *, u32);
 static void qlcnic_sriov_vf_poll_dev_state(struct work_struct *);
@@ -177,7 +178,10 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 	}
 
 	bc->bc_async_wq =  wq;
-	INIT_LIST_HEAD(&bc->async_list);
+	INIT_LIST_HEAD(&bc->async_cmd_list);
+	INIT_WORK(&bc->vf_async_work, qlcnic_sriov_handle_async_issue_cmd);
+	spin_lock_init(&bc->queue_lock);
+	bc->adapter = adapter;
 
 	for (i = 0; i < num_vfs; i++) {
 		vf = &sriov->vf_info[i];
@@ -1517,17 +1521,21 @@ static void qlcnic_vf_add_mc_list(struct net_device *netdev, const u8 *mac,
 
 void qlcnic_sriov_cleanup_async_list(struct qlcnic_back_channel *bc)
 {
-	struct list_head *head = &bc->async_list;
-	struct qlcnic_async_work_list *entry;
+	struct list_head *head = &bc->async_cmd_list;
+	struct qlcnic_async_cmd *entry;
 
 	flush_workqueue(bc->bc_async_wq);
+	cancel_work_sync(&bc->vf_async_work);
+
+	spin_lock(&bc->queue_lock);
 	while (!list_empty(head)) {
-		entry = list_entry(head->next, struct qlcnic_async_work_list,
+		entry = list_entry(head->next, struct qlcnic_async_cmd,
 				   list);
-		cancel_work_sync(&entry->work);
 		list_del(&entry->list);
+		kfree(entry->cmd);
 		kfree(entry);
 	}
+	spin_unlock(&bc->queue_lock);
 }
 
 void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
@@ -1587,57 +1595,64 @@ void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
 
 static void qlcnic_sriov_handle_async_issue_cmd(struct work_struct *work)
 {
-	struct qlcnic_async_work_list *entry;
-	struct qlcnic_adapter *adapter;
+	struct qlcnic_async_cmd *entry, *tmp;
+	struct qlcnic_back_channel *bc;
 	struct qlcnic_cmd_args *cmd;
+	struct list_head *head;
+	LIST_HEAD(del_list);
+
+	bc = container_of(work, struct qlcnic_back_channel, vf_async_work);
+	head = &bc->async_cmd_list;
+
+	spin_lock(&bc->queue_lock);
+	list_splice_init(head, &del_list);
+	spin_unlock(&bc->queue_lock);
+
+	list_for_each_entry_safe(entry, tmp, &del_list, list) {
+		list_del(&entry->list);
+		cmd = entry->cmd;
+		__qlcnic_sriov_issue_cmd(bc->adapter, cmd);
+		kfree(entry);
+	}
+
+	if (!list_empty(head))
+		queue_work(bc->bc_async_wq, &bc->vf_async_work);
 
-	entry = container_of(work, struct qlcnic_async_work_list, work);
-	adapter = entry->ptr;
-	cmd = entry->cmd;
-	__qlcnic_sriov_issue_cmd(adapter, cmd);
 	return;
 }
 
-static struct qlcnic_async_work_list *
-qlcnic_sriov_get_free_node_async_work(struct qlcnic_back_channel *bc)
+static struct qlcnic_async_cmd *
+qlcnic_sriov_alloc_async_cmd(struct qlcnic_back_channel *bc,
+			     struct qlcnic_cmd_args *cmd)
 {
-	struct list_head *node;
-	struct qlcnic_async_work_list *entry = NULL;
-	u8 empty = 0;
+	struct qlcnic_async_cmd *entry = NULL;
 
-	list_for_each(node, &bc->async_list) {
-		entry = list_entry(node, struct qlcnic_async_work_list, list);
-		if (!work_pending(&entry->work)) {
-			empty = 1;
-			break;
-		}
-	}
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
+	if (!entry)
+		return NULL;
 
-	if (!empty) {
-		entry = kzalloc(sizeof(struct qlcnic_async_work_list),
-				GFP_ATOMIC);
-		if (entry == NULL)
-			return NULL;
-		list_add_tail(&entry->list, &bc->async_list);
-	}
+	entry->cmd = cmd;
+
+	spin_lock(&bc->queue_lock);
+	list_add_tail(&entry->list, &bc->async_cmd_list);
+	spin_unlock(&bc->queue_lock);
 
 	return entry;
 }
 
 static void qlcnic_sriov_schedule_async_cmd(struct qlcnic_back_channel *bc,
-					    work_func_t func, void *data,
 					    struct qlcnic_cmd_args *cmd)
 {
-	struct qlcnic_async_work_list *entry = NULL;
+	struct qlcnic_async_cmd *entry = NULL;
 
-	entry = qlcnic_sriov_get_free_node_async_work(bc);
-	if (!entry)
+	entry = qlcnic_sriov_alloc_async_cmd(bc, cmd);
+	if (!entry) {
+		qlcnic_free_mbx_args(cmd);
+		kfree(cmd);
 		return;
+	}
 
-	entry->ptr = data;
-	entry->cmd = cmd;
-	INIT_WORK(&entry->work, func);
-	queue_work(bc->bc_async_wq, &entry->work);
+	queue_work(bc->bc_async_wq, &bc->vf_async_work);
 }
 
 static int qlcnic_sriov_async_issue_cmd(struct qlcnic_adapter *adapter,
@@ -1649,8 +1664,8 @@ static int qlcnic_sriov_async_issue_cmd(struct qlcnic_adapter *adapter,
 	if (adapter->need_fw_reset)
 		return -EIO;
 
-	qlcnic_sriov_schedule_async_cmd(bc, qlcnic_sriov_handle_async_issue_cmd,
-					adapter, cmd);
+	qlcnic_sriov_schedule_async_cmd(bc, cmd);
+
 	return 0;
 }
 
-- 
1.5.6
