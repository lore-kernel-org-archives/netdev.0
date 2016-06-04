From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] net: wireless: marvell: libertas: Remove create_workqueue
Date: Sat, 4 Jun 2016 19:29:01 +0530
Message-ID: <20160604135901.GA29897@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Andreas Kemnade <andreas@kemnade.info>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
	"Andrew F. Davis" <afd@ti.com>,
	Jonathan Cameron <jic23@kernel.org>,
	Mark Brown <broonie@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_workqueue().

In if_sdio.c, the workqueue card->workqueue has workitem
&card->packet_worker, which is mapped to if_sdio_host_to_card_worker.
The workitem is involved in sending packets to firmware.
Forward progress under memory pressure is a requirement here.

In if_spi.c, the workqueue card->workqueue has workitem
&card->packet_worker, which is mapped to if_spi_host_to_card_worker.
The workitem is involved in sending command packets from the host.
Forward progress under memory pressure is a requirement here.

Dedicated workqueues have been used in both cases since the workitems
on the workqueues are involved in normal device operation with
WQ_MEM_RECLAIM set to gurantee forward progress under memory pressure.
Since there are only a fixed number of work items, explicit concurrency
limit is unnecessary.

flush_workqueue is unnecessary since destroy_workqueue() itself calls
drain_workqueue() which flushes repeatedly till the workqueue
becomes empty. Hence the calls to flush_workqueue() before
destroy_workqueue() have been dropped.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/wireless/marvell/libertas/if_sdio.c | 3 +--
 drivers/net/wireless/marvell/libertas/if_spi.c  | 4 +---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/marvell/libertas/if_sdio.c b/drivers/net/wireless/marvell/libertas/if_sdio.c
index 13eae9f..47f4a14 100644
--- a/drivers/net/wireless/marvell/libertas/if_sdio.c
+++ b/drivers/net/wireless/marvell/libertas/if_sdio.c
@@ -1228,7 +1228,7 @@ static int if_sdio_probe(struct sdio_func *func,
 	}

 	spin_lock_init(&card->lock);
-	card->workqueue = create_workqueue("libertas_sdio");
+	card->workqueue = alloc_workqueue("libertas_sdio", WQ_MEM_RECLAIM, 0);
 	INIT_WORK(&card->packet_worker, if_sdio_host_to_card_worker);
 	init_waitqueue_head(&card->pwron_waitq);

@@ -1326,7 +1326,6 @@ static void if_sdio_remove(struct sdio_func *func)
 	lbs_stop_card(card->priv);
 	lbs_remove_card(card->priv);

-	flush_workqueue(card->workqueue);
 	destroy_workqueue(card->workqueue);

 	while (card->packets) {
diff --git a/drivers/net/wireless/marvell/libertas/if_spi.c b/drivers/net/wireless/marvell/libertas/if_spi.c
index 82c0796..c3a53cd 100644
--- a/drivers/net/wireless/marvell/libertas/if_spi.c
+++ b/drivers/net/wireless/marvell/libertas/if_spi.c
@@ -1180,7 +1180,7 @@ static int if_spi_probe(struct spi_device *spi)
 	priv->fw_ready = 1;

 	/* Initialize interrupt handling stuff. */
-	card->workqueue = create_workqueue("libertas_spi");
+	card->workqueue = alloc_workqueue("libertas_spi", WQ_MEM_RECLAIM, 0);
 	INIT_WORK(&card->packet_work, if_spi_host_to_card_worker);
 	INIT_WORK(&card->resume_work, if_spi_resume_worker);

@@ -1208,7 +1208,6 @@ static int if_spi_probe(struct spi_device *spi)
 release_irq:
 	free_irq(spi->irq, card);
 terminate_workqueue:
-	flush_workqueue(card->workqueue);
 	destroy_workqueue(card->workqueue);
 	lbs_remove_card(priv); /* will call free_netdev */
 free_card:
@@ -1235,7 +1234,6 @@ static int libertas_spi_remove(struct spi_device *spi)
 	lbs_remove_card(priv); /* will call free_netdev */

 	free_irq(spi->irq, card);
-	flush_workqueue(card->workqueue);
 	destroy_workqueue(card->workqueue);
 	if (card->pdata->teardown)
 		card->pdata->teardown(spi);
