From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 06/10] enic: Add new firmware devcmds
Date: Thu, 24 Jun 2010 13:51:43 -0700
Message-ID: <20100624205101.22595.92093.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:23688 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab0FXUvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:51:44 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Add new firmware devcmds - CMD_PROXY_BY_BDF, CMD_PACKET_FILTER_ALL,
CMD_ENABLE_WAIT.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/vnic_dev.c    |  136 +++++++++++++++++++++++++++++++++++++---
 drivers/net/enic/vnic_dev.h    |    5 +
 drivers/net/enic/vnic_devcmd.h |   14 ++++
 3 files changed, 146 insertions(+), 9 deletions(-)

diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 042f4b8..180912f 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -30,6 +30,11 @@
 #include "vnic_dev.h"
 #include "vnic_stats.h"
 
+enum vnic_proxy_type {
+	PROXY_NONE,
+	PROXY_BY_BDF,
+};
+
 struct vnic_res {
 	void __iomem *vaddr;
 	dma_addr_t bus_addr;
@@ -55,6 +60,9 @@ struct vnic_dev {
 	struct vnic_devcmd_fw_info *fw_info;
 	dma_addr_t fw_info_pa;
 	u32 cap_flags;
+	enum vnic_proxy_type proxy;
+	u32 proxy_index;
+	u64 args[VNIC_DEVCMD_NARGS];
 };
 
 #define VNIC_MAX_RES_HDR_SIZE \
@@ -257,10 +265,11 @@ void vnic_dev_free_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring)
 	}
 }
 
-int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
-	u64 *a0, u64 *a1, int wait)
+static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
+	int wait)
 {
 	struct vnic_devcmd __iomem *devcmd = vdev->devcmd;
+	unsigned int i;
 	int delay;
 	u32 status;
 	int err;
@@ -272,8 +281,8 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	}
 
 	if (_CMD_DIR(cmd) & _CMD_DIR_WRITE) {
-		writeq(*a0, &devcmd->args[0]);
-		writeq(*a1, &devcmd->args[1]);
+		for (i = 0; i < VNIC_DEVCMD_NARGS; i++)
+			writeq(vdev->args[i], &devcmd->args[i]);
 		wmb();
 	}
 
@@ -287,6 +296,7 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		udelay(100);
 
 		status = ioread32(&devcmd->status);
+
 		if (!(status & STAT_BUSY)) {
 
 			if (status & STAT_ERROR) {
@@ -300,8 +310,8 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 
 			if (_CMD_DIR(cmd) & _CMD_DIR_READ) {
 				rmb();
-				*a0 = readq(&devcmd->args[0]);
-				*a1 = readq(&devcmd->args[1]);
+				for (i = 0; i < VNIC_DEVCMD_NARGS; i++)
+					vdev->args[i] = readq(&devcmd->args[i]);
 			}
 
 			return 0;
@@ -312,6 +322,80 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	return -ETIMEDOUT;
 }
 
+static int vnic_dev_cmd_proxy_by_bdf(struct vnic_dev *vdev,
+	enum vnic_devcmd_cmd cmd, u64 *a0, u64 *a1, int wait)
+{
+	u32 status;
+	int err;
+
+	memset(vdev->args, 0, sizeof(vdev->args));
+
+	vdev->args[0] = vdev->proxy_index; /* bdf */
+	vdev->args[1] = cmd;
+	vdev->args[2] = *a0;
+	vdev->args[3] = *a1;
+
+	err = _vnic_dev_cmd(vdev, CMD_PROXY_BY_BDF, wait);
+	if (err)
+		return err;
+
+	status = (u32)vdev->args[0];
+	if (status & STAT_ERROR) {
+		err = (int)vdev->args[1];
+		if (err != ERR_ECMDUNKNOWN ||
+		    cmd != CMD_CAPABILITY)
+			pr_err("Error %d proxy devcmd %d\n", err, _CMD_N(cmd));
+		return err;
+	}
+
+	*a0 = vdev->args[1];
+	*a1 = vdev->args[2];
+
+	return 0;
+}
+
+static int vnic_dev_cmd_no_proxy(struct vnic_dev *vdev,
+	enum vnic_devcmd_cmd cmd, u64 *a0, u64 *a1, int wait)
+{
+	int err;
+
+	vdev->args[0] = *a0;
+	vdev->args[1] = *a1;
+
+	err = _vnic_dev_cmd(vdev, cmd, wait);
+
+	*a0 = vdev->args[0];
+	*a1 = vdev->args[1];
+
+	return err;
+}
+
+void vnic_dev_cmd_proxy_by_bdf_start(struct vnic_dev *vdev, u16 bdf)
+{
+	vdev->proxy = PROXY_BY_BDF;
+	vdev->proxy_index = bdf;
+}
+
+void vnic_dev_cmd_proxy_end(struct vnic_dev *vdev)
+{
+	vdev->proxy = PROXY_NONE;
+	vdev->proxy_index = 0;
+}
+
+int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
+	u64 *a0, u64 *a1, int wait)
+{
+	memset(vdev->args, 0, sizeof(vdev->args));
+
+	switch (vdev->proxy) {
+	case PROXY_BY_BDF:
+		return vnic_dev_cmd_proxy_by_bdf(vdev, cmd, a0, a1, wait);
+	case PROXY_NONE:
+	default:
+		return vnic_dev_cmd_no_proxy(vdev, cmd, a0, a1, wait);
+	}
+}
+
 static int vnic_dev_capable(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd)
 {
 	u64 a0 = (u32)cmd, a1 = 0;
@@ -430,6 +514,19 @@ int vnic_dev_enable(struct vnic_dev *vdev)
 	return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
 }
 
