From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH v2] net: fjes: fjes_main: Remove create_workqueue
Date: Sat, 4 Jun 2016 19:40:04 +0530
Message-ID: <20160604141004.GA30209@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>,
	Florian Westphal <fw@strlen.de>,
	Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_workqueue().

The workqueue adapter->txrx_wq has workitem
&adapter->raise_intr_rxdata_task per adapter. Extended Socket Network
Device is shared memory based, so someone's transmission denotes other's
reception.  raise_intr_rxdata_task raises interruption of receivers from
the sender in order to notify receivers. Forward progress under memory
pressure is a requirement here.

The workqueue adapter->control_wq has workitem
&adapter->interrupt_watch_task per adapter. interrupt_watch_task is used
to prevent delay of interrupts. Forward progress under memory pressure
is a requirement here.

Dedicated workqueues have been used in both cases since the workitems
on the workqueues are involved in normal device operation with
WQ_MEM_RECLAIM set to gurantee forward progress under memory pressure.
Since there are only a fixed number of work items, explicit concurrency
limit is unnecessary.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 Changes in v2:
	- Changed commit description to more concise one.

 drivers/net/fjes/fjes_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 86c331b..9006877 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1187,8 +1187,9 @@ static int fjes_probe(struct platform_device *plat_dev)
 	adapter->force_reset = false;
 	adapter->open_guard = false;

-	adapter->txrx_wq = create_workqueue(DRV_NAME "/txrx");
-	adapter->control_wq = create_workqueue(DRV_NAME "/control");
+	adapter->txrx_wq = alloc_workqueue(DRV_NAME "/txrx", WQ_MEM_RECLAIM, 0);
+	adapter->control_wq = alloc_workqueue(DRV_NAME "/control",
+					      WQ_MEM_RECLAIM, 0);

 	INIT_WORK(&adapter->tx_stall_task, fjes_tx_stall_task);
 	INIT_WORK(&adapter->raise_intr_rxdata_task,
