From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/3] enic: Helper code for SRIOV proxy commands
Date: Thu, 22 Sep 2011 06:44:38 -0700
Message-ID: <20110922134438.2145.76057.stgit@savbu-pc100.cisco.com>
References: <20110922134410.2145.72210.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:12959 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab1IVNoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 09:44:38 -0400
In-Reply-To: <20110922134410.2145.72210.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds helper functions to use PF as proxy for SRIOV VF firmware
commands.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |    1 +
 drivers/net/ethernet/cisco/enic/enic_dev.h  |   19 ++++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c |    9 +++++++++
 drivers/net/ethernet/cisco/enic/vnic_dev.c  |   28 ++++++++++++++++++++++-----
 drivers/net/ethernet/cisco/enic/vnic_dev.h  |    2 ++
 5 files changed, 54 insertions(+), 5 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 13ff78e..8c5cfb5 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -129,5 +129,6 @@ static inline struct device *enic_get_dev(struct enic *enic)
 
 void enic_reset_addr_lists(struct enic *enic);
 int enic_sriov_enabled(struct enic *enic);
+int enic_is_valid_vf(struct enic *enic, int vf);
 
 #endif /* _ENIC_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
index ff8e87f..1f83a47 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.h
@@ -19,6 +19,25 @@
 #ifndef _ENIC_DEV_H_
 #define _ENIC_DEV_H_
 
+#include "vnic_dev.h"
+
+/*
+ * Calls the devcmd function given by argument vnicdevcmdfn.
+ * If vf argument is valid, it proxies the devcmd
+ */
+#define ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnicdevcmdfn, ...) \
+	do { \
+		spin_lock(&enic->devcmd_lock); \
+		if (enic_is_valid_vf(enic, vf)) { \
+			vnic_dev_cmd_proxy_by_index_start(enic->vdev, vf); \
+			err = vnicdevcmdfn(enic->vdev, ##__VA_ARGS__); \
+			vnic_dev_cmd_proxy_end(enic->vdev); \
+		} else { \
+			err = vnicdevcmdfn(enic->vdev, ##__VA_ARGS__); \
+		} \
+		spin_unlock(&enic->devcmd_lock); \
+	} while (0)
+
 int enic_dev_fw_info(struct enic *enic, struct vnic_devcmd_fw_info **fw_info);
 int enic_dev_stats_dump(struct enic *enic, struct vnic_stats **vstats);
 int enic_dev_add_station_addr(struct enic *enic);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ad6580e..154cb99 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -132,6 +132,15 @@ int enic_sriov_enabled(struct enic *enic)
 	return (enic->priv_flags & ENIC_SRIOV_ENABLED) ? 1 : 0;
 }
 
+int enic_is_valid_vf(struct enic *enic, int vf)
+{
+#ifdef CONFIG_PCI_IOV
+	return vf >= 0 && vf < enic->num_vfs;
+#else
+	return 0;
+#endif
+}
+
 static inline unsigned int enic_cq_rq(struct enic *enic, unsigned int rq)
 {
 	return rq;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 8c4c8cf..31e7f9b 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -32,6 +32,7 @@
 enum vnic_proxy_type {
 	PROXY_NONE,
 	PROXY_BY_BDF,
+	PROXY_BY_INDEX,
 };
 
 struct vnic_res {
@@ -328,20 +329,21 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	return -ETIMEDOUT;
 }
 
-static int vnic_dev_cmd_proxy_by_bdf(struct vnic_dev *vdev,
-	enum vnic_devcmd_cmd cmd, u64 *a0, u64 *a1, int wait)
+static int vnic_dev_cmd_proxy(struct vnic_dev *vdev,
+	enum vnic_devcmd_cmd proxy_cmd, enum vnic_devcmd_cmd cmd,
+	u64 *a0, u64 *a1, int wait)
 {
 	u32 status;
 	int err;
 
 	memset(vdev->args, 0, sizeof(vdev->args));
 
-	vdev->args[0] = vdev->proxy_index; /* bdf */
+	vdev->args[0] = vdev->proxy_index;
 	vdev->args[1] = cmd;
 	vdev->args[2] = *a0;
 	vdev->args[3] = *a1;
 
-	err = _vnic_dev_cmd(vdev, CMD_PROXY_BY_BDF, wait);
+	err = _vnic_dev_cmd(vdev, proxy_cmd, wait);
 	if (err)
 		return err;
 
@@ -376,14 +378,30 @@ static int vnic_dev_cmd_no_proxy(struct vnic_dev *vdev,
 	return err;
 }
 
+void vnic_dev_cmd_proxy_by_index_start(struct vnic_dev *vdev, u16 index)
+{
+	vdev->proxy = PROXY_BY_INDEX;
+	vdev->proxy_index = index;
+}
+
+void vnic_dev_cmd_proxy_end(struct vnic_dev *vdev)
+{
+	vdev->proxy = PROXY_NONE;
+	vdev->proxy_index = 0;
+}
+
 int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait)
 {
 	memset(vdev->args, 0, sizeof(vdev->args));
 
 	switch (vdev->proxy) {
+	case PROXY_BY_INDEX:
+		return vnic_dev_cmd_proxy(vdev, CMD_PROXY_BY_INDEX, cmd,
+				a0, a1, wait);
 	case PROXY_BY_BDF:
-		return vnic_dev_cmd_proxy_by_bdf(vdev, cmd, a0, a1, wait);
+		return vnic_dev_cmd_proxy(vdev, CMD_PROXY_BY_BDF, cmd,
+				a0, a1, wait);
 	case PROXY_NONE:
 	default:
 		return vnic_dev_cmd_no_proxy(vdev, cmd, a0, a1, wait);
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index 852b698..6a138b6 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -85,6 +85,8 @@ void vnic_dev_free_desc_ring(struct vnic_dev *vdev,
 	struct vnic_dev_ring *ring);
 int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait);
+void vnic_dev_cmd_proxy_by_index_start(struct vnic_dev *vdev, u16 index);
+void vnic_dev_cmd_proxy_end(struct vnic_dev *vdev);
 int vnic_dev_fw_info(struct vnic_dev *vdev,
 	struct vnic_devcmd_fw_info **fw_info);
 int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
