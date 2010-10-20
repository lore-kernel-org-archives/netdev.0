From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 3/5] enic: Replace firmware devcmd CMD_ENABLE
	with CMD_ENABLE_WAIT
Date: Wed, 20 Oct 2010 13:17:09 -0700
Message-ID: <20101020201709.26870.4150.stgit@savbu-pc100.cisco.com>
References: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:23645 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab0JTURK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 16:17:10 -0400
In-Reply-To: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Replace no wait CMD_ENABLE firmware devcmd with CMD_ENABLE_WAIT

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic_main.c |    2 +-
 drivers/net/enic/vnic_dev.c  |   10 ++++++++--
 drivers/net/enic/vnic_dev.h  |    2 +-
 3 files changed, 10 insertions(+), 4 deletions(-)


diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 622106d..a63d2ba 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1787,7 +1787,7 @@ static int enic_dev_enable(struct enic *enic)
 	int err;
 
 	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_enable(enic->vdev);
+	err = vnic_dev_enable_wait(enic->vdev);
 	spin_unlock(&enic->devcmd_lock);
 
 	return err;
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 11dc8f7..fb35d8b 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -487,11 +487,17 @@ int vnic_dev_close(struct vnic_dev *vdev)
 	return vnic_dev_cmd(vdev, CMD_CLOSE, &a0, &a1, wait);
 }
 
-int vnic_dev_enable(struct vnic_dev *vdev)
+int vnic_dev_enable_wait(struct vnic_dev *vdev)
 {
 	u64 a0 = 0, a1 = 0;
 	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
+	int err;
+
+	err = vnic_dev_cmd(vdev, CMD_ENABLE_WAIT, &a0, &a1, wait);
+	if (err == ERR_ECMDUNKNOWN)
+		return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
+
+	return err;
 }
 
 int vnic_dev_disable(struct vnic_dev *vdev)
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 3f00143..05f9a24 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -111,7 +111,7 @@ u32 vnic_dev_port_speed(struct vnic_dev *vdev);
 u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
 u32 vnic_dev_mtu(struct vnic_dev *vdev);
 int vnic_dev_close(struct vnic_dev *vdev);
-int vnic_dev_enable(struct vnic_dev *vdev);
+int vnic_dev_enable_wait(struct vnic_dev *vdev);
 int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);

