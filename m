From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4 net-next] cnic: Add VLAN ID as a parameter during
 netevent upcall
Date: Wed, 20 Jul 2011 17:55:24 -0700
Message-ID: <1311209725-10414-3-git-send-email-mchan@broadcom.com>
References: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
 <1311209725-10414-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2460 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab1GUBre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 21:47:34 -0400
In-Reply-To: <1311209725-10414-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2fc driver needs to handle netdev events on VLAN devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
---
 drivers/net/cnic.c                |   50 +++++++++++++++++++++++++-----------
 drivers/net/cnic_if.h             |    6 ++--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c |    8 +++++-
 drivers/scsi/bnx2i/bnx2i_hwi.c    |    8 +++++-
 4 files changed, 52 insertions(+), 20 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 9be0c26..94a2e54 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -5334,6 +5334,27 @@ static struct cnic_dev *is_cnic_dev(struct net_device *dev)
 	return cdev;
 }
 
+static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
+			      u16 vlan_id)
+{
+	int if_type;
+
+	rcu_read_lock();
+	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
+		struct cnic_ulp_ops *ulp_ops;
+		void *ctx;
+
+		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
+		if (!ulp_ops || !ulp_ops->indicate_netevent)
+			continue;
+
+		ctx = cp->ulp_handle[if_type];
+
+		ulp_ops->indicate_netevent(ctx, event, vlan_id);
+	}
+	rcu_read_unlock();
+}
+
 /**
  * netdev event handler
  */
@@ -5342,7 +5363,6 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *netdev = ptr;
 	struct cnic_dev *dev;
-	int if_type;
 	int new_dev = 0;
 
 	dev = cnic_from_netdev(netdev);
@@ -5372,20 +5392,7 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 				cnic_ulp_start(dev);
 		}
 
-		rcu_read_lock();
-		for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
-			struct cnic_ulp_ops *ulp_ops;
-			void *ctx;
-
-			ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
-			if (!ulp_ops || !ulp_ops->indicate_netevent)
-				continue;
-
-			ctx = cp->ulp_handle[if_type];
-
-			ulp_ops->indicate_netevent(ctx, event);
-		}
-		rcu_read_unlock();
+		cnic_rcv_netevent(cp, event, 0);
 
 		if (event == NETDEV_GOING_DOWN) {
 			cnic_ulp_stop(dev);
@@ -5401,6 +5408,19 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 			goto done;
 		}
 		cnic_put(dev);
+	} else {
+		struct net_device *realdev;
+		u16 vid;
+
+		vid = cnic_get_vlan(netdev, &realdev);
+		if (realdev) {
+			dev = cnic_from_netdev(realdev);
+			if (dev) {
+				vid |= VLAN_TAG_PRESENT;
+				cnic_rcv_netevent(dev->cnic_priv, event, vid);
+				cnic_put(dev);
+			}
+		}
 	}
 done:
 	return NOTIFY_DONE;
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 642b9d5..fd54a6a 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.5.6"
-#define CNIC_MODULE_RELDATE	"July 12, 2011"
+#define CNIC_MODULE_VERSION	"2.5.7"
+#define CNIC_MODULE_RELDATE	"July 20, 2011"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -313,7 +313,7 @@ struct cnic_ulp_ops {
 	void (*cnic_stop)(void *ulp_ctx);
 	void (*indicate_kcqes)(void *ulp_ctx, struct kcqe *cqes[],
 				u32 num_cqes);
-	void (*indicate_netevent)(void *ulp_ctx, unsigned long event);
+	void (*indicate_netevent)(void *ulp_ctx, unsigned long event, u16 vid);
 	void (*cm_connect_complete)(struct cnic_sock *);
 	void (*cm_close_complete)(struct cnic_sock *);
 	void (*cm_abort_complete)(struct cnic_sock *);
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 7a16ca1..9eebaeb 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -767,17 +767,23 @@ static void bnx2fc_destroy_timer(unsigned long data)
  *
  * @context:	adapter structure pointer
  * @event:	event type
+ * @vlan_id:	vlan id - associated vlan id with this event
  *
  * Handles NETDEV_UP, NETDEV_DOWN, NETDEV_GOING_DOWN,NETDEV_CHANGE and
  * NETDEV_CHANGE_MTU events
  */
-static void bnx2fc_indicate_netevent(void *context, unsigned long event)
+static void bnx2fc_indicate_netevent(void *context, unsigned long event,
+				     u16 vlan_id)
 {
 	struct bnx2fc_hba *hba = (struct bnx2fc_hba *)context;
 	struct fc_lport *lport = hba->ctlr.lp;
 	struct fc_lport *vport;
 	u32 link_possible = 1;
 
+	/* Ignore vlans for now */
+	if (vlan_id != 0)
+		return;
+
 	if (!test_bit(BNX2FC_CREATE_DONE, &hba->init_done)) {
 		BNX2FC_MISC_DBG("driver not ready. event=%s %ld\n",
 			   hba->netdev->name, event);
diff --git a/drivers/scsi/bnx2i/bnx2i_hwi.c b/drivers/scsi/bnx2i/bnx2i_hwi.c
index 5c54a2d..372d30c 100644
--- a/drivers/scsi/bnx2i/bnx2i_hwi.c
+++ b/drivers/scsi/bnx2i/bnx2i_hwi.c
@@ -2386,14 +2386,20 @@ static void bnx2i_indicate_kcqe(void *context, struct kcqe *kcqe[],
  * bnx2i_indicate_netevent - Generic netdev event handler
  * @context:	adapter structure pointer
  * @event:	event type
+ * @vlan_id:	vlans id - associated vlan id with this event
  *
  * Handles four netdev events, NETDEV_UP, NETDEV_DOWN,
  *	NETDEV_GOING_DOWN and NETDEV_CHANGE
  */
-static void bnx2i_indicate_netevent(void *context, unsigned long event)
+static void bnx2i_indicate_netevent(void *context, unsigned long event,
+				    u16 vlan_id)
 {
 	struct bnx2i_hba *hba = context;
 
+	/* Ignore all netevent coming from vlans */
+	if (vlan_id != 0)
+		return;
+
 	switch (event) {
 	case NETDEV_UP:
 		if (!test_bit(ADAPTER_STATE_UP, &hba->adapter_state))
-- 
1.6.4.GIT


