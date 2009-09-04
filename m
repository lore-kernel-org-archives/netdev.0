From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 09/11] enic: changes to driver/firmware interface
Date: Thu, 03 Sep 2009 20:02:35 -0700
Message-ID: <20090904030234.5047.59369.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6569 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932779AbZIDDCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:02:32 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: changes to driver/firmware interface

Deprecate some old APIa; change arguments to stats dump all API; add new
interrupt assert API

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/vnic_dev.c    |   14 ++++++++++++++
 drivers/net/enic/vnic_dev.h    |    1 +
 drivers/net/enic/vnic_devcmd.h |   20 ++++++++++----------
 drivers/net/enic/vnic_intr.c   |    5 +++++
 4 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index c8d3fc7..29a48e8 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -560,6 +560,20 @@ void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
 		printk(KERN_ERR "Can't del addr [%pM], %d\n", addr, err);
 }
 
+int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr)
+{
+	u64 a0 = intr, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	err = vnic_dev_cmd(vdev, CMD_IAR, &a0, &a1, wait);
+	if (err)
+		printk(KERN_ERR "Failed to raise INTR[%d], err %d\n",
+			intr, err);
+
+	return err;
+}
+
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 {
 	u64 a0, a1;
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index db1d63e..fc5e3eb 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -106,6 +106,7 @@ void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
+int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr);
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
 void vnic_dev_notify_unset(struct vnic_dev *vdev);
 int vnic_dev_link_status(struct vnic_dev *vdev);
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index 2587f34..d78bbcc 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -105,14 +105,6 @@ enum vnic_devcmd_cmd {
 	CMD_MAC_ADDR            = _CMDC(_CMD_DIR_READ,
 					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 9),
 
-	/* disable/enable promisc mode: (u8)a0=0/1 */
-/***** XXX DEPRECATED *****/
-	CMD_PROMISC_MODE        = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 10),
-
-	/* disable/enable all-multi mode: (u8)a0=0/1 */
-/***** XXX DEPRECATED *****/
-	CMD_ALLMULTI_MODE       = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 11),
-
 	/* add addr from (u48)a0 */
 	CMD_ADDR_ADD            = _CMDCNW(_CMD_DIR_WRITE,
 					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 12),
@@ -182,7 +174,9 @@ enum vnic_devcmd_cmd {
 	/* disable virtual link */
 	CMD_DISABLE		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 29),
 
-	/* stats dump all vnics on uplink in mem: (u64)a0=paddr (u32)a1=uif */
+	/* stats dump sum of all vnic stats on same uplink in mem:
+	 *     (u64)a0=paddr
+	 *     (u16)a1=sizeof stats area */
 	CMD_STATS_DUMP_ALL	= _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 30),
 
 	/* init status:
@@ -211,7 +205,12 @@ enum vnic_devcmd_cmd {
 	/* persistent binding info
 	 * in:  (u64)a0=paddr of arg
 	 *      (u32)a1=CMD_PERBI_XXX */
-	CMD_PERBI               = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_FC, 37),
+	CMD_PERBI		= _CMDC(_CMD_DIR_RW, _CMD_VTYPE_FC, 37),
+
+	/* Interrupt Assert Register functionality
+	 * in: (u16)a0=interrupt number to assert
+	 */
+	CMD_IAR			= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 38),
 };
 
 /* flags for CMD_OPEN */
@@ -244,6 +243,7 @@ enum vnic_devcmd_error {
 	ERR_ENOMEM = 7,
 	ERR_ETIMEDOUT = 8,
 	ERR_ELINKDOWN = 9,
+	ERR_EMAXRES = 10,
 };
 
 struct vnic_devcmd_fw_info {
diff --git a/drivers/net/enic/vnic_intr.c b/drivers/net/enic/vnic_intr.c
index ddc38f8..1f8786d 100644
--- a/drivers/net/enic/vnic_intr.c
+++ b/drivers/net/enic/vnic_intr.c
@@ -60,3 +60,8 @@ void vnic_intr_clean(struct vnic_intr *intr)
 {
 	iowrite32(0, &intr->ctrl->int_credits);
 }
+
+void vnic_intr_raise(struct vnic_intr *intr)
+{
+	vnic_dev_raise_intr(intr->vdev, (u16)intr->index);
+}

