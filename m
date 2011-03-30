From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/4] enic: Add support for new fw devcmds for
	port profile handling
Date: Tue, 29 Mar 2011 23:35:51 -0700
Message-ID: <20110330063551.7187.5364.stgit@savbu-pc100.cisco.com>
References: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:14610 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217Ab1C3Gfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 02:35:52 -0400
In-Reply-To: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch introduces new fw devcmds for port profile handling.
These new commands are similar to the current fw commands for
port profile handling. The only difference being that the new
commands split the existing port profile handling devcmds into multiple
fw commands, giving the driver finer control over port profile operations.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/vnic_dev.c    |   97 +++++++++++++++++++++++-----------------
 drivers/net/enic/vnic_dev.h    |    6 ++
 drivers/net/enic/vnic_devcmd.h |   57 +++++++++++++++++++++---
 3 files changed, 111 insertions(+), 49 deletions(-)


diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index c089b36..68f24ae 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -786,48 +786,6 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 	return r;
 }
 
-int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	int ret;
-
-	*done = 0;
-
-	ret = vnic_dev_cmd(vdev, CMD_INIT_STATUS, &a0, &a1, wait);
-	if (ret)
-		return ret;
-
-	*done = (a0 == 0);
-
-	*err = (a0 == 0) ? (int)a1:0;
-
-	return 0;
-}
-
-int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len)
-{
-	u64 a0, a1 = len;
-	int wait = 1000;
-	dma_addr_t prov_pa;
-	void *prov_buf;
-	int ret;
-
-	prov_buf = pci_alloc_consistent(vdev->pdev, len, &prov_pa);
-	if (!prov_buf)
-		return -ENOMEM;
-
-	memcpy(prov_buf, buf, len);
-
-	a0 = prov_pa;
-
-	ret = vnic_dev_cmd(vdev, CMD_INIT_PROV_INFO, &a0, &a1, wait);
-
-	pci_free_consistent(vdev->pdev, len, prov_buf, prov_pa);
-
-	return ret;
-}
-
 int vnic_dev_deinit(struct vnic_dev *vdev)
 {
 	u64 a0 = 0, a1 = 0;
@@ -927,4 +885,59 @@ err_out:
 	return NULL;
 }
 
+int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len)
+{
+	u64 a0, a1 = len;
+	int wait = 1000;
+	dma_addr_t prov_pa;
+	void *prov_buf;
+	int ret;
+
+	prov_buf = pci_alloc_consistent(vdev->pdev, len, &prov_pa);
+	if (!prov_buf)
+		return -ENOMEM;
 
+	memcpy(prov_buf, buf, len);
+
+	a0 = prov_pa;
+
+	ret = vnic_dev_cmd(vdev, CMD_INIT_PROV_INFO2, &a0, &a1, wait);
+
+	pci_free_consistent(vdev->pdev, len, prov_buf, prov_pa);
+
+	return ret;
+}
+
+int vnic_dev_enable2(struct vnic_dev *vdev, int active)
+{
+	u64 a0, a1 = 0;
+	int wait = 1000;
+
+	a0 = (active ? CMD_ENABLE2_ACTIVE : 0);
+
+	return vnic_dev_cmd(vdev, CMD_ENABLE2, &a0, &a1, wait);
+}
+
+static int vnic_dev_cmd_status(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
+	int *status)
+{
+	u64 a0 = cmd, a1 = 0;
+	int wait = 1000;
+	int ret;
+
+	ret = vnic_dev_cmd(vdev, CMD_STATUS, &a0, &a1, wait);
+	if (!ret)
+		*status = (int)a0;
+
+	return ret;
+}
+
+int vnic_dev_enable2_done(struct vnic_dev *vdev, int *status)
+{
+	return vnic_dev_cmd_status(vdev, CMD_ENABLE2, status);
+}
+
+int vnic_dev_deinit_done(struct vnic_dev *vdev, int *status)
+{
+	return vnic_dev_cmd_status(vdev, CMD_DEINIT, status);
+}
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index e837546..cf482a2 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -108,8 +108,6 @@ int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
 int vnic_dev_init(struct vnic_dev *vdev, int arg);
