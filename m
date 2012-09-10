From: Robert Love <robert.w.love@intel.com>
Subject: [RFC PATCH 5/5] libfcoe, fcoe: Remove libfcoe module parameters
Date: Mon, 10 Sep 2012 15:59:35 -0700
Message-ID: <20120910225935.13140.1505.stgit@fritz>
References: <20120910225908.13140.97277.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: devel@open-fcoe.org
To: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, bprakash@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16398 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757975Ab2IJW7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 18:59:38 -0400
In-Reply-To: <20120910225908.13140.97277.stgit@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the create, create_vn2vn, destroy,
enable and disable module parameters. Previous patches
have added these interfaces to the fcoe_sysfs layout
and these misplaced interfaces are no longer necessary.

Signed-off-by: Robert Love <robert.w.love@intel.com>
---
 drivers/scsi/fcoe/fcoe_transport.c |  211 ------------------------------------
 include/scsi/libfcoe.h             |    7 -
 2 files changed, 1 insertion(+), 217 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fcoe_transport.c
index 8e50d9a..f9e6e67 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -32,15 +32,11 @@ MODULE_AUTHOR("Open-FCoE.org");
 MODULE_DESCRIPTION("FIP discovery protocol and FCoE transport for FCoE HBAs");
 MODULE_LICENSE("GPL v2");
 
-static int fcoe_transport_create(const char *, struct kernel_param *);
-static int fcoe_transport_destroy(const char *, struct kernel_param *);
 static int fcoe_transport_show(char *buffer, const struct kernel_param *kp);
 static struct fcoe_transport *fcoe_transport_lookup(struct net_device *device);
 static struct fcoe_transport *fcoe_netdev_map_lookup(struct net_device *device);
-static int fcoe_transport_enable(const char *, struct kernel_param *);
-static int fcoe_transport_disable(const char *, struct kernel_param *);
 static int libfcoe_device_notification(struct notifier_block *notifier,
-				    ulong event, void *ptr);
+				       ulong event, void *ptr);
 
 static LIST_HEAD(fcoe_transports);
 static DEFINE_MUTEX(ft_mutex);
@@ -55,29 +51,6 @@ module_param_call(show, NULL, fcoe_transport_show, NULL, S_IRUSR);
 __MODULE_PARM_TYPE(show, "string");
 MODULE_PARM_DESC(show, " Show attached FCoE transports");
 
