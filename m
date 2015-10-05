From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/13] rocker: pre-allocate wait structures during cmd ring init
Date: Mon,  5 Oct 2015 19:44:03 +0200
Message-ID: <1444067046-27825-11-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34880 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbJERoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:22 -0400
Received: by wicge5 with SMTP id ge5so131620295wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:21 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This avoids need to alloc/free wait structure for every command call.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 87 +++++++++++++++++++++++--------
 1 file changed, 66 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index af70a48..9a38b83 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -414,23 +414,19 @@ static void rocker_wait_init(struct rocker_wait *wait)
 	rocker_wait_reset(wait);
 }
 
-static struct rocker_wait *rocker_wait_create(struct rocker_port *rocker_port,
-					      struct switchdev_trans *trans,
-					      int flags)
+static struct rocker_wait *rocker_wait_create(void)
 {
 	struct rocker_wait *wait;
 
-	wait = rocker_kzalloc(trans, flags, sizeof(*wait));
+	wait = kzalloc(sizeof(*wait), GFP_KERNEL);
 	if (!wait)
 		return NULL;
-	rocker_wait_init(wait);
 	return wait;
 }
 
-static void rocker_wait_destroy(struct switchdev_trans *trans,
-				struct rocker_wait *wait)
+static void rocker_wait_destroy(struct rocker_wait *wait)
 {
-	rocker_kfree(trans, wait);
+	kfree(wait);
 }
 
 static bool rocker_wait_event_timeout(struct rocker_wait *wait,
@@ -906,6 +902,53 @@ static void rocker_dma_ring_bufs_free(const struct rocker *rocker,
 	}
 }
 
+static int rocker_dma_cmd_ring_wait_alloc(struct rocker_desc_info *desc_info)
+{
+	struct rocker_wait *wait;
+
+	wait = rocker_wait_create();
+	if (!wait)
+		return -ENOMEM;
+	rocker_desc_cookie_ptr_set(desc_info, wait);
+	return 0;
+}
+
+static void
+rocker_dma_cmd_ring_wait_free(const struct rocker_desc_info *desc_info)
+{
+	struct rocker_wait *wait = rocker_desc_cookie_ptr_get(desc_info);
+
+	rocker_wait_destroy(wait);
+}
+
+static int rocker_dma_cmd_ring_waits_alloc(const struct rocker *rocker)
+{
+	const struct rocker_dma_ring_info *cmd_ring = &rocker->cmd_ring;
+	int i;
+	int err;
+
+	for (i = 0; i < cmd_ring->size; i++) {
+		err = rocker_dma_cmd_ring_wait_alloc(&cmd_ring->desc_info[i]);
+		if (err)
+			goto rollback;
+	}
+	return 0;
+
+rollback:
+	for (i--; i >= 0; i--)
+		rocker_dma_cmd_ring_wait_free(&cmd_ring->desc_info[i]);
+	return err;
+}
+
+static void rocker_dma_cmd_ring_waits_free(const struct rocker *rocker)
+{
+	const struct rocker_dma_ring_info *cmd_ring = &rocker->cmd_ring;
+	int i;
+
+	for (i = 0; i < cmd_ring->size; i++)
+		rocker_dma_cmd_ring_wait_free(&cmd_ring->desc_info[i]);
+}
+
 static int rocker_dma_rings_init(struct rocker *rocker)
 {
 	const struct pci_dev *pdev = rocker->pdev;
@@ -928,6 +971,12 @@ static int rocker_dma_rings_init(struct rocker *rocker)
 		goto err_dma_cmd_ring_bufs_alloc;
 	}
 
+	err = rocker_dma_cmd_ring_waits_alloc(rocker);
+	if (err) {
+		dev_err(&pdev->dev, "failed to alloc command dma ring waits\n");
+		goto err_dma_cmd_ring_waits_alloc;
+	}
+
 	err = rocker_dma_ring_create(rocker, ROCKER_DMA_EVENT,
 				     ROCKER_DMA_EVENT_DEFAULT_SIZE,
 				     &rocker->event_ring);
@@ -950,6 +999,8 @@ err_dma_event_ring_bufs_alloc:
 err_dma_event_ring_create:
 	rocker_dma_ring_bufs_free(rocker, &rocker->cmd_ring,
 				  PCI_DMA_BIDIRECTIONAL);
+err_dma_cmd_ring_waits_alloc:
+	rocker_dma_cmd_ring_waits_free(rocker);
 err_dma_cmd_ring_bufs_alloc:
 	rocker_dma_ring_destroy(rocker, &rocker->cmd_ring);
 	return err;
@@ -960,6 +1011,7 @@ static void rocker_dma_rings_fini(struct rocker *rocker)
 	rocker_dma_ring_bufs_free(rocker, &rocker->event_ring,
 				  PCI_DMA_BIDIRECTIONAL);
 	rocker_dma_ring_destroy(rocker, &rocker->event_ring);
+	rocker_dma_cmd_ring_waits_free(rocker);
 	rocker_dma_ring_bufs_free(rocker, &rocker->cmd_ring,
 				  PCI_DMA_BIDIRECTIONAL);
 	rocker_dma_ring_destroy(rocker, &rocker->cmd_ring);
@@ -1181,7 +1233,6 @@ static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
 		wait = rocker_desc_cookie_ptr_get(desc_info);
 		if (wait->nowait) {
 			rocker_desc_gen_clear(desc_info);
-			rocker_wait_destroy(NULL, wait);
 		} else {
 			rocker_wait_wake_up(wait);
 		}
@@ -1373,28 +1424,24 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int err;
 
-	wait = rocker_wait_create(rocker_port, trans, flags);
-	if (!wait)
-		return -ENOMEM;
-	wait->nowait = nowait;
-
 	spin_lock_irqsave(&rocker->cmd_ring_lock, lock_flags);
 
 	desc_info = rocker_desc_head_get(&rocker->cmd_ring);
 	if (!desc_info) {
 		spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
-		err = -EAGAIN;
-		goto out;
+		return -EAGAIN;
 	}
 
+	wait = rocker_desc_cookie_ptr_get(desc_info);
+	rocker_wait_init(wait);
+	wait->nowait = nowait;
+
 	err = prepare(rocker_port, desc_info, prepare_priv);
 	if (err) {
 		spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
-		goto out;
+		return err;
 	}
 
-	rocker_desc_cookie_ptr_set(desc_info, wait);
-
 	if (!switchdev_trans_ph_prepare(trans))
 		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
@@ -1415,8 +1462,6 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 		err = process(rocker_port, desc_info, process_priv);
 
 	rocker_desc_gen_clear(desc_info);
-out:
-	rocker_wait_destroy(trans, wait);
 	return err;
 }
 
-- 
1.9.3
