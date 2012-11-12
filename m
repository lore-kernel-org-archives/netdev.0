From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH v3 2/9] net: rds: use this_cpu_ptr per-cpu helper
Date: Mon, 12 Nov 2012 20:47:35 +0800
Message-ID: <50A0EFE7.9010100@gmail.com>
References: <509C687E.1080106@gmail.com> <0000013ae6cadebe-0e44d6a0-5e8c-4ded-a337-d2f41f2ab0e4-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0000013ae6cadebe-0e44d6a0-5e8c-4ded-a337-d2f41f2ab0e4-000000@email.amazonses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter said, at 2012/11/10 4:09:
>> -	chp = per_cpu_ptr(cache->percpu, smp_processor_id());
>> +	chp = this_cpu_ptr(cache->percpu);
>>  	if (!chp->first)
> 
> if (!__this_cpu_read(cache-0>percpu->first))
> 
> ?

__percpu annotations in struct rds_ib_refill_cache is missing.

you mean that read/write fields of struct rds_ib_cache_head
using __this_cpu_* operation like following?
How about it?

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
