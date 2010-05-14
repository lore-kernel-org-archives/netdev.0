From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 04/25] wimax/i2400m: fix the race condition for
	accessing TX queue
Date: Fri, 14 May 2010 14:45:03 -0700
Message-ID: <f22cf689a6353f072bca15d0a26f870e62dfacf8.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Cindy H Kao <cindy.h.kao@intel.com>

The race condition happens when the TX queue is accessed by
the TX work while the same TX queue is being destroyed because
a bus reset is triggered either by debugfs entry or simply
by failing waking up the device from WiMAX IDLE mode.

This fix is to prevent the TX queue from being accessed by
multiple threads

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/i2400m-sdio.h |    5 ++++-
 drivers/net/wimax/i2400m/sdio-tx.c     |   31 ++++++++++++++++++++++++-------
 2 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index b9c4bed..360d4fb 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -99,7 +99,10 @@ enum {
  *
  * @tx_workqueue: workqeueue used for data TX; we don't use the
  *     system's workqueue as that might cause deadlocks with code in
- *     the bus-generic driver.
+ *     the bus-generic driver. The read/write operation to the queue
+ *     is protected with spinlock (tx_lock in struct i2400m) to avoid
+ *     the queue being destroyed in the middle of a the queue read/write
+ *     operation.
  *
  * @debugfs_dentry: dentry for the SDIO specific debugfs files
  *
diff --git a/drivers/net/wimax/i2400m/sdio-tx.c b/drivers/net/wimax/i2400m/sdio-tx.c
index de66d06..412b6a8 100644
--- a/drivers/net/wimax/i2400m/sdio-tx.c
+++ b/drivers/net/wimax/i2400m/sdio-tx.c
@@ -114,13 +114,17 @@ void i2400ms_bus_tx_kick(struct i2400m *i2400m)
 {
 	struct i2400ms *i2400ms = container_of(i2400m, struct i2400ms, i2400m);
 	struct device *dev = &i2400ms->func->dev;
+	unsigned long flags;
 
 	d_fnstart(3, dev, "(i2400m %p) = void\n", i2400m);
 
 	/* schedule tx work, this is because tx may block, therefore
 	 * it has to run in a thread context.
 	 */
-	queue_work(i2400ms->tx_workqueue, &i2400ms->tx_worker);
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	if (i2400ms->tx_workqueue != NULL)
+		queue_work(i2400ms->tx_workqueue, &i2400ms->tx_worker);
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
 
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 }
@@ -130,27 +134,40 @@ int i2400ms_tx_setup(struct i2400ms *i2400ms)
 	int result;
 	struct device *dev = &i2400ms->func->dev;
 	struct i2400m *i2400m = &i2400ms->i2400m;
+	struct workqueue_struct *tx_workqueue;
+	unsigned long flags;
 
 	d_fnstart(5, dev, "(i2400ms %p)\n", i2400ms);
 
 	INIT_WORK(&i2400ms->tx_worker, i2400ms_tx_submit);
 	snprintf(i2400ms->tx_wq_name, sizeof(i2400ms->tx_wq_name),
 		 "%s-tx", i2400m->wimax_dev.name);
-	i2400ms->tx_workqueue =
+	tx_workqueue =
 		create_singlethread_workqueue(i2400ms->tx_wq_name);
-	if (NULL == i2400ms->tx_workqueue) {
+	if (tx_workqueue == NULL) {
 		dev_err(dev, "TX: failed to create workqueue\n");
 		result = -ENOMEM;
 	} else
 		result = 0;
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	i2400ms->tx_workqueue = tx_workqueue;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
 	d_fnend(5, dev, "(i2400ms %p) = %d\n", i2400ms, result);
 	return result;
 }
 
 void i2400ms_tx_release(struct i2400ms *i2400ms)
 {
-	if (i2400ms->tx_workqueue) {
-		destroy_workqueue(i2400ms->tx_workqueue);
-		i2400ms->tx_workqueue = NULL;
-	}
+	struct i2400m *i2400m = &i2400ms->i2400m;
+	struct workqueue_struct *tx_workqueue;
+	unsigned long flags;
+
+	tx_workqueue = i2400ms->tx_workqueue;
+
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	i2400ms->tx_workqueue = NULL;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+
+	if (tx_workqueue)
+		destroy_workqueue(tx_workqueue);
 }
-- 
1.6.6.1
