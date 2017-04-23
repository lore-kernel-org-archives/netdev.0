From: Pan Bian <bianpan201603@163.com>
Subject: [PATCH 1/1] libertas: check return value of alloc_workqueue
Date: Sun, 23 Apr 2017 21:19:38 +0800
Message-ID: <1492953578-387-1-git-send-email-bianpan201603@163.com>
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
To: Kalle Valo <kvalo@codeaurora.org>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:57186 "EHLO m50-133.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1045279AbdDWNUl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 09:20:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>

Function alloc_workqueue() will return a NULL pointer if there is no
enough memory, and its return value should be validated before using.
However, in function if_spi_probe(), its return value is not checked.
This may result in a NULL dereference bug. This patch fixes the bug.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/wireless/marvell/libertas/if_spi.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/wireless/marvell/libertas/if_spi.c b/drivers/net/wireless/marvell/libertas/if_spi.c
index c3a53cd..7b4955c 100644
--- a/drivers/net/wireless/marvell/libertas/if_spi.c
+++ b/drivers/net/wireless/marvell/libertas/if_spi.c
@@ -1181,6 +1181,10 @@ static int if_spi_probe(struct spi_device *spi)
 
 	/* Initialize interrupt handling stuff. */
 	card->workqueue = alloc_workqueue("libertas_spi", WQ_MEM_RECLAIM, 0);
+	if (!card->workqueue) {
+		err = -ENOMEM;
+		goto remove_card;
+	}
 	INIT_WORK(&card->packet_work, if_spi_host_to_card_worker);
 	INIT_WORK(&card->resume_work, if_spi_resume_worker);
 
@@ -1209,6 +1213,7 @@ static int if_spi_probe(struct spi_device *spi)
 	free_irq(spi->irq, card);
 terminate_workqueue:
 	destroy_workqueue(card->workqueue);
+remove_card:
 	lbs_remove_card(priv); /* will call free_netdev */
 free_card:
 	free_if_spi_card(card);
-- 
1.9.1
