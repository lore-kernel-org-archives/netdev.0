From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next PATCH 4/5] enic: Clean up: Add wrapper functions
Date: Thu, 18 Mar 2010 19:19:59 -0700
Message-ID: <20100319021959.10527.81432.stgit@savbu-pc100.cisco.com>
References: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:42826 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab0CSCT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 22:19:59 -0400
In-Reply-To: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Add wrapper functions vnic_dev_notify_setcmd and vnic_dev_notify_unsetcmd
for firmware notify commands.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/vnic_dev.c |   52 ++++++++++++++++++++++++++++++++++---------
 drivers/net/enic/vnic_dev.h |    3 ++
 2 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 69b9b70..cbc0ba9 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -573,22 +573,18 @@ int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr)
 	return err;
 }
 
-int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
+int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
+	void *notify_addr, dma_addr_t notify_pa, u16 intr)
 {
 	u64 a0, a1;
 	int wait = 1000;
 	int r;
 
-	if (!vdev->notify) {
-		vdev->notify = pci_alloc_consistent(vdev->pdev,
-			sizeof(struct vnic_devcmd_notify),
-			&vdev->notify_pa);
-		if (!vdev->notify)
-			return -ENOMEM;
-		memset(vdev->notify, 0, sizeof(struct vnic_devcmd_notify));
-	}
+	memset(notify_addr, 0, sizeof(struct vnic_devcmd_notify));
+	vdev->notify = notify_addr;
+	vdev->notify_pa = notify_pa;
 
-	a0 = vdev->notify_pa;
+	a0 = (u64)notify_pa;
 	a1 = ((u64)intr << 32) & 0x0000ffff00000000ULL;
 	a1 += sizeof(struct vnic_devcmd_notify);
 
@@ -597,7 +593,27 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 	return r;
 }
 
-void vnic_dev_notify_unset(struct vnic_dev *vdev)
+int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
+{
+	void *notify_addr;
+	dma_addr_t notify_pa;
+
+	if (vdev->notify || vdev->notify_pa) {
+		printk(KERN_ERR "notify block %p still allocated",
+			vdev->notify);
+		return -EINVAL;
+	}
+
+	notify_addr = pci_alloc_consistent(vdev->pdev,
+			sizeof(struct vnic_devcmd_notify),
+			&notify_pa);
+	if (!notify_addr)
+		return -ENOMEM;
+
+	return vnic_dev_notify_setcmd(vdev, notify_addr, notify_pa, intr);
+}
+
+void vnic_dev_notify_unsetcmd(struct vnic_dev *vdev)
 {
 	u64 a0, a1;
 	int wait = 1000;
@@ -607,9 +623,23 @@ void vnic_dev_notify_unset(struct vnic_dev *vdev)
 	a1 += sizeof(struct vnic_devcmd_notify);
 
 	vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
+	vdev->notify = NULL;
+	vdev->notify_pa = 0;
 	vdev->notify_sz = 0;
 }
 
+void vnic_dev_notify_unset(struct vnic_dev *vdev)
+{
+	if (vdev->notify) {
+		pci_free_consistent(vdev->pdev,
+			sizeof(struct vnic_devcmd_notify),
+			vdev->notify,
+			vdev->notify_pa);
+	}
+
+	vnic_dev_notify_unsetcmd(vdev);
+}
+
 static int vnic_dev_notify_ready(struct vnic_dev *vdev)
 {
 	u32 *words;
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index fc5e3eb..f5be640 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -107,7 +107,10 @@ void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
 int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr);
+int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
+	void *notify_addr, dma_addr_t notify_pa, u16 intr);
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
+void vnic_dev_notify_unsetcmd(struct vnic_dev *vdev);
 void vnic_dev_notify_unset(struct vnic_dev *vdev);
 int vnic_dev_link_status(struct vnic_dev *vdev);
 u32 vnic_dev_port_speed(struct vnic_dev *vdev);

