From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 2/5] enic: driver/firmware API updates
Date: Fri, 21 Nov 2008 16:34:02 -0800
Message-ID: <20081122003402.15540.44659.stgit@palito_client100.nuovasystems.com>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:3254 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbYKVAlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:41:36 -0500
In-Reply-To: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: driver/firmware API updates

Add driver/firmware compatibility check.
Update firmware notify cmd to honor notify area size.
Add new version of init cmd.
Add link_down_cnt to notify area to track link down count.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/vnic_dev.c    |   60 ++++++++++++++++++++++++++++------------
 drivers/net/enic/vnic_devcmd.h |   19 ++++++++++++-
 2 files changed, 60 insertions(+), 19 deletions(-)

diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 4d104f5..4a537d1 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -43,6 +43,7 @@ struct vnic_dev {
 	struct vnic_devcmd_notify *notify;
 	struct vnic_devcmd_notify notify_copy;
 	dma_addr_t notify_pa;
+	u32 notify_sz;
 	u32 *linkstatus;
 	dma_addr_t linkstatus_pa;
 	struct vnic_stats *stats;
@@ -235,14 +236,6 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	struct vnic_devcmd __iomem *devcmd = vdev->devcmd;
 	int delay;
 	u32 status;
-	int dev_cmd_err[] = {
-		/* convert from fw's version of error.h to host's version */
-		0,	/* ERR_SUCCESS */
-		EINVAL,	/* ERR_EINVAL */
-		EFAULT,	/* ERR_EFAULT */
-		EPERM,	/* ERR_EPERM */
-		EBUSY,  /* ERR_EBUSY */
-	};
 	int err;
 
 	status = ioread32(&devcmd->status);
@@ -270,10 +263,12 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		if (!(status & STAT_BUSY)) {
 
 			if (status & STAT_ERROR) {
-				err = dev_cmd_err[(int)readq(&devcmd->args[0])];
-				printk(KERN_ERR "Error %d devcmd %d\n",
-					err, _CMD_N(cmd));
-				return -err;
+				err = (int)readq(&devcmd->args[0]);
+				if (err != ERR_ECMDUNKNOWN ||
+				    cmd != CMD_CAPABILITY)
+					printk(KERN_ERR "Error %d devcmd %d\n",
+						err, _CMD_N(cmd));
+				return err;
 			}
 
 			if (_CMD_DIR(cmd) & _CMD_DIR_READ) {
@@ -290,6 +285,17 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	return -ETIMEDOUT;
 }
 
+int vnic_dev_capable(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd)
+{
+	u64 a0 = (u32)cmd, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	err = vnic_dev_cmd(vdev, CMD_CAPABILITY, &a0, &a1, wait);
+
+	return !(err || a0);
+}
+
 int vnic_dev_fw_info(struct vnic_dev *vdev,
 	struct vnic_devcmd_fw_info **fw_info)
 {
@@ -517,6 +523,7 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 {
 	u64 a0, a1;
 	int wait = 1000;
+	int r;
 
 	if (!vdev->notify) {
 		vdev->notify = pci_alloc_consistent(vdev->pdev,
@@ -524,13 +531,16 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 			&vdev->notify_pa);
 		if (!vdev->notify)
 			return -ENOMEM;
+		memset(vdev->notify, 0, sizeof(struct vnic_devcmd_notify));
 	}
 
 	a0 = vdev->notify_pa;
 	a1 = ((u64)intr << 32) & 0x0000ffff00000000ULL;
 	a1 += sizeof(struct vnic_devcmd_notify);
 
-	return vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
+	r = vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
+	vdev->notify_sz = (r == 0) ? (u32)a1 : 0;
+	return r;
 }
 
 void vnic_dev_notify_unset(struct vnic_dev *vdev)
@@ -543,22 +553,22 @@ void vnic_dev_notify_unset(struct vnic_dev *vdev)
 	a1 += sizeof(struct vnic_devcmd_notify);
 
 	vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
+	vdev->notify_sz = 0;
 }
 
 static int vnic_dev_notify_ready(struct vnic_dev *vdev)
 {
 	u32 *words;
-	unsigned int nwords = sizeof(struct vnic_devcmd_notify) / 4;
+	unsigned int nwords = vdev->notify_sz / 4;
 	unsigned int i;
 	u32 csum;
 
-	if (!vdev->notify)
+	if (!vdev->notify || !vdev->notify_sz)
 		return 0;
 
 	do {
 		csum = 0;
-		memcpy(&vdev->notify_copy, vdev->notify,
-			sizeof(struct vnic_devcmd_notify));
+		memcpy(&vdev->notify_copy, vdev->notify, vdev->notify_sz);
 		words = (u32 *)&vdev->notify_copy;
 		for (i = 1; i < nwords; i++)
 			csum += words[i];
@@ -571,7 +581,20 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 {
 	u64 a0 = (u32)arg, a1 = 0;
 	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_INIT, &a0, &a1, wait);
+        int r = 0;
+
+	if (vnic_dev_capable(vdev, CMD_INIT))
+		r = vnic_dev_cmd(vdev, CMD_INIT, &a0, &a1, wait);
+	else {
+		vnic_dev_cmd(vdev, CMD_INIT_v1, &a0, &a1, wait);
+		if (a0 & CMD_INITF_DEFAULT_MAC) {
+			// Emulate these for old CMD_INIT_v1 which
+			// didn't pass a0 so no CMD_INITF_*.
+			vnic_dev_cmd(vdev, CMD_MAC_ADDR, &a0, &a1, wait);
+			vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
+		}
+        }
+        return r;
 }
 
 int vnic_dev_link_status(struct vnic_dev *vdev)
@@ -672,3 +695,4 @@ err_out:
 	return NULL;
 }
 
+
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index d8617a3..8062c75 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -168,7 +168,8 @@ enum vnic_devcmd_cmd {
 	CMD_CLOSE		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 25),
 
 	/* initialize virtual link: (u32)a0=flags (see CMD_INITF_*) */
-	CMD_INIT		= _CMDCNW(_CMD_DIR_READ, _CMD_VTYPE_ALL, 26),
+/***** Replaced by CMD_INIT *****/
+	CMD_INIT_v1		= _CMDCNW(_CMD_DIR_READ, _CMD_VTYPE_ALL, 26),
 
 	/* variant of CMD_INIT, with provisioning info
 	 *     (u64)a0=paddr of vnic_devcmd_provinfo
@@ -198,6 +199,14 @@ enum vnic_devcmd_cmd {
 
 	/* undo initialize of virtual link */
 	CMD_DEINIT		= _CMDCNW(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 34),
+
+	/* initialize virtual link: (u32)a0=flags (see CMD_INITF_*) */
+	CMD_INIT		= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 35),
+
+	/* check fw capability of a cmd:
+	 * in:  (u32)a0=cmd
+	 * out: (u32)a0=errno, 0:valid cmd, a1=supported VNIC_STF_* bits */
+	CMD_CAPABILITY		= _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 36),
 };
 
 /* flags for CMD_OPEN */
@@ -249,8 +258,16 @@ struct vnic_devcmd_notify {
 	u32 uif;		/* uplink interface */
 	u32 status;		/* status bits (see VNIC_STF_*) */
 	u32 error;		/* error code (see ERR_*) for first ERR */
+	u32 link_down_cnt;	/* running count of link down transitions */
 };
 #define VNIC_STF_FATAL_ERR	0x0001	/* fatal fw error */
+#define VNIC_STF_STD_PAUSE	0x0002	/* standard link-level pause on */
+#define VNIC_STF_PFC_PAUSE	0x0004	/* priority flow control pause on */
+/* all supported status flags */
+#define VNIC_STF_ALL		(VNIC_STF_FATAL_ERR |\
+				 VNIC_STF_STD_PAUSE |\
+				 VNIC_STF_PFC_PAUSE |\
+				 0)
 
 struct vnic_devcmd_provinfo {
 	u8 oui[3];

