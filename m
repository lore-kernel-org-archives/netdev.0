From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V4 2/9] liquidio CN23XX: sysfs VF config support
Date: Thu, 3 Nov 2016 14:35:11 -0700
Message-ID: <1478208918-8330-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0057.outbound.protection.outlook.com ([104.47.34.57]:60789
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758373AbcKCVgK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 17:36:10 -0400
In-Reply-To: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds sysfs based support for enabling or disabling VFs.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 98 ++++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  3 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  8 ++
 3 files changed, 109 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 71d01a7..29f5985 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -180,6 +180,8 @@ struct octeon_device_priv {
 	unsigned long napi_mask;
 };
 
+static int liquidio_enable_sriov(struct pci_dev *dev, int num_vfs);
+
 static int octeon_device_init(struct octeon_device *);
 static int liquidio_stop(struct net_device *netdev);
 static void liquidio_remove(struct pci_dev *pdev);
@@ -518,6 +520,7 @@ static int liquidio_resume(struct pci_dev *pdev __attribute__((unused)))
 	.suspend	= liquidio_suspend,
 	.resume		= liquidio_resume,
 #endif
+	.sriov_configure = liquidio_enable_sriov,
 };
 
 /**
@@ -1472,6 +1475,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 				continue;
 			octeon_delete_instr_queue(oct, i);
 		}
+		if (oct->sriov_info.sriov_enabled)
+			pci_disable_sriov(oct->pci_dev);
 		/* fallthrough */
 	case OCT_DEV_SC_BUFF_POOL_INIT_DONE:
 		octeon_free_sc_buffer_pool(oct);
@@ -3990,6 +3995,99 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	return -ENODEV;
 }
 
+static int octeon_enable_sriov(struct octeon_device *oct)
+{
+	unsigned int num_vfs_alloced = oct->sriov_info.num_vfs_alloced;
+	struct pci_dev *vfdev;
+	int err;
+	u32 u;
+
+	if (OCTEON_CN23XX_PF(oct) && num_vfs_alloced) {
+		err = pci_enable_sriov(oct->pci_dev,
+				       oct->sriov_info.num_vfs_alloced);
+		if (err) {
+			dev_err(&oct->pci_dev->dev,
+				"OCTEON: Failed to enable PCI sriov: %d\n",
+				err);
+			oct->sriov_info.num_vfs_alloced = 0;
+			return err;
+		}
+		oct->sriov_info.sriov_enabled = 1;
+
+		/* init lookup table that maps DPI ring number to VF pci_dev
+		 * struct pointer
+		 */
+		u = 0;
+		vfdev = pci_get_device(PCI_VENDOR_ID_CAVIUM,
+				       OCTEON_CN23XX_VF_VID, NULL);
+		while (vfdev) {
+			if (vfdev->is_virtfn &&
+			    (vfdev->physfn == oct->pci_dev)) {
+				oct->sriov_info.dpiring_to_vfpcidev_lut[u] =
+					vfdev;
+				u += oct->sriov_info.rings_per_vf;
+			}
+			vfdev = pci_get_device(PCI_VENDOR_ID_CAVIUM,
+					       OCTEON_CN23XX_VF_VID, vfdev);
+		}
+	}
+
+	return num_vfs_alloced;
+}
+
+static int lio_pci_sriov_disable(struct octeon_device *oct)
+{
+	int u;
+
+	if (pci_vfs_assigned(oct->pci_dev)) {
+		dev_err(&oct->pci_dev->dev, "VFs are still assigned to VMs.\n");
+		return -EPERM;
+	}
+
+	pci_disable_sriov(oct->pci_dev);
+
+	u = 0;
+	while (u < MAX_POSSIBLE_VFS) {
+		oct->sriov_info.dpiring_to_vfpcidev_lut[u] = NULL;
+		u += oct->sriov_info.rings_per_vf;
+	}
+
+	oct->sriov_info.num_vfs_alloced = 0;
+	dev_info(&oct->pci_dev->dev, "oct->pf_num:%d disabled VFs\n",
+		 oct->pf_num);
+
+	return 0;
+}
+
+static int liquidio_enable_sriov(struct pci_dev *dev, int num_vfs)
+{
+	struct octeon_device *oct = pci_get_drvdata(dev);
+	int ret = 0;
+
+	if ((num_vfs == oct->sriov_info.num_vfs_alloced) &&
+	    (oct->sriov_info.sriov_enabled)) {
+		dev_info(&oct->pci_dev->dev, "oct->pf_num:%d already enabled num_vfs:%d\n",
+			 oct->pf_num, num_vfs);
+		return 0;
+	}
+
+	if (!num_vfs) {
+		ret = lio_pci_sriov_disable(oct);
+	} else if (num_vfs > oct->sriov_info.max_vfs) {
+		dev_err(&oct->pci_dev->dev,
+			"OCTEON: Max allowed VFs:%d user requested:%d",
+			oct->sriov_info.max_vfs, num_vfs);
+		ret = -EPERM;
+	} else {
+		oct->sriov_info.num_vfs_alloced = num_vfs;
+		ret = octeon_enable_sriov(oct);
+		dev_info(&oct->pci_dev->dev, "oct->pf_num:%d enabled num_vfs:%d\n",
+			 oct->pf_num, num_vfs);
+	}
+
+	return ret;
+}
+
 /**
  * \brief initialize the NIC
  * @param oct octeon device
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 512bca5..71daf82 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -472,4 +472,7 @@ struct octeon_config {
 
 #define MAX_POSSIBLE_OCTEON_INSTR_QUEUES	CN23XX_MAX_INPUT_QUEUES
 #define MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES	CN23XX_MAX_OUTPUT_QUEUES
+
+#define MAX_POSSIBLE_VFS			64
+
 #endif /* __OCTEON_CONFIG_H__  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 751d3b6..cfd12ec 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -38,6 +38,7 @@
 #define  OCTEON_CN68XX                0x0091
 #define  OCTEON_CN66XX                0x0092
 #define  OCTEON_CN23XX_PF_VID         0x9702
+#define  OCTEON_CN23XX_VF_VID         0x9712
 
 /**RevisionId for the chips */
 #define  OCTEON_CN23XX_REV_1_0        0x00
@@ -331,6 +332,9 @@ struct octeon_sriov_info {
 	 **/
 	u32	max_vfs;
 
+	/** Number of VF devices enabled using sysfs. */
+	u32	num_vfs_alloced;
+
 	/* Actual rings left for PF device */
 	u32	num_pf_rings;
 
@@ -340,6 +344,10 @@ struct octeon_sriov_info {
 	/* total pf rings */
 	u32	trs;
 
+	u32	sriov_enabled;
+
+	/*lookup table that maps DPI ring number to VF pci_dev struct pointer*/
+	struct pci_dev *dpiring_to_vfpcidev_lut[MAX_POSSIBLE_VFS];
 };
 
 struct octeon_ioq_vector {
-- 
1.8.3.1
