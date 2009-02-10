From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH net-next 4/4] enic: misc
Date: Mon, 09 Feb 2009 16:57:28 -0800
Message-ID: <20090210005727.24315.46206.stgit@palito_client100.nuovasystems.com>
References: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:61391 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbZBJA52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 19:57:28 -0500
Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id n1A0vS1T013073
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 16:57:28 -0800
Received: from palito_client100.nuovasystems.com (savbu-palito-client100.cisco.com [10.193.70.13])
	by sj-core-2.cisco.com (8.13.8/8.13.8) with ESMTP id n1A0vS5d000993
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 00:57:28 GMT
In-Reply-To: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: misc

Misc change to add api for link down count and to get firmware notification status.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c   |    2 --
 drivers/net/enic/vnic_dev.c    |   33 +++++++++++++++++++++++++++++----
 drivers/net/enic/vnic_dev.h    |    2 ++
 drivers/net/enic/vnic_devcmd.h |    8 +++++++-
 4 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 4da1e35..6c59d76 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1866,7 +1866,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-
 	enic->csum_rx_enabled = ENIC_SETTING(enic, RXCSUM);
 
 	enic->lro_mgr.max_aggr = ENIC_LRO_MAX_AGGR;
@@ -1878,7 +1877,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->lro_mgr.ip_summed = CHECKSUM_COMPLETE;
 	enic->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 
-
 	err = register_netdev(netdev);
 	if (err) {
 		printk(KERN_ERR PFX
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 1170857..e21b9d6 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -34,6 +34,9 @@ struct vnic_res {
 	unsigned int count;
 };
 
+#define VNIC_DEV_CAP_INIT	0x0001
+#define VNIC_DEV_CAP_PERBI	0x0002
+
 struct vnic_dev {
 	void *priv;
 	struct pci_dev *pdev;
@@ -50,6 +53,7 @@ struct vnic_dev {
 	dma_addr_t stats_pa;
 	struct vnic_devcmd_fw_info *fw_info;
 	dma_addr_t fw_info_pa;
+	u32 cap_flags;
 };
 
 #define VNIC_MAX_RES_HDR_SIZE \
@@ -575,9 +579,9 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 {
 	u64 a0 = (u32)arg, a1 = 0;
 	int wait = 1000;
-        int r = 0;
+	int r = 0;
 
-	if (vnic_dev_capable(vdev, CMD_INIT))
+	if (vdev->cap_flags & VNIC_DEV_CAP_INIT)
 		r = vnic_dev_cmd(vdev, CMD_INIT, &a0, &a1, wait);
 	else {
 		vnic_dev_cmd(vdev, CMD_INIT_v1, &a0, &a1, wait);
@@ -587,8 +591,8 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 			vnic_dev_cmd(vdev, CMD_MAC_ADDR, &a0, &a1, wait);
 			vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 		}
-        }
-        return r;
+	}
+	return r;
 }
 
 int vnic_dev_link_status(struct vnic_dev *vdev)
@@ -626,6 +630,22 @@ u32 vnic_dev_mtu(struct vnic_dev *vdev)
 	return vdev->notify_copy.mtu;
 }
 
+u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev)
+{
+	if (!vnic_dev_notify_ready(vdev))
+		return 0;
+
+	return vdev->notify_copy.link_down_cnt;
+}
+
+u32 vnic_dev_notify_status(struct vnic_dev *vdev)
+{
+	if (!vnic_dev_notify_ready(vdev))
+		return 0;
+
+	return vdev->notify_copy.status;
+}
+
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 	enum vnic_dev_intr_mode intr_mode)
 {
@@ -682,6 +702,11 @@ struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	if (!vdev->devcmd)
 		goto err_out;
 
+	vdev->cap_flags = 0;
+
+	if (vnic_dev_capable(vdev, CMD_INIT))
+		vdev->cap_flags |= VNIC_DEV_CAP_INIT;
+
 	return vdev;
 
 err_out:
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index b9dc182..8aa8db2 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -102,6 +102,8 @@ int vnic_dev_link_status(struct vnic_dev *vdev);
 u32 vnic_dev_port_speed(struct vnic_dev *vdev);
 u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
 u32 vnic_dev_mtu(struct vnic_dev *vdev);
+u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev);
+u32 vnic_dev_notify_status(struct vnic_dev *vdev);
 int vnic_dev_close(struct vnic_dev *vdev);
 int vnic_dev_enable(struct vnic_dev *vdev);
 int vnic_dev_disable(struct vnic_dev *vdev);
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index 8062c75..2587f34 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -191,7 +191,7 @@ enum vnic_devcmd_cmd {
 	CMD_INIT_STATUS		= _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 31),
 
 	/* INT13 API: (u64)a0=paddr to vnic_int13_params struct
-	 *            (u8)a1=INT13_CMD_xxx */
+	 *            (u32)a1=INT13_CMD_xxx */
 	CMD_INT13               = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_FC, 32),
 
 	/* logical uplink enable/disable: (u64)a0: 0/1=disable/enable */
@@ -207,6 +207,11 @@ enum vnic_devcmd_cmd {
 	 * in:  (u32)a0=cmd
 	 * out: (u32)a0=errno, 0:valid cmd, a1=supported VNIC_STF_* bits */
 	CMD_CAPABILITY		= _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 36),
+
+	/* persistent binding info
+	 * in:  (u64)a0=paddr of arg
+	 *      (u32)a1=CMD_PERBI_XXX */
+	CMD_PERBI               = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_FC, 37),
 };
 
 /* flags for CMD_OPEN */
@@ -259,6 +264,7 @@ struct vnic_devcmd_notify {
 	u32 status;		/* status bits (see VNIC_STF_*) */
 	u32 error;		/* error code (see ERR_*) for first ERR */
 	u32 link_down_cnt;	/* running count of link down transitions */
+	u32 perbi_rebuild_cnt;	/* running count of perbi rebuilds */
 };
 #define VNIC_STF_FATAL_ERR	0x0001	/* fatal fw error */
 #define VNIC_STF_STD_PAUSE	0x0002	/* standard link-level pause on */

