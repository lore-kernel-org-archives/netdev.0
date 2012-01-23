From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 1/6] bnx2x: credit-leakage fixup on vlan_mac_del_all
Date: Mon, 23 Jan 2012 12:31:51 -0500
Message-ID: <1327339916-19138-2-git-send-email-yuvalmin@broadcom.com>
References: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3038 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083Ab2AWKhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 05:37:47 -0500
In-Reply-To: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon insertion of elements into the execution queue, it is validated
that there are enough credits to support additional vlan-macs,
and the credits are consumed. However, when removing a pending
command in `bnx2x_vland_mac_del_all' the consumed credits are not
released, which might cause leakage and eventually the inability to
add new vlan-macs in certain scenarios.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |   44 +++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h |   11 ++++++
 2 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 5ac6160..cb6339c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -50,6 +50,7 @@ static inline void bnx2x_exe_queue_init(struct bnx2x *bp,
 					int exe_len,
 					union bnx2x_qable_obj *owner,
 					exe_q_validate validate,
+					exe_q_remove remove,
 					exe_q_optimize optimize,
 					exe_q_execute exec,
 					exe_q_get get)
@@ -66,6 +67,7 @@ static inline void bnx2x_exe_queue_init(struct bnx2x *bp,
 
 	/* Owner specific callbacks */
 	o->validate      = validate;
+	o->remove        = remove;
 	o->optimize      = optimize;
 	o->execute       = exec;
 	o->get           = get;
@@ -1340,6 +1342,35 @@ static int bnx2x_validate_vlan_mac(struct bnx2x *bp,
 	}
 }
 
+static int bnx2x_remove_vlan_mac(struct bnx2x *bp,
+				  union bnx2x_qable_obj *qo,
+				  struct bnx2x_exeq_elem *elem)
+{
+	int rc = 0;
+
+	/* If consumption wasn't required, nothing to do */
+	if (test_bit(BNX2X_DONT_CONSUME_CAM_CREDIT,
+		     &elem->cmd_data.vlan_mac.vlan_mac_flags))
+		return 0;
+
+	switch (elem->cmd_data.vlan_mac.cmd) {
+	case BNX2X_VLAN_MAC_ADD:
+	case BNX2X_VLAN_MAC_MOVE:
+		rc = qo->vlan_mac.put_credit(&qo->vlan_mac);
+		break;
+	case BNX2X_VLAN_MAC_DEL:
+		rc = qo->vlan_mac.get_credit(&qo->vlan_mac);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (rc != true)
+		return -EINVAL;
+
+	return 0;
+}
+
 /**
  * bnx2x_wait_vlan_mac - passivly wait for 5 seconds until all work completes.
  *
@@ -1801,8 +1832,14 @@ static int bnx2x_vlan_mac_del_all(struct bnx2x *bp,
 
 	list_for_each_entry_safe(exeq_pos, exeq_pos_n, &exeq->exe_queue, link) {
 		if (exeq_pos->cmd_data.vlan_mac.vlan_mac_flags ==
-		    *vlan_mac_flags)
+		    *vlan_mac_flags) {
+			rc = exeq->remove(bp, exeq->owner, exeq_pos);
+			if (rc) {
+				BNX2X_ERR("Failed to remove command\n");
+				return rc;
+			}
 			list_del(&exeq_pos->link);
+		}
 	}
 
 	spin_unlock_bh(&exeq->lock);
@@ -1908,6 +1945,7 @@ void bnx2x_init_mac_obj(struct bnx2x *bp,
 		bnx2x_exe_queue_init(bp,
 				     &mac_obj->exe_queue, 1, qable_obj,
 				     bnx2x_validate_vlan_mac,
+				     bnx2x_remove_vlan_mac,
 				     bnx2x_optimize_vlan_mac,
 				     bnx2x_execute_vlan_mac,
 				     bnx2x_exeq_get_mac);
@@ -1924,6 +1962,7 @@ void bnx2x_init_mac_obj(struct bnx2x *bp,
 		bnx2x_exe_queue_init(bp,
 				     &mac_obj->exe_queue, CLASSIFY_RULES_COUNT,
 				     qable_obj, bnx2x_validate_vlan_mac,
+				     bnx2x_remove_vlan_mac,
 				     bnx2x_optimize_vlan_mac,
 				     bnx2x_execute_vlan_mac,
 				     bnx2x_exeq_get_mac);
@@ -1963,6 +2002,7 @@ void bnx2x_init_vlan_obj(struct bnx2x *bp,
 		bnx2x_exe_queue_init(bp,
 				     &vlan_obj->exe_queue, CLASSIFY_RULES_COUNT,
 				     qable_obj, bnx2x_validate_vlan_mac,
+				     bnx2x_remove_vlan_mac,
 				     bnx2x_optimize_vlan_mac,
 				     bnx2x_execute_vlan_mac,
 				     bnx2x_exeq_get_vlan);
@@ -2009,6 +2049,7 @@ void bnx2x_init_vlan_mac_obj(struct bnx2x *bp,
 		bnx2x_exe_queue_init(bp,
 				     &vlan_mac_obj->exe_queue, 1, qable_obj,
 				     bnx2x_validate_vlan_mac,
+				     bnx2x_remove_vlan_mac,
 				     bnx2x_optimize_vlan_mac,
 				     bnx2x_execute_vlan_mac,
 				     bnx2x_exeq_get_vlan_mac);
@@ -2025,6 +2066,7 @@ void bnx2x_init_vlan_mac_obj(struct bnx2x *bp,
 				     &vlan_mac_obj->exe_queue,
 				     CLASSIFY_RULES_COUNT,
 				     qable_obj, bnx2x_validate_vlan_mac,
+				     bnx2x_remove_vlan_mac,
 				     bnx2x_optimize_vlan_mac,
 				     bnx2x_execute_vlan_mac,
 				     bnx2x_exeq_get_vlan_mac);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 992308f..66da39f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -161,6 +161,10 @@ typedef int (*exe_q_validate)(struct bnx2x *bp,
 			      union bnx2x_qable_obj *o,
 			      struct bnx2x_exeq_elem *elem);
 
+typedef int (*exe_q_remove)(struct bnx2x *bp,
+			    union bnx2x_qable_obj *o,
+			    struct bnx2x_exeq_elem *elem);
+
 /**
  * @return positive is entry was optimized, 0 - if not, negative
  *         in case of an error.
@@ -203,11 +207,18 @@ struct bnx2x_exe_queue_obj {
 	 */
 	exe_q_validate		validate;
 
+	/**
+	 * Called before removing pending commands, cleaning allocated
+	 * resources (e.g., credits from validate)
+	 */
+	 exe_q_remove		remove;
 
 	/**
 	 * This will try to cancel the current pending commands list
 	 * considering the new command.
 	 *
+	 * Returns the number of optimized commands or a negative error code
+	 *
 	 * Must run under exe_queue->lock
 	 */
 	exe_q_optimize		optimize;
-- 
1.7.1
