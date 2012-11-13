From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH v4 2/9] net: rds: use this_cpu_* per-cpu helper
Date: Tue, 13 Nov 2012 09:52:01 +0800
Message-ID: <50A1A7C1.50308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	cl@linux-foundation.org, Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <davidshan@tencent.com>


Signed-off-by: Shan Wei <davidshan@tencent.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
---
v4:
1. add missing __percpu annotations.
2. [read|write]ing fields of struct rds_ib_cache_head
using __this_cpu_* operation, drop per_cpu_ptr.
---
 net/rds/ib.h      |    2 +-
 net/rds/ib_recv.c |   24 +++++++++++++-----------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 8d2b3d5..7280ab8 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -50,7 +50,7 @@ struct rds_ib_cache_head {
 };
 
 struct rds_ib_refill_cache {
-	struct rds_ib_cache_head *percpu;
+	struct rds_ib_cache_head __percpu *percpu;
 	struct list_head	 *xfer;
 	struct list_head	 *ready;
 };
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 8d19491..8c5bc85 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -418,20 +418,21 @@ static void rds_ib_recv_cache_put(struct list_head *new_item,
 				 struct rds_ib_refill_cache *cache)
 {
 	unsigned long flags;
-	struct rds_ib_cache_head *chp;
 	struct list_head *old;
+	struct list_head __percpu *chpfirst;
 
 	local_irq_save(flags);
 
-	chp = per_cpu_ptr(cache->percpu, smp_processor_id());
-	if (!chp->first)
+	chpfirst = __this_cpu_read(cache->percpu->first);
+	if (!chpfirst)
 		INIT_LIST_HEAD(new_item);
 	else /* put on front */
-		list_add_tail(new_item, chp->first);
-	chp->first = new_item;
-	chp->count++;
+		list_add_tail(new_item, chpfirst);
 
-	if (chp->count < RDS_IB_RECYCLE_BATCH_COUNT)
+	__this_cpu_write(chpfirst, new_item);
+	__this_cpu_inc(cache->percpu->count);
+
+	if (__this_cpu_read(cache->percpu->count) < RDS_IB_RECYCLE_BATCH_COUNT)
 		goto end;
 
 	/*
@@ -443,12 +444,13 @@ static void rds_ib_recv_cache_put(struct list_head *new_item,
 	do {
 		old = xchg(&cache->xfer, NULL);
 		if (old)
-			list_splice_entire_tail(old, chp->first);
-		old = cmpxchg(&cache->xfer, NULL, chp->first);
+			list_splice_entire_tail(old, chpfirst);
+		old = cmpxchg(&cache->xfer, NULL, chpfirst);
 	} while (old);
 
-	chp->first = NULL;
-	chp->count = 0;
+
+	__this_cpu_write(chpfirst, NULL);
+	__this_cpu_write(cache->percpu->count, 0);
 end:
 	local_irq_restore(flags);
 }
-- 
1.7.1
