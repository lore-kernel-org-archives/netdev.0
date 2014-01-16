From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH] net: rds: fix per-cpu helper usage
Date: Thu, 16 Jan 2014 16:54:48 +0100
Message-ID: <1389887688-55632-1-git-send-email-gerald.schaefer@de.ibm.com>
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	Sebastian Ott <sebott@linux.vnet.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>
To: Shan Wei <davidshan@tencent.com>, Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:56865 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbaAPPyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 10:54:54 -0500
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 16 Jan 2014 15:54:52 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ae4b46e9d "net: rds: use this_cpu_* per-cpu helper" broke per-cpu
handling for rds. chpfirst is the result of __this_cpu_read(), so it is
an absolute pointer and not __percpu. Therefore, __this_cpu_write()
should not operate on chpfirst, but rather on cache->percpu->first, just
like __this_cpu_read() did before.

Cc: <stable@vger.kernel.org> # 3.8+
Signed-off-byd Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 net/rds/ib_recv.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 8eb9501..b7ebe23 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -421,8 +421,7 @@ static void rds_ib_recv_cache_put(struct list_head *new_item,
 				 struct rds_ib_refill_cache *cache)
 {
 	unsigned long flags;
-	struct list_head *old;
-	struct list_head __percpu *chpfirst;
+	struct list_head *old, *chpfirst;
 
 	local_irq_save(flags);
 
@@ -432,7 +431,7 @@ static void rds_ib_recv_cache_put(struct list_head *new_item,
 	else /* put on front */
 		list_add_tail(new_item, chpfirst);
 
-	__this_cpu_write(chpfirst, new_item);
+	__this_cpu_write(cache->percpu->first, new_item);
 	__this_cpu_inc(cache->percpu->count);
 
 	if (__this_cpu_read(cache->percpu->count) < RDS_IB_RECYCLE_BATCH_COUNT)
@@ -452,7 +451,7 @@ static void rds_ib_recv_cache_put(struct list_head *new_item,
 	} while (old);
 
 
-	__this_cpu_write(chpfirst, NULL);
+	__this_cpu_write(cache->percpu->first, NULL);
 	__this_cpu_write(cache->percpu->count, 0);
 end:
 	local_irq_restore(flags);
-- 
1.8.4.5
