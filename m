From: Robert Love <robert.w.love@intel.com>
Subject: [RFC PATCH 2/5] libfcoe: Create new libfcoe control interfaces
Date: Mon, 10 Sep 2012 15:59:19 -0700
Message-ID: <20120910225919.13140.63240.stgit@fritz>
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

This patch is the first in a series that will remove
libfcoe's create, destroy, enable and disable module
parameters and replace them with interface files in
the new /sys/bus/fcoe subsystem.

Old layout:

/sys/module/libfcoe/parameters/{create,destroy,enable,disable,vn2vn_create}

New layout:

/sys/bus/fcoe/ctlr_{create,destroy}
/sys/bus/fcoe/ctlr_X/{enable,disable,start}

This patch moves fcoe drivers to the following
initialization sequence-

1) create/alloc
2) configure
3) start

A control sysfs interface at /sys/bus/fcoe/ctlr_create
is added. Writing the interface name to this file
will allocate memory and create a sysfs entry for a
new fcoe_ctlr_device. The user may then tune the interface in
any desired way. After configuration the user will
echo any value into the /sys/bus/fcoe/devices/ctlr_X/start
interface to proceed with logging in.

VN2VN logins will still use the module parameters.
A follow up patch to this one will make the 'mode'
attribute of the fcoe_ctlr_device writable. Which will
allow a user to change the ctlr's mode to 'VN2VN'.

Signed-off-by: Robert Love <robert.w.love@intel.com>
---
 Documentation/ABI/testing/sysfs-bus-fcoe |   43 ++++++++++++
 drivers/scsi/fcoe/fcoe.h                 |    9 +++
 drivers/scsi/fcoe/fcoe_ctlr.c            |    2 -
 drivers/scsi/fcoe/fcoe_sysfs.c           |   78 ++++++++++++++++++++++
 drivers/scsi/fcoe/fcoe_transport.c       |  105 +++++++++++++++++++++++++++++-
 include/scsi/fcoe_sysfs.h                |    4 +
 include/scsi/libfcoe.h                   |   14 ++++
 7 files changed, 250 insertions(+), 5 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-bus-fcoe b/Documentation/ABI/testing/sysfs-bus-fcoe
index 1b06ec1..242d4a1 100644
--- a/Documentation/ABI/testing/sysfs-bus-fcoe
+++ b/Documentation/ABI/testing/sysfs-bus-fcoe
@@ -1,8 +1,37 @@
+What:		/sys/bus/fcoe/
+Date:		August 2012
+KernelVersion:	TBD
+Contact:	Robert Love <robert.w.love@intel.com>, devel@open-fcoe.org
+Description:	The FCoE bus. Attributes in this directory are control interfaces.
+Attributes:
+
+	ctlr_create: 'FCoE Controller' instance creation interface. Writing an
+		     <ifname> to this file will allocate and populate sysfs with a
+		     fcoe_ctlr_device (ctlr_X). The user can then configure any
+		     per-port settings and finally write to the fcoe_ctlr_device's
+		     'start' attribute to begin the kernel's discovery and login
+		     process.
+
+	ctlr_destroy: 'FCoE Controller' instance removal interface. Writing a
+		       fcoe_ctlr_device's sysfs name to this file will log the
+		       fcoe_ctlr_device out of the fabric or otherwise connected
+		       FCoE devices. It will also free all kernel memory allocated
+		       for this fcoe_ctlr_device and any structures associated
+		       with it, this includes the scsi_host.
+
 What:		/sys/bus/fcoe/ctlr_X
 Date:		March 2012
 KernelVersion:	TBD
 Contact:	Robert Love <robert.w.love@intel.com>, devel@open-fcoe.org
-Description:	'FCoE Controller' instances on the fcoe bus
+Description:	'FCoE Controller' instances on the fcoe bus.
+
+		The FCoE Controller now has a three stage creation process.
+		1) Write interface name to ctlr_create 2) Configure the FCoE
+		Controller (ctlr_X) 3) Write anything to the FCoE
+		Controller's 'start' file to begin discovery and login. The
+		FCoE Controller is destroyed by writing it's name, i.e. ctlr_X
+		to the ctlr_delete file.
+
 Attributes:
 
 	fcf_dev_loss_tmo: Device loss timeout peroid (see below). Changing
@@ -17,6 +46,18 @@ Attributes:
 			  FIP VN2VN discovery and login is performed. A FCoE
 			  Controller only supports one mode at a time.
 
