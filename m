From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [RFC/PATCH] net: add deferred flow cache flush function to be used in xfrm
Date: Mon, 12 Sep 2011 15:17:26 +0300
Message-ID: <1315829846-15016-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <timo.teras@iki.fi>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:22839
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755508Ab1ILMSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 08:18:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xfrm garbage collector calls flow_cache_flush() that might sleep.
The xfrm garbage collector can be called from softirq context, such as from
net_rx_action() through ip_forward(). Added flow_cache_flush_deferred()
function that uses the kernel-global work queue to leave the actual
cache flush processing outside the softirq context.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 include/net/flow.h     |    1 +
 net/core/flow.c        |   12 ++++++++++++
 net/xfrm/xfrm_policy.c |    2 +-
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index c6d5fe5..7b4bc88 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -188,6 +188,7 @@ extern struct flow_cache_object *flow_cache_lookup(
 		u8 dir, flow_resolve_t resolver, void *ctx);
 
 extern void flow_cache_flush(void);
+extern void flow_cache_flush_deferred(void);
 extern atomic_t flow_cache_genid;
 
 #endif
diff --git a/net/core/flow.c b/net/core/flow.c
index 990703b..4edef63 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -352,6 +352,18 @@ void flow_cache_flush(void)
 	put_online_cpus();
 }
 
+static void flow_cache_flush_wq(struct work_struct *work)
+{
+	flow_cache_flush();
+}
+
+static DECLARE_WORK(flow_cache_flush_work, flow_cache_flush_wq);
+
+void flow_cache_flush_deferred(void)
+{
+	schedule_work(&flow_cache_flush_work);
+}
+
 static int __cpuinit flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
 {
 	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5ce74a3..62b1af8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2274,7 +2274,7 @@ static void __xfrm_garbage_collect(struct net *net)
 {
 	struct dst_entry *head, *next;
 
-	flow_cache_flush();
+	flow_cache_flush_deferred();
 
 	spin_lock_bh(&xfrm_policy_sk_bundle_lock);
 	head = xfrm_policy_sk_bundles;
-- 
1.7.0.1
