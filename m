From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 03/10] enic: Use a lighter reset operation for
	enic devices
Date: Thu, 24 Jun 2010 13:50:00 -0700
Message-ID: <20100624204956.22595.3695.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:12720 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755775Ab0FXUuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:50:01 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

The port profile information for a dynamic enic device is set by the upper
layers, that are oblivious to the device reset operation. We do not want a
reset operation erase the network state of a dynamic enic device as there
is no way to set up the port profile information again. Hence a lighter
reset operation called hang reset is used. Hang reset, unlike soft reset
does not reset the network state and resets the host side state only.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/enic_main.c   |   16 ++++++++--------
 drivers/net/enic/vnic_dev.c    |   38 ++++++++++++++++++++++++++++++++++++++
 drivers/net/enic/vnic_dev.h    |    2 ++
 drivers/net/enic/vnic_devcmd.h |    7 +++++++
 4 files changed, 55 insertions(+), 8 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 7f98af1..d7434b7 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -812,9 +812,10 @@ static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 	return net_stats;
 }
 
-static void enic_reset_mcaddrs(struct enic *enic)
+static void enic_reset_multicast_list(struct enic *enic)
 {
 	enic->mc_count = 0;
+	enic->flags = 0;
 }
 
 static int enic_set_mac_addr(struct net_device *netdev, char *addr)
@@ -1847,15 +1848,15 @@ static int enic_dev_open(struct enic *enic)
 	return err;
 }
 
-static int enic_dev_soft_reset(struct enic *enic)
+static int enic_dev_hang_reset(struct enic *enic)
 {
 	int err;
 
-	err = enic_dev_wait(enic->vdev, vnic_dev_soft_reset,
-		vnic_dev_soft_reset_done, 0);
+	err = enic_dev_wait(enic->vdev, vnic_dev_hang_reset,
+		vnic_dev_hang_reset_done, 0);
 	if (err)
 		printk(KERN_ERR PFX
-			"vNIC soft reset failed, err %d.\n", err);
+			"vNIC hang reset failed, err %d.\n", err);
 
 	return err;
 }
@@ -1906,9 +1907,8 @@ static void enic_reset(struct work_struct *work)
 	spin_unlock(&enic->devcmd_lock);
 
 	enic_stop(enic->netdev);
-	enic_dev_soft_reset(enic);
-	vnic_dev_init(enic->vdev, 0);
-	enic_reset_mcaddrs(enic);
+	enic_dev_hang_reset(enic);
+	enic_reset_multicast_list(enic);
 	enic_init_vnic_resources(enic);
 	enic_set_niccfg(enic);
 	enic_dev_set_ig_vlan_rewrite_mode(enic);
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index e3742fa..c93012f 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -486,6 +486,44 @@ int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
 	return 0;
 }
 
+int vnic_dev_hang_reset(struct vnic_dev *vdev, int arg)
+{
+	u64 a0 = (u32)arg, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	err = vnic_dev_cmd(vdev, CMD_HANG_RESET, &a0, &a1, wait);
+	if (err == ERR_ECMDUNKNOWN) {
+		err = vnic_dev_soft_reset(vdev, arg);
+		if (err)
+			return err;
+
+		return vnic_dev_init(vdev, 0);
+	}
+
+	return err;
+}
+
+int vnic_dev_hang_reset_done(struct vnic_dev *vdev, int *done)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	*done = 0;
+
+	err = vnic_dev_cmd(vdev, CMD_HANG_RESET_STATUS, &a0, &a1, wait);
+	if (err) {
+		if (err == ERR_ECMDUNKNOWN)
+			return vnic_dev_soft_reset_done(vdev, done);
+		return err;
+	}
+
+	*done = (a0 == 0);
+
+	return 0;
+}
+
 int vnic_dev_hang_notify(struct vnic_dev *vdev)
 {
 	u64 a0, a1;
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 780c3cd..4980615 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -129,6 +129,8 @@ int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len);
 int vnic_dev_deinit(struct vnic_dev *vdev);
 int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg);
 int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done);
+int vnic_dev_hang_reset(struct vnic_dev *vdev, int arg);
+int vnic_dev_hang_reset_done(struct vnic_dev *vdev, int *done);
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 	enum vnic_dev_intr_mode intr_mode);
 enum vnic_dev_intr_mode vnic_dev_get_intr_mode(struct vnic_dev *vdev);
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index c5ff4ff..1c4fb35 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -212,6 +212,13 @@ enum vnic_devcmd_cmd {
 	 */
 	CMD_IAR			= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 38),
 
+	/* initiate hangreset, like softreset after hang detected */
+	CMD_HANG_RESET		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 39),
+
+	/* hangreset status:
+	 *    out: a0=0 reset complete, a0=1 reset in progress */
+	CMD_HANG_RESET_STATUS   = _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 40),
+
 	/*
 	 * Set hw ingress packet vlan rewrite mode:
 	 * in:  (u32)a0=new vlan rewrite mode

