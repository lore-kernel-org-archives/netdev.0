From: Maris Paupe <marisp@mt.lv>
Subject: [PATCH]  flow_cache_flush soft lockup with heavy ipsec traffic
Date: Wed, 09 Nov 2011 14:21:12 +0200
Message-ID: <4EBA7038.4050702@mt.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.195]:50678 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352Ab1KIMjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 07:39:42 -0500
Received: from [10.0.0.160]
	by bute.mt.lv with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <marisp@mt.lv>)
	id 1RO79V-0004Dt-Lw
	for netdev@vger.kernel.org; Wed, 09 Nov 2011 14:21:13 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


During ipsec packet processing flow_cache_flush() may get called which 
creates flow_cache_gc_taklet(), this function is guarded by mutex and 
waits until all tasklets are finished before releasing it, another 
softirq may happen during flow_cache_gc_taklet(), in case when this irq 
is packet reading from a device, it can happen that flow_cache_flush() 
gets called again and a deadlock occurs.
Here i purpose a simple fix to this problem by disabling softirqs during 
tasklet process. It could also be fixed in ipsec processing code, but I 
am too unfamiliar with it to touch it.

Signed-off-by: Maris Paupe <marisp@mt.lv>

diff --git a/net/core/flow.c b/net/core/flow.c
index 8ae42de..19ff283 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -105,6 +105,7 @@ static void flow_cache_gc_task(struct work_struct *work)
  	struct list_head gc_list;
  	struct flow_cache_entry *fce, *n;

+	local_bh_disable();
  	INIT_LIST_HEAD(&gc_list);
  	spin_lock_bh(&flow_cache_gc_lock);
  	list_splice_tail_init(&flow_cache_gc_list, &gc_list);
@@ -112,6 +113,7 @@ static void flow_cache_gc_task(struct work_struct *work)

  	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list)
  		flow_entry_kill(fce);
+	local_bh_enable();
  }
  static DECLARE_WORK(flow_cache_gc_work, flow_cache_gc_task);
