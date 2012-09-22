From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 3/4] ptp: link the phc device to its parent device
Date: Sat, 22 Sep 2012 09:42:55 +0200
Message-ID: <847f89f4f5a2757c2487b23dac218e15613c2bb5.1348299094.git.richardcochran@gmail.com>
References: <cover.1348299094.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60234 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530Ab2IVHnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 03:43:15 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so2368173wey.19
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 00:43:14 -0700 (PDT)
In-Reply-To: <cover.1348299094.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348299094.git.richardcochran@gmail.com>
References: <cover.1348299094.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTP Hardware Clock devices appear as class devices in sysfs. This patch
changes the registration API to use the parent device, clarifying the
clock's relationship to the underlying device.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c |    2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c     |    3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    3 ++-
 drivers/net/ethernet/sfc/ptp.c               |    3 ++-
 drivers/net/phy/dp83640.c                    |    2 +-
 drivers/ptp/ptp_clock.c                      |    5 +++--
 drivers/ptp/ptp_ixp46x.c                     |    2 +-
 drivers/ptp/ptp_pch.c                        |    2 +-
 include/linux/ptp_clock_kernel.h             |    7 +++++--
 9 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index c08e5d4..18762a3 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -510,7 +510,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 
 	spin_unlock_irqrestore(&etsects->lock, flags);
 
-	etsects->clock = ptp_clock_register(&etsects->caps);
+	etsects->clock = ptp_clock_register(&etsects->caps, &dev->dev);
 	if (IS_ERR(etsects->clock)) {
 		err = PTR_ERR(etsects->clock);
 		goto no_clock;
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index e13ba1d..ee21445 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -752,7 +752,8 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		wr32(E1000_IMS, E1000_IMS_TS);
 	}
 
-	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps);
+	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
+						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		dev_err(&adapter->pdev->dev, "ptp_clock_register failed\n");
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 3456d56..39881cb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -960,7 +960,8 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 	/* (Re)start the overflow check */
 	adapter->flags2 |= IXGBE_FLAG2_OVERFLOW_CHECK_ENABLED;
 
-	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps);
+	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
+						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		e_dev_err("ptp_clock_register failed\n");
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 2b07a4e..3ed5d13 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -931,7 +931,8 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
 	ptp->phc_clock_info.settime = efx_phc_settime;
 	ptp->phc_clock_info.enable = efx_phc_enable;
 
-	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info);
+	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
+					    &channel->napi_dev->dev);
 	if (!ptp->phc_clock)
 		goto fail3;
 
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index b0da022..24e05c4 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -980,7 +980,7 @@ static int dp83640_probe(struct phy_device *phydev)
 
 	if (choose_this_phy(clock, phydev)) {
 		clock->chosen = dp83640;
-		clock->ptp_clock = ptp_clock_register(&clock->caps);
+		clock->ptp_clock = ptp_clock_register(&clock->caps, &phydev->dev);
 		if (IS_ERR(clock->ptp_clock)) {
 			err = PTR_ERR(clock->ptp_clock);
 			goto no_register;
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 6f7009a..b15a376 100644
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
@@ -219,7 +220,7 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
 	init_waitqueue_head(&ptp->tsev_wq);
 
 	/* Create a new device in our class. */
-	ptp->dev = device_create(ptp_class, NULL, ptp->devid, ptp,
+	ptp->dev = device_create(ptp_class, parent, ptp->devid, ptp,
 				 "ptp%d", ptp->index);
 	if (IS_ERR(ptp->dev))
 		goto no_device;
diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index e03c406..d49b851 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -298,7 +298,7 @@ static int __init ptp_ixp_init(void)
 
 	ixp_clock.caps = ptp_ixp_caps;
 
-	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps);
+	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps, NULL);
 
 	if (IS_ERR(ixp_clock.ptp_clock))
 		return PTR_ERR(ixp_clock.ptp_clock);
diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 3a9c17e..e624e4d 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -627,7 +627,7 @@ pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	chip->caps = ptp_pch_caps;
-	chip->ptp_clock = ptp_clock_register(&chip->caps);
+	chip->ptp_clock = ptp_clock_register(&chip->caps, &pdev->dev);
 
 	if (IS_ERR(chip->ptp_clock))
 		return PTR_ERR(chip->ptp_clock);
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index a644b29..56c71b2 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -21,6 +21,7 @@
 #ifndef _PTP_CLOCK_KERNEL_H_
 #define _PTP_CLOCK_KERNEL_H_
 
+#include <linux/device.h>
 #include <linux/pps_kernel.h>
 #include <linux/ptp_clock.h>
 
@@ -93,10 +94,12 @@ struct ptp_clock;
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
