From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] net: cavium: liquidio: Remove deprecated create_workqueue
Date: Wed, 8 Jun 2016 01:47:59 +0530
Message-ID: <20160607201758.GA14937@Karyakshetra>
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
(&lio->txq_status_wq.wk.work which maps to octnet_poll_check_txq_status)
is involved in a brief poll routine for checking transmit queue status
and is an intergral part of normal device operation.
WQ_MEM_RECLAIM has been set to guarantee forward progress under memory
pressure, which is a requirement here.
Since there are only a fixed number of work items, explicit concurrency
limit is unnecessary.

flush_workqueue is unnecessary since destroy_workqueue() itself calls
drain_workqueue() which flushes repeatedly till the workqueue
becomes empty.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8de79ae..655d89e 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2036,7 +2036,8 @@ static inline void setup_tx_poll_fn(struct net_device *netdev)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;

-	lio->txq_status_wq.wq = create_workqueue("txq-status");
+	lio->txq_status_wq.wq = alloc_workqueue("txq-status",
+						WQ_MEM_RECLAIM, 0);
 	if (!lio->txq_status_wq.wq) {
 		dev_err(&oct->pci_dev->dev, "unable to create cavium txq status wq\n");
 		return;
@@ -2103,7 +2104,6 @@ static int liquidio_stop(struct net_device *netdev)
 	send_rx_ctrl_cmd(lio, 0);

 	cancel_delayed_work_sync(&lio->txq_status_wq.wk.work);
-	flush_workqueue(lio->txq_status_wq.wq);
 	destroy_workqueue(lio->txq_status_wq.wq);

 	if (lio->ptp_clock) {
