From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/3] bnx2x, cnic: Disable iSCSI if DCBX
 negotiation is successful
Date: Thu, 31 Mar 2011 14:45:33 -0800
Message-ID: <1301611533-9725-3-git-send-email-mchan@broadcom.com>
References: <1301611533-9725-1-git-send-email-mchan@broadcom.com>
 <1301611533-9725-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2944 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753940Ab1CaXjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 19:39:46 -0400
In-Reply-To: <1301611533-9725-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

With current bnx2x firmware 6.2.9, iSCSI is not supported in DCB
network, so we need to disable it.  Add cnic command to disconnect
iSCSI connections and prevent future connections when DCBX negotiation
succeeds.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_dcb.c  |   22 ++++++++++++++
 drivers/net/bnx2x/bnx2x_dcb.h  |    8 ++++-
 drivers/net/bnx2x/bnx2x_main.c |    5 +++
 drivers/net/cnic.c             |   64 ++++++++++++++++++++++++++++------------
 drivers/net/cnic.h             |    1 +
 drivers/net/cnic_if.h          |    6 ++-
 6 files changed, 83 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index 9a24d79..1214907 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -571,6 +571,28 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 {
 	switch (state) {
 	case BNX2X_DCBX_STATE_NEG_RECEIVED:
+#ifdef BCM_CNIC
+		if (bp->state != BNX2X_STATE_OPENING_WAIT4_LOAD) {
+			struct cnic_ops *c_ops;
+			struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+			bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
+			cp->drv_state |= CNIC_DRV_STATE_NO_ISCSI_OOO;
+			cp->drv_state |= CNIC_DRV_STATE_NO_ISCSI;
+
+			rcu_read_lock();
+			c_ops = rcu_dereference(bp->cnic_ops);
+			if (c_ops) {
+				bnx2x_cnic_notify(bp, CNIC_CTL_STOP_ISCSI_CMD);
+				rcu_read_unlock();
+				return;
+			}
+			rcu_read_unlock();
+		}
+
+		/* fall through if no CNIC initialized  */
+	case BNX2X_DCBX_STATE_ISCSI_STOPPED:
+#endif
+
 		{
 			DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_NEG_RECEIVED\n");
 #ifdef BCM_DCBNL
diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
index 71b8eda..1e14775 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -183,9 +183,13 @@ void bnx2x_dcbx_set_state(struct bnx2x *bp, bool dcb_on, u32 dcbx_enabled);
 
 enum {
 	BNX2X_DCBX_STATE_NEG_RECEIVED = 0x1,
-	BNX2X_DCBX_STATE_TX_PAUSED = 0x2,
-	BNX2X_DCBX_STATE_TX_RELEASED = 0x4
+#ifdef BCM_CNIC
+	BNX2X_DCBX_STATE_ISCSI_STOPPED,
+#endif
+	BNX2X_DCBX_STATE_TX_PAUSED,
+	BNX2X_DCBX_STATE_TX_RELEASED
 };
+
 void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state);
 
 /* DCB netlink */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 32e64cc..f3cf889 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -10342,6 +10342,11 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 		break;
 	}
 
+	case DRV_CTL_ISCSI_STOPPED_CMD: {
+		bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_ISCSI_STOPPED);
+		break;
+	}
+
 	default:
 		BNX2X_ERR("unknown command %x\n", ctl->cmd);
 		rc = -EINVAL;
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 8cca60e..5dfbff0 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2966,31 +2966,36 @@ static int cnic_service_bnx2x(void *data, void *status_blk)
 	return 0;
 }
 
-static void cnic_ulp_stop(struct cnic_dev *dev)
+static void cnic_ulp_stop_one(struct cnic_local *cp, int if_type)
 {
-	struct cnic_local *cp = dev->cnic_priv;
-	int if_type;
-
-	cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+	struct cnic_ulp_ops *ulp_ops;
 
-	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
-		struct cnic_ulp_ops *ulp_ops;
+	if (if_type == CNIC_ULP_ISCSI)
+		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
 
-		mutex_lock(&cnic_lock);
-		ulp_ops = rcu_dereference_protected(cp->ulp_ops[if_type],
-						    lockdep_is_held(&cnic_lock));
-		if (!ulp_ops) {
-			mutex_unlock(&cnic_lock);
-			continue;
-		}
-		set_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
+	mutex_lock(&cnic_lock);
+	ulp_ops = rcu_dereference_protected(cp->ulp_ops[if_type],
+					    lockdep_is_held(&cnic_lock));
+	if (!ulp_ops) {
 		mutex_unlock(&cnic_lock);
+		return;
+	}
+	set_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
+	mutex_unlock(&cnic_lock);
 
-		if (test_and_clear_bit(ULP_F_START, &cp->ulp_flags[if_type]))
-			ulp_ops->cnic_stop(cp->ulp_handle[if_type]);
+	if (test_and_clear_bit(ULP_F_START, &cp->ulp_flags[if_type]))
+		ulp_ops->cnic_stop(cp->ulp_handle[if_type]);
 
-		clear_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
-	}
+	clear_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
+}
+
+static void cnic_ulp_stop(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int if_type;
+
+	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++)
+		cnic_ulp_stop_one(cp, if_type);
 }
 
 static void cnic_ulp_start(struct cnic_dev *dev)