+	start:		  Start the FCoE controller.
+
+	disable:	  Allow FCoE controller's that support disabling
+			  to be disabled when any value is written to this
+			  file. This attribute is only displayed if the
+			  driver supports it.
+
+	enable:           Allow FCoE controller's that support enabling
+			  to be enabled when any value is written to this
+			  file. This attribute is only displayed if the
+			  driver supports it.
+
 	lesb_link_fail:   Link Error Status Block (LESB) link failure count.
 
 	lesb_vlink_fail:  Link Error Status Block (LESB) virtual link
diff --git a/drivers/scsi/fcoe/fcoe.h b/drivers/scsi/fcoe/fcoe.h
index a624add..e984627 100644
--- a/drivers/scsi/fcoe/fcoe.h
+++ b/drivers/scsi/fcoe/fcoe.h
@@ -22,6 +22,7 @@
 
 #include <linux/skbuff.h>
 #include <linux/kthread.h>
+#include <scsi/libfc.h>
 
 #define FCOE_MAX_QUEUE_DEPTH	256
 #define FCOE_MIN_QUEUE_DEPTH	32
@@ -99,4 +100,12 @@ static inline struct net_device *fcoe_netdev(const struct fc_lport *lport)
 			((struct fcoe_port *)lport_priv(lport))->priv)->netdev;
 }
 
