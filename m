From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V3 net-next 2/2] liquidio: Configure switchdev with devlink
Date: Tue, 31 Oct 2017 16:04:57 -0700
Message-ID: <20171031230457.GA3641@felix-thinkpad.cavium.com>
References: <20171031230420.GA3615@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        vijaya.guvva@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0059.outbound.protection.outlook.com ([104.47.36.59]:38720
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753775AbdJaXFB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 19:05:01 -0400
Content-Disposition: inline
In-Reply-To: <20171031230420.GA3615@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>

Enable and disable switchdev on SRIOV capable LiquidIO NIC with devlink.
Create representor netdev for each SRIOV VF function on SRIOV enable and
and do the cleanup on SRIOV disable.

Signed-off-by: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/Kconfig                |  1 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 93 ++++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c  |  6 ++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  1 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  7 ++
 5 files changed, 108 insertions(+)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index dcbce6c..63be75e 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -53,6 +53,7 @@ config	THUNDER_NIC_RGX
 config LIQUIDIO
 	tristate "Cavium LiquidIO support"
 	depends on 64BIT
+	depends on MAY_USE_DEVLINK
 	imply PTP_1588_CLOCK
 	select FW_LOADER
 	select LIBCRC32C
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8078412..f27f0af 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -35,6 +35,7 @@
 #include "cn68xx_device.h"
 #include "cn23xx_pf_device.h"
 #include "liquidio_image.h"
+#include "lio_vf_rep.h"
 
 MODULE_AUTHOR("Cavium Networks, <support@cavium.com>");
 MODULE_DESCRIPTION("Cavium LiquidIO Intelligent Server Adapter Driver");
@@ -1603,6 +1604,8 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 	oct->cmd_resp_state = OCT_DRV_OFFLINE;
 	spin_unlock_bh(&oct->cmd_resp_wqlock);
 
+	lio_vf_rep_destroy(oct);
+
 	for (i = 0; i < oct->ifcount; i++) {
 		lio = GET_LIO(oct->props[i].netdev);
 		for (j = 0; j < oct->num_oqs; j++)
@@ -1613,6 +1616,12 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 	for (i = 0; i < oct->ifcount; i++)
 		liquidio_destroy_nic_device(oct, i);
 
+	if (oct->devlink) {
+		devlink_unregister(oct->devlink);
+		devlink_free(oct->devlink);
+		oct->devlink = NULL;
+	}
+
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces stopped\n");
 	return 0;
 }
@@ -3311,9 +3320,66 @@ static int liquidio_set_vf_link_state(struct net_device *netdev, int vfidx,
 }
 
 static int
+liquidio_eswitch_mode_get(struct devlink *devlink, u16 *mode)
+{
+	struct lio_devlink_priv *priv;
+	struct octeon_device *oct;
+
+	priv = devlink_priv(devlink);
+	oct = priv->oct;
+
+	*mode = oct->eswitch_mode;
+
+	return 0;
+}
+
+static int
+liquidio_eswitch_mode_set(struct devlink *devlink, u16 mode)
+{
+	struct lio_devlink_priv *priv;
+	struct octeon_device *oct;
+	int ret = 0;
+
+	priv = devlink_priv(devlink);
+	oct = priv->oct;
+
+	if (!(oct->fw_info.app_cap_flags & LIQUIDIO_SWITCHDEV_CAP))
+		return -EINVAL;
+
+	if (oct->eswitch_mode == mode)
+		return 0;
+
+	switch (mode) {
+	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
+		oct->eswitch_mode = mode;
+		ret = lio_vf_rep_create(oct);
+		break;
+
+	case DEVLINK_ESWITCH_MODE_LEGACY:
+		lio_vf_rep_destroy(oct);
+		oct->eswitch_mode = mode;
+		break;
+
+	default:
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
+
+static const struct devlink_ops liquidio_devlink_ops = {
+	.eswitch_mode_get = liquidio_eswitch_mode_get,
+	.eswitch_mode_set = liquidio_eswitch_mode_set,
+};
+
+static int
 lio_pf_switchdev_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 {
 	struct lio *lio = GET_LIO(dev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	if (oct->eswitch_mode != DEVLINK_ESWITCH_MODE_SWITCHDEV)
+		return -EOPNOTSUPP;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
@@ -3462,6 +3528,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	u32 resp_size, ctx_size, data_size;
 	u32 ifidx_or_pfnum;
 	struct lio_version *vdata;
+	struct devlink *devlink;
+	struct lio_devlink_priv *lio_devlink;
 
 	/* This is to handle link status changes */
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
@@ -3794,6 +3862,26 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		octeon_free_soft_command(octeon_dev, sc);
 	}
 
+	devlink = devlink_alloc(&liquidio_devlink_ops,
+				sizeof(struct lio_devlink_priv));
+	if (!devlink) {
+		dev_err(&octeon_dev->pci_dev->dev, "devlink alloc failed\n");
+		goto setup_nic_wait_intr;
+	}
+
+	lio_devlink = devlink_priv(devlink);
+	lio_devlink->oct = octeon_dev;
+
+	if (devlink_register(devlink, &octeon_dev->pci_dev->dev)) {
+		devlink_free(devlink);
+		dev_err(&octeon_dev->pci_dev->dev,
+			"devlink registration failed\n");
+		goto setup_nic_wait_intr;
+	}
+
+	octeon_dev->devlink = devlink;
+	octeon_dev->eswitch_mode = DEVLINK_ESWITCH_MODE_LEGACY;
+
 	return 0;
 
 setup_nic_dev_fail:
@@ -3888,6 +3976,7 @@ static int liquidio_enable_sriov(struct pci_dev *dev, int num_vfs)
 	}
 
 	if (!num_vfs) {
+		lio_vf_rep_destroy(oct);
 		ret = lio_pci_sriov_disable(oct);
 	} else if (num_vfs > oct->sriov_info.max_vfs) {
 		dev_err(&oct->pci_dev->dev,
@@ -3899,6 +3988,10 @@ static int liquidio_enable_sriov(struct pci_dev *dev, int num_vfs)
 		ret = octeon_enable_sriov(oct);
 		dev_info(&oct->pci_dev->dev, "oct->pf_num:%d num_vfs:%d\n",
 			 oct->pf_num, num_vfs);
+		ret = lio_vf_rep_create(oct);
+		if (ret)
+			dev_info(&oct->pci_dev->dev,
+				 "vf representor create failed");
 	}
 
 	return ret;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
index 67ff7a1..de0c80d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
@@ -515,6 +515,9 @@ lio_vf_rep_create(struct octeon_device *oct)
 	struct net_device *ndev;
 	int i, num_vfs;
 
+	if (oct->eswitch_mode != DEVLINK_ESWITCH_MODE_SWITCHDEV)
+		return 0;
+
 	if (!oct->sriov_info.sriov_enabled)
 		return 0;
 
@@ -599,6 +602,9 @@ lio_vf_rep_destroy(struct octeon_device *oct)
 	struct net_device *ndev;
 	int i;
 
+	if (oct->eswitch_mode != DEVLINK_ESWITCH_MODE_SWITCHDEV)
+		return;
+
 	if (!oct->sriov_info.sriov_enabled)
 		return;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 3aceb78..441cc78 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -114,6 +114,7 @@ enum octeon_tag_type {
 
 /* App specific capabilities from firmware to pf driver */
 #define LIQUIDIO_TIME_SYNC_CAP 0x1
+#define LIQUIDIO_SWITCHDEV_CAP 0x2
 
 static inline u32 incr_index(u32 index, u32 count, u32 max)
 {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index c97e067..63b0c75 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -23,6 +23,7 @@
 #define  _OCTEON_DEVICE_H_
 
 #include <linux/interrupt.h>
+#include <net/devlink.h>
 
 /** PCI VendorId Device Id */
 #define  OCTEON_CN68XX_PCIID          0x91177d
@@ -396,6 +397,10 @@ struct lio_vf_rep_list {
 	struct net_device *ndev[CN23XX_MAX_VFS_PER_PF];
 };
 
+struct lio_devlink_priv {
+	struct octeon_device *oct;
+};
+
 /** The Octeon device.
  *  Each Octeon device has this structure to represent all its
  *  components.
@@ -575,6 +580,8 @@ struct octeon_device {
 	bool ptp_enable;
 
 	struct lio_vf_rep_list vf_rep_list;
+	struct devlink *devlink;
+	enum devlink_eswitch_mode eswitch_mode;
 };
 
 #define  OCT_DRV_ONLINE 1
-- 
2.9.0