+int vnic_dev_enable_wait(struct vnic_dev *vdev)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	err = vnic_dev_cmd(vdev, CMD_ENABLE_WAIT, &a0, &a1, wait);
+	if (err == ERR_ECMDUNKNOWN)
+		return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
+
+	return err;
+}
+
 int vnic_dev_disable(struct vnic_dev *vdev)
 {
 	u64 a0 = 0, a1 = 0;
@@ -569,6 +666,26 @@ int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	return err;
 }
 
+int vnic_dev_packet_filter_all(struct vnic_dev *vdev, int directed,
+	int multicast, int broadcast, int promisc, int allmulti)
+{
+	u64 a0, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	a0 = (directed ? CMD_PFILTER_DIRECTED : 0) |
+	     (multicast ? CMD_PFILTER_MULTICAST : 0) |
+	     (broadcast ? CMD_PFILTER_BROADCAST : 0) |
+	     (promisc ? CMD_PFILTER_PROMISCUOUS : 0) |
+	     (allmulti ? CMD_PFILTER_ALL_MULTICAST : 0);
+
+	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER_ALL, &a0, &a1, wait);
+	if (err)
+		pr_err("Can't set packet filter\n");
+
+	return err;
+}
+
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
 {
 	u64 a0 = 0, a1 = 0;
@@ -731,8 +848,9 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 	else {
 		vnic_dev_cmd(vdev, CMD_INIT_v1, &a0, &a1, wait);
 		if (a0 & CMD_INITF_DEFAULT_MAC) {
-			// Emulate these for old CMD_INIT_v1 which
-			// didn't pass a0 so no CMD_INITF_*.
+			/* Emulate these for old CMD_INIT_v1 which
+			 * didn't pass a0 so no CMD_INITF_*.
+			 */
 			vnic_dev_cmd(vdev, CMD_MAC_ADDR, &a0, &a1, wait);
 			vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 		}
@@ -754,7 +872,7 @@ int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err)
 
 	*done = (a0 == 0);
 
-	*err = (a0 == 0) ? a1 : 0;
+	*err = (a0 == 0) ? (int)a1:0;
 
 	return 0;
 }
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 11659c6..cfdaa69 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -95,6 +95,8 @@ void vnic_dev_free_desc_ring(struct vnic_dev *vdev,
 	struct vnic_dev_ring *ring);
 int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait);
+void vnic_dev_cmd_proxy_by_bdf_start(struct vnic_dev *vdev, u16 bdf);
+void vnic_dev_cmd_proxy_end(struct vnic_dev *vdev);
 int vnic_dev_fw_info(struct vnic_dev *vdev,
 	struct vnic_devcmd_fw_info **fw_info);
 int vnic_dev_hw_version(struct vnic_dev *vdev,
@@ -106,6 +108,8 @@ int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
 int vnic_dev_hang_notify(struct vnic_dev *vdev);
 int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	int broadcast, int promisc, int allmulti);
+int vnic_dev_packet_filter_all(struct vnic_dev *vdev, int directed,
+	int multicast, int broadcast, int promisc, int allmulti);
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
@@ -124,6 +128,7 @@ u32 vnic_dev_notify_status(struct vnic_dev *vdev);
 u32 vnic_dev_uif(struct vnic_dev *vdev);
 int vnic_dev_close(struct vnic_dev *vdev);
 int vnic_dev_enable(struct vnic_dev *vdev);
+int vnic_dev_enable_wait(struct vnic_dev *vdev);
 int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index 1c4fb35..e6c80c7 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -98,6 +98,9 @@ enum vnic_devcmd_cmd {
 	/* set Rx packet filter: (u32)a0=filters (see CMD_PFILTER_*) */
 	CMD_PACKET_FILTER	= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 7),
 
+	/* set Rx packet filter for all: (u32)a0=filters (see CMD_PFILTER_*) */
+	CMD_PACKET_FILTER_ALL   = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 7),
+
 	/* hang detection notification */
 	CMD_HANG_NOTIFY         = _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 8),
 
@@ -171,6 +174,9 @@ enum vnic_devcmd_cmd {
 	/* enable virtual link */
 	CMD_ENABLE		= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 28),
 
+	/* enable virtual link, waiting variant. */
+	CMD_ENABLE_WAIT		= _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 28),
+
 	/* disable virtual link */
 	CMD_DISABLE		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 29),
 
@@ -224,6 +230,14 @@ enum vnic_devcmd_cmd {
 	 * in:  (u32)a0=new vlan rewrite mode
 	 * out: (u32)a0=old vlan rewrite mode */
 	CMD_IG_VLAN_REWRITE_MODE = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ENET, 41),
+
+	/*
+	 * in:  (u16)a0=bdf of target vnic
+	 *      (u32)a1=cmd to proxy
+	 *      a2-a15=args to cmd in a1
+	 * out: (u32)a0=status of proxied cmd
+	 *      a1-a15=out args of proxied cmd */
+	CMD_PROXY_BY_BDF =	_CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 42),
 };
 
 /* flags for CMD_OPEN */

