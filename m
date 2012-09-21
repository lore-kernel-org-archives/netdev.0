From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/3] ptp: derive the device name from the parent device
Date: Fri, 21 Sep 2012 19:00:27 +0200
Message-ID: <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48114 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755072Ab2IURAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:00:48 -0400
Received: by wgbdr13 with SMTP id dr13so1590078wgb.1
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 10:00:47 -0700 (PDT)
In-Reply-To: <cover.1348245523.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348245523.git.richardcochran@gmail.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTP Hardware Clock device have a name that appears under sysfs that should
identify the underlying device. Instead of leaving it up to the driver to
invent a name, this patch changes the registration to automatically use
the name from the parent device.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c |    3 +--
 drivers/net/ethernet/intel/igb/igb_ptp.c     |    7 ++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    5 ++---
 drivers/net/phy/dp83640.c                    |    3 +--
 drivers/ptp/ptp_clock.c                      |    7 +++++--
 drivers/ptp/ptp_ixp46x.c                     |    3 +--
 drivers/ptp/ptp_pch.c                        |    3 +--
 drivers/ptp/ptp_private.h                    |    1 +
 drivers/ptp/ptp_sysfs.c                      |    2 +-
 include/linux/ptp_clock_kernel.h             |    8 +++++---
 10 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index c08e5d4..a0eaafd 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -408,7 +408,6 @@ static int ptp_gianfar_enable(struct ptp_clock_info *ptp,
 
 static struct ptp_clock_info ptp_gianfar_caps = {
 	.owner		= THIS_MODULE,
-	.name		= "gianfar clock",
 	.max_adj	= 512000,
 	.n_alarm	= N_ALARM,
 	.n_ext_ts	= N_EXT_TS,
@@ -510,7 +509,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 
 	spin_unlock_irqrestore(&etsects->lock, flags);
 
-	etsects->clock = ptp_clock_register(&etsects->caps);
+	etsects->clock = ptp_clock_register(&etsects->caps, &dev->dev);
 	if (IS_ERR(etsects->clock)) {
 		err = PTR_ERR(etsects->clock);
 		goto no_clock;
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index e13ba1d..546e9e2 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -665,11 +665,9 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 void igb_ptp_init(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
 
 	switch (hw->mac.type) {
 	case e1000_82576:
-		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 1000000000;
 		adapter->ptp_caps.n_ext_ts = 0;
@@ -688,7 +686,6 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		break;
 	case e1000_82580:
 	case e1000_i350:
-		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 62499999;
 		adapter->ptp_caps.n_ext_ts = 0;
@@ -707,7 +704,6 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		break;
 	case e1000_i210:
 	case e1000_i211:
-		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 62499999;
 		adapter->ptp_caps.n_ext_ts = 0;
@@ -752,7 +748,8 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		wr32(E1000_IMS, E1000_IMS_TS);
 	}
 
-	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps);
+	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
+						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		dev_err(&adapter->pdev->dev, "ptp_clock_register failed\n");
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 3456d56..6219c91 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -917,7 +917,6 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X540:
-		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 250000000;
 		adapter->ptp_caps.n_alarm = 0;
@@ -931,7 +930,6 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 		adapter->ptp_caps.enable = ixgbe_ptp_enable;
 		break;
 	case ixgbe_mac_82599EB:
-		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 250000000;
 		adapter->ptp_caps.n_alarm = 0;
@@ -960,7 +958,8 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 	/* (Re)start the overflow check */
 	adapter->flags2 |= IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED;
 
-	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps);
+	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
+						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		e_dev_err("ptp_clock_register failed\n");
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index b0da022..12a4c4c 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -871,7 +871,6 @@ static void dp83640_clock_init(struct dp83640_clock *clock, struct mii_bus *bus)
 	mutex_init(&clock->clock_lock);
 	INIT_LIST_HEAD(&clock->phylist);
 	clock->caps.owner = THIS_MODULE;
-	sprintf(clock->caps.name, "dp83640 timer");
 	clock->caps.max_adj	= 1953124;
 	clock->caps.n_alarm	= 0;
 	clock->caps.n_ext_ts	= N_EXT_TS;
@@ -980,7 +979,7 @@ static int dp83640_probe(struct phy_device *phydev)
 
 	if (choose_this_phy(clock, phydev)) {
 		clock->chosen = dp83640;
-		clock->ptp_clock = ptp_clock_register(&clock->caps);
+		clock->ptp_clock = ptp_clock_register(&clock->caps, &phydev->dev);
 		if (IS_ERR(clock->ptp_clock)) {
 			err = PTR_ERR(clock->ptp_clock);
 			goto no_register;
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 6e47450..60fa259 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -186,7 +186,8 @@ static void delete_ptp_clock(struct posix_clock *pc)
 
 /* public interface */
 
-struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
+struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
+				     struct device *parent)
 {
 	struct ptp_clock *ptp;
 	int err = 0, index, major = MAJOR(ptp_devt);
@@ -219,11 +220,13 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
 	init_waitqueue_head(&ptp->tsev_wq);
 
 	/* Create a new device in our class. */
-	ptp->dev = device_create(ptp_class, NULL, ptp->devid, ptp,
+	ptp->dev = device_create(ptp_class, parent, ptp->devid, ptp,
 				 "ptp%d", ptp->index);
 	if (IS_ERR(ptp->dev))
 		goto no_device;
 
+	ptp->name = parent ? dev_name(parent) : dev_name(ptp->dev);
+
 	dev_set_drvdata(ptp->dev, ptp);
 
 	err = ptp_populate_sysfs(ptp);
diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index e03c406..c0939b1 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -241,7 +241,6 @@ static int ptp_ixp_enable(struct ptp_clock_info *ptp,
 
 static struct ptp_clock_info ptp_ixp_caps = {
 	.owner		= THIS_MODULE,
-	.name		= "IXP46X timer",
 	.max_adj	= 66666655,
 	.n_ext_ts	= N_EXT_TS,
 	.pps		= 0,
@@ -298,7 +297,7 @@ static int __init ptp_ixp_init(void)
 
 	ixp_clock.caps = ptp_ixp_caps;
 
-	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps);
+	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps, NULL);
 
 	if (IS_ERR(ixp_clock.ptp_clock))
 		return PTR_ERR(ixp_clock.ptp_clock);
diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 3a9c17e..0ae0c27 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -511,7 +511,6 @@ static int ptp_pch_enable(struct ptp_clock_info *ptp,
 
 static struct ptp_clock_info ptp_pch_caps = {
 	.owner		= THIS_MODULE,
-	.name		= "PCH timer",
 	.max_adj	= 50000000,
 	.n_ext_ts	= N_EXT_TS,
 	.pps		= 0,
@@ -627,7 +626,7 @@ pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	chip->caps = ptp_pch_caps;
-	chip->ptp_clock = ptp_clock_register(&chip->caps);
+	chip->ptp_clock = ptp_clock_register(&chip->caps, &pdev->dev);
 
 	if (IS_ERR(chip->ptp_clock))
 		return PTR_ERR(chip->ptp_clock);
diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
index 69d3207..a3bf959 100644
--- a/drivers/ptp/ptp_private.h
+++ b/drivers/ptp/ptp_private.h
@@ -42,6 +42,7 @@ struct ptp_clock {
 	struct posix_clock clock;
 	struct device *dev;
 	struct ptp_clock_info *info;
+	const char *name;
 	dev_t devid;
 	int index; /* index into clocks.map */
 	struct pps_device *pps_source;
diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
index 2f93926..f3c4519 100644
--- a/drivers/ptp/ptp_sysfs.c
+++ b/drivers/ptp/ptp_sysfs.c
@@ -25,7 +25,7 @@ static ssize_t clock_name_show(struct device *dev,
 			       struct device_attribute *attr, char *page)
 {
 	struct ptp_clock *ptp = dev_get_drvdata(dev);
-	return snprintf(page, PAGE_SIZE-1, "%s\n", ptp->info->name);
+	return snprintf(page, PAGE_SIZE-1, "%s\n", ptp->name);
 }
 
 #define PTP_SHOW_INT(name)						\
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 945704c..e673de0 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -21,6 +21,7 @@
 #ifndef _PTP_CLOCK_KERNEL_H_
 #define _PTP_CLOCK_KERNEL_H_
 
+#include <linux/device.h>
 #include <linux/ptp_clock.h>
 
 
@@ -73,7 +74,6 @@ struct ptp_clock_request {
 
 struct ptp_clock_info {
 	struct module *owner;
-	char name[16];
 	s32 max_adj;
 	int n_alarm;
 	int n_ext_ts;
@@ -92,10 +92,12 @@ struct ptp_clock;
 /**
  * ptp_clock_register() - register a PTP hardware clock driver
  *
- * @info:  Structure describing the new clock.
+ * @info:   Structure describing the new clock.
+ * @parent: Pointer to the parent device of the new clock.
  */
 
-extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info);
+extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
+					    struct device *parent);
 
 /**
  * ptp_clock_unregister() - unregister a PTP hardware clock driver
-- 
1.7.2.5
