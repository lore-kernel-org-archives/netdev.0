From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 09/10] enic: Bug Fix: Handle surprise hardware
	removals
Date: Thu, 24 Jun 2010 13:52:08 -0700
Message-ID: <20100624205204.22595.77152.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:60764 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab0FXUwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:52:08 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Handle surprise hardware removals gracefully during devcmd issue and init,
cleanup of queues.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/vnic_dev.c |    9 +++++++++
 drivers/net/enic/vnic_rq.c  |   13 +++++++++++--
 drivers/net/enic/vnic_wq.c  |    2 --
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 180912f..662123c 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -275,6 +275,11 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	int err;
 
 	status = ioread32(&devcmd->status);
+	if (status == 0xFFFFFFFF) {
+		/* PCI-e target device is gone */
+		return -ENODEV;
+	}
+
 	if (status & STAT_BUSY) {
 		pr_err("Busy devcmd %d\n", _CMD_N(cmd));
 		return -EBUSY;
@@ -296,6 +301,10 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		udelay(100);
 
 		status = ioread32(&devcmd->status);
+		if (status == 0xFFFFFFFF) {
+			/* PCI-e target device is gone */
+			return -ENODEV;
+		}
 
 		if (!(status & STAT_BUSY)) {
 
diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index 45cfc79..061a26f 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -146,6 +146,11 @@ void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 	/* Use current fetch_index as the ring starting point */
 	fetch_index = ioread32(&rq->ctrl->fetch_index);
 
+	if (fetch_index == 0xFFFFFFFF) { /* check for hardware gone  */
+		/* Hardware surprise removal: reset fetch_index */
+		fetch_index = 0;
+	}
+
 	vnic_rq_init_start(rq, cq_index,
 		fetch_index, fetch_index,
 		error_interrupt_enable,
@@ -187,8 +192,6 @@ void vnic_rq_clean(struct vnic_rq *rq,
 	u32 fetch_index;
 	unsigned int count = rq->ring.desc_count;
 
-	BUG_ON(ioread32(&rq->ctrl->enable));
-
 	buf = rq->to_clean;
 
 	while (vnic_rq_desc_used(rq) > 0) {
@@ -201,6 +204,12 @@ void vnic_rq_clean(struct vnic_rq *rq,
 
 	/* Use current fetch_index as the ring starting point */
 	fetch_index = ioread32(&rq->ctrl->fetch_index);
+
+	if (fetch_index == 0xFFFFFFFF) { /* check for hardware gone  */
+		/* Hardware surprise removal: reset fetch_index */
+		fetch_index = 0;
+	}
+
 	rq->to_use = rq->to_clean =
 		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES(count)]
 			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES(count)];
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index 6c4d4f7..3ab7fa5 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -178,8 +178,6 @@ void vnic_wq_clean(struct vnic_wq *wq,
 {
 	struct vnic_wq_buf *buf;
 
-	BUG_ON(ioread32(&wq->ctrl->enable));
-
 	buf = wq->to_clean;
 
 	while (vnic_wq_desc_used(wq) > 0) {

