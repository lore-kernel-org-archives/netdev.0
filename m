From: Robert Love <robert.w.love@intel.com>
Subject: [RFC PATCH 3/5] fcoe: Use new fcoe_sysfs control interface
Date: Mon, 10 Sep 2012 15:59:25 -0700
Message-ID: <20120910225924.13140.84794.stgit@fritz>
References: <20120910225908.13140.97277.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: devel@open-fcoe.org
To: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, bprakash@broadcom.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120910225908.13140.97277.stgit@fritz>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert fcoe to use the new fcoe_sysfs create, delete,
enable, disable, start and mode.

Signed-off-by: Robert Love <robert.w.love@intel.com>
---
 drivers/scsi/fcoe/fcoe.c |  229 +++++++++++++++++++++++-----------------------
 1 file changed, 115 insertions(+), 114 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index fe30b1b..fe9ce98 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -112,10 +112,10 @@ static int fcoe_dcb_app_notification(struct notifier_block *notifier,
 				     ulong event, void *ptr);
 
 static bool fcoe_match(struct net_device *netdev);
-static int fcoe_create(struct net_device *netdev, enum fip_state fip_mode);
+static int fcoe_start(struct fcoe_ctlr_device *cdev);
 static int fcoe_destroy(struct net_device *netdev);
-static int fcoe_enable(struct net_device *netdev);
-static int fcoe_disable(struct net_device *netdev);
+static int fcoe_enable(struct fcoe_ctlr_device *cdev);
+static int fcoe_disable(struct fcoe_ctlr_device *cdev);
 
 static struct fc_seq *fcoe_elsct_send(struct fc_lport *,
 				      u32 did, struct fc_frame *,
@@ -155,6 +155,10 @@ static void fcoe_ctlr_get_lesb(struct fcoe_ctlr_device *);
 static void fcoe_fcf_get_vlan_id(struct fcoe_fcf_device *);
 
 static struct fcoe_sysfs_function_template fcoe_sysfs_templ = {
+	.set_fcoe_ctlr_mode = fcoe_ctlr_set_fip_mode,
+	.set_fcoe_ctlr_start = fcoe_start,
+	.set_fcoe_ctlr_enable = fcoe_enable,
+	.set_fcoe_ctlr_disable = fcoe_disable,
 	.get_fcoe_ctlr_mode = fcoe_ctlr_get_fip_mode,
 	.get_fcoe_ctlr_link_fail = fcoe_ctlr_get_lesb,
 	.get_fcoe_ctlr_vlink_fail = fcoe_ctlr_get_lesb,
@@ -2034,105 +2038,6 @@ out:
 }
 
 /**
- * fcoe_disable() - Disables a FCoE interface
- * @netdev  : The net_device object the Ethernet interface to create on
- *
- * Called from fcoe transport.
- *
- * Returns: 0 for success
- */
-static int fcoe_disable(struct net_device *netdev)
-{
-	struct fcoe_ctlr *ctlr;
-	struct fcoe_interface *fcoe;
-	int rc = 0;
-
-	mutex_lock(&fcoe_config_mutex);
-
-	rtnl_lock();
-	fcoe = fcoe_hostlist_lookup_port(netdev);
-	rtnl_unlock();
-
-	if (fcoe) {
-		ctlr = fcoe_to_ctlr(fcoe);
-		fcoe_ctlr_link_down(ctlr);
-		fcoe_clean_pending_queue(ctlr->lp);
-	} else
-		rc = -ENODEV;
-
-	mutex_unlock(&fcoe_config_mutex);
-	return rc;
-}
-
-/**
- * fcoe_enable() - Enables a FCoE interface
- * @netdev  : The net_device object the Ethernet interface to create on
- *
- * Called from fcoe transport.
- *
- * Returns: 0 for success
- */
-static int fcoe_enable(struct net_device *netdev)
-{
-	struct fcoe_ctlr *ctlr;
-	struct fcoe_interface *fcoe;
-	int rc = 0;
-
-	mutex_lock(&fcoe_config_mutex);
-	rtnl_lock();
-	fcoe = fcoe_hostlist_lookup_port(netdev);
-	rtnl_unlock();
-
-	if (!fcoe) {
-		rc = -ENODEV;
-		goto out;
-	}
-
-	ctlr = fcoe_to_ctlr(fcoe);
-
-	if (!fcoe_link_ok(ctlr->lp))
-		fcoe_ctlr_link_up(ctlr);
-
-out:
-	mutex_unlock(&fcoe_config_mutex);
-	return rc;
-}
-
-/**
- * fcoe_destroy() - Destroy a FCoE interface
- * @netdev  : The net_device object the Ethernet interface to create on
- *
- * Called from fcoe transport
- *
- * Returns: 0 for success
- */
-static int fcoe_destroy(struct net_device *netdev)
-{
-	struct fcoe_ctlr *ctlr;
-	struct fcoe_interface *fcoe;
-	struct fc_lport *lport;
-	struct fcoe_port *port;
-	int rc = 0;
-
-	mutex_lock(&fcoe_config_mutex);
-	rtnl_lock();
-	fcoe = fcoe_hostlist_lookup_port(netdev);
-	if (!fcoe) {
-		rc = -ENODEV;
-		goto out_nodev;
-	}
-	ctlr = fcoe_to_ctlr(fcoe);
-	lport = ctlr->lp;
-	port = lport_priv(lport);
-	list_del(&fcoe->list);
-	queue_work(fcoe_wq, &port->destroy_work);
-out_nodev:
-	rtnl_unlock();
-	mutex_unlock(&fcoe_config_mutex);
-	return rc;
-}
-
-/**
  * fcoe_destroy_work() - Destroy a FCoE port in a deferred work context
  * @work: Handle to the FCoE port to be destroyed
  */
@@ -2207,18 +2112,17 @@ static void fcoe_dcb_create(struct fcoe_interface *fcoe)
 }
 
 /**
- * fcoe_create() - Create a fcoe interface
+ * fcoe_alloc() - Allocate memory for a fcoe interface
  * @netdev  : The net_device object the Ethernet interface to create on
- * @fip_mode: The FIP mode for this creation
  *
  * Called from fcoe transport
  *
  * Returns: 0 for success
  */