-module_param_call(create, fcoe_transport_create, NULL,
-		  (void *)FIP_MODE_FABRIC, S_IWUSR);
-__MODULE_PARM_TYPE(create, "string");
-MODULE_PARM_DESC(create, " Creates fcoe instance on a ethernet interface");
-
-module_param_call(create_vn2vn, fcoe_transport_create, NULL,
-		  (void *)FIP_MODE_VN2VN, S_IWUSR);
-__MODULE_PARM_TYPE(create_vn2vn, "string");
-MODULE_PARM_DESC(create_vn2vn, " Creates a VN_node to VN_node FCoE instance "
-		 "on an Ethernet interface");
-
-module_param_call(destroy, fcoe_transport_destroy, NULL, NULL, S_IWUSR);
-__MODULE_PARM_TYPE(destroy, "string");
-MODULE_PARM_DESC(destroy, " Destroys fcoe instance on a ethernet interface");
-
-module_param_call(enable, fcoe_transport_enable, NULL, NULL, S_IWUSR);
-__MODULE_PARM_TYPE(enable, "string");
-MODULE_PARM_DESC(enable, " Enables fcoe on a ethernet interface.");
-
-module_param_call(disable, fcoe_transport_disable, NULL, NULL, S_IWUSR);
-__MODULE_PARM_TYPE(disable, "string");
-MODULE_PARM_DESC(disable, " Disables fcoe on a ethernet interface.");
-
 /* notification function for packets from net device */
 static struct notifier_block libfcoe_notifier = {
 	.notifier_call = libfcoe_device_notification,
@@ -730,188 +703,6 @@ out_nodev:
 EXPORT_SYMBOL(fcoe_ctlr_destroy_store);
 
 /**
- * fcoe_transport_create() - Create a fcoe interface
- * @buffer: The name of the Ethernet interface to create on
- * @kp:	    The associated kernel param
- *
- * Called from sysfs. This holds the ft_mutex while calling the
- * registered fcoe transport's create function.
- *
- * Returns: 0 for success
- */
-static int fcoe_transport_create(const char *buffer, struct kernel_param *kp)
-{
-	int rc = -ENODEV;
-	struct net_device *netdev = NULL;
-	struct fcoe_transport *ft = NULL;
-	enum fip_state fip_mode = (enum fip_state)(long)kp->arg;
-
-	mutex_lock(&ft_mutex);
-
-	netdev = fcoe_if_to_netdev(buffer);
-	if (!netdev) {
-		LIBFCOE_TRANSPORT_DBG("Invalid device %s.\n", buffer);
-		goto out_nodev;
-	}
-
-	ft = fcoe_netdev_map_lookup(netdev);
-	if (ft) {
-		LIBFCOE_TRANSPORT_DBG("transport %s already has existing "
-				      "FCoE instance on %s.\n",
-				      ft->name, netdev->name);
-		rc = -EEXIST;
-		goto out_putdev;
-	}
-
-	ft = fcoe_transport_lookup(netdev);
-	if (!ft) {
-		LIBFCOE_TRANSPORT_DBG("no FCoE transport found for %s.\n",
-				      netdev->name);
-		goto out_putdev;
-	}
-
-	rc = fcoe_add_netdev_mapping(netdev, ft);
-	if (rc) {
-		LIBFCOE_TRANSPORT_DBG("failed to add new netdev mapping "
-				      "for FCoE transport %s for %s.\n",
-				      ft->name, netdev->name);
-		goto out_putdev;
-	}
-
-	/* pass to transport create */
-	rc = ft->create ? ft->create(netdev, fip_mode) : -ENODEV;
-	if (rc)
-		fcoe_del_netdev_mapping(netdev);
-
-	LIBFCOE_TRANSPORT_DBG("transport %s %s to create fcoe on %s.\n",
-			      ft->name, (rc) ? "failed" : "succeeded",
-			      netdev->name);
-
-out_putdev:
-	dev_put(netdev);
-out_nodev:
-	mutex_unlock(&ft_mutex);
-	return rc;
-}
-
-/**
- * fcoe_transport_destroy() - Destroy a FCoE interface
- * @buffer: The name of the Ethernet interface to be destroyed
- * @kp:	    The associated kernel parameter
- *
- * Called from sysfs. This holds the ft_mutex while calling the
- * registered fcoe transport's destroy function.
- *
- * Returns: 0 for success
- */
-static int fcoe_transport_destroy(const char *buffer, struct kernel_param *kp)
-{
-	int rc = -ENODEV;
-	struct net_device *netdev = NULL;
-	struct fcoe_transport *ft = NULL;
-
-	mutex_lock(&ft_mutex);
-
-	netdev = fcoe_if_to_netdev(buffer);
-	if (!netdev) {
-		LIBFCOE_TRANSPORT_DBG("invalid device %s.\n", buffer);
-		goto out_nodev;
-	}
-
-	ft = fcoe_netdev_map_lookup(netdev);
-	if (!ft) {
-		LIBFCOE_TRANSPORT_DBG("no FCoE transport found for %s.\n",
-				      netdev->name);
-		goto out_putdev;
-	}
-
-	/* pass to transport destroy */
-	rc = ft->destroy ? ft->destroy(netdev) : -ENODEV;
-	fcoe_del_netdev_mapping(netdev);
-	LIBFCOE_TRANSPORT_DBG("transport %s %s to destroy fcoe on %s.\n",
-			      ft->name, (rc) ? "failed" : "succeeded",
-			      netdev->name);
-
-out_putdev:
-	dev_put(netdev);
-out_nodev:
-	mutex_unlock(&ft_mutex);
-	return rc;
-}
-
-/**
- * fcoe_transport_disable() - Disables a FCoE interface
- * @buffer: The name of the Ethernet interface to be disabled
- * @kp:	    The associated kernel parameter
- *
- * Called from sysfs.
- *
- * Returns: 0 for success
- */
-static int fcoe_transport_disable(const char *buffer, struct kernel_param *kp)
-{
-	int rc = -ENODEV;
-	struct net_device *netdev = NULL;
-	struct fcoe_transport *ft = NULL;
-
-	mutex_lock(&ft_mutex);
-
-	netdev = fcoe_if_to_netdev(buffer);
-	if (!netdev)
-		goto out_nodev;
-
-	ft = fcoe_netdev_map_lookup(netdev);
-	if (!ft)
-		goto out_putdev;
-
-	rc = ft->disable ? ft->disable(netdev) : -ENODEV;
-
-out_putdev:
-	dev_put(netdev);
-out_nodev:
-	mutex_unlock(&ft_mutex);
-
-	if (rc == -ERESTARTSYS)
-		return restart_syscall();
-	else
-		return rc;
-}
-
-/**
- * fcoe_transport_enable() - Enables a FCoE interface
- * @buffer: The name of the Ethernet interface to be enabled
- * @kp:     The associated kernel parameter
- *
- * Called from sysfs.
- *
- * Returns: 0 for success
- */
-static int fcoe_transport_enable(const char *buffer, struct kernel_param *kp)
-{
-	int rc = -ENODEV;
-	struct net_device *netdev = NULL;
-	struct fcoe_transport *ft = NULL;
-
-	mutex_lock(&ft_mutex);
-
-	netdev = fcoe_if_to_netdev(buffer);
-	if (!netdev)
-		goto out_nodev;
-
-	ft = fcoe_netdev_map_lookup(netdev);
-	if (!ft)
-		goto out_putdev;
-
-	rc = ft->enable ? ft->enable(netdev) : -ENODEV;
-
-out_putdev:
-	dev_put(netdev);
-out_nodev:
-	mutex_unlock(&ft_mutex);
-	return rc;
-}
-
-/**
  * libfcoe_init() - Initialization routine for libfcoe.ko
  */
 static int __init libfcoe_init(void)
diff --git a/include/scsi/libfcoe.h b/include/scsi/libfcoe.h
index b19a489..af2e444 100644
--- a/include/scsi/libfcoe.h
+++ b/include/scsi/libfcoe.h
@@ -291,11 +291,7 @@ static inline bool is_fip_mode(struct fcoe_ctlr *fip)
  * @match:	handler to allow the transport driver to match up a given netdev
  * @alloc:      handler to allocate per-instance FCoE structures
  *		(no discovery or login)
- * @create:	handler to sysfs entry of create for FCoE instances
  * @destroy:    handler to delete per-instance FCoE structures
- *		(frees all memory)
- * @enable:	handler to sysfs entry of enable for FCoE instances
- * @disable:	handler to sysfs entry of disable for FCoE instances
  */
 struct fcoe_transport {
 	char name[IFNAMSIZ];
@@ -303,10 +299,7 @@ struct fcoe_transport {
 	struct list_head list;
 	bool (*match) (struct net_device *device);
 	int (*alloc) (struct net_device *device);
-	int (*create) (struct net_device *device, enum fip_state fip_mode);
 	int (*destroy) (struct net_device *device);
-	int (*enable) (struct net_device *device);
-	int (*disable) (struct net_device *device);
 };
 
 /**