@@ -3039,6 +3044,12 @@ static int cnic_ctl(void *data, struct cnic_ctl_info *info)
 
 		cnic_put(dev);
 		break;
+	case CNIC_CTL_STOP_ISCSI_CMD: {
+		struct cnic_local *cp = dev->cnic_priv;
+		set_bit(CNIC_LCL_FL_STOP_ISCSI, &cp->cnic_local_flags);
+		queue_delayed_work(cnic_wq, &cp->delete_task, 0);
+		break;
+	}
 	case CNIC_CTL_COMPLETION_CMD: {
 		u32 cid = BNX2X_SW_CID(info->data.comp.cid);
 		u32 l5_cid;
@@ -3562,8 +3573,12 @@ static void cnic_init_csk_state(struct cnic_sock *csk)
 
 static int cnic_cm_connect(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
 {
+	struct cnic_local *cp = csk->dev->cnic_priv;
 	int err = 0;
 
+	if (cp->ethdev->drv_state & CNIC_DRV_STATE_NO_ISCSI)
+		return -EOPNOTSUPP;
+
 	if (!cnic_in_use(csk))
 		return -EINVAL;
 
@@ -3965,6 +3980,17 @@ static void cnic_delete_task(struct work_struct *work)
 	cp = container_of(work, struct cnic_local, delete_task.work);
 	dev = cp->dev;
 
+	if (test_and_clear_bit(CNIC_LCL_FL_STOP_ISCSI, &cp->cnic_local_flags)) {
+		struct drv_ctl_info info;
+
+		rtnl_lock();
+		cnic_ulp_stop_one(cp, CNIC_ULP_ISCSI);
+		rtnl_unlock();
+
+		info.cmd = DRV_CTL_ISCSI_STOPPED_CMD;
+		cp->ethdev->drv_ctl(dev->netdev, &info);
+	}
+
 	for (i = 0; i < cp->max_cid_space; i++) {
 		struct cnic_context *ctx = &cp->ctx_tbl[i];
 
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 4456260..3367a6d 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -226,6 +226,7 @@ struct cnic_local {
 #define	CNIC_LCL_FL_KWQ_INIT		0x0
 #define	CNIC_LCL_FL_L2_WAIT		0x1
 #define	CNIC_LCL_FL_RINGS_INITED	0x2
+#define	CNIC_LCL_FL_STOP_ISCSI		0x4
 
 	struct cnic_dev *dev;
 
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index e01b49e..fdd8e46 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.2.13"
-#define CNIC_MODULE_RELDATE	"Jan 31, 2011"
+#define CNIC_MODULE_VERSION	"2.2.14"
+#define CNIC_MODULE_RELDATE	"Mar 30, 2011"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -85,6 +85,7 @@ struct kcqe {
 #define CNIC_CTL_STOP_CMD		1
 #define CNIC_CTL_START_CMD		2
 #define CNIC_CTL_COMPLETION_CMD		3
+#define CNIC_CTL_STOP_ISCSI_CMD		4
 
 #define DRV_CTL_IO_WR_CMD		0x101
 #define DRV_CTL_IO_RD_CMD		0x102
@@ -94,6 +95,7 @@ struct kcqe {
 #define DRV_CTL_START_L2_CMD		0x106
 #define DRV_CTL_STOP_L2_CMD		0x107
 #define DRV_CTL_RET_L2_SPQ_CREDIT_CMD	0x10c
+#define DRV_CTL_ISCSI_STOPPED_CMD	0x10d
 
 struct cnic_ctl_completion {
 	u32	cid;
-- 
1.6.4.GIT


