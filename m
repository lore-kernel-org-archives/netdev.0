From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] cisco: enic: Fic an error handling path in 'vnic_dev_init_devcmd2()'
Date: Sat,  8 Jul 2017 06:51:35 +0200
Message-ID: <20170708045135.14753-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: benve@cisco.com, govind@gmx.com, neepatel@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp04.smtpout.orange.fr ([80.12.242.126]:45307 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdGHEvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 00:51:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if 'ioread32()' returns 0xFFFFFFF, we have to go through the error
handling path as done everywhere else in this function.

Move the 'err_free_wq' label to better match its name and its location
and add a new label 'err_disable_wq'.
Update the code accordingly.

Fixes: 373fb0873d43 ("enic: add devcmd2")
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 1841ad45d215..39bad67422dd 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -402,8 +402,8 @@ static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
 	fetch_index = ioread32(&vdev->devcmd2->wq.ctrl->fetch_index);
 	if (fetch_index == 0xFFFFFFFF) { /* check for hardware gone  */
 		vdev_err(vdev, "Fatal error in devcmd2 init - hardware surprise removal\n");
-
-		return -ENODEV;
+		err = -ENODEV;
+		goto err_free_wq;
 	}
 
 	enic_wq_init_start(&vdev->devcmd2->wq, 0, fetch_index, fetch_index, 0,
@@ -414,7 +414,7 @@ static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
 	err = vnic_dev_alloc_desc_ring(vdev, &vdev->devcmd2->results_ring,
 				       DEVCMD2_RING_SIZE, DEVCMD2_DESC_SIZE);
 	if (err)
-		goto err_free_wq;
+		goto err_disable_wq;
 
 	vdev->devcmd2->result = vdev->devcmd2->results_ring.descs;
 	vdev->devcmd2->cmd_ring = vdev->devcmd2->wq.ring.descs;
@@ -433,8 +433,9 @@ static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
 
 err_free_desc_ring:
 	vnic_dev_free_desc_ring(vdev, &vdev->devcmd2->results_ring);
-err_free_wq:
+err_disable_wq:
 	vnic_wq_disable(&vdev->devcmd2->wq);
+err_free_wq:
 	vnic_wq_free(&vdev->devcmd2->wq);
 err_free_devcmd2:
 	kfree(vdev->devcmd2);
-- 
2.11.0