+struct net_device *fcoe_ctlr_to_netdev(
+	const struct fcoe_ctlr_device *ctlr_dev)
+{
+	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(ctlr_dev);
+	struct fc_lport *lport = ctlr->lp;
+	return fcoe_netdev(lport);
+}
+
 #endif /* _FCOE_H_ */
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index bd899bf..ccb92323 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -147,7 +147,7 @@ static void fcoe_ctlr_map_dest(struct fcoe_ctlr *fip)
  */
 void fcoe_ctlr_init(struct fcoe_ctlr *fip, enum fip_state mode)
 {
-	fcoe_ctlr_set_state(fip, FIP_ST_LINK_WAIT);
+	fcoe_ctlr_set_state(fip, FIP_ST_DISABLED);
 	fip->mode = mode;
 	INIT_LIST_HEAD(&fip->fcfs);
 	mutex_init(&fip->ctlr_mutex);
diff --git a/drivers/scsi/fcoe/fcoe_sysfs.c b/drivers/scsi/fcoe/fcoe_sysfs.c
index 3fbc556..d2f8cf9 100644
--- a/drivers/scsi/fcoe/fcoe_sysfs.c
+++ b/drivers/scsi/fcoe/fcoe_sysfs.c
@@ -24,6 +24,7 @@
 #include <linux/ctype.h>
 
 #include <scsi/fcoe_sysfs.h>
+#include <scsi/libfcoe.h>
 
 static atomic_t ctlr_num;
 static atomic_t fcf_num;
@@ -41,6 +42,9 @@ MODULE_PARM_DESC(fcf_dev_loss_tmo,
 		 " insulate the loss of a fcf. Once this value is"
 		 " exceeded, the fcf is removed.");
 
+BUS_ATTR(ctlr_create, S_IWUSR, NULL, fcoe_ctlr_create_store);
+BUS_ATTR(ctlr_destroy, S_IWUSR, NULL, fcoe_ctlr_destroy_store);
+
 #define FCOE_MAX_MODENAME_LEN 20
 struct fcoe_ctlr_mode_table {
 	char *modename;
@@ -333,6 +337,65 @@ static ssize_t store_ctlr_mode(struct device *dev,
 static FCOE_DEVICE_ATTR(ctlr, mode, S_IRUGO | S_IWUSR,
 			show_ctlr_mode, store_ctlr_mode);
 
+static ssize_t store_ctlr_start(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct fcoe_ctlr_device *ctlr = dev_to_ctlr(dev);
+	int rc;
+
+	if (ctlr->started == 1)
+		return -EINVAL;
+
+	rc = ctlr->f->set_fcoe_ctlr_start(ctlr);
+	if (rc)
+		return rc;
+
+	ctlr->started = 1;
+
+	return count;
+}
+static FCOE_DEVICE_ATTR(ctlr, start, S_IWUSR,
+			NULL, store_ctlr_start);
+
+static ssize_t store_ctlr_enable(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct fcoe_ctlr_device *ctlr = dev_to_ctlr(dev);
+	int rc;
+
+	if (ctlr->started == 1)
+		return -EINVAL;
+
+	rc = ctlr->f->set_fcoe_ctlr_enable(ctlr);
+	if (rc)
+		return rc;
+
+	return count;
+}
+static FCOE_DEVICE_ATTR(ctlr, enable, S_IWUSR,
+			NULL, store_ctlr_enable);
+
+static ssize_t store_ctlr_disable(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t count)
+{
+	struct fcoe_ctlr_device *ctlr = dev_to_ctlr(dev);
+	int rc;
+
+	if (ctlr->started == 1)
+		return -EINVAL;
+
+	rc = ctlr->f->set_fcoe_ctlr_disable(ctlr);
+	if (rc)
+		return rc;
+
+	return count;
+}
+static FCOE_DEVICE_ATTR(ctlr, disable, S_IWUSR,
+			NULL, store_ctlr_disable);
+
 static ssize_t
 store_private_fcoe_ctlr_fcf_dev_loss_tmo(struct device *dev,
 					 struct device_attribute *attr,
@@ -416,6 +479,9 @@ static struct attribute_group fcoe_ctlr_lesb_attr_group = {
 
 static struct attribute *fcoe_ctlr_attrs[] = {
 	&device_attr_fcoe_ctlr_fcf_dev_loss_tmo.attr,
+	&device_attr_fcoe_ctlr_start.attr,
+	&device_attr_fcoe_ctlr_enable.attr,
+	&device_attr_fcoe_ctlr_disable.attr,
 	&device_attr_fcoe_ctlr_mode.attr,
 	NULL,
 };
@@ -880,6 +946,18 @@ int __init fcoe_sysfs_setup(void)
 	if (error)
 		return error;
 
+	error = bus_create_file(&fcoe_bus_type, &bus_attr_ctlr_create);
+	if (error) {
+		bus_unregister(&fcoe_bus_type);
+		return error;
+	}
+
+	error = bus_create_file(&fcoe_bus_type, &bus_attr_ctlr_destroy);
+	if (error) {
+		bus_unregister(&fcoe_bus_type);
+		return error;
+	}
+
 	return 0;
 }
 
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fcoe_transport.c
index b46f43d..8e50d9a 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -515,9 +515,8 @@ static int __exit fcoe_transport_exit(void)
 	return 0;
 }
 
-
 static int fcoe_add_netdev_mapping(struct net_device *netdev,
-					struct fcoe_transport *ft)
+				   struct fcoe_transport *ft)
 {
 	struct fcoe_netdev_mapping *nm;
 
@@ -627,6 +626,108 @@ static int libfcoe_device_notification(struct notifier_block *notifier,
 	return NOTIFY_OK;
 }
 
+ssize_t fcoe_ctlr_create_store(struct bus_type *bus,
+			       const char *buf, size_t count)
+{
+	struct net_device *netdev = NULL;
+	struct fcoe_transport *ft = NULL;
+	struct fcoe_ctlr_device *ctlr_dev = NULL;
+	int rc = -ENODEV;
+	int err;
+
+	mutex_lock(&ft_mutex);
+
+	netdev = fcoe_if_to_netdev(buf);
+	if (!netdev) {
+		LIBFCOE_TRANSPORT_DBG("Invalid device %s.\n", buf);
+		rc = -ENODEV;
+		goto out_nodev;
+	}
+
+	ft = fcoe_netdev_map_lookup(netdev);
+	if (ft) {
+		LIBFCOE_TRANSPORT_DBG("transport %s already has existing "
+				      "FCoE instance on %s.\n",
+				      ft->name, netdev->name);
+		rc = -EEXIST;
+		goto out_putdev;
+	}
+
+	ft = fcoe_transport_lookup(netdev);
+	if (!ft) {
+		LIBFCOE_TRANSPORT_DBG("no FCoE transport found for %s.\n",
+				      netdev->name);
+		rc = -ENODEV;
+		goto out_putdev;
+	}
+
+	/* pass to transport create */
+	err = ft->alloc ? ft->alloc(netdev) : -ENODEV;
+	if (err) {
+		fcoe_del_netdev_mapping(netdev);
+		rc = -ENOMEM;
+		goto out_putdev;
+	}
+
+	err = fcoe_add_netdev_mapping(netdev, ft);
+	if (err) {
+		LIBFCOE_TRANSPORT_DBG("failed to add new netdev mapping "
+				      "for FCoE transport %s for %s.\n",
+				      ft->name, netdev->name);
+		rc = -ENODEV;
+		goto out_putdev;
+	}
+
+	LIBFCOE_TRANSPORT_DBG("transport %s %s to create fcoe on %s.\n",
+			      ft->name, (ctlr_dev) ? "succeeded" : "failed",
+			      netdev->name);
+
+out_putdev:
+	dev_put(netdev);
+out_nodev:
+	mutex_unlock(&ft_mutex);
+	return rc;
+}
+
+ssize_t fcoe_ctlr_destroy_store(struct bus_type *bus,
+				const char *buf, size_t count)
+{
+	int rc = -ENODEV;
+	struct net_device *netdev = NULL;
+	struct fcoe_transport *ft = NULL;
+
+	mutex_lock(&ft_mutex);
+
+	netdev = fcoe_if_to_netdev(buf);
+	if (!netdev) {
+		LIBFCOE_TRANSPORT_DBG("invalid device %s.\n", buf);
+		goto out_nodev;
+	}
+
+	ft = fcoe_netdev_map_lookup(netdev);
+	if (!ft) {
+		LIBFCOE_TRANSPORT_DBG("no FCoE transport found for %s.\n",
+				      netdev->name);
+		goto out_putdev;
+	}
+
+	/* pass to transport destroy */
+	rc = ft->destroy(netdev);
+	if (rc)
+		goto out_putdev;
+
+	fcoe_del_netdev_mapping(netdev);
+	LIBFCOE_TRANSPORT_DBG("transport %s %s to destroy fcoe on %s.\n",
+			      ft->name, (rc) ? "failed" : "succeeded",
+			      netdev->name);
+	rc = count; /* required for successful return */
+out_putdev:
+	dev_put(netdev);
+out_nodev:
+	mutex_unlock(&ft_mutex);
+	return rc;
+}
+EXPORT_SYMBOL(fcoe_ctlr_destroy_store);
 
 /**
  * fcoe_transport_create() - Create a fcoe interface
diff --git a/include/scsi/fcoe_sysfs.h b/include/scsi/fcoe_sysfs.h
index 421ae67..8c5ea70 100644
--- a/include/scsi/fcoe_sysfs.h
+++ b/include/scsi/fcoe_sysfs.h
@@ -36,6 +36,9 @@ struct fcoe_sysfs_function_template {
 	void (*get_fcoe_ctlr_fcs_error)(struct fcoe_ctlr_device *);
 	void (*get_fcoe_ctlr_mode)(struct fcoe_ctlr_device *);
 	void (*set_fcoe_ctlr_mode)(struct fcoe_ctlr_device *);
+	int  (*set_fcoe_ctlr_start)(struct fcoe_ctlr_device *);
+	int  (*set_fcoe_ctlr_enable)(struct fcoe_ctlr_device *);
+	int  (*set_fcoe_ctlr_disable)(struct fcoe_ctlr_device *);
 	void (*get_fcoe_fcf_selected)(struct fcoe_fcf_device *);
 	void (*get_fcoe_fcf_vlan_id)(struct fcoe_fcf_device *);
 };
@@ -64,6 +67,7 @@ struct fcoe_ctlr_device {
 
 	int                             fcf_dev_loss_tmo;
 	enum fip_conn_type              mode;
+	u8                              started:1;
 
 	/* expected in host order for displaying */
 	struct fcoe_fc_els_lesb         lesb;
diff --git a/include/scsi/libfcoe.h b/include/scsi/libfcoe.h
index 20533cc..b19a489 100644
--- a/include/scsi/libfcoe.h
+++ b/include/scsi/libfcoe.h
@@ -289,8 +289,11 @@ static inline bool is_fip_mode(struct fcoe_ctlr *fip)
  * @attached:	whether this transport is already attached
  * @list:	list linkage to all attached transports
  * @match:	handler to allow the transport driver to match up a given netdev
+ * @alloc:      handler to allocate per-instance FCoE structures
+ *		(no discovery or login)
  * @create:	handler to sysfs entry of create for FCoE instances
- * @destroy:	handler to sysfs entry of destroy for FCoE instances
+ * @destroy:    handler to delete per-instance FCoE structures
+ *		(frees all memory)
  * @enable:	handler to sysfs entry of enable for FCoE instances
  * @disable:	handler to sysfs entry of disable for FCoE instances
  */
@@ -299,6 +302,7 @@ struct fcoe_transport {
 	bool attached;
 	struct list_head list;
 	bool (*match) (struct net_device *device);
+	int (*alloc) (struct net_device *device);
 	int (*create) (struct net_device *device, enum fip_state fip_mode);
 	int (*destroy) (struct net_device *device);
 	int (*enable) (struct net_device *device);
@@ -375,4 +379,12 @@ struct fcoe_netdev_mapping {
 int fcoe_transport_attach(struct fcoe_transport *ft);
 int fcoe_transport_detach(struct fcoe_transport *ft);
 
+/* sysfs store handler for ctrl_control interface */
+ssize_t fcoe_ctlr_create_store(struct bus_type *bus,
+			       const char *buf, size_t count);
+ssize_t fcoe_ctlr_destroy_store(struct bus_type *bus,
+				const char *buf, size_t count);
+
 #endif /* _LIBFCOE_H */
+
+

