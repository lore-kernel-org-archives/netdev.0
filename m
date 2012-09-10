From: Robert Love <robert.w.love@intel.com>
Subject: [RFC PATCH 4/5] bnx2fc: Use new fcoe_sysfs control interface
Date: Mon, 10 Sep 2012 15:59:30 -0700
Message-ID: <20120910225930.13140.97949.stgit@fritz>
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

Convert	bnx2fc to use the new fcoe_sysfs create, delete,
enable, disable, start and mode.

bnx2fc doesn't support VN2VN. bnx2fc will not initialize
the set_fcoe_ctlr_mode routine and therefore its instances
will always be in FABRIC mode. There was previously an
explicit check for the ctlr's mode, but this is no longer
needed because not implementing set_fcoe_ctlr_mode implies
that the ctlr cannot change from the FABRIC mode.

Signed-off-by: Robert Love <robert.w.love@intel.com>
---
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c |   98 +++++++++++++++++++++++--------------
 1 file changed, 60 insertions(+), 38 deletions(-)

diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index f52f668f..560c8c8 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -56,11 +56,12 @@ static struct scsi_host_template bnx2fc_shost_template;
 static struct fc_function_template bnx2fc_transport_function;
 static struct fcoe_sysfs_function_template bnx2fc_fcoe_sysfs_templ;
 static struct fc_function_template bnx2fc_vport_xport_function;
-static int bnx2fc_create(struct net_device *netdev, enum fip_state fip_mode);
+
+static int bnx2fc_start(struct fcoe_ctlr_device *);
+static int bnx2fc_enable(struct fcoe_ctlr_device *);
+static int bnx2fc_disable(struct fcoe_ctlr_device *);
+
 static void __bnx2fc_destroy(struct bnx2fc_interface *interface);
-static int bnx2fc_destroy(struct net_device *net_device);
-static int bnx2fc_enable(struct net_device *netdev);
-static int bnx2fc_disable(struct net_device *netdev);
 
 static void bnx2fc_recv_frame(struct sk_buff *skb);
 
@@ -1594,8 +1595,7 @@ static void __bnx2fc_destroy(struct bnx2fc_interface *interface)
 /**
  * bnx2fc_destroy - Destroy a bnx2fc FCoE interface
  *
- * @buffer: The name of the Ethernet interface to be destroyed
- * @kp:     The associated kernel parameter
+ * @netdev: The name of the Ethernet interface to be destroyed
  *
  * Called from sysfs.
  *
@@ -1954,10 +1954,11 @@ static void bnx2fc_ulp_init(struct cnic_dev *dev)
 }
 
 
-static int bnx2fc_disable(struct net_device *netdev)
+static int bnx2fc_disable(struct fcoe_ctlr_device *cdev)
 {
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(cdev);
+	struct net_device *netdev = bnx2fc_netdev(ctlr->lp);
 	struct bnx2fc_interface *interface;
-	struct fcoe_ctlr *ctlr;
 	int rc = 0;
 
 	rtnl_lock();
@@ -1980,10 +1981,11 @@ static int bnx2fc_disable(struct net_device *netdev)
 }
 
 
-static int bnx2fc_enable(struct net_device *netdev)
+static int bnx2fc_enable(struct fcoe_ctlr_device *cdev)
 {
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(cdev);
+	struct net_device *netdev = bnx2fc_netdev(ctlr->lp);
 	struct bnx2fc_interface *interface;
-	struct fcoe_ctlr *ctlr;
 	int rc = 0;
 
 	rtnl_lock();
@@ -2005,17 +2007,17 @@ static int bnx2fc_enable(struct net_device *netdev)
 }
 
 /**
- * bnx2fc_create - Create bnx2fc FCoE interface
+ * bnx2fc_alloc - Alocate a bnx2fc FCoE interface
  *
- * @buffer: The name of Ethernet interface to create on
- * @kp:     The associated kernel param
+ * @netdev: The name of Ethernet interface to allocate on
  *
  * Called from sysfs.
  *
  * Returns: 0 for success
  */
-static int bnx2fc_create(struct net_device *netdev, enum fip_state fip_mode)
+static int bnx2fc_alloc(struct net_device *netdev)
 {
+	struct fcoe_ctlr_device *cdev;
 	struct fcoe_ctlr *ctlr;
 	struct bnx2fc_interface *interface;
 	struct bnx2fc_hba *hba;
@@ -2025,12 +2027,6 @@ static int bnx2fc_create(struct net_device *netdev, enum fip_state fip_mode)
 	int rc = 0;
 	int vlan_id;
 
-	BNX2FC_MISC_DBG("Entered bnx2fc_create\n");
-	if (fip_mode != FIP_MODE_FABRIC) {
-		printk(KERN_ERR "fip mode not FABRIC\n");
-		return -EIO;
-	}
-
 	rtnl_lock();
 
 	mutex_lock(&bnx2fc_dev_lock);
@@ -2077,13 +2073,17 @@ static int bnx2fc_create(struct net_device *netdev, enum fip_state fip_mode)
 		goto netdev_err;
 	}
 