-int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err);
-int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len);
 int vnic_dev_deinit(struct vnic_dev *vdev);
 int vnic_dev_hang_reset(struct vnic_dev *vdev, int arg);
 int vnic_dev_hang_reset_done(struct vnic_dev *vdev, int *done);
@@ -122,5 +120,9 @@ int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
 struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar,
 	unsigned int num_bars);
+int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len);
+int vnic_dev_enable2(struct vnic_dev *vdev, int active);
+int vnic_dev_enable2_done(struct vnic_dev *vdev, int *status);
+int vnic_dev_deinit_done(struct vnic_dev *vdev, int *status);
 
 #endif /* _VNIC_DEV_H_ */
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index d833a07..c5569bf 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -267,17 +267,62 @@ enum vnic_devcmd_cmd {
 
 	/*
 	 * As for BY_BDF except a0 is index of hvnlink subordinate vnic
-	 * or SR-IOV virtual vnic */
+	 * or SR-IOV virtual vnic
+	 */
 	CMD_PROXY_BY_INDEX =    _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 43),
 
 	/*
-	 * in:  (u64)a0=paddr of buffer to put latest VIC VIF-CONFIG-INFO TLV in
-	 *      (u32)a1=length of buffer in a0
-	 * out: (u64)a0=paddr of buffer with latest VIC VIF-CONFIG-INFO TLV
-	 *      (u32)a1=actual length of latest VIC VIF-CONFIG-INFO TLV */
+	 * For HPP toggle:
+	 * adapter-info-get
+	 * in:  (u64)a0=phsical address of buffer passed in from caller.
+	 *      (u16)a1=size of buffer specified in a0.
+	 * out: (u64)a0=phsical address of buffer passed in from caller.
+	 *      (u16)a1=actual bytes from VIF-CONFIG-INFO TLV, or
+	 *              0 if no VIF-CONFIG-INFO TLV was ever received. */
 	CMD_CONFIG_INFO_GET     = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 44),
+
+	/* init_prov_info2:
+	 * Variant of CMD_INIT_PROV_INFO, where it will not try to enable
+	 * the vnic until CMD_ENABLE2 is issued.
+	 *     (u64)a0=paddr of vnic_devcmd_provinfo
+	 *     (u32)a1=sizeof provision info */
+	CMD_INIT_PROV_INFO2  = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 47),
+
+	/* enable2:
+	 *      (u32)a0=0                  ==> standby
+	 *             =CMD_ENABLE2_ACTIVE ==> active
+	 */
+	CMD_ENABLE2 = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 48),
+
+	/*
+	 * cmd_status:
+	 *     Returns the status of the specified command
+	 * Input:
+	 *     a0 = command for which status is being queried.
+	 *          Possible values are:
+	 *              CMD_SOFT_RESET
+	 *              CMD_HANG_RESET
+	 *              CMD_OPEN
+	 *              CMD_INIT
+	 *              CMD_INIT_PROV_INFO
+	 *              CMD_DEINIT
+	 *              CMD_INIT_PROV_INFO2
+	 *              CMD_ENABLE2
+	 * Output:
+	 *     if status == STAT_ERROR
+	 *        a0 = ERR_ENOTSUPPORTED - status for command in a0 is
+	 *                                 not supported
+	 *     if status == STAT_NONE
+	 *        a0 = status of the devcmd specified in a0 as follows.
+	 *             ERR_SUCCESS   - command in a0 completed successfully
+	 *             ERR_EINPROGRESS - command in a0 is still in progress
+	 */
+	CMD_STATUS = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 49),
 };
 
+/* CMD_ENABLE2 flags */
+#define CMD_ENABLE2_ACTIVE  0x1
+
 /* flags for CMD_OPEN */
 #define CMD_OPENF_OPROM		0x1	/* open coming from option rom */
 
@@ -315,6 +360,8 @@ enum vnic_devcmd_error {
 	ERR_ETIMEDOUT = 8,
 	ERR_ELINKDOWN = 9,
 	ERR_EMAXRES = 10,
+	ERR_ENOTSUPPORTED = 11,
+	ERR_EINPROGRESS = 12,
 };
 
 /*

