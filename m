From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] net: ethernet: wiznet: Remove create_workqueue
Date: Wed, 1 Jun 2016 23:29:15 +0530
Message-ID: <20160601175914.GA5169@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Antonio Quartulli <a@unstable.cc>,
	Felipe Balbi <felipe.balbi@linux.intel.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_workqueue().

A dedicated workqueue has been used since the workitems are involved
in normal device operation. Workitems &priv->rx_work and &priv->tx_work,
map to w5100_rx_work and w5100_tx_work respectively and are involved in
receiving and transmitting packets. Forward progress under
memory pressure is a requirement here.

create_workqueue has been replaced with alloc_workqueue with max_active
as 0 since there is no need for throttling the number of active work
items.

Since the driver may be used in memory reclaim path,
WQ_MEM_RECLAIM has been set to guarantee forward progress.

flush_workqueue is unnecessary since destroy_workqueue() itself calls
drain_workqueue() which flushes repeatedly till the workqueue
becomes empty. Hence the call to flush_workqueue() has been dropped.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/wiznet/w5100.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 4f6255c..37ab46c 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -1154,7 +1154,7 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 	if (err < 0)
 		goto err_register;

-	priv->xfer_wq = create_workqueue(netdev_name(ndev));
+	priv->xfer_wq = alloc_workqueue(netdev_name(ndev), WQ_MEM_RECLAIM, 0);
 	if (!priv->xfer_wq) {
 		err = -ENOMEM;
 		goto err_wq;
@@ -1233,7 +1233,6 @@ int w5100_remove(struct device *dev)

 	flush_work(&priv->setrx_work);
 	flush_work(&priv->restart_work);
-	flush_workqueue(priv->xfer_wq);
 	destroy_workqueue(priv->xfer_wq);

 	unregister_netdev(ndev);
