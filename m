From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] net: ethernet: cavium: liquidio: response_manager: Remove
 create_workqueue
Date: Sat, 4 Jun 2016 20:21:40 +0530
Message-ID: <20160604145139.GA31437@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_workqueue().

A dedicated workqueue has been used since the workitem viz
(&cwq->wk.work which maps to oct_poll_req_completion) is involved
in normal device operation. WQ_MEM_RECLAIM has been set to guarantee
forward progress under memory pressure, which is a requirement here.
Since there are only a fixed number of work items, explicit concurrency
limit is unnecessary.

flush_workqueue is unnecessary since destroy_workqueue() itself calls
drain_workqueue() which flushes repeatedly till the workqueue
becomes empty. Hence the call to flush_workqueue() has been dropped.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/cavium/liquidio/response_manager.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 091f537..6287a7c 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -55,7 +55,7 @@ int octeon_setup_response_list(struct octeon_device *oct)
 		atomic_set(&oct->response_list[i].pending_req_count, 0);
 	}

-	oct->dma_comp_wq.wq = create_workqueue("dma-comp");
+	oct->dma_comp_wq.wq = alloc_workqueue("dma-comp", WQ_MEM_RECLAIM, 0);
 	if (!oct->dma_comp_wq.wq) {
 		dev_err(&oct->pci_dev->dev, "failed to create wq thread\n");
 		return -ENOMEM;
@@ -72,7 +72,6 @@ int octeon_setup_response_list(struct octeon_device *oct)
 void octeon_delete_response_list(struct octeon_device *oct)
 {
 	cancel_delayed_work_sync(&oct->dma_comp_wq.wk.work);
-	flush_workqueue(oct->dma_comp_wq.wq);
 	destroy_workqueue(oct->dma_comp_wq.wq);
 }