-static int fcoe_create(struct net_device *netdev, enum fip_state fip_mode)
+static int fcoe_alloc(struct net_device *netdev)
 {
 	int rc = 0;
-	struct fcoe_ctlr_device *ctlr_dev;
+	struct fcoe_ctlr_device *ctlr_dev = NULL;
 	struct fcoe_ctlr *ctlr;
 	struct fcoe_interface *fcoe;
 	struct fc_lport *lport;
@@ -2232,7 +2136,10 @@ static int fcoe_create(struct net_device *netdev, enum fip_state fip_mode)
 		goto out_nodev;
 	}
 
-	fcoe = fcoe_interface_create(netdev, fip_mode);
+	/*
+	 * Create the interface with the default 'Fabric' mode.
+	 */
+	fcoe = fcoe_interface_create(netdev, FIP_MODE_FABRIC);
 	if (IS_ERR(fcoe)) {
 		rc = PTR_ERR(fcoe);
 		goto out_nodev;
@@ -2250,14 +2157,36 @@ static int fcoe_create(struct net_device *netdev, enum fip_state fip_mode)
 		goto out_nortnl;
 	}
 
+	/* add to lports list */
+	fcoe_hostlist_add(lport);
+
 	/* Make this the "master" N_Port */
 	ctlr->lp = lport;
 
 	/* setup DCB priority attributes. */
 	fcoe_dcb_create(fcoe);
 
-	/* add to lports list */
-	fcoe_hostlist_add(lport);
+out_nodev:
+	rtnl_unlock();
+out_nortnl:
+	mutex_unlock(&fcoe_config_mutex);
+	return rc;
+}
+
+/**
+ * fcoe_start() - Start the controller on a fcoe interface
+ * @cdev  : The FCoE Controller Device to start
+ *
+ * Returns: 0 for success
+ */
+int fcoe_start(struct fcoe_ctlr_device *cdev)
+{
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(cdev);
+	struct fc_lport *lport = ctlr->lp;
+	int rc = 0;
+
+	mutex_lock(&fcoe_config_mutex);
+	rtnl_lock();
 
 	/* start FIP Discovery and FLOGI */
 	lport->boot_time = jiffies;
@@ -2269,14 +2198,88 @@ static int fcoe_create(struct net_device *netdev, enum fip_state fip_mode)
 		return rc;
 	}
 
-out_nodev:
 	rtnl_unlock();
-out_nortnl:
 	mutex_unlock(&fcoe_config_mutex);
+
 	return rc;
 }
 
 /**
+ * fcoe_destroy() - Destroy the controller on a fcoe interface
+ * @netdev: The netdevice associated with the controller to destroy
+ *
+ * Called from fcoe transport
+ *
+ * Returns: 0 for success
+ */
+int fcoe_destroy(struct net_device *netdev)
+{
+	struct fcoe_ctlr *ctlr;
+	struct fcoe_interface *fcoe;
+	struct fcoe_port *port;
+	int rc = 0;
+
+	mutex_lock(&fcoe_config_mutex);
+	rtnl_lock();
+
+	fcoe = fcoe_hostlist_lookup_port(netdev);
+	if (!fcoe) {
+		rc = -ENODEV;
+		goto out_nodev;
+	}
+
+	ctlr = fcoe_to_ctlr(fcoe);
+	port = lport_priv(ctlr->lp);
+	list_del(&fcoe->list);
+	queue_work(fcoe_wq, &port->destroy_work);
+
+out_nodev:
+	rtnl_unlock();
+	mutex_unlock(&fcoe_config_mutex);
+	return 0;
+}
+
+/**
+ * fcoe_enable() - Enable the controller on a fcoe interface
+ * @cdev  : The FCoE Controller Device to enable
+ *
+ * Returns: 0 for success
+ */
+int fcoe_enable(struct fcoe_ctlr_device *cdev)
+{
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(cdev);
+
+	mutex_lock(&fcoe_config_mutex);
+
+	if (!fcoe_link_ok(ctlr->lp))
+		fcoe_ctlr_link_up(ctlr);
+
+	mutex_unlock(&fcoe_config_mutex);
+
+	return 0;
+}
+
+/**
+ * fcoe_disable() - Disable the controller on a fcoe interface
+ * @cdev  : The FCoE Controller Device to disable
+ *
+ * Returns: 0 for success
+ */
+int fcoe_disable(struct fcoe_ctlr_device *cdev)
+{
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(cdev);
+
+	mutex_lock(&fcoe_config_mutex);
+
+	fcoe_ctlr_link_down(ctlr);
+	fcoe_clean_pending_queue(ctlr->lp);
+
+	mutex_unlock(&fcoe_config_mutex);
+
+	return 0;
+}
+
+/**
  * fcoe_link_speed_update() - Update the supported and actual link speeds
  * @lport: The local port to update speeds for
  *
@@ -2453,10 +2456,8 @@ static struct fcoe_transport fcoe_sw_transport = {
 	.attached = false,
 	.list = LIST_HEAD_INIT(fcoe_sw_transport.list),
 	.match = fcoe_match,
-	.create = fcoe_create,
+	.alloc = fcoe_alloc,
 	.destroy = fcoe_destroy,
-	.enable = fcoe_enable,
-	.disable = fcoe_disable,
 };
 
 /**

