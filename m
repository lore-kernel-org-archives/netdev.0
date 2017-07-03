From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 20/27] RDMA: Simplify get firmware interface
Date: Mon,  3 Jul 2017 09:28:23 +0300
Message-ID: <20170703062830.30361-21-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59622 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752728AbdGCG3x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:53 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

There is a need to forward FW version to user space
application through RDMA netlink. In order to make it safe, there
is need to declare nla_policy and limit the size of FW string.

The new define IB_FW_VERSION_NAME_MAX will limit the size of
FW version string. That define was chosen to be equal to
ETHTOOL_FWVERS_LEN, because many drivers anyway are limited
by that value indirectly.

The introduction of this define allows us to remove the string size
from get_fw_str function signature.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/device.c               | 4 ++--
 drivers/infiniband/core/sysfs.c                | 4 ++--
 drivers/infiniband/hw/cxgb3/iwch_provider.c    | 5 ++---
 drivers/infiniband/hw/cxgb4/provider.c         | 5 ++---
 drivers/infiniband/hw/hfi1/verbs.c             | 5 ++---
 drivers/infiniband/hw/i40iw/i40iw_verbs.c      | 7 +++----
 drivers/infiniband/hw/mlx4/main.c              | 5 ++---
 drivers/infiniband/hw/mlx5/main.c              | 8 ++++----
 drivers/infiniband/hw/mthca/mthca_provider.c   | 5 ++---
 drivers/infiniband/hw/nes/nes_verbs.c          | 5 ++---
 drivers/infiniband/hw/ocrdma/ocrdma_main.c     | 5 ++---
 drivers/infiniband/hw/qedr/main.c              | 5 ++---
 drivers/infiniband/hw/usnic/usnic_ib_main.c    | 6 ++----
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_main.c | 5 ++---
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c   | 3 +--
 include/rdma/ib_verbs.h                        | 6 ++++--
 16 files changed, 36 insertions(+), 47 deletions(-)

diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 646c98acc43b..84df7cf868af 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -326,10 +326,10 @@ static int read_port_immutable(struct ib_device *device)
 	return 0;
 }
 
-void ib_get_device_fw_str(struct ib_device *dev, char *str, size_t str_len)
+void ib_get_device_fw_str(struct ib_device *dev, char *str)
 {
 	if (dev->get_dev_fw_str)
-		dev->get_dev_fw_str(dev, str, str_len);
+		dev->get_dev_fw_str(dev, str);
 	else
 		str[0] = '\0';
 }
