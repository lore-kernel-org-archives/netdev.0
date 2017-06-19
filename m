From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net v2] cxgb4: notify uP to route ctrlq compl to rdma rspq
Date: Mon, 19 Jun 2017 19:46:00 +0530
Message-ID: <1497881760-10240-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Raju Rangoju <rajur@chelsio.com>,
        Stable <stable@vger.kernel.org>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Raju Rangoju <rajur@chelsio.com>

During the module initialisation there is a possible race
(basically race between uld and lld) where neither the uld
nor lld notifies the uP about where to route the ctrl queue
completions. LLD skips notifying uP as the rdma queues were
not created by then (will leave it to ULD to notify the uP).
As the ULD comes up, it also skips notifying the uP as the
flag FULL_INIT_DONE is not set yet (ULD assumes that the
interface is not up yet).

Consequently, this race between uld and lld leaves uP
unnotified about where to send the ctrl queue completions
to, leading to iwarp RI_RES WR failure.

Here is the race:

CPU 0                                   CPU1

- allocates nic rx queus
- t4_sge_alloc_ctrl_txq()
(if rdma rsp queues exists,
tell uP to route ctrl queue
compl to rdma rspq)
                                - acquires the mutex_lock
                                - allocates rdma response queues
                                - if FULL_INIT_DONE set,
                                  tell uP to route ctrl queue compl
                                  to rdma rspq
                                - relinquishes mutex_lock
- acquires the mutex_lock
- enable_rx()
- set FULL_INIT_DONE
- relinquishes mutex_lock

This patch fixes the above issue.

Fixes: e7519f9926f1('cxgb4: avoid enabling napi twice to the same queue')
Signed-off-by: Raju Rangoju <rajur@chelsio.com>
Acked-by: Steve Wise <swise@opengridcomputing.com>
CC: Stable <stable@vger.kernel.org> # 4.9+
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
V2: sending to net tree
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ea1bfcf..53309f6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2171,9 +2171,10 @@ static int cxgb_up(struct adapter *adap)
 {
 	int err;
 
+	mutex_lock(&uld_mutex);
 	err = setup_sge_queues(adap);
 	if (err)
-		goto out;
+		goto rel_lock;
 	err = setup_rss(adap);
 	if (err)
 		goto freeq;
@@ -2197,7 +2198,6 @@ static int cxgb_up(struct adapter *adap)
 			goto irq_err;
 	}
 
-	mutex_lock(&uld_mutex);
 	enable_rx(adap);
 	t4_sge_start(adap);
 	t4_intr_enable(adap);
@@ -2210,13 +2210,15 @@ static int cxgb_up(struct adapter *adap)
 #endif
 	/* Initialize hash mac addr list*/
 	INIT_LIST_HEAD(&adap->mac_hlist);
- out:
 	return err;
+
  irq_err:
 	dev_err(adap->pdev_dev, "request_irq failed, err %d\n", err);
  freeq:
 	t4_free_sge_resources(adap);
-	goto out;
+ rel_lock:
+	mutex_unlock(&uld_mutex);
+	return err;
 }
 
 static void cxgb_down(struct adapter *adapter)
-- 
2.1.0