-	interface = bnx2fc_interface_create(hba, netdev, fip_mode);
+	/*
+	 * Create the interface with the default 'Fabric' mode.
+	 */
+	interface = bnx2fc_interface_create(hba, netdev, FIP_MODE_FABRIC);
 	if (!interface) {
 		printk(KERN_ERR PFX "bnx2fc_interface_create failed\n");
 		goto ifput_err;
 	}
 
 	ctlr = bnx2fc_to_ctlr(interface);
+	cdev = fcoe_ctlr_to_ctlr_dev(ctlr);
 	interface->vlan_id = vlan_id;
 	interface->vlan_enabled = 1;
 
@@ -2106,20 +2106,6 @@ static int bnx2fc_create(struct net_device *netdev, enum fip_state fip_mode)
 	/* Add interface to if_list */
 	list_add_tail(&interface->list, &if_list);
 
-	lport->boot_time = jiffies;
-
-	/* Make this master N_port */
-	ctlr->lp = lport;
-
-	if (!bnx2fc_link_ok(lport)) {
-		fcoe_ctlr_link_up(ctlr);
-		fc_host_port_type(lport->host) = FC_PORTTYPE_NPORT;
-		set_bit(ADAPTER_STATE_READY, &interface->hba->adapter_state);
-	}
-
-	BNX2FC_HBA_DBG(lport, "create: START DISC\n");
-	bnx2fc_start_disc(interface);
-	interface->enabled = true;
 	/*
 	 * Release from kref_init in bnx2fc_interface_setup, on success
 	 * lport should be holding a reference taken in bnx2fc_if_create
@@ -2128,6 +2114,7 @@ static int bnx2fc_create(struct net_device *netdev, enum fip_state fip_mode)
 	/* put netdev that was held while calling dev_get_by_name */
 	mutex_unlock(&bnx2fc_dev_lock);
 	rtnl_unlock();
+
 	return 0;
 
 if_create_err:
@@ -2145,6 +2132,40 @@ mod_err:
 }
 
 /**
+ * bnx2fc_alloc - Alocate a bnx2fc FCoE interface
+ *
+ * @cdev: The FCoE Controller Device to start
+ *
+ * Called from sysfs.
+ *
+ * Returns: 0 for success
+ */
+static int bnx2fc_start(struct fcoe_ctlr_device *cdev)
+{
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(cdev);
+	struct fc_lport *lport = ctlr->lp;
+	struct fcoe_port *port = lport_priv(lport);
+	struct bnx2fc_interface *interface = port->priv;
+
+	lport->boot_time = jiffies;
+
+	/* Make this master N_port */
+	ctlr->lp = lport;
+
+	if (!bnx2fc_link_ok(lport)) {
+		fcoe_ctlr_link_up(ctlr);
+		fc_host_port_type(lport->host) = FC_PORTTYPE_NPORT;
+		set_bit(ADAPTER_STATE_READY, &interface->hba->adapter_state);
+	}
+
+	BNX2FC_HBA_DBG(lport, "create: START DISC\n");
+	bnx2fc_start_disc(interface);
+	interface->enabled = true;
+
+	return 0;
+}
+
+/**
  * bnx2fc_find_hba_for_cnic - maps cnic instance to bnx2fc hba instance
  *
  * @cnic:	Pointer to cnic device instance
@@ -2271,10 +2292,8 @@ static struct fcoe_transport bnx2fc_transport = {
 	.attached = false,
 	.list = LIST_HEAD_INIT(bnx2fc_transport.list),
 	.match = bnx2fc_match,
-	.create = bnx2fc_create,
+	.alloc = bnx2fc_alloc,
 	.destroy = bnx2fc_destroy,
-	.enable = bnx2fc_enable,
-	.disable = bnx2fc_disable,
 };
 
 /**
@@ -2514,6 +2533,9 @@ module_init(bnx2fc_mod_init);
 module_exit(bnx2fc_mod_exit);
 
 static struct fcoe_sysfs_function_template bnx2fc_fcoe_sysfs_templ = {
+	.set_fcoe_ctlr_start = bnx2fc_start,
+	.set_fcoe_ctlr_enable = bnx2fc_enable,
+	.set_fcoe_ctlr_disable = bnx2fc_disable,
 	.get_fcoe_ctlr_mode = fcoe_ctlr_get_fip_mode,
 	.get_fcoe_ctlr_link_fail = bnx2fc_ctlr_get_lesb,
 	.get_fcoe_ctlr_vlink_fail = bnx2fc_ctlr_get_lesb,