diff --git a/drivers/infiniband/core/sysfs.c b/drivers/infiniband/core/sysfs.c
index 7ebe1ef23652..abc5ab581f82 100644
--- a/drivers/infiniband/core/sysfs.c
+++ b/drivers/infiniband/core/sysfs.c
@@ -1210,8 +1210,8 @@ static ssize_t show_fw_ver(struct device *device, struct device_attribute *attr,
 {
 	struct ib_device *dev = container_of(device, struct ib_device, dev);
 
-	ib_get_device_fw_str(dev, buf, PAGE_SIZE);
-	strlcat(buf, "\n", PAGE_SIZE);
+	ib_get_device_fw_str(dev, buf);
+	strlcat(buf, "\n", IB_FW_VERSION_NAME_MAX);
 	return strlen(buf);
 }
 
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 29d30744d6c9..f3b27a5a5e06 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -1337,8 +1337,7 @@ static int iwch_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void get_dev_fw_ver_str(struct ib_device *ibdev, char *str,
-			       size_t str_len)
+static void get_dev_fw_ver_str(struct ib_device *ibdev, char *str)
 {
 	struct iwch_dev *iwch_dev = to_iwch_dev(ibdev);
 	struct ethtool_drvinfo info;
@@ -1346,7 +1345,7 @@ static void get_dev_fw_ver_str(struct ib_device *ibdev, char *str,
 
 	pr_debug("%s dev 0x%p\n", __func__, iwch_dev);
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
-	snprintf(str, str_len, "%s", info.fw_version);
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%s", info.fw_version);
 }
 
 int iwch_register_device(struct iwch_dev *dev)
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 0771e9a4d061..346e8334279a 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -517,14 +517,13 @@ static int c4iw_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void get_dev_fw_str(struct ib_device *dev, char *str,
-			   size_t str_len)
+static void get_dev_fw_str(struct ib_device *dev, char *str)
 {
 	struct c4iw_dev *c4iw_dev = container_of(dev, struct c4iw_dev,
 						 ibdev);
 	pr_debug("%s dev 0x%p\n", __func__, dev);
 
-	snprintf(str, str_len, "%u.%u.%u.%u",
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%u.%u.%u.%u",
 		 FW_HDR_FW_VER_MAJOR_G(c4iw_dev->rdev.lldi.fw_vers),
 		 FW_HDR_FW_VER_MINOR_G(c4iw_dev->rdev.lldi.fw_vers),
 		 FW_HDR_FW_VER_MICRO_G(c4iw_dev->rdev.lldi.fw_vers),
diff --git a/drivers/infiniband/hw/hfi1/verbs.c b/drivers/infiniband/hw/hfi1/verbs.c
index 90e7b77d68e8..f05911e7ac61 100644
--- a/drivers/infiniband/hw/hfi1/verbs.c
+++ b/drivers/infiniband/hw/hfi1/verbs.c
@@ -1564,14 +1564,13 @@ static void init_ibport(struct hfi1_pportdata *ppd)
 	RCU_INIT_POINTER(ibp->rvp.qp[1], NULL);
 }
 
-static void hfi1_get_dev_fw_str(struct ib_device *ibdev, char *str,
-				size_t str_len)
+static void hfi1_get_dev_fw_str(struct ib_device *ibdev, char *str)
 {
 	struct rvt_dev_info *rdi = ib_to_rvt(ibdev);
 	struct hfi1_ibdev *dev = dev_from_rdi(rdi);
 	u32 ver = dd_from_dev(dev)->dc8051_ver;
 
-	snprintf(str, str_len, "%u.%u.%u", dc8051_ver_maj(ver),
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%u.%u.%u", dc8051_ver_maj(ver),
 		 dc8051_ver_min(ver), dc8051_ver_patch(ver));
 }
 
diff --git a/drivers/infiniband/hw/i40iw/i40iw_verbs.c b/drivers/infiniband/hw/i40iw/i40iw_verbs.c
index 4dbe61ec7a77..5ad46a454155 100644
--- a/drivers/infiniband/hw/i40iw/i40iw_verbs.c
+++ b/drivers/infiniband/hw/i40iw/i40iw_verbs.c
@@ -2575,13 +2575,12 @@ static const char * const i40iw_hw_stat_names[] = {
 		"iwRdmaInv"
 };
 
-static void i40iw_get_dev_fw_str(struct ib_device *dev, char *str,
-				 size_t str_len)
+static void i40iw_get_dev_fw_str(struct ib_device *dev, char *str)
 {
 	u32 firmware_version = I40IW_FW_VERSION;
 
-	snprintf(str, str_len, "%u.%u", firmware_version,
-		       (firmware_version & 0x000000ff));
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%u.%u", firmware_version,
+		 (firmware_version & 0x000000ff));
 }
 
 /**
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 521d0def2d9e..a3fcedd1c574 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2567,12 +2567,11 @@ static int mlx4_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void get_fw_ver_str(struct ib_device *device, char *str,
-			   size_t str_len)
+static void get_fw_ver_str(struct ib_device *device, char *str)
 {
 	struct mlx4_ib_dev *dev =
 		container_of(device, struct mlx4_ib_dev, ib_dev);
-	snprintf(str, str_len, "%d.%d.%d",
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%d.%d.%d",
 		 (int) (dev->dev->caps.fw_ver >> 32),
 		 (int) (dev->dev->caps.fw_ver >> 16) & 0xffff,
 		 (int) dev->dev->caps.fw_ver & 0xffff);
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 0c79983c8b1a..f9679c3af387 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -3181,13 +3181,13 @@ static int mlx5_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void get_dev_fw_str(struct ib_device *ibdev, char *str,
-			   size_t str_len)
+static void get_dev_fw_str(struct ib_device *ibdev, char *str)
 {
 	struct mlx5_ib_dev *dev =
 		container_of(ibdev, struct mlx5_ib_dev, ib_dev);
-	snprintf(str, str_len, "%d.%d.%04d", fw_rev_maj(dev->mdev),
-		       fw_rev_min(dev->mdev), fw_rev_sub(dev->mdev));
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%d.%d.%04d",
+		 fw_rev_maj(dev->mdev), fw_rev_min(dev->mdev),
+		 fw_rev_sub(dev->mdev));
 }
 
 static int mlx5_eth_lag_init(struct mlx5_ib_dev *dev)
diff --git a/drivers/infiniband/hw/mthca/mthca_provider.c b/drivers/infiniband/hw/mthca/mthca_provider.c
index c197cd9b193f..eae9bffd45d4 100644
--- a/drivers/infiniband/hw/mthca/mthca_provider.c
+++ b/drivers/infiniband/hw/mthca/mthca_provider.c
@@ -1178,12 +1178,11 @@ static int mthca_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void get_dev_fw_str(struct ib_device *device, char *str,
-			   size_t str_len)
+static void get_dev_fw_str(struct ib_device *device, char *str)
 {
 	struct mthca_dev *dev =
 		container_of(device, struct mthca_dev, ib_dev);
-	snprintf(str, str_len, "%d.%d.%d",
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%d.%d.%d",
 		 (int) (dev->fw_ver >> 32),
 		 (int) (dev->fw_ver >> 16) & 0xffff,
 		 (int) dev->fw_ver & 0xffff);
diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband/hw/nes/nes_verbs.c
index 25dcd7573df9..c2943e39d2f9 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -3672,15 +3672,14 @@ static int nes_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void get_dev_fw_str(struct ib_device *dev, char *str,
-			   size_t str_len)
+static void get_dev_fw_str(struct ib_device *dev, char *str)
 {
 	struct nes_ib_device *nesibdev =
 			container_of(dev, struct nes_ib_device, ibdev);
 	struct nes_vnic *nesvnic = nesibdev->nesvnic;
 
 	nes_debug(NES_DBG_INIT, "\n");
-	snprintf(str, str_len, "%u.%u",
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%u.%u",
 		 (nesvnic->nesdev->nesadapter->firmware_version >> 16),
 		 (nesvnic->nesdev->nesadapter->firmware_version & 0x000000ff));
 }
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_main.c b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
index 57c9a2ad0260..43fc9b393e6f 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_main.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
@@ -108,12 +108,11 @@ static int ocrdma_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void get_dev_fw_str(struct ib_device *device, char *str,
-			   size_t str_len)
+static void get_dev_fw_str(struct ib_device *device, char *str)
 {
 	struct ocrdma_dev *dev = get_ocrdma_dev(device);
 
-	snprintf(str, str_len, "%s", &dev->attr.fw_ver[0]);
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%s", &dev->attr.fw_ver[0]);
 }
 
 static int ocrdma_register_device(struct ocrdma_dev *dev)
diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index 6a72095d6c7a..1e4f1d159715 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -69,13 +69,12 @@ static enum rdma_link_layer qedr_link_layer(struct ib_device *device,
 	return IB_LINK_LAYER_ETHERNET;
 }
 
-static void qedr_get_dev_fw_str(struct ib_device *ibdev, char *str,
-				size_t str_len)
+static void qedr_get_dev_fw_str(struct ib_device *ibdev, char *str)
 {
 	struct qedr_dev *qedr = get_qedr_dev(ibdev);
 	u32 fw_ver = (u32)qedr->attr.fw_ver;
 
-	snprintf(str, str_len, "%d. %d. %d. %d",
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%d. %d. %d. %d",
 		 (fw_ver >> 24) & 0xFF, (fw_ver >> 16) & 0xFF,
 		 (fw_ver >> 8) & 0xFF, fw_ver & 0xFF);
 }
diff --git a/drivers/infiniband/hw/usnic/usnic_ib_main.c b/drivers/infiniband/hw/usnic/usnic_ib_main.c
index c0c1e8b027b1..ef7de0cada17 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_main.c
+++ b/drivers/infiniband/hw/usnic/usnic_ib_main.c
@@ -333,9 +333,7 @@ static int usnic_port_immutable(struct ib_device *ibdev, u8 port_num,
 	return 0;
 }
 
-static void usnic_get_dev_fw_str(struct ib_device *device,
-				 char *str,
-				 size_t str_len)
+static void usnic_get_dev_fw_str(struct ib_device *device, char *str)
 {
 	struct usnic_ib_dev *us_ibdev =
 		container_of(device, struct usnic_ib_dev, ib_dev);
@@ -345,7 +343,7 @@ static void usnic_get_dev_fw_str(struct ib_device *device,
 	us_ibdev->netdev->ethtool_ops->get_drvinfo(us_ibdev->netdev, &info);
 	mutex_unlock(&us_ibdev->usdev_lock);
 
-	snprintf(str, str_len, "%s", info.fw_version);
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%s", info.fw_version);
 }
 
 /* Start of PF discovery section */
diff --git a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_main.c b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_main.c
index 34ebc7615411..49e4f7e0b6df 100644
--- a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_main.c
+++ b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_main.c
@@ -102,12 +102,11 @@ static struct device_attribute *pvrdma_class_attributes[] = {
 	&dev_attr_board_id
 };
 
-static void pvrdma_get_fw_ver_str(struct ib_device *device, char *str,
-				  size_t str_len)
+static void pvrdma_get_fw_ver_str(struct ib_device *device, char *str)
 {
 	struct pvrdma_dev *dev =
 		container_of(device, struct pvrdma_dev, ib_dev);
-	snprintf(str, str_len, "%d.%d.%d\n",
+	snprintf(str, IB_FW_VERSION_NAME_MAX, "%d.%d.%d\n",
 		 (int) (dev->dsr->caps.fw_ver >> 32),
 		 (int) (dev->dsr->caps.fw_ver >> 16) & 0xffff,
 		 (int) dev->dsr->caps.fw_ver & 0xffff);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
index 7871379342f4..98e30b41e436 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
@@ -62,8 +62,7 @@ static void ipoib_get_drvinfo(struct net_device *netdev,
 {
 	struct ipoib_dev_priv *priv = ipoib_priv(netdev);
 
-	ib_get_device_fw_str(priv->ca, drvinfo->fw_version,
-			     sizeof(drvinfo->fw_version));
+	ib_get_device_fw_str(priv->ca, drvinfo->fw_version);
 
 	strlcpy(drvinfo->bus_info, dev_name(priv->ca->dev.parent),
 		sizeof(drvinfo->bus_info));
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index b73120727d60..0ffc43562237 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -64,6 +64,8 @@
 #include <linux/cgroup_rdma.h>
 #include <uapi/rdma/ib_user_verbs.h>
 
+#define IB_FW_VERSION_NAME_MAX	ETHTOOL_FWVERS_LEN
+
 extern struct workqueue_struct *ib_wq;
 extern struct workqueue_struct *ib_comp_wq;
 
@@ -2246,7 +2248,7 @@ struct ib_device {
 	 * in fast paths.
 	 */
 	int (*get_port_immutable)(struct ib_device *, u8, struct ib_port_immutable *);
-	void (*get_dev_fw_str)(struct ib_device *, char *str, size_t str_len);
+	void (*get_dev_fw_str)(struct ib_device *, char *str);
 };
 
 struct ib_client {
@@ -2282,7 +2284,7 @@ struct ib_client {
 struct ib_device *ib_alloc_device(size_t size);
 void ib_dealloc_device(struct ib_device *device);
 
-void ib_get_device_fw_str(struct ib_device *device, char *str, size_t str_len);
+void ib_get_device_fw_str(struct ib_device *device, char *str);
 
 int ib_register_device(struct ib_device *device,
 		       int (*port_callback)(struct ib_device *,
-- 
2.13.2
