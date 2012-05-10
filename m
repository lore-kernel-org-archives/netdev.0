From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] ixgbe: cleanup the hwmon function calls
Date: Wed,  9 May 2012 23:46:52 -0700
Message-ID: <1336632413-19135-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756263Ab2EJGrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:47:07 -0400
In-Reply-To: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

When the hwmon code was initially added it was with the assumption that a
sysfs patch would be also coming soon.  Since that isn't the case some
clean up needs to be done.  This patch does that.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    4 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |   36 ++---------------------
 3 files changed, 10 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index cba6ff4..3ef3c52 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -677,8 +677,10 @@ extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 #endif
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
 extern void ixgbe_do_reset(struct net_device *netdev);
+#ifdef CONFIG_IXGBE_HWMON
 extern void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter);
 extern int ixgbe_sysfs_init(struct ixgbe_adapter *adapter);
+#endif /* CONFIG_IXGBE_HWMON */
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_ring *tx_ring,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 05f66a2..863c9b7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7344,8 +7344,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	e_dev_info("%s\n", ixgbe_default_device_descr);
 	cards_found++;
 
+#ifdef CONFIG_IXGBE_HWMON
 	if (ixgbe_sysfs_init(adapter))
 		e_err(probe, "failed to allocate sysfs resources\n");
+#endif /* CONFIG_IXGBE_HWMON */
 
 	return 0;
 
@@ -7397,7 +7399,9 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	}
 
 #endif
+#ifdef CONFIG_IXGBE_HWMON
 	ixgbe_sysfs_exit(adapter);
+#endif /* CONFIG_IXGBE_HWMON */
 
 #ifdef IXGBE_FCOE
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index f81c166..1d80b1c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -37,12 +37,7 @@
 #include <linux/netdevice.h>
 #include <linux/hwmon.h>
 
-/*
- * This file provides a sysfs interface to export information from the
- * driver.  The information presented is READ-ONLY.
- */
 #ifdef CONFIG_IXGBE_HWMON
-
 /* hwmon callback functions */
 static ssize_t ixgbe_hwmon_show_location(struct device *dev,
 					 struct device_attribute *attr,
@@ -162,17 +157,13 @@ static int ixgbe_add_hwmon_attr(struct ixgbe_adapter *adapter,
 
 	return rc;
 }
-#endif /* CONFIG_IXGBE_HWMON */
 
 static void ixgbe_sysfs_del_adapter(struct ixgbe_adapter *adapter)
 {
-#ifdef CONFIG_IXGBE_HWMON
 	int i;
-#endif /* CONFIG_IXGBE_HWMON */
 
 	if (adapter == NULL)
 		return;
-#ifdef CONFIG_IXGBE_HWMON
 
 	for (i = 0; i < adapter->ixgbe_hwmon_buff.n_hwmon; i++) {
 		device_remove_file(&adapter->pdev->dev,
@@ -183,12 +174,6 @@ static void ixgbe_sysfs_del_adapter(struct ixgbe_adapter *adapter)
 
 	if (adapter->ixgbe_hwmon_buff.device)
 		hwmon_device_unregister(adapter->ixgbe_hwmon_buff.device);
-#endif /* CONFIG_IXGBE_HWMON */
-
-	if (adapter->info_kobj != NULL) {
-		kobject_put(adapter->info_kobj);
-		adapter->info_kobj = NULL;
-	}
 }
 
 /* called from ixgbe_main.c */
@@ -200,32 +185,19 @@ void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter)
 /* called from ixgbe_main.c */
 int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
 {
-#ifdef CONFIG_IXGBE_HWMON
 	struct hwmon_buff *ixgbe_hwmon = &adapter->ixgbe_hwmon_buff;
 	unsigned int i;
 	int n_attrs;
-#endif /* CONFIG_IXGBE_HWMON */
-	struct net_device *netdev = adapter->netdev;
 	int rc = 0;
 
-	/* create info kobj and attribute listings in kobj */
-	adapter->info_kobj = kobject_create_and_add("info", &netdev->dev.kobj);
-	if (adapter->info_kobj == NULL) {
-		rc = -ENOMEM;
-		goto err;
-	}
-
-#ifdef CONFIG_IXGBE_HWMON
 	/* If this method isn't defined we don't support thermals */
 	if (adapter->hw.mac.ops.init_thermal_sensor_thresh == NULL) {
-		rc = -EPERM;
-		goto err;
+		goto exit;
 	}
 
 	/* Don't create thermal hwmon interface if no sensors present */
-	rc = adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw);
-	if (rc)
-		goto err;
+	if (adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw))
+		goto exit;
 
 	/*
 	 * Allocation space for max attributs
@@ -261,7 +233,6 @@ int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
 		if (rc)
 			goto err;
 	}
-#endif /* CONFIG_IXGBE_HWMON */
 
 	goto exit;
 
@@ -270,4 +241,5 @@ err:
 exit:
 	return rc;
 }
+#endif /* CONFIG_IXGBE_HWMON */
 
-- 
1.7.7.6
