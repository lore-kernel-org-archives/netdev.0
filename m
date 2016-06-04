From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] net: ethernet: cavium: liquidio: request_manager: Remove
 create_workqueue
Date: Sat, 4 Jun 2016 20:54:00 +0530
Message-ID: <20160604152400.GA559@Karyakshetra>
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
(&db_wq->wk.work which maps to check_db_timeout) is involved
in normal device operation. WQ_MEM_RECLAIM has been set to guarantee
forward progress under memory pressure, which is a requirement here.
Since there are only a fixed number of work items, explicit concurrency
limit is unnecessary.

flush_workqueue is unnecessary since destroy_workqueue() itself calls
drain_workqueue() which flushes repeatedly till the workqueue
becomes empty.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/cavium/liquidio/request_manager.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index a2a2465..9313915 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -144,7 +144,9 @@ int octeon_init_instr_queue(struct octeon_device *oct,

 	oct->fn_list.setup_iq_regs(oct, iq_no);

-	oct->check_db_wq[iq_no].wq = create_workqueue("check_iq_db");
+	oct->check_db_wq[iq_no].wq = alloc_workqueue("check_iq_db",
+						     WQ_MEM_RECLAIM,
+						     0);
 	if (!oct->check_db_wq[iq_no].wq) {
 		lio_dma_free(oct, q_size, iq->base_addr, iq->base_addr_dma);
 		dev_err(&oct->pci_dev->dev, "check db wq create failed for iq %d\n",
@@ -168,7 +170,6 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];

 	cancel_delayed_work_sync(&oct->check_db_wq[iq_no].wk.work);
-	flush_workqueue(oct->check_db_wq[iq_no].wq);
 	destroy_workqueue(oct->check_db_wq[iq_no].wq);

 	if (OCTEON_CN6XXX(oct))
